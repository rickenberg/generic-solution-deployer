Function Execute-OnPreDeploy {
    # Do nothing
}

Function Execute-OnDeploy {
    Write-GsdLog -Message "Registering PP custom actions started" -Level $GSD.LogLevel.Normal
    Remove-SiteCustomAction -SiteUrl "{{targetUrl}}" -Name "NNProgrammingPlanJqScript"
    $installDate = [System.Uri]::EscapeDataString([System.DateTime]::Now.ToLongTimeString())
    $scriptUrl = "~SiteCollection/style library/ProgrammingPlan.js?installDate=$installDate"
    Add-SiteCustomAction -SiteUrl "{{targetUrl}}" -Name "NNProgrammingPlanJqScript" -Location "ScriptLink" -Sequence 103 -ScriptSrc $scriptUrl
    Write-GsdLog -Message "Registering PP custom actions completed" -Level $GSD.LogLevel.Normal
}

Function Execute-OnPostDeploy {
    # Do nothing
}