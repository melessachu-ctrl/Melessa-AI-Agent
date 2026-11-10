# Security patterns for Rust rewrites

## Primary references

- **ANSSI Secure Rust Guidelines**: https://anssi-fr.github.io/rust-guide/
  Published by France's national cybersecurity agency. THE definitive security checklist.
- **RustBelt**: https://plv.mpi-sws.org/rustbelt/popl18/paper.pdf
  Formal proof that Rust's type system provides safety guarantees.
- **Rustonomicon** (unsafe code guide): https://doc.rust-lang.org/nomicon/

## Security by default: what Rust gives you

Rust eliminates these vulnerability classes at compile time:
- Buffer overflows (bounds checking on all array/slice access)
- Use-after-free (ownership system prevents access after move/drop)
- Double free (ownership system prevents multiple frees)
- Null pointer dereference (`Option<T>` instead of null)
- Data races (borrow checker prevents concurrent mutable access)
- Uninitialized memory (compiler requires initialization before use)
- Integer overflow (checked in debug, wrapping or panicking in release — configurable)

Google Android evidence: memory safety bugs dropped from 76% to <20% of total vulnerabilities
after Rust adoption. 1000× reduction in vulnerability density.
Source: https://security.googleblog.com/2025/11/rust-in-android-move-fast-fix-things.html

## Newtype pattern for security invariants

Use newtypes to prevent security-critical type confusion:

```rust
/// A validated, sanitized SQL query parameter.
/// Can only be created through `sanitize()`, preventing SQL injection by construction.
pub struct SanitizedParam(String);

impl SanitizedParam {
    pub fn sanitize(raw: &str) -> Result<Self, SqlInjectionError> {
        // Validation and sanitization logic here
        if contains_sql_injection(raw) {
            return Err(SqlInjectionError(raw.to_string()));
        }
        Ok(SanitizedParam(escape_sql(raw)))
    }

    pub fn as_str(&self) -> &str {
        &self.0
    }
}

// Cannot construct SanitizedParam without going through sanitize():
// SanitizedParam("raw".to_string())  ← COMPILE ERROR (field is private)

/// An authenticated user session. Can only be created through `authenticate()`.
pub struct AuthenticatedSession {
    user_id: UserId,
    token: SessionToken,
    expires_at: SystemTime,
}

impl AuthenticatedSession {
    /// Only way to create a session is through successful authentication.
    pub fn authenticate(credentials: &Credentials) -> Result<Self, AuthError> {
        // ... authentication logic ...
    }

    // All methods that require authentication take &self
    pub fn access_resource(&self, resource: &Resource) -> Result<Data, AuthError> {
        // Authentication is guaranteed by the type system
    }
}
```

## Minimizing and auditing unsafe code

### Crate-level forbid

```rust
// In lib.rs or main.rs — forbid unsafe by default
#![forbid(unsafe_code)]

// In specific modules that NEED unsafe, use allow:
// src/ffi.rs
#![allow(unsafe_code)]
```

### Every unsafe block MUST have a SAFETY comment

```rust
/// # Safety
/// The caller must ensure that `ptr` is a valid, aligned pointer to `len` bytes
/// of initialized memory, and that this memory will not be modified or freed
/// during the lifetime of the returned slice.
pub unsafe fn from_raw_parts<'a>(ptr: *const u8, len: usize) -> &'a [u8] {
    // SAFETY: Caller guarantees ptr is valid for len bytes and outlives 'a.
    // We check for null to provide a friendlier error than a segfault.
    assert!(!ptr.is_null(), "null pointer passed to from_raw_parts");
    unsafe { std::slice::from_raw_parts(ptr, len) }
}
```

### Safe abstraction pattern

```rust
// The OUTER function is safe — it validates all invariants
pub fn get_unchecked_safe(slice: &[u8], index: usize) -> u8 {
    assert!(index < slice.len(), "index {index} out of bounds for len {}", slice.len());
    // SAFETY: We just verified that index < slice.len()
    unsafe { *slice.get_unchecked(index) }
}
```

## Dependency security

### Minimizing dependencies (the sudo-rs approach)

sudo-rs reduced dependencies from 135 to 3 for a setuid-root binary.
Source: https://www.memorysafety.org/blog/reducing-dependencies-in-sudo/

Decision framework for each dependency:
1. How many lines of code does the dependency add?
2. How many transitive dependencies does it pull in?
3. Could a simpler alternative be written in fewer lines than the dependency's code?
4. Is the dependency actively maintained? Who maintains it?
5. Has it been audited? (Check https://github.com/nicross/nicross/blob/main/notes/awesome-rust-audits.md)
6. For security-critical code: does the dependency use `unsafe`? How much?

sudo-rs replaced clap (CLI parsing library) with custom code because their custom solution
required fewer lines than clap would have added as a dependency.

### Dependency auditing tools

```bash
# Check for known vulnerabilities in dependencies
cargo install cargo-audit
cargo audit

# Check licenses, sources, and ban specific crates/versions
cargo install cargo-deny
# Create deny.toml configuration:
cargo deny init
cargo deny check

# Count unsafe usage across entire dependency tree
cargo install cargo-geiger
cargo geiger

# Embed dependency tree into compiled binary for production auditing
cargo install cargo-auditable
cargo auditable build --release
# Later, inspect a production binary:
cargo audit bin ./target/release/my-app
```

### cargo-deny configuration for security-critical projects

```toml
# deny.toml
[advisories]
vulnerability = "deny"       # Fail on known vulnerabilities
unmaintained = "warn"        # Warn on unmaintained crates
yanked = "deny"              # Fail on yanked crate versions
notice = "warn"

[licenses]
unlicensed = "deny"
allow = ["MIT", "Apache-2.0", "BSD-2-Clause", "BSD-3-Clause", "ISC"]
deny = ["GPL-3.0"]           # Adjust per project requirements

[bans]
multiple-versions = "warn"   # Flag dependency version conflicts
wildcards = "deny"           # Require exact versions
allow-wildcard-paths = false

[sources]
unknown-registry = "deny"    # Only allow crates.io
unknown-git = "deny"         # No git dependencies
allow-registry = ["https://github.com/rust-lang/crates.io-index"]
```

## Compiler and build hardening

### Cargo.toml profiles

```toml
[profile.release]
opt-level = 3
lto = "fat"                   # Link-time optimization (slower builds, faster binary)
codegen-units = 1             # Better optimization (slower builds)
panic = "abort"               # Smaller binary, no unwinding overhead
strip = true                  # Strip debug symbols from release binary
overflow-checks = true        # CHECK INTEGER OVERFLOW IN RELEASE (important for security!)

[profile.dev]
overflow-checks = true        # Always check overflow
debug-assertions = true       # Always check debug assertions

[profile.test]
overflow-checks = true
debug-assertions = true
```

### Clippy security lints

```bash
# Run with all pedantic and security-relevant lints
cargo clippy -- \
    -W clippy::all \
    -W clippy::pedantic \
    -W clippy::cargo \
    -W clippy::unwrap_used \
    -W clippy::expect_used \
    -W clippy::panic \
    -W clippy::indexing_slicing \
    -W clippy::arithmetic_side_effects \
    -W clippy::as_conversions
```

Or in `Cargo.toml`:
```toml
[lints.clippy]
all = "warn"
pedantic = "warn"
unwrap_used = "warn"
expect_used = "warn"
panic = "warn"
```

## Verification tools

### Miri — undefined behavior detection

```bash
# Install Miri
rustup +nightly component add miri

# Run tests under Miri (detects UB in unsafe code)
cargo +nightly miri test

# Run a specific test
cargo +nightly miri test specific_test_name

# Miri detects: use-after-free, out-of-bounds access, invalid alignment,
# data races, invalid values in types, memory leaks.
# Miri CANNOT run code with FFI calls.
```

Source: https://dl.acm.org/doi/10.1145/3776690

### Kani — bounded model checking

```rust
// Install Kani
// cargo install --locked kani-verifier
// cargo kani setup

#[cfg(kani)]
mod verification {
    #[kani::proof]
    fn verify_no_overflow() {
        let a: u32 = kani::any();
        let b: u32 = kani::any();

        // Kani will check ALL possible values of a and b
        if let Some(result) = a.checked_add(b) {
            assert!(result >= a);
            assert!(result >= b);
        }
    }
}
```

Kani is used by AWS to verify Firecracker and parts of the Rust standard library.
Source: https://model-checking.github.io/kani-verifier-blog/2022/05/04/announcing-the-kani-rust-verifier-project.html

## ANSSI Secure Rust Guidelines checklist (summary)

From https://anssi-fr.github.io/rust-guide/:

1. **Development tools**: Use `rustfmt`, `clippy`, `cargo audit`, and `cargo deny` in CI
2. **External libraries**: Audit dependencies, prefer well-known crates, minimize count
3. **Language**: Avoid `unsafe` unless necessary; use `#![forbid(unsafe_code)]`
4. **Unsafe code**: Document invariants, minimize scope, test with Miri
5. **FFI**: Use two-layer pattern (`*-sys` + safe wrapper), validate all inputs from FFI
6. **Memory**: Prefer stack allocation, use `zeroize` for sensitive data
7. **Error handling**: Never use `unwrap()` or `expect()` in production code paths that
   handle untrusted input; use `Result` and propagate errors
8. **Integer handling**: Use checked arithmetic for untrusted input; enable overflow checks
9. **Strings**: Validate encoding assumptions; Rust strings are UTF-8, but FFI data may not be
10. **Concurrency**: Prefer message passing over shared state; use `Arc<Mutex<T>>` when needed

## Sensitive data handling

```rust
// Use the `zeroize` crate to clear sensitive data from memory
use zeroize::Zeroize;

struct SecretKey {
    bytes: Vec<u8>,
}

impl Drop for SecretKey {
    fn drop(&mut self) {
        self.bytes.zeroize(); // Overwrite with zeros before deallocation
    }
}

// Use `secrecy` crate for types that prevent accidental logging
use secrecy::{Secret, ExposeSecret};

let api_key: Secret<String> = Secret::new("sk-abc123".to_string());
// println!("{}", api_key);  // This prints "[REDACTED]"
// To access: api_key.expose_secret()
```
