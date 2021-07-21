# ax_deploy_cs

**Deploying the Automox agent using the Falcon sensor**

Prerequisites

1. You need to have RTR enabled in the Response policy assigned to the device in Falcon. Ensure "runcscript" and "put" are also fully enabled. The script uses Crowdstrike RTR to push the agent out. You also need to have full Falcon admin priviliges.

2. Follow the instruction to download and install the PSFalcon module. https://github.com/CrowdStrike/psfalcon/wiki/Installation

3. API Credentials: Interacting with the CrowdStrike Falcon API requires an API Client ID and Secret. You will need to create this from the Falcon console to use for the script.

4. *For Windows Deployment Only* - Upload the Automox .msi file: Upload the Automox_Installer-1.0.31.msi file using the Falcon Console by navigating to Response Scripts & Files > "PUT" Files. From there, click 'Upload File' and upload the Automox_Installer-1.0.31.msi file. DO NOT change the naming of the .msi file. The File Name must read 'Automox_Installer-1.0.31.msi'. This gets uploaded to the working directory of the device for Falcon sensor. Here is the link to Download the Automox_Installer-1.0.31.msi

5. Upload the installation script to install Automox for each of the OS's you want to deploy to by navigating to Response Scripts & Files > "Custom Scripts":

 
 ```
 
 Windows:
  Script Name:   AxAgentInstall.ps1
 
  Script:        .\Automox_Installer-1.0.31.msi ACCESSKEY=<your_org_access_key> /quiet
  
 
 Linux:
  Script Name:   AXInstallLinux.bs
 
  Script:        #!/bin/bash
                curl -sS "https://console.automox.com/downloadInstaller?accesskey=<your_org_access_key" | sudo bash
                sudo service amagent stop
                sleep 5
                sudo service amagent start 
 
 
 Mac: 
  Script Name:   AXInstallMac.bs
 
  Script:        #!/bin/bash
                curl -sS "https://console.automox.com/downloadInstaller?accesskey=<your_org_access_key>" | sudo bash

 
  Permission:    RTR Active Responder and RTR Administrator for all scripts
  
  You will need to add your Automox organization access key where it says <your_org_access_key> to the script command. example:
  ACCESSKEY=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
  
  ```

  NOTE: You can add as many arguments to the Automox install command script. The above is for basic quiet install of Automox into your organization. 
  visit https://support.automox.com for more install options for the Automox agent.
  

7. Once you have the custom script saved you can now run the Deploy-Automox.ps1 script.



**Deploy-Automox.ps1**
1. Copy the Deploy-Automox.ps1 script locally to the device you will be performing the deployment from.

2. execute the Deploy-Automox.ps1 script on the device. This script creates a powershell function called Deploy-AxAgent

  Here is an example of the Deploy-AxAgent usage after running the Deploy-Automox.ps1

  ```
  PS C:\> .\Deploy-Automox.ps1

  PS C:\> Deploy-AxAgent
  cmdlet Deploy-AxAgent at command pipeline position 1
  Supply values for the following parameters:
  Id: <string> (Your API Client ID)
  Secret: <string> (Your API Client Secret) 
  HostGroup: "<string>" (The host group of devices you want to deploy the automox agent to. NOTE: You must put the group name in ". example: "windows group"
  Cloud: <string> (CS destination cloud  ex: eu-1, us-gov-1, us-1, us-2)
  osplatform: <string> (the OS you want to deploy to ex: Windos, Mac, Linux)
  Example command:
  ```

  ```
  Deploy-AxAgent -Id '<your_client_id>' -Secret '<your_client_secret>' -HostGroup "<your_host_group>" -Cloud '<cloud>' -osplatform '<OS name>'
  ```

  The Automox agent should now be installed successfully on all your devices and reporting into your Automox console!

  ```
  -QueueOffline is set to $true in the function. So by default we will queue the install on offline devices and will push the install the next time they login. This can also be disabled.
