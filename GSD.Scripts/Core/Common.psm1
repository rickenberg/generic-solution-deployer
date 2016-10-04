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

Function Initialize-Script($ScriptPath, $Command, $Environment) {
	<#
	  .SYNOPSIS
	  Initializes the main GSD script. Sets global variables and parses the command line parameters.
	#>

	$Script:GSD = @{
	                    Version = [System.Version]"1.0"
                        DisplayName ="Generic Solution Deployer (GSD)"
                        StatusWidth = 79
	                    LogLevel = @{
                            Success     = 0
	                        Error       = 1
	                        Warning     = 2
	                        Information = 3
	                        Normal      = 4

	                    }
	                    Commands = @{
	                        Deploy      = 0
	                        Rollback    = 1
	                        Redeploy    = 2
	                        Update      = 3
	                    }
                        LogIndentVal = 0
                        BaseDir = $ScriptPath
                        LogDir = Get-DirOrCreateIt -path "$($ScriptPath)\Logs"
						SolutionDir = "$($ScriptPath)\Solution"
                        TargetEnvironment = $Environment
	                }

    $Script:GSD.DeploymentCommand = Get-Parameter -value $Command -values $GSD.Commands -default $GSD.Commands.Deploy
    $Script:GSD.DeploymentCommandTitle = Get-ParameterName -value $Command -values $GSD.Commands
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
	                    [System.Collections.Hashtable]$values = $(throw "You have to specify the values HashTable"), 
	                    [int]$default = 0) {
	<#
	  .SYNOPSIS
	  Finds the given command-line parameter in a hashtable and returns the value.
	#>
	
	foreach($key in $values.Keys) {
	    if([System.String]::Compare($key, $value, $true) -eq 0) {
	        return $values[$key]
	    }
	}
	return $default
}

Function Get-ParameterName([string]$value = $(throw "You have to specify the desired value"), 
	                    [System.Collections.Hashtable]$values = $(throw "You have to specify the values HashTable")) {
	<#
	  .SYNOPSIS
	  Finds value in hastable for the given key.
	#>
	
	foreach($item in $values.GetEnumerator()) {
	    if($item.Value -eq $value) {
	        return $item.Key
	    }
	}

	return ""
}

# Work-around for variable export. It is not enough to set this in psd1 file. No idea why.
Export-ModuleMember -Variable @('GSD') -Function "*"