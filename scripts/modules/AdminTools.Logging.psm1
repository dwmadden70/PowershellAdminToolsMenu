# Shared logger used by handlers. Empty messages are valid because native
# commands can emit blank lines while their output is streamed.
function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]$Message,

        [Parameter(Mandatory)]
        [string]$Path,

        [switch]$NoConsole
    )

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $line = "[$timestamp] $Message"
    # LiteralPath prevents wildcard characters in a path from being expanded;
    # explicit encoding keeps logs readable across PowerShell versions.
    Add-Content -LiteralPath $Path -Value $line -Encoding utf8

    if (-not $NoConsole) {
        Write-Host $line
    }
}

Export-ModuleMember -Function Write-Log
