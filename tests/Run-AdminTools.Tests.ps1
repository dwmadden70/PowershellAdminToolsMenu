$projectRoot = Split-Path -Parent $PSScriptRoot
$scriptPath = Join-Path $projectRoot 'scripts\Run-AdminTools.ps1'

# Dot-sourcing loads functions and modules without starting the interactive menu.
. $scriptPath

Describe 'Run-AdminTools script' {
    It 'exposes the application entry point without starting the menu' {
        (Get-Command Start-AdminTools).CommandType | Should Be 'Function'
    }

}

Describe 'DISM action validation' {
    It 'rejects an empty offline image path' {
        $result = Invoke-DismAction -Action 'checkhealth' -ImageType 'offline' -ImagePath '' -Context @{} 6>$null
        $result | Should BeNullOrEmpty
    }

    It 'rejects an unsupported image type' {
        $result = Invoke-DismAction -Action 'checkhealth' -ImageType 'invalid' -ImagePath '' -Context @{} 6>$null
        $result | Should BeNullOrEmpty
    }

    It 'rejects an unsupported DISM action' {
        $result = Invoke-DismAction -Action 'invalid' -ImageType 'online' -ImagePath '' -Context @{} 6>$null
        $result | Should BeNullOrEmpty
    }
}

Describe 'Generic menu handler dispatch' {
    It 'invokes a handler through the menu item contract' {
        $context = @{
            ImageSubMenuHandler = {
                param($actionName, $logPath)
                'handled:{0}:{1}' -f $actionName, $logPath
            }
            LogPath = 'test.log'
        }
        $menuItem = [pscustomobject]@{
            Label      = 'Test action'
            Handler    = 'Invoke-DismMenuItem'
            ActionName = 'checkhealth'
        }

        Invoke-MenuItem -MenuItem $menuItem -Context $context | Should Be 'handled:checkhealth:test.log'
    }

    It 'rejects a menu item without a handler' {
        $menuItem = [pscustomobject]@{ Label = 'Incomplete action' }
        $threw = $false
        try {
            Invoke-MenuItem -MenuItem $menuItem -Context @{}
        }
        catch {
            $threw = $true
        }

        $threw | Should Be $true
    }
}
