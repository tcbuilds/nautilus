# Postmortem: [incident title]

**Date:** YYYY-MM-DD
**Severity:** SEV1 | SEV2 | SEV3
**Duration:** start time to end time (UTC)
**Author:** [name]

## Summary

One paragraph. What happened, who was affected, how it was resolved.

## Impact

User impact in concrete terms. Number of users, requests failed, dollars lost, SLO budget burned.

## Contributing factors

Plural. Single root causes are usually a story we tell ourselves. List the conditions that combined to produce the failure.

## Timeline

Facts only, no narration. UTC timestamps.

- HH:MM — Event
- HH:MM — Event

## What went well

Safety-II thinking. What worked? What detection, response, or mitigation prevented this from being worse?

## What went poorly

Where was the system slower, blinder, or more brittle than it should have been?

## Where we got lucky

Conditions that made this less bad than it could have been. These are not future safety nets.

## Action items

| Owner | Action | Due date | Severity |
|---|---|---|---|
| ... | ... | YYYY-MM-DD | high/medium/low |

Tracked in the work tracker, not buried in this doc. Unfulfilled items get reviewed in the next postmortem.

---

*Blameless: assume every actor had good intentions and the best information available at the time. Locate causes in the system (process, tooling, documentation, training), not in individuals.*
