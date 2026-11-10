# Migrating GUI Desktop Applications to Rust

## Overview

The Rust GUI ecosystem is maturing rapidly but remains fragmented. This reference covers
migrating existing desktop GUI applications to Rust, with detailed guidance on toolkit
selection, crate recommendations for desktop integration (system tray, D-Bus, video playback),
and migration strategies from common source platforms.

### Ecosystem Status (2025)

A 2025 survey by boringcactus evaluated 43 Rust GUI crates against three
criteria: basic functionality, screen reader accessibility, and IME (Input Method) support.

**Production-ready with accessibility + IME**: GTK 4 (gtk-rs), Relm4, FLTK, Slint, Dioxus,
WinSafe, GPUI

**Production-ready, partial accessibility**: egui, Iced, Tauri

**Promising but pre-1.0**: Xilem, Floem, Freya, Makepad

- 2025 Survey: https://www.boringcactus.com/2025/04/13/2025-survey-of-rust-gui-libraries.html
- Are We GUI Yet: https://areweguiyet.com/
- LogRocket comparison: https://blog.logrocket.com/state-rust-gui-libraries/

---

## Toolkit Decision Framework

```
Answer each question to narrow your choice:

1. What platform(s) must you support?
   └─ Linux only → GTK 4 (gtk-rs) or Relm4
   └─ Linux + Windows + macOS → See question 2
   └─ Embedded/constrained → Slint

2. Does the app need native look-and-feel?
   └─ Yes, native widgets → GTK 4 (Linux), or Tauri (native webview)
   └─ No, custom rendering OK → Iced, egui, Slint

3. Does the team have web frontend experience?
   └─ Yes → Tauri (HTML/CSS/JS frontend) or Dioxus (React-like Rust)
   └─ No → See question 4

4. How complex is the UI?
   └─ Simple tools/debug UI → egui (immediate mode, simplest API)
   └─ Medium complexity → Iced (Elm architecture, good structure)
   └─ Complex forms/data → GTK 4 + Relm4, or Slint
   └─ Existing Qt/QML codebase → CXX-Qt (incremental migration)

5. Is screen reader accessibility required?
   └─ Yes → GTK 4, Slint, Dioxus, FLTK, or WinSafe
   └─ No → Any of the above
```

---

## GTK 4 with gtk-rs

### When to Use

GTK 4 is the strongest choice for **Linux-native** desktop applications. It provides mature
widgets, excellent accessibility, proper IME support, and is the native toolkit for GNOME.
Cross-platform support exists but GTK looks non-native on Windows and macOS.

### Key Crates

| Crate | Purpose | Notes |
|-------|---------|-------|
| `gtk4` | GTK 4 Rust bindings | Core widget toolkit |
| `libadwaita` | GNOME Adwaita widgets + styling | Modern GNOME look, dark mode |
| `glib` | GLib bindings (event loop, signals) | Foundation for all GNOME bindings |
| `gio` | GIO bindings (async I/O, settings) | File operations, app settings |
| `gdk4` | GDK 4 (display, input, rendering) | Low-level display abstraction |
| `cairo-rs` | Cairo 2D rendering | Custom drawing |
| `pango` | Text rendering/layout | Complex text, i18n |
| `sourceview5` | Source code editor widget | Syntax highlighting, line numbers |
| `webkit6` | WebKitGTK bindings | Embedded web content |

- gtk-rs website: https://gtk-rs.org/
- gtk-rs book: https://gtk-rs.org/gtk4-rs/stable/latest/book/
- GNOME Rust bindings GitLab: https://gitlab.gnome.org/World/Rust

### Minimal GTK 4 Application

```rust
use gtk4 as gtk;
use gtk::prelude::*;
use gtk::{glib, Application, ApplicationWindow, Button};

const APP_ID: &str = "com.example.MyApp";

fn main() -> glib::ExitCode {
    let app = Application::builder()
        .application_id(APP_ID)
        .build();

    app.connect_activate(build_ui);
    app.run()
}

fn build_ui(app: &Application) {
    let button = Button::with_label("Click me!");
    button.connect_clicked(|button| {
        button.set_label("Clicked!");
    });

    let window = ApplicationWindow::builder()
        .application(app)
        .title("My GTK App")
        .child(&button)
        .build();

    window.present();
}
```

