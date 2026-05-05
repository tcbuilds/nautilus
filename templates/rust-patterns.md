# Rust Patterns — Project Development Rules

Assumes Rust 1.80+ / edition 2021.

Project-specific Rust idioms and constraints. Copy into `.claude/rules/` of any new project, then trim or extend per project needs. Pairs with the cross-language `codingStandards.md` baseline.

## Non-Negotiable Rules

- No `unwrap()` or `expect()` in production paths. Tests may use `.expect("reason")` with a stated reason. Carve-out: `.expect("reason")` is allowed in static initializers (`LazyLock`) and on `Mutex::lock()` where panic-on-poison is the documented contract.
- Every error crossing a function boundary carries context via `.context()` or `.with_context()`.
- Application binaries use `anyhow::Result`; libraries define typed errors via `thiserror = "2"`.
- Regex patterns are compiled once with `std::sync::LazyLock` (Rust 1.80+). Never `Regex::new()` inside a hot path. For MSRV < 1.80, fall back to `once_cell::sync::Lazy`.
- Function signatures take borrows (`&str`, `&[T]`, `&Path`) by default. Take ownership only when ownership is required.
- Iterator chains beat hand-rolled `for` + `Vec::push` for transformation pipelines.
- `match` arms are exhaustive and explicit. Never silently swallow `Err(_) => {}`.
- Async runtime is a deliberate choice. If the project does not need async, do not pull `tokio`. If it does, use `tokio` consistently.
- Validated inputs use newtypes. Raw `String` does not cross the parsing boundary.

## Error Handling

Use `anyhow` at the application boundary, `thiserror` for library-style domain errors, and always attach context.

```rust
// ❌ Naked unwrap, no context, panic on missing env var.
fn load_port() -> u16 {
    std::env::var("PORT").unwrap().parse().unwrap()
}
```

```rust
// ✅ Typed error chain with context, recoverable failure.
use anyhow::{Context, Result};

fn load_port() -> Result<u16> {
    let raw = std::env::var("PORT").context("PORT env var missing")?;
    raw.parse::<u16>()
        .with_context(|| format!("PORT not a valid u16: {raw:?}"))
}
```

For libraries, prefer `thiserror`:

```rust
// ✅ Domain-specific error type, machine-matchable variants.
use thiserror::Error;

#[derive(Debug, Error)]
pub enum ConfigError {
    #[error("missing key: {0}")]
    Missing(&'static str),
    #[error("invalid value for {key}: {value}")]
    Invalid { key: &'static str, value: String },
}
```

## Regex Compilation

Regex compilation is expensive. Compile once at module load, reuse forever.

```rust
// ❌ Recompiles on every call.
fn extract_id(input: &str) -> Option<&str> {
    let re = regex::Regex::new(r"id=([0-9a-f]{8})").unwrap();
    re.captures(input).and_then(|c| c.get(1).map(|m| m.as_str()))
}
```

```rust
// ✅ Compiled once, shared via LazyLock (Rust 1.80+).
use std::sync::LazyLock;

use regex::Regex;

static ID_RE: LazyLock<Regex> = LazyLock::new(|| {
    Regex::new(r"id=([0-9a-f]{8})").expect("ID_RE pattern is valid")
});

fn extract_id(input: &str) -> Option<&str> {
    ID_RE.captures(input).and_then(|c| c.get(1).map(|m| m.as_str()))
}
```

For MSRV < 1.80, substitute `once_cell::sync::Lazy` (same shape).

## Borrowing And Ownership

Prefer borrows. Clone only when the callee needs to outlive the caller's reference.

```rust
// ❌ Forces caller to clone, takes &String which is strictly worse than &str.
fn looks_like_url(s: &String) -> bool {
    s.starts_with("http://") || s.starts_with("https://")
}
```

```rust
// ✅ Accepts any string-like borrow, no allocation forced on caller.
fn looks_like_url(s: &str) -> bool {
    s.starts_with("http://") || s.starts_with("https://")
}
```

