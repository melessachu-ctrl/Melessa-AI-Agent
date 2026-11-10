# Codebase analysis: understanding existing implementations before rewriting

## Principle: the existing implementation IS the specification

Michael Feathers (Working Effectively with Legacy Code, 2004): "When a system goes into production,
it becomes its own specification." The goal of codebase analysis is NOT to understand every line
of code — it is to capture the BEHAVIOR of the system well enough to write tests that the Rust
rewrite must pass.

Source: https://www.artima.com/weblogs/viewpost.jsp?thread=198296

## Step 1: Architecture-level understanding

### C4 model mapping

Use the C4 model (https://c4model.com/) to document the system at four levels:

1. **Context**: What external systems and actors interact with this software?
   - Other services, databases, file systems, network protocols, users
   - Document every external dependency and interface

2. **Containers**: What are the major runtime units?
   - Processes, libraries, databases, message queues
   - How do they communicate? (HTTP, gRPC, shared memory, pipes, signals)

3. **Components**: What are the major internal modules?
   - Core business logic, I/O handling, configuration, error handling
   - What are the dependencies between them?

4. **Code**: How is the logic structured within components?
   - Key data structures, algorithms, state machines
   - This level is only needed for the specific modules being rewritten

### Generating architecture documentation

For C/C++:
```bash
# Generate call graphs with Doxygen + Graphviz
doxygen -g Doxyfile
# Edit Doxyfile: set HAVE_DOT = YES, CALL_GRAPH = YES, CALLER_GRAPH = YES
doxygen Doxyfile

# Alternative: cflow for simpler call graphs
cflow --tree --main=main src/*.c

# Include-what-you-use for dependency analysis
include-what-you-use -std=c17 src/main.c
```

For Python:
```bash
# pydeps for module dependency graphs
pip install pydeps
pydeps mypackage --max-bacon=3 -o deps.svg

# py-call-graph for runtime call graphs
pip install pycallgraph2
pycallgraph graphviz -- python my_script.py
```

For JavaScript/TypeScript:
```bash
# madge for dependency graphs
npx madge --image deps.svg src/index.ts

# dependency-cruiser for architecture validation
npx depcruise --output-type dot src | dot -Tsvg > deps.svg
```

For Ruby:
```bash
# debride for finding dead code
gem install debride
debride lib/

# ruby-prof for runtime call analysis
ruby -r ruby-prof my_script.rb
```

For Go:
```bash
# go-callvis for call graph visualization
go install github.com/ofabry/go-callvis@latest
go-callvis -group pkg ./cmd/myapp

# godepgraph for dependency graphs
go install github.com/kisielk/godepgraph@latest
godepgraph ./... | dot -Tsvg -o deps.svg
```

For Java:
```bash
# jdeps for module dependencies (built into JDK)
jdeps --dot-output deps/ myapp.jar

# JArchitect or Structure101 for full architecture analysis
```

## Step 2: VCS history mining

VCS history reveals what code changes most (hotspots), why code exists (commit messages),
and who holds knowledge (blame analysis).

```bash
# Find most-changed files (hotspots = likely problem areas)
git log --format=format: --name-only | sort | uniq -c | sort -rn | head -30

# Find files with most distinct authors (knowledge distribution)
git log --format='%an' --name-only | awk '/^$/{next} /^[^\/]/{author=$0; next} {print author, $0}' \
  | sort -u | awk '{print $NF}' | sort | uniq -c | sort -rn | head -20

# Find files that change together (coupling)
git log --format=format: --name-only | awk 'BEGIN{RS=""} {for(i=1;i<=NF;i++) for(j=i+1;j<=NF;j++) print $i, $j}' \
  | sort | uniq -c | sort -rn | head -20

# Find recently active files (current development focus)
git log --since="6 months ago" --format=format: --name-only | sort | uniq -c | sort -rn | head -20

# Identify commit message patterns (bug fixes, security patches)
git log --oneline --grep="fix\|bug\|security\|CVE\|crash\|memory\|leak" | wc -l
```

**CodeScene** (https://codescene.com/) automates all of this with visualization. The open-source
alternative is **code-maat** (https://github.com/adamtornhill/code-maat).

## Step 3: Dynamic analysis — observing runtime behavior

### System call tracing

```bash
# Linux: strace to observe all system calls
strace -f -e trace=file,network,process -o syscalls.log ./my_program args

# macOS: dtruss (requires SIP disabled) or dtrace
sudo dtruss -f ./my_program args

# Count system call types
strace -c ./my_program args
```

### Profiling for call graphs and hot paths

```bash
# C/C++: Valgrind + callgrind for call graphs
valgrind --tool=callgrind ./my_program args
kcachegrind callgrind.out.*

# C/C++: perf for sampling profiler
perf record -g ./my_program args
perf report

# Python: cProfile for call statistics
python -m cProfile -s cumtime my_script.py

# Ruby: stackprof
ruby -r stackprof -e 'StackProf.run(mode: :cpu, out: "stackprof.dump") { load "my_script.rb" }'

# Node.js: --prof flag
node --prof my_script.js
node --prof-process isolate-*.log > profile.txt
```

### Network protocol analysis

```bash
# Capture and analyze network traffic
tcpdump -i lo -w capture.pcap port 8080
tshark -r capture.pcap -T fields -e http.request.method -e http.request.uri
```

## Step 4: Characterization testing

Characterization tests capture the ACTUAL behavior of the existing implementation,
including bugs and undocumented behavior. From Feathers' algorithm:

1. Write an assertion you KNOW will fail
2. Run the test — let the failure tell you the actual behavior
3. Update the assertion to match the actual behavior
4. Repeat until all important paths are covered

### Process for generating characterization tests

```
For each public function/endpoint/command:
  1. Identify typical inputs (from tests, docs, or usage logs)
  2. Identify boundary inputs (empty, max, negative, Unicode, special chars)
  3. Identify error inputs (invalid, missing, malformed)
  4. Run the existing implementation with each input
  5. Record: input → output (stdout, stderr, return code, files written, side effects)
  6. Write a test that asserts this exact behavior
  7. Mark any SURPRISING behavior with a comment: "// NOTE: Original does X here, seems like a bug"
```

### Characterization test template for CLI tools

```bash
#!/bin/bash
# characterize-tool.sh: Record behavior of an existing CLI tool
TOOL=$1
OUTPUT_DIR="characterization-tests"
mkdir -p "$OUTPUT_DIR"

# Define test cases as: description|args|stdin
TEST_CASES=(
    "no_args|"
    "help_flag|--help"
    "version_flag|--version"
    "typical_input|-f input.txt"
    "empty_input|-f /dev/null"
    "missing_file|-f nonexistent.txt"
    "unicode_input|-f unicode-test.txt"
)

for tc in "${TEST_CASES[@]}"; do
    IFS='|' read -r desc args <<< "$tc"
    echo "=== Test: $desc ==="

    # Capture stdout, stderr, and exit code
    stdout=$($TOOL $args 2>/dev/null)
    stderr=$($TOOL $args 2>&1 >/dev/null)
    $TOOL $args >/dev/null 2>&1
    exit_code=$?

    # Write test record
    cat > "$OUTPUT_DIR/${desc}.json" <<EOF
{
    "description": "$desc",
    "command": "$TOOL $args",
    "exit_code": $exit_code,
    "stdout_hash": "$(echo "$stdout" | sha256sum | cut -d' ' -f1)",
    "stderr_hash": "$(echo "$stderr" | sha256sum | cut -d' ' -f1)",
    "stdout_lines": $(echo "$stdout" | wc -l),
    "stderr_lines": $(echo "$stderr" | wc -l)
}
EOF
done
```

### Characterization test template for libraries/APIs

```python
#!/usr/bin/env python3
"""Record behavior of library functions for characterization testing."""
import json
import hashlib
import traceback

def characterize(func, test_cases, output_file):
    """Run func with each test case and record results."""
    results = []
    for name, args, kwargs in test_cases:
        try:
            result = func(*args, **kwargs)
            results.append({
                "name": name,
                "args": repr(args),
                "kwargs": repr(kwargs),
                "result": repr(result),
                "result_type": type(result).__name__,
                "exception": None,
            })
        except Exception as e:
            results.append({
                "name": name,
                "args": repr(args),
                "kwargs": repr(kwargs),
                "result": None,
                "exception": f"{type(e).__name__}: {e}",
                "traceback": traceback.format_exc(),
            })

    with open(output_file, 'w') as f:
        json.dump(results, f, indent=2)
    print(f"Recorded {len(results)} characterization tests to {output_file}")
```

## Step 5: Interface inventory

Document every external interface — this is the contract the Rust rewrite MUST honor.

### Interface inventory checklist

```markdown
## Public API surface

### CLI interface
- [ ] All command-line flags and their behaviors
- [ ] All subcommands
- [ ] Exit codes and their meanings
- [ ] Stdin/stdout/stderr behavior for each mode
- [ ] Signal handling (SIGINT, SIGTERM, SIGHUP, etc.)
- [ ] Environment variables read

### File formats
- [ ] Configuration file format and all supported options
- [ ] Input file formats with parsing rules
- [ ] Output file formats

### Network protocols
- [ ] Ports and protocols (TCP, UDP, Unix sockets)
- [ ] Request/response formats
- [ ] Authentication mechanisms
- [ ] TLS requirements

### Library API
- [ ] All public functions with signatures
- [ ] All public types and their invariants
- [ ] Error types and when they're returned
- [ ] Thread safety guarantees
- [ ] Callback/hook interfaces

### Platform behavior
- [ ] OS-specific behavior differences
- [ ] File system interactions (permissions, paths, symlinks)
- [ ] Locale/encoding behavior
```

## Step 6: Using C2Rust for C codebase understanding

**C2Rust** (https://c2rust.com/) transpiles C99 to unsafe Rust. The output is NOT idiomatic —
it's a direct translation full of `unsafe` blocks. Use it as a READING AID, not as the final code.

```bash
# Install C2Rust
cargo install c2rust

# Transpile a C project
c2rust transpile compile_commands.json

# The output preserves structure but is non-idiomatic:
# - Global mutable state becomes unsafe static
# - Pointers become raw pointers
# - malloc/free become unsafe alloc calls
# The value is in understanding the LOGIC, not in using the output directly.
```

Recent research (C2SaferRust, 2025 — https://arxiv.org/html/2501.14257v1) combines C2Rust with
LLM-based translation to produce safer, more idiomatic output. Successfully translated 7 GNU
coreutils programs.

## Step 7: Pre-rewrite trimming

From Philippe Gaultier's C++ → Rust case study:
> Before rewriting, he removed 33-50% of the original codebase that was unused or unnecessary.

Process:
1. Identify dead code: functions never called, features never enabled
2. Identify rarely-used features: check logs, usage metrics, or user surveys
3. **Explicitly decide** which features to port and which to drop
4. Document dropped features with rationale
5. sudo-rs intentionally omitted sendmail support and wildcards in argument positions — both
   were rarely used and expanded the attack surface unnecessarily
