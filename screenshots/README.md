# Screenshots

Add clean, redacted screenshots here after each part of the lab. Suggested set:

| File name | Shows |
| --- | --- |
| `01-splunk-home.png` | Splunk Home after install |
| `02-data-summary.png` | `stats count by host, sourcetype` result |
| `03-failed-logons-d1.png` | D1 brute force results |
| `04-fail-then-success-d2.png` | D2 results |
| `05-new-account-d3.png` | D3 results |
| `06-alert-config.png` | The saved alert settings |
| `07-dashboard.png` | The SOC Overview dashboard |

## Redact before you commit

Public screenshots can leak personal details. Before saving, blur or crop:

- Your computer name, Windows username, and real account names
- IP addresses and email addresses
- Anything from an employer or customer (none should be in this lab)

Put unredacted originals in `screenshots/raw/`. That folder is in `.gitignore` and will not be uploaded.
