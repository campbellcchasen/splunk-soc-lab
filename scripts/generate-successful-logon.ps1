<#
.SYNOPSIS
  Generates one successful network logon (Windows Security Event 4624) for the lab account.
.EXAMPLE
  .\scripts\generate-successful-logon.ps1 -User labuser
#>
param([string]$User = "labuser")

$secure = Read-Host "Password for $User" -AsSecureString
$ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
try {
    $plain = [Runtime.InteropServices.Marshal]::PtrToStringAuto($ptr)
    net use '\\localhost\IPC$' "/user:$User" $plain 2>&1 | Out-Null
    net use '\\localhost\IPC$' /delete 2>&1 | Out-Null
}
finally {
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
}
Write-Host "Generated one logon for '$User'."
