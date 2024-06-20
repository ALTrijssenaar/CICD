param (
    [Parameter(Mandatory = $true)]
    [System.Management.Automation.InvocationInfo] $InvocationInfo
)

if ($VerbosePreference -ne "Continue") {
    return
}

Write-AltEndInvocationInfo -InvocationInfo $InvocationInfo -Stopwatch $stopwatch