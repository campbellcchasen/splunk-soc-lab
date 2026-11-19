<#
.SYNOPSIS
  Generates failed network logons (Windows Security Event 4625) for the lab account.
.EXAMPLE
  .\scripts\generate-failed-logons.ps1 -User labuser -Attempts 6
#>
param(
    [string]$User = "labuser",
    [int]$Attempts = 6
)

for ($i = 1; $i -le $Attempts; $i++) {
    net use '\\localhost\IPC$' "/user:$User" "WrongPass-$i!" 2>&1 | Out-Null
    Start-Sleep -Milliseconds 500
}
net use '\\localhost\IPC$' /delete 2>&1 | Out-Null
Write-Host "Generated $Attempts failed logon attempts for '$User'."
