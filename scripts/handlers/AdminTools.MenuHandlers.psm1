# Menu handlers stay separate from the entry script so the main loop only
# coordinates startup, shared context, and application shutdown.
function Show-ImageSubMenu {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ActionName,

        [Parameter(Mandatory)]
        [string]$LogPath
    )

    while ($true) {
        $options = @(
            'Online image',
            'Offline image',
            'Back to Windows Health menu'
        )

        $selection = Show-Menu -Title "DISM ACTION: $ActionName" -Options $options -Subtitle 'Choose the image target'

        switch ($selection) {
            '1' {
                # Pass the logger through context so the DISM module does not
                # need to import or depend on the main script's scope.
                $context = @{ LogPath = $LogPath; WriteLog = (Get-Command Write-Log) }
                $result = Invoke-DismAction -Action $ActionName -ImageType 'online' -ImagePath '' -Context $context
                if ($null -ne $result) {
                    if ($result.ExitCode -eq 0) {
                        Write-Host "`nTHE $ActionName ACTION COMPLETED SUCCESSFULLY ON THE ONLINE IMAGE." -ForegroundColor Green
                    }
                    else {
                        Write-Host "`nTHE $ActionName ACTION FAILED ON THE ONLINE IMAGE. SEE LOG: $LogPath" -ForegroundColor Red
                    }
                }
                Write-Host ''
                $null = Read-Host 'PRESS ENTER TO CONTINUE'
                return [MenuResult]::Back
            }
            '2' {
                $offlineImagePath = Read-Host 'ENTER THE PATH TO THE OFFLINE IMAGE (EXAMPLE: D:\MOUNT\WINSXS)'
                $context = @{ LogPath = $LogPath; WriteLog = (Get-Command Write-Log) }
                $result = Invoke-DismAction -Action $ActionName -ImageType 'offline' -ImagePath $offlineImagePath -Context $context
                if ($null -ne $result) {
                    if ($result.ExitCode -eq 0) {
                        Write-Host "`nTHE $ActionName ACTION COMPLETED SUCCESSFULLY ON THE OFFLINE IMAGE." -ForegroundColor Green
                    }
                    else {
                        Write-Host "`nTHE $ActionName ACTION FAILED ON THE OFFLINE IMAGE. SEE LOG: $LogPath" -ForegroundColor Red
                    }
                }
                Write-Host ''
                $null = Read-Host 'PRESS ENTER TO CONTINUE'
                return [MenuResult]::Back
            }
            '3' {
                return [MenuResult]::Back
            }
            default {
                Write-Host 'INVALID SELECTION. PLEASE CHOOSE 1, 2, OR 3.' -ForegroundColor Yellow
                Write-Host ''
                $null = Read-Host 'PRESS ENTER TO CONTINUE'
            }
        }
    }
}

function Show-WindowsHealthMenu {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$LogPath
    )

    while ($true) {
        # Menu items are data, not switch branches. Add a record here to
        # expose another action while reusing the generic handler dispatcher.
        $menuItems = @(
            [pscustomobject]@{
                Label      = 'Check health'
                ActionName = 'checkhealth'
                Handler    = 'Invoke-DismMenuItem'
            }
            [pscustomobject]@{
                Label      = 'Restore health'
                ActionName = 'restorehealth'
                Handler    = 'Invoke-DismMenuItem'
            }
            [pscustomobject]@{
                Label      = 'Start component cleanup'
                ActionName = 'componentcleanup'
                Handler    = 'Invoke-DismMenuItem'
            }
        )
        $options = @($menuItems.Label) + @('Back to main menu')

        $selection = Show-Menu -Title 'WINDOWS HEALTH' -Options $options -Subtitle 'Choose a maintenance action'

        if ($selection -match '^\d+$') {
            $selectedIndex = [int]$selection - 1

            if ($selectedIndex -ge 0 -and $selectedIndex -lt $menuItems.Count) {
                # A scriptblock reference lets this module call the nested menu
                # without importing or duplicating the UI function.
                $context = @{
                    LogPath              = $LogPath
                    ImageSubMenuHandler = ${function:Show-ImageSubMenu}
                }
                $result = Invoke-MenuItem -MenuItem $menuItems[$selectedIndex] -Context $context
                if ($result -in @([MenuResult]::MainMenu, [MenuResult]::Exit)) {
                    return $result
                }

                continue
            }

            if ($selectedIndex -eq $menuItems.Count) {
                return [MenuResult]::Back
            }
        }

        Write-Host 'INVALID SELECTION. PLEASE CHOOSE 1, 2, 3, OR 4.' -ForegroundColor Yellow
        Write-Host ''
        $null = Read-Host 'PRESS ENTER TO CONTINUE'
    }
}

Export-ModuleMember -Function Show-ImageSubMenu, Show-WindowsHealthMenu
