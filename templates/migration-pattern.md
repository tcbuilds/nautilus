# Database Migration Pattern: Expand, Migrate, Contract

The only safe pattern for schema changes against a running system that needs rollback safety. Applies to Postgres, MySQL, and any RDBMS with online migration tooling.

## The three phases

### 1. Expand

Additive only. Backward-compatible with the previous app version.

- Add nullable columns.
- Add new tables.
- Add new indexes (CONCURRENTLY where supported).
- Never drop, rename, or constrain.

The previous app version continues to work unchanged against the expanded schema.

### 2. Migrate

Backfill data. Deploy app version that writes to **both** old and new schemas (dual-write).

- Backfill in batches with explicit progress tracking.
- Application writes go to old + new for the duration.
- Reads can begin shifting to new once backfill is verified complete.

This is the longest phase. Verify data parity before contracting.

### 3. Contract

Remove the old schema. Deploy app version that reads and writes only the new schema.

- Drop old columns, tables, indexes.
- Remove dual-write code.
- This step is non-reversible — only execute after the new path has run cleanly long enough to trust.

## Why this matters

This pattern is the only way to maintain N-1 application/schema compatibility. N-1 compatibility is what makes deploy rollback actually work — if the previous app version cannot run against the current schema, you cannot roll back code without rolling back data, and that path is full of foot-guns.

## Run as a separate pipeline stage

Schema migrations belong in their own pipeline stage, not bundled with app deploys. Schema changes ship on their own cadence; app deploys ship many times against the same schema.
