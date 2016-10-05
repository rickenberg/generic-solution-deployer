<#
	.SYNOPSIS
	Core module for Generic Solution Deployer. Implements configuration for GSD.

	.NOTES
	Generic Solution Deployer (GSD)
	Version		: 1.0
	Date		: 2016-09-30
	Author		: Bernd Rickenberg
	License		: MS-PL

	.LINK
	https://github.com/rickenberg/generic-solution-deployer
#>

# Variables from this module to be exported. They are used for general settings.
$GSDConfig = @{ Variables = @{} }

	
Function Get-Config() {
	<#
	  .SYNOPSIS
      Load configuration from settings.xml and store in 'global' variable
	#>

    Write-GsdLog -Message "- Processing $($GSD.SettingsFilePath)" -Level $GSD.LogLevel.Normal
	[xml]$configDoc = Get-Content $GSD.SettingsFilePath

	# Get general settings
    Write-GsdLog -Message "- Getting general settings" -Level $GSD.LogLevel.Normal
	$settings = ConvertConfigSectionToHashtable $configDoc.Settings

	# Get environment specific settings, overwrite general settings where applicable
    Write-GsdLog -Message "- Getting environment settings for '$($GSD.TargetEnvironment)'" -Level $GSD.LogLevel.Normal
	$envSettings = ConvertConfigSectionToHashtable $configDoc.SelectSingleNode("//Environment[@name='$($GSD.TargetEnvironment)']")
}

Function ConvertConfigSectionToHashtable($settingsNode) {
	<#
	  .SYNOPSIS
      Helper method to convert config section to hashtable
	#>

    if ($settingsNode -eq $null) {
        # Config empty - probably not found
        return
    }

    $result = @{ Variables = @{} }

    # Get GSD settings
    # TODO: Use the proper types - boolean and int
    foreach($setting in $settingsNode.Gsd.ChildNodes) {
        $key = $setting.Name
        $value = $setting.InnerText
        SetConfigValue -config $Script:GsdConfig -key $key -value $value
    }

    # Get variables
    foreach($variable in $settingsNode.Variables.ChildNodes) {
        $key = $variable.Name
        $value = $variable.InnerText
        SetConfigValue -config $Script:GsdConfig.Variables -key $key -value $value
    }
}

Function SetConfigValue($config, $key, $value) {
	<#
	  .SYNOPSIS
      Helper method to convert config section to hashtable
	#>

    if ([System.String]::IsNullOrWhiteSpace($value)) {
        return
    }
    if ($config.ContainsKey($key)) {
        # Key found - update value
        $config[$key] = $value
    } else {
        # Key not found - add key/value pair
        $config.Add($key, $value)
    }
}

# Work-around for variable export. It is not enough to set this in psd1 file. No idea why.
Export-ModuleMember -Variable @('GSDConfig') -Function "*"