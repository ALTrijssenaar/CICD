# Part of the ForEach-Parallel functionality
if (-not (Get-Variable -Name Synchronized -Scope Global -ErrorAction SilentlyContinue)) {
   Set-Variable -Name Synchronized -Scope Global -Value ([hashtable]::Synchronized(@{})) -WhatIf:$false
}

function ForEachParallel {
   [CmdletBinding()]
   param (
      [parameter(Mandatory = $true, ValueFromPipeline = $true)]
      [Object[]]$Items,
      [parameter(Mandatory = $true)]
      [scriptblock]$ScriptBlock,
      [Object[]]$ArgumentList,
      [parameter(Mandatory = $false)]
      [int]$ThrottleLimit = 16,
      [parameter(Mandatory = $false)]
      [int]$WaitTimeout = (60 * 60 * 1000)
   )

   begin {
      $searchLocation = Join-Path -Path $PSScriptRoot -ChildPath '../../..'
      $moduleNames = Get-ChildItem -Path $searchLocation -Recurse -Include *.psm1 | ForEach-Object { $_.BaseName }

      # create the optional argument- & parameter-lists to be used in the script-block
      $arguments = ''
      $parameters = ''
      if ($ArgumentList) {
         for ($index = 0; $index -lt $ArgumentList.Length; $index++) {
            $arguments += ", `$$index"
            $parameters += " `$$index"
         }
      }

      # create the script-block to be executed
      # - the provided script-block is wrapped, so the provided arguments (ArgumentList) can be passed along with the current item ($_)
      # - the current module is always loaded
      $scriptText =
      @"
[CmdletBinding()]
param (`$ModuleNames,`$ErrorActionPreference,`$VerbosePreference,`$WhatIfPreference,`$EnrichLogging,`$Synchronized, `$_$arguments)

Set-StrictMode -Version Latest

`$global:ErrorActionPreference = `$ErrorActionPreference
`$global:VerbosePreference = `$VerbosePreference
`$global:WhatIfPreference = `$WhatIfPreference

`$saveVerbosePreference = `$global:VerbosePreference;
`$global:VerbosePreference = 'SilentlyContinue';
`$ModuleNames | ForEach-Object {
   Import-Module -Name `$_ -DisableNameChecking -Force
}
`$global:VerbosePreference = `$saveVerbosePreference;

function Wrapper {
$ScriptBlock
}

Wrapper $parameters
"@
      $sessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()

      # providing the current host makes the output of each runspace show up in the current host
      $pool = [runspacefactory]::CreateRunspacePool(1, $ThrottleLimit, $sessionState, $Host)
      $pool.Open()

      # create a new runspace for each item
      $runspaces = @()
      $asyncResults = @()
   }

   process {
      foreach ($item in $Items) {
         $runspace = [powershell]::create()
         $runspace.RunSpacePool = $pool
         $runspaces += $runspace

         $runspace.Streams.Error.add_DataAdded({
               param (
                  [object]$_sender
               )

               foreach ($s in $_sender.ReadAll()) {
                  throw $s.Exception.InnerException
               }
            })

         # add the generated script-block, passing the current item and optional arguments
         [void]$runspace.AddScript($scriptText)
         [void]$runspace.AddArgument($item)
         if ($ArgumentList) {
            [void]$runspace.AddParameters($ArgumentList)
         }
      
         # Pass the parameters
         $synchronized = Get-AltSynchronized
         [void]$runspace.AddParameter('Verbose', $VerbosePreference -eq 'Continue')
         [void]$runspace.AddParameter('ModuleNames', $moduleNames)
         [void]$runspace.AddParameter('Synchronized', $synchronized)
         [void]$runspace.AddParameter('ErrorActionPreference', $ErrorActionPreference)
         [void]$runspace.AddParameter('VerbosePreference', $VerbosePreference)
         [void]$runspace.AddParameter('WhatIfPreference', $WhatIfPreference)

         # Start the runspace synchronously
         $asyncResult = $runspace.BeginInvoke()
         $asyncResults += $asyncResult
      }
   }
   
   end {
      try {
         # wait for all runspaces to finish
         for ($index = 0; $index -lt $asyncResults.Length; $index++) {
            $null = [System.Threading.WaitHandle]::WaitAll($asyncResults[$index].AsyncWaitHandle, $WaitTimeout)
         }

         # retrieve the result of each runspace
         $exceptions = @()
         for ($index = 0; $index -lt $asyncResults.Length; $index++) {
            $asyncResult = $asyncResults[$index]
            $runspace = $runspaces[$index]

            # if needed, the following properties provide details of the runspace completion-status
            # $runspace.InvocationStateInfo.State
            # $runspace.InvocationStateInfo.Reason

            try {
               Write-Output ($runspace.EndInvoke($asyncResult))
            }
            catch {
               # collect each error, so they can be provided as a single error
               $exception = $_.Exception.InnerException.InnerException
               $exception.Data.Add('Item', $item)
               $exceptions += $exception
            }
         }
      }
      finally {
         <#Do this after the try block regardless of whether an exception occurred or not#>
         if ($pool) {
            $pool.Close()
         }
         if ($exceptions) {
            throw [System.AggregateException]::new("One or more errors occurred:", $exceptions)
         }
      }
   }
}