---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.cts"
  - "**/*.mts"
  - "tsconfig*.json"
  - "package.json"
---

# TypeScript Patterns — Project Development Rules

Project-specific TypeScript idioms and constraints. Copy into `.claude/rules/` of any new project, then trim or extend per project needs. Pairs with the cross-language `../codingStandards.md` baseline.

## Non-Negotiable Rules

- TypeScript 4.5+ is required (this template uses `import { type Foo }` syntax and modern inference).
- `tsconfig.json` enables `"strict": true`, `"noUncheckedIndexedAccess": true`, and `"exactOptionalPropertyTypes": true`.
- `tsconfig.json` sets `"target": "es2022"` (or includes `"lib": ["es2022.error"]`) so `Error.cause` is available.
- `any` is forbidden. Use `unknown` at boundaries and narrow before use. ESLint `@typescript-eslint/no-explicit-any` is set to `error`.
- Floating promises are forbidden. ESLint `@typescript-eslint/no-floating-promises` is set to `error`. Every async call is awaited or handled explicitly.
- Errors extend `Error` and set `name`. Never throw strings, numbers, or plain objects.
- Discriminated unions model state. Nullable flag fields like `data?: T; error?: E` are forbidden in domain types.
- Named exports only for libraries and shared modules. Default exports are limited to framework-required entry points (Next.js pages, etc).
- No `enum`. Use `as const` objects with `keyof typeof` derived unions.
- The project picks one of `null` or `undefined` for "missing" and stays consistent. Default: `undefined` everywhere; `null` only when JSON inbound forces it.

## Error Handling

Custom error classes carry the failure mode in the type system. Result types model expected failures; thrown errors signal bugs.

```ts
// ❌ Throws a string, no type, no stack location, cannot be matched.
function loadConfig(raw: string) {
  if (!raw) throw "config missing";
  return JSON.parse(raw);
}
```

```ts
// ✅ Typed error, named for filtering, preserves cause.
export class ConfigError extends Error {
  constructor(message: string, options?: { cause?: unknown }) {
    super(message, options);
    this.name = "ConfigError";
  }
}

export function loadConfig(raw: string): Config {
  if (!raw) throw new ConfigError("config missing");
  try {
    return JSON.parse(raw) as Config;
  } catch (e) {
    throw new ConfigError("config is not valid JSON", { cause: e });
  }
}
```

For expected failures, return a Result discriminated union instead of throwing:

```ts
// No default for `E`: callers must spell out the typed failure mode.
export type Result<T, E> =
  | { ok: true; value: T }
  | { ok: false; error: E };

export function parsePort(
  raw: string,
  opts?: { log?: (event: { raw: string }) => void },
): Result<number, ConfigError> {
  const n = Number(raw);
  if (!Number.isInteger(n) || n < 1 || n > 65535) {
    opts?.log?.({ raw });
    return { ok: false, error: new ConfigError(`invalid port: ${raw}`) };
  }
  return { ok: true, value: n };
}
```

## Discriminated Unions Over Flag Fields

Model the actual states, not a soup of nullable fields.

```ts
// ❌ Three nullable fields produce 8 representable states; only 3 are valid.
interface Fetch<T> {
  loading?: boolean;
  data?: T;
  error?: Error;
}
```

```ts
// ✅ Discriminator makes invalid states unrepresentable.
type Fetch<T> =
  | { status: "idle" }
  | { status: "loading" }
  | { status: "success"; data: T }
  | { status: "error"; error: Error };

function render<T>(state: Fetch<T>): string {
  switch (state.status) {
    case "idle":
      return "Press load.";
    case "loading":
      return "Loading...";
    case "success":
      return `Got ${JSON.stringify(state.data)}`;
    case "error":
      return `Failed: ${state.error.message}`;
    default: {
      const _exhaustive: never = state;
      throw new Error(`unhandled state: ${JSON.stringify(_exhaustive)}`);
    }
  }
}
```

## Type vs Interface

Both have their place. Pick by intent.

```ts
// ✅ `type` for unions, intersections, and computed/mapped types.
type Status = "idle" | "loading" | "success" | "error";
type Optional<T> = T | undefined;
type ReadonlyDeep<T> = { readonly [K in keyof T]: ReadonlyDeep<T[K]> };

// ✅ `interface` for object contracts that may be extended or implemented.
interface UserRepo {
  findById(id: string): Promise<User | undefined>;
  save(user: User): Promise<void>;
}

interface CachingUserRepo extends UserRepo {
  invalidate(id: string): void;
}
```

## Async Patterns

Always await. Never let a promise float. Use `Promise.allSettled` when partial failure is acceptable.

Snippets in this section assume `logger` is imported as shown in §Module Structure (`import { logger } from "@/lib/logger";`).

```ts
// ❌ Floating promise: error path is invisible, ordering is undefined.
function refresh(client: Client) {
  client.warmCache();
  return client.fetchLatest();
}
```

```ts
// ✅ Awaited in parallel, partial failure is explicit.
async function refresh(client: Client): Promise<Latest> {
  const [warm, latest] = await Promise.allSettled([
    client.warmCache(),
    client.fetchLatest(),
  ]);
  if (warm.status === "rejected") {
    logger.warn("cache warm failed", { error: warm.reason });
  }
  if (latest.status === "rejected") {
    throw latest.reason;
  }
  return latest.value;
}
```

If a promise truly does not need awaiting, mark the intent with `void`:

```ts
// ✅ Explicit fire-and-forget with logged failure tail.
void heartbeat(client).catch((e) => logger.error("heartbeat crashed", { error: e }));
```

