#Testing Variables
$Script:FunctionToTest = 'Read-SPMTConfiguration'
$Script:Dependencies = @(
    'ConvertTo-HashTable'
)

#Inital Setup
Remove-Module InitTests -ErrorAction SilentlyContinue
Import-Module $PSScriptRoot\InitTests.psm1
$Script:FunctionLocation = GetFunctionLocation $Script:FunctionToTest
ForEach ($function in $Script:Dependencies) {
    . (GetFunctionLocation $function)
}
. $Script:FunctionLocation

#Functions
Function SuiteSetup {
    
    #Set Variables
    $Script:ConfigLocation = "ConfigLocation"
    $Script:Config = $null

    TurnOffAutoLoading
}

Function SuiteCleanup {
    ResetAutoLoading
    Remove-Variable $Script:FunctionToTest -ErrorAction SilentlyContinue
}


#Tests
Describe SPMTools.Private.Read-SPMTConfiguration {
    BeforeAll {
        SuiteSetup
    }

    AfterAll {
        SuiteCleanup
    }

    <#
    Purpose:         Converts the Configuration from JSON to a HashTable
    Action:          Read-SPMTConfiguration
    Expected Result: ConvertTo-HashTable is loaded into $Script:Config
    #>

    Context 'Read Default Configuration' {

        #Mock Methods
        Mock Get-Content -Verifiable -ParameterFilter { $Path -eq $Script:ConfigLocation} { return "Get-Content" }
        Mock ConvertFrom-Json -Verifiable -ParameterFilter { $InputObject -eq "Get-Content" } { return "ConvertFrom-Json" }
        Mock ConvertTo-HashTable -Verifiable -ParameterFilter { $root -eq "ConvertFrom-Json" } { return "ConvertTo-HashTable" }

        #Run Function
        $Output = Read-SPMTConfiguration

        It 'Returns the proper value to $Script:Config' {
            $Script:Config | Should be 'ConvertTo-HashTable'
        }
        It 'Outputs nothing' {
            $Output | Should be $null
        }
        It 'Calls all mocked functions' {
            Assert-VerifiableMocks
        }
    }
}