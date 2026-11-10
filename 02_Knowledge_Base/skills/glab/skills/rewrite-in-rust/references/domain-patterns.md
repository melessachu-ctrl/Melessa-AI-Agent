# Domain patterns

Project shapes the rewrite usually lands in, the quality gates specific to
each, and the pitfalls that show up most. For GitLab network services, also
read [gitlab-labkit-rs.md](gitlab-labkit-rs.md): the service skeletons below
get their logging, metrics, health, and lifecycle from labkit-rs rather than
hand-rolled code.

## Project shapes

### CLI tools

**Structure:**
```
cli-tool/
├── src/
│   ├── main.rs    # clap argument parsing
│   ├── lib.rs     # Core logic (testable)
│   └── commands/  # Subcommands
└── tests/
    └── cli/       # assert_cmd integration tests
```

**Crates:** `clap`, `anyhow`, `assert_cmd`

### Systems daemons

**Structure:**
```
daemon/
├── src/
│   ├── main.rs    # tokio runtime, signal handling
│   ├── server.rs  # Listener
│   └── worker.rs  # Background tasks
└── systemd/       # Service files
```

**Crates:** `tokio`, `nix` (privilege separation), `tracing`. A daemon that serves HTTP or gRPC at GitLab uses labkit-rs for the tracing setup.

**Privilege separation:**

```rust
use nix::unistd::{setuid, setgid};

#[tokio::main]
async fn main() -> Result<()> {
    let config = load_config()?;

    // Drop privileges before serving
    setgid(Gid::from_raw(config.gid))?;
    setuid(Uid::from_raw(config.uid))?;

    let server = Server::new(config).await?;
    server.run().await
}
```

### Network services

Generic axum skeleton. For a service that runs at GitLab, start from the
labkit-rs wiring in [gitlab-labkit-rs.md](gitlab-labkit-rs.md#wire-it-up)
instead: it adds logging, correlation IDs, metrics, probes, and graceful
shutdown that this skeleton leaves out.

```rust
use axum::{Router, routing::get, extract::State};
use std::sync::Arc;

#[derive(Clone)]
struct AppState {
    db: sqlx::PgPool,
}

#[tokio::main]
async fn main() -> Result<()> {
    let db = sqlx::PgPool::connect(&db_url).await?;
    let state = Arc::new(AppState { db });

    let app = Router::new()
        .route("/api/resource", get(handler))
        .with_state(state);

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await?;
    axum::serve(listener, app).await?;
    Ok(())
}
```

**Crates:** `axum`, `sqlx` (compile-time query checks), `tokio`

### Quality gates by shape

**GUI apps:** Cross-platform compilation, accessibility (screen readers), IME support, HiDPI rendering, dark/light mode, memory leak detection. See [gui-desktop-migration.md](gui-desktop-migration.md).

**TUI apps:** Terminal restore on panic, cross-platform key handling, responsive layout (80×24 min), view purity, alternate screen cleanup, color fallback. See [tui-ratatui-migration.md](tui-ratatui-migration.md).

**Async/tokio apps:** No blocking in async, minimal feature flags, graceful shutdown, backpressure control, tracing instrumentation, no nested runtimes, cancellation safety. See [tokio-async-migration.md](tokio-async-migration.md).

## Common pitfalls

**Don't transliterate:**

```rust
// Bad: Direct translation
let mut buffer: [u8; 1024] = [0; 1024];
let n = read_data(&mut buffer)?;

// Good: Idiomatic
let data = read_data_vec()?;
```

**Don't ignore errors:**

```rust
// Bad
config.unwrap()

// Good
config?
```

**Don't block async:**

```rust
// Bad: Blocks executor
async fn handler() {
    std::fs::read("file")?;
}

// Good: Async I/O
async fn handler() {
    tokio::fs::read("file").await?;
}
```

