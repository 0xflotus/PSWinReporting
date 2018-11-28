function Get-ComputerStatus {
    param (
        $Events,
        $IgnoreWords = ''
    )
    $EventsType = $Script:ReportDefinitions.ReportsAD.EventBased.ComputerDeleted.LogName
    $EventsNeeded = $Script:ReportDefinitions.ReportsAD.EventBased.ComputerDeleted.Events
    $EventsFound = Find-EventsNeeded -Events $Events -EventsNeeded $EventsNeeded -EventsType $EventsType
    $EventsFound = Get-EventsTranslation -Events $EventsFound -Fields $Script:ReportDefinitions.ReportsAD.EventBased.ComputerDeleted.Fields
    return Find-EventsIgnored -Events $EventsFound -IgnoreWords $IgnoreWords | Sort-Object $Script:ReportDefinitions.ReportsAD.EventBased.ComputerDeleted.SortBy
}