## Iterators Over Manual Loops

Iterator chains express intent; manual loops hide it.

```rust
// ❌ Manual loop, intent buried.
fn first_three_even(nums: &[i64]) -> Vec<i64> {
    let mut out = Vec::new();
    for n in nums {
        if *n % 2 == 0 {
            out.push(*n);
            if out.len() == 3 {
                break;
            }
        }
    }
    out
}
```

```rust
// ✅ Declarative pipeline, lazy and bounded.
fn first_three_even(nums: &[i64]) -> Vec<i64> {
    nums.iter().copied().filter(|n| n % 2 == 0).take(3).collect()
}
```

## Async Discipline

Pull `tokio` only when async genuinely earns its weight. Once in, commit fully.

```rust
// ❌ Async wrapper around purely sync work, plus blocking sleep inside async fn.
async fn add(a: u64, b: u64) -> u64 {
    std::thread::sleep(std::time::Duration::from_millis(10));
    a + b
}
```

```rust
// ✅ Sync code stays sync. Async code uses tokio primitives end to end.
use anyhow::Context;

fn add(a: u64, b: u64) -> u64 {
    a + b
}

async fn fetch_with_timeout(client: &reqwest::Client, url: &str) -> anyhow::Result<String> {
    let resp = tokio::time::timeout(
        std::time::Duration::from_secs(5),
        client.get(url).send(),
    )
    .await
    .context("request timed out")??;
    resp.text().await.context("failed to read body")
}
```

### Async hazards

- Spawned futures must be `Send + 'static`. A non-`Send` value (e.g. `Rc`, `RefCell`, `MutexGuard` from `std::sync::Mutex`) held across `.await` will fail to compile under `tokio::spawn`.
- `std::sync::Mutex` (and `parking_lot::Mutex`) held across `.await` is a hazard — both are blocking locks that park the async executor thread on contention, stalling every other task on that worker. Use `tokio::sync::Mutex` when the guard must span an await point; keep blocking mutexes for short, sync-only critical sections.
- `select!` branches must be cancellation-safe. If a future is dropped mid-`.await`, partial state must be recoverable. Wrap non-cancel-safe work in a separate task and select on its handle.
- Prefer `tokio::task::JoinSet` over raw `tokio::spawn` when managing a dynamic group of tasks — it propagates panics, cancels on drop, and yields results in completion order.
- Use `tokio::task::spawn_blocking` for CPU-bound or blocking syscalls; never run them on the async runtime threads.
- Prefer native AFIT (async fn in trait, Rust 1.75+) for static dispatch; reach for `async-trait` only when you need `dyn Trait`.
- Never call `block_on` (or `Handle::block_on`) inside an async context — it deadlocks the runtime.

## Match Exhaustiveness

Silent `Err(_) => {}` arms hide bugs. Log, fallback, or propagate — pick one explicitly.

```rust
// ❌ Errors vanish, caller sees None and has no idea why.
fn parse_port(raw: &str) -> Option<u16> {
    match raw.parse::<u16>() {
        Ok(p) => Some(p),
        Err(_) => None,
    }
}
```

```rust
// ✅ Each arm is explicit; the error variant is named, contextualised, and propagated.
use anyhow::{Context, Result};

fn parse_port(raw: &str) -> Result<u16> {
    match raw.parse::<u16>() {
        Ok(port) => Ok(port),
        Err(e) => Err(e).with_context(|| format!("invalid port: {raw:?}")),
    }
}
```

## Newtypes For Validation

Validated values get their own type so invalid values cannot construct.

```rust
// ❌ Any String can be passed as an email anywhere in the codebase.
fn send_welcome(email: String) { /* ... */ }
```

