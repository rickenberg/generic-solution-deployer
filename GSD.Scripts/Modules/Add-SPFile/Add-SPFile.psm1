<#
	.SYNOPSIS
	Extension module for Generic Solution Deployer for uploading files and file structures to a SharePoint
	document library.

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
		Deploys local files to a document library on SharePoint 2010.
	#>

	Add-LocalSPFile -SiteUrl $SiteUrl -SourceDirectory $SourceDirectory -RelativeDocLibUrl $RelativeDocLibUrl
}

Export-ModuleMember -Function "*"