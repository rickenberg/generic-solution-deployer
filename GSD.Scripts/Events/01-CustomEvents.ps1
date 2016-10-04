Function Execute-OnPreDeploy {
    Write-GsdLog -Message "OnPreDeploy 01 Custom Events" -Level $GSD.LogLevel.Normal
}

Function Execute-OnDeploy {
    Write-GsdLog -Message "OnDeploy 01 Custom Events" -Level $GSD.LogLevel.Normal
}

Function Execute-OnPostDeploy {
    Write-GsdLog -Message "OnPostDeploy 01 Custom Events" -Level $GSD.LogLevel.Normal
}