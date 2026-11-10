# Migrating to Tokio & Async Rust

## When to Use Async

Async Rust with Tokio is the right choice when the program spends significant time waiting on
I/O — network requests, database queries, file operations, or external processes. It is NOT
the right choice for pure CPU-bound computation (use `rayon` instead) or simple CLI tools with
sequential logic.

### Decision Framework

```
Score each factor 0-3:

  + Network I/O (HTTP, TCP, UDP, WebSocket)         ___
  + Database queries                                 ___
  + File I/O with many concurrent files              ___
  + Multiple external service calls                  ___
  + Event-driven architecture (servers, daemons)     ___
  + Need to handle many concurrent connections       ___
                                          Subtotal = ___

  - Pure CPU-bound computation                       ___
  - Simple sequential CLI tool                       ___
  - Tight real-time constraints (< 1ms latency)      ___
  - Team has zero async Rust experience              ___
                                          Subtotal = ___

  Net score (positive minus negative):
    >= 6:  Strong case for tokio async
    3-5:   Consider async for I/O-heavy components
    0-2:   Sync is likely simpler and sufficient
    < 0:   Stay synchronous
```

### Reference: Production Tokio Migrations

| Project | Migration Type | Outcome |
|---------|---------------|---------|
| Cloudflare Pingora | Nginx C → async Rust | 70% CPU reduction, 1T+ req/day |
| Discord | Go → async Rust | Eliminated GC tail latency spikes |
| Linkerd2-proxy | Service mesh proxy | Sub-millisecond p99 latency |
| Deno | Node.js-style runtime | Built entirely on tokio |
| Axum/Hyper | HTTP framework stack | De facto standard async web stack |

- Tokio GitHub: https://github.com/tokio-rs/tokio
- Tokio tutorial: https://tokio.rs/tokio/tutorial
- Axum framework: https://github.com/tokio-rs/axum
- Bridging sync/async: https://tokio.rs/tokio/topics/bridging

---

## Phase 1: Understand the Async Model

### Core Concepts

Tokio is an event-driven, non-blocking I/O runtime. Key mental model differences from
synchronous code:

1. **Futures are lazy**: They do nothing until `.await`ed or spawned
2. **Function coloring**: `async fn` cannot be called from sync context without a runtime
3. **Cooperative scheduling**: Tasks must yield (via `.await`) — blocking the thread blocks ALL
   tasks on that thread
4. **`Send + 'static` bounds**: `tokio::spawn` requires the future to be `Send + 'static`
   because it may run on any worker thread

```rust
// WRONG: Blocking the tokio runtime thread
async fn bad_example() {
    std::thread::sleep(Duration::from_secs(5)); // Blocks the entire worker!
}

// RIGHT: Use tokio's async sleep
async fn good_example() {
    tokio::time::sleep(Duration::from_secs(5)).await; // Yields to other tasks
}
```

### Runtime Configuration

```rust
// Full multi-threaded runtime (most common for servers)
#[tokio::main]
async fn main() {
    // ...
}

// Equivalent manual setup — useful for customization
fn main() {
    tokio::runtime::Builder::new_multi_thread()
        .worker_threads(4)          // Default: num CPUs
        .max_blocking_threads(512)  // For spawn_blocking pool
        .enable_all()               // Enable I/O + timers
        .build()
        .unwrap()
        .block_on(async { /* ... */ })
}

// Single-threaded runtime (simpler, no Send requirement)
#[tokio::main(flavor = "current_thread")]
async fn main() {
    // Tasks don't need to be Send
}
```

**Feature flags**: Don't use `features = ["full"]` in production. Specify exactly what you need
to reduce compile time and binary size:

```toml
[dependencies]
tokio = { version = "1", features = ["rt-multi-thread", "macros", "net", "io-util", "time", "sync"] }
```

- Tokio features reference: https://docs.rs/tokio/latest/tokio/#feature-flags

---

## Phase 2: Incremental Migration Strategy

### The Strangler Fig for Async

NEVER attempt a big-bang sync→async conversion. Migrate incrementally:

```
Phase 1: Add tokio as dependency, keep everything sync
Phase 2: Identify I/O-heavy leaf functions → make async
Phase 3: Bridge async into sync callers with block_on / spawn_blocking
Phase 4: Push async boundary upward toward main()
Phase 5: Make main() async with #[tokio::main]
Phase 6: Remove bridging code, full async
```

### Bridging Patterns

#### Calling Async from Sync (during migration)

