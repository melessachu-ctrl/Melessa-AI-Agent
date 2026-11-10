# Migrating TUIs to Ratatui

## Overview

Ratatui is the dominant terminal user interface library in Rust, forked from `tui-rs` in
February 2023 and under active development. It uses an **immediate mode** rendering model
with double-buffered diff-based terminal output. This reference covers migrating existing TUI
applications (from any language or from tui-rs) to ratatui, with emphasis on The Elm
Architecture (TEA) as the recommended structural pattern.

### Key Facts

- Crate: `ratatui` (>30M downloads on crates.io)
- Backends: crossterm (default, cross-platform), termion (Unix), termwiz (cross-platform)
- Rendering: Immediate mode, double-buffered (only diffs sent to terminal)
- Architecture: Library, not framework — you own the event loop
- Forked from: `tui-rs` by Florian Dehau, February 2023

### References

- Ratatui website: https://ratatui.rs
- GitHub: https://github.com/ratatui/ratatui
- Widget examples: https://github.com/ratatui/ratatui/tree/main/examples
- App examples: https://github.com/ratatui/ratatui/tree/main/examples
- Awesome Ratatui: https://github.com/ratatui/awesome-ratatui
- Templates: https://github.com/ratatui/templates
- EuroRust 2024 talk: referenced on ratatui GitHub

---

## The Elm Architecture (TEA) for Ratatui

TEA is the **recommended** architecture for ratatui applications. It originates from the Elm
programming language and has been adopted by BubbleTea (Go), Iced (Rust GUI), and others.

### Core Components

```
┌─────────────────────────────────────────┐
│                                         │
│   ┌─────────┐    Message    ┌────────┐  │
│   │  Event   │─────────────▶│ Update │  │
│   │  Source  │              │  fn()  │  │
│   └─────────┘              └───┬────┘  │
│                                │        │
│                          mutates Model  │
│                                │        │
│   ┌─────────┐              ┌───▼────┐  │
│   │ Terminal │◀─────────────│  View  │  │
│   │  Output  │   renders    │  fn()  │  │
│   └─────────┘              └────────┘  │
│                                         │
└─────────────────────────────────────────┘
```

**Model**: The complete application state, stored in a single struct. All data your
application works with lives here.

**Update**: A pure-ish function that takes the current model and a message, then modifies
the model. This is where all state changes happen.

**View**: A pure function that takes the model and renders it to a `Frame`. For a given
state, it MUST always produce the same visual output. No side effects.

### Minimal TEA Implementation

```rust
use crossterm::event::{self, Event, KeyCode, KeyEventKind};
use ratatui::{
    prelude::*,
    widgets::{Block, Paragraph},
};

// ── Model ──────────────────────────────────────────────────
struct Model {
    counter: i32,
    running: bool,
}

impl Model {
    fn new() -> Self {
        Self { counter: 0, running: true }
    }
}

// ── Messages ───────────────────────────────────────────────
enum Message {
    Increment,
    Decrement,
    Quit,
}

// ── Update ─────────────────────────────────────────────────
fn update(model: &mut Model, msg: Message) -> Option<Message> {
    match msg {
        Message::Increment => model.counter += 1,
        Message::Decrement => model.counter -= 1,
        Message::Quit => model.running = false,
    }
    None // Return Some(Message) to chain updates
}

// ── View ───────────────────────────────────────────────────
fn view(model: &Model, frame: &mut Frame) {
    let text = format!("Counter: {} (j/k to change, q to quit)", model.counter);
    let paragraph = Paragraph::new(text)
        .block(Block::bordered().title("TEA Counter"));
    frame.render_widget(paragraph, frame.area());
}

// ── Event → Message mapping ────────────────────────────────
fn handle_event(event: &Event) -> Option<Message> {
    if let Event::Key(key) = event {
        if key.kind != KeyEventKind::Press { return None; }
        match key.code {
            KeyCode::Char('j') | KeyCode::Up => Some(Message::Increment),
            KeyCode::Char('k') | KeyCode::Down => Some(Message::Decrement),
            KeyCode::Char('q') | KeyCode::Esc => Some(Message::Quit),
            _ => None,
        }
    } else {
        None
    }
}

// ── Main loop ──────────────────────────────────────────────
fn main() -> color_eyre::Result<()> {
    color_eyre::install()?;
    let mut terminal = ratatui::init();
    let mut model = Model::new();

    while model.running {
        // View
        terminal.draw(|frame| view(&model, frame))?;

        // Event → Message → Update
        if event::poll(std::time::Duration::from_millis(16))? {
            let evt = event::read()?;
            if let Some(msg) = handle_event(&evt) {
                // Chain messages if update returns one
                let mut next = update(&mut model, msg);
                while let Some(msg) = next {
                    next = update(&mut model, msg);
                }
            }
        }
    }

    ratatui::restore();
    Ok(())
}
```

