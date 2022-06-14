& 'C:\Program Files (x86)\Automox\amagent.exe' --deregister


    # Add Application name exactly as it appears in Add/Remove Programs, Programs and Features, or Apps and Features between single quotes.
    # Modify $exeCmd as needed for EXE Installer based installations that require additional settings.
    ######## Make changes within the block ########
    $appName = 'Automox Agent'
    $exeCmd = '/S'
    ###############################################

    # Define registry location for uninstall keys
    $uninstReg = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall','HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall')

    # Get all entries that match our criteria. DisplayName matches $appName (using -like to support special characters)
    $installed = @(Get-ChildItem $uninstReg -ErrorAction SilentlyContinue | Get-ItemProperty | Where-Object {($_.DisplayName -like $appName)})

    # Initialize an array to store the uninstalled app information
    $uninstalled = @()

    # Start a loop in-case you get more than one match, uninstall each.
    foreach ($version in $installed)
    {
        #For every version found, run the uninstall string
        $uninstString = $version.UninstallString
        #If exe, run as written + $exeCmd variable, if msiexec run as msi using the name of the reg key as the msi guid.
        if($uninstString -match 'msiexec')
        {
            $process = Start-Process msiexec.exe -ArgumentList "/x $($version.PSChildName) /qn /norestart" -Wait -PassThru
        }
        else
        {
            $process = Start-Process $uninstString -ArgumentList $exeCmd -Wait -PassThru
        }

        # Check exit code for success/fail and verifying against known successful installation codes
        # If unsuccessful, don't add to uninstalled list.
        if (($process.ExitCode -eq '0') -or ($process.ExitCode -eq '1641') -or ($process.ExitCode -eq '3010'))
        {
            $uninstalled += $version.PSPath
        }
    }