```rust
use tokio::runtime::Runtime;

// Option 1: Create a runtime and block on it (for entry points)
fn sync_function_that_needs_async() -> Result<Data> {
    let rt = Runtime::new()?;
    rt.block_on(async {
        fetch_data_async().await
    })
}

// Option 2: Use an existing runtime handle (if runtime exists elsewhere)
fn sync_function_in_async_context() -> Result<Data> {
    let handle = tokio::runtime::Handle::current();
    handle.block_on(async {
        fetch_data_async().await
    })
}

// Option 3: Run runtime in a separate thread (for GUIs, game loops)
fn start_async_backend() -> TaskSpawner {
    let (tx, mut rx) = tokio::sync::mpsc::channel(32);
    std::thread::spawn(move || {
        let rt = Runtime::new().unwrap();
        rt.block_on(async move {
            while let Some(task) = rx.recv().await {
                tokio::spawn(handle_task(task));
            }
        });
    });
    TaskSpawner { tx }
}
```

- Bridging guide: https://tokio.rs/tokio/topics/bridging

#### Calling Sync from Async (wrapping blocking code)

```rust
// For blocking I/O or slow sync libraries
let result = tokio::task::spawn_blocking(move || {
    // This runs on a dedicated blocking thread pool
    expensive_sync_computation()
}).await?;

// For blocking I/O on byte streams
use tokio_util::io::SyncIoBridge;
let async_reader = tokio::fs::File::open("data.bin").await?;
tokio::task::spawn_blocking(move || {
    let sync_reader = SyncIoBridge::new(async_reader);
    sync_library::parse(sync_reader) // Uses std::io::Read
}).await?;

// For CPU-bound work — prefer rayon over spawn_blocking
let result = tokio::task::spawn_blocking(move || {
    rayon::scope(|s| {
        // Parallel CPU work here
    })
}).await?;
```

**Critical**: `spawn_blocking` tasks CANNOT be cancelled. They run to completion even during
shutdown. Use `tokio::runtime::Builder::shutdown_timeout()` to bound shutdown time.

- spawn_blocking docs: https://docs.rs/tokio/latest/tokio/task/fn.spawn_blocking.html

---

## Phase 3: Common Migration Patterns

### Pattern: std → tokio Equivalents

| Sync (std)                      | Async (tokio)                         |
|---------------------------------|---------------------------------------|
| `std::net::TcpListener`        | `tokio::net::TcpListener`             |
| `std::net::TcpStream`          | `tokio::net::TcpStream`               |
| `std::net::UdpSocket`          | `tokio::net::UdpSocket`               |
| `std::fs::File`                | `tokio::fs::File`                     |
| `std::fs::read_to_string`      | `tokio::fs::read_to_string`           |
| `std::thread::sleep`           | `tokio::time::sleep`                  |
| `std::thread::spawn`           | `tokio::spawn` (for async tasks)      |
| `std::sync::Mutex`             | `tokio::sync::Mutex`                  |
| `std::sync::RwLock`            | `tokio::sync::RwLock`                 |
| `std::sync::mpsc`              | `tokio::sync::mpsc`                   |
| `std::sync::mpsc` (broadcast)  | `tokio::sync::broadcast`              |
| `std::sync::mpsc` (oneshot)    | `tokio::sync::oneshot`                |
| `std::io::Read` / `Write`      | `tokio::io::AsyncRead` / `AsyncWrite` |

**Important**: Only use `tokio::sync::Mutex` when the lock must be held across `.await` points.
For short critical sections without `.await`, `std::sync::Mutex` is faster and has no overhead:

```rust
// PREFER std::sync::Mutex for simple state guards
use std::sync::Mutex;
let data = Arc::new(Mutex::new(HashMap::new()));

// ONLY use tokio::sync::Mutex when you await while holding the lock
use tokio::sync::Mutex;
let conn = Arc::new(Mutex::new(db_connection));
let guard = conn.lock().await;
guard.query("SELECT ...").await; // Holding lock across await
```

### Pattern: Converting Thread-Per-Connection Servers

```rust
// BEFORE: Thread-per-connection (sync)
fn main() -> std::io::Result<()> {
    let listener = std::net::TcpListener::bind("0.0.0.0:8080")?;
    for stream in listener.incoming() {
        let stream = stream?;
        std::thread::spawn(move || {
            handle_connection(stream);
        });
    }
    Ok(())
}

// AFTER: Task-per-connection (async)
#[tokio::main]
async fn main() -> std::io::Result<()> {
    let listener = tokio::net::TcpListener::bind("0.0.0.0:8080").await?;
    loop {
        let (stream, _addr) = listener.accept().await?;
        tokio::spawn(async move {
            handle_connection(stream).await;
        });
    }
}
```

