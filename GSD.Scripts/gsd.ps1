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

    [bool]$createNewPSSession = $false
)

# Set working directory (compatible to all PS versions)
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
Set-Location $scriptPath

# Preflight check
# Check PS version

# Get credentials
#Get-Credential

# Start new session
#PowerShell -Command Start-Process "$PSHOME\powershell.exe"


# Load GSD core modules
Import-Module .\Core\Common -Force -Prefix Gsd
Import-Module .\Core\Configuration -Force -Prefix Gsd
Import-Module .\Core\Logging -Force -Prefix Gsd
Import-Module .\Core\CustomEvents -Force -Prefix Gsd

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
Test-GsdCustomEvents
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