```toml
[dependencies]
gtk4 = "0.9"
# Optional: For modern GNOME styling
libadwaita = "0.7"
```

### Relm4: Elm Architecture for GTK 4

Relm4 wraps GTK 4 with an Elm/React-inspired component model. **Recommended over raw gtk-rs**
for applications with complex state management:

```rust
use relm4::prelude::*;
use gtk::prelude::*;

struct App {
    counter: u8,
}

#[derive(Debug)]
enum Msg {
    Increment,
    Decrement,
}

#[relm4::component]
impl SimpleComponent for App {
    type Init = u8;
    type Input = Msg;
    type Output = ();

    view! {
        gtk::Window {
            set_title: Some("Relm4 Counter"),
            gtk::Box {
                set_orientation: gtk::Orientation::Vertical,
                set_spacing: 5,

                gtk::Button {
                    set_label: "Increment",
                    connect_clicked => Msg::Increment,
                },
                gtk::Label {
                    #[watch]
                    set_label: &format!("Counter: {}", model.counter),
                },
                gtk::Button {
                    set_label: "Decrement",
                    connect_clicked => Msg::Decrement,
                },
            }
        }
    }

    fn init(counter: Self::Init, root: Self::Root,
            sender: ComponentSender<Self>) -> ComponentParts<Self> {
        let model = App { counter };
        let widgets = view_output!();
        ComponentParts { model, widgets }
    }

    fn update(&mut self, msg: Self::Input, _sender: ComponentSender<Self>) {
        match msg {
            Msg::Increment => self.counter = self.counter.wrapping_add(1),
            Msg::Decrement => self.counter = self.counter.wrapping_sub(1),
        }
    }
}

fn main() {
    let app = RelmApp::new("com.example.relm4");
    app.run::<App>(0);
}
```

- Relm4: https://relm4.org/
- Relm4 book: https://relm4.org/book/stable/
- Relm4 GitHub: https://github.com/Relm4/Relm4

---

## Qt with CXX-Qt

### When to Use

CXX-Qt is the right choice when:
- Migrating an existing Qt/QML application incrementally to Rust
- You need QML for the UI but want Rust for business logic
- Your team has Qt expertise
- You need Qt's widget ecosystem (charts, 3D, multimedia)

CXX-Qt is maintained by **KDAB** (premier Qt consulting firm), has stabilized its bridge
macro API in v0.7, and supports both Qt 5 and Qt 6.

**Important limitation**: CXX-Qt lets you implement QObject subclasses in Rust. It does NOT
provide Rust bindings for QWidgets API directly — you use QML or C++ for the widget layer.

### Key Crates

| Crate | Purpose |
|-------|---------|
| `cxx-qt` | Bridge macro for QObject subclasses in Rust |
| `cxx-qt-lib` | Rust types for common Qt types (QString, QColor, QVariant) |
| `cxx-qt-build` | Build script for generating C++ from Rust bridge definitions |

### CXX-Qt Bridge Example

```rust
#[cxx_qt::bridge]
mod qobject {
    unsafe extern "C++" {
        include!("cxx-qt-lib/qstring.h");
        type QString = cxx_qt_lib::QString;
    }

    unsafe extern "RustQt" {
        #[qobject]
        #[qml_element]
        #[qproperty(i32, counter)]
        #[qproperty(QString, message)]
        type MyObject = super::MyObjectRust;

        #[qinvokable]
        fn increment(self: Pin<&mut MyObject>);
    }
}

use core::pin::Pin;
use cxx_qt_lib::QString;

#[derive(Default)]
pub struct MyObjectRust {
    counter: i32,
    message: QString,
}

impl qobject::MyObject {
    fn increment(self: Pin<&mut Self>) {
        let new_count = self.counter() + 1;
        self.set_counter(new_count);
        self.set_message(QString::from(
            &format!("Count: {new_count}")
        ));
    }
}
```

- CXX-Qt GitHub: https://github.com/KDAB/cxx-qt
- CXX-Qt Book: https://kdab.github.io/cxx-qt/book/
- CXX-Qt 0.7 release: https://www.kdab.com/cxx-qt-0-7/
- Rust Foundation article: https://rustfoundation.org/media/best-practices-for-integrating-rust-and-qt-in-embedded-systems/
- KDAB blog: https://www.kdab.com/cxx-qt/

