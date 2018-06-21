#Testing Variables
$Script:ModulePath = "$PSScriptRoot\..\SPMTools"

# Test Mode must be set before testing
 $Env:SPMTools_TestMode = 1

#Functions
Import-Module $Script:ModulePath


#Test Suite
Describe SPMTools.Public.Get-TranslatedSid {
    InModuleScope SPMTools {
        It 'Should translate a SID' {
            Get-TranslatedSid 'S-1-5-7' | Should be 'NT AUTHORITY\ANONYMOUS LOGON'
        }
    }
}

#Cleanup
$Env:SPMTools_TestMode = 0
Remove-Module SPMTools