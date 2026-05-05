# Python Patterns — Project Development Rules

Project-specific Python idioms and constraints. Copy into `.claude/rules/` of any new project, then trim or extend per project needs. Pairs with the cross-language `codingStandards.md` baseline.

## Non-Negotiable Rules

- Type hints are required on every function signature and class attribute. `mypy --strict` is the aspiration.
- Use `from __future__ import annotations` on Python 3.9–3.11 codebases; native union syntax (`int | None`) on 3.12+.
- No bare `except:` and no `except Exception:` without logging context and either re-raising or converting.
- No mutable default arguments. Default to `None` and initialize inside the function body.
- Async code never calls blocking primitives (`time.sleep`, `requests.get`, sync DB drivers). Use `asyncio.sleep`, `httpx`, async drivers.
- Library code uses `logging.getLogger(__name__)`. `print()` is for scripts and CLIs only.
- External boundaries (HTTP in/out, config, queue payloads) validate with `pydantic`. Internal data shapes are `@dataclass` or typed.
- Imports are grouped: stdlib, third-party, local. No wildcard imports.

## Error Handling

Catch what you can act on. Preserve the cause. Convert at boundaries.

```python
# ❌ Bare except, swallows KeyboardInterrupt, hides the real failure.
def load_user(user_id: str):
    try:
        return db.get(user_id)
    except:
        return None
```

```python
# ✅ Specific exception, logged, converted to a domain error with cause preserved.
import logging

logger = logging.getLogger(__name__)


class UserNotFound(Exception):
    """Raised when a user lookup returns no row."""


def load_user(user_id: str) -> User:
    try:
        return db.get(user_id)
    except db.RowNotFound as e:
        logger.warning("user lookup miss", extra={"user_id": user_id})
        raise UserNotFound(user_id) from e
```

Custom exception classes belong to the domain that raises them. Re-raise with `raise NewError(...) from original` so the traceback chain is intact.

## Async Discipline

`asyncio` end to end. Never mix sync blocking calls into an async path.

```python
# ❌ time.sleep blocks the entire event loop.
async def poll_until_ready(client) -> None:
    while not await client.ready():
        time.sleep(1)
```

```python
# ✅ asyncio.sleep yields control. asyncio.gather parallelizes independent work.
import asyncio


async def poll_until_ready(client) -> None:
    while not await client.ready():
        await asyncio.sleep(1)


async def warm_caches(client) -> None:
    await asyncio.gather(
        client.warm("users"),
        client.warm("orders"),
        client.warm("inventory"),
    )
```

Fire-and-forget tasks need explicit references and cancellation handling:

```python
# ✅ Track the task so it can be cancelled on shutdown; surface exceptions.
async def run_service(client) -> None:
    background = asyncio.create_task(heartbeat(client), name="heartbeat")
    try:
        await client.serve()
    finally:
        background.cancel()
        with contextlib.suppress(asyncio.CancelledError):
            await background
```

## Data Classes vs Pydantic

Internal: `@dataclass`. External boundary: `pydantic.BaseModel`. No floating `dict[str, Any]` in business logic.

```python
# ❌ dict floating through the codebase, no validation, no field discoverability.
def credit_account(payload: dict) -> None:
    db.update(payload["account_id"], payload["amount"])
```

```python
# ✅ Pydantic validates the wire shape; dataclass carries the validated value internally.
from dataclasses import dataclass
from decimal import Decimal

from pydantic import BaseModel, Field


class CreditRequest(BaseModel):
    account_id: str = Field(min_length=1)
    amount: Decimal = Field(gt=0)


@dataclass(frozen=True, slots=True)
class Credit:
    account_id: str
    amount: Decimal


def credit_account(req: CreditRequest) -> None:
    credit = Credit(account_id=req.account_id, amount=req.amount)
    db.update(credit.account_id, credit.amount)
```

## Logging

Module-level logger. Structured fields via `extra=`. Never `print()` in importable code.

```python
# ❌ Print loses log level, has no structured fields, cannot be silenced.
def send_email(to: str) -> None:
    print(f"sending email to {to}")
```

```python
# ✅ Structured logger, configurable level, machine-parseable fields.
import logging

logger = logging.getLogger(__name__)


def send_email(to: str) -> None:
    logger.info("send_email start", extra={"to": to})
```

## Imports

Three groups, separated by a blank line. No wildcard imports. Absolute imports inside packages.

```python
# ✅ stdlib → third-party → local.
from __future__ import annotations

import json
import logging
from pathlib import Path

import httpx
from pydantic import BaseModel

from myapp.config import Settings
from myapp.domain import User
```

## Mutable Default Arguments

The default object is created once at function-definition time and shared across calls.

```python
# ❌ The list persists across calls; unrelated callers mutate each other's state.
def append_tag(tag: str, tags: list[str] = []) -> list[str]:
    tags.append(tag)
    return tags
```

```python
# ✅ None sentinel, build a fresh list inside the function.
def append_tag(tag: str, tags: list[str] | None = None) -> list[str]:
    tags = list(tags) if tags is not None else []
    tags.append(tag)
    return tags
```

## Module Structure

Canonical layout for a new Python module:

```python
"""Short docstring describing what this module is for and who imports it."""

from __future__ import annotations

# stdlib
import logging
from dataclasses import dataclass

# third-party
import httpx
from pydantic import BaseModel

# local
from myapp.config import Settings

# Module-level logger.
logger = logging.getLogger(__name__)

# Constants — uppercase, units in the name when applicable.
DEFAULT_TIMEOUT_SECONDS = 5.0


# Types and dataclasses.
@dataclass(frozen=True, slots=True)
class Page:
    url: str
    body: str


# Public functions and classes.
async def fetch(url: str, *, timeout: float = DEFAULT_TIMEOUT_SECONDS) -> Page:
    async with httpx.AsyncClient(timeout=timeout) as client:
        resp = await client.get(url)
        resp.raise_for_status()
        return Page(url=url, body=resp.text)


# Script entry point — only when this module is meant to be run directly.
if __name__ == "__main__":
    import asyncio

    page = asyncio.run(fetch("https://example.com"))
    logger.info("fetched", extra={"url": page.url, "bytes": len(page.body)})
```

## Testing

- `pytest` with fixtures over `setUp` / `tearDown`.
- `@pytest.mark.parametrize` over hand-rolled loops.
- Test names describe behavior: `test_fetch_raises_on_404`, `test_credit_rejects_negative_amount`.
- Default invocation: `pytest -x --tb=short`.
- Use `pytest.raises(SpecificError)` — never `except Exception` in test bodies.

```python
import pytest

from myapp.billing import credit_account, CreditRequest


@pytest.mark.parametrize(
    "amount",
    ["0", "-1", "-0.01"],
)
def test_credit_rejects_non_positive_amount(amount: str) -> None:
    with pytest.raises(ValueError):
        CreditRequest(account_id="a1", amount=amount)
```

## Anti-Patterns

| Pattern                          | Problem                                              | Fix                                                |
| -------------------------------- | ---------------------------------------------------- | -------------------------------------------------- |
| `except:` or bare `except Exception:` | Swallows `KeyboardInterrupt`, hides bugs       | Catch specific types, log, re-raise with `from e`  |
| `def f(xs=[])`                   | Default list is shared across all calls              | `xs: list \| None = None`, create inside           |
| `print()` in library code        | No level, no structured fields, cannot be silenced   | `logger = logging.getLogger(__name__)`             |
| `dict[str, Any]` in business logic | No validation, no field discoverability            | `pydantic.BaseModel` at the boundary, `@dataclass` inside |
| `time.sleep` in `async def`      | Blocks the entire event loop                         | `await asyncio.sleep(...)`                         |
| `requests.get` in async code     | Sync HTTP blocks the loop                            | `httpx.AsyncClient` with explicit timeout          |
| Wildcard imports                 | Pollutes namespace, breaks `mypy` and refactor tools | Explicit named imports                             |
| Untyped function signatures      | `mypy` cannot verify, IDE cannot help                | Annotate every parameter and return type           |
