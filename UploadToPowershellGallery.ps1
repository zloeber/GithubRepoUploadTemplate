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
    [parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage='Path of module to upload.')]
    [string]$ModulePath,
    [parameter(Position=1, Mandatory=$true, HelpMessage='API key for the powershellgallery.com site.')]
    [string]$APIKey,
    [parameter(Position=2, Mandatory=$true, HelpMessage='Tags for your module.')]
    [string[]]$Tags,
    [parameter(Position=3, Mandatory=$true, HelpMessage='Project site (like github).')]
    [string]$ProjectURI
)
# This assumes you are running PowerShell 5
if ($PSVersionTable.PSVersion.Major -ge 5) {
    # Parameters for publishing the module
    $PublishParams = @{
        NuGetApiKey = $APIKey
        Path = $ModulePath
        ProjectUri = $ProjectURI
        Tags = $Tags
    }

    # ScriptAnalyzer passed! Let's publish
    Publish-Module @PublishParams
}
else {
    Write-Error 'This requires powershell version 5!'
}