### Pattern: Concurrent Operations with `join!` and `select!`

```rust
use tokio::{join, select};

// Run multiple futures concurrently, wait for ALL
let (users, posts, comments) = join!(
    fetch_users(),
    fetch_posts(),
    fetch_comments(),
);

// Run multiple futures, proceed when FIRST completes
select! {
    result = fetch_from_primary() => handle_primary(result),
    result = fetch_from_fallback() => handle_fallback(result),
    _ = tokio::time::sleep(Duration::from_secs(5)) => handle_timeout(),
}
```

### Pattern: Graceful Shutdown

```rust
use tokio::signal;
use tokio_util::sync::CancellationToken;

#[tokio::main]
async fn main() {
    let token = CancellationToken::new();
    let shutdown_token = token.clone();

    // Spawn worker tasks
    let worker = tokio::spawn(async move {
        loop {
            select! {
                _ = token.cancelled() => {
                    println!("Shutting down gracefully...");
                    break;
                }
                _ = do_work() => {}
            }
        }
    });

    // Wait for Ctrl+C
    signal::ctrl_c().await.unwrap();
    shutdown_token.cancel();
    worker.await.unwrap();
}
```

- tokio-util CancellationToken: https://docs.rs/tokio-util/latest/tokio_util/sync/struct.CancellationToken.html

### Pattern: Channel Selection Guide

```
Need one producer, one consumer?         → tokio::sync::mpsc (bounded)
Need multiple consumers?                 → tokio::sync::broadcast
Need a single response to a request?     → tokio::sync::oneshot
Need latest-value-wins (config reload)?  → tokio::sync::watch
Need backpressure control?               → tokio::sync::mpsc with bounded capacity
Need unbounded (careful!)?               → tokio::sync::mpsc::unbounded_channel
```

---

## Phase 4: Error Handling in Async

### The `?` Operator in Async

Error propagation with `?` works naturally in async functions. Prefer `anyhow` for applications
and `thiserror` for libraries:

```rust
use anyhow::{Context, Result};

async fn fetch_and_process(url: &str) -> Result<ProcessedData> {
    let response = reqwest::get(url)
        .await
        .context("Failed to fetch URL")?;

    let body = response.text()
        .await
        .context("Failed to read response body")?;

    parse_data(&body)
        .context("Failed to parse response")
}
```

### Handling Errors from Spawned Tasks

```rust
// JoinHandle returns Result<T, JoinError>
let handle = tokio::spawn(async {
    might_fail().await
});

match handle.await {
    Ok(Ok(value)) => println!("Success: {value}"),
    Ok(Err(e)) => println!("Task returned error: {e}"),
    Err(join_err) => {
        if join_err.is_panic() {
            println!("Task panicked!");
        } else {
            println!("Task was cancelled");
        }
    }
}
```

---

## Phase 5: Ecosystem Crate Equivalents

When migrating, replace sync crates with their async equivalents:

| Domain | Sync Crate | Async Crate |
|--------|-----------|-------------|
| HTTP client | `ureq`, `attohttpc` | `reqwest`, `hyper` |
| HTTP server | `tiny_http`, `actix-web` (has own rt) | `axum`, `warp` |
| Database (Postgres) | `postgres` | `tokio-postgres`, `sqlx` |
| Database (MySQL) | `mysql` | `sqlx` |
| Database (SQLite) | `rusqlite` | `sqlx` (with runtime-tokio) |
| Database ORM | `diesel` (sync) | `sea-orm`, `diesel-async` |
| Redis | `redis` (sync mode) | `redis` (tokio feature), `fred` |
| gRPC | — | `tonic` |
| WebSocket | `tungstenite` | `tokio-tungstenite` |
| DNS | `trust-dns-resolver` (sync) | `hickory-resolver` (async) |
| Process exec | `std::process::Command` | `tokio::process::Command` |
| File I/O | `std::fs` | `tokio::fs` |
| Serialization | `serde` (sync) | `serde` + `tokio::io` (serde itself is sync, use spawn_blocking for heavy parsing) |
| Logging/tracing | `log`, `env_logger` | `tracing`, `tracing-subscriber` (async-aware) |

