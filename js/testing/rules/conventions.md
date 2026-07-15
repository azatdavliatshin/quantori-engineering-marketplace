# JS/TS Testing Conventions (swappable)

> **This file is the swappable seam.** It holds project- and org-specific conventions. The commands and the backing skill read it instead of hard-coding rules, so you can drop in Quantori's conventions (or another project's) without editing any command or skill. Everything below is **generic best-practice** — replace or extend it as needed.
>
> To swap: keep the same headings so the skill can find each section; change the content under them.

## Language & types

- Output TypeScript: `.ts` for logic, `.tsx` for anything with JSX. Never author tests in plain JS for a TS project.
- No `any`. Prefer precise types; use `unknown` + narrowing when a type is truly open. Type test helpers and mock factories too.
- Import types with `import type { ... }` where the value isn't used at runtime.

## Test file location & naming

- **Colocate** tests next to the unit under test: `Button.tsx` → `Button.test.tsx` in the same folder. (If a project clearly uses a `__tests__/` folder or a `.spec.` suffix, match the project's existing pattern instead — detect, don't impose.)
- One test file per source module. Name the top-level `describe` after the component/function under test.

## What to test (priority order)

1. **Behavior, not implementation.** Assert on what the user/consumer observes (rendered output, return values, called callbacks), not on internal state or private methods.
2. **The contract:** props/inputs → rendered output/return value. Cover the documented prop combinations.
3. **Branches & edge cases:** empty/loading/error states, boundary values, falsy inputs, the "nothing to show" path.
4. **User interactions:** clicks, typing, submit — via `@testing-library/user-event`, asserting the resulting effect.
5. **Accessibility of queries:** prefer role/label/text queries over `data-testid`; a `getByRole` failure often signals a real a11y gap.

Do **not** write tests that merely restate the implementation, snapshot enormous trees, or assert on class names / DOM structure that isn't part of the contract.

## React Testing Library idioms

- Query priority: `getByRole` > `getByLabelText` / `getByPlaceholderText` > `getByText` > `getByTestId` (last resort).
- Use `findBy*` (async) for anything that appears after an effect/await; use `queryBy*` only to assert absence.
- Wrap interactions in `await user.click(...)` with `userEvent.setup()`; avoid `fireEvent` unless you need a low-level event.
- Avoid `act()` warnings by awaiting the async queries rather than manual `act` wrapping.

## Mocking

- Mock at the module boundary (network, timers, external SDKs), not the unit under test.
- Prefer dependency injection / MSW for network over hand-rolled `fetch` mocks where the project already uses them.
- Reset mocks between tests (`beforeEach` / `clearMocks`), and restore real timers you faked.
- Keep mocks minimal and typed — a mock that drifts from the real signature is worse than none.

## Assertions & structure

- Use `@testing-library/jest-dom` matchers (`toBeInTheDocument`, `toBeDisabled`, `toHaveAccessibleName`) — they read clearly and fail helpfully. (Vitest projects use the same matchers via `@testing-library/jest-dom/vitest`.)
- Arrange–Act–Assert per test; one behavior per `it`. A descriptive `it('disables submit while pending')` beats a comment.
- No conditional logic or loops that hide which case failed, unless it's a deliberate `it.each` table.

## Coverage expectations

- Treat coverage as a **map of gaps, not a target to game.** Prioritize uncovered branches in logic-heavy and user-facing code over chasing a percentage.
- Generic default thresholds (override per project): lines/statements 80%, branches 75%. Do not add tests solely to hit a number.

## Runner specifics

The backing skill auto-detects the runner; these notes apply once detected.

- **Vitest:** `import { describe, it, expect, vi } from 'vitest'`. Mocks via `vi.fn()` / `vi.mock()`. jsdom environment. jest-dom via `@testing-library/jest-dom/vitest` in setup.
- **Jest:** globals (`describe`/`it`/`expect`) usually available without import. Mocks via `jest.fn()` / `jest.mock()`. `testEnvironment: 'jsdom'`. For Next.js, use the project's `next/jest` transform rather than adding ts-jest/babel config.

---

<!--
QUANTORI CONVENTIONS: replace the content above with Quantori's house rules,
keeping these headings so the skill can locate each section. Add a "House rules"
section here for anything Quantori-specific (fixtures, custom render wrappers,
provider setup, banned patterns).
-->
