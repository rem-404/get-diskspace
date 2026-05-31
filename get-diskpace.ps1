<#
  Just a simple tool for checking a computer's disk space usage
  Data output is not pipe friendly, useful only for viasual check
#>

function Get-DiskSpace {
  [CmdletBinding()]
  param (
    [alias('Name')]
    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [string[]]$ComputerName = $env:COMPUTERNAME
  )

  BEGIN {}

  PROCESS {

    # Loops through Computername array
    foreach ($Computer in $ComputerName) {

      try {

        # This violates "dry" principle but its the least complicated approach (i tried function call but it didn't work)
        # This condition is for checking localhost "locally" bacause if the command is invoked - Google Drive is invalidated
        if ($Computer -eq "$env:COMPUTERNAME") {
          $Result = Get-CimInstance -ClassName Win32_LogicalDisk -ErrorAction Stop | Where-Object { $_.DriveType -eq 3 } |
          Select-Object DeviceID,
          @{n = 'SizeGB'; e = { [math]::Round($_.Size / 1GB, 2) } },
          @{n = 'FreeGB'; e = { [math]::Round($_.FreeSpace / 1GB, 2) } },
          @{n = 'FreePercent'; e = { [math]::Round(($_.FreeSpace / $_.Size) * 100, 2) } } -ErrorAction Stop
        }
        else {
          # This is for remote
          # -Credential $cred is intentional, not a mistake. Local Admin + separate domain = Kerberos doesn't work
          $Result = Invoke-Command -ComputerName $Computer -Credential $cred -ScriptBlock {
            Get-CimInstance -ClassName Win32_LogicalDisk -ErrorAction Stop | Where-Object { $_.DriveType -eq 3 } |
            Select-Object DeviceID,
            @{n = 'SizeGB'; e = { [math]::Round($_.Size / 1GB, 2) } },
            @{n = 'FreeGB'; e = { [math]::Round($_.FreeSpace / 1GB, 2) } },
            @{n = 'FreePercent'; e = { [math]::Round(($_.FreeSpace / $_.Size) * 100, 2) } }
          }
        }

        # Looks complicated because  of the condition needed to display different colors depending on disk remaining space

        # ==========================================
        #                 DISPLAY 
        # ==========================================
        Write-Host "$Computer" -ForegroundColor Cyan

        # Trying a new approach in colum alignment (using padding)
        Write-Host $("Drive".PadRight(7) + "Size(GB)".PadLeft(10) + "Free(GB)".PadLeft(12) + "Free%".PadLeft(9)) -ForegroundColor Gray
        Write-Host $("-----".PadRight(7) + "--------".PadLeft(10) + "--------".PadLeft(12) + "-----".PadLeft(9)) -ForegroundColor Gray

        # Loops through logical Disk Drives
        foreach ($Disk in $Result) {

          #Adding padding to the data - it will line up with the header
          $DriveCol = "$($Disk.DeviceID)".PadRight(7)
          $SizeCol = "$($Disk.SizeGB)".PadLeft(10)
          $FreeCol = "$($Disk.FreeGB)".PadLeft(12)
          $PctCol = "$($Disk.FreePercent)%".PadLeft(9)

         
          # construct the psuedo table
          $msg = "$DriveCol$SizeCol$FreeCol$PctCol"

          # red if disk space is less than 15%
          # yellow if less than 35%
          # green for all others
          if ($Disk.FreePercent -lt 15) {
            Write-Host $msg -ForegroundColor Red
          }
          elseif ($Disk.FreePercent -lt 35) {
            Write-Host $msg -ForegroundColor Yellow
          }
          else {
            Write-Host $msg -ForegroundColor Green
          }

        } # foreach
      } 
      catch {
        Write-Warning "Failed to to get diskpace of $computer : $($_.Exception.Message)"
      }

    } # main foreach

  } # PROCESS

  END {}

} # function
