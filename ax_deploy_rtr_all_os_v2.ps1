function Deploy-AxAgent {

[CmdletBinding()]
[OutputType([psobject])]

param(
        [Parameter(Mandatory = $true)]
        [ValidateLength(32,32)]
        [string]
        $Id,

        [Parameter(Mandatory = $true)]
        [string]
        $Secret,

        [Parameter(Mandatory = $true)] 
        [string]
        $HostGroup,

        [Parameter(Mandatory = $true)]
        [string]
        $Cloud,

        [Parameter(Mandatory = $true)]
        [string]
        $osplatform
        )


Request-FalconToken -ClientId $Id -ClientSecret $Secret -Cloud $Cloud

#Get the group you want to deploy the ax agent to
$groupfilter = Get-FalconHostGroup -detailed | select ("name", "id") | ? {$_.name -match $HostGroup} | select "id"
$group = $groupfilter."id"

#get devices within group to deploy ax agent to
$devicelist = Get-Falconhost -Detailed | Select ("device_id", "platform_name", "groups") | Where-Object {$_.groups.Contains($group)} | Select ("device_id", "platform_name") | ? {$_.platform_name -eq $osplatform}
$hostids = $devicelist."device_id"

#determine the correct install commands for the given OS Platform
if( $osplatform -eq "Linux" ) {
        
        #get the runscript to run across devices via RTR
        $axscript1=('-CloudFile=' + '"AXInstallLinux.bs"' + ' ' + '-CommandLine="-Verbose true"' ) 
        Invoke-FalconRTR -HostIds $hostids -Command 'runscript' -Arguments $axscript1 -QueueOffline $true

} elseif ( $osplatform -eq "Windows" ) {
           
            #push the Automox msi file to the device in the Crowdstrike RTR working directy "C:\"
            $axfile = Get-FalconPutFile -Detailed -All | select ("id", "name") | ? {$_.name -match "Automox_installer-1.0.31.msi"} | select "name"
            $axfileid = $axfile."name"

            #get the runscript to run across devices via RTR
            $axscript2=('-CloudFile=' + '"AxAgentInstall.ps1"' + ' ' + '-CommandLine="-Verbose true"' )
            
            #commands to push the ax .msi and run the installation script
            Invoke-FalconRTR -HostIds $hostids -Command 'put' -Arguments $axfileid -QueueOffline $true
            Invoke-FalconRTR -HostIds $hostids -Command 'runscript' -Arguments $axscript2 -QueueOffline $true
} elseif ( $osplatform -eq "Mac"){
            
            #get the runscript to run across devices via RTR
            $axscript3=('-CloudFile=' + '"AXInstallMac.bs"' + ' ' + '-CommandLine="-Verbose true"' ) 
            Invoke-FalconRTR -HostIds $hostids -Command 'runscript' -Arguments $axscript3 -QueueOffline $true

} else {
            Write-Output "No OS supported by Automox exists in this Falcon Host Group"
             
             }
    }
    