### TEA with Async (Tokio)

For applications that need background I/O, use tokio with crossterm's `event-stream` feature:

```toml
[dependencies]
ratatui = "0.30"
crossterm = { version = "0.29", features = ["event-stream"] }
tokio = { version = "1", features = ["rt-multi-thread", "macros", "time", "sync"] }
futures = "0.3"
color-eyre = "0.6"
```

```rust
use crossterm::event::{EventStream, KeyCode, KeyEventKind};
use futures::StreamExt;
use tokio::sync::mpsc;

enum Message {
    Key(crossterm::event::KeyEvent),
    Tick,
    DataLoaded(Vec<String>),
    Quit,
}

async fn run(mut terminal: ratatui::DefaultTerminal) -> color_eyre::Result<()> {
    let mut model = Model::new();
    let mut event_stream = EventStream::new();
    let mut tick_interval = tokio::time::interval(Duration::from_millis(250));
    let (bg_tx, mut bg_rx) = mpsc::unbounded_channel();

    loop {
        // View
        terminal.draw(|frame| view(&model, frame))?;

        // Select on multiple event sources
        let msg = tokio::select! {
            // Terminal events (key presses, mouse, resize)
            Some(Ok(event)) = event_stream.next() => {
                handle_event(&event)
            }
            // Background task results
            Some(msg) = bg_rx.recv() => Some(msg),
            // Periodic tick
            _ = tick_interval.tick() => Some(Message::Tick),
        };

        if let Some(msg) = msg {
            // Update can spawn background work via bg_tx
            if update(&mut model, msg, &bg_tx).should_quit() {
                break;
            }
        }
    }
    Ok(())
}
```

- Async counter tutorial: https://ratatui.rs/tutorials/counter-async-app/
- Async template: https://github.com/ratatui/templates
- Async event stream: https://ratatui.rs/tutorials/counter-async-app/async-event-stream/
- Full async events: https://ratatui.rs/tutorials/counter-async-app/full-async-events/

### TEA Frameworks for Ratatui

If you prefer a more opinionated framework layer on top of ratatui:

| Crate | Approach | Notes |
|-------|----------|-------|
| `tui-realm` | React+Elm inspired, component-based | v3.3, ~7K downloads/month, mountable components with properties/state |
| `ratatui-elm` | Iced-inspired TEA framework | Built-in terminal event subscription, re-renders only when needed |
| `tears` | TEA with subscriptions and commands | Requires Rust 2024 edition (1.86+), WebSocket and HTTP support |
| `teatui` | Minimal pure-functional TEA | Experimental, minimizes mutability |
| `rat-salsa` | Event queue with tasks and timers | Focus handling, dialog windows |

- tui-realm: https://github.com/veeso/tui-realm
- ratatui-elm: https://crates.io/crates/ratatui-elm
- tears: https://github.com/akiomik/tears
- BubbleTea (Go, original inspiration): https://github.com/charmbracelet/bubbletea

---

## Migration Strategies by Source

### From tui-rs (Rust)

Ratatui is a direct fork. Migration is mostly mechanical:

1. Replace `tui` dependency with `ratatui` in Cargo.toml
2. Replace `use tui::` with `use ratatui::` globally
3. Check breaking changes list: https://github.com/ratatui/ratatui/blob/main/BREAKING_CHANGES.md
4. The `Frame` type no longer requires a generic backend parameter (simplified)
5. `Terminal::new()` → `ratatui::init()` for quick setup (v0.28+)

### From ncurses/curses (C/C++/Python)

| ncurses Concept | Ratatui Equivalent |
|----------------|-------------------|
| `initscr()` / `endwin()` | `ratatui::init()` / `ratatui::restore()` |
| `mvprintw(y, x, str)` | `Paragraph::new(str)` rendered at `Rect` |
| `wrefresh(win)` | `terminal.draw(\|f\| ...)` (automatic) |
| `getch()` | `crossterm::event::read()` |
| Windows/panels | `Layout` with constraints + `Block` borders |
| `COLOR_PAIR` | `Style::new().fg(Color::Red).bg(Color::Blue)` |
| `attron(A_BOLD)` | `Style::new().bold()` |
| Pads (scrollable) | `Paragraph` with `.scroll((offset, 0))` |
| Forms | `tui-input`, `tui-textarea` crates |
| Menus | Custom widget or `tui-menu` crate |

