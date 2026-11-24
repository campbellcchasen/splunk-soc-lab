# 07 - Analyst runbook (SOC Analyst I workflow)

This is how I work an alert from the queue to a decision, using the alerts in `06-scheduled-alerts.md`. It is the routine I practice on lab data so I can explain each step in an interview or follow it on a real shift.

## A typical shift

| When | Task | Where in the lab |
|---|---|---|
| Start | Read the previous shift's handoff notes | `docs/shift-handoff-template.md` |
| Start | Check that data is flowing (no gaps in `winlogs` and `linuxlogs`) | `index=winlogs OR index=linuxlogs \| timechart span=15m count by index` |
| Through the shift | Work the alert queue, highest severity first | **Activity > Triggered Alerts** |
| Per alert | Triage, investigate, enrich, decide | The steps below |
| Per alert | Write the note and hand off or close | `docs/investigation-template.md` |
| Ongoing | Tune noisy alerts and record why | The tuning section of each note |
| End | Write the handoff for the next shift | `docs/shift-handoff-template.md` |

## Working one alert

1. **Read the alert.** Note the name, severity, time, and what fired it. Open it with **View results** from Triggered Alerts, or **Open in search** on the alert.
2. **Understand the detection.** The alert description names the MITRE technique and the first triage step. Know what behavior it is built to catch and what it can miss.
3. **Scope it.** Widen the time range around the alert. Who is the account or source? What else did they do before and after? Pivot on the user, the host, and the source address.
4. **Enrich the indicators.** Check public IPs on a reputation source such as AbuseIPDB or VirusTotal. Private and loopback addresses cannot be looked up, so ask whether the source is a known internal system. For a file or service path, check the name, location and signer.
5. **Decide.** Choose one:
   - **False positive:** a known, expected cause (for example an admin change during a change window). Write down why, and note how to tune the alert.
   - **True positive, benign:** real activity that is allowed (for example my own test). Close it with the evidence.
   - **True positive, malicious or unknown:** treat it as an incident and escalate.
6. **Document.** Fill in the investigation template: summary, evidence, assessment, impact, recommended action and tuning notes.
7. **Hand off.** Escalate with the evidence attached, or close the alert with the reason.

## Triage guide by alert

| Alert | Key questions | Typical true-positive signs | Typical false-positive causes |
|---|---|---|---|
| D1 / L1 brute force | How many failures, how many accounts, from where? | Many accounts from one source, external address | Mistyped passwords, vulnerability scanner, service account with an old password |
| D2 / L2 failures then success | Did the success come after the failures, and who is the user? | Success right after a burst of failures, unusual hour or source | User who forgot a password and then remembered it |
| D3 / L4 new account | Who created it and was there a ticket? | Created outside business hours by an unexpected user | Onboarding or software installs (service accounts) |
| D4 log cleared | Who cleared it and why? | Cleared with no maintenance window, followed by other changes | Planned log maintenance by an admin |
| D5 admin group change | Who was added and who made the change? | Unknown member or unexpected actor | Approved admin onboarding |
| D6 new service | What is the path and who installed it? | Odd name, runs from a temp or user folder | Software installers and updates |
| L3 sudo to root | Which user and what did they run? | Unexpected user, followed by account or SSH changes | Admin doing routine work |

## Escalation criteria

Escalate when any of these is true:
- A credential attack is followed by a successful logon (D2 / L2).
- A security log is cleared with no known reason (D4).
- An unexpected account is created and then added to a privileged group (D3 followed by D5).
- A new service or account is tied to an address or host I cannot explain.
- I cannot rule out compromise after enrichment.

When escalating, include the alert name, time window, affected account and host, the SPL used, what I checked, and what I recommend.

## Tracking cases with GitHub Issues

A real SOC uses a ticketing system. For the lab I use GitHub Issues in a private repo as a stand-in: one issue per case, with the investigation note as the body, labels for severity and status, and a closing comment that gives the decision and the reason. This practices the habit of every alert ending in a documented decision.

## What this lab does not cover

- EDR consoles and endpoint isolation
- Real alert volume and shift work
- Email and phishing analysis in a mail security tool
- On-call and formal escalation paths

I cover these topics separately by reading and by practicing with sample data.
