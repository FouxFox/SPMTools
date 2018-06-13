#Set Variables
$Script:ModuleName = "SPMTools"
$Script:LoadingPreference = $false

$PublicFunctions = @( Get-ChildItem -Path .\SPMTools\public\*.ps1 -Recurse -ErrorAction SilentlyContinue )
$PrivateFunctions = @( Get-ChildItem -Path .\SPMTools\Private\Functions\*.ps1 -ErrorAction SilentlyContinue )
$AllFunctions = $PublicFunctions + $PrivateFunctions
$Script:FunctionLocations = @{}
ForEach ($function in $AllFunctions) {
	$Script:FunctionLocations.Add($function.Name.Split('.')[0],$function.Fullname)
}

Function GetFunctionLocation ($inputObj) {
	$Script:FunctionLocations[$inputObj]
}

Function TurnOffAutoLoading {
	if($PSModuleAutoLoadingPreference) {
		$Script:LoadingPreference = $PSModuleAutoLoadingPreference
	}
	$PSModuleAutoLoadingPreference = 'none'
}

Function ResetAutoLoading {
	if($Script:LoadingPreference) {
		$PSModuleAutoLoadingPreference = $Script:LoadingPreference
	}
	else {
		$PSModuleAutoLoadingPreference = $null
	}
}

#Pull existing module if loaded
Remove-Module -ErrorAction SilentlyContinue -Name SPMTools