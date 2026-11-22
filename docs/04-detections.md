# 04 - SOC-style detections

**Time:** about 45 minutes. For each detection: run it, decide whether the result is real, say what you would do next, and say how you would tune it. All queries are also in `queries/`.

> **Data sources.** Windows detections (D1-D7) run against the `winlogs` index, with fields pulled out using `rex` because the Splunk Windows add-on is not installed. Linux detections (L1-L4) run against `linuxlogs` and are documented in `queries/06-detections-linux.spl` and `docs/linux-forwarder-setup.md`. Web detections (W1-W2) run against the Splunk tutorial data in `index=main`.

## D1 - Multiple failed logons (T1110 Brute Force)

```
index=winlogs source="WinEventLog:Security" EventCode=4625
| rex max_match=0 "Account Name:\s+(?<acct>\S+)"
| rex "Source Network Address:\s+(?<src_ip>\S+)"
| rex "Logon Type:\s+(?<logon_type>\d+)"
| eval target_user=mvindex(acct,1)
| stats count AS failures, dc(target_user) AS accounts_tried, values(logon_type) AS logon_types by src_ip
| where failures > 5
| sort - failures
```

**Triage:** many failures from one source, especially against many accounts, suggests brute force or password spraying. Check the source reputation, then check whether any attempt succeeded (D2). **Tuning:** raise or lower the threshold, exclude known scanners and service accounts.

## D2 - Failures followed by a success (T1110 / T1078)

```
index=winlogs source="WinEventLog:Security" (EventCode=4625 OR EventCode=4624)
| rex max_match=0 "Account Name:\s+(?<acct>\S+)"
| eval target_user=mvindex(acct,1)
| eval outcome=if(EventCode=4625,"failure","success")
| stats count(eval(outcome="failure")) AS failures, count(eval(outcome="success")) AS successes, earliest(_time) AS first_seen, latest(_time) AS last_seen by target_user
| where failures > 3 AND successes > 0
| eval first_seen=strftime(first_seen,"%F %T"), last_seen=strftime(last_seen,"%F %T")
```

**Triage:** a success after repeated failures means the account may be compromised. Next: review what the account did after the success, reset the credentials, and look for the same source elsewhere. **Limit:** this does not check ordering; a production rule would confirm the success came after the failures.

## D3 - New local account created (T1136.001)

```
index=winlogs source="WinEventLog:Security" EventCode=4720
| rex max_match=0 "Account Name:\s+(?<acct>\S+)"
| eval created_by=mvindex(acct,0), new_account=mvindex(acct,1)
| table _time host created_by new_account
```

**Triage:** was the account expected? Who created it? Attackers create accounts for persistence. This fires when you run `create-lab-user.ps1`.

## D4 - Security audit log cleared (T1070.001)

```
index=winlogs source="WinEventLog:Security" EventCode=1102
| rex "Account Name:\s+(?<acct>\S+)"
| table _time host acct
```

**Triage:** clearing the log is a classic way to hide activity and is high severity unless an admin did it on purpose. Tested by exporting the log with `wevtutil epl`, then clearing it with `wevtutil cl Security`; Splunk had already ingested the earlier events, which shows why forwarding logs off the host matters.

## D5 - Member added to Administrators (T1098)

```
index=winlogs source="WinEventLog:Security" EventCode=4732
| rex "Subject:\s+Security ID:\s+\S+\s+Account Name:\s+(?<changed_by>\S+)"
| rex "Member:\s+Security ID:\s+(?<member_sid>\S+)"
| rex "Group Name:\s+(?<group>[^\r\n]+)"
| eval group=trim(group)
| where group="Administrators"
| table _time host changed_by member_sid group
```

**Triage:** who made the change, and who was added? An unexpected addition to Administrators is a privilege-escalation or persistence signal. **Tuning:** allowlist known admin accounts and change windows.

## D6 - New service installed (T1543.003)

```
index=winlogs source="WinEventLog:System" EventCode=7045
| rex "Service Name:\s+(?<service_name>[^\r\n]+)"
| rex "Service File Name:\s+(?<service_path>[^\r\n]+)"
| table _time host service_name service_path
```

**Triage:** check the service path. Services running from temp or user-writable folders, or with random names, are suspicious. **Tuning:** allowlist known software installs.

## D7 - Spike in failed logons over time (T1110)

```
index=winlogs source="WinEventLog:Security" EventCode=4625
| timechart span=15m count
```

Turn this into an alert when the count crosses a threshold (see `05-alerts-and-dashboards.md`).

## W1 - Web scanner (T1595 Active Scanning)

```
index=main sourcetype=access_combined* status=404
| stats count, dc(uri_path) AS paths by clientip
| where paths > 20
| sort - paths
```

**Triage:** one client probing many nonexistent paths looks like a scanner. Usually block and monitor; escalate if any probe got a `200`.

## W2 - Large data transfer (T1048)

```
index=main sourcetype=access_combined*
| stats sum(bytes) AS total by clientip
| eval mb=round(total/1024/1024,1)
| sort - mb
| head 10
```

**Triage:** compare with that client's normal volume before calling it exfiltration. This is a ranking, not a threshold rule.

## Linux detections (L1-L4)

See `queries/06-detections-linux.spl`: L1 SSH brute force (T1110), L2 SSH failures followed by a success (T1110 / T1078), L3 sudo session opened for root (T1548.003), L4 new local user created (T1136.001).

## How to describe each detection (practice out loud)

1. What it detects and the MITRE technique.
2. What makes it a true positive vs a false positive.
3. What you would do next.
4. How you would tune it.

## Checkpoint

- [ ] D1, D2 and D3 return your `labuser` events
- [ ] You saved a screenshot of D1 and D2 results
- [ ] You wrote one investigation note using `docs/investigation-template.md`
