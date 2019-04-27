﻿function Get-EventsDefinitions {
    [CmdLetBinding()]
    param(
        $Definitions
    )
    [string] $ConfigurationPath = "$Env:ALLUSERSPROFILE\Evotec\PSWinReporting\Definitions"
    $Files = Get-ChildItem -LiteralPath $ConfigurationPath -Filter '*.xml'

    try {
        $AllDefinitions = $Script:ReportDefinitions
        foreach ($File in $Files) {
            $AllDefinitions += Import-CliXML -LiteralPath $File.FullName
        }
        if ($Definitions) {
            $AllDefinitions += $Definitions
        }
    } catch {
        $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
        if ($ErrorMessage -like '*Item has already been added. Key in dictionary*') {
            Write-Warning "Get-EventsDefintions - Duplicate key in definition. Please make sure names in Hashtables are unique."
        } else {
            Write-Warning "Get-EventsDefintions - Error: $ErrorMessage"
        }
        $AllDefinitions = $null
    }
    return $AllDefinitions
}