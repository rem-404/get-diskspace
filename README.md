# Get-DiskSpace

## What does it do

Checks disk space usage on one or more computers and displays a color coded summary per drive:

- 🟢 Green — healthy (35%+ free)
- 🟡 Yellow — getting low (15-35% free)
- 🔴 Red — critical (under 15% free)

Works on the local machine without needing a network connection, and on remote machines via `Invoke-Command`.

## What does it solve

Checking disk space manually on multiple machines one by one is slow. This gives a quick color coded snapshot across all target machines in one shot — useful for spotting drives that need attention before they become a problem.

## Who's it for

Sysadmins who want a fast visual disk health check across local and remote Windows machines.

## Requirements

- PowerShell with WinRM enabled on remote target machines
- `$cred` loaded in your session for remote queries — see note below
- No network required for local machine checks

## Usage

powershell

```powershell
# Local machine only
Get-DiskSpace

# Single remote machine
Get-DiskSpace -ComputerName DC01

# Multiple remote machines
Get-DiskSpace -ComputerName DC01, DC02, THINKPAD-T470

# Pipeline from Get-ADComputerState (online machines only)
Get-ADComputerState | Where-Object { $_.Status -eq "Online" } | Get-DiskSpace

# Using the alias
Get-DiskSpace -Name DC01
```

## Warning

- `$cred` is intentional for remote queries — local admin + separate domain means Kerberos doesn't work. Change to `$Credential` parameter if running from a domain joined machine
- Google Drive and mapped network drives are excluded from local checks by design — `Invoke-Command` runs in a context where mapped drives are not available, so local CIM query is used instead for the local machine
- `-ErrorAction Stop` is on `Get-CimInstance` so failed connections are caught cleanly and don't silently return empty results

## Limitations

- Display uses `Write-Host` — output is not pipeline friendly, for display only
- Color thresholds (15% and 35%) are hardcoded — not currently parameters
- No logging to file
- `BEGIN {}` and `END {}` blocks are empty — placeholders for future use

## Notes

Work in progress — configurable thresholds and pipeline friendly output coming in a future iteration. Pairs well with `Get-ADComputerState` for targeting online machines before checking disk health.
