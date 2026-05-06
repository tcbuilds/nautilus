# Phase 5 — Incident Response (Solo Edition)

When something breaks in production, this is the playbook. Solo edition: no Incident Commander handoffs, no separate Comms Lead. You wear all the hats. The discipline is in the artifacts you leave behind.

## Severity ladder

Defined up front, not negotiated mid-incident.

- **SEV1** — Data loss, security breach, prolonged total outage, or revenue impact above a threshold you set in advance. Drop everything.
- **SEV2** — Significant feature outage or degradation affecting a meaningful share of users. Address within hours.
- **SEV3** — Minor degradation, partial outage, or recoverable error spike. Address within the working day.

Write the threshold numbers down. "I'll know it when I see it" is not a severity ladder.

## During the incident

1. **Acknowledge** the alert or report. Stop other work.
2. **Confirm** the symptom. Reproduce if possible.
3. **Mitigate first, root-cause later.** Roll back, flip a flag, drain traffic, restart the service. Restoring users beats explaining what happened.
4. **Capture** what you did and when. A scratch file, a Slack message to yourself, a notes app — anything timestamped. Memory rewrites itself within hours.
5. **Validate** the mitigation worked. Specific check, not "looks fine."

## After the incident

Within one week, write a postmortem using `templates/postmortem-template.md`. Even for solo work. Especially for solo work — there is no team memory to rely on.

The action items go in your work tracker with owner (you) and due date. Unfulfilled items get reviewed at the start of the next postmortem.

## Runbooks

Every alert that pages you needs a runbook. Use `templates/runbook-template.md`. The runbook URL goes inside the alert payload so it is one click away when you are tired and confused.

## Blameless even when alone

The point of blameless postmortems is not feelings. It is accurate timelines. If you write postmortems that cast yourself as careless, future-you will sanitize them and you will lose the signal. Write the truth: the system was missing a check, the documentation was wrong, the alert fired too late, the deploy lacked a rollback path. Locate the cause in the system.

## Exit criteria

Service is restored. Postmortem is written. Action items are tracked. Runbook is updated based on what you learned.
