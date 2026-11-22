# Screenshots

Evidence for each setup step and detection in this project. Usernames, computer
names, and any IPv6 addresses are redacted; private IPv4 addresses (`192.168.x.x`)
are shown since they only resolve inside the lab network.

Unredacted originals are kept locally in `screenshots/raw/` (not committed — see
`.gitignore`).

| # | File | Description |
|---|---|---|
| 01 | `01-splunk-home.png` | Splunk Enterprise home page after install |
| 02 | `02-tutorial-data-loaded.png` | Tutorial data ingested, confirmed by index/sourcetype counts |
| 03 | `03-winlogs-ingested.png` | Local Windows Event Log input configured and ingesting |
| 04 | `04-generated-events.png` | Generated test activity (failed logons, account/group/service changes) |
| 05 | `05-d1-failed-logons.png` | D1 — multiple failed logons detection results |
| 06 | `06-d2-bruteforce-success.png` | D2 — failed logons followed by a success |
| 07 | `07-d3-new-account.png` | D3 — new local account created |
| 08 | `08-d5-admin-group-add.png` | D5 — member added to Administrators group |
| 09 | `09-d6-service-install.png` | D6 — new service installed |
| 10 | `10-d7-failed-logon-spike.png` | D7 — failed logon spike, column chart |
| 11 | `11-forwarder-running.png` | Splunk Universal Forwarder installed and running on Mint |
| 12 | `12-linuxlogs-events.png` | First events landing in the `linuxlogs` index |
| 13 | `13-linux-network.png` | Kali and Mint network addresses and successful ping |
| 14 | `14-splunk-receiving-9997.png` | Splunk configured to receive on TCP 9997 |
| 15 | `15-ssh-attack.png` | Hydra SSH brute-force test from Kali against Mint |
| 16 | `16-l1-ssh-bruteforce.png` | L1 — SSH brute force detection results |
| 17 | `17-l2-sudo-root.png` | L3 — sudo session opened for root |
| 18 | `18-l3-new-user.png` | L4 — new local user created (`labvictim`) |
