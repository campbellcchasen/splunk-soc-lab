# Investigation note template

Write one note per detection you run. Keep it short and factual, as if a customer will read it.

## Summary
One sentence: what happened.

## Evidence
- Search used (paste the SPL)
- Key results: timestamps, account, source, counts
- Screenshot reference (file name in `screenshots/`)

## Assessment
True positive, false positive, or needs review. Say why.

## Impact
What is at risk if this is real.

## Recommended action
Specific steps (reset credentials, block source, review account activity, escalate).

## Tuning notes
How to reduce noise next time (threshold, allowlist, exclusions).

---

### Example (D1 and D2, lab data)

**Summary:** Six failed network logons against `labuser` followed by one success.
**Evidence:** D1 showed 6 failures from one source in under a minute; D2 showed 1 success for the same account.
**Assessment:** True positive in the lab; I generated the events myself with `generate-failed-logons.ps1`.
**Impact:** In production, a success after repeated failures could mean the account was guessed.
**Recommended action:** Reset the password, review activity after the success, check the source for other targets.
**Tuning notes:** Exclude vulnerability scanner addresses and raise the threshold for noisy service accounts.
