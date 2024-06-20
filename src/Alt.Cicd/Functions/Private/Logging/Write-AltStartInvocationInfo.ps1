function Write-AltStartInvocationInfo {
    [CmdletBinding()]
    param (
       [Parameter(Mandatory = $true)]
       [System.Management.Automation.InvocationInfo] $InvocationInfo
    )
 
    Write-AltLog -Message "> $($InvocationInfo.InvocationName)" -Trace
 
    $parametersDictionary = Get-DemoParameterValuesIncludingDefaultValues($InvocationInfo)
    foreach ($parameter in $parametersDictionary.GetEnumerator()) {
       $parameterValue = $parameter.Value
 
       if (($null -ne $parameterValue) -and ($parameterValue.GetType() -eq [ScriptBlock])) {
          $expandString = $ExecutionContext.InvokeCommand.ExpandString($parameterValue)
          Write-AltLog -Message ">`t-$($parameter.Key) `n{$expandString`n}" -Trace
       }
       else {
          Write-AltLog -Message ">`t-$($parameter.Key) $($parameterValue)" -Trace
       }
    }
 }