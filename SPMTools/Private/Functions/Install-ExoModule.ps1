#Adapted from https://www.powershellgallery.com/packages/Load-ExchangeMFA

function Install-EXOModule {
    [CmdletBinding()] 
    Param()

    $Manifest = "https://cmdletpswmodule.blob.core.windows.net/exopsmodule/Microsoft.Online.CSE.PSModule.Client.application"
    $ElevatePermissions = $true
        Try { 
            Add-Type -AssemblyName System.Deployment
            Write-Verbose "Start installation of ClockOnce Application $Manifest"
    
            $RemoteURI = [URI]::New( $Manifest , [UriKind]::Absolute)
            $HostingManager = New-Object System.Deployment.Application.InPlaceHostingManager -ArgumentList $RemoteURI,$False
        
            #Register custom events to catch the completed downloads
            $Param = @{
                InpurtObject = $HostingManager
                EventName = GetMainifestCompleted
                Action = {
                    New-Event -SourceIdentifier "ManifestDownloadComplete"
                }
            }
            $null = Register-ObjectEvent @Param

            $Param = @{
                InpurtObject = $HostingManager
                EventName = DownloadApplicationCompleted
                Action = {
                    New-Event -SourceIdentifier "DownloadApplicationCompleted"
                }
            }
            $null = Register-ObjectEvent @Param
    
            #Get the Manifest
            $HostingManager.GetManifestAsync()
    
            #Wait for up to 5s for our custom event
            $ManifestEvent = Wait-Event -SourceIdentifier "ManifestDownloadComplete" -Timeout 5
            if ($ManifestEvent) {
                $ManifestEvent | Remove-Event
                Write-Verbose "ClickOnce Manifest Download Completed"
                
                Try {
                    $HostingManager.AssertApplicationRequirements($ElevatePermissions)
                }
                Catch {
                    $message = "Unable to elevate permissions to install Exchange Online Powershell Module"
                    $Param = @{
                        ExceptionName = "System.Security.AccessControl.PrivilegeNotHeldException"
                        ExceptionMessage = $message
                        ErrorId = "EXOModuleElevatePermissions" 
                        CallerPSCmdlet = $PSCmdlet
                        ErrorCategory = 'AccessDenied'
                    }
                    ThrowError @Param
                }
                
                #Download Application
                $HostingManager.DownloadApplicationAsync()
                #register and wait for completion event
                # $HostingManager.DownloadApplicationCompleted
                $DownloadEvent = Wait-Event -SourceIdentifier "DownloadApplicationCompleted" -Timeout 15
                if ($DownloadEvent) {
                    $DownloadEvent | Remove-Event
                    Write-Verbose "ClickOnce Application Download Completed"
                } else {
                    #We didn't download the app in time
                    $message = "ClickOnce Application Download did not complete in time (15s)"
                    $Param = @{
                        ExceptionName = "System.TimeoutException"
                        ExceptionMessage = $message
                        ErrorId = "EXOModuleManifestDownload" 
                        CallerPSCmdlet = $PSCmdlet
                        ErrorCategory = 'Timeout'
                    }
                    ThrowError @Param
                }
            } else {
                #We didn't download the manifest in time
               $message = "ClickOnce Manifest Download did not complete in time (5s)"
                    $Param = @{
                        ExceptionName = "System.TimeoutException"
                        ExceptionMessage = $message
                        ErrorId = "EXOModuleApplicationDownload" 
                        CallerPSCmdlet = $PSCmdlet
                        ErrorCategory = 'Timeout'
                    }
                    ThrowError @Param
            }
    
            #Clean Up
        } finally {
            #get rid of our eventhandlers
            $Filter = { $_.SourceObject.ToString() -eq 'System.Deployment.Application.InPlaceHostingManager' }
            Get-EventSubscriber | Where-Object $Filter | Unregister-Event
        }
    }