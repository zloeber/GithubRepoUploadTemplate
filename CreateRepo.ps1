<#
    .SYNOPSIS
        
    .DESCRIPTION
        
    .PARAMETER ModulePath
    
    .PARAMETER APIKey
        
    .PARAMETER Tags
    
    .PARAMETER ProjectURI
        
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
    [parameter(Mandatory=$true, HelpMessage='Path of project to make into a repo.')]
    [string]$ProjectPath,
    [parameter(Position=1, Mandatory=$true, HelpMessage='Github readme Author.')]
    [string]$GithubAuthor,
    [parameter(Position=2, Mandatory=$true, HelpMessage='Github readme author website')]
    [string]$AuthorWebsite,
    [parameter(Position=3, Mandatory=$true, HelpMessage='Github readme title')]
    [string]$GithubTitle,
    [parameter(Position=4, Mandatory=$true, HelpMessage='Github readme description text')]
    [string]$GithubDesc,
    [parameter(Position=5, Mandatory=$true, HelpMessage='Github readme introduction text')]
    [string]$GithubIntro,
    [parameter(Position=6, Mandatory=$true, HelpMessage='Github Repository upload url (ie. https://github.com/zloeber/GithubRepoUploadTemplate.git)')]
    [string]$GithubRepo
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

$ScriptPath = if (Split-Path $MyInvocation.MyCommand.Path -Parent) {Split-Path $MyInvocation.MyCommand.Path -Parent} else {$PWD}

if (Test-Path $ProjectPath) {
    [string]$readme = [IO.File]::ReadAllText("$($ScriptPath)\templates\readme.md")
    $readme = $readme -replace '%%Title%%', $GithubTitle `
                      -replace '%%Intro%%', $GithubIntro `
                      -replace '%%Description%%', $GithubDesc `
                      -replace '%%Author%%', $GithubAuthor `
                      -replace '%%Website%%', $AuthorWebsite `
                      -replace '%%githubsite%%', ($GithubRepo -replace '.git','')

    $readme | Out-File -FilePath ($ProjectPath + '\readme.md')
    Copy-Item -Path "$($ScriptPath)\templates\.gitattributes" -Destination $ProjectPath
    Copy-Item -Path "$($ScriptPath)\templates\.gitignore" -Destination $ProjectPath

    cd $ProjectPath
    git init
    git add .
    git commit -m 'First Commit'
    git remote add origin $GithubRepo
    git remote -v
    git push origin master
    cd $ScriptPath
}
else {
    Write-Warning "Target project directory was not found: $ProjectPath"
}