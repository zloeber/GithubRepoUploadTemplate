function New-CommentBasedHelp {
    <#
    .SYNOPSIS
        Create comment based help for a function.
    .DESCRIPTION
        Create comment based help for a function.
    .PARAMETER Code
        Multi-line or piped lines of code to process.
    .PARAMETER Advanced
        The default CBH result is good for most scenarios. Using this switch returns a more advanced CBH string.
    .EXAMPLE
       PS > $testfile = 'C:\temp\test.ps1'
       PS > $test = Get-Content $testfile -raw
       PS > $test | New-CommentBasedHelp | clip
       
       Description
       -----------
       Takes C:\temp\test.ps1 as input, creates basic comment based help and puts the result in the clipboard 
       to be pasted elsewhere for review.
    .EXAMPLE
        PS > $CBH = Get-Content 'C:\EWSModule\Get-EWSContact.ps1' -Raw | New-CommentBasedHelp -Verbose -Advanced
        PS > ($CBH | Where {$FunctionName -eq 'Get-EWSContact'}).CBH
        
        Description
        -----------
        Consumes Get-EWSContact.ps1 and generates advanced CBH templates for all functions found within. Print out to the screen the advanced
        CBH for just the Get-EWSContact function.
    .NOTES
       Author: Zachary Loeber
       Site: http://www.the-little-things.net/
       Requires: Powershell 3.0

       Version History
       1.0.0 - Initial release
    #>
    [CmdletBinding()]
    param(
        [parameter(Position=0, ValueFromPipeline=$true, HelpMessage='Lines of code to process.')]
        [string[]]$Code,
        [parameter(Position=0, HelpMessage='The default CBH result is good for most scenarios. Using this switch returns a more advanced CBH string.')]
        [switch]$Advanced
    )
    begin {
        $FunctionName = $MyInvocation.MyCommand.Name
        Write-Verbose "$($FunctionName): Begin."
        
        function Get-FunctionParameters {
            <#
            .SYNOPSIS
                Return all parameters for each function found in a code block.
            .DESCRIPTION
                Return all parameters for each function found in a code block.
            .PARAMETER Code
                Multi-line or piped lines of code to process.
            .EXAMPLE
               PS > $testfile = 'C:\temp\test.ps1'
               PS > $test = Get-Content $testfile -raw
               PS > $test | Get-FunctionParameters | clip
               
               Description
               -----------
               Takes C:\temp\test.ps1 as input, remove statement separators and puts the result in the clipboard 
               to be pasted elsewhere for review.

            .NOTES
               Author: Zachary Loeber
               Site: http://www.the-little-things.net/
               Requires: Powershell 3.0

               Version History
               1.0.0 - Initial release
            #>
            [CmdletBinding()]
            param(
                [parameter(Position=0, ValueFromPipeline=$true, HelpMessage='Lines of code to process.')]
                [string[]]$Code
            )
            begin {
                #Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
                $FunctionName = $MyInvocation.MyCommand.Name
                Write-Verbose "$($FunctionName): Begin."
                
                $Codeblock = @()
                $ParseError = $null
                $Tokens = $null

                # These are essentially our AST filters
                $functionpredicate = { ($args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]) }
                $parampredicate = { ($args[0] -is [System.Management.Automation.Language.ParameterAst]) }
                $typepredicate = { ($args[0] -is [System.Management.Automation.Language.TypeConstraintAst]) }
                $paramattributes = { ($args[0] -is [System.Management.Automation.Language.NamedAttributeArgumentAst]) }
                $output = @()

            }
            process {
                $Codeblock += $Code
            }
            end {
                $ScriptText = $Codeblock | Out-String
                Write-Verbose "$($FunctionName): Attempting to parse AST."

                $AST = [System.Management.Automation.Language.Parser]::ParseInput($ScriptText, [ref]$Tokens, [ref]$ParseError) 
         
                if($ParseError) {
                    $ParseError | Write-Error
                    throw "$($FunctionName): Will not work properly with errors in the script, please modify based on the above errors and retry."
                }

                $functions = $ast.FindAll($functionpredicate, $true)
                
                # get the begin and end positions of every for loop
                foreach ($function in $functions) {
                    Write-Verbose "$($FunctionName): Processing function - $($function.Name.ToString())"
                    $Parameters = $function.FindAll($parampredicate, $true)
                    foreach ($p in $Parameters) {
                        $ParamType = $p.FindAll($typepredicate, $true)
                        Write-Verbose "$($FunctionName): Processing Parameter of type [$($ParamType.typeName.FullName)] - $($p.Name.VariablePath.ToString())"
                        $OutProps = @{
                            'FunctionName' = $function.Name.ToString()
                            'ParameterName' = $p.Name.VariablePath.ToString()
                            'ParameterType' = $ParamType[0].typeName.FullName
                        }
                        $p.FindAll($paramattributes, $true) | Foreach {
                            $OutProps.($_.ArgumentName) = $_.Argument.Value
                        }
                        $Output += New-Object -TypeName PSObject -Property $OutProps
                    }
                }

                $Output
                Write-Verbose "$($FunctionName): End."
            }
        }
        $CBH_PARAM = @'
.PARAMETER %%PARAM%%
%%PARAMHELP%%
'@

        $FullCBH = @'
<#
.SYNOPSIS
    A brief description of the function or script.

.DESCRIPTION
    A detailed description of the function or script.

%%PARAMETER%%
.EXAMPLE

.EXAMPLE

.EXAMPLE

.INPUTS
    The Microsoft .NET Framework types of objects that can be piped to the
    function or script. You can also include a description of the input
    objects.

.OUTPUTS
    The .NET Framework type of the objects that the cmdlet returns. You can
    also include a description of the returned objects.

.NOTES
    Additional information about the function or script.

.LINK

.LINK

.COMPONENT
    The technology or feature that the function or script uses, or to which
    it is related.

.ROLE
    The user role for the help topic. This content appears when the Get-Help
    command includes the Role parameter of Get-Help.

.FUNCTIONALITY
    The intended use of the function. This content appears when the Get-Help
    command includes the Functionality parameter of Get-Help.

.FORWARDHELPTARGETNAME <Command-Name>
    Redirects to the help topic for the specified command. You can redirect
    users to any help topic, including help topics for a function, script,
    cmdlet, or provider.

.FORWARDHELPCATEGORY  <Category>
    Specifies the help category of the item in ForwardHelpTargetName.
    Valid values are Alias, Cmdlet, HelpFile, Function, Provider, General,
    FAQ, Glossary, ScriptCommand, ExternalScript, Filter, or All. Use this
    keyword to avoid conflicts when there are commands with the same name.

.REMOTEHELPRUNSPACE <PSSession-variable>
    Specifies a session that contains the help topic. Enter a variable that
    contains a PSSession. This keyword is used by the Export-PSSession
    cmdlet to find the help topics for the exported commands.

.EXTERNALHELP  <XML Help File>
    Specifies an XML-based help file for the script or function.

    The ExternalHelp keyword is required when a function or script
    is documented in XML files. Without this keyword, Get-Help cannot
    find the XML-based help file for the function or script.

    The ExternalHelp keyword takes precedence over other comment-based
    help keywords. If ExternalHelp is present, Get-Help does not display
    comment-based help, even if it cannot find a help topic that matches
    the value of the ExternalHelp keyword.

    If the function is exported by a module, set the value of the
    ExternalHelp keyword to a file name without a path. Get-Help looks for
    the specified file name in a language-specific subdirectory of the module
    directory. There are no requirements for the name of the XML-based help
    file for a function, but a best practice is to use the following format:
    <ScriptModule.psm1>-help.xml

    If the function is not included in a module, include a path to the
    XML-based help file. If the value includes a path and the path contains
    UI-culture-specific subdirectories, Get-Help searches the subdirectories
    recursively for an XML file with the name of the script or function in
    accordance with the language fallback standards established for Windows,
    just as it does in a module directory.

    For more information about the cmdlet help XML-based help file format,
    see "How to Create Cmdlet Help" in the MSDN (Microsoft Developer Network)
    library at http://go.microsoft.com/fwlink/?LinkID=123415.
#>
'@

        $BasicCBH = @'
<#
.SYNOPSIS

.DESCRIPTION

%%PARAMETER%%
.EXAMPLE

.EXAMPLE

.EXAMPLE

.INPUTS

.OUTPUTS

.NOTES

.LINK

.LINK

#>
'@

        $Codeblock = @()
        $CBHResults = @()
    }
    process {
        $Codeblock += $Code
    }
    end {
        $ScriptText = $Codeblock | Out-String
        Write-Verbose "$($FunctionName): Attempting to parse parameters."
        $AllParams = Get-FunctionParameters -Code $Codeblock | Sort-Object -Property FunctionName
        $AllFunctions = @($AllParams.FunctionName | Select -unique)
        
        foreach ($f in $AllFunctions) {
            $OutCBH = @{}
            $OutCBH.'FunctionName' = $f
            [string]$OutParams = ''
            $fparams = @($AllParams | Where {$_.FunctionName -eq $f} | Sort-Object -Property Position)
            $fparams | foreach {
                $ParamHelpMessage = if ([string]::IsNullOrEmpty($_.HelpMessage)) {"`n`r"} else {"`t" + $_.HelpMessage + "`n`r`n`r"}
                $OutParams += $CBH_PARAM -replace '%%PARAM%%',$_.ParameterName -replace '%%PARAMHELP%%',$ParamHelpMessage
            }
            if ($Advanced) {
                $OutCBH.'CBH' = $FullCBH -replace '%%PARAMETER%%',$OutParams
            }
            else {
                $OutCBH.'CBH' = $BasicCBH -replace '%%PARAMETER%%',$OutParams
            }
            New-Object PSObject -Property $OutCBH
        }

        Write-Verbose "$($FunctionName): End."
    }
}