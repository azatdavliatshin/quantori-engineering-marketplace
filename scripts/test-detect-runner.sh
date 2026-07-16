#!/usr/bin/env bash
# Fixture tests for detect-runner.sh — run against every copy in the catalog.
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fail=0

assert() { # assert <label> <output> <expected KEY=VALUE>
  if grep -q "^$3$" <<<"$2"; then
    echo "  ok: $1 -> $3"
  else
    echo "  FAIL: $1 expected '$3', got:"; sed 's/^/    /' <<<"$2"; fail=1
  fi
}

run_suite() {
  local script="$1"
  echo "== $script"
  bash -n "$script" || { echo "  FAIL: syntax"; fail=1; return; }

  local T; T="$(mktemp -d)"

  # 1. React + Vitest via deps
  mkdir -p "$T/a/src"
  echo '{"name":"a","devDependencies":{"vitest":"1"},"dependencies":{"react":"18"}}' > "$T/a/package.json"
  out="$(bash "$script" "$T/a")"
  assert "react-vitest" "$out" "RUNNER=vitest"
  assert "react-vitest" "$out" "REACT=yes"

  # 2. Plain TS + Jest — no React anywhere
  mkdir -p "$T/b/src"; echo "x" > "$T/b/src/index.ts"
  echo '{"name":"b","scripts":{"test":"jest"},"devDependencies":{"jest":"29","ts-jest":"29"}}' > "$T/b/package.json"
  out="$(bash "$script" "$T/b")"
  assert "ts-jest" "$out" "RUNNER=jest"
  assert "ts-jest" "$out" "REACT=no"

  # 3. React via .tsx files only (no react dep)
  mkdir -p "$T/c/src"; echo "x" > "$T/c/src/App.tsx"
  echo '{"name":"c","devDependencies":{"vitest":"1"}}' > "$T/c/package.json"
  out="$(bash "$script" "$T/c")"
  assert "tsx-only" "$out" "REACT=yes"

  # 4. Next.js implies React; next/jest signal
  mkdir -p "$T/d"
  echo '{"name":"d","dependencies":{"next":"15"},"devDependencies":{"jest":"29"}}' > "$T/d/package.json"
  out="$(bash "$script" "$T/d")"
  assert "nextjs" "$out" "NEXTJS=yes"
  assert "nextjs" "$out" "REACT=yes"
  assert "nextjs" "$out" "RUNNER=jest"

  # 5. JSX only inside node_modules must NOT count
  mkdir -p "$T/e/node_modules/x"; echo "x" > "$T/e/node_modules/x/y.jsx"
  echo '{"name":"e","devDependencies":{"jest":"29"}}' > "$T/e/package.json"
  out="$(bash "$script" "$T/e")"
  assert "nm-only" "$out" "REACT=no"

  # 6. No package.json at all
  mkdir -p "$T/f"
  out="$(bash "$script" "$T/f")"
  assert "empty" "$out" "RUNNER=unknown"
  assert "empty" "$out" "REACT=no"

  # 7. Config file beats deps: vitest.config.ts with jest in deps
  mkdir -p "$T/g"
  echo '{"name":"g","devDependencies":{"jest":"29"}}' > "$T/g/package.json"
  touch "$T/g/vitest.config.ts"
  out="$(bash "$script" "$T/g")"
  assert "config-wins" "$out" "RUNNER=vitest"

  rm -rf "$T"
}

found=0
while IFS= read -r script; do
  found=1
  run_suite "$script"
done < <(find "$ROOT" -name detect-runner.sh -not -path '*/node_modules/*' | sort)

[ "$found" = 1 ] || { echo "FAIL: no detect-runner.sh found"; exit 1; }
[ "$fail" = 0 ] && echo "All detect-runner suites passed." || echo "detect-runner tests FAILED."
exit "$fail"
