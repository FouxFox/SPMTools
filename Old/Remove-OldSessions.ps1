Function Remove-OldSessions {
	[cmdletbinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [HashTable]$OnPremHosts,
		[Parameter(Mandatory=$true)]
        [String]$OnlineHost
    )
	$OldSessions = Get-PSSession | Where-Object {
		ForEach ($v in $OnPremHosts.Values) {
			if($v.ToLower() -eq $_.ComputerName.ToLower()) {
				return $true 
			}
			elseif($_.ComputerName.contains($OnlineHost)) {
				return $true
			}
			elseif($_.State -eq 'Broken') {
				return $true
			}
		}
	}
	if($OldSessions) {
		Remove-PSSession $OldSessions
	}
}