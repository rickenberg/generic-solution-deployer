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

	[string]$RunningInNewSession = "False"
)

# Set working directory (compatible to all PS versions)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
Set-Location $scriptPath

# Load GSD core modules
Import-Module .\Common -Force -Prefix Gsd
Import-Module .\Configuration -Force -Prefix Gsd
Import-Module .\Logging -Force -Prefix Gsd
Import-Module .\CustomEvents -Force -Prefix Gsd

# Initialize
Initialize-GsdScript -ScriptPath $scriptPath -Command $Command -Environment $TargetEnvironment -LogLevelTitle $LogLevel
Start-GsdTracing
Write-GsdIntro

# Load
Write-GsdLog -Message "LOAD: Loading GSD components" -Level $GSD.LogLevel.Always -Indent
Pop-GsdIndentLevel

# 1. Load configuration
Write-GsdLog -Message "LOAD: Loading configuration" -Level $GSD.LogLevel.Always -Indent
Get-GsdConfig
Pop-GsdIndentLevel

# 2. Load modules
Write-GsdLog -Message "LOAD: Loading modules" -Level $GSD.LogLevel.Always -Indent
$moduleFiles = Get-ChildItem "$($GSD.ModulesDir)" -Recurse | Where {$_.Name -like "*.gsd.psm1"} 
$moduleFiles | ForEach { 
	Write-GsdLog -Message "- loading $_" -Level $GSD.LogLevel.Always
	Import-Module $_.FullName -Force
}
Pop-GsdIndentLevel

# 3. Load custom events
Write-GsdLog -Message "LOAD: Loading custom events" -Level $GSD.LogLevel.Always -Indent
$customEventScripts = Import-GsdCustomEvents
Pop-GsdIndentLevel

# Validate
Write-GsdLog -Message "VALIDATE: Validating GSD components" -Level $GSD.LogLevel.Always -Indent
Pop-GsdIndentLevel

# 1. Validate configuration
Write-GsdLog -Message "VALIDATE: Validating configuration" -Level $GSD.LogLevel.Always -Indent
Pop-GsdIndentLevel

# 2. Validate modules
Write-GsdLog -Message "VALIDATE: Validating modules" -Level $GSD.LogLevel.Always -Indent
Pop-GsdIndentLevel

# 3. Validate custom events
Write-GsdLog -Message "VALIDATE: Validating custom events" -Level $GSD.LogLevel.Always -Indent
Test-GsdCustomEvents $customEventScripts
Pop-GsdIndentLevel

# Run deployment
Write-GsdLog -Message "DEPLOY: Starting deployment" -Level $GSD.LogLevel.Always -Indent
# Determine deploy action (deploy|redeploy|rollback|update)

# 1. Run pre deploy action
Invoke-GsdCustomEventsPreDeploy $customEventScripts

# 2. Run deploy action
Invoke-GsdCustomEventsDeploy $customEventScripts

# 3. Run post deploy action
Invoke-GsdCustomEventsPostDeploy $customEventScripts

Pop-GsdIndentLevel

Write-GsdLog -Message "Deployment completed successfully" -Level $GSD.LogLevel.Success

# Stop logging
Stop-GsdTracing

if ($RunningInNewSession -eq $true) {
	# Wait for input until scripts ends and windows is closed when running a separate PS session
	Write-Host
	Write-Host "Done - Press [enter] to close window"
	Read-Host
}

CD .. | Out-Null