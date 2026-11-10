# Analysis Patterns

## Table of Contents

- [General Analysis Workflow](#general-analysis-workflow)
- [C/C++ Analysis](#cc-analysis)
- [Go Analysis](#go-analysis)
- [Python Analysis](#python-analysis)
- [Ruby Analysis](#ruby-analysis)
- [Language-Agnostic Analysis](#language-agnostic-analysis)
- [Security Analysis](#security-analysis)
- [Performance Profiling](#performance-profiling)
- [Test Coverage Analysis](#test-coverage-analysis)
- [Documentation Extraction](#documentation-extraction)
- [Dependency Analysis](#dependency-analysis)
- [Output: Analysis Document](#output-analysis-document)

Language-specific techniques for analyzing codebases before rewriting to Rust.

## General Analysis Workflow

1. **Map architecture** — Identify modules, boundaries, data flow
2. **Catalog dependencies** — External libraries, system calls, APIs
3. **Document security** — Trust boundaries, privilege separation, input validation
4. **Review tests** — Existing coverage, test types, edge cases
6. **Note idioms** — Language-specific patterns that need Rust equivalents

## C/C++ Analysis

### Memory Management Patterns

**Identify allocation patterns:**
```bash
# Find manual memory management
grep -rn "malloc\|calloc\|realloc\|free" src/

# Buffer operations (potential overflow)
grep -rn "strcpy\|strcat\|sprintf\|gets" src/

# Find pointer arithmetic
grep -rn "\*\+\+\|ptr\[\|ptr +" src/
```

**Common C patterns → Rust equivalents:**

| C Pattern | Rust Equivalent |
|---|---|
| `malloc()` + `free()` | `Box<T>`, `Vec<T>`, ownership |
| `strcpy()`, `strcat()` | `String`, `str::push_str()` |
| `sprintf()` | `format!()`, `write!()` |
| Manual reference counting | `Rc<T>`, `Arc<T>` |
| `pthread_mutex_t` | `Mutex<T>`, `RwLock<T>` |

### System Call Usage

```bash
# Find system calls
grep -rn "open\|close\|read\|write\|ioctl" src/

# Signal handling
grep -rn "signal\|sigaction" src/

# Process management
grep -rn "fork\|exec\|wait\|kill" src/
```

**Map to Rust crates:**
- File I/O → `std::fs`, `tokio::fs`
- Signals → `tokio::signal`, `signal-hook`
- Process → `std::process`, `tokio::process`
- Low-level → `nix` crate

## Go Analysis

### Goroutine and Channel Patterns

**Identify concurrency:**
```bash
# Find goroutines
grep -rn "go func" src/

# Channels
grep -rn "make(chan\|<-\|chan<-" src/

# Sync primitives
grep -rn "sync\\.Mutex\|sync\\.WaitGroup\|sync\\.Once" src/
```

**Go patterns → Rust equivalents:**

| Go Pattern | Rust Equivalent |
|---|---|
| `go func()` | `tokio::spawn()`, `std::thread::spawn()` |
| `chan` | `tokio::sync::mpsc`, `crossbeam::channel` |
| `sync.Mutex` | `std::sync::Mutex<T>` |
| `sync.WaitGroup` | `tokio::sync::Semaphore`, manual counter |
| `context.Context` | `tokio::select!`, cancellation tokens |
| `defer` | RAII with `Drop` trait |

### Error Handling

```bash
# Find error handling patterns
grep -rn "if err != nil" src/

# Panic usage
grep -rn "panic(" src/
```

**Translation strategy:**
- `if err != nil; return err` → `?` operator
- `panic()` → `panic!()` only for unrecoverable errors
- Multiple return values → `Result<T, E>` or tuples

### Interface Usage

```bash
# Find interface definitions
grep -rn "type.*interface" src/

# Empty interface usage
grep -rn "interface{}" src/
```

**Go interfaces → Rust traits:**
- Define traits for polymorphism
- Use trait objects (`dyn Trait`) or generics
- `interface{}` → `Box<dyn Any>` or generics with constraints

## Python Analysis

### Dynamic Features

**Identify dynamic code:**
```bash
# Dynamic execution (risky)
grep -rn "eval\|exec\|compile" src/

# Reflection
grep -rn "getattr\|setattr\|hasattr\|__dict__" src/

# Dynamic imports
grep -rn "__import__\|importlib" src/
```

**Python patterns → Rust equivalents:**

| Python Pattern | Rust Equivalent |
|---|---|
| Duck typing | Traits with generics |
| `None` | `Option<T>` |
| Exceptions | `Result<T, E>` |
| List comprehensions | Iterator chains with `map()`, `filter()` |
| `with` statements | RAII with `Drop` |
| Decorators | Procedural macros, wrapper functions |
| `*args`, `**kwargs` | Variadic generics (limited), builder pattern |

### Type Hints

```bash
# Find type hints (Python 3.5+)
grep -rn ": str\|: int\|: List\|: Dict\|-> " src/
```

**Use type hints to inform Rust types:**
- `str` → `String` or `&str`
- `int` → `i32`, `i64`, `usize` (context-dependent)
- `float` → `f32`, `f64`
- `List[T]` → `Vec<T>`
- `Dict[K, V]` → `HashMap<K, V>`
- `Optional[T]` → `Option<T>`

### Async Code

```bash
# Find async/await usage
grep -rn "async def\|await " src/

# Event loops
grep -rn "asyncio" src/
```

**Python async → Rust async:**
- `async def` → `async fn`
- `await expr` → `expr.await`
- `asyncio.gather()` → `tokio::join!()`, `futures::join!`
- `asyncio.Queue` → `tokio::sync::mpsc`

## Ruby Analysis

### Metaprogramming

**Identify dynamic behavior:**
```bash
# Eval patterns (dangerous)
grep -rn "eval\|instance_eval\|class_eval\|module_eval" src/

# Method manipulation
grep -rn "define_method\|method_missing\|send" src/

# Monkey patching
grep -rn "class.*<\|module.*include" src/
```

**Ruby patterns → Rust equivalents:**

| Ruby Pattern | Rust Equivalent |
|---|---|
| Blocks/Procs | Closures (`Fn`, `FnMut`, `FnOnce`) |
| `nil` | `Option<T>` |
| Exceptions | `Result<T, E>` |
| Mixins | Traits |
| `attr_accessor` | Derive macros for getters/setters |
| Symbols | Interned strings or enums |
| `yield` | Iterators with `Iterator` trait |

### Rails-Specific Patterns

If rewriting a Rails app:

**Identify framework usage:**
```bash
# ActiveRecord
grep -rn "has_many\|belongs_to\|validates" app/models/

# Controllers
grep -rn "before_action\|respond_to\|render" app/controllers/

# Background jobs
grep -rn "perform_later\|Sidekiq" app/jobs/
```

**Rails → Rust web framework:**
- Models → structs with `sqlx` or `diesel`
- Controllers → axum/actix handlers
- Views → templates (Tera, Askama, or API-only)
- Background jobs → `tokio::spawn()`, dedicated worker service

## Language-Agnostic Analysis

### Configuration Management

```bash
# Find config files
find . -name "*.yml" -o -name "*.yaml" -o -name "*.toml" -o -name "*.json" -o -name "*.ini"

# Environment variables
grep -rn "getenv\|ENV\|os\\.environ" src/
```

**Rust config handling:**
- Use `config` crate for layered configuration
- Use `serde` for deserialization
- Use `dotenvy` for `.env` files

### Logging

```bash
# Find logging calls
grep -rn "log\|logger\|print\|printf\|fmt\\.Print\|puts\|echo" src/
```

**Migrate to structured logging:**
- Use `tracing` crate (preferred)
- Or `log` + `env_logger`
- Replace print debugging with proper log levels

### Error Types

**Catalog error conditions:**
- Network failures
- File I/O errors
- Parse errors
- Validation failures
- Business logic errors

**Design Rust error types:**
```rust
use thiserror::Error;

#[derive(Error, Debug)]
pub enum AppError {
    #[error("network error: {0}")]
    Network(#[from] reqwest::Error),

    #[error("database error: {0}")]
    Database(#[from] sqlx::Error),

    #[error("validation failed: {0}")]
    Validation(String),
}
```

## Security Analysis

### Input Validation

```bash
# Find user input sources
grep -rn "stdin\|argv\|getopt\|input()\|gets\|scanf" src/
grep -rn "request\\.params\|request\\.form\|request\\.json" src/

# SQL construction (injection risk)
grep -rn "execute.*+\|query.*format\|SELECT.*%" src/
```

**Rust hardening:**
- Validate all inputs at boundaries
- Use parameterized queries (sqlx, diesel)
- Use `validator` crate for complex validation

### Crypto Usage

```bash
# Find crypto calls
grep -rn "MD5\|SHA1\|DES\|random\|rand(" src/
```

**Upgrade to secure Rust crypto:**
- Weak hashes → use `sha2`, `blake3`
- Passwords → use `argon2`, `bcrypt`
- Random numbers → use `rand` with `OsRng`
- TLS → use `rustls`, not OpenSSL

### Privilege Separation

```bash
# Find privilege operations
grep -rn "setuid\|setgid\|chroot\|pledge\|unveil" src/
```

**Maintain or improve in Rust:**
- Use `nix` crate for privilege dropping
- Use `landlock` for Linux landlock LSM
- Use `seccomp` for syscall filtering

## Performance Profiling

Before rewriting, profile the original:

```bash
# C/C++: perf, valgrind
perf record -g ./app
perf report

# Go: pprof
go test -cpuprofile cpu.prof -memprofile mem.prof -bench .

# Python: cProfile, py-spy
python -m cProfile -o profile.stats script.py
py-spy record -o profile.svg -- python script.py

# Ruby: stackprof
stackprof app.rb --mode cpu
```

**Identify hotspots** to prioritize in Rust implementation.

## Test Coverage Analysis

```bash
# C: gcov + lcov
gcc --coverage src/*.c
./test
lcov --capture --directory . --output-file coverage.info

# Go: built-in
go test -cover -coverprofile=coverage.out

# Python: coverage.py
coverage run -m pytest
coverage report

# Ruby: SimpleCov
# (in test_helper.rb)
# require 'simplecov'
# SimpleCov.start
```

**Set baseline:** Rust rewrite should match or exceed original coverage.

## Documentation Extraction

**Extract existing documentation:**
```bash
# Find comments
grep -rn "^\/\/\|^\/\*\|^#\|^=begin" src/

# Find docstrings
grep -rn '"""' src/  # Python
```

**Convert to Rust doc comments:**
- `///` for item documentation
- `//!` for module documentation
- Use examples in doc tests

## Dependency Analysis

**List external dependencies:**
```bash
# C: Check Makefile, CMakeLists.txt, configure.ac
# Go: go.mod
# Python: requirements.txt, Pipfile, pyproject.toml
# Ruby: Gemfile
```

**Find Rust equivalents:**
- Search crates.io
- Check [Lib.rs](https://lib.rs/) for categorized crates
- Prefer well-maintained crates with security audits

## Output: Analysis Document

Create `ANALYSIS.md` with:

```markdown
# Original Codebase Analysis

## Architecture
- Module structure: [describe]
- Entry points: [list]
- Data flow: [diagram or description]

## Dependencies
- External libraries: [list with versions]
- System requirements: [OS, services]
- Optional features: [list]

## Security Boundaries
- Privilege separation: [describe]
- Input validation: [list sources]
- Crypto usage: [what and where]

## Tests
- Unit tests: [count, coverage %]
- Integration tests: [count]
- Coverage gaps: [areas with low coverage]

## Performance Characteristics
- Hotspots: [from profiling]
- Bottlenecks: [I/O, CPU, memory]
- Concurrency model: [threads, async, etc.]

## Language-Specific Patterns
- [Pattern 1]: Rust equivalent
- [Pattern 2]: Rust equivalent
- [Pattern 4]: Rust equivalent

## Rust Crate Selection
- HTTP: `reqwest`
- Database: `sqlx`
- [etc.]

## Migration Strategy
- Phase 1: [describe]
- Phase 2: [describe]
- Phase 4: [describe]
```

This analysis document guides the entire rewrite process.
