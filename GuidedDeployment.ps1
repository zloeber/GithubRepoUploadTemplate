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
$ISModule = $false
$ProjectPath = ''
$ModuleName = ''

# Create a module template project directory
$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Create a new PowerShell Module."
$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Skip straight to publishing a folder to github"
$launchNewPoshModuleWizard = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
if (($host.ui.PromptForChoice('New PowerShell Module?', 'Create a new PowerShell module with basic template files?', $launchNewPoshModuleWizard, 0)) -eq 0) {
    Write-Output ''
    Write-Output 'Ok, next we need to create a new module directory.'
    Write-Output 'This script creates a module directory with the name of the PowerShell module in a base path you specify.'
    Write-Output 'So if your module will be called MyNewModule and you specify c:\projects as the base path. A new module folder'
    Write-Output 'will get created called c:\projects\MyNewModule.'
    Write-Output 'If that directory already exists we do nothing. The point is that you are not ever specifying a working project directory.'
    Write-Output 'This is meant for brand new module projects that you will then move existing projects into.'
    Write-Output ''
    do {
        do {
            $ModuleName = Read-Host -Prompt 'What is your short module name? (ie. TestModule)'
        } until (-not [string]::IsNullOrEmpty($ModuleName))
        do {
            $TargetDir = Read-Host -Prompt 'Target Directory (Directory must already exist. Directory does NOT include the module name.)'
        } until ((Test-Path $TargetDir))
        if ((Test-Path $TargetDir\$ModuleName)) {
            Write-Output ''
            Write-Output 'The combonation of the target directory and module name results in a directory which already exists!'
            Write-Output 'This script is only for brand new module template creation (as I have no desire to muck with a working project directory)!'
            Write-Output ''
        }
    } until (-not (Test-Path "$TargetDir\$ModuleName"))
    $ModuleAuthor = Read-Host -Prompt 'The module author'
    $ModuleDescription = Read-Host -Prompt 'A short module description'
    $ISModule = $true
    $ProjectPath = "$TargetDir\$ModuleName"
    . ./CreatePSModule.ps1 -ModulePath $ProjectPath -ModuleName $ModuleName -ModuleAuthor $ModuleAuthor -ModuleDescription $ModuleDescription
}

# Create and upload to github repository
$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Run git template wizard."
$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Do not run git template wizard"
$launchNewGithubWizard = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
if (($host.ui.PromptForChoice('Github?', 'Create a Git repo and link it to Github?', $launchNewGithubWizard, 0)) -eq 0) {
    Write-Output ''
    if ([string]::IsNullOrEmpty($ProjectPath)) {
        do {
            $ProjectPath = Read-Host -Prompt 'What is the full project path? (ie. C:\temp\MyTestModule)'
            if (-not (Test-Path $ProjectPath)) {
                Write-Warning "The path was not found. Please enter an existing project path!"
            }
        } until (Test-Path $ProjectPath)
        $ModuleName = Split-Path $ProjectPath -Leaf
        $ModuleAuthor = Read-Host -Prompt 'The module author'
        $ModuleDescription = Read-Host -Prompt 'A short module description'
    }
    $creategithubreposplat = @{
        'ProjectPath' = $ProjectPath
        'GitHubAuthor' = $ModuleAuthor
        'GithubTitle' = $ModuleName
        'GithubDesc' = $ModuleDescription
    }
    . .\CreateRepo.ps1 @creategithubreposplat
    Write-Output ''
}

# Analyze Script
$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Use PSScriptAnalyzer against project."
$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Do not run script analysis."
$launchScriptAnalysisWizard = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
if (($host.ui.PromptForChoice('Analyze Project?', 'Run PSScriptAnalyzer against your project?', $launchScriptAnalysisWizard, 0)) -eq 0) {
    if ([string]::IsNullOrEmpty($ProjectPath)) {
        do {
            $ProjectPath = Read-Host -Prompt 'What is the full project path? (ie. C:\temp\MyTestModule)'
            if (-not (Test-Path $ProjectPath)) {
                Write-Warning "The path was not found. Please enter an existing project path!"
            }
        } until (Test-Path $ProjectPath)
    }
    $analyzescriptsplat = @{
        'ProjectPath' = $ProjectPath
    }
    . ./AnalyzeScript.ps1 @analyzescriptsplat
}
Write-Output ''

# Upload to PowerShell Gallery
if ($ISModule) {
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Run the gallery upload wizard."
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Do not run gallery upload wizard"
    $launchNewGalleryUploadWizard = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
    if (($host.ui.PromptForChoice('Gallery?', 'Upload module to the powershell gallery?', $launchNewGalleryUploadWizard, 0)) -eq 0) {
        if ([string]::IsNullOrEmpty($ProjectPath)) {
            do {
                $ProjectPath = Read-Host -Prompt 'What is the full project path? (ie. C:\temp\MyTestModule)'
                if (-not (Test-Path $ProjectPath)) {
                    Write-Warning "The path was not found. Please enter an existing project path!"
                }
            } until (Test-Path $ProjectPath)
        }

        . ./UploadToPowershellGallery.ps1 -ModulePath $ProjectPath
    }
}