# Get-DiskSpace
*This script is for a lab environment and meant for learning purposes only*

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

## Sample Output

> [!Note] `Get-ADComputerState` is a custom script (it pulls all AD computers and displays if it's online or offline)


<img width="831" height="548" alt="image" src="https://github.com/user-attachments/assets/9a45d3d5-0b44-45cd-9684-75b331000c77" />



```
PS C:\Logs> get-adcomputerstate | where {$_.status -eq 'online'} | get-diskspace
DC01
Drive    Size(GB)    Free(GB)    Free%
-----    --------    --------    -----
C:          79.37       62.76   79.07%
A8-7600-1
Drive    Size(GB)    Free(GB)    Free%
-----    --------    --------    -----
C:         110.74       39.62   35.77%
G:              0           0        %
THINKPAD-T470
Drive    Size(GB)    Free(GB)    Free%
-----    --------    --------    -----
C:         237.86       64.63   27.17%
D:         238.47       50.73   21.27%
E:             15        5.45   36.32%
G:             15        2.16   14.37%
J:             15       12.25   81.69%
DC02
Drive    Size(GB)    Free(GB)    Free%
-----    --------    --------    -----
C:          59.37       48.09      81%
PS C:\Logs>
```
