# Splunk SOC Lab

A hands-on Splunk lab built to practice SOC Analyst I detection engineering: ingesting
Windows and Linux security logs, writing SPL detections mapped to MITRE ATT&CK, and
documenting the full workflow end to end.

> **Lab only.** All hosts, accounts, and attacks in this project are isolated virtual
> machines and test accounts created for this exercise. Nothing here targets a real
> production system.

## Goals

- Stand up a working Splunk Enterprise instance and ingest real Windows Security/System
  event logs and Linux auth logs.
- Write SPL detections for common attacker behavior (brute force, privilege escalation,
  persistence, log tampering) and map each one to MITRE ATT&CK.
- Practice the SOC analyst workflow: generate activity, search for it, build a detection,
  validate it, and document the result.
- Build a portfolio piece that demonstrates practical Splunk and detection engineering
  skills for a SOC Analyst I interview.

## Environment

| Component | Details |
|---|---|
| SIEM | Splunk Enterprise (free trial), Windows 10/11 host |
| Windows source | Local Windows Security and System event logs |
| Linux source | Linux Mint VM (VirtualBox), `/var/log/auth.log` via Splunk Universal Forwarder |
| Attacker | Kali Linux VM (VirtualBox), used to generate SSH brute-force traffic |
| Networking | Kali and Mint on a Bridged Adapter, sharing the host's home network |
| Indexes | `winlogs` (Windows events), `linuxlogs` (Linux auth events) |

## Repo layout

- `queries/` — SPL detections, in the order they were built
- `configs/` — Splunk Universal Forwarder config files (`inputs.conf`, `outputs.conf`)
- `docs/` — setup documentation (Linux forwarder integration)
- `screenshots/` — redacted evidence for each detection and setup step
- `scripts/` — supporting scripts
- `LICENSE`

## Detections

| ID | Detection | MITRE ATT&CK | Source |
|---|---|---|---|
| D1 | Multiple failed logons | T1110 Brute Force | Windows |
| D2 | Failed logons followed by a success | T1110 / T1078 Valid Accounts | Windows |
| D3 | New local account created | T1136.001 Local Account | Windows |
| D4 | Security audit log cleared | T1070.001 Clear Windows Event Logs | Windows |
| D5 | Member added to Administrators group | T1098 Account Manipulation | Windows |
| D6 | New service installed | T1543.003 Windows Service | Windows |
| D7 | Spike in failed logons over time | T1110 Brute Force | Windows |
| W1 | Web scanner activity | T1595 Active Scanning | Web |
| W2 | Large data transfer | T1048 Exfiltration Over Alternative Protocol | Web |
| L1 | SSH brute force | T1110 Brute Force | Linux |
| L2 | SSH failures followed by a success | T1110 / T1078 Valid Accounts | Linux |
| L3 | Sudo session opened for root | T1548.003 Sudo and Sudo Caching | Linux |
| L4 | New local user created | T1136.001 Local Account | Linux |

Screenshots for each detection are in `screenshots/` (see `screenshots/README.md` for the
full list).

## How I built it

1. Installed Splunk Enterprise on Windows and ingested the built-in tutorial data plus
   local Windows Security/System event logs into the `winlogs` index.
2. Added the Splunk service account (`NT SERVICE\Splunkd`) to the local **Event Log
   Readers** group so it could read the Security log.
3. Generated test activity on the Windows host: failed logons, a new local account, a
   security log clear, a group membership change, and a new service install.
4. Wrote and validated SPL detections (D1–D7) for each of those behaviors, using `rex`
   to extract fields since the Splunk Windows TA wasn't installed.
5. Connected a Linux Mint VM and a Kali Linux VM in VirtualBox, installed the Splunk
   Universal Forwarder on Mint, and forwarded `/var/log/auth.log` into a new `linuxlogs`
   index. Full steps are in `docs/linux-forwarder-setup.md`.
6. Ran an SSH brute-force test from Kali against Mint with Hydra, then wrote and
   validated Linux detections (L1–L4).

## Example: D2 triage walkthrough

The D2 query (`index=winlogs source="WinEventLog:Security" (EventCode=4625 OR
EventCode=4624)`) looks for an account with several failed logons followed by a
successful one — a pattern consistent with a brute-force attempt that eventually
succeeded. Triage steps:

1. Confirm the target account and source host from the `target_user` field.
2. Check whether the account's owner actually logged on around that time (ask the user,
   or cross-reference with expected work hours/location).
3. If unconfirmed, treat it as a potential account compromise: reset the password,
   review the account's recent activity, and check for any new account or group changes
   that might indicate follow-on persistence.

## Lessons learned

- **Service account permissions.** Splunk couldn't read the Windows Security log until
  `NT SERVICE\Splunkd` was added to the local Event Log Readers group.
- **Field extraction without the Windows TA.** Without the Splunk Windows add-on,
  fields like `Account_Name` weren't automatically extracted, so `rex` was used against
  the raw event text instead.
- **The `mvindex` fix.** In 4624/4625 events, the multivalue `Account Name` field lists
  the subject account first and the target account second — using `mvindex(acct,1)`
  fixed a detection that was silently matching the wrong account.
- **Cron vs. sudo.** On Linux, cron jobs running as root also log a "session opened for
  user root" event through `pam_unix`, so the sudo-to-root detection filters out
  `sudo_user=root` to avoid flagging scheduled tasks as privilege escalation.
- **Service accounts vs. real users.** Installing SSH and the Splunk forwarder creates
  local service accounts (`sshd`, `splunkfwd`) that also show up as "new user" events,
  so the new-account detection filters those out.
- **VirtualBox networking.** A VirtualBox NAT Network lets VMs reach each other but not
  the host machine. Since Splunk runs on the host, a Bridged Adapter was used instead so
  the Mint VM could reach the host's Splunk instance directly.

## What I'd do next

- Save the D2 (and L2) detection as a real-time alert instead of a saved search.
- Add Sysmon on the Windows host for richer process-level telemetry.
- Install the official Splunk Add-on for Windows to get proper field extractions instead
  of relying on `rex`.
- Work through the Boss of the SOC (BOTS) dataset for broader detection practice.
- Add a second Linux detection source (e.g., Apache/nginx access logs) for a web-facing
  attack scenario.

## License

See `LICENSE`.
