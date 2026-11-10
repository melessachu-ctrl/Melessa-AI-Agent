# Idiomatic Rust design patterns

Reference: Rust Design Patterns book — https://rust-unofficial.github.io/patterns/
Reference: Rust API Guidelines — https://rust-lang.github.io/api-guidelines/

## Core principle: "Parse, don't validate"

From Alexis King (https://lexi-lambda.github.io/blog/2019/11/05/parse-don-t-validate/):
Reject invalid data at construction time. If a value of type `T` exists, it is ALWAYS valid.
This eliminates entire categories of runtime checks and bugs.

```rust
// BAD: validate at every use site
fn send_email(address: &str) -> Result<()> {
    if !is_valid_email(address) {  // Must remember this check EVERYWHERE
        return Err(Error::InvalidEmail);
    }
    // ...
}

// GOOD: parse at construction, guarantee at type level
struct Email(String);

impl Email {
    pub fn parse(s: &str) -> Result<Self, EmailError> {
        if is_valid_email(s) {
            Ok(Email(s.to_string()))
        } else {
            Err(EmailError::Invalid(s.to_string()))
        }
    }

    pub fn as_str(&self) -> &str {
        &self.0
    }
}

fn send_email(address: &Email) -> Result<()> {
    // No validation needed — Email type guarantees validity
    // ...
}
```

Reference: Luca Palmieri's Zero to Production — https://lpalmieri.com/posts/2020-12-11-zero-to-production-6-domain-modelling/

## The newtype pattern

Wrap primitive types to create semantically distinct types at zero runtime cost.

```rust
// Prevents mixing up user IDs with order IDs at compile time
struct UserId(u64);
struct OrderId(u64);

// This is a compile error:
// fn get_order(user: UserId) -> Order { ... }
// get_order(OrderId(42)); // ERROR: expected UserId, found OrderId

// Override Display to prevent sensitive data leaking into logs
struct Password(String);

impl std::fmt::Display for Password {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "********")
    }
}

impl std::fmt::Debug for Password {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "Password(********)")
    }
}
```

Reference: Rust Design Patterns — https://rust-unofficial.github.io/patterns/patterns/behavioural/newtype.html

## The typestate pattern

Encode state machines in the type system. Invalid state transitions become compile errors.

```rust
// States are empty structs used as type parameters
struct Unvalidated;
struct Validated;
struct Submitted;

struct Form<State> {
    data: FormData,
    _state: std::marker::PhantomData<State>,
}

impl Form<Unvalidated> {
    fn new(data: FormData) -> Self {
        Form { data, _state: std::marker::PhantomData }
    }

    // validate() consumes Unvalidated and returns Validated — can't use old form
    fn validate(self) -> Result<Form<Validated>, ValidationError> {
        // ... validation logic ...
        Ok(Form { data: self.data, _state: std::marker::PhantomData })
    }
}

impl Form<Validated> {
    // submit() is ONLY available on validated forms
    fn submit(self) -> Result<Form<Submitted>, SubmitError> {
        // ... submission logic ...
        Ok(Form { data: self.data, _state: std::marker::PhantomData })
    }
}

// This is a compile error:
// Form::new(data).submit();  // ERROR: submit() not available on Form<Unvalidated>
```

Reference: https://cliffle.com/blog/rust-typestate/

## The builder pattern

For complex construction with many optional parameters:

```rust
#[derive(Debug)]
struct Server {
    host: String,
    port: u16,
    max_connections: usize,
    timeout_secs: u64,
    tls_enabled: bool,
}

#[derive(Default)]
struct ServerBuilder {
    host: Option<String>,
    port: Option<u16>,
    max_connections: Option<usize>,
    timeout_secs: Option<u64>,
    tls_enabled: Option<bool>,
}

impl ServerBuilder {
    fn new() -> Self {
        Self::default()
    }

    fn host(mut self, host: impl Into<String>) -> Self {
        self.host = Some(host.into());
        self
    }

    fn port(mut self, port: u16) -> Self {
        self.port = Some(port);
        self
    }

    fn max_connections(mut self, max: usize) -> Self {
        self.max_connections = Some(max);
        self
    }

    fn timeout(mut self, secs: u64) -> Self {
        self.timeout_secs = Some(secs);
        self
    }

    fn tls(mut self, enabled: bool) -> Self {
        self.tls_enabled = Some(enabled);
        self
    }

    fn build(self) -> Result<Server, &'static str> {
        Ok(Server {
            host: self.host.unwrap_or_else(|| "localhost".to_string()),
            port: self.port.unwrap_or(8080),
            max_connections: self.max_connections.unwrap_or(100),
            timeout_secs: self.timeout_secs.unwrap_or(30),
            tls_enabled: self.tls_enabled.unwrap_or(false),
        })
    }
}

// Usage:
// let server = ServerBuilder::new().host("0.0.0.0").port(443).tls(true).build()?;
```

Consider using the `derive_builder` or `bon` crate for automatic builder generation.

## RAII and the Drop trait

Resource cleanup is automatic and deterministic in Rust. Replace manual cleanup, `finally`
blocks, context managers, and `defer` with `Drop`:

```rust
struct TempFile {
    path: std::path::PathBuf,
}

impl TempFile {
    fn new(path: impl Into<std::path::PathBuf>) -> std::io::Result<Self> {
        let path = path.into();
        std::fs::File::create(&path)?;
        Ok(TempFile { path })
    }
}

impl Drop for TempFile {
    fn drop(&mut self) {
        let _ = std::fs::remove_file(&self.path); // cleanup on scope exit
    }
}
```

## Iterator patterns

Prefer iterator chains over imperative loops. They are zero-cost abstractions — the compiler
optimizes them to the same machine code as hand-written loops.

```rust
// Instead of:
let mut results = Vec::new();
for item in &items {
    if item.is_valid() {
        results.push(item.transform());
    }
}

// Write:
let results: Vec<_> = items.iter()
    .filter(|item| item.is_valid())
    .map(|item| item.transform())
    .collect();

// Useful combinators for rewrites:
// .enumerate()       — add index
// .zip()            — combine two iterators
// .chain()          — concatenate iterators
// .flat_map()       — map + flatten
// .take() / .skip() — slicing
// .peekable()       — look ahead
// .windows()        — sliding windows over slices
// .chunks()         — fixed-size chunks
// .partition()      — split into two collections by predicate
// .fold()           — accumulate with state
// .scan()           — fold that yields intermediate results
```

## Extension traits

Add methods to types you don't own (Rust's answer to monkey patching):

