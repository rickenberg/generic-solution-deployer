<#
	.SYNOPSIS
	Main script for the for Generic Solution Deployer.

	.NOTES
	Generic Solution Deployer (GSD)
	Version		: 1.0
	Date		: 2016-09-30
	Author		: Bernd Rickenberg
	License		: MS-PL

	.LINK
	https://github.com/rickenberg/generic-solution-deployer
#>

Param 
(
    [ValidateSet('Deploy', 'Redeploy', 'Rollback', 'Update')]
    [string]$Command = "Deploy",

    [string]$TargetEnvironment = "DEV", 

    [ValidateSet('Always', 'Success', 'Error', 'Warning', 'Information', 'Normal')]
    [string]$LogLevel = "Success",

    [bool]$PromptForCredentials = $false,

    [switch]$RunInNewSession = $false
)

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

# Preflight check
# Check PS version

# Get credentials
#$creds = Get-Credential

# Execute main script
$scriptCommand = "$scriptPath\Core\GSD_Main.ps1 -Command $Command -TargetEnvironment $TargetEnvironment -LogLevel $LogLevel -RunningInNewSession $RunInNewSession"
if ($RunInNewSession) {
	# Run GSD in a new PS window
	Start-Process "$PSHOME\PowerShell.exe" -Verb RunAs -ArgumentList $scriptCommand
} else {
	# Run GSD in current session
	Invoke-Expression $scriptCommand
}