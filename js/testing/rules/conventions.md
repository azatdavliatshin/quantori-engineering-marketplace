# TypeScript Testing Conventions (swappable)

> **This file is the swappable seam.** It holds project- and org-specific conventions. The commands and the backing skill read it instead of hard-coding rules, so you can drop in Quantori's conventions (or another project's) without editing any command or skill. Everything below is **generic best-practice** — replace or extend it as needed.
>
> To swap: keep the same headings so the skill can find each section; change the content under them.
>
> **Structure:** the first part is the **general TypeScript core** and always applies. The **React section** at the end applies **only when the detector reports `REACT=yes`**.

## Language & types

- Output TypeScript: `.ts` for logic, `.tsx` for anything with JSX. Never author tests in plain JS for a TS project.
- No `any`. Prefer precise types; use `unknown` + narrowing when a type is truly open. Type test helpers and mock factories too.
- Import types with `import type { ... }` where the value isn't used at runtime.

## Test file location & naming

- **Colocate** tests next to the unit under test: `parse.ts` → `parse.test.ts` in the same folder. (If a project clearly uses a `__tests__/` folder or a `.spec.` suffix, match the project's existing pattern instead — detect, don't impose.)
- One test file per source module. Name the top-level `describe` after the module/function under test.

## What to test (priority order)

1. **Behavior, not implementation.** Assert on what the consumer observes (return values, emitted events, called callbacks, thrown errors), not on internal state or private methods.
2. **The contract:** inputs → outputs/effects. Cover the documented input combinations of each exported unit.
3. **Branches & edge cases:** error paths, boundary values, empty/falsy inputs, the "nothing to do" path.
4. **Async behavior:** resolved and rejected promises, ordering, cancellation/timeout paths where they exist.

Do **not** write tests that merely restate the implementation, snapshot enormous structures, or assert on internals that aren't part of the contract.

## Mocking

- Mock at the module boundary (network, timers, filesystem, external SDKs), not the unit under test.
- Prefer dependency injection / MSW for network over hand-rolled `fetch` mocks where the project already uses them.
- Reset mocks between tests (`beforeEach` / `clearMocks`), and restore real timers you faked.
- Keep mocks minimal and typed — a mock that drifts from the real signature is worse than none.

## Assertions & structure

- Arrange–Act–Assert per test; one behavior per `it`. A descriptive `it('rejects an expired token')` beats a comment.
- No conditional logic or loops that hide which case failed, unless it's a deliberate `it.each` table.
- Assert the most specific thing that's part of the contract: `toEqual` on the shape over `toBeTruthy`, `rejects.toThrow(SpecificError)` over a bare rejection check.

## Coverage expectations

- Treat coverage as a **map of gaps, not a target to game.** Prioritize uncovered branches in logic-heavy and user-facing code over chasing a percentage.
- Generic default thresholds (override per project): lines/statements 80%, branches 75%. Do not add tests solely to hit a number.

## Runner specifics

The backing skill auto-detects the runner; these notes apply once detected.

- **Vitest:** `import { describe, it, expect, vi } from 'vitest'`. Mocks via `vi.fn()` / `vi.mock()`.
- **Jest:** globals (`describe`/`it`/`expect`) usually available without import. Mocks via `jest.fn()` / `jest.mock()`. For Next.js, use the project's `next/jest` transform rather than adding ts-jest/babel config.

---

## React (applies only when `REACT=yes`)

> Skip this entire section for non-React projects. When the detector reports `REACT=yes`, everything here applies **in addition to** the core above.

### Component testing priorities

- Assert on rendered output and user-observable effects, not component internals or state.
- Cover the props → rendered output contract, plus empty/loading/error states.
- **User interactions:** clicks, typing, submit — via `@testing-library/user-event`, asserting the resulting effect.
- **Accessibility of queries:** prefer role/label/text queries over `data-testid`; a `getByRole` failure often signals a real a11y gap.
- Component test files use `.test.tsx`.

### React Testing Library idioms

- Query priority: `getByRole` > `getByLabelText` / `getByPlaceholderText` > `getByText` > `getByTestId` (last resort).
- Use `findBy*` (async) for anything that appears after an effect/await; use `queryBy*` only to assert absence.
- Wrap interactions in `await user.click(...)` with `userEvent.setup()`; avoid `fireEvent` unless you need a low-level event.
- Avoid `act()` warnings by awaiting the async queries rather than manual `act` wrapping.

### Environment & matchers

- Use a `jsdom` test environment for component tests (`testEnvironment: 'jsdom'` in Jest, `environment: 'jsdom'` in Vitest).
- Use `@testing-library/jest-dom` matchers (`toBeInTheDocument`, `toBeDisabled`, `toHaveAccessibleName`) — they read clearly and fail helpfully. (Vitest projects use the same matchers via `@testing-library/jest-dom/vitest`.)

---

<!--
QUANTORI CONVENTIONS: replace the content above with Quantori's house rules,
keeping these headings so the skill can locate each section. Add a "House rules"
section here for anything Quantori-specific (fixtures, custom render wrappers,
provider setup, banned patterns).
-->
