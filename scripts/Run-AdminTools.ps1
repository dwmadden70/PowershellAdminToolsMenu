[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

# Explicit results let nested menus communicate navigation intent without
# printing Boolean values or terminating the session inside a helper function.
enum MenuResult {
    Continue
    Back
    MainMenu
    Exit
}

# Import shared services and handlers before the application-specific menu loop.
Import-Module (Join-Path $PSScriptRoot 'modules\AdminTools.Logging.psm1') -Force
Import-Module (Join-Path $PSScriptRoot 'modules\AdminTools.System.psm1') -Force
Import-Module (Join-Path $PSScriptRoot 'modules\AdminTools.UI.psm1') -Force
Import-Module (Join-Path $PSScriptRoot 'handlers\AdminTools.Handlers.psm1') -Force
Import-Module (Join-Path $PSScriptRoot 'handlers\AdminTools.MenuHandlers.psm1') -Force

function Start-AdminTools {
    [CmdletBinding()]
    param()

    $logDirectory = Join-Path $PSScriptRoot '..\logs'
    if (-not (Test-Path -LiteralPath $logDirectory)) {
        New-Item -LiteralPath $logDirectory -ItemType Directory -Force | Out-Null
    }

    $logFile = Join-Path $logDirectory 'dism.log'

    if (-not (Test-IsAdministrator)) {
        Write-Host 'This script must be run as Administrator.' -ForegroundColor Red
        Write-Host 'Please reopen PowerShell as an administrator and run this script again.' -ForegroundColor Yellow
        $null = Read-Host 'Press Enter to exit'
        return 1
    }

    Write-Log -Message 'Starting DISM script.' -Path $logFile

    while ($true) {
        $mainOptions = @(
            'Windows Health',
            'Exit'
        )

        $selection = Show-Menu -Title 'ADMIN TOOLS' -Options $mainOptions -Subtitle ''

        switch ($selection) {
            '1' {
                $menuResult = Show-WindowsHealthMenu -LogPath $logFile
            }
            '2' {
                $menuResult = [MenuResult]::Exit
            }
            default {
                $menuResult = [MenuResult]::Continue
            }
        }

        if ($menuResult -eq [MenuResult]::Exit) {
            Write-Log -Message 'User exited the DISM menu.' -Path $logFile
            Write-Host "`nPROGRAM TERMINATED." -ForegroundColor Green
            return 0
        }

        if ($menuResult -eq [MenuResult]::Continue -and $selection -notin @('1', '2')) {
            Write-Host 'INVALID SELECTION. PLEASE CHOOSE 1 OR 2.' -ForegroundColor Yellow
            Write-Host ''
            $null = Read-Host 'PRESS ENTER TO CONTINUE'
        }
    }
}

# Dot-sourcing loads the functions for tests or another script without
# launching the interactive menu. Direct execution starts the application.
if ($MyInvocation.InvocationName -ne '.') {
    $exitCode = Start-AdminTools
    if ($null -ne $exitCode) {
        exit $exitCode
    }
}
