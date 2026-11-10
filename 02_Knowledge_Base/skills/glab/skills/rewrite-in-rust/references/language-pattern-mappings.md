# Language → Rust pattern mappings

## Table of Contents

- [Universal mappings](#universal-mappings-all-source-languages--rust)
- [C-specific mappings](#c-specific-mappings)
- [C++-specific mappings](#c-specific-mappings-1)
- [Python-specific mappings](#python-specific-mappings)
- [Go-specific mappings](#go-specific-mappings)
- [Ruby-specific mappings](#ruby-specific-mappings)
- [JavaScript/TypeScript-specific mappings](#javascripttypescript-specific-mappings)
- [Java-specific mappings](#java-specific-mappings)

This reference provides concrete mappings from common patterns in source languages to their
idiomatic Rust equivalents. The goal is NOT line-by-line translation — it is capturing the same
BEHAVIOR using Rust's type system, ownership model, and standard patterns.

Key references:
- Rust Design Patterns book: https://rust-unofficial.github.io/patterns/
- Rust for C Programmers: https://rust-for-c-programmers.com/
- Rust API Guidelines: https://rust-lang.github.io/api-guidelines/

## Universal mappings (all source languages → Rust)

### Error handling

| Source pattern | Rust idiom |
|---------------|------------|
| Exceptions (try/catch) | `Result<T, E>` with `?` operator |
| Null returns for errors | `Option<T>` or `Result<T, E>` |
| Error codes (int returns) | `Result<T, ErrorEnum>` |
| Sentinel values (-1, "", null) | `Option<T>` |
| Error strings | `thiserror` for libraries, `anyhow` for applications |
| Global errno | Return `Result` from every fallible function |
| Multiple error types | `enum Error` with `From` impls, or `anyhow::Error` |

```rust
// Library error type with thiserror
use thiserror::Error;

#[derive(Error, Debug)]
pub enum ParseError {
    #[error("invalid header at byte {position}")]
    InvalidHeader { position: usize },
    #[error("unsupported version: {0}")]
    UnsupportedVersion(u32),
    #[error(transparent)]
    Io(#[from] std::io::Error),
}

// Application error handling with anyhow
use anyhow::{Context, Result};

fn process_file(path: &str) -> Result<()> {
    let content = std::fs::read_to_string(path)
        .with_context(|| format!("failed to read {path}"))?;
    let parsed = parse(&content)
        .context("failed to parse content")?;
    Ok(())
}
```

### Null/nil/None handling

| Source pattern | Rust idiom |
|---------------|------------|
| Nullable pointer/reference | `Option<T>` or `Option<&T>` |
| Default/zero values | `Default` trait |
| Null checks (`if x != null`) | `if let Some(x) = opt` or `.is_some()` |
| Optional chaining (`x?.y?.z`) | `.and_then(\|x\| x.y()).and_then(\|y\| y.z())` |
| Null object pattern | `Option<T>` with `unwrap_or_default()` |

### Collection patterns

| Source pattern | Rust idiom |
|---------------|------------|
| `for (i = 0; i < len; i++)` | `for item in collection` or `for (i, item) in collection.iter().enumerate()` |
| `list.map(f).filter(p)` | `.iter().map(f).filter(p).collect()` |
| `list.reduce(f)` | `.iter().fold(init, f)` or `.iter().reduce(f)` |
| `list.find(p)` | `.iter().find(\|x\| p(x))` |
| `list.any(p)` / `list.all(p)` | `.iter().any(\|x\| p(x))` / `.iter().all(\|x\| p(x))` |
| Mutable iteration with removal | `.retain(\|x\| keep_condition(x))` |
| Sorted + deduped | `.sort(); .dedup();` or `BTreeSet` |
| Hash map with default | `entry(key).or_default()` or `or_insert_with(f)` |

### OOP → Rust

| Source pattern | Rust idiom |
|---------------|------------|
| Class with fields and methods | `struct` + `impl` block |
| Interface/protocol/abstract class | `trait` |
| Inheritance | Trait default methods + composition |
| Abstract class | Trait with mix of required + default methods |
| Closed type hierarchy | `enum` with variants (preferred over trait objects) |
| Open type hierarchy | `trait` with `Box<dyn Trait>` or generics |
| Mixins / multiple inheritance | Multiple trait implementations |
| Singleton | `once_cell::sync::Lazy` or `std::sync::OnceLock` |
| Factory pattern | `fn new() -> Self` or builder pattern |
| Observer pattern | Callbacks: `Vec<Box<dyn Fn(Event)>>` or channels |

```rust
// Closed hierarchy: use enum (preferred when variants are known at compile time)
enum Shape {
    Circle { radius: f64 },
    Rectangle { width: f64, height: f64 },
    Triangle { base: f64, height: f64 },
}

impl Shape {
    fn area(&self) -> f64 {
        match self {
            Shape::Circle { radius } => std::f64::consts::PI * radius * radius,
            Shape::Rectangle { width, height } => width * height,
            Shape::Triangle { base, height } => 0.5 * base * height,
        }
    }
}

// Open hierarchy: use trait (when third parties need to add variants)
trait Drawable {
    fn draw(&self, canvas: &mut Canvas);
    fn bounding_box(&self) -> Rect;
}

// Static dispatch (zero overhead, monomorphized)
fn render<D: Drawable>(item: &D, canvas: &mut Canvas) {
    item.draw(canvas);
}

// Dynamic dispatch (when you need heterogeneous collections)
fn render_all(items: &[Box<dyn Drawable>], canvas: &mut Canvas) {
    for item in items {
        item.draw(canvas);
    }
}
```

### Concurrency

| Source pattern | Rust idiom |
|---------------|------------|
| Threads + mutex | `std::thread::spawn` + `Arc<Mutex<T>>` |
| Async/await | `tokio` or `async-std` runtime |
| Thread pool | `rayon` for data parallelism, `tokio` for I/O |
| Channels | `std::sync::mpsc` or `tokio::sync::mpsc` |
| Atomic operations | `std::sync::atomic` types |
| Read-write lock | `std::sync::RwLock` or `parking_lot::RwLock` |
| Thread-local storage | `thread_local!` macro |
| Go goroutines | `tokio::spawn` (async) or `rayon::spawn` (CPU) |
| Python GIL workarounds | Not needed — Rust has no GIL |

## C-specific mappings

| C pattern | Rust idiom |
|-----------|------------|
| `malloc`/`free` | `Box<T>`, `Vec<T>`, `String` (automatic) |
| `char*` strings | `String` (owned) or `&str` (borrowed) |
| `struct` with function pointers | `trait` with methods |
| `union` | `enum` (safe, tagged) or `union` (unsafe, untagged) |
| `#define` constants | `const` or `static` |
| `#define` macros | `macro_rules!` or `const fn` |
| `typedef` | `type` alias or newtype struct |
| `goto` for cleanup | `Drop` trait (RAII) or `?` early returns |
| `errno` | `Result<T, E>` |
| Array + length parameters | Slices: `&[T]` or `&mut [T]` |
| Void pointer (`void*`) | Generics `<T>` or `Box<dyn Any>` |
| Bitfields | `bitflags` crate or manual bit manipulation |
| `setjmp`/`longjmp` | `Result` + `?` for normal flow; `catch_unwind` for panic recovery |
| Header files | `pub` visibility + module system |
| `static` local variables | `once_cell::sync::Lazy` or `OnceLock` |

### C memory management → Rust ownership

```c
// C: manual allocation
char* buf = malloc(1024);
if (!buf) return NULL;
// ... use buf ...
free(buf);  // easy to forget, double-free, use-after-free
```

```rust
// Rust: ownership handles it
let buf = vec![0u8; 1024];  // Allocated on heap
// ... use buf ...
// Automatically freed when buf goes out of scope
// Cannot double-free, cannot use-after-free — compiler prevents it
```

## C++-specific mappings

| C++ pattern | Rust idiom |
|-------------|------------|
| `std::unique_ptr<T>` | `Box<T>` |
| `std::shared_ptr<T>` | `Arc<T>` (thread-safe) or `Rc<T>` (single-thread) |
| `std::optional<T>` | `Option<T>` |
| `std::variant<A,B,C>` | `enum { A(A), B(B), C(C) }` |
| `std::vector<T>` | `Vec<T>` |
| `std::string` | `String` |
| `std::string_view` | `&str` |
| `std::span<T>` | `&[T]` or `&mut [T]` |
| `std::unordered_map<K,V>` | `HashMap<K,V>` |
| `std::map<K,V>` | `BTreeMap<K,V>` |
| Templates | Generics with trait bounds |
| RAII | `Drop` trait |
| Move semantics | Default behavior (all types move by default) |
| `const&` parameters | `&T` (immutable borrow) |
| Virtual methods | `dyn Trait` (dynamic dispatch) |
| `static_cast` | `.into()` or `as` |
| `dynamic_cast` | `downcast_ref()` on `dyn Any` |
| Namespaces | Modules (`mod`) |
| Exceptions | `Result<T, E>` |
| Destructors | `impl Drop for T` |
| Copy constructors | `impl Clone for T` (explicit `.clone()`) |
| Operator overloading | `std::ops` traits (`Add`, `Mul`, `Index`, etc.) |

## Python-specific mappings

| Python pattern | Rust idiom |
|----------------|------------|
| `dict` | `HashMap` or `BTreeMap` |
| `list` | `Vec<T>` |
| `set` | `HashSet` or `BTreeSet` |
| `tuple` | Tuple `(A, B, C)` or named struct |
| `class` | `struct` + `impl` |
| Decorators | Procedural macros or wrapper functions |
| Context managers (`with`) | `Drop` trait (RAII) |
| List comprehension | `.iter().filter().map().collect()` |
| `*args, **kwargs` | Generics, builder pattern, or `impl Into<T>` |
| Duck typing | Trait bounds |
| `__str__` / `__repr__` | `impl Display` / `impl Debug` |
| `__eq__`, `__hash__` | `#[derive(PartialEq, Eq, Hash)]` |
| `__iter__` | `impl Iterator` |
| `dataclass` | `#[derive(Debug, Clone, PartialEq)]` struct |
| Type hints | Rust types (enforced at compile time, not runtime) |
| `asyncio` | `tokio` or `async-std` |
| `multiprocessing` | `rayon` (data parallelism) or `std::thread` |

```python
# Python dataclass
@dataclass
class Config:
    host: str = "localhost"
    port: int = 8080
    debug: bool = False
```

```rust
// Rust equivalent
#[derive(Debug, Clone, PartialEq)]
struct Config {
    host: String,
    port: u16,
    debug: bool,
}

impl Default for Config {
    fn default() -> Self {
        Self {
            host: "localhost".to_string(),
            port: 8080,
            debug: false,
        }
    }
}
```

## Go-specific mappings

| Go pattern | Rust idiom |
|------------|------------|
| `error` return | `Result<T, E>` |
| `interface{}` / `any` | `Box<dyn Any>` or generics |
| Interfaces (implicit) | Traits (explicit `impl Trait for Type`) |
| Goroutines | `tokio::spawn` (async I/O) or `rayon` (CPU parallel) |
| Channels | `tokio::sync::mpsc` or `crossbeam::channel` |
| `defer` | `Drop` trait (RAII) |
| `struct` embedding | Composition with `Deref` or explicit delegation |
| `map[K]V` | `HashMap<K, V>` |
| `[]T` slices | `Vec<T>` (owned) or `&[T]` (borrowed) |
| `sync.Mutex` | `std::sync::Mutex` or `parking_lot::Mutex` |
| `sync.WaitGroup` | `tokio::task::JoinSet` or barrier patterns |
| `context.Context` | `tokio_util::sync::CancellationToken` or custom |
| Multiple return values | Tuple `(A, B)` or struct |
| `init()` | `once_cell::sync::Lazy` or module-level init |

```go
// Go: error handling with multiple returns
func readConfig(path string) (*Config, error) {
    data, err := os.ReadFile(path)
    if err != nil {
        return nil, fmt.Errorf("reading config: %w", err)
    }
    var cfg Config
    if err := json.Unmarshal(data, &cfg); err != nil {
        return nil, fmt.Errorf("parsing config: %w", err)
    }
    return &cfg, nil
}
```

```rust
// Rust: Result with ? and context
fn read_config(path: &str) -> anyhow::Result<Config> {
    let data = std::fs::read_to_string(path)
        .with_context(|| format!("reading config from {path}"))?;
    let cfg: Config = serde_json::from_str(&data)
        .context("parsing config")?;
    Ok(cfg)
}
```

## Ruby-specific mappings

| Ruby pattern | Rust idiom |
|--------------|------------|
| `class` with `attr_accessor` | `struct` with `pub` fields or getter/setter methods |
| Blocks / `yield` | Closures `\|args\| body` or `impl Fn(Args) -> Ret` |
| Mixins (`include Module`) | Trait implementations |
| `method_missing` | Not directly available; use `enum` dispatch or `HashMap` |
| `Enumerable` | `Iterator` trait |
| Symbols (`:name`) | Enum variants or `&'static str` |
| `nil` | `Option::None` |
| `rescue` / `ensure` | `Result` + `?` / `Drop` trait |
| Monkey patching | Extension traits (trait on foreign types) |
| `Struct.new(:a, :b)` | `#[derive] struct` |
| Gems / Bundler | Crates / Cargo |
| `freeze` | All Rust values are immutable by default |

```ruby
# Ruby class with mixins
module Printable
  def to_s
    inspect
  end
end

class Config
  include Printable
  attr_reader :host, :port

  def initialize(host: "localhost", port: 8080)
    @host = host
    @port = port
  end
end
```

```rust
// Rust equivalent using traits
use std::fmt;

trait Printable: fmt::Debug {
    fn to_string_pretty(&self) -> String {
        format!("{:?}", self)
    }
}

#[derive(Debug, Clone)]
struct Config {
    host: String,
    port: u16,
}

impl Printable for Config {}

impl Default for Config {
    fn default() -> Self {
        Self {
            host: "localhost".to_string(),
            port: 8080,
        }
    }
}
```

## JavaScript/TypeScript-specific mappings

| JS/TS pattern | Rust idiom |
|---------------|------------|
| `interface` | `trait` |
| `class` | `struct` + `impl` |
| `Promise` / `async`/`await` | `Future` / `async`/`await` (with tokio/async-std) |
| `null`/`undefined` | `Option<T>` |
| Callbacks | Closures: `impl Fn()`, `Box<dyn Fn()>` |
| `JSON.parse()` | `serde_json::from_str()` |
| `Array.map/filter/reduce` | `.iter().map().filter().fold()` |
| `Map` / `Set` | `HashMap` / `HashSet` |
| `typeof` / `instanceof` | Pattern matching, `downcast_ref` |
| Destructuring | Pattern matching in `let`, `match`, function args |
| Spread operator (`...`) | `.iter().chain()`, `extend()`, or struct update syntax |
| Template literals | `format!()` macro |
| `EventEmitter` | Channels or callback vectors |
| npm / package.json | Cargo / Cargo.toml |
| TypeScript generics | Rust generics with trait bounds |
| Union types (`A \| B`) | `enum { A(A), B(B) }` |
| `Readonly<T>` | Default behavior (everything immutable unless `mut`) |

```typescript
// TypeScript
interface Serializable {
    serialize(): string;
    deserialize(data: string): void;
}

class User implements Serializable {
    constructor(
        public name: string,
        public age: number,
    ) {}

    serialize(): string {
        return JSON.stringify({ name: this.name, age: this.age });
    }

    deserialize(data: string): void {
        const obj = JSON.parse(data);
        this.name = obj.name;
        this.age = obj.age;
    }
}
```

```rust
// Rust equivalent using serde
use serde::{Serialize, Deserialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
struct User {
    name: String,
    age: u32,
}

// serde provides serialize/deserialize automatically via derive macros
// For custom serialization: impl Serialize and Deserialize manually
```

## Java-specific mappings

| Java pattern | Rust idiom |
|--------------|------------|
| `interface` | `trait` |
| `abstract class` | `trait` with default methods |
| `final class` | Default (Rust types can't be inherited from) |
| Generics `<T extends Bound>` | Generics `<T: Bound>` |
| `Optional<T>` | `Option<T>` |
| `Stream` API | Iterator adaptors |
| `synchronized` | `Mutex<T>` or `RwLock<T>` |
| `try-with-resources` | `Drop` trait (RAII) |
| `enum` (with methods) | `enum` + `impl` block |
| Annotations | Derive macros, attribute macros |
| `instanceof` | Pattern matching |
| `equals`/`hashCode` | `#[derive(PartialEq, Eq, Hash)]` |
| `toString()` | `impl Display` |
| `Iterable<T>` | `impl IntoIterator` |
| `Collections.unmodifiableList()` | `&[T]` (immutable borrow) |
| Builder pattern | Builder pattern (see idiomatic-rust-patterns.md) |
| Dependency injection | Constructor injection (pass dependencies as params) |
| Maven/Gradle | Cargo |
