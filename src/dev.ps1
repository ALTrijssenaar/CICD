Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ($IsLinux) {
   $env:PSModulePath = "$($env:PSModulePath):$PSScriptRoot"
}
if ($IsWindows) {
   $env:PSModulePath = "$($env:PSModulePath);$PSScriptRoot"
}


Import-Module -Name Alt.Cicd
$synchronized = Get-AltSynchronized
$synchronized.ArtifactPath = Get-AltRepoPath -ChildPath 'build/Artifacts'
$synchronized.TempPath = Get-AltRepoPath -ChildPath 'build/Tmp'
$synchronized.AutoUpgradeTerraform = $true

$env:TF_VAR_token = ''
$env:TF_VAR_owner = 'Trijssenaar'

'training-repositories', 'gdex-repositories' | ForEach-Object {
   $sourcesPath = Get-AltFilesPath -ChildPath "terraform/$_"
   $variablesFilePath = Join-Path -Path $PSScriptRoot -ChildPath "$_.json"
   Invoke-AltTerraformPlan -VariablesFilePath $variablesFilePath -SourcesPath $sourcesPath
}