---

## Other GUI Frameworks

### Iced (Elm Architecture, Pure Rust)

Cross-platform GPU-rendered GUI with Elm architecture. No native widgets.

```rust
use iced::widget::{button, column, text};
use iced::{Element, Task};

#[derive(Default)]
struct Counter {
    value: i32,
}

#[derive(Debug, Clone)]
enum Message {
    Increment,
    Decrement,
}

impl Counter {
    fn update(&mut self, message: Message) -> Task<Message> {
        match message {
            Message::Increment => self.value += 1,
            Message::Decrement => self.value -= 1,
        }
        Task::none()
    }

    fn view(&self) -> Element<Message> {
        column![
            button("+").on_press(Message::Increment),
            text(self.value),
            button("-").on_press(Message::Decrement),
        ].into()
    }
}
```

- Iced: https://github.com/iced-rs/iced

### egui (Immediate Mode, Pure Rust)

Simplest Rust GUI. Immediate mode (rebuild UI every frame). Best for tools, debug UIs, game
editors.

```rust
use eframe::egui;

struct MyApp { counter: i32 }

impl eframe::App for MyApp {
    fn update(&mut self, ctx: &egui::Context, _frame: &mut eframe::Frame) {
        egui::CentralPanel::default().show(ctx, |ui| {
            if ui.button("Increment").clicked() {
                self.counter += 1;
            }
            ui.label(format!("Counter: {}", self.counter));
        });
    }
}
```

- egui: https://github.com/emilk/egui

### Slint (DSL-based, Commercial-friendly)

Declarative DSL, designed for embedded and desktop. Requires commercial license for closed-source.

- Slint: https://slint.dev/
- Slint GitHub: https://github.com/slint-ui/slint

### Tauri (Web Frontend, Rust Backend)

Uses system webview (WebView2/WebKitGTK) instead of bundled Chromium. Write frontend in any
web framework (React, Svelte, Vue), backend in Rust.

- Tauri: https://tauri.app/
- Tauri GitHub: https://github.com/tauri-apps/tauri

### Dioxus (React-like, Pure Rust)

React-inspired framework targeting desktop, web, and mobile. Uses system webview for
rendering.

- Dioxus: https://dioxuslabs.com/
- Dioxus GitHub: https://github.com/DioxusLabs/dioxus

---

## Desktop Integration Crates

### System Tray Icons

| Crate | Platform | Notes |
|-------|----------|-------|
| `tray-icon` | Windows, macOS, Linux (GTK) | From Tauri team, most actively maintained |
| `system-tray` | Linux (D-Bus StatusNotifierItem) | Async (tokio), for custom tray implementations |
| `ksni` | Linux (StatusNotifierItem) | Pure Rust SNI implementation |

**`tray-icon`** is the recommended cross-platform choice:

```rust
use tray_icon::{TrayIconBuilder, menu::{Menu, MenuItem}};

fn create_tray() -> tray_icon::TrayIcon {
    let menu = Menu::new();
    let quit_item = MenuItem::new("Quit", true, None);
    menu.append(&quit_item).unwrap();

    TrayIconBuilder::new()
        .with_menu(Box::new(menu))
        .with_tooltip("My Application")
        .with_icon(load_icon()) // Icon from embedded resource
        .build()
        .unwrap()
}
```

**Platform requirements**:
- **Linux**: Requires GTK event loop, plus `libappindicator3` or `libayatana-appindicator3`
- **Windows**: Requires Win32 event loop on the tray thread
- **macOS**: Must be on main thread with event loop

- tray-icon: https://crates.io/crates/tray-icon
- system-tray: https://crates.io/crates/system-tray
- muda (menu library, used by tray-icon): https://github.com/tauri-apps/muda

### D-Bus Integration

| Crate | Approach | Notes |
|-------|----------|-------|
| `zbus` | Pure Rust, async-first | **Recommended**. tokio + async-std support. Most idiomatic |
| `dbus` | libdbus bindings | Older, requires C library |
| `dbus-crossroads` | High-level server on `dbus` | Easier server implementation |