### From BubbleTea (Go)

BubbleTea is the direct TEA inspiration. Mapping is close:

| BubbleTea (Go) | Ratatui + TEA (Rust) |
|----------------|---------------------|
| `type model struct` | `struct Model` |
| `type Msg interface{}` | `enum Message` |
| `func (m model) Init() tea.Cmd` | `Model::new()` + initial commands |
| `func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd)` | `fn update(model: &mut Model, msg: Message)` |
| `func (m model) View() string` | `fn view(model: &Model, frame: &mut Frame)` |
| `tea.Cmd` | `Option<Message>` or channel send |
| `lipgloss.Style` | `ratatui::style::Style` |
| `lipgloss.JoinHorizontal` | `Layout::horizontal([...])` |
| `tea.BatchMsg` | Multiple messages via channel |
| `tea.Quit` | Set `model.running = false` |

### From blessed/blessed-contrib (Node.js)

| blessed Concept | Ratatui Equivalent |
|----------------|-------------------|
| `screen.render()` | `terminal.draw(\|f\| ...)` |
| `box` widget | `Paragraph` + `Block` |
| `list` widget | `List` widget |
| `table` widget | `Table` widget |
| `gauge` widget | `Gauge` widget |
| `log` widget | `Paragraph` with scrollback buffer in model |
| `tree` widget | `tui-tree-widget` crate |
| `canvas` | `Canvas` widget |
| `sparkline` | `Sparkline` widget |
| `contrib.line` | `Chart` widget with `Dataset` |
| `element.on('click', cb)` | Check `Event::Mouse` in event handler |
| `screen.key(['q'], ...)` | Match `KeyCode::Char('q')` in event handler |

### From Python (urwid, textual, rich)

| Python TUI Concept | Ratatui Equivalent |
|--------------------|-------------------|
| `urwid.MainLoop` | Your own main loop (you own the event loop) |
| `urwid.Text` | `Paragraph` |
| `urwid.Columns` / `urwid.Pile` | `Layout::horizontal` / `Layout::vertical` |
| `textual.App.compose()` | `view()` function |
| `textual.App.on_key()` | Event handler → Message mapping |
| `textual.reactive` | Fields on `Model` struct |
| `rich.table.Table` | `Table` widget |
| `rich.progress.Progress` | `Gauge` widget |
| `rich.tree.Tree` | `tui-tree-widget` crate |

---

## Widget Ecosystem

### Core Ratatui Widgets

Built into `ratatui` itself:

`Paragraph`, `List`, `Table`, `Tabs`, `Block`, `Gauge`, `LineGauge`, `Sparkline`, `Chart`,
`BarChart`, `Canvas`, `Clear`, `Calendar`

### Essential Third-Party Widgets

| Crate | Purpose | Downloads |
|-------|---------|-----------|
| `tui-input` | Headless text input handling | High |
| `tui-textarea` | Multi-line text editor widget | High |
| `tui-tree-widget` | Tree view widget | Medium |
| `ratatui-image` | Image display (sixels, halfblocks) | Medium |
| `edtui` | Vim-inspired editor widget | Medium |
| `ratatui-explorer` | File explorer widget | Medium |
| `tui-big-text` | Large ASCII text (figlet-style) | Medium |
| `tui-scrollview` | Scrollable content area | Medium |
| `rat-widget` | Data input, tables, menus, file dialogs | Growing |
| `tui-logger` | Log viewer widget | Medium |

- Awesome ratatui (full widget list): https://github.com/ratatui/awesome-ratatui

---

## Terminal Setup and Teardown

### Reliable terminal management

```rust
use std::io;
use crossterm::{
    execute,
    terminal::{disable_raw_mode, enable_raw_mode,
               EnterAlternateScreen, LeaveAlternateScreen},
};

fn setup_terminal() -> color_eyre::Result<ratatui::DefaultTerminal> {
    // Install panic hook BEFORE entering raw mode
    color_eyre::install()?;

    // Custom panic hook that restores terminal
    let original_hook = std::panic::take_hook();
    std::panic::set_hook(Box::new(move |panic_info| {
        let _ = restore_terminal();
        original_hook(panic_info);
    }));

    let terminal = ratatui::init();
    Ok(terminal)
}

fn restore_terminal() -> color_eyre::Result<()> {
    ratatui::restore();
    Ok(())
}
```

