Function Execute-OnPreDeploy {
    # Do nothing
}

Function Execute-OnDeploy {
    Write-GsdLog -Message "Copy file started" -Level $GSD.LogLevel.Normal
    $sourcePath = "$($GSD.SolutionDir)\{{sourceFolder}}"
    $targetPath = "{{targetPath}}"
    
    New-Item -ItemType Directory -Force -Path $targetPath
    Copy -Path "$($sourcePath)\*.*" -Destination $targetPath
    
    Write-GsdLog -Message "Source: '$sourcePath', target: '$targetPath'" -Level $GSD.LogLevel.Normal
    Write-GsdLog -Message "Copy file completed" -Level $GSD.LogLevel.Normal
}

Function Execute-OnPostDeploy {
    Write-GsdLog -Message "OnPostDeploy 01 Custom Events" -Level $GSD.LogLevel.Normal
}