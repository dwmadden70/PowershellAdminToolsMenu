[CmdletBinding()]
param()

$testPath = Join-Path $PSScriptRoot 'Run-AdminTools.Tests.ps1'
$result = Invoke-Pester -Path $testPath -Quiet -PassThru

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
