function Get-AltTerraformPlanLocation {
   [CmdletBinding()]
   param (
      [Parameter(Mandatory = $true)]
      [string] $Name,
      [Parameter(Mandatory = $false)]
      [switch] $Destroy
   )
   begin { . "$PSScriptRoot/../../begin.ps1" -InvocationInfo $MyInvocation }
   clean { . "$PSScriptRoot/../../clean.ps1" -InvocationInfo $MyInvocation }

   process {
      $tfPlanFileName = "${Name}.plan"
      if ($Destroy) {
         $tfPlanFileName = "create-$tfPlanFileName"
      }
      else {
         $tfPlanFileName = "deploy-$tfPlanFileName"
      }

      $synchronized = Get-AltSynchronized
      return Join-Path -Path $synchronized.ArtifactPath -ChildPath $tfPlanFileName
   }
}