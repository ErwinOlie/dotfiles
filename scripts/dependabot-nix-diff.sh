#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <base_dir> <head_dir> [system]" >&2
  exit 1
fi

BASE_DIR="$1"
HEAD_DIR="$2"
SYSTEM="${3:-x86_64-linux}"
WATCHLIST_FILE="${WATCHLIST_FILE:-.github/nix-watchlist.txt}"

if [[ ! -f "$WATCHLIST_FILE" ]]; then
  echo "Watchlist file not found: $WATCHLIST_FILE" >&2
  exit 1
fi

get_version() {
  local dir="$1"
  local pkg="$2"
  nix eval --raw --extra-experimental-features 'nix-command flakes' \
    --expr "let flake = builtins.getFlake (toString ${dir@Q}); in flake.inputs.nixpkgs.legacyPackages.${SYSTEM}.${pkg}.version" 2>/dev/null || true
}

printf "## Nixpkgs package diff\n\n"
printf "Compared lockfile update for \\`nixpkgs\\` on \\`%s\\`.\n\n" "$SYSTEM"
printf "| package | base | head | status |\n"
printf "|---|---:|---:|---|\n"

changes=0
while IFS= read -r pkg; do
  [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue

  base_v="$(get_version "$BASE_DIR" "$pkg")"
  head_v="$(get_version "$HEAD_DIR" "$pkg")"

  [[ -z "$base_v" ]] && base_v="(missing)"
  [[ -z "$head_v" ]] && head_v="(missing)"

  if [[ "$base_v" == "$head_v" ]]; then
    status="unchanged"
  elif [[ "$base_v" == "(missing)" ]]; then
    status="added"
    ((changes+=1))
  elif [[ "$head_v" == "(missing)" ]]; then
    status="removed"
    ((changes+=1))
  else
    status="updated"
    ((changes+=1))
  fi

  printf "| \\`%s\\` | %s | %s | %s |\n" "$pkg" "$base_v" "$head_v" "$status"
done < "$WATCHLIST_FILE"

printf "\n"
if [[ "$changes" -eq 0 ]]; then
  printf "Geen versieverschillen gevonden voor de watchlist.\n"
else
  printf "Totaal gewijzigde entries: **%d**.\n" "$changes"
fi
