[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Write-Log {
    param(
        [string]$Message,
        [string]$Path
    )

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $line = "[$timestamp] $Message"
    Add-Content -Path $Path -Value $line
    Write-Host $line
}

function Write-DosHeader {
    param(
        [string]$Title,
        [string]$Subtitle = ''
    )

    $line = "+" + ('-' * 76) + "+"
    Write-Host "" 
    Write-Host $line -ForegroundColor DarkCyan
    Write-Host ("| {0,-74} |" -f $Title.ToUpper()) -ForegroundColor Yellow
    if (-not [string]::IsNullOrWhiteSpace($Subtitle)) {
        Write-Host ("| {0,-74} |" -f $Subtitle) -ForegroundColor DarkGray
    }
    Write-Host $line -ForegroundColor DarkCyan
}

function Write-DosFooter {
    Write-Host "+" + ('-' * 76) + "+" -ForegroundColor DarkCyan
}

function Show-Menu {
    param(
        [string]$Title,
        [string[]]$Options,
        [string]$Subtitle = ''
    )

    Clear-Host
    Write-DosHeader -Title $Title -Subtitle $Subtitle

    for ($i = 0; $i -lt $Options.Count; $i++) {
        Write-Host ("   {0}. {1}" -f ($i + 1), $Options[$i]) -ForegroundColor White
    }

    Write-DosFooter
    $choice = Read-Host "SELECT OPTION"
    return $choice
}

function Invoke-DismCommand {
    param(
        [string[]]$Arguments,
        [string]$LogPath
    )

    Write-Host "`nRunning DISM command..." -ForegroundColor Cyan
    Write-Host ("dism.exe " + ($Arguments -join ' ')) -ForegroundColor DarkGray

    $output = & dism.exe @Arguments 2>&1
    $exitCode = $LASTEXITCODE

    foreach ($line in $output) {
        Write-Log -Message $line -Path $LogPath
    }

    if ($exitCode -eq 0) {
        Write-Host "DISM completed successfully." -ForegroundColor Green
    }
    else {
        Write-Host "DISM did not complete successfully. Exit code: $exitCode" -ForegroundColor Red
    }

    return [pscustomobject]@{
        ExitCode = $exitCode
        Output   = $output
    }
}

function Invoke-DismAction {
    param(
        [string]$Action,
        [string]$ImageType,
        [string]$ImagePath,
        [string]$LogPath
    )

    $arguments = @()

    switch ($ImageType) {
        'online' {
            $arguments += '/Online'
        }
        'offline' {
            if ([string]::IsNullOrWhiteSpace($ImagePath)) {
                Write-Host "An offline image path is required." -ForegroundColor Red
                return $null
            }
            $arguments += '/Image:' + $ImagePath
        }
        default {
            Write-Host "Invalid image type selected." -ForegroundColor Red
            return $null
        }
    }

    $arguments += '/Cleanup-Image'

    switch ($Action) {
        'checkhealth' {
            $arguments += '/CheckHealth'
        }
        'restorehealth' {
            $arguments += '/RestoreHealth'
        }
        'componentcleanup' {
            $arguments += '/StartComponentCleanup'
        }
        default {
            Write-Host "Unsupported DISM action: $Action" -ForegroundColor Red
            return $null
        }
    }

    return Invoke-DismCommand -Arguments $arguments -LogPath $LogPath
}

function Show-ImageSubMenu {
    param(
        [string]$ActionName,
        [string]$LogPath
    )

    while ($true) {
        $options = @(
            'Online image',
            'Offline image',
            'Back to main menu'
        )

        $selection = Show-Menu -Title "DISM ACTION: $ActionName" -Options $options -Subtitle 'Choose the image target'

        switch ($selection) {
            '1' {
                $result = Invoke-DismAction -Action $ActionName -ImageType 'online' -ImagePath '' -LogPath $LogPath
                if ($null -ne $result) {
                    if ($result.ExitCode -eq 0) {
                        Write-Host "`nTHE $ActionName ACTION COMPLETED SUCCESSFULLY ON THE ONLINE IMAGE." -ForegroundColor Green
                    }
                    else {
                        Write-Host "`nTHE $ActionName ACTION FAILED ON THE ONLINE IMAGE. SEE LOG: $LogPath" -ForegroundColor Red
                    }
                }
                Write-Host "" ; Read-Host "PRESS ENTER TO CONTINUE"
                return
            }
            '2' {
                $offlineImagePath = Read-Host "ENTER THE PATH TO THE OFFLINE IMAGE (EXAMPLE: D:\\MOUNT\\WINSXS)"
                $result = Invoke-DismAction -Action $ActionName -ImageType 'offline' -ImagePath $offlineImagePath -LogPath $LogPath
                if ($null -ne $result) {
                    if ($result.ExitCode -eq 0) {
                        Write-Host "`nTHE $ActionName ACTION COMPLETED SUCCESSFULLY ON THE OFFLINE IMAGE." -ForegroundColor Green
                    }
                    else {
                        Write-Host "`nTHE $ActionName ACTION FAILED ON THE OFFLINE IMAGE. SEE LOG: $LogPath" -ForegroundColor Red
                    }
                }
                Write-Host "" ; Read-Host "PRESS ENTER TO CONTINUE"
                return
            }
            '3' {
                return
            }
            default {
                Write-Host "INVALID SELECTION. PLEASE CHOOSE 1, 2, OR 3." -ForegroundColor Yellow
                Write-Host "" ; Read-Host "PRESS ENTER TO CONTINUE"
            }
        }
    }
}

$logDirectory = Join-Path $PSScriptRoot '..\logs'
if (-not (Test-Path -Path $logDirectory)) {
    New-Item -Path $logDirectory -ItemType Directory -Force | Out-Null
}

$logFile = Join-Path $logDirectory 'dism.log'

if (-not (Test-IsAdministrator)) {
    Write-Host "This script must be run as Administrator." -ForegroundColor Red
    Write-Host "Please reopen PowerShell as an administrator and run this script again." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Log -Message 'Starting DISM script.' -Path $logFile

while ($true) {
    $mainOptions = @(
        'Check health',
        'Restore health',
        'Start component cleanup',
        'Exit'
    )

    $selection = Show-Menu -Title 'WINDOWS DISM REPAIR MENU' -Options $mainOptions -Subtitle 'ADMINISTRATIVE SYSTEM REPAIR TOOL'

    switch ($selection) {
        '1' {
            Show-ImageSubMenu -ActionName 'checkhealth' -LogPath $logFile
        }
        '2' {
            Show-ImageSubMenu -ActionName 'restorehealth' -LogPath $logFile
        }
        '3' {
            Show-ImageSubMenu -ActionName 'componentcleanup' -LogPath $logFile
        }
        '4' {
            Write-Log -Message 'User exited the DISM menu.' -Path $logFile
            Write-Host "`nPROGRAM TERMINATED." -ForegroundColor Green
            exit 0
        }
        default {
            Write-Host "INVALID SELECTION. PLEASE CHOOSE 1, 2, 3, OR 4." -ForegroundColor Yellow
            Write-Host "" ; Read-Host "PRESS ENTER TO CONTINUE"
        }
    }
}
