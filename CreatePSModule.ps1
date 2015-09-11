<#
    .SYNOPSIS
        
    .DESCRIPTION
        
    .PARAMETER ModulePath
    
    .PARAMETER ModuleName
        
    .PARAMETER ModuleDescription
    
    .PARAMETER ModuleAuthor
        
    .EXAMPLE

    .NOTES
       Author: Zachary Loeber
       Site: http://www.the-little-things.net/
       Requires: Powershell 5.0

       Version History
       1.0.0 - Initial release
    #>
[CmdletBinding()]
param(
    [parameter(Mandatory=$true, HelpMessage='Path to create module template.')]
    [string]$ModulePath,
    [parameter(Position=1, Mandatory=$true, HelpMessage='Module name.')]
    [string]$ModuleName,
    [parameter(Position=2, Mandatory=$true, HelpMessage='Module description.')]
    [string]$ModuleDescription,
    [parameter(Position=3, Mandatory=$true, HelpMessage='Module author.')]
    [string]$ModuleAuthor
)

function Get-ScriptPath {
	$scriptDir = Get-Variable PSScriptRoot -ErrorAction SilentlyContinue | ForEach-Object { $_.Value }
	if (-not $scriptDir) {
		if ($MyInvocation.MyCommand.Path) {
			$scriptDir = Split-Path $MyInvocation.MyCommand.Path -Parent
		}
	}
	if (-not $scriptDir) {
		if ($ExecutionContext.SessionState.Module.Path) {
			$scriptDir = Split-Path (Split-Path $ExecutionContext.SessionState.Module.Path)
		}
	}
	if (!$scriptDir) {
		$scriptDir = $PWD
	}
	
	$scriptDir
}

$ScriptPath = Get-ScriptPath

# Create the module and private function directories
mkdir $ModulePath
mkdir $ModulePath\src\private
mkdir $ModulePath\src\public
mkdir $ModulePath\lib
mkdir $ModulePath\bin
mkdir $ModulePath\tests
mkdir $ModulePath\en-US
mkdir $ModulePath\build

#Create the module and related files
Copy-Item -Path "$($ScriptPath)\templates\Module.psm1" -Destination "$ModulePath\$($ModuleName).psm1"

[string]$AboutHelp = [IO.File]::ReadAllText("$ScriptPath\templates\about_.help.txt")
$AboutHelp = $AboutHelp -replace '%%ModuleName%%', $ModuleName -replace '%%ModuleDescription%%', $ModuleDescription
$AboutHelp | Out-File -FilePath "$ModulePath\en-US\about_$($ModuleName).help.txt"

New-Item "$ModulePath\tests\$($ModuleName).Tests.ps1" -ItemType File
New-Item "$ModulePath\$($ModuleName).Format.ps1xml" -ItemType File

New-ModuleManifest -Path $ModulePath\$ModuleName.psd1 `
                   -RootModule $ModulePath\$ModuleName.psm1 `
                   -Description $ModuleDescription `
                   -PowerShellVersion 3.0 `
                   -Author $ModuleAuthor `
                   -FormatsToProcess "$ModuleName.Format.ps1xml"

Write-Output ''
Write-Output '--==={ SOME NOTES }===--'
Write-Output "Copy public functions for this module into: $ModulePath\public"
Write-Output "Copy private functions for this module into: $ModulePath\private"
Write-Output "Copy dll files for this module into: $ModulePath\lib"
Write-Output "Copy executable files for this module into: $ModulePath\bin"
Write-Output "A blank unit test file can be edited here: $ModulePath\tests\$($ModuleName).Tests.ps1"
Write-Output "A blank custom formats can be edited here: $ModulePath\$($ModuleName).Format.ps1xml"
Write-Output "A template general help file should be updated here: $ModulePath\en-US\about_$($ModuleName).help.txt"
Write-Output ''