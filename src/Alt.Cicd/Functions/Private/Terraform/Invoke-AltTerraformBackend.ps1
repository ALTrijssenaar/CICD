function Invoke-AltTerraformBackend {
   [CmdletBinding(SupportsShouldProcess)]
   param (
      [Parameter(Mandatory = $true)]
      [string] $SourcesPath,
      [Parameter(Mandatory = $true)]
      [bool] $Upgrade
   )
   begin { . "$PSScriptRoot/../../begin.ps1" -InvocationInfo $MyInvocation }
   clean { . "$PSScriptRoot/../../clean.ps1" -InvocationInfo $MyInvocation }
   
   process {
      if (-not $PSCmdlet.ShouldProcess("Terraform: Initialize backend for [$SourcesPath]...")) {
         return
      }

      Write-AltLog -Message "Terraform: Initialize backend for [$SourcesPath]..." -Info
   
      if ($Upgrade) {
         Invoke-AltTerraformExecutable {
            terraform -chdir="$SourcesPath" init `
               -input=false `
               -reconfigure `
               -upgrade
         } -WhatIf:$false
      }
      else {
         Invoke-AltTerraformExecutable { 
            terraform -chdir="$SourcesPath" init `
               -input=false `
               -reconfigure `
         }  -WhatIf:$false
      }
   }
}