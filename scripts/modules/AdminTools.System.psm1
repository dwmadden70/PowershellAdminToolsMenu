# Uses the Windows security principal APIs instead of assuming that the
# current user name or PowerShell host implies an elevated session.
function Test-IsAdministrator {
    [CmdletBinding()]
    param()

    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    # IsInRole returns a Boolean that the caller can use without UI coupling.
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

Export-ModuleMember -Function Test-IsAdministrator
