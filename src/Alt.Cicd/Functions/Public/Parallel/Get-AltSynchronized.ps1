function Get-AltSynchronized {
   return (Get-Variable -Name Synchronized -Scope Global).Value
}