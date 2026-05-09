#!/usr/bin/env bash
set -euo pipefail

BASE_REF="${BASE_REF:-main}"
WATCHLIST_FILE="${WATCHLIST_FILE:-.github/nix-watchlist.txt}"

if [[ ! -f flake.lock ]]; then
  echo "flake.lock not found; skipping report generation." > dependabot-nix-report.md
  exit 0
fi

mkdir -p .tmp

if git show "origin/${BASE_REF}:flake.lock" > .tmp/flake.lock.base 2>/dev/null; then
  :
else
  echo "Could not read flake.lock from origin/${BASE_REF}." > dependabot-nix-report.md
  exit 0
fi

# Snapshot old lock metadata from base branch lock file.
git show "origin/${BASE_REF}:flake.lock" > .tmp/flake.lock.base
cp flake.lock .tmp/flake.lock.head
cp .tmp/flake.lock.base flake.lock
nix flake metadata --json > .tmp/metadata-base.json
cp .tmp/flake.lock.head flake.lock
nix flake metadata --json > .tmp/metadata-head.json

# Build target before and after (best effort).
set +e
cp .tmp/flake.lock.base flake.lock
nix build .#nixosConfigurations.nixos.config.system.build.toplevel -o .tmp/result-base 2> .tmp/build-base.err
base_build_rc=$?
cp .tmp/flake.lock.head flake.lock
nix build .#nixosConfigurations.nixos.config.system.build.toplevel -o .tmp/result-head 2> .tmp/build-head.err
head_build_rc=$?
set -e

if [[ -f "$WATCHLIST_FILE" ]]; then
  mapfile -t watchlist < <(sed -e 's/#.*$//' -e '/^\s*$/d' "$WATCHLIST_FILE")
else
  watchlist=()
fi

if [[ $base_build_rc -eq 0 && $head_build_rc -eq 0 ]]; then
  nvd_output="$(nvd diff .tmp/result-base .tmp/result-head || true)"
  package_rows="$(printf '%s\n' "$nvd_output" | awk '
    /^\[[^]]+\]/ {
      status = $1
      pkg = $2
      old = ""
      new = ""
      if (match($0, /\(([^)]*) -> ([^)]*)\)/, m)) {
        old = m[1]
        new = m[2]
      } else if (match($0, /\(\? -> ([^)]*)\)/, m)) {
        old = "(missing)"
        new = m[1]
      } else if (match($0, /\(([^)]*) -> \?\)/, m)) {
        old = m[1]
        new = "(missing)"
      }
      if (old != "" || new != "") {
        print status "\t" pkg "\t" old "\t" new
      }
    }
  ' )"
fi

{
  echo "## Nix package update report"
  echo
  echo "### 1) flake metadata (base vs PR)"
  echo
  echo '```bash'
  echo "nix flake metadata --json"
  echo '```'
  echo
  echo "<details><summary>Diff metadata JSON</summary>"
  echo
  echo '```diff'
  diff -u .tmp/metadata-base.json .tmp/metadata-head.json || true
  echo '```'
  echo "</details>"
  echo
  echo "### 2) Build status"
  echo
  if [[ $base_build_rc -eq 0 ]]; then
    echo "- ✅ Base lock build succeeded"
  else
    echo "- ⚠️ Base lock build failed"
  fi
  if [[ $head_build_rc -eq 0 ]]; then
    echo "- ✅ PR lock build succeeded"
  else
    echo "- ⚠️ PR lock build failed"
  fi

  if [[ $base_build_rc -eq 0 && $head_build_rc -eq 0 ]]; then
    echo
    echo "### 3) System updated packages"
    echo
    echo "Rows with ⚠️ are also present in \\`$WATCHLIST_FILE\\`."
    echo
    echo "| status | package | base | head | watchlist |"
    echo "|---|---|---:|---:|---|"
    if [[ -n "${package_rows:-}" ]]; then
      while IFS=$'\t' read -r status pkg base_v head_v; do
        [[ -z "$status" ]] && continue
        marker=""
        for w in "${watchlist[@]}"; do
          if [[ "$w" == "$pkg" ]]; then
            marker="⚠️"
            break
          fi
        done
        echo "| $status | $pkg | ${base_v:-(unknown)} | ${head_v:-(unknown)} | $marker |"
      done <<< "$package_rows"
    else
      echo "| (none) | - | - | - | - |"
    fi
  else
    echo
    echo "### 3) Closure / derivation diff"
    echo
    echo "Skipped because one or both builds failed."
    echo
    echo "<details><summary>Build logs</summary>"
    echo
    echo "#### base"
    echo '```text'
    cat .tmp/build-base.err
    echo '```'
    echo
    echo "#### head"
    echo '```text'
    cat .tmp/build-head.err
    echo '```'
    echo "</details>"
  fi

  echo
  echo "### 4) Changelog"
  echo
  echo "Please paste upstream changelog links for the main upgraded packages shown above (e.g. from GitHub releases)."
} > dependabot-nix-report.md

# Restore PR lock file
cp .tmp/flake.lock.head flake.lock