## No `any` — Use `unknown` And Narrow

The example below is **Node-only** because it references `Buffer`. For browser or edge runtimes, narrow on `ArrayBuffer`/`Uint8Array` instead.

```ts
// ❌ `any` disables every type check downstream.
function readBody(raw: any): string {
  return raw.toString();
}
```

```ts
// Node-only: requires the Node `Buffer` global.
import { Buffer } from "node:buffer";

// ✅ `unknown` forces a narrow before use.
function readBody(raw: unknown): string {
  if (typeof raw === "string") return raw;
  if (raw instanceof Buffer) return raw.toString("utf8");
  throw new TypeError(`unsupported body type: ${typeof raw}`);
}
```

## No Enums — `as const` Objects Instead

TypeScript `enum` has surprising runtime semantics (numeric vs string, reverse mappings, breaks tree-shaking). Use `as const` objects.

The `Status` union earlier in §Type vs Interface and the `LoadStatus` const-object below are independent illustrations — they intentionally share no members.

```ts
// ❌ Numeric enum: reverse mappings, awkward serialization.
enum LoadStatus {
  Idle,
  Loading,
  Done,
}
```

```ts
// ✅ Plain object + derived union. Tree-shakes cleanly, serializes as a string.
export const LoadStatus = {
  Idle: "idle",
  Loading: "loading",
  Done: "done",
} as const;

export type LoadStatus = (typeof LoadStatus)[keyof typeof LoadStatus];
```

## Named Exports Over Default Exports

Default exports are renamed silently by every importer, harming refactor tooling. Reserve them for framework conventions.

```ts
// ❌ Every importer can rename this; refactor across the codebase becomes manual.
export default function parsePortLegacy(raw: string): number { /* ... */ }
```

```ts
// ✅ Single canonical name across the codebase.
export function parsePortLegacy(raw: string): number { /* ... */ }
```

The canonical `parsePort` signature lives in §Error Handling; this section uses `parsePortLegacy` purely to illustrate the export-shape choice.

Avoid mass `index.ts` barrel re-exports inside an app — they confuse module resolution and slow tooling. Reserve barrels for genuine package boundaries.

## Module Structure

Canonical layout for a new TypeScript module:

```ts
// 1. Imports — external first, then internal absolute, then relative.
import { z } from "zod";

import { logger } from "@/lib/logger";

import { parsePort } from "./parse-port";

// 2. Schemas / validators (declared before types so types can be inferred from them).
const DEFAULT_HOST = "127.0.0.1";

const ServerSchema = z.object({
  host: z.string().min(1).default(DEFAULT_HOST),
  port: z.number().int().min(1).max(65535),
});

// 3. Types — inferred from the schema. Zod-inferred types are mutable; if you
// want `readonly` fields, re-declare the type by hand or wrap in `Readonly<...>`.
export type Server = z.infer<typeof ServerSchema>;

// 4. Functions and classes (named exports).
export function buildServer(raw: unknown): Server {
  const parsed = ServerSchema.parse(raw);
  logger.info("server configured", { host: parsed.host, port: parsed.port });
  return parsed;
}

// 5. Default export only when the framework requires one (Next.js page, etc.).
```

## Testing

`vitest` or `jest`, depending on stack. Behavior assertions over snapshots. Snapshots are reserved for stable serialized output (formatter output, generated SQL, etc.).

```ts
import { describe, it, expect, vi } from "vitest";

import { ConfigError, parsePort } from "./parse-port";

describe("parsePort", () => {
  it("returns ok for valid integer in range", () => {
    const result = parsePort("8080");
    expect(result).toEqual({ ok: true, value: 8080 });
  });

  it("returns error for out-of-range value", () => {
    const result = parsePort("99999");
    if (result.ok) {
      throw new Error("expected parsePort to fail for 99999");
    } else {
      expect(result.error).toBeInstanceOf(ConfigError);
    }
  });

  it("calls the logger on invalid input", () => {
    const log = vi.fn();
    parsePort("oops", { log });
    expect(log).toHaveBeenCalledWith(expect.objectContaining({ raw: "oops" }));
  });
});
```

## Anti-Patterns

| Pattern                                | Problem                                                | Fix                                                       |
| -------------------------------------- | ------------------------------------------------------ | --------------------------------------------------------- |
| `any`                                  | Disables type checks downstream                        | `unknown` + narrowing, or a precise type                  |
| Floating promise                       | Error invisible, undefined ordering, race conditions   | `await`, or `void` with `.catch` and explicit log         |
| Default export in shared library code  | Importers rename freely, breaks refactor tools         | Named export                                              |
| `enum`                                 | Surprising runtime semantics, breaks tree-shaking      | `as const` object + `keyof typeof` union                  |
| `throw "string"`                       | No stack, no type, cannot be filtered                  | `class FooError extends Error` with `name` set            |
| `// @ts-ignore` without justification  | Hides a real type error indefinitely                   | `// @ts-expect-error: <reason and ticket>` with context   |
| Nullable flag soup (`data?; error?;`)  | Invalid states are representable                       | Discriminated union on a `status` field                   |
| Mass `index.ts` barrel re-exports      | Slow tooling, confusing module resolution inside apps  | Direct imports, reserve barrels for package boundaries    |

When a type-system escape hatch is genuinely required, use `@ts-expect-error` with a written reason and a tracking ticket. The directive errors if the underlying type problem is fixed, so it forces cleanup once the upstream type lands.

```ts
// @ts-expect-error: upstream types lag the runtime API; tracked in PROJ-1234
const handle = legacyClient.connect({ tlsVersion: "1.3" });
```
