<#
	.SYNOPSIS
	Core module for Generic Solution Deployer. Implements handling of custom deploy events.

	.NOTES
	Generic Solution Deployer (GSD)
	Version		: 1.0
	Date		: 2016-09-30
	Author		: Bernd Rickenberg
	License		: MS-PL

	.LINK
	https://github.com/rickenberg/generic-solution-deployer
#>

Function Import-CustomEvents() {
	<# 
		.SYNOPSIS
	    Loads all custom event files from the Events folder.
	#>

	$customEventScripts = @()
	$customEventFiles = Get-ChildItem ".\Events" | Where {$_.Name -like "*.ps1"} 
	$customEventFiles | ForEach { 
		Write-GsdLog -Message "- loading $_" -Level $GSD.LogLevel.Always
        # Keep line breaks - otherwise multi-line functions will break
		$script = (Get-Content .\Events\$_) -Join "`n"
		$customEventScript = @{}
		$customEventScript.FileName = $_
		$customEventScript.Script = ReplaceVariables -script $script
        # Load PS script into current session
        $customEventScript.ScriptBlock = [scriptblock]::Create($customEventScript.Script)
		$customEventScripts += $customEventScript
        Write-GsdLog -Message "- loaded successfully" -Level $GSD.LogLevel.Success
	}
	return $customEventScripts
}

Function Test-CustomEvents() {
	<# 
		.SYNOPSIS
	    Checks that the custom events have defined an event handler for all deployment events.
	#>

    $isValid = $true
    $customEventScripts | ForEach {
        Write-GsdLog -Message "- processing $($_.FileName)" -Level $GSD.LogLevel.Always
        $functions = $_.ScriptBlock.Ast.FindAll({$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]}, $true)
        $noDeploy = $functions.Find({$args[0].Name -eq "Execute-OnDeploy"}) -eq $null
        $noPreDeploy = $functions.Find({$args[0].Name -eq "Execute-OnPreDeploy"}) -eq $null
        $noPostDeploy = $functions.Find({$args[0].Name -eq "Execute-OnPostDeploy"}) -eq $null
        if ($noDeploy -or $noPreDeploy -or $noPostDeploy) {
            Write-GsdLog -Message "- failed. Found missing method(s)" -Level $GSD.LogLevel.Error
		    $isValid = $false;
        } else {
            Write-GsdLog -Message "- succedded" -Level $GSD.LogLevel.Success
        }
    }

    if (!$isValid) {
	    # Set the exit code and stop the script
		#$Host.SetShouldExit(1)
		#Exit
    }
}

Function Invoke-CustomEventsPreDeploy($customEventScripts) {
	<# 
		.SYNOPSIS
	    Run the script for pre-deploy event
	#>

    $customEventScripts | ForEach {
        Write-GsdLog -Message "- running OnPreDeploy from $($_.FileName)" -Level $GSD.LogLevel.Always -Indent
        . $_.ScriptBlock
	    Execute-OnPreDeploy
        Pop-GsdIndentLevel
    }
}

Function Invoke-CustomEventsDeploy($customEventScripts) {
	<# 
		.SYNOPSIS
	    Run the script for deploy event
	#>

    $customEventScripts | ForEach {
        Write-GsdLog -Message "- running OnDeploy from $($_.FileName)" -Level $GSD.LogLevel.Always -Indent
        . $_.ScriptBlock
	    Execute-OnDeploy
        Pop-GsdIndentLevel
    }
}

Function Invoke-CustomEventsPostDeploy($customEventScripts) {
	<# 
		.SYNOPSIS
        Run the script for post deploy event
	#>

    $customEventScripts | ForEach {
	    Write-GsdLog -Message "- running OnPostDeploy from $($_.FileName)" -Level $GSD.LogLevel.Always -Indent
        . $_.ScriptBlock
	    Execute-OnPostDeploy
        Pop-GsdIndentLevel
    }
}

Function ReplaceVariables ($script) {
	<# 
		.SYNOPSIS
        Finds all variables denoted with {{name}} in the script and replaces with values from config
	#>

    $matchEvaluator = {
        $match = $args[0]

        if ($GSDConfig.Variables.ContainsKey($match.Groups[1].Value)) {
            # Variable found in current config
            return $GSDConfig.Variables[$match.Groups[1].Value]
        } else {
            # Handle error
            return ""
        }
    }

    $regex = [regex] "\{\{([^}]+)\}\}"
    return $regex.Replace($script, $matchEvaluator)
    #return $script -replace "\{\{[^}]+\}\}","test"
}
