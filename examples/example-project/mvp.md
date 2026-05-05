# MVP: Release Notes Digest

## Target user / use case

A solo developer maintaining several small products wants a weekly digest of shipped changes, incidents, and follow-up tasks without manually rereading every commit and issue.

## Product shape

A CLI reads a local Git repository, groups merged changes by week, and writes a Markdown release digest. The first version works on one repo at a time and stores no remote credentials.

## Constraints

- Runs locally from the command line.
- Reads Git history only; no hosted API integration in the MVP.
- Produces deterministic Markdown suitable for review in a pull request.
- Avoids sending source code or commit data to external services.

## Success criteria

- Generates a useful weekly digest in under one minute for a repository with at least 500 commits.
- Output includes merged changes, notable fixes, and open follow-up items.
- Maintainer can edit and publish the generated Markdown without reformatting.
