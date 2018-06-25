#Testing Variables
$Script:ModulePath = "$PSScriptRoot\..\SPMTools"

# Test Mode must be set before testing
$Env:SPMTools_TestMode = 1

#Functions
Import-Module $Script:ModulePath

#Test Suite
Describe SPMTools.Public.Export-ModuleMember {
    $PublicFunctions = @( Get-ChildItem -Path $Script:ModulePath\public\*.ps1 -Recurse)
    $ExportedFunctions = (Get-Module -ListAvailable $Script:ModulePath).ExportedCommands.Keys
    ForEach ($Function in $PublicFunctions) {
        $FunctionName = $Function.Name.Replace('.ps1','')
        It "Exports $FunctionName" {
            $ExportedFunctions.Contains($FunctionName) | Should be $true
        }
    }
}
