# 02 - Load data and generate test events

**Time:** about 30 minutes. You will load two kinds of data: Splunk's tutorial data, and your own Windows Security events that you create on purpose.

## Part A - Tutorial data (web, mail and sales logs)

1. In Splunk's documentation, open the **Search Tutorial** and download `tutorialdata.zip` and `Prices.csv.zip`. **Do not unzip them.**
2. In Splunk: **Settings > Add Data > Upload**.
3. Click **Select File** and choose `tutorialdata.zip`.
4. Click **Next**. Keep source type on **Automatic**. If you see a Host section, you can use the path-based option; otherwise keep the default.
5. Click **Next**, set **Index** to `main`, then **Review > Submit**.
6. Repeat for `Prices.csv.zip` (optional, used for the lookup exercise).

**Verify.** Open **Search & Reporting**, set the time picker to **All time**, and run:

```
index=main | stats count by host, sourcetype
```

You should see several hosts and sourcetypes, including a web access sourcetype (usually `access_combined_wcookie`).

> **All time matters.** The tutorial data is old. With "Last 24 hours" you will see nothing.

## Part B - Windows event logs from your own PC

1. **Settings > Add Data > Monitor > Local Event Logs**.
2. Under **Available log(s)**, add **Security**, **System** and **Application**.
3. **Next**, keep the default source type, set **Index** to `main`, then **Review > Submit**.

**Verify:**

```
index=main source="WinEventLog:Security" | stats count by EventCode | sort - count
```

If there are no results, set the time range to **Last 60 minutes**, lock your PC (Win+L), sign back in, and run it again.

> If you get no Security events at all, Splunk may not have permission. Confirm the Splunk service runs as **Local System** (see `01-install-splunk-windows.md`).

## Part C - Make sure Windows is auditing logons

In **PowerShell as Administrator**:

```powershell
auditpol /get /category:"Logon/Logoff"
```

Look for `Logon` with `Success and Failure`. If it only shows one, enable both:

```powershell
auditpol /set /subcategory:"Logon" /success:enable /failure:enable
```

## Part D - Create a throwaway test account

A test account lets you create realistic failed and successful logons without touching your real account.

Run from the repo folder in **PowerShell as Administrator**:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\scripts\create-lab-user.ps1
```

It asks you to choose a throwaway password (not one you use anywhere else). Creating the account generates **Event 4720** (a user account was created), which is Detection D3.

**Verify** in Windows: press Win+R, type `eventvwr.msc`, expand **Windows Logs > Security**, and use **Filter Current Log** for Event ID `4720`.

## Part E - Generate failed and successful logons

Still in the same PowerShell window:

```powershell
.\scripts\generate-failed-logons.ps1 -User labuser -Attempts 6
.\scripts\generate-successful-logon.ps1 -User labuser
```

The first script makes six failed network logons (**Event 4625**). The second makes one successful logon (**Event 4624**). Windows may lock accounts after repeated failures on some PCs; six is under the usual threshold.

**Verify** in Splunk (time picker: **Last 15 minutes**):

```
index=main source="WinEventLog:Security" (EventCode=4625 OR EventCode=4624)
| table _time EventCode Account_Name Logon_Type Source_Network_Address
```

Expect rows for `labuser` with `Logon_Type=3`.

> **Field names.** In Windows events, `Account_Name` appears twice (the account that made the request, then the target account). In SPL, `mvindex(Account_Name,1)` gives the target. If a field name differs on your system, click an event and check the field list.

## Part F - Cleanup (when you are done testing)

```powershell
.\scripts\remove-lab-user.ps1
```

## Checkpoint

- [ ] Tutorial data returns results with **All time**
- [ ] Security events (4624, 4625, 4720) appear in Splunk
- [ ] `labuser` events are visible in Event Viewer and Splunk