**`zbus`** is the recommended D-Bus crate (pure Rust, no C dependencies):

```rust
use zbus::{Connection, proxy};

// Define a proxy for an existing D-Bus service
#[proxy(
    interface = "org.freedesktop.Notifications",
    default_service = "org.freedesktop.Notifications",
    default_path = "/org/freedesktop/Notifications"
)]
trait Notifications {
    fn notify(
        &self,
        app_name: &str,
        replaces_id: u32,
        app_icon: &str,
        summary: &str,
        body: &str,
        actions: &[&str],
        hints: std::collections::HashMap<&str, zbus::zvariant::Value<'_>>,
        expire_timeout: i32,
    ) -> zbus::Result<u32>;
}

async fn send_notification() -> zbus::Result<()> {
    let connection = Connection::session().await?;
    let proxy = NotificationsProxy::new(&connection).await?;
    proxy.notify(
        "MyApp", 0, "", "Hello", "World!",
        &[], std::collections::HashMap::new(), 5000,
    ).await?;
    Ok(())
}
```

**Exposing a D-Bus service**:

```rust
use zbus::{interface, ConnectionBuilder};

struct MyService {
    count: u32,
}

#[interface(name = "com.example.MyService")]
impl MyService {
    fn increment(&mut self) -> u32 {
        self.count += 1;
        self.count
    }

    #[zbus(property)]
    fn count(&self) -> u32 {
        self.count
    }
}

async fn run_service() -> zbus::Result<()> {
    let service = MyService { count: 0 };
    let _conn = ConnectionBuilder::session()?
        .name("com.example.MyService")?
        .serve_at("/com/example/MyService", service)?
        .build()
        .await?;
    std::future::pending::<()>().await;
    Ok(())
}
```

- zbus: https://github.com/dbus2/zbus
- zbus book: https://dbus2.github.io/zbus/
- dbus crate: https://github.com/diwic/dbus-rs

### MPRIS (Media Player Remote Interface)

MPRIS is the standard D-Bus interface for controlling media players on Linux.

| Crate | Direction | Notes |
|-------|-----------|-------|
| `mpris-server` | Implement MPRIS in your player | Built on zbus, async |
| `mpris` | Control other MPRIS players | Client library, idiomatic Rust |

**Implementing MPRIS in your application** (so desktop environments can control it):

```rust
use mpris_server::{zbus::Result, Player, Time};

async fn setup_mpris() -> Result<Player> {
    let player = Player::builder("com.example.MyPlayer")
        .can_play(true)
        .can_pause(true)
        .can_seek(true)
        .build()
        .await?;

    player.connect_play_pause(|_player| {
        println!("Play/Pause toggled");
    });

    player.connect_next(|_player| {
        println!("Next track");
    });

    Ok(player)
}
```

**Controlling other media players**:

```rust
use mpris::PlayerFinder;

fn control_player() -> Result<(), mpris::FindingError> {
    let player = PlayerFinder::new()?.find_active()?;
    println!("Playing: {:?}", player.get_metadata()?.title());
    player.play_pause()?;
    Ok(())
}
```

- mpris-server: https://crates.io/crates/mpris-server
- mpris (client): https://crates.io/crates/mpris
- mpris-rs GitHub: https://github.com/Mange/mpris-rs
- MPRIS spec: https://specifications.freedesktop.org/mpris-spec/latest/

### Video Playback

| Crate | Backend | Notes |
|-------|---------|-------|
| `gstreamer` (gstreamer-rs) | GStreamer | **Recommended**. Full multimedia pipeline. Supports HW accel |
| `gstreamer-video` | GStreamer video | Video-specific types and traits |
| `gstreamer-player` | GStreamer Player | High-level playback API |
| `libmpv` / `mpv` | mpv library | Embed mpv player. Good for simple playback |

**GStreamer** is the recommended choice for video in Rust GUI applications:

```rust
use gstreamer as gst;
use gst::prelude::*;

fn play_video(uri: &str) -> Result<(), Box<dyn std::error::Error>> {
    gst::init()?;

    let pipeline = gst::parse::launch(
        &format!("playbin uri={uri}")
    )?;

    pipeline.set_state(gst::State::Playing)?;

    let bus = pipeline.bus().unwrap();
    for msg in bus.iter_timed(gst::ClockTime::NONE) {
        match msg.view() {
            gst::MessageView::Eos(..) => break,
            gst::MessageView::Error(err) => {
                eprintln!("Error: {:?}", err.error());
                break;
            }
            _ => (),
        }
    }

    pipeline.set_state(gst::State::Null)?;
    Ok(())
}
```

**GStreamer + GTK 4** integration (for embedding video in a GTK window):

```rust
// Use gstreamer's gtksink for native GTK 4 video rendering
use gstreamer as gst;
use gtk4 as gtk;

fn create_video_widget() -> gtk::Widget {
    let pipeline = gst::parse::launch(
        "playbin uri=file:///path/to/video.mp4 video-sink=gtk4paintablesink"
    ).unwrap();

    // Get the paintable from the sink
    let sink = pipeline
        .downcast_ref::<gst::Bin>().unwrap()
        .by_name("gtk4paintablesink0").unwrap();
    let paintable = sink.property::<gdk4::Paintable>("paintable");

    // Create a GTK Picture widget
    let picture = gtk::Picture::for_paintable(&paintable);
    picture.into()
}
```

**System dependencies for GStreamer**:

```bash
# Debian/Ubuntu
apt install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
    gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav

# Fedora
dnf install gstreamer1-devel gstreamer1-plugins-base-devel \
    gstreamer1-plugins-good gstreamer1-plugins-bad-free gstreamer1-plugins-ugly

# macOS
brew install gstreamer
# OR download official .pkg from https://gstreamer.freedesktop.org/

# Windows
# Download official .msi from https://gstreamer.freedesktop.org/
```

- gstreamer-rs: https://gitlab.freedesktop.org/gstreamer/gstreamer-rs
- gstreamer-rs docs: https://gstreamer.pages.freedesktop.org/gstreamer-rs/stable/latest/docs/gstreamer/
- GStreamer Rust plugins: https://github.com/GStreamer/gst-plugins-rs
- GStreamer tutorials (Rust): https://gitlab.freedesktop.org/gstreamer/gstreamer-rs/-/tree/main/tutorials

### Additional Desktop Integration

| Domain | Crate | Notes |
|--------|-------|-------|
| **Notifications** | `notify-rust` | Desktop notifications (Linux/macOS/Windows) |
| **File dialogs** | `rfd` (Rusty File Dialogs) | Native file open/save dialogs, cross-platform |
| **Clipboard** | `arboard` | Cross-platform clipboard (text + images) |
| **Global hotkeys** | `global-hotkey` | System-wide keyboard shortcuts (from Tauri team) |
| **Keyring/secrets** | `keyring` | OS credential storage (Keychain, Secret Service, Credential Manager) |
| **Auto-launch** | `auto-launch` | Start app on login |
| **Single instance** | `single-instance` | Prevent multiple app instances |
| **Screen capture** | `screenshots` | Cross-platform screenshot capture |
| **Window management** | `winit` | Cross-platform window creation (used by iced, egui) |
| **Settings/config** | `directories` + `confy` | XDG-compliant config/data paths + serialized config |

---

## Migration Strategies by Source Framework

### From GTK 3 (Python/C) → GTK 4 (Rust)

1. Port UI from GTK 3 to GTK 4 first (even in the original language) — the GTK 3→4 migration
   guide is substantial
2. Rewrite business logic in Rust, exposing via GObject if needed
3. Port UI layer to gtk-rs / Relm4
4. GTK 3→4 changes: `GtkContainer` removed, `GtkBox` packing API changed, CSS node changes,
   `GtkTreeView` → `GtkColumnView`

### From Qt/QML (C++) → CXX-Qt (Rust)

Use the strangler fig approach:
1. Keep existing QML UI
2. Identify QObject subclasses with heavy business logic
3. Reimplement those in Rust using CXX-Qt bridge
4. QML continues to work — it sees Rust QObjects identically to C++ ones
5. Gradually migrate more QObjects to Rust

### From Electron/Web → Tauri

1. Keep your existing web frontend (React, Vue, Svelte)
2. Replace Electron's Node.js backend with Rust (Tauri commands)
3. Replace Electron APIs: file system → `tauri::api::path`, shell → `tauri::api::shell`,
   dialogs → `tauri::api::dialog`