```rust
// ✅ Email is constructable only through a validating constructor.
// Shown in application style with anyhow; library-shaped newtypes return typed
// errors (see thiserror example under "Error Handling").
#[derive(Debug, Clone)]
pub struct Email(String);

impl Email {
    pub fn parse(raw: impl Into<String>) -> anyhow::Result<Self> {
        let raw = raw.into();
        anyhow::ensure!(raw.contains('@'), "email missing '@': {raw:?}");
        Ok(Self(raw))
    }

    pub fn as_str(&self) -> &str {
        &self.0
    }
}

fn send_welcome(email: &Email) { /* ... */ }
```

## Module Structure

Canonical layout for a new Rust module file:

```rust
// 1. Imports — std, then external crates, then crate-local.
use std::sync::LazyLock;
use std::time::Duration;

use anyhow::{Context, Result};
use regex::Regex;

use crate::domain::Email;

// 2. Public types and traits.
pub struct Mailer { /* ... */ }

// 3. Lazy statics (regex, configs).
// Illustrative only — real email validation belongs in a typed newtype, not a regex.
static EMAIL_RE: LazyLock<Regex> =
    LazyLock::new(|| Regex::new(r".+@.+").expect("EMAIL_RE pattern is valid"));

// 4. Public entry points.
impl Mailer {
    pub fn send(&self, to: &Email, body: &str) -> Result<()> { /* ... */ }
}

// 5. Private helpers.
fn redact(s: &str) -> String { /* ... */ }

// 6. Tests live in the same file under cfg(test).
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn redacts_email_local_part() {
        assert_eq!(redact("alice@example.com"), "***@example.com");
    }
}
```

## Testing

- Unit tests live in `#[cfg(test)] mod tests` at the bottom of the file under test.
- Integration tests live in `tests/` at the crate root.
- Test names describe behavior: `parses_valid_input`, `rejects_negative_amount`.
- `.expect("reason")` is fine in tests; `unwrap()` is not — the reason aids debugging.
- Use `proptest` or `quickcheck` for parsers, codecs, and math-heavy logic.

```rust
#[test]
fn email_parse_rejects_missing_at_sign() {
    let err = Email::parse("not-an-email").expect_err("should fail");
    assert!(err.to_string().contains("missing '@'"));
}
```

## Anti-Patterns

| Pattern                                  | Problem                                                | Fix                                                  |
| ---------------------------------------- | ------------------------------------------------------ | ---------------------------------------------------- |
| `.unwrap()` in production code           | Panic on the user's hot path, no context              | Return `Result`, attach context, or `?` propagate    |
| `Regex::new()` inside a function         | Recompiles per call, hidden allocation                | `LazyLock<Regex>` at module scope                    |
| `&String` in fn signature                | Forces `String` allocation on caller                   | `&str`                                               |
| `for x in ... { out.push(...) }`         | Manual loop hides transformation intent               | Iterator chain `.filter().map().collect()`           |
| `async fn` with no `.await`              | Async overhead, no concurrency benefit                | Make it `fn` and remove the runtime                  |
| `Err(_) => {}`                           | Silent failure, undebuggable                          | Log + explicit fallback, or propagate                |
| Raw `String` for validated values        | Invalid values flow through the codebase              | Newtype with a validating constructor                |
| `unsafe` without invariant docs          | Memory unsafety with no audit trail                   | Document invariants, isolate, justify in review      |
| `Arc<std::sync::Mutex<T>>` held across `.await` | Blocks the async executor thread on contention; deadlock risk | Use `tokio::sync::Mutex` when the guard must cross `.await` |
| `parking_lot::Mutex` held across `.await` | Blocks the async executor thread on contention; no async support | `tokio::sync::Mutex` when guards must cross `.await`; keep `parking_lot` for sync-only critical sections |
| `block_on` inside async                  | Deadlocks the runtime                                 | Restructure as `.await`, or `spawn_blocking` for blocking work |
| Spawned future is not `Send`             | `tokio::spawn` requires `Send + 'static`              | Drop non-`Send` values before `.await`, or use `spawn_local` on a `LocalSet` |
