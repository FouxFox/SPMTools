

$Script:FunctionToTest = 'Read-SPMTConfiguration'
$Script:Dependencies = @(
    'ConvertTo-HashTable'
)
$Script:FunctionLocation = GetFunctionLocation $Script:FunctionToTest

Function SuiteSetup {
    Import-Module $PSScriptRoot\InitTests.psm1
    #Set Variables
    $Script:ConfigLocation = "ConfigLocation"
    $Script:Config = $null

    TurnOffAutoLoading
    ForEach ($function in $Script:Dependencies) {
        . (GetFunctionLocation $function)
    }
    . $Script:FunctionLocation
}

Function SuiteCleanup {
    ResetAutoLoading
    Remove-Variable $Script:FunctionToTest -ErrorAction SilentlyContinue
}

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
    Expected Result: The default Configu
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