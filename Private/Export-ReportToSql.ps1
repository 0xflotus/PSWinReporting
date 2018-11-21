function Export-ReportToSQL {
    param (
        [hashtable] $Report,
        [hashtable] $ReportOptions,
        [string] $ReportName,
        $ReportTable
    )
    #Get-ObjectType -Object $Report -Verbose -VerboseOnly
    #Get-ObjectType -Object $ReportOptions -Verbose -VerboseOnly
    if ($Report.Enabled) {
        # checks if Report is enabled
        if ($ReportOptions.Contains('AsSql') -and $ReportOptions.AsSql.Use) {
            # checks if global sql is enabled
            if ($Report.EnabledSqlGlobal) {
                # checks if global sql is enabled for particular dataset
                $Logger.AddRecord("Sending $ReportName to SQL at Global level")
                $SqlQuery = Send-SqlInsert -Object $ReportTable -SqlSettings $ReportOptions.AsSql -Verbose:$ReportOptions.Debug.Verbose
                foreach ($Query in $SqlQuery) {
                    $Logger.AddRecord("MS SQL Output: $Query")
                }
            }
        }
        if ($Report.Contains('ExportToSql') -and $Report.ExportToSql.Use) {
            # checks if local sql is enabled for dataset
            $Logger.AddRecord("Sending $ReportName to SQL at Local level")
            $SqlQuery = Send-SqlInsert -Object $ReportTable -SqlSettings $Report.ExportToSql -Verbose:$ReportOptions.Debug.Verbose
            foreach ($Query in $SqlQuery) {
                $Logger.AddRecord("MS SQL Output: $Query")
            }
        }
    }
}