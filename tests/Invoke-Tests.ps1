[CmdletBinding()]
param()

# The test file uses BeforeAll and modern Should syntax, which require Pester 5+.
Import-Module Pester -MinimumVersion 6.0.0 -MaximumVersion 6.99.99 -Force

$testPath = Join-Path $PSScriptRoot 'Run-AdminTools.Tests.ps1'
$result = Invoke-Pester -Path $testPath -Output None -PassThru

$summary = [pscustomobject]@{
    TestPath    = $testPath
    Total       = $result.TotalCount
    Passed      = $result.PassedCount
    Failed      = $result.FailedCount
    Skipped     = $result.SkippedCount
    Inconclusive = $result.InconclusiveCount
    Duration    = $result.Time
    Status      = if ($result.FailedCount -eq 0) { 'Passed' } else { 'Failed' }
}

$summary | Format-List

if ($result.FailedCount -gt 0) {
    exit 1
}
