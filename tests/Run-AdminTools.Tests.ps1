BeforeAll {
    $projectRoot = Split-Path -Parent $PSScriptRoot
    $scriptPath  = Join-Path $projectRoot 'scripts/Run-AdminTools.ps1'

    # Dot-sourcing loads functions and modules without starting the interactive menu.
    . $scriptPath
}

Describe 'Run-AdminTools script' {
    It 'exposes the application entry point without starting the menu' {
        (Get-Command Start-AdminTools).CommandType.ToString() | Should-BeString 'Function'
    }
}

Describe 'DISM action validation' {
    It 'rejects <scenario>' -ForEach @(
        @{ scenario = 'an empty offline image path';    Action = 'checkhealth'; ImageType = 'offline'; ImagePath = '' }
        @{ scenario = 'an unsupported image type';      Action = 'checkhealth'; ImageType = 'invalid'; ImagePath = '' }
        @{ scenario = 'an unsupported DISM action';     Action = 'invalidxxx';     ImageType = 'online';  ImagePath = '' }
    ) {
        $result = Invoke-DismAction -Action $Action -ImageType $ImageType -ImagePath $ImagePath -Context @{} 6>$null
        $result | Should-BeNull
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

        Invoke-MenuItem -MenuItem $menuItem -Context $context | Should-BeString 'handled:checkhealth:test.log'
    }

   It 'rejects a menu item without a handler' {
    $menuItem = [pscustomobject]@{ Label = 'Incomplete action' }

        { Invoke-MenuItem -MenuItem $menuItem -Context @{} } | Should-Throw -Because 'a menu item must declare a handler'}
    }

