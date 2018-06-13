Function Get-ModulesAvailability ([string]$Name) {
    if (-not(Get-Module -name $name)) {
        if (Get-Module -ListAvailable | Where-Object { $_.name -eq $name }) {
            try {
                Import-Module -Name $name
                return $true
            } catch {
                return $false
            }
        } else { return $false } #module not available
    } else { return $true } #module already loaded
}
function Test-Key ($ConfigurationTable, $ConfigurationSection = "", $ConfigurationKey, $DisplayProgress = $false) {

    if ($ConfigurationTable -eq $null) { return $false }
    try {
        $value = $ConfigurationTable.ContainsKey($ConfigurationKey)
    } catch {
        $value = $false
    }

    if ($value -eq $true) {
        if ($DisplayProgress -eq $true) {
            Write-Color @script:WriteParameters -Text "[i] ", "Parameter in configuration of ", "$ConfigurationSection.$ConfigurationKey", " exists." -Color White, White, Green, White
        }
        return $true
    } else {
        if ($DisplayProgress -eq $true) {
            Write-Color @script:WriteParameters -Text "[i] ", "Parameter in configuration of ", "$ConfigurationSection.$ConfigurationKey", " doesn't exist." -Color White, White, Red, White
        }
        return $false
    }
}
function Set-DisplayParameters($ReportOptions) {
    $Test0 = Test-Key -ConfigurationTable $ReportOptions -ConfigurationKey 'DisplayConsole' -DisplayProgress $false
    if ($Test0 -eq $true) {
        $Test1 = Test-Key -ConfigurationTable $ReportOptions.DisplayConsole -ConfigurationSection '' -ConfigurationKey "DisplayConsole.ShowTime" -DisplayProgress $false
        $Test2 = Test-Key -ConfigurationTable $ReportOptions.DisplayConsole -ConfigurationSection '' -ConfigurationKey "DisplayConsole.LogFile" -DisplayProgress $false
        $Test3 = Test-Key -ConfigurationTable $ReportOptions.DisplayConsole -ConfigurationSection '' -ConfigurationKey "DisplayConsole.TimeFormat" -DisplayProgress $false

        if ($Test1 -and $Test2 -and $Test3) { $script:WriteParameters = $ScriptParameters }
    }
}

function Find-EventsNeeded ($Events, $EventsNeeded, $EventsType = 'Security') {
    $EventsFound = @()
    foreach ($Event in $Events) {
        if ($Event.LogName -eq $EventsType) {
            if ($EventsNeeded -contains $Event.ID) {
                $EventsFound += $Event
            }
        }
    }
    return $EventsFound
}
function Find-EventsIgnored($Events, $IgnoreWords = '') {
    $EventsToReturn = @()
    foreach ($Event in $Events) {
        $Found = $false
        foreach ($Ignore in $IgnoreWords.GetEnumerator()) {
            if ($Ignore.Value -ne '') {
                foreach ($Value in $Ignore.Value) {
                    $ColumnName = $Ignore.Name
                    if ($Event.$ColumnName -like $Value) {
                        $Found = $true
                    }
                }
            }
        }
        if ($Found -eq $false) {
            $EventsToReturn += $Event
        }
    }
    return $EventsToReturn
}

function Convert-Size {
    # Original - https://techibee.com/powershell/convert-from-any-to-any-bytes-kb-mb-gb-tb-using-powershell/2376
    #
    # Changelog - Modified 30.03.2018 - przemyslaw.klys at evotec.pl
    # - Added $Display Switch
    [cmdletbinding()]
    param(
        [validateset("Bytes", "KB", "MB", "GB", "TB")]
        [string]$From,
        [validateset("Bytes", "KB", "MB", "GB", "TB")]
        [string]$To,
        [Parameter(Mandatory = $true)]
        [double]$Value,
        [int]$Precision = 4,
        [switch]$Display
    )
    switch ($From) {
        "Bytes" {$value = $Value }
        "KB" {$value = $Value * 1024 }
        "MB" {$value = $Value * 1024 * 1024}
        "GB" {$value = $Value * 1024 * 1024 * 1024}
        "TB" {$value = $Value * 1024 * 1024 * 1024 * 1024}
    }

    switch ($To) {
        "Bytes" {return $value}
        "KB" {$Value = $Value / 1KB}
        "MB" {$Value = $Value / 1MB}
        "GB" {$Value = $Value / 1GB}
        "TB" {$Value = $Value / 1TB}

    }
    if ($Display) {
        return "$([Math]::Round($value,$Precision,[MidPointRounding]::AwayFromZero)) $To"
    } else {
        return [Math]::Round($value, $Precision, [MidPointRounding]::AwayFromZero)
    }

}
function Remove-ReportsFiles ($KeepReports, $AsExcel, $AsCSV, $ReportFiles) {
    if ($KeepReports -eq $false -and ($AsExcel -eq $true -or $AsCSV -eq $true)) {
        foreach ($report in $ReportFiles) {
            if (Test-Path $report) {
                Write-Color @script:WriteParameters "[i] ", "Removing file ", " $report " -Color White, White, Yellow, White, Red
                try {
                    Remove-Item $report -ErrorAction Stop
                } catch {
                    #Write-Color @Global:WriteParameters "[i] Error reported when removing file ", "$Report", ". File will be skipped..." -Color White, Red, White
                    Write-Color @script:WriteParameters "[i] Error: ", "$($_.Exception.Message)" -Color White, Red
                }
            }
        }
    }
}
function Export-ReportToXLSX ($Report, $ReportOptions, $ReportFilePath, $ReportName, $ReportTable) {
    if (($Report -eq $true) -and ($($ReportTable | Measure-Object).Count -gt 0)) {
        $ReportTable | Export-Excel -Path $ReportFilePath -WorkSheetname $ReportName -AutoSize -FreezeTopRow -AutoFilter
        return
    } else {
        return
    }
}
function Export-ReportToCSV ($Report, $ReportOptions, $Extension, $ReportName, $ReportTable) {
    if ($Report -eq $true) {
        $ReportFilePath = Set-ReportFileName -ReportOptions $ReportOptions -ReportExtension $Extension -ReportName $ReportName
        $ReportTable | Export-Csv -Encoding Unicode -Path $ReportFilePath
        return $ReportFilePath
    } else {
        return ""
    }
}
function Export-ReportToHTML($Report, $ReportTable, $ReportTableText, [switch] $Special) {
    if ($Report -eq $true) {
        if ($special) {
            return Set-EmailBodyPreparedTable -TableData $ReportTable -TableWelcomeMessage $ReportTableText
        }
        return Set-Emailbody -TableData $ReportTable -TableWelcomeMessage $ReportTableText
    } else {
        return ''
    }
}

function Set-ReportFileName($ReportOptions, $ReportExtension, $ReportName = "") {
    $ReportTime = $(get-date -f $ReportOptions.FilePatternDateFormat)
    if ($ReportOptions.KeepReportsPath -ne "") { $Path = $ReportOptions.KeepReportsPath} else { $Path = $env:TEMP }
    $ReportPath = $Path + "\" + $ReportOptions.FilePattern
    $ReportPath = $ReportPath -replace "<currentdate>", $ReportTime
    if ($ReportName -ne "") {
        $ReportPath = $ReportPath.Replace(".<extension>", "-$ReportName.$ReportExtension")
    } else {
        $ReportPath = $ReportPath.Replace(".<extension>", ".$ReportExtension")
    }
    return $ReportPath
}