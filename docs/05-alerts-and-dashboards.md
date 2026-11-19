# 05 - Alerts, reports and dashboards

**Time:** about 30 minutes.

## Create an alert (D1: brute force)

1. In **Search & Reporting**, set the time picker to **Last 15 minutes** and run D1 from `04-detections.md`.
2. Click **Save As > Alert**.
3. Title: `Brute Force - Multiple Failed Logons`.
4. **Alert type:** Scheduled, **Run every hour** is the simplest option in the dropdown; choose **Run on Cron Schedule** with `*/15 * * * *` to run every 15 minutes.
5. **Trigger alert when:** Number of Results is greater than 0.
6. **Trigger Actions:** Add to Triggered Alerts, severity High.
7. Click **Save**.

Generate more failures (`.\scripts\generate-failed-logons.ps1 -Attempts 8`) and check **Activity > Triggered Alerts** after the next run.

**Verify:** the alert is listed under **Settings > Searches, reports, and alerts**.

> After the 60-day trial, the Free license cannot schedule alerts. Take your screenshots while the trial is active.

## Create a dashboard

1. Run D7 (`timechart` of failures). **Save As > Dashboard Panel**, create a new dashboard named `SOC Overview`.
2. Run D1 and save it as a second panel (table).
3. Run `index=main sourcetype=access_combined* | top limit=10 clientip` and save it as a third panel.
4. Open **Dashboards > SOC Overview** and confirm all three panels load.

## Create a report

Run `index=main sourcetype=access_combined* | stats count by status`, then **Save As > Report**.

## Enterprise Security concepts (know the vocabulary)

- **Correlation search:** a scheduled search that creates a notable event when its logic matches.
- **Notable event:** the alert an analyst triages (status, owner, urgency).
- **Incident Review:** the ES queue where notables are worked.
- **Risk-based alerting:** many small risk events add up to one alert.
- **CIM / data models:** normalized field names (`src`, `dest`, `user`) so one search works across vendors.
- **Add-ons (TAs):** parse and normalize a specific log source.

## Checkpoint

- [ ] Alert saved and visible in Searches, reports, and alerts
- [ ] Dashboard has three working panels
- [ ] Screenshots saved (redacted)
