# Supply-chain / backdoor sanity check

Changelog review alone doesn't catch a compromised release. Always run this check on every
review, whether or not the user asks about backdoors/supply-chain risk:

1. **Install scripts** — the delivery mechanism for the 2025 npm worm attacks (chalk/debug
   family). Scan `package-lock.json` for `hasInstallScript: true` on the changed packages:
   ```python
   import json
   data = json.load(open('package-lock.json'))
   for path, info in data.get("packages", {}).items():
       if info.get("hasInstallScript"):
           print(path, info.get("version"))
   ```
2. **npm audit** — `npm audit --json`, then check whether any flagged advisory actually
   touches a package from this diff (don't let unrelated pre-existing audit noise pollute
   the verdict).
3. **Publish timing coherence** — for packages that jumped multiple majors at once, pull
   `npm view <pkg> time --json` and check whether sibling packages in the same
   family/monorepo published on the same days. Coordinated lockstep releases across a
   family are a sign of a legitimate coordinated release; an isolated single-package
   version jump out of sync with its siblings is a yellow flag worth digging into further.
4. **Name check** — eyeball for typosquats (package names that are near-misses of popular
   packages).
5. **Bundled/minified binaries** — new or changed files that don't look like ordinary
   published JS: `.node` native addons, `.wasm`, `.exe`/ELF/Mach-O binaries, or any file
   whose size/entropy looks off for what the package claims to do (e.g. a tiny CLI helper
   suddenly shipping a multi-MB blob). Compare the file list between old and new tarballs:
   ```bash
   # Fresh dir per package (parallel agents must not share one); outside the project.
   work=$(mktemp -d)
   mkdir "$work/old" "$work/new"
   # --ignore-scripts: never run lifecycle scripts from a release under review.
   # Run from "$work" so the project's .npmrc/lockfile are not picked up.
   (cd "$work" && npm pack "<pkg>@<old>" --ignore-scripts --pack-destination old \
     && npm pack "<pkg>@<new>" --ignore-scripts --pack-destination new)
   # Scoped names pack as scope-name-<ver>.tgz, so glob inside the per-package dir.
   for v in old new; do
     tar tzf "$work/$v"/*.tgz | sort > "$work/$v-files.txt"
   done
   diff "$work/old-files.txt" "$work/new-files.txt"
   ```
   Extract and inspect any newly-added binary-looking file rather than assuming it's benign.
   Treat the tarball as hostile: extract only with `tar xzf ... -C "$work/<dir>"`, never into
   the project, and never `npm install` it or run anything it contains. Read files with
   `file`, `strings`, and `diff -r` on the extracted trees.
6. **In-code exfiltration / destructive-code patterns** — diff the actual published source
   (not just the changelog) between old and new tarballs for **every** package touched by the
   diff, direct and transitive alike — a compromised release can land through any transitive
   package, not just the ones that look high-value. Piggyback this on the step-4 agent groups:
   each agent runs the tarball diff for its own batch of packages (4-6 packages per agent
   already handles the fan-out), so no separate full-sweep pass is needed. Grep the diff for
   signals like:
   - Network calls to unfamiliar hosts/IPs, especially raw IPs or newly-added domains
     (`fetch(`, `http.request(`, `XMLHttpRequest`, `dns.lookup`, `net.connect`)
   - Reads of credential/secret material (`process.env`, `~/.ssh`, `~/.aws`,
     `.npmrc`, `id_rsa`, keychain/credential-store paths, browser cookie/wallet paths)
     followed by anything that serializes and sends it off-host
   - Destructive filesystem operations (`fs.rm`/`rmSync` with recursive/force flags,
     `child_process.exec`/`execSync` with shell strings built from remote data)
   - Obfuscation: unusually long single-line minified blocks in a package that otherwise
     ships readable source, `eval(`, `Function(...)(`, base64/hex blobs decoded and executed,
     unicode homoglyphs in identifiers
   - `postinstall`-adjacent equivalents that aren't in the `scripts` field but achieve the
     same effect (e.g. code that runs at `require()`/module-load time, top-level side effects
     in the main entry file, not just inside exported functions)

   Every package gets the tarball file-list diff (step 5's `npm pack`/`tar tzf`/`diff`) and a
   grep pass over the source diff. Spend more time reading closely on higher blast-radius
   packages (direct deps, deps that touch network/fs/env, anything the earlier steps already
   made suspicious — unexpected install script, isolated off-cadence release, unfamiliar
   binary) — but don't skip a package's diff entirely just because it looks like a
   low-value leaf/string-utility package.

State plainly what was checked per package (source diffed vs. changelog-only) — this is a
lightweight sanity pass, not a full SCA/SBOM scan, but every changed package should at least
get the tarball diff, not just the direct bump target.
