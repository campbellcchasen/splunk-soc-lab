# Splunk SOC Analyst Lab (Windows)

A hands-on home lab where I installed Splunk Enterprise on a Windows PC, ingested my own Windows Security and System event logs plus Splunk's tutorial data, generated attack-like activity with throwaway test accounts, and wrote and validated seven SOC-style detections mapped to MITRE ATT&CK.

> **Lab only.** Everything here runs on my personal computer with throwaway test accounts. No employer, customer, or personal data is included.

## Goals

- Learn the Splunk workflow: install, ingest, search, detect.
- Practice SPL (Search Processing Language) with `stats`, `eval`, `rex`, `timechart`, `where`, and `sort`.
- Write detections mapped to MITRE ATT&CK and practice triaging the results.
- Practice writing short, clear investigation notes like an analyst would for a customer.

## Environment

| Item | Value |
| --- | --- |
| Host OS | Windows 10/11 (personal PC) |
| SIEM | Splunk Enterprise (trial license) |
| Data | Windows Security and System event logs (index `winlogs`) and Splunk tutorial data (index `main`) |
| Test account | Local user `testuser`, added to Administrators for testing, then deleted |

## Repo layout

```
queries/     Copy-paste SPL files, one per topic
screenshots/ Screenshots of results
docs/        Supporting notes
scripts/     Helper scripts
```

## Detections (validated against my own generated events)

| ID | Detection | MITRE ATT&CK | Event ID | Evidence |
| --- | --- | --- | --- | --- |
| D1 | Multiple failed logons (brute force) | T1110 | 4625 | [screenshot](screenshots/05-d1-failed-logons.png) |
| D2 | Failed logons followed by a success | T1110 / T1078 | 4625 + 4624 | [screenshot](screenshots/06-d2-bruteforce-success.png) |
| D3 | New local account created | T1136.001 | 4720 | [screenshot](screenshots/07-d3-new-account.png) |
| D4 | Security audit log cleared | T1070.001 | 1102 | Query written; I did not clear my logs, so it returns no results |
| D5 | Member added to Administrators | T1098 | 4732 | [screenshot](screenshots/08-d5-admin-group-add.png) |
| D6 | New service installed | T1543.003 | 7045 (System) | [screenshot](screenshots/09-d6-service-install.png) |
| D7 | Spike in failed logons over time | T1110 | 4625 | [screenshot](screenshots/10-d7-failed-logon-spike.png) |

All Windows detections are in [queries/04-detections-windows.spl](queries/04-detections-windows.spl).

Additional web-log detections on the tutorial data are in [queries/05-detections-web.spl](queries/05-detections-web.spl): W1 web scanner (many 404s from one client, T1595) and W2 large data transfer by client (T1048).

## How I built it

1. Installed Splunk Enterprise on Windows and confirmed `splunkd` was running.
2. Loaded Splunk's tutorial data (about 110k events) into `main`. [Screenshot](screenshots/02-tutorial-data-loaded.png)
3. Created an index named `winlogs` and added the local Security and System event logs as inputs. [Screenshot](screenshots/03-winlogs-ingested.png)
4. Generated test activity from an admin terminal: created `testuser`, added it to Administrators, ran 8 failed logons followed by a successful one, and installed a test service. [Screenshot](screenshots/04-generated-events.png)
5. Wrote each detection in SPL, tested it against those events, and cleaned up the test account and service afterward.

## Example triage: D2 (failed logons then success)

- **What it means:** Several failures followed by a success on the same account can indicate a successful password-guessing attack.
- **First checks:** Source IP and logon type, whether the account is privileged, how long between the last failure and the success, and whether the source is normal for that user.
- **Next steps:** Look at what the account did after the success (new accounts, group changes, services). If suspicious, reset the password, disable the account, and escalate with the timeline.

## Lessons learned

- **Service permissions:** Splunk ran as the virtual account `NT SERVICE\Splunkd`, which cannot read the Security log. I fixed it by adding that account to the local **Event Log Readers** group and restarting the service.
- **Field extraction:** Without the Splunk Add-on for Microsoft Windows, fields like `Account_Name` were not extracted, so I used `rex` against the event text.
- **Multi-value fields:** Windows events list several `Account Name` values (the requester first, the target account second). Picking the last value returned `-` for 4624 events, so I switched to `mvindex(acct,1)`. Checking the raw event fixed it.

## What I'd do next

- Save D2 as a scheduled Splunk alert.
- Add Sysmon for richer endpoint telemetry.
- Install the Splunk Add-on for Microsoft Windows and compare normalized (CIM) field names.
- Explore Splunk's BOTS (Boss of the SOC) datasets for harder investigations.

## License

MIT. See [LICENSE](LICENSE).
