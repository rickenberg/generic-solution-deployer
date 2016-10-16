<#
	.SYNOPSIS
	Core module for Generic Solution Deployer. Implements common functionality.

	.NOTES
	Generic Solution Deployer (GSD)
	Version		: 1.0
	Date		: 2016-09-30
	Author		: Bernd Rickenberg, Matthias Einig
	License		: MS-PL

	.LINK
	https://github.com/rickenberg/generic-solution-deployer
#>

# Variables from this module to be exported. They are used for general settings.
$GSD = $null

Function Initialize-Script($ScriptPath, $Command, $Environment, $LogLevelTitle) {
	<#
	  .SYNOPSIS
	  Initializes the main GSD script. Sets global variables and parses the command line parameters.
	#>

	$Script:GSD = @{
	                    Version = [System.Version]"1.0"
                        DisplayName ="Generic Solution Deployer (GSD)"
                        StatusWidth = 79
	                    LogLevel = @{
                            Always      = 0
                            Success     = 1
	                        Error       = 2
	                        Warning     = 3
	                        Information = 4
	                        Normal      = 5

	                    }
	                    Commands = @{
	                        Deploy      = 0
	                        Rollback    = 1
	                        Redeploy    = 2
	                        Update      = 3
	                    }
                        LogIndentVal = 0
                        BaseDir = $ScriptPath
						ConfigDir = "$($ScriptPath)\..\Config"
						EventsDir = "$($ScriptPath)\..\Events"
						LogDir = Get-DirOrCreateIt -path "$($ScriptPath)\..\Logs"
						ModulesDir = "$($ScriptPath)\..\Modules"
						SettingsFilePath = "$($ScriptPath)\..\Config\settings.xml"
						SolutionDir = "$($ScriptPath)\..\Solution"
                        TargetEnvironment = $Environment
	                }

    $GSD.DeploymentCommandTitle = $Command
    $GSD.DeploymentCommand = Get-Parameter -value $Command -values $GSD.Commands
 
    # Set log level
    $GSD.MinLogLevelTitle = $LogLevelTitle
    $GSD.MinLogLevel = Get-Parameter -value $LogLevelTitle -values $GSD.LogLevel
}

Function Get-DirOrCreateIt($path) {
	<#
	  .SYNOPSIS
	  Gets the specified file system folder. Creates it if it does not exist.
	#>

	if (!(Test-Path $path))
	{
	    New-Item $path -type directory | out-null
	}
	return $path
}

Function Get-Parameter([string]$value = $(throw "You have to specify the desired value"), 
	                    [System.Collections.Hashtable]$values = $(throw "You have to specify the values HashTable")) {
	<#
	  .SYNOPSIS
	  Finds the given command-line parameter in a hashtable and returns the value.
	#>
	
	foreach($key in $values.Keys) {
	    if([System.String]::Compare($key, $value, $true) -eq 0) {
	        return $values[$key]
	    }
	}

    # Never happens
	return $null
}

# Work-around for variable export. It is not enough to set this in psd1 file. No idea why.
Export-ModuleMember -Variable @('GSD') -Function "*"