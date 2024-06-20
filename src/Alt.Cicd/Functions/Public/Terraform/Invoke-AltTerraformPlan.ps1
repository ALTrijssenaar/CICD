function Invoke-AltTerraformPlan {
   [CmdletBinding(SupportsShouldProcess)]
   param (
      [Parameter(Mandatory = $true)]
      [string] $VariablesFilePath,
      [Parameter(Mandatory = $true)]
      [string] $SourcesPath,
      [Parameter(Mandatory = $false)]
      [int] $Parallelism = 100,
      [Parameter(Mandatory = $false)]
      [switch] $Destroy
   )
   begin { . "$PSScriptRoot/../../begin.ps1" -InvocationInfo $MyInvocation }
   clean { . "$PSScriptRoot/../../clean.ps1" -InvocationInfo $MyInvocation }

   process {
      $synchronized = Get-AltSynchronized
      Invoke-AltTerraformBackend -SourcesPath $SourcesPath -Upgrade:$($synchronized.AutoUpgradeTerraform)

      $name = [System.IO.Path]::GetFileNameWithoutExtension($VariablesFilePath)
      $tfPlan = Get-AltTerraformPlanLocation -Name $name -Destroy:$($Destroy.IsPresent)

      if (Test-Path -PathType Leaf -Path $tfPlan) {
         Write-AltLog -Message "Removing old plan in [$tfPlan] before generating a new one"
         Remove-Item -Path $tfPlan -WhatIf:$false | Out-Null
      }
      $tfPlanFolder = $tfPlan | Split-Path -Parent
      if (-not (Test-Path -PathType Container -Path $tfPlanFolder)) {
         New-Item -Path $tfPlanFolder -ItemType Directory -WhatIf:$false | Out-Null
      }

      $lock = "-lock=false"
      if ($PSCmdlet.ShouldProcess('Lock environment')) {
         $lock = "-lock=true"
      }
      $parallel = "-parallelism=$Parallelism" 

      if ($Destroy.IsPresent) {
         Write-AltLog -Message "Determining a plan for destroying the environment..." -Info -HighLight
           
         Invoke-AltTerraformExecutable -WhatIf:$false {
            terraform -chdir="$SourcesPath" plan $parallel $lock -detailed-exitcode -compact-warnings -destroy -var-file="$VariablesFilePath" -out "$tfPlan"
         }
      }
      else {
         Write-AltLog -Message "Determining a plan for creating the environment" -Info -HighLight

         Invoke-AltTerraformExecutable -WhatIf:$false {
            terraform -chdir="$SourcesPath" plan $parallel $lock -detailed-exitcode -compact-warnings -var-file="$VariablesFilePath" -out "$tfPlan"
         }
      }
      Write-AltLog -Message "Determined a plan for [$SourcesPath] in [$tfPlan]" -Info
   }
}