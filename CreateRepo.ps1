function Get-ScriptPath {
	$scriptDir = Get-Variable PSScriptRoot -ErrorAction SilentlyContinue | ForEach-Object { $_.Value }
	if (!$scriptDir) {
		if ($MyInvocation.MyCommand.Path) {
			$scriptDir = Split-Path $MyInvocation.MyCommand.Path -Parent
		}
	}
	if (!$scriptDir) {
		if ($ExecutionContext.SessionState.Module.Path) {
			$scriptDir = Split-Path (Split-Path $ExecutionContext.SessionState.Module.Path)
		}
	}
	if (!$scriptDir) {
		$scriptDir = $PWD
	}
	
	return $scriptDir
}

$Author = 'Zachary Loeber'
$Website = 'http://www.the-little-things.net'

$ScriptPath = Get-ScriptPath

Write-Output '-- Quick Git repository creation and upload to Github build tool --'
Write-Output "-- Running in $($ScriptPath)"

$TargetDir = Read-Host -Prompt 'Target Directory'
$GithubRepo = Read-Host -Prompt 'Github Repository upload url (ie. https://github.com/zloeber/GithubRepoUploadTemplate.git)'
$GithubTitle = Read-Host -Prompt 'Github readme title'
$GithubIntro = Read-Host -Prompt 'Github readme introduction text'
$GithubDesc = Read-Host -Prompt 'Github readme description text'
$GithubAuthor = Read-Host -Prompt 'Github readme author'
$AuthorWebsite = Read-Host -Prompt 'Github readme author website'

if (Test-Path $TargetDir) {
    if (-not [string]::isnullorempty($GithubAuthor)) {
        $Author = $GithubAuthor
    }
    if (-not [string]::isnullorempty($AuthorWebsite)) {
        $Website = $AuthorWebsite
    }

    [string]$readme = [IO.File]::ReadAllText("$($ScriptPath)\templates\readme.md")

    $readme = $readme -replace '%%Title%%', $GithubTitle `
                      -replace '%%Intro%%', $GithubIntro `
                      -replace '%%Description%%', $GithubDesc `
                      -replace '%%Author%%', $Author `
                      -replace '%%Website%%', $Website `
                      -replace '%%githubsite%%', ($GithubRepo -replace '.git','')

    $readme | Out-File -FilePath ($TargetDir + '\readme.md')
    Copy-Item -Path "$($ScriptPath)\templates\.gitattributes" -Destination $TargetDir
    Copy-Item -Path "$($ScriptPath)\templates\.gitignore" -Destination $TargetDir

    cd $TargetDir
    git init
    git add .
    git commit -m 'First Commit'
    git remote add origin $GithubRepo
    git remote -v
    git push origin master
    cd $ScriptPath
}
else {
    Write-Warning "Target project directory was not found: $TargetDir"
}