### Cross-Platform Key Event Handling

```rust
// CRITICAL: Windows with crossterm sends both Press and Release events.
// Always filter for Press only to avoid double-processing.
fn handle_event(event: &Event) -> Option<Message> {
    match event {
        Event::Key(key) if key.kind == KeyEventKind::Press => {
            match key.code {
                KeyCode::Char('q') => Some(Message::Quit),
                KeyCode::Char(c) => Some(Message::CharInput(c)),
                KeyCode::Enter => Some(Message::Submit),
                KeyCode::Esc => Some(Message::Cancel),
                KeyCode::Up => Some(Message::NavigateUp),
                KeyCode::Down => Some(Message::NavigateDown),
                _ => None,
            }
        }
        Event::Resize(w, h) => Some(Message::Resize(*w, *h)),
        Event::Mouse(mouse) => handle_mouse(mouse),
        _ => None,
    }
}
```

---

## Layout Patterns

### Responsive Layouts

```rust
use ratatui::prelude::*;

fn view(model: &Model, frame: &mut Frame) {
    let area = frame.area();

    // Main vertical split
    let [header, body, footer] = Layout::vertical([
        Constraint::Length(3),      // Fixed header
        Constraint::Min(0),         // Body fills remaining
        Constraint::Length(1),      // Fixed footer
    ]).areas(area);

    // Body: sidebar + content
    let [sidebar, content] = Layout::horizontal([
        Constraint::Percentage(20), // 20% sidebar
        Constraint::Min(0),         // Remaining content
    ]).areas(body);

    // Render each area
    render_header(model, frame, header);
    render_sidebar(model, frame, sidebar);
    render_content(model, frame, content);
    render_footer(model, frame, footer);
}
```

### Popup/Modal Pattern

```rust
fn render_popup(frame: &mut Frame, content: &str) {
    let area = frame.area();
    // Center a 60x20 popup
    let popup_area = Rect {
        x: area.width.saturating_sub(60) / 2,
        y: area.height.saturating_sub(20) / 2,
        width: 60.min(area.width),
        height: 20.min(area.height),
    };

    // Clear the popup area first
    frame.render_widget(Clear, popup_area);

    let popup = Paragraph::new(content)
        .block(Block::bordered().title("Confirm"))
        .wrap(Wrap { trim: true });
    frame.render_widget(popup, popup_area);
}
```

---

## Component Architecture (for complex apps)

For larger applications, organize TEA hierarchically with components:

```rust
// Each component has its own Model, Message, update, and view

trait Component {
    type Message;

    fn update(&mut self, msg: Self::Message) -> Option<AppMessage>;
    fn view(&self, frame: &mut Frame, area: Rect);
}

// ── Sidebar component ──
struct Sidebar {
    items: Vec<String>,
    selected: usize,
}

enum SidebarMessage {
    SelectNext,
    SelectPrevious,
    Confirm,
}

impl Component for Sidebar {
    type Message = SidebarMessage;

    fn update(&mut self, msg: SidebarMessage) -> Option<AppMessage> {
        match msg {
            SidebarMessage::SelectNext => {
                self.selected = (self.selected + 1).min(self.items.len() - 1);
                None
            }
            SidebarMessage::SelectPrevious => {
                self.selected = self.selected.saturating_sub(1);
                None
            }
            SidebarMessage::Confirm => {
                // Bubble up to parent
                Some(AppMessage::ItemSelected(self.selected))
            }
        }
    }

    fn view(&self, frame: &mut Frame, area: Rect) {
        let items: Vec<ListItem> = self.items.iter()
            .map(|i| ListItem::new(i.as_str()))
            .collect();

        let list = List::new(items)
            .block(Block::bordered().title("Items"))
            .highlight_style(Style::new().reversed());

        let mut state = ListState::default().with_selected(Some(self.selected));
        frame.render_stateful_widget(list, area, &mut state);
    }
}
```

---

## Quality Gates

| Gate | Check | Tool | Phase |
|------|-------|------|-------|
| Terminal restore on panic | Panic hook restores terminal state | Manual test: trigger panic, verify terminal | Setup |
| Cross-platform key handling | Filter `KeyEventKind::Press` only | Code review, test on Windows | Every PR |
| Responsive layout | UI renders correctly at 80×24 minimum | Test with `resize` events | Every PR |
| View function purity | `view()` has no side effects, only reads model | Code review | Every PR |
| No blocking in event loop | Event loop doesn't block > 16ms (60fps) | Profiling, `tracing` | Performance |
| Alternate screen cleanup | `LeaveAlternateScreen` always called on exit | Test all exit paths (quit, panic, Ctrl+C, SIGTERM) | Pre-release |
| Widget rendering | All widgets render without panic at any terminal size | Fuzz terminal dimensions | Pre-release |
| Color fallback | Graceful degradation for terminals without color | Test with `TERM=dumb` | Pre-release |
| Accessibility | Text-based output works with screen readers | Manual test | Pre-release |
| Event handling coverage | All key bindings tested | Unit tests on `handle_event` | Every PR |

---

## Guardrails

### Compile-Time Enforcements

```rust
// Enforce that view is pure by taking &Model (not &mut Model)
fn view(model: &Model, frame: &mut Frame) { /* ... */ }

// Enforce message-based state changes via enum
// (compiler ensures all variants handled in update)
#[derive(Debug)]
enum Message {
    Increment,
    Decrement,
    Quit,
    // Adding a variant forces handling in update()
}

fn update(model: &mut Model, msg: Message) -> Option<Message> {
    match msg {
        // Compiler warns if not exhaustive
        Message::Increment => model.counter += 1,
        Message::Decrement => model.counter -= 1,
        Message::Quit => model.running = false,
    }
    None
}
```

### Testing Strategy

```rust
// Test the update function in isolation (pure logic)
#[test]
fn test_increment() {
    let mut model = Model::new();
    update(&mut model, Message::Increment);
    assert_eq!(model.counter, 1);
}

#[test]
fn test_quit() {
    let mut model = Model::new();
    assert!(model.running);
    update(&mut model, Message::Quit);
    assert!(!model.running);
}

// Test event → message mapping
#[test]
fn test_key_mapping() {
    use crossterm::event::{Event, KeyCode, KeyEvent, KeyModifiers, KeyEventKind, KeyEventState};
    let key = Event::Key(KeyEvent::new(KeyCode::Char('q'), KeyModifiers::NONE));
    assert!(matches!(handle_event(&key), Some(Message::Quit)));
}

// Test view rendering (snapshot tests with insta)
#[test]
fn test_view_rendering() {
    let model = Model { counter: 42, running: true };
    let backend = ratatui::backend::TestBackend::new(80, 24);
    let mut terminal = ratatui::Terminal::new(backend).unwrap();
    terminal.draw(|frame| view(&model, frame)).unwrap();
    let buffer = terminal.backend().buffer().clone();
    // Use insta for snapshot testing
    insta::assert_debug_snapshot!(buffer);
}
```

### CI Configuration

```yaml
# .github/workflows/ci.yml
- name: Test TUI
  run: cargo test

- name: Check minimum terminal size
  run: |
    # Ensure app handles 80x24 minimum
    cargo test -- --test-threads=1 test_minimum_size

- name: Clippy
  run: cargo clippy -- -D warnings
```

---

## Notable Ratatui Applications (Migration References)

These real-world applications demonstrate ratatui patterns at scale:

| Application | Category | Architecture Notes |
|-------------|----------|-------------------|
| `gitui` | Git TUI | Component-based, async git operations |
| `spotify-player` | Music player | Async (tokio), MPRIS integration |
| `yazi` | File manager | Async, plugin system, actor pattern |
| `bottom` (`btm`) | System monitor | Real-time data, multiple views |
| `oatmeal` | LLM chat client | Streaming async, text input |
| `lazydocker` (Rust) | Docker management | Component hierarchy |
| `atac` | API client | Complex forms, tabs, async HTTP |

- Showcase: https://ratatui.rs/showcase/
- Awesome ratatui apps: https://github.com/ratatui/awesome-ratatui

---

## Further Resources

- Ratatui official docs: https://ratatui.rs
- TEA architecture guide: https://ratatui.rs/concepts/application-patterns/the-elm-architecture/
- Event handling concepts: https://ratatui.rs/concepts/event-handling/
- Elm Architecture original: https://guide.elm-lang.org/architecture/
- Best practices discussion: https://github.com/ratatui/ratatui/discussions/220
- FAQ (including async advice): https://ratatui.rs/faq/
- BubbleTea tutorials (concept transfer): https://github.com/charmbracelet/bubbletea/tree/main/tutorials
