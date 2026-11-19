#Requires -RunAsAdministrator
<#
.SYNOPSIS
  Removes the throwaway lab account when you are finished testing.
#>
param([string]$User = "labuser")

if (Get-LocalUser -Name $User -ErrorAction SilentlyContinue) {
    Remove-LocalUser -Name $User
    Write-Host "Removed local user '$User'."
} else {
    Write-Host "User '$User' not found."
}