```rust
trait StringExt {
    fn truncate_with_ellipsis(&self, max_len: usize) -> String;
}

impl StringExt for str {
    fn truncate_with_ellipsis(&self, max_len: usize) -> String {
        if self.len() <= max_len {
            self.to_string()
        } else {
            format!("{}...", &self[..max_len.saturating_sub(3)])
        }
    }
}
```

## Smart pointer patterns for ownership

| Need | Use | Notes |
|------|-----|-------|
| Single owner, heap allocation | `Box<T>` | Like C++ `unique_ptr` |
| Multiple owners, single-thread | `Rc<T>` | Reference counted |
| Multiple owners, multi-thread | `Arc<T>` | Atomic reference counted |
| Interior mutability, single-thread | `Cell<T>` / `RefCell<T>` | Runtime borrow checking |
| Interior mutability, multi-thread | `Mutex<T>` / `RwLock<T>` | Locking |
| Lazy initialization | `OnceLock<T>` / `LazyLock<T>` | Thread-safe, init once |
| Weak references (break cycles) | `Weak<T>` | With `Rc` or `Arc` |

## Derive macros — use liberally

```rust
#[derive(
    Debug,          // For {:?} formatting and error messages
    Clone,          // For explicit copying
    PartialEq, Eq,  // For equality comparison
    Hash,           // For use as HashMap key
    PartialOrd, Ord, // For sorting
    Default,        // For default values
)]
struct MyType {
    // ...
}

// serde for serialization
#[derive(serde::Serialize, serde::Deserialize)]
struct Config {
    // ...
}
```

## Module organization patterns

```
my-crate/
├── Cargo.toml
├── src/
│   ├── lib.rs           # Public API (re-exports)
│   ├── config.rs        # Configuration types
│   ├── error.rs         # Error types
│   ├── domain/          # Domain types
│   │   ├── mod.rs
│   │   ├── user.rs
│   │   └── order.rs
│   ├── service/         # Business logic
│   │   ├── mod.rs
│   │   └── auth.rs
│   └── infra/           # External integrations
│       ├── mod.rs
│       ├── database.rs
│       └── http.rs
├── tests/               # Integration tests
│   ├── integration.rs
│   └── compatibility.rs
└── benches/             # Benchmarks
    └── performance.rs
```

Use `pub use` in `lib.rs` to flatten the module hierarchy for consumers:
```rust
// src/lib.rs
pub mod config;
pub mod error;
mod domain;
mod service;

// Re-export important types at crate root
pub use config::Config;
pub use error::Error;
pub use domain::user::User;
```

## Anti-patterns to avoid in rewrites

From the Rust Design Patterns book (anti-patterns section):

1. **Transliteration**: Writing C/Python/Java in Rust syntax. Use Rust idioms.
2. **`clone()` to satisfy the borrow checker**: Usually means the ownership model is wrong.
   Redesign data flow instead.
3. **`unwrap()` in library code**: Use `?` and `Result`. Reserve `unwrap()` for tests and
   provably-safe cases (with a comment explaining why).
4. **Stringly-typed APIs**: Use enums and newtypes instead of strings for fixed sets of values.
5. **God structs**: Break large structs into smaller, focused types with clear ownership.
6. **Deep trait hierarchies**: Prefer composition over deep trait inheritance chains.