- reqwest: https://github.com/seanmonstar/reqwest
- axum: https://github.com/tokio-rs/axum
- sqlx: https://github.com/launchbadge/sqlx
- tonic (gRPC): https://github.com/hyperium/tonic
- tracing: https://github.com/tokio-rs/tracing

---

## Anti-Patterns and Pitfalls

### 1. Blocking the Runtime

The #1 cause of async performance problems. ANY blocking call on a tokio worker thread blocks
ALL tasks on that thread.

```rust
// WRONG: These all block the runtime
async fn bad() {
    std::thread::sleep(Duration::from_secs(1));     // Use tokio::time::sleep
    let data = std::fs::read_to_string("file.txt"); // Use tokio::fs
    let result = expensive_computation();             // Use spawn_blocking
    let _lock = std_mutex.lock().unwrap();            // OK if held briefly, no await
    // ... but NOT if you await while holding it
}
```

### 2. Holding Locks Across Await Points

```rust
// WRONG: MutexGuard held across await — can deadlock with single-threaded runtime
let mut guard = data.lock().unwrap(); // std::sync::Mutex
*guard = fetch_data().await;           // Guard held across await!
drop(guard);

// RIGHT: Release lock before awaiting
let current = { data.lock().unwrap().clone() };  // Lock released here
let new_data = fetch_data().await;
*data.lock().unwrap() = new_data;

// OR: Use tokio::sync::Mutex if you MUST hold across await
let mut guard = data.lock().await; // tokio::sync::Mutex
*guard = fetch_data().await;        // Safe (but has performance cost)
```

### 3. Spawning Without Backpressure

```rust
// WRONG: Unbounded spawning can exhaust memory
for item in huge_iterator {
    tokio::spawn(async move { process(item).await });
}

// RIGHT: Use a semaphore to limit concurrency
use tokio::sync::Semaphore;
let semaphore = Arc::new(Semaphore::new(100)); // Max 100 concurrent tasks
for item in huge_iterator {
    let permit = semaphore.clone().acquire_owned().await.unwrap();
    tokio::spawn(async move {
        process(item).await;
        drop(permit); // Release when done
    });
}

// RIGHT: Or use futures::stream::buffered
use futures::stream::{self, StreamExt};
stream::iter(items)
    .map(|item| async move { process(item).await })
    .buffer_unordered(100)
    .collect::<Vec<_>>()
    .await;
```

### 4. Nested Runtime Panic

```rust
// WRONG: Panics with "Cannot start a runtime from within a runtime"
#[tokio::main]
async fn main() {
    let rt = tokio::runtime::Runtime::new().unwrap();
    rt.block_on(async { /* ... */ }); // PANIC!
}

// RIGHT: Use tokio::task::spawn_blocking to escape the async context
#[tokio::main]
async fn main() {
    let result = tokio::task::spawn_blocking(|| {
        let rt = tokio::runtime::Runtime::new().unwrap();
        rt.block_on(async { /* ... */ })
    }).await.unwrap();
}
```

### 5. Forgetting Cancellation Safety

When a future is dropped (e.g., in `select!`), it is cancelled at the next `.await` point.
This can leave operations half-complete:

```rust
// DANGEROUS: If timeout fires, the database write may be partially committed
select! {
    result = write_to_database(&data) => handle_result(result),
    _ = tokio::time::sleep(timeout) => handle_timeout(),
}

// SAFER: Use cancellation-safe operations or wrap in spawn
let handle = tokio::spawn(write_to_database(data));
select! {
    result = handle => handle_result(result),
    _ = tokio::time::sleep(timeout) => {
        // Task continues running even if we stop waiting
        handle_timeout()
    }
}
```

- Cancellation safety docs: https://docs.rs/tokio/latest/tokio/macro.select.html#cancellation-safety

---

## Testing Async Code

### Basic Async Tests

```rust
#[tokio::test]
async fn test_fetch() {
    let result = fetch_data("https://example.com").await;
    assert!(result.is_ok());
}

// Use multi-threaded test runtime for tests that spawn tasks
#[tokio::test(flavor = "multi_thread", worker_threads = 2)]
async fn test_concurrent_operations() {
    let (tx, mut rx) = tokio::sync::mpsc::channel(10);
    tokio::spawn(async move { tx.send(42).await.unwrap() });
    assert_eq!(rx.recv().await, Some(42));
}
```

### Testing with Time Control

