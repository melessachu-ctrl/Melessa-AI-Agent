# Releases, Deploys & Sourcemaps

- [Releases](#releases)
- [Deploys](#deploys)
- [Sourcemaps](#sourcemaps)
- [Debug Files](#debug-files)

## Releases

Releases are global per organization. Use unique version names across projects if needed (e.g. `projectA-1.0`).

### Lifecycle

```bash
# 1. Create a release (starts as "unreleased")
sentry-cli releases new "$VERSION" -o ORG -p PROJECT

# 2. Associate commits
sentry-cli releases set-commits "$VERSION" --auto -o ORG

# 3. Upload artifacts (sourcemaps, debug files)
sentry-cli sourcemaps upload /path -o ORG -p PROJECT

# 4. Finalize (marks as released, sets timestamp)
sentry-cli releases finalize "$VERSION" -o ORG

# 5. Create deploy
sentry-cli deploys new -o ORG -r "$VERSION" -e production
```

Or create + finalize in one step:

```bash
sentry-cli releases new "$VERSION" --finalize -o ORG -p PROJECT
```

### Commands

```bash
sentry-cli releases list -o ORG -p PROJECT
sentry-cli releases info VERSION -o ORG
sentry-cli releases new VERSION -o ORG -p PROJECT
sentry-cli releases new VERSION --finalize -o ORG -p PROJECT
sentry-cli releases finalize VERSION -o ORG
sentry-cli releases delete VERSION -o ORG -p PROJECT
sentry-cli releases archive VERSION -o ORG
sentry-cli releases restore VERSION -o ORG
```

### Propose Version (from git)

```bash
VERSION=$(sentry-cli releases propose-version)
```

Uses git HEAD to generate a version string.

### Set Commits

```bash
# Auto-detect from git repo + configured source code integration
sentry-cli releases set-commits "$VERSION" --auto -o ORG

# Without repo integration (uses local git tree)
sentry-cli releases set-commits "$VERSION" --local -o ORG

# Manual: specific repo + commit
sentry-cli releases set-commits "$VERSION" --commit "owner/repo@deadbeef" -o ORG

# Manual: commit range
sentry-cli releases set-commits "$VERSION" --commit "owner/repo@prev_sha..current_sha" -o ORG

# Ignore missing commits (rebased/squashed)
sentry-cli releases set-commits "$VERSION" --auto --ignore-missing -o ORG
```

List configured repos: `sentry-cli repos list -o ORG`

## Deploys

```bash
sentry-cli deploys new -o ORG -r "$VERSION" -e production
sentry-cli deploys new -o ORG -r "$VERSION" -e staging -t 120   # duration in seconds
sentry-cli deploys list -o ORG -r "$VERSION"
```

## Sourcemaps

### Upload

```bash
# Basic upload (auto-detects .js ↔ .map relationships)
sentry-cli sourcemaps upload /path/to/sourcemaps -o ORG -p PROJECT

# With URL prefix (match where sources are hosted)
sentry-cli sourcemaps upload /path --url-prefix '~/static/js' -o ORG -p PROJECT

# Strip common path prefix from source references
sentry-cli sourcemaps upload /path --url-prefix '~/static/js' --strip-common-prefix -o ORG -p PROJECT

# With validation
sentry-cli sourcemaps upload /path --validate -o ORG -p PROJECT

# Custom file extensions
sentry-cli sourcemaps upload /path --ext js --ext map -o ORG -p PROJECT

# With ignore patterns
sentry-cli sourcemaps upload /path --ignore node_modules -o ORG -p PROJECT
sentry-cli sourcemaps upload /path --ignore-file .sentryignore -o ORG -p PROJECT

# With dist for disambiguation
sentry-cli sourcemaps upload /path --dist 42 -o ORG -p PROJECT

# Fail if nothing to upload
sentry-cli sourcemaps upload /path --strict -o ORG -p PROJECT
```

For all upload options and their defaults, run
`sentry-cli sourcemaps upload --help`.

### Inject Debug IDs

```bash
sentry-cli sourcemaps inject /path/to/sourcemaps
```

Modifies JS files and sourcemaps in-place to add debug IDs for reliable sourcemap association.

### Resolve

```bash
sentry-cli sourcemaps resolve /path/to/file.min.js LINE COLUMN
```

By default, sentry-cli **rewrites sourcemaps** before upload:
1. Flattens indexed source maps
2. Inlines local file references for source contents
3. Validates sourcemaps automatically

## Debug Files

```bash
sentry-cli debug-files upload /path -o ORG -p PROJECT
sentry-cli debug-files check /path/to/file
sentry-cli debug-files find DEBUG_ID
sentry-cli debug-files print-sources /path/to/file
sentry-cli debug-files bundle-sources /path/to/file
```
