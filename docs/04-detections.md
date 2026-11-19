# 04 - SOC-style detections

**Time:** about 45 minutes. For each detection: run it, decide whether the result is real, say what you would do next, and say how you would tune it. All queries are also in `queries/`.

## D1 - Multiple failed logons (T1110 Brute Force)

```
index=main source="WinEventLog:Security" EventCode=4625
| eval target_user=mvindex(Account_Name,1)
| stats count AS failures, dc(target_user) AS accounts_tried, values(Logon_Type) AS logon_types by Source_Network_Address
| where failures > 5
| sort - failures
```

**Triage:** many failures from one source, especially against many accounts, suggests brute force or password spraying. Check the source reputation, then check whether any attempt succeeded (D2). **Tuning:** raise or lower the threshold, exclude known scanners and service accounts.

## D2 - Failures followed by a success (T1110 / T1078)

```
index=main source="WinEventLog:Security" (EventCode=4625 OR EventCode=4624)
| eval target_user=mvindex(Account_Name,1)
| eval outcome=if(EventCode=4625,"failure","success")
| stats count(eval(outcome="failure")) AS failures, count(eval(outcome="success")) AS successes, earliest(_time) AS first_seen, latest(_time) AS last_seen by target_user
| where failures > 3 AND successes > 0
| eval first_seen=strftime(first_seen,"%F %T"), last_seen=strftime(last_seen,"%F %T")
```

**Triage:** a success after repeated failures means the account may be compromised. Next: review what the account did after the success, reset the credentials, and look for the same source elsewhere. **Limit:** this does not check ordering; a production rule would confirm the success came after the failures.

## D3 - New local account created (T1136.001)

```
index=main source="WinEventLog:Security" EventCode=4720
| eval created_by=mvindex(Account_Name,0), new_account=mvindex(Account_Name,1)
| table _time host created_by new_account
```

**Triage:** was the account expected? Who created it? Attackers create accounts for persistence. This fires when you run `create-lab-user.ps1`.

## D4 - Security audit log cleared (T1070.001)

```
index=main source="WinEventLog:Security" EventCode=1102
| table _time host Account_Name
```

**Triage:** clearing the log is a classic way to hide activity and is high severity unless an admin did it on purpose. It will only fire if the log is cleared, so do not clear your own log just to test it.

## D5 - Web scanner (T1595)

```
index=main sourcetype=access_combined* status=404
| stats count, dc(uri_path) AS paths by clientip
| where paths > 20
| sort - paths
```

**Triage:** one client probing many nonexistent paths looks like a scanner. Usually block and monitor; escalate if any probe got a `200`.

## D6 - Large data transfer (T1048)

```
index=main sourcetype=access_combined*
| stats sum(bytes) AS total by clientip
| eval mb=round(total/1024/1024,1)
| sort - mb
| head 10
```

**Triage:** compare with that client's normal volume before calling it exfiltration.

## D7 - Spike in failures over time (T1110)

```
index=main source="WinEventLog:Security" EventCode=4625
| timechart span=15m count
```

Turn this into an alert when the count crosses a threshold (see `05-alerts-and-dashboards.md`).

## Stretch: process creation (Event 4688)

Process creation is not logged by default. To enable it, in **PowerShell as Administrator**:

```powershell
auditpol /set /subcategory:"Process Creation" /success:enable
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit" /v ProcessCreationIncludeCmdLine_Enabled /t REG_DWORD /d 1 /f
```

Then:

```
index=main source="WinEventLog:Security" EventCode=4688
| stats count by New_Process_Name
| sort count
```

Rare processes at the top are worth a look. This produces a lot of data, so turn it off when finished:

```powershell
auditpol /set /subcategory:"Process Creation" /success:disable
```

## How to describe each detection (practice out loud)

1. What it detects and the MITRE technique.
2. What makes it a true positive vs a false positive.
3. What you would do next.
4. How you would tune it.

## Checkpoint

- [ ] D1, D2 and D3 return your `labuser` events
- [ ] You saved a screenshot of D1 and D2 results
- [ ] You wrote one investigation note using `docs/investigation-template.md`
