# 01 - Install Splunk Enterprise on Windows

**Time:** about 20 minutes. **Use a personal computer only.** Do not install this on an employer-owned machine.

## Requirements

- Windows 10 or 11, 64-bit, with administrator rights
- 8 GB RAM recommended (4 GB works but is slow) and 10 GB free disk
- A free account at splunk.com

## Step 1 - Download

1. Go to splunk.com and sign in (or create a free account).
2. Search for **Splunk Enterprise free trial download** and choose **Windows, 64-bit (.msi)**.
3. Save the file to `Downloads`. Do not commit it to Git (the `.gitignore` already blocks `*.msi`).

## Step 2 - Run the installer

1. Double-click the `.msi`. If Windows asks for permission, choose **Yes**.
2. Check **Check this box to accept the License Agreement**.
3. Click **Customize Options** so you can see what is being installed. Keep the default install path `C:\Program Files\Splunk`. Click **Next**.
4. On the account screen choose **Local System**. (This lets Splunk read the Windows Security event log on this PC.) Click **Next**.
5. Create the admin account:
   - Username: `admin` (or your choice)
   - Password: a long, unique password. Save it in a password manager. Never put it in this repo.
6. Click **Install**. When it finishes, leave **Launch browser with Splunk Enterprise** checked and click **Finish**.

## Step 3 - First sign-in

1. Your browser opens `http://localhost:8000`. If not, open it yourself.
2. Sign in with the admin account.
3. Close the welcome tour. You should land on **Home** with **Search & Reporting** in the left panel.

## Step 4 - Verify it is working

Open **PowerShell as Administrator** (Start menu, type PowerShell, right-click, Run as administrator):

```powershell
Get-Service splunkd
```

Expected: `Status` is `Running`.

```powershell
netstat -ano | findstr :8000
```

Expected: a line with `LISTENING`.

```powershell
& "C:\Program Files\Splunk\bin\splunk.exe" version
```

Expected: prints the Splunk version.

## Step 5 - Useful service commands

```powershell
Stop-Service splunkd      # stop Splunk to free memory
Start-Service splunkd     # start it again
Restart-Service splunkd   # restart after config changes
```

To stop Splunk from starting every time Windows boots (saves resources):

```powershell
Set-Service splunkd -StartupType Manual
```

## Troubleshooting

| Problem | Fix |
| --- | --- |
| Page will not load | Wait 1-2 minutes after install. Run `Get-Service splunkd`; if stopped, `Start-Service splunkd`. |
| Still will not load | `Get-Content "C:\Program Files\Splunk\var\log\splunk\splunkd.log" -Tail 50` and read the last errors. |
| Port 8000 in use | Another app is using it. Find it with `netstat -ano | findstr :8000` and stop it, or change Splunk's web port. |
| Very slow | Close other apps, and confirm at least 4 GB of free RAM. |
| Installer blocked | Your antivirus or Windows SmartScreen may need an "Allow" or "Run anyway". |

## About the license

The Enterprise trial lasts 60 days. After that Splunk reverts to a Free license with limits (including no scheduled alerting). Check status in **Settings > Licensing**.

## Checkpoint

- [ ] `Get-Service splunkd` shows Running
- [ ] You can sign in at `http://localhost:8000`
- [ ] You saved a screenshot of the Splunk Home page (redact nothing needed here, but see `screenshots/README.md`)
