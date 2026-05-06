# Open Source Release Checklist

Use this before making the repository public.

## Repository metadata

- [ ] Set repository description: "AI-augmented SDLC playbook for shipping software with specs, standards, roadmaps, agents, and retrospectives."
- [ ] Add topics: `sdlc`, `ai-assisted-development`, `developer-workflow`, `claude-code`, `templates`, `software-engineering`.
- [ ] Confirm default branch is `main`.
- [ ] Enable issues and discussions if maintainers want public feedback.
- [ ] Verify `install.sh` succeeds against a fresh temp directory after publishing.
- [ ] Verify `install-tools.sh` succeeds against a fresh `$HOME/.claude` after publishing (skills/agents may be empty in early phases).

## Safety

- [ ] Run `rtk git diff --check`.
- [ ] Run `rtk rg -n "secret|token|password|api_key|private|/home/|~/.claude" .`.
- [ ] Review [SECURITY.md](SECURITY.md) and enable GitHub private vulnerability reporting if available.
- [ ] Confirm no private names, customer references, credentials, local paths, or screenshots are committed.

## Maintainer workflow

- [ ] Confirm [CONTRIBUTING.md](CONTRIBUTING.md) matches current review expectations.
- [ ] Confirm [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) is acceptable for public participation.
- [ ] Confirm [LICENSE](LICENSE) is the intended license.
- [ ] Open one test PR after publishing to verify the PR template and issue templates render correctly.
