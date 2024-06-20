function Get-AltFilesPath {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $false)]
    [string] $ChildPath
  )

  $path = Join-Path -Path $PSScriptRoot -ChildPath '../../../Files'
  if ($null -ne $ChildPath) {
    $path = Join-Path -Path $path -ChildPath $ChildPath
  }

  if (-not (Test-Path -Path $path)) {
    New-Item -Path $path -ItemType Directory -WhatIf:$false
  }
 
  return ($path | Resolve-Path).Path
}