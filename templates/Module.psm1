#region Private Variables
# Current script path
[string]$ScriptPath = Split-Path (get-variable myinvocation -scope script).value.Mycommand.Definition -Parent
#endregion Private Variables

#region Methods
Get-ChildItem $ScriptPath/src/private -Recurse -Filter "*.ps1" -File | Foreach { 
    Write-Output "Dot sourcing private function: $($_.Name)"
    . $_.FullName
}

# Load and export methods
Get-ChildItem $ScriptPath/src/public -Recurse -Filter "*.ps1" -File | Foreach { 
    Write-Output "Dot sourcing public function file: $($_.Name)"
    . $_.FullName

    # Find all the functions defined no deeper than the first level deep and export it.
    # This looks ugly but allows us to not keep any uneeded variables in memory that are not related to the module.
    ([System.Management.Automation.Language.Parser]::ParseInput((Get-Content -Path $_.FullName -Raw), [ref]$null, [ref]$null)).FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false) | Foreach {
        Export-ModuleMember $_.Name
    }
}
#endregion Methods

#region Module Cleanup
$ExecutionContext.SessionState.Module.OnRemove = {
    # cleanup when unloading module (if any)
}
#endregion Module Cleanup