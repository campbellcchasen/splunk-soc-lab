#Requires -RunAsAdministrator
<#
.SYNOPSIS
  Creates a throwaway local, non-admin test account for the Splunk lab.
  Generates Windows Security Event 4720 (user account created).
.NOTES
  Use a password you do not use anywhere else. Never commit it to Git.
#>
param([string]$User = "labuser")

if (Get-LocalUser -Name $User -ErrorAction SilentlyContinue) {
    Write-Host "User '$User' already exists. Nothing to do."
    return
}

$password = Read-Host "Choose a throwaway password for $User" -AsSecureString
New-LocalUser -Name $User -Password $password -Description "Splunk lab test account" -PasswordNeverExpires | Out-Null
Add-LocalGroupMember -Group "Users" -Member $User
Write-Host "Created local user '$User' (standard user)."
