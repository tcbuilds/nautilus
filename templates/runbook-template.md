# Runbook: [service or alert name]

## Symptom

What the operator sees. Alert text, customer report, observable behavior. Be specific.

## Diagnosis

Steps to confirm the symptom and isolate the cause. Each step has a command or query and the expected output.

1. ...
2. ...

## Mitigation

What to do to stop user impact, in priority order. Mitigations restore service; root-cause fixes come later.

1. ...
2. ...

## Escalation

When to escalate, who to call, what context to hand off. Phone numbers and names go in a separate private file linked from here.

## Validation

How to confirm the fix worked. Specific check, not "looks fine."

---

*Runbook URL goes in the alert payload itself. Keep this file in the same repo as the service so it versions with the code.*
