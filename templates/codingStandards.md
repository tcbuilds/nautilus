# codingStandards.md

Portable coding standards. Drop this into any project root and reference it from the project's `CLAUDE.md`. These rules apply to all code written under the orchestrator/agent workflow.

## Comments

- Never use inline comments.
- Always place comments above the code they describe.

## Data handling

- **Never use mock data.**
- **Never default to testnet.**
- **Only fix with appropriate real data.**
- Never use placeholders for live code paths.
- Always complete real implementations. If a real implementation isn't possible right now, surface that explicitly — don't paper over it with a stub.

## File management

- When debugging or troubleshooting a script, edit that script directly.
- Do not create parallel copies or new files with changes unless explicitly told to do so.
- Edit the file already in scope.

## Git workflow

- Commit and push all completed, verified, working changes.
- Never leave verified working changes uncommitted.
- Verify changes work before committing — run tests, exercise the code path, confirm it does what it should.
- Use descriptive commit messages that explain *why* the change was made, not just *what* changed.
- Command pattern: `git add` → verify → `git commit -m "..."` → `git push`.
- **Never add `Co-Authored-By` lines for Claude, AI, or any AI assistant.** Hard rule.

## Process management (systemd services)

- Use `systemctl` to manage services. Never kill processes directly.
- Correct: `sudo systemctl restart <service>`, `sudo systemctl stop <service>`, `sudo systemctl start <service>`.
- Incorrect: `pkill -f python`, `kill <pid>`, `killall python3`.
- Direct kill commands bypass systemd, leave orphans, and break service state. systemctl ensures clean shutdown and proper restart.

## Log analysis

- Never follow logs in real time.
- Always examine snapshots from a specific past timeframe.
- Redirect `journalctl` output to a temporary file and search through the snapshot.
- Use `journalctl -u <unit> --since "..." --until "..."` for time-bounded queries.

## Workflow optimization

- After receiving tool results, reflect on their quality before proceeding. Plan the next step based on what the results actually showed.
- For maximum efficiency, invoke independent tools in parallel rather than sequentially.
- If temporary files, scripts, or helpers are created during iteration, remove them at the end of the task.
