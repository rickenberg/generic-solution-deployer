Function Execute-OnPreDeploy {
    Write-GsdLog -Message "OnPreDeploy 03 Custom Events" -Level $GSD.LogLevel.Normal
}

Function Execute-OnDeploy {
    Write-GsdLog -Message "OnDeploy 03 Custom Events" -Level $GSD.LogLevel.Normal
}

Function Execute-OnPostDeploy {
    Write-GsdLog -Message "OnPostDeploy 03 Custom Events" -Level $GSD.LogLevel.Normal
}