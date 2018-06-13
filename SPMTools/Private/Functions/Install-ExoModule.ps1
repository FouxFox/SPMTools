#Adapted from https://www.powershellgallery.com/packages/Load-ExchangeMFA

function Install-EXOModule {
    [CmdletBinding()] 
    Param()

    $Manifest = "https://cmdletpswmodule.blob.core.windows.net/exopsmodule/Microsoft.Online.CSE.PSModule.Client.application"
    $ElevatePermissions = $true
        Try { 
            Add-Type -AssemblyName System.Deployment
            
            Write-Verbose "Start installation of ClockOnce Application $Manifest "
    
            $RemoteURI = [URI]::New( $Manifest , [UriKind]::Absolute)
    
            $HostingManager = New-Object System.Deployment.Application.InPlaceHostingManager -ArgumentList $RemoteURI , $False
        
            #register an event to trigger custom event (yep, its a hack)
            Register-ObjectEvent -InputObject $HostingManager -EventName GetManifestCompleted -Action { 
                new-event -SourceIdentifier "ManifestDownloadComplete"
            } | Out-Null
            #register an event to trigger custom event (yep, its a hack)
            Register-ObjectEvent -InputObject $HostingManager -EventName DownloadApplicationCompleted -Action { 
                new-event -SourceIdentifier "DownloadApplicationCompleted"
            } | Out-Null
    
            #get the Manifest
            $HostingManager.GetManifestAsync()
    
            #Waitfor up to 5s for our custom event
            $ManifestEvent = Wait-Event -SourceIdentifier "ManifestDownloadComplete" -Timeout 5
            if ($ManifestEvent) {
                $ManifestEvent | Remove-Event
                Write-Verbose "ClickOnce Manifest Download Completed"
    
                $HostingManager.AssertApplicationRequirements($ElevatePermissions)
                #todo :: can this fail ?
                
                #Download Application
                $HostingManager.DownloadApplicationAsync()
                #register and wait for completion event
                # $HostingManager.DownloadApplicationCompleted
                $DownloadEvent = Wait-Event -SourceIdentifier "DownloadApplicationCompleted" -Timeout 15
                if ($DownloadEvent) {
                    $DownloadEvent | Remove-Event
                    Write-Verbose "ClickOnce Application Download Completed"
                } else {
                    Write-error "ClickOnce Application Download did not complete in time (15s)"
                }
            } else {
               Write-error "ClickOnce Manifest Download did not complete in time (5s)"
            }
    
            #Clean Up
        } finally {
            #get rid of our eventhandlers
            Get-EventSubscriber | Where-Object {
                $_.SourceObject.ToString() -eq 'System.Deployment.Application.InPlaceHostingManager'
            } | Unregister-Event
        }
    }

    
    <#
    Function Test-ClickOnce {
    [CmdletBinding()] 
    Param(
        $ApplicationName = "Microsoft Exchange Online Powershell Module"
    )
        return ( (Get-ClickOnce -ApplicationName $ApplicationName) -ne $null) 
    }
    
    
    # Simple UnInstall
    function Uninstall-ClickOnce {
    [CmdletBinding()] 
    Param(
        $ApplicationName = "Microsoft Exchange Online Powershell Module"
    )
        $app=Get-ClickOnce -ApplicationName $ApplicationName
    
        #Deinstall One to remove all instances
        if ($App) { 
            $selectedUninstallString = $App.UninstallString 
            #Seperate cmd from parameters (First Space)
            $parts = $selectedUninstallString.Split(' ', 2)
            Start-Process -FilePath $parts[0] -ArgumentList $parts[1] -Wait 
            #ToDo : Automatic press of OK
            #Start-Sleep 5
            #$wshell = new-object -com wscript.shell
            #$wshell.sendkeys("`"OK`"~")
    
            $app=Get-ClickOnce -ApplicationName $ApplicationName
            if ($app) {
                Write-verbose 'De-installation aborted'
                #return $false
            } else {
                Write-verbose 'De-installation completed'
                #return $true
            } 
            
        } else {
            #return $null
        }
    }

    #>