4. Remove Chromium dependency — Tauri uses system webview

### From wxWidgets/FLTK → fltk-rs or Native Rust

FLTK has direct Rust bindings (`fltk-rs`) that closely mirror the C++ API:

```rust
use fltk::{app, button::Button, frame::Frame, prelude::*, window::Window};

fn main() {
    let app = app::App::default();
    let mut win = Window::new(100, 100, 400, 300, "FLTK in Rust");
    let mut frame = Frame::new(0, 0, 400, 200, "");
    let mut btn = Button::new(160, 210, 80, 40, "Click");
    win.end();
    win.show();

    btn.set_callback(move |_| frame.set_label("Clicked!"));
    app.run().unwrap();
}
```

- fltk-rs: https://github.com/fltk-rs/fltk-rs

---

## Quality Gates

| Gate | Check | Tool | Phase |
|------|-------|------|-------|
| Cross-platform compilation | Builds on Linux, macOS, Windows | CI matrix | Every PR |
| System dependency documented | All required C libraries listed | README / build docs | Setup |
| Accessibility | Screen reader can navigate core UI | Manual test (NVDA/Orca/VoiceOver) | Pre-release |
| IME support | Japanese/Chinese/Korean input works | Manual test | Pre-release |
| HiDPI rendering | UI scales correctly at 150%/200% | Manual test | Pre-release |
| Theme support | Respects system dark/light mode | Manual test | Pre-release |
| Memory: no leaks | No growing RSS over time | `valgrind` / `heaptrack` | Pre-release |
| Window resize | UI reflows correctly at all reasonable sizes | Manual test | Every PR |
| Graceful degradation | Works if optional features unavailable (tray, D-Bus) | Manual test | Pre-release |
| Clean shutdown | No zombie processes, temp files cleaned | `strace`, manual | Pre-release |

---

## Guardrails

### Dependency Management for GUI

GUI applications pull in many system dependencies. Document them clearly:

```toml
# Cargo.toml — Document what's needed
[package.metadata.docs.rs]
# System libraries required:
# Debian/Ubuntu: libgtk-4-dev libadwaita-1-dev
# Fedora: gtk4-devel libadwaita-devel
# macOS: brew install gtk4 libadwaita
```

### Build Script Validation

```rust
// build.rs — Verify system dependencies early
fn main() {
    // pkg-config will fail with a clear message if library is missing
    #[cfg(target_os = "linux")]
    {
        pkg_config::probe_library("gtk4").expect(
            "GTK 4 not found. Install with: apt install libgtk-4-dev"
        );
    }
}
```

### Thread Safety for GUI

Most GUI toolkits require UI operations on the main thread:

```rust
// GTK: Use glib::MainContext for async operations
glib::spawn_future_local(async move {
    let data = fetch_data().await;
    // Safe to update GTK widgets here — we're on the main thread
    label.set_text(&data);
});

// For background work that updates UI:
let (tx, rx) = glib::MainContext::channel(glib::Priority::DEFAULT);
std::thread::spawn(move || {
    let result = heavy_computation();
    tx.send(result).unwrap();
});
rx.attach(None, move |result| {
    label.set_text(&result);
    glib::ControlFlow::Continue
});
```

---

## Further Resources

- Are We GUI Yet: https://areweguiyet.com/
- 2025 GUI Survey: https://www.boringcactus.com/2025/04/13/2025-survey-of-rust-gui-libraries.html
- gtk-rs book: https://gtk-rs.org/gtk4-rs/stable/latest/book/
- Relm4 book: https://relm4.org/book/stable/
- CXX-Qt book: https://kdab.github.io/cxx-qt/book/
- Tauri guides: https://tauri.app/start/
- zbus book: https://dbus2.github.io/zbus/
- GStreamer Rust tutorials: https://gitlab.freedesktop.org/gstreamer/gstreamer-rs
- notify-rust: https://github.com/hoodie/notify-rust
- rfd (file dialogs): https://github.com/PolyMeilex/rfd
- arboard (clipboard): https://github.com/1Password/arboard
- tray-icon: https://crates.io/crates/tray-icon