```rust
use tokio::time::{self, Duration};

#[tokio::test]
async fn test_timeout_behavior() {
    // Pause time — sleep/timeout resolve instantly when advanced
    time::pause();

    let start = time::Instant::now();
    time::sleep(Duration::from_secs(3600)).await; // Returns instantly
    assert!(start.elapsed() >= Duration::from_secs(3600)); // But logical time advanced

    // Use advance() for fine-grained control
    time::advance(Duration::from_secs(60)).await;
}
```

### Tracing for Async Debugging

```rust
// In Cargo.toml:
// tracing = "0.1"
// tracing-subscriber = { version = "0.3", features = ["env-filter"] }
// console-subscriber = "0.4"  # For tokio-console

use tracing::{info, instrument};

#[instrument(skip(db))]  // Automatically logs entry/exit and arguments
async fn process_request(id: u64, db: &Database) -> Result<Response> {
    info!(request_id = id, "Processing request");
    let data = db.fetch(id).await?;
    Ok(transform(data))
}

// Enable tokio-console for runtime diagnostics:
// console-subscriber = "0.4"
// RUSTFLAGS="--cfg tokio_unstable" cargo run
```

- tokio-console: https://github.com/tokio-rs/console
- tracing: https://github.com/tokio-rs/tracing

---

## Quality Gates

| Gate | Check | Tool | Phase |
|------|-------|------|-------|
| No blocking in async context | Lint for `std::thread::sleep`, `std::fs::*` in async fns | `clippy`, manual review | Every PR |
| Feature flags minimal | Only required tokio features enabled | `Cargo.toml` review | Setup |
| `Send + 'static` compliance | All spawned futures compile without errors | `cargo check` | Build |
| No `unwrap()` on JoinHandle | Handle task panics gracefully | `clippy::unwrap_used` | Every PR |
| Graceful shutdown | All tasks respect cancellation token | Integration test | Pre-release |
| Backpressure present | Bounded channels or semaphores for concurrency control | Code review | Every PR |
| Tracing instrumented | All public async fns have `#[instrument]` | Code review | Every PR |
| No nested runtimes | No `Runtime::new()` inside async context | `grep -r "Runtime::new"` | Every PR |
| Async tests pass | `#[tokio::test]` for all async logic | `cargo test` | Every PR |
| No cancellation hazards | `select!` branches documented for safety | Code review | Every PR |

---

## Guardrails

### Clippy Configuration for Async Code

```toml
# In Cargo.toml or .clippy.toml
[lints.clippy]
# Catch common async mistakes
await_holding_lock = "deny"          # Don't hold std::sync lock across await
await_holding_refcell_ref = "deny"   # Don't hold RefCell borrow across await
large_futures = "warn"               # Warn on futures > 16KB on stack
```

### CI Pipeline Additions

```yaml
# .github/workflows/ci.yml additions for async projects
- name: Check for blocking calls in async
  run: |
    # Flag std::thread::sleep in async functions
    grep -rn "std::thread::sleep" src/ && echo "WARN: Found blocking sleep" || true
    # Flag std::fs in async modules
    grep -rn "std::fs::" src/ | grep -v "spawn_blocking" | grep -v "// sync-ok" && \
      echo "WARN: Found std::fs without spawn_blocking" || true

- name: Tokio console compatibility
  run: RUSTFLAGS="--cfg tokio_unstable" cargo check
```

### Required Dependencies for Async Projects

```toml
[dependencies]
tokio = { version = "1", features = ["rt-multi-thread", "macros", "signal"] }
tokio-util = { version = "0.7", features = ["rt"] }  # CancellationToken
tracing = "0.1"
tracing-subscriber = { version = "0.3", features = ["env-filter"] }

[dev-dependencies]
tokio = { version = "1", features = ["test-util"] }  # Time control in tests
```

---

## Further Resources

- Tokio official tutorial: https://tokio.rs/tokio/tutorial
- Async Rust book (community): https://rust-lang.github.io/async-book/
- Alice Ryhl's actors with Tokio: https://ryhl.io/blog/actors-with-tokio/
- Practical guide to async Rust (Oleg Kubrakov): https://medium.com/@OlegKubrakov/practical-guide-to-async-rust-and-tokio-99e818c11965
- Bridging async and sync (GreptimeDB): https://greptime.com/blogs/2023-03-09-bridging-async-and-sync-rust
- State of async Rust runtimes (corrode): https://corrode.dev/blog/async/
- mini-redis (Tokio example project): https://github.com/tokio-rs/mini-redis
- tokio-console (runtime diagnostics): https://github.com/tokio-rs/console
