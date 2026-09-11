# Draws the shared fixed-width header used by every menu. Keeping this in a
# module means new tools inherit the same visual format automatically.
function Write-DosHeader {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Title,

        [string]$Subtitle = ''
    )

    $line = "+" + ('-' * 76) + "+"
    Write-Host ''
    Write-Host $line -ForegroundColor DarkCyan
    Write-Host ("| {0,-74} |" -f $Title.ToUpper()) -ForegroundColor Yellow
    if (-not [string]::IsNullOrWhiteSpace($Subtitle)) {
        Write-Host ("| {0,-74} |" -f $Subtitle) -ForegroundColor DarkGray
    }
    Write-Host $line -ForegroundColor DarkCyan
}

function Write-DosFooter {
    [CmdletBinding()]
    param()

    Write-Host "+" + ('-' * 76) + "+" -ForegroundColor DarkCyan
}

# Normalizes only menu choices. Free-form values, such as an offline image
# path, should continue to be read directly so their original casing is kept.
function Read-MenuSelection {
    [CmdletBinding()]
    param(
        [string]$Prompt = 'SELECT OPTION'
    )

    return (Read-Host $Prompt).Trim().ToLowerInvariant()
}

function Show-Menu {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Title,

        [Parameter(Mandatory)]
        [string[]]$Options,

        [string]$Subtitle = ''
    )

    # This function owns rendering and input, while callers own menu behavior.
    Clear-Host
    Write-DosHeader -Title $Title -Subtitle $Subtitle

    for ($i = 0; $i -lt $Options.Count; $i++) {
        Write-Host ("   {0}. {1}" -f ($i + 1), $Options[$i]) -ForegroundColor White
    }

    Write-DosFooter
    return Read-MenuSelection
}

Export-ModuleMember -Function Write-DosHeader, Write-DosFooter, Read-MenuSelection, Show-Menu
