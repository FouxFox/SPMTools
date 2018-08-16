#Taken from the CreateExoPSSession script packaged with the EXOPowershell Module

$script:MFAImplicitRemotingHandler = { 
    ${function:Get-PSImplicitRemotingSession} = {
        param(
            [Parameter(Mandatory = $true, Position = 0)]
            [string]
            $commandName
        )

        if (
            ($null -eq $script:PSSession) -or
            ($script:PSSession.Runspace.RunspaceStateInfo.State -ne 'Opened')
        ) {
            Set-PSImplicitRemotingSession `
                (& $script:GetPSSession `
                    -InstanceId $script:PSSession.InstanceId.Guid `
                    -ErrorAction SilentlyContinue )
        }
        if (
            ($null -ne $script:PSSession) -and
            ($script:PSSession.Runspace.RunspaceStateInfo.State -eq 'Disconnected')
        ) {
            # If we are handed a disconnected session, try re-connecting it before creating a new session.
            Set-PSImplicitRemotingSession `
                (& $script:ConnectPSSession `
                    -Session $script:PSSession `
                    -ErrorAction SilentlyContinue)
        }
        if (
            ($null -eq $script:PSSession) -or
            ($script:PSSession.Runspace.RunspaceStateInfo.State -ne 'Opened')
        ) {
            $Message = 'Creating a new session using MFA for implicit remoting of "{0}" command ...'
            Write-PSImplicitRemotingMessage ($Message -f $commandName)
            $session = Connect-ExchangeOnline -Company $global:ExoCompany -ReturnSession

            if ($null -ne $session) {
                Set-PSImplicitRemotingSession -CreatedByModule $true -PSSession $session
            }
        }
        if (
            ($null -eq $script:PSSession) -or
            ($script:PSSession.Runspace.RunspaceStateInfo.State -ne 'Opened')
        ) {
            throw 'No session has been associated with this implicit remoting module'
        }

        return [Management.Automation.Runspaces.PSSession]$script:PSSession
    }
}