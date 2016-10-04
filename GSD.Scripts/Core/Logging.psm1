<#
	.SYNOPSIS
	Core module for Generic Solution Deployer. Implements handling logging functionality.

	.NOTES
	Generic Solution Deployer (GSD)
	Version		: 1.0
	Date		: 2016-09-30
	Author		: Bernd Rickenberg, Matthias Einig
	License		: MS-PL

	.LINK
	https://github.com/rickenberg/generic-solution-deployer
#>

Function Write-Log([string]$Message, [int]$Level, [switch]$NoNewline, [switch]$Indent, [switch]$Outdent, [switch]$NoIndent) {
	<#
	  .SYNOPSIS
	  Logging function which sets color and indentation

	  .PARAMETER Message
	  The message to add to log

	  .PARAMETER Type
	  Log level (integer) - Use the global enum $GSD.LogLevel - to specify the level suc as error or sucess

	  .PARAMETER NoNewline

	  .PARAMETER Indent

	  .PARAMETER Outdent

	  .PARAMETER NoIndent
	#>

	# TODO
	# if($type -gt $Script:LogLevel){
	#    return
	#}
	$foregroundColor = "Gray"
	$backgroundColor = "Blue"
	switch ($Level){
	    $GSD.LogLevel.Success          { $foregroundColor = "Green" }
	    $GSD.LogLevel.Error            { $foregroundColor = "Red" }
	    $GSD.LogLevel.Warning          { $foregroundColor = "Yellow" }
	    $GSD.LogLevel.Information      { $foregroundColor = "White" }
	    $GSD.LogLevel.Normal           { $foregroundColor = "Gray" }
	}
	if($Outdent){ Pop-IndentLevel }
	if(!$NoIndent){
	    $indentChars = " " * (2 * $Script:LogIndentVal)
	}

		$loggingHost = (Get-Host).Name
    if(($loggingHost -eq "ConsoleHost" -or $loggingHost -eq 'Windows PowerShell ISE Host') -and -not $isAppHost){
	    if($NoNewline)
	    {
	        Write-Host -foregroundColor $foregroundColor ($indentChars + $Message) -NoNewline
	    }
	    else{
	        Write-Host -foregroundColor $foregroundColor ($indentChars + $Message)
	    }
    }
    # always log to file
	if($NoNewline){
        [System.IO.File]::AppendAllText($script:LogFile, ($indentChars + $Message), [System.Text.Encoding]::Default)
	}
    else{
        Add-Content $script:LogFile ($indentChars + $Message)
	}
	if($Indent){ Push-IndentLevel }
}

Function Pop-IndentLevel() {
	<#
	  .SYNOPSIS
	  Decrease the indentation level of the log
	#>

	$Script:LogIndentVal--
	if($Script:LogIndentVal -lt 0){
	    $Script:LogIndentVal = 0
	}
}

Function Push-IndentLevel() {
	<#
	  .SYNOPSIS
	  Increase the indentation level of the log
	#>

	$Script:LogIndentVal++
}

Function Start-Tracing() {
	<#
	  .SYNOPSIS
	  Start tracing the PowerShell Output to a file
	#>

	$script:LogTime = Get-Date -Format yyyyMMdd-HHmmss
	$script:LogFile = "$LogDir\$LogTime-$DeploymentCommandTitle.log"
    if((Get-Host).Name -eq "ConsoleHost" -and -not $isAppHost){
	    Start-Transcript -Path $LogFile -Force
    }
	$script:ElapsedTime = [System.Diagnostics.Stopwatch]::StartNew()
}

Function Stop-Tracing() {
	<#
	  .SYNOPSIS
	  Stop tracing the PowerShell Output to a file
	#>

    if((Get-Host).Name -eq "ConsoleHost" -and -not $isAppHost){
		Stop-Transcript
    }
}

Filter Set-ColorPattern([string]$ErrorPattern, [string]$SuccessPattern) {
	<#
	  .SYNOPSIS
	  Colorizes and outputs a certain regex match on the piped string

	  .LINK
	  http://stackoverflow.com/questions/7362097/color-words-in-powershell-script-format-table-output
	#>

    $lines = $_ -split "`n"
    for( $k = 1; $k -lt $lines.Count-3; ++$k ) {
        if($k -eq 1){
            Log $lines[$k] -Type $SPSD.LogTypes.Information
        }
        else{
            Log -NoNewline #for correct indentation
            $split1 = $lines[$k] -split $ErrorPattern
            $error = [regex]::Matches( $lines[$k], $ErrorPattern, 'IgnoreCase' )
            for( $i = 0; $i -lt $split1.Count; ++$i ) {
	        $split2 =  $split1[$i] -split $SuccessPattern
            $success = [regex]::Matches( $split1[$i], $SuccessPattern, 'IgnoreCase' )
            for( $j = 0; $j -lt $split2.Count; ++$j ) {
            	Log $split2[$j] -Type $SPSD.LogTypes.Normal -NoNewline -NoIndent
            	Log $success[$j] -Type $SPSD.LogTypes.Success -NoNewline -NoIndent
            }
            Log $error[$i] -Type $SPSD.LogTypes.Error -NoNewline -NoIndent
            }
            Log
        }
    }
}