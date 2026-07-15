#!/usr/bin/env bash
# detect-runner.sh — detect the JS/TS test runner for a project/package.
# Usage: detect-runner.sh [dir]   (defaults to current directory)
# Walks up from [dir] to the nearest package.json, then inspects config,
# dependencies, and the test script. Prints machine-readable KEY=VALUE lines.
set -euo pipefail

start_dir="${1:-.}"
[ -d "$start_dir" ] || { echo "ERROR=not-a-directory:$start_dir"; exit 1; }

# Walk up to the nearest package.json.
dir="$(cd "$start_dir" && pwd)"
pkg=""
while [ "$dir" != "/" ]; do
  if [ -f "$dir/package.json" ]; then pkg="$dir/package.json"; break; fi
  dir="$(dirname "$dir")"
done

if [ -z "$pkg" ]; then
  echo "RUNNER=unknown"
  echo "CONFIG="
  echo "NEXTJS=no"
  echo "TEST_SCRIPT="
  echo "PKG_MANAGER=unknown"
  echo "PACKAGE_DIR=$start_dir"
  echo "NOTE=no package.json found walking up from $start_dir"
  exit 0
fi

pkgdir="$(dirname "$pkg")"

runner="unknown"
config=""

# 1) Config files (decisive).
for f in vitest.config.ts vitest.config.js vitest.config.mjs vitest.config.mts; do
  [ -f "$pkgdir/$f" ] && { runner="vitest"; config="$pkgdir/$f"; break; }
done
if [ "$runner" = "unknown" ]; then
  # vite.config with a test block also implies Vitest.
  for f in vite.config.ts vite.config.js vite.config.mjs vite.config.mts; do
    if [ -f "$pkgdir/$f" ] && grep -Eq "test\s*:" "$pkgdir/$f"; then
      runner="vitest"; config="$pkgdir/$f"; break
    fi
  done
fi
if [ "$runner" = "unknown" ]; then
  for f in jest.config.ts jest.config.js jest.config.mjs jest.config.cjs jest.config.json; do
    [ -f "$pkgdir/$f" ] && { runner="jest"; config="$pkgdir/$f"; break; }
  done
fi

# Helper: grep a dependency name in package.json dependency blocks.
has_dep() { grep -Eq "\"$1\"[[:space:]]*:" "$pkg"; }

# 2) Dependencies (if config didn't decide).
if [ "$runner" = "unknown" ]; then
  if has_dep vitest; then runner="vitest";
  elif has_dep jest || has_dep ts-jest || has_dep babel-jest; then runner="jest";
  fi
fi

# 3) Test script signal (can confirm/override an ambiguous guess).
# Non-greedy capture ([^"]*) so single-line/minified package.json parses correctly.
test_script="$(grep -Eo '"test"[[:space:]]*:[[:space:]]*"[^"]*"' "$pkg" 2>/dev/null | head -1 | sed -E 's/.*:[[:space:]]*"([^"]*)"/\1/' || true)"
if [ "$runner" = "unknown" ] && [ -n "$test_script" ]; then
  case "$test_script" in
    *vitest*) runner="vitest" ;;
    *jest*)   runner="jest" ;;
  esac
fi

# 4) Next.js detection.
nextjs="no"
if has_dep next; then nextjs="yes"; fi
# jest config extending next/jest is a strong Jest signal for Next projects.
if [ "$runner" = "unknown" ] && [ -n "$config" ] && grep -q "next/jest" "$config" 2>/dev/null; then
  runner="jest"
fi

# 5) Package manager from lockfile (nearest, then repo).
pm="npm"
d="$pkgdir"
while [ "$d" != "/" ]; do
  if   [ -f "$d/pnpm-lock.yaml" ]; then pm="pnpm"; break
  elif [ -f "$d/yarn.lock" ];      then pm="yarn"; break
  elif [ -f "$d/bun.lockb" ];      then pm="bun";  break
  elif [ -f "$d/package-lock.json" ]; then pm="npm"; break
  fi
  d="$(dirname "$d")"
done

echo "RUNNER=$runner"
echo "CONFIG=$config"
echo "NEXTJS=$nextjs"
echo "TEST_SCRIPT=$test_script"
echo "PKG_MANAGER=$pm"
echo "PACKAGE_DIR=$pkgdir"
