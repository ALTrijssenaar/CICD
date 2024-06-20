function Invoke-AltTerraformExecutable {
   [CmdletBinding(SupportsShouldProcess)]
   param (
      [Parameter(Mandatory = $true)]
      [scriptblock] $ScriptBlock
   )
   begin { . "$PSScriptRoot/../../begin.ps1" -InvocationInfo $MyInvocation }
   clean { . "$PSScriptRoot/../../clean.ps1" -InvocationInfo $MyInvocation }
    
   process {
      if ($PSCmdlet.ShouldProcess($ScriptBlock)) {
         Invoke-Command -ScriptBlock $ScriptBlock
         switch ( $LASTEXITCODE ) {
            0 { 
               Write-AltLog -Message "Succeeded, diff is empty (no changes)" -Trace
            }
            2 { 
               Write-AltLog -Message "Succeeded, there is a diff" -Trace
            }
            default { 
               throw [AsmlSharedException] "Detected a non zero exit code. The exit code was $LASTEXITCODE."
            }
         }
      }
   }
}