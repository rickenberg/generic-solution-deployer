<#
	.SYNOPSIS
	Extension module for Generic Solution Deployer for deploying various artefacts to SharePoint 2010 using CSOM.

	.NOTES
	Generic Solution Deployer (GSD)
	Version		: 1.0
	Date		: 2016-09-30
	Author		: Bernd Rickenberg
	License		: MS-PL

	.LINK
	https://github.com/rickenberg/generic-solution-deployer
#>

$modulePath = split-path -parent $MyInvocation.MyCommand.Definition
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client,Version=14.0.0.0") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.Runtime,Version=14.0.0.0") | Out-Null
Import-Module $modulePath\SPSD.Extensions.Client.dll -Prefix Local

Function Add-SPFile($SiteUrl, $SourceDirectory, $RelativeDocLibUrl)
{
	<#
		.SYNOPSIS
		Deploys files and folder structures to a document library on SharePoint 2010.
	#>

	Add-LocalSPFile -SiteUrl $SiteUrl -SourceDirectory $SourceDirectory -RelativeDocLibUrl $RelativeDocLibUrl
}

Function Add-SiteCustomAction($SiteUrl, $Location, $ScriptSrc, [int]$Sequence, $Name) {
	Write-Host "Adding site custom action with name '$Name'"
	$context = New-Object Microsoft.SharePoint.Client.ClientContext($SiteUrl)
	$customActions = $context.Site.UserCustomActions
	$customAction = $customActions.Add()
	$customAction.Location = $Location
	$customAction.ScriptSrc = $ScriptSrc
	$customAction.Sequence = $Sequence
	$customAction.Name = $Name
	$customAction.Update()
	$context.ExecuteQuery()
}

Function Remove-SiteCustomAction($SiteUrl, $Name) {
	$context = New-Object Microsoft.SharePoint.Client.ClientContext($SiteUrl)
	$customActions = $context.Site.UserCustomActions
	$context.Load($customActions)
	$context.ExecuteQuery()
	Write-Host "Deleting $($customActions.Count) site custom actions with name '$Name'"
	$result = $customActions.Where({ $_.Name -eq $Name })
	foreach($ca in $result) {
	    $ca.DeleteObject()
	    $context.Load($ca)
	    $context.ExecuteQuery()
	}
}

Export-ModuleMember -Function "*"