# Migration architectures: strategies for rewriting in Rust

## Decision framework: incremental vs. full rewrite

Use this scoring system (adapted from community consensus documented at nandann.com and
gaultier.github.io) to decide:

```
Score each factor from +1 (low) to +3 (high):
  Infrastructure costs (CPU, memory, scaling pain)    : ___
  Security incidents (CVEs, memory safety bugs)       : ___
  Performance requirements (latency, throughput)      : ___
  Team Rust capacity (experience, willingness)        : ___

Score each risk from -1 (low) to -3 (high):
  Codebase size and complexity                        : ___
  Internal ecosystem dependencies (monitoring, RPC)   : ___
  Timeline pressure                                   : ___

Total: ___

Interpretation:
  +8 or higher  → Strong case for rewrite
  +3 to +7      → Start with a targeted pilot
  0 to +2       → Weak case; consider targeted Rust modules only
  Negative      → Do not rewrite; invest in improving the existing codebase
```

### When full rewrite is justified (evidence from production)

Full rewrites succeeded when the ARCHITECTURE was the problem, not just the language:
- **Cloudflare Pingora**: NGINX's worker-process model prevented connection reuse
- **Dropbox Nucleus**: Python data model had fundamental limits at scale
- **InfluxDB 3.0**: Go implementation couldn't support tiered storage architecture
- **sudo-rs**: C codebase had decades of accumulated complexity; memory safety was existential

### When incremental rewrite is required

Incremental migration is the default. Use it when:
- Codebase is >10K LOC
- System must remain operational throughout migration
- Team is learning Rust during the migration
- Internal ecosystem (monitoring, auth, RPC) can't be ported immediately

**Evidence**: Big-bang migration failure rates run 4.2× higher than incremental ones
(Thoughtworks: https://www.thoughtworks.com/en-cl/insights/blog/amortizing-software-rewrites-evolutionary-approach).
Joel Spolsky's 2000 warning about full rewrites remains relevant — but the strangler fig pattern
fundamentally changes the risk equation.

## The strangler fig pattern for Rust migration

Named by Martin Fowler after the strangler fig tree that grows around its host. Three phases:

### Phase 1: Identify and extract

```
┌─────────────────────────────────┐
│         Legacy System           │
│  ┌─────────┐  ┌─────────┐     │
│  │ Module A │  │ Module B │     │
│  │ (target) │  │          │     │
│  └─────────┘  └─────────┘     │
└─────────────────────────────────┘
```

Select initial targets using KDAB's criteria (from their best practices guide at
https://kdab.com/publications/bestpractices/best-practices-hybrid-rust-cpp-apps.html):
- **Problematic**: Source of bugs, security issues, performance problems
- **Self-contained**: Sharp boundaries, minimal coupling
- **Clean interface**: Well-defined inputs and outputs
- **Idiomatically similar**: Maps well to Rust patterns

Good first targets (in priority order):
1. Leaf libraries with no downstream dependencies in the legacy codebase
2. Parsers and input handlers (especially for untrusted data)
3. Performance-critical hot paths
4. Security-critical modules (crypto, auth, privilege management)
5. Modules with high bug density (mine VCS history to find these)

### Phase 2: Build alongside with FFI bridge

```
┌─────────────────────────────────────────┐
│              Facade Layer               │
│  ┌──────────────┐  ┌──────────────┐    │
│  │  Rust Module  │  │ Legacy Module│    │
│  │  (Module A')  │  │  (Module B)  │    │
│  └──────┬───────┘  └──────────────┘    │
│         │ FFI bridge                    │
│  ┌──────┴───────┐                      │
│  │ Legacy Mod A │  ← still available   │
│  └──────────────┘    for rollback      │
└─────────────────────────────────────────┘
```

### Phase 3: Redirect and retire

Once the Rust module passes all tests and shadow testing confirms behavioral equivalence,
redirect traffic/calls to the Rust version. Keep the legacy module available for rollback
until confidence is established (typically 2-4 weeks of production traffic).

## FFI bridging strategies

### C ↔ Rust

**bindgen** (https://github.com/rust-lang/rust-bindgen): Auto-generates Rust FFI bindings from C headers.
```bash
# Install
cargo install bindgen-cli

# Generate bindings
bindgen wrapper.h -o src/bindings.rs
```

**cbindgen** (https://github.com/eyre-rs/cbindgen): Generates C/C++ headers from Rust code.
Used by Mozilla Firefox in production.
```bash
cargo install cbindgen
cbindgen --config cbindgen.toml --crate my-crate --output my_crate.h
```

**ANSSI two-layer pattern** (https://anssi-fr.github.io/rust-guide/):
```rust
// Layer 1: Low-level *-sys crate with raw FFI
// my-lib-sys/src/lib.rs
extern "C" {
    fn legacy_process(data: *const u8, len: usize) -> i32;
}

// Layer 2: Safe wrapper crate
// my-lib/src/lib.rs
pub fn process(data: &[u8]) -> Result<(), Error> {
    // SAFETY: data.as_ptr() is valid for data.len() bytes,
    // and legacy_process does not retain the pointer after returning.
    let result = unsafe { my_lib_sys::legacy_process(data.as_ptr(), data.len()) };
    match result {
        0 => Ok(()),
        e => Err(Error::Legacy(e)),
    }
}
```

### C++ ↔ Rust

**CXX** (https://cxx.rs/): Safe interop — "auditing just the C++ side is sufficient to catch
all problems."
```rust
// src/main.rs
#[cxx::bridge]
mod ffi {
    // Shared types
    struct BlobMetadata {
        size: usize,
        tags: Vec<String>,
    }

    // Functions implemented in C++
    unsafe extern "C++" {
        include!("my-project/include/blobstore.h");
        type BlobstoreClient;
        fn new_blobstore_client() -> UniquePtr<BlobstoreClient>;
        fn put(&self, parts: &mut MultiBuf) -> u64;
    }

    // Functions implemented in Rust
    extern "Rust" {
        fn process_metadata(metadata: &BlobMetadata) -> String;
    }
}
```

**autocxx**: Consumes C++ headers directly for higher-level interop. Used by Fish Shell
during the C++ → Rust transition.

### Python ↔ Rust

**PyO3** (https://pyo3.rs/): Dominant solution for Python↔Rust interop.
```rust
use pyo3::prelude::*;

#[pyfunction]
fn sum_as_string(a: usize, b: usize) -> PyResult<String> {
    Ok((a + b).to_string())
}

#[pymodule]
fn my_module(m: &Bound<'_, PyModule>) -> PyResult<()> {
    m.add_function(wrap_pyfunction!(sum_as_string, m)?)?;
    Ok(())
}
```

Combined with **maturin** for package building:
```bash
pip install maturin
maturin develop  # Build and install in current virtualenv
maturin build    # Build wheel for distribution
```

Migration pattern: replace Python modules bottom-up through the dependency hierarchy.
Start with leaf modules that have the clearest interface.

### Ruby ↔ Rust

**Rutie** (https://github.com/danielpclark/rutie) or **Magnus** (https://github.com/matsadler/magnus):
```rust
// Using Magnus
use magnus::{define_module, function, prelude::*, Error};

fn fibonacci(n: usize) -> usize {
    match n {
        0 => 0,
        1 => 1,
        _ => fibonacci(n - 1) + fibonacci(n - 2),
    }
}

#[magnus::init]
fn init() -> Result<(), Error> {
    let module = define_module("MyRustLib")?;
    module.define_singleton_method("fibonacci", function!(fibonacci, 1))?;
    Ok(())
}
```

### Node.js/JavaScript ↔ Rust

**Napi-rs** (https://napi.rs/): Build Node.js addons in Rust.
```rust
use napi_derive::napi;

#[napi]
fn sum(a: i32, b: i32) -> i32 {
    a + b
}
```

**wasm-bindgen** for WebAssembly targets:
```rust
use wasm_bindgen::prelude::*;

#[wasm_bindgen]
pub fn greet(name: &str) -> String {
    format!("Hello, {}!", name)
}
```

### Go ↔ Rust

No mature FFI bridge exists. Go's goroutine runtime and Rust's async runtime conflict.
The recommended approach is **service-level integration**: run Rust and Go as separate
processes communicating via gRPC, HTTP, or message queues. This is what Discord did.

### Java/JVM ↔ Rust

**JNI via jni crate** (https://docs.rs/jni/):
```rust
use jni::JNIEnv;
use jni::objects::JClass;
use jni::sys::jstring;

#[no_mangle]
pub extern "system" fn Java_MyClass_hello(
    mut env: JNIEnv,
    _class: JClass,
) -> jstring {
    let output = env.new_string("Hello from Rust!").expect("Couldn't create string");
    output.into_raw()
}
```

## Build integration

**Corrosion** (https://github.com/corrosion-rs/corrosion): CMake integration for Rust.
Supports CXX, cbindgen, and bindgen workflows.
```cmake
find_package(Corrosion REQUIRED)
corrosion_import_crate(MANIFEST_PATH rust-lib/Cargo.toml)
target_link_libraries(my_cpp_app PRIVATE rust-lib)
```

## Critical warning: FFI safety

From Philippe Gaultier's C++ → Rust case study
(https://gaultier.github.io/blog/lessons_learned_from_a_successful_rust_rewrite.html):

> "It is easier to inadvertently introduce Undefined Behavior in Rust than in C++ when using
> unsafe blocks."

Rust's memory model has stricter aliasing requirements than C/C++. Raw pointers at FFI boundaries
can violate these requirements silently. Mitigations:
1. Use the ANSSI two-layer pattern (raw `*-sys` crate + safe wrapper)
2. Run Miri on all testable code (note: Miri cannot run code with actual FFI calls)
3. Use feature flags to separate FFI code from pure-Rust code for testing:
   ```rust
   #[cfg(not(feature = "ffi"))]
   fn process(data: &[u8]) -> Result<(), Error> {
       // Pure Rust implementation for testing with Miri
   }

   #[cfg(feature = "ffi")]
   fn process(data: &[u8]) -> Result<(), Error> {
       // FFI implementation
   }
   ```
4. Minimize the `unsafe` surface area — keep FFI boundaries as thin as possible
