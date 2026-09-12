# Load the DISM-specific module as a nested module so this module can expose
# both generic dispatch and the DISM handlers from one import point.
Import-Module (Join-Path $PSScriptRoot 'AdminTools.DismHandlers.psm1') -Force

# Routes a menu item to the function named by its Handler property. This keeps
# menu definitions data-driven and lets future tools provide their own handler.
function Invoke-MenuItem {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [pscustomobject]$MenuItem,

        [Parameter(Mandatory)]
        [hashtable]$Context
    )

    if ([string]::IsNullOrWhiteSpace($MenuItem.Handler)) {
        throw "Menu item '$($MenuItem.Label)' does not define a handler."
    }

    # Resolve the function before invoking it so a bad menu configuration gets
    # a clear error instead of silently failing during dynamic invocation.
    $handler = Get-Command -Name $MenuItem.Handler -CommandType Function -ErrorAction SilentlyContinue
    if ($null -eq $handler) {
        throw "Menu handler '$($MenuItem.Handler)' was not found."
    }

    # The call operator (&) invokes a command stored in a variable. Passing the
    # same contract to every handler keeps this dispatcher independent of tools.
    return & $handler.Name -MenuItem $MenuItem -Context $Context
}

# Adapts a generic menu item to the existing image-target submenu. The callback
# comes from the main script because this module should not own UI functions.
function Invoke-DismMenuItem {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [pscustomobject]$MenuItem,

        [Parameter(Mandatory)]
        [hashtable]$Context
    )

    return & $Context.ImageSubMenuHandler $MenuItem.ActionName $Context.LogPath
}

# Export only the public handler surface; helper or implementation details in
# nested modules remain behind this module's import boundary.
Export-ModuleMember -Function Invoke-MenuItem, Invoke-DismMenuItem, Invoke-DismCommand, Invoke-DismAction
