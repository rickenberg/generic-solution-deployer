Function Execute-OnPreDeploy {
    Write-GsdLog -Message "OnPreDeploy 02 Custom Events" -Level $GSD.LogLevel.Normal
}

Function Execute-OnDeploy {
    Write-GsdLog -Message "OnDeploy 02 Custom Events" -Level $GSD.LogLevel.Normal
}

Function Execute-OnPostDeploy {
    Write-GsdLog -Message "OnPostDeploy 02 Custom Events" -Level $GSD.LogLevel.Normal
}