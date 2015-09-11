#Github Repo Upload Template Script

Quick and dirty repository init and github upload script.

##Description
This script requires git.exe in the path and is a quick and dirty hack that I should be partially ashamed of. But it saves me a little bit of time creating repositories for all my existing projects and uploading them to github.

##Files
**GuidedDeployment.ps1** - Asks a series of yes/no questions for each of the scripts in this repo. If you were to answer yes to them all you would: Create a new PowerShell Module template folder, Initialize a git repo for the folder and link to github, Run a best practices analysis against the folder, then upload it to the poweshell gallery.

**CreatePSModule.ps1** - Create a new PowerShell module template directory.

**CreateRepo.ps1** - Create a git repository out of a project folder and upload its contents to Github as the master branch.

**AnalyzeScript.ps1** - Requires PowerShell 5. Download and run the PSScriptAnalyzer module against your project folder.

**UploadToPowershellGallery.ps1** - Requires PowerShell 5. Upload a module into the powershellgallery.com site. You need the API key from https://www.powershellgallery.com/account in order to do this.

##Other Information
**Author:** Zachary Loeber

**Website:** http://www.the-little-things.net

**Github:** https:/github.com/zloeber/GithubRepoUploadTemplate
