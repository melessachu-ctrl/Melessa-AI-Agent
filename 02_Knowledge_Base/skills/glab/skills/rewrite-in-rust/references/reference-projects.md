# Reference projects: documented Rust rewrites

This reference catalogs production Rust rewrites with published technical write-ups, quantified
results, and lessons learned. Use these as evidence when justifying migration decisions, selecting
architecture strategies, and estimating effort.

## Tier 1: Extensively documented migrations with published post-mortems

### Cloudflare Pingora (C/Lua NGINX → Rust)

- **Source**: https://blog.cloudflare.com/how-we-built-pingora-the-proxy-that-connects-cloudflare-to-the-internet/
- **Also**: https://blog.cloudflare.com/20-percent-internet-upgrade/
- **Repo**: https://github.com/cloudflare/pingora (Apache 2.0)
- **From**: NGINX (C + Lua modules)
- **Results**: 70% less CPU, 67% less memory, connection reuse 87.1% → 99.92%
- **Scale**: >1 trillion requests/day
- **Architecture**: Full rewrite (NGINX's worker-process model was architecturally incompatible with
  connection-reuse requirements). Built custom HTTP library instead of using `hyper` because they
  needed to handle non-RFC-compliant real-world internet traffic.
- **Key lesson**: Sometimes a full rewrite is justified when the original architecture is
  fundamentally incompatible with requirements. Cloudflare also rewrote FL (routing brain) as FL2
  on the Oxy framework after Pingora proved the approach.
- **Testing strategy**: Gradual traffic migration — started with small percentage, validated
  metrics at each step before increasing.

### Discord Read States (Go → Rust)

- **Source**: https://discord.com/blog/why-discord-is-switching-from-go-to-rust
- **From**: Go 1.9
- **Results**: Eliminated 10-50ms GC latency spikes occurring every 2 minutes. Unoptimized Rust
  outperformed hyper-tuned Go.
- **Root cause**: Go's GC scanned millions of LRU cache entries; minimum 2-minute GC cycle was
  pathological for this workload.
- **Architecture**: Targeted rewrite of a single service (Read States). Not a whole-platform migration.
- **Key lesson**: GC-induced latency in hot paths is one of the strongest justifications for a
  Rust rewrite. Discord now considers Rust for any latency-sensitive service.
- **Testing strategy**: A/B deployment with metrics comparison between Go and Rust versions.

### Dropbox Nucleus sync engine (Python → Rust)

- **Source**: https://dropbox.tech/infrastructure/rewriting-the-heart-of-our-sync-engine
- **From**: Python
- **Results**: Called Rust "a force multiplier for our team"
- **Architecture**: Full rewrite — Python's data model had fundamental architectural limits at scale.
- **Key lesson**: Deterministic simulation testing was critical — single control thread with Rust
  futures, fully deterministic via fixed PRNG seeds, tens of millions of randomized fuzz test runs
  nightly. Also: Dropbox initially rewrote Tomahawk (API server) in Rust but moved it to Go because
  porting their entire internal ecosystem (monitoring, RPC, auth) was prohibitively expensive.
  **Rewrite what benefits from Rust's strengths, not everything.**
- **Testing strategy**: Deterministic simulation testing + massive fuzz testing.

### sudo-rs (C → Rust)

- **Source**: https://www.memorysafety.org/initiative/sudo-su/
- **Blog**: https://ferrous-systems.com/blog/testing-sudo-rs/
- **Repo**: https://github.com/trifectatechfoundation/sudo-rs
- **From**: C (sudo/su)
- **Results**: Memory-safe sudo. Becoming Ubuntu default in 25.10, LTS 26.04.
- **Architecture**: Full rewrite. Intentionally omitted rarely-used features (sendmail support,
  wildcards in argument positions) to shrink attack surface.
- **Security**: Reduced dependencies from 135 to 3. Two independent security audits completed.
- **Key lesson**: THE model for security-critical rewrites. Their testing approach is the gold
  standard — see test-validation-strategies.md for details.
- **Testing strategy**: Implementation-agnostic compliance test suite running in ephemeral Docker
  environments. Tests verify behavior described in sudo documentation. `SUDO_UNDER_TEST` env var
  switches between implementations. Discovered and fixed 2 bugs in original sudo.

### uutils coreutils (C → Rust)

- **Source**: https://github.com/uutils/coreutils
- **Compatibility tracking**: https://github.com/uutils/coreutils/wiki/Compatibility
- **From**: GNU coreutils (C)
- **Results**: 96.28% GNU test suite compatibility (v0.6.0), 22,500+ stars, 530+ contributors
- **Architecture**: Incremental — each utility (ls, cp, cat, etc.) is an independent crate.
- **Key lesson**: THE model for compatibility-focused rewrites. Runs the ENTIRE GNU coreutils
  test suite against Rust binaries. Also runs BusyBox and ToyBox test suites. Integrates
  differential fuzzing via OSS-Fuzz.
- **Testing strategy**: GNU test suite as primary oracle + BusyBox + ToyBox + OSS-Fuzz.
  Compatibility tracked quantitatively in CI with every release.

### Fish Shell 4.0 (C++ → Rust)

- **Source**: https://fishshell.com/blog/rustport/
- **Plan**: https://github.com/fish-shell/fish-shell/blob/master/doc_internal/fish-riir-plan.md
- **From**: C++ (~72,000 LOC)
- **Architecture**: "Fish of Theseus" — incremental replacement over ~2 years. Ported "outside in"
  from leaf builtins to core systems. Used autocxx/cxx for C++↔Rust interop during transition.
  Always maintained a working, shippable shell at every commit.
- **Key lesson**: The incremental approach works even for tightly-coupled codebases. The key is
  starting from leaf nodes and working inward. autocxx/cxx handled the interop layer.
- **Testing strategy**: Existing Fish test suite served as behavioral oracle throughout migration.
  Each ported component had to pass all existing tests before the C++ version was removed.

## Tier 2: Well-documented production deployments

### AWS Firecracker (QEMU C → Rust)

- **Source**: https://www.amazon.science/blog/how-awss-firecracker-virtual-machines-work
- **Repo**: https://github.com/firecracker-microvm/firecracker
- **From**: QEMU (C, ~4 million LOC)
- **Results**: ~50,000 LOC (96% reduction), 150 microVMs/sec, <125ms boot times
- **Testing**: Formally verified with Kani model checker.

### Figma multiplayer server (TypeScript → Rust, partial)

- **Source**: https://www.figma.com/blog/rust-in-production-at-figma/
- **From**: TypeScript/Node.js
- **Results**: 10× server-side performance improvement
- **Key lesson**: Explicitly chose NOT to rewrite the entire server — only performance-critical
  encoding and syncing components. **Targeted rewrites yield the greatest ROI.**

### 1Password core engine (multiple → Rust)

- **Source**: https://serokell.io/blog/rust-in-production-1password
- **Architecture**: Headless Rust application with thin native UI layers per platform. Rust core
  handles all business logic, crypto, database, and server communication.
- **Key lesson**: Rust fulfilled 90% of hopes. Primary complaint: compile times. Cross-platform
  shared core eliminates the "rewrite the logic for every platform" problem.

### Microsoft Windows kernel (C/C++ → Rust, incremental)

- **Source**: https://www.theregister.com/2023/04/27/microsoft_windows_rust/
- **DWriteCore**: 152K lines Rust + 96K lines C++, 5-15% faster glyph shaping
- **Win32 GDI**: 36K lines Rust, boots and passes all tests behind feature flag
- **Key lesson**: Even the world's largest C/C++ codebase is migrating incrementally to Rust.
  Microsoft targets replacing C/C++ code with Rust by 2030.

### Google Android (C/C++ → Rust for new code + targeted rewrites)

- **Source**: https://security.googleblog.com/2025/11/rust-in-android-move-fast-fix-things.html
- **Also**: https://rustfoundation.org/media/the-power-of-rust-adoption-lessons-from-google/
- **Results**: Memory safety bugs dropped from 76% to <20% of total vulnerabilities.
  1000× reduction in vulnerability density. Rust changes have 4× lower rollback rate,
  25% less code review time. Survey of 1000+ developers: most productive within weeks.
- **Key lesson**: Interoperability over rewrites. Write new code in Rust, rewrite existing code
  only when it requires substantial changes anyway.

### InfluxDB 3.0 (Go → Rust)

- **Full rewrite enabling tiered storage, high-cardinality metadata, native SQL. Research project
  started 2019, launched 2023.

## Tier 3: JavaScript tooling rewrites

The entire JS build pipeline has been rebuilt in Rust:

| Tool | Replaces | Speedup | Source |
|------|----------|---------|--------|
| **SWC** | Babel | 20-70× | https://swc.rs/ |
| **Turbopack** | webpack | 700× cold starts | Vercel/Next.js |
| **Biome** | Prettier+ESLint | 95%+ faster | https://biomejs.dev/ |
| **Rspack** | webpack | webpack-compatible API | https://github.com/web-infra-dev/rspack |
| **Rolldown** | Rollup | Rollup-compatible | Evan You / Vue.js |
| **oxc** | ESLint/Babel/Prettier | 50-100× | https://oxc.rs/ |

- **Curated list**: https://github.com/nicross/nicross/blob/main/notes/awesome-js-tooling-in-rust.md

## Tier 4: CLI tool replacements (all production-quality, widely adopted)

| Rust tool | Replaces | Key advantage |
|-----------|----------|---------------|
| **ripgrep** | grep | 2-5× faster, Unicode-aware |
| **fd** | find | Simpler syntax, faster |
| **bat** | cat | Syntax highlighting, Git integration |
| **eza** | ls | Colors, Git status, tree view |
| **delta** | diff | Syntax highlighting, side-by-side |
| **dust** | du | Visual, intuitive output |
| **zoxide** | cd/autojump | Frecency-based |
| **Alacritty** | terminal emulators | GPU-accelerated |
| **Zellij** | tmux/screen | Plugin system, Rust-native |
| **Helix** | vim/neovim | Tree-sitter, LSP built-in |
| **Starship** | oh-my-zsh prompts | Fast, cross-shell |

## Curated lists for further reference

- **awesome-rewrite-it-in-rust**: https://github.com/j-m-hoffmann/awesome-rewrite-it-in-rust
- **awesome-alternatives-in-rust**: https://github.com/flobsx/awesome-alternatives-in-rust
- **Rust adoption list**: https://github.com/brson/my-rust-lists/blob/master/rust-adoption.md
- **awesome-js-tooling-in-rust**: https://github.com/nicross/nicross/blob/main/notes/awesome-js-tooling-in-rust.md
- **ISRG/Prossimo memory safety initiative**: https://www.memorysafety.org/
