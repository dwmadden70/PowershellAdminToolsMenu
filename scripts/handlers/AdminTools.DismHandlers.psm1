# Executes a prepared DISM argument list. The caller supplies shared services
# through Context so this module does not need to import the menu's logger.
function Invoke-DismCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string[]]$Arguments,

        [Parameter(Mandatory)]
        [hashtable]$Context
    )

    $logPath = $Context.LogPath
    $writeLog = $Context.WriteLog

    # Resolve the executable before invoking it so a missing Windows tool gets
    # a useful application error instead of a less clear command-not-found error.
    $dismCommand = Get-Command -Name 'dism.exe' -CommandType Application -ErrorAction SilentlyContinue
    if ($null -eq $dismCommand) {
        $message = 'DISM was not found on this system. Verify that dism.exe is available in the Windows system path.'
        & $writeLog -Message $message -Path $logPath -NoConsole
        Write-Host $message -ForegroundColor Red
        return [pscustomobject]@{
            ExitCode = 1
            Output   = @($message)
        }
    }

    Write-Host "`nRunning DISM command..." -ForegroundColor Cyan
    Write-Host ("{0} {1}" -f $dismCommand.Name, ($Arguments -join ' ')) -ForegroundColor DarkGray

    $output = [System.Collections.Generic.List[string]]::new()
    try {
        # The native command's output is streamed through the pipeline. 2>&1
        # combines stderr with stdout so errors are logged with other output.
        & $dismCommand.Source @Arguments 2>&1 | ForEach-Object {
            $line = [string]$_
            $output.Add($line)

            if ($line -match '(\d+(?:\.\d+)?)%') {
                $percentComplete = [math]::Min(100, [math]::Max(0, [double]$Matches[1]))
                & $writeLog -Message $line -Path $logPath -NoConsole
                Write-Progress -Activity 'DISM operation in progress' -Status ("{0:N1}% complete" -f $percentComplete) -PercentComplete $percentComplete
            }
            else {
                & $writeLog -Message $line -Path $logPath -NoConsole
            }
        }
        $exitCode = $LASTEXITCODE
    }
    finally {
        # finally runs even when output processing or logging throws, ensuring
        # an interrupted operation cannot leave a stale progress display.
        Write-Progress -Activity 'DISM operation in progress' -Completed
    }

    if ($exitCode -eq 0) {
        Write-Host 'DISM completed successfully.' -ForegroundColor Green
    }
    else {
        Write-Host "DISM did not complete successfully. Exit code: $exitCode" -ForegroundColor Red
    }

    return [pscustomobject]@{
        # Returning an object keeps the native exit code and captured output
        # available to the menu without making callers parse console text.
        ExitCode = $exitCode
        Output   = $output.ToArray()
    }
}

# Converts a menu action and image target into the corresponding DISM switches.
# This keeps menu code independent from the command-line syntax.
function Invoke-DismAction {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Action,

        [Parameter(Mandatory)]
        [string]$ImageType,

        [string]$ImagePath,

        [Parameter(Mandatory)]
        [hashtable]$Context
    )

    $arguments = @()

    switch ($ImageType) {
        'online' {
            $arguments += '/Online'
        }
        'offline' {
            if ([string]::IsNullOrWhiteSpace($ImagePath)) {
                Write-Host 'An offline image path is required.' -ForegroundColor Red
                return $null
            }
            $arguments += '/Image:' + $ImagePath
        }
        default {
            Write-Host 'Invalid image type selected.' -ForegroundColor Red
            return $null
        }
    }

    $arguments += '/Cleanup-Image'

    switch ($Action) {
        'checkhealth' {
            $arguments += '/CheckHealth'
        }
        'restorehealth' {
            $arguments += '/RestoreHealth'
        }
        'componentcleanup' {
            $arguments += '/StartComponentCleanup'
        }
        default {
            Write-Host "Unsupported DISM action: $Action" -ForegroundColor Red
            return $null
        }
    }

    return Invoke-DismCommand -Arguments $arguments -Context $Context
}

Export-ModuleMember -Function Invoke-DismCommand, Invoke-DismAction
