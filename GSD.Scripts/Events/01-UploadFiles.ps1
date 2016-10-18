Function Execute-OnPreDeploy {
    # Do nothing
}

Function Execute-OnDeploy {
    Write-GsdLog -Message "Uploading PP files started" -Level $GSD.LogLevel.Normal
	$targetUrl = "{{targetUrl}}"
	Write-Host "Target URL $targetUrl"
	Add-SPFile -SiteUrl "{{targetUrl}}" -SourceDirectory "$($GSD.SolutionDir)\ProgrammingPlan" -RelativeDocLibUrl "Style Library"
    Write-GsdLog -Message "Uploading PP files completed" -Level $GSD.LogLevel.Normal
}

Function Execute-OnPostDeploy {
    # Do nothing
}