# Splunk SOC Analyst Lab (Windows)

A hands-on home lab where I installed Splunk Enterprise on a Windows PC, ingested Windows Security event logs and Splunk's tutorial data, and built SOC-style detections, an alert, and a dashboard.

> **Lab only.** Everything here runs on my personal computer with throwaway test accounts. No employer, customer, or personal data is included.

## Goals

- Learn the Splunk workflow end to end: install, ingest, search, detect, alert, visualize.
- Practice SPL (Search Processing Language) with `stats`, `eval`, `rex`, `timechart`, `where`, and `sort`.
- Write detections mapped to MITRE ATT&CK and practice triaging the results.
- Practice writing short, clear investigation notes like an analyst would for a customer.

## Environment

| Item | Value |
| --- | --- |
| Host OS | Windows 10/11 (personal PC) |
| SIEM | Splunk Enterprise (60-day trial license) |
| Data | Windows Event Logs (Security, System, Application) and Splunk tutorial data |
| Test account | Local, non-admin user `labuser`, deleted after testing |

## Repo layout

```
docs/        Step-by-step guides (setup, data, SPL, detections, alerts)
queries/     Copy-paste SPL files, one per topic
scripts/     PowerShell helpers to create the lab user and generate test events
screenshots/ Redacted screenshots of results (see screenshots/README.md)
```

## Quick start

1. Follow [docs/01-install-splunk-windows.md](docs/01-install-splunk-windows.md).
2. Follow [docs/02-load-and-generate-data.md](docs/02-load-and-generate-data.md).
3. Work through [docs/03-spl-fundamentals.md](docs/03-spl-fundamentals.md).
4. Run the detections in [docs/04-detections.md](docs/04-detections.md).
5. Build the alert and dashboard in [docs/05-alerts-and-dashboards.md](docs/05-alerts-and-dashboards.md).

## Detections

| ID | Detection | MITRE ATT&CK | Data source | Query |
| --- | --- | --- | --- | --- |
| D1 | Multiple failed logons (brute force) | T1110 | Windows Security 4625 | [queries/04-detections-windows.spl](queries/04-detections-windows.spl) |
| D2 | Failed logons followed by a success | T1110 / T1078 | Windows Security 4625 + 4624 | same file |
| D3 | New local account created | T1136.001 | Windows Security 4720 | same file |
| D4 | Security audit log cleared | T1070.001 | Windows Security 1102 | same file |
| D5 | Web scanner (many 404s from one client) | T1595 | Tutorial web logs | [queries/05-detections-web.spl](queries/05-detections-web.spl) |
| D6 | Large data transfer by client | T1048 | Tutorial web logs | same file |
| D7 | Spike in failures over time | T1110 | Windows Security 4625 | same file |

## Skills practiced

Splunk install and administration basics, data onboarding (Windows event log inputs), SPL, alert and dashboard creation, MITRE ATT&CK mapping, alert triage, and investigation write-ups.

## Results

Screenshots of the search results, alert, and dashboard are in [`screenshots/`](screenshots/).

## What I'd do next

- Add Sysmon for richer endpoint telemetry.
- Install the Splunk Add-on for Microsoft Windows and compare normalized (CIM) field names.
- Try the same detections in Elastic (KQL) to compare query languages.
- Explore Splunk's BOTS (Boss of the SOC) datasets for harder investigations.

## License

MIT. See [LICENSE](LICENSE).
