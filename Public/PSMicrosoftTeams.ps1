function Start-TeamsReport {
    [CmdletBinding()]
    param(
        $ReportOptions,
        $ReportDefinitions,
        $EventID,
        $EventRecordID,
        $EventChannel
    )
    Set-DisplayParameters -ReportOptions $ReportOptions -DisplayProgress $false

    $TeamsID = $ReportDefinitions.TeamsID
    Write-Color @script:WriteParameters -Text '[i] TeamsID: ', "$($TeamsID.Substring(0, 50))..." -Color White, Yellow
    Write-Color @script:WriteParameters -Text '[i] Executed ', 'Trigger', ' for ID: ', $eventid, ' and RecordID: ', $eventRecordID -Color White, Yellow, White, Yellow, White, Yellow
    Write-Color @script:WriteParameters -Text "Start-TeamsReport (PSWinReporting) - This is a PSSCRIPTROOT path ", " $PSScriptRoot"
    $GroupsEventsTable = @()
    $GroupCreateDeleteTable = @()
    $UsersEventsTable = @()
    $UsersEventsStatusesTable = @()
    $UsersLockoutsTable = @()
    $LogonEvents = @()
    $LogonEventsKerberos = @()
    $RebootEventsTable = @()
    $TableGroupPolicyChanges = @()
    $TableEventLogClearedLogs = @()
    $TableEventLogClearedLogsOther = @()
    $Events = Get-Events -Server $ReportDefinitions.ReportsAD.Servers.ForwardServer -LogName $ReportDefinitions.ReportsAD.Servers.ForwardEventLog -EventID $eventid | Where {$_.RecordID -eq $eventRecordID }
    ### USER EVENTS STARTS ###
    if ($ReportDefinitions.ReportsAD.EventBased.UserChanges.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "User Changes Report." -Color White, Green, White, Green, White, Green, White
        $ExecutionTime = Start-TimeLog # Timer
        $UsersEventsTable = Get-UserChanges -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.UserChanges.IgnoreWords
        $script:TimeToGenerateReports.Reports.UserChanges.Total = Stop-TimeLog -Time $ExecutionTime
        Write-Color @script:WriteParameters "[i] Ending ", "User Changes Report." -Color White, Green, White, Green, White, Green, White
    }
    if ($ReportDefinitions.ReportsAD.EventBased.UserStatus.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "User Statues Report." -Color White, Green, White, Green, White, Green, White
        $ExecutionTime = Start-TimeLog # Timer
        $UsersEventsStatusesTable = Get-UserStatuses -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.UserStatus.IgnoreWords
        $script:TimeToGenerateReports.Reports.UserStatus.Total = Stop-TimeLog -Time $ExecutionTime
        Write-Color @script:WriteParameters "[i] Ending ", "User Statues Report." -Color White, Green, White, Green, White, Green, White
    }
    If ($ReportDefinitions.ReportsAD.EventBased.UserLockouts.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "User Lockouts Report." -Color White, Green, White, Green, White, Green, White
        $ExecutionTime = Start-TimeLog # Timer
        $UsersLockoutsTable = Get-UserLockouts -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.UserLockouts.IgnoreWords
        $script:TimeToGenerateReports.Reports.UserLockouts.Total = Stop-TimeLog -Time $ExecutionTime
        Write-Color @script:WriteParameters "[i] Ending ", "User Lockouts Report." -Color White, Green, White, Green, White, Green, White
    }
    if ($ReportDefinitions.ReportsAD.EventBased.UserLogon.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "Logon Events Report." -Color White, Green, White, Green, White, Green, White
        $ExecutionTime = Start-TimeLog # Timer
        $LogonEvents = Get-LogonEvents -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.UserLogon.IgnoreWords
        $script:TimeToGenerateReports.Reports.UserLogon.Total = Stop-TimeLog -Time $ExecutionTime
        Write-Color @script:WriteParameters "[i] Ending ", "Logon Events Report." -Color White, Green, White, Green, White, Green, White
    }
    if ($ReportDefinitions.ReportsAD.EventBased.UserLogonKerberos.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "Logon Events (Kerberos) Report." -Color White, Green, White, Green, White, Green, White
        $ExecutionTime = Start-TimeLog # Timer
        $LogonEventsKerberos = Get-LogonEventsKerberos -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.UserLogonKerberos.IgnoreWords
        $script:TimeToGenerateReports.Reports.UserLogonKerberos.Total = Stop-TimeLog -Time $ExecutionTime
        Write-Color @script:WriteParameters "[i] Ending ", "Logon Events (Kerberos) Report." -Color White, Green, White, Green, White, Green, White
    }
    ### USER EVENTS END ###

    if ($ReportDefinitions.ReportsAD.EventBased.GroupMembershipChanges.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "Group Membership Changes Report" -Color White, Green, White, Green, White, Green, White
        $ExecutionTime = Start-TimeLog # Timer St
        $GroupsEventsTable = Get-GroupMembershipChanges -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.GroupMembershipChanges.IgnoreWords
        $script:TimeToGenerateReports.Reports.GroupMembershipChanges.Total = Stop-TimeLog -Time $ExecutionTime
        Write-Color @script:WriteParameters "[i] Ending ", "Group Membership Changes Report." -Color White, Green, White, Green, White, Green, White
    }
    if ($ReportDefinitions.ReportsAD.EventBased.GroupCreateDelete.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "Group Create/Delete Report." -Color White, Green, White, Green, White, Green, White
        $ExecutionTime = Start-TimeLog # Timer
        $GroupCreateDeleteTable = Get-GroupCreateDelete -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.GroupCreateDelete.IgnoreWords
        $script:TimeToGenerateReports.Reports.GroupCreateDelete.Total = Stop-TimeLog -Time $ExecutionTime
        Write-Color @script:WriteParameters "[i] Ending ", "Group Create/Delete Report." -Color White, Green, White, Green, White, Green, White
    }
    if ($ReportDefinitions.ReportsAD.EventBased.EventsReboots.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "Reboot Events Report (Troubleshooting Only)." -Color White, Green, White, Green, White, Green, White
        $ExecutionTime = Start-TimeLog # Timer
        $RebootEventsTable = Get-RebootEvents -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.EventsReboots.IgnoreWords
        $script:TimeToGenerateReports.Reports.EventsReboots.Total = Stop-TimeLog -Time $ExecutionTime
        Write-Color @script:WriteParameters "[i] Ending ", "Reboot Events Report (Troubleshooting Only)." -Color White, Green, White, Green, White, Green, White
    }
    if ($ReportDefinitions.ReportsAD.EventBased.GroupPolicyChanges.Enabled -eq $true) {
        Write-Color @script:WriteParameters "[i] Running ", "Group Policy Changes Report." -Color White, Green, White, Green, White, Green, White
        $ExecutionTime = Start-TimeLog # Timer
        $TableGroupPolicyChanges = Get-GroupPolicyChanges -Events $Events -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.GroupPolicyChanges.IgnoreWords
        $script:TimeToGenerateReports.Reports.GroupPolicyChanges.Total = Stop-TimeLog -Time $ExecutionTime
        Write-Color @script:WriteParameters "[i] Ending ", "Group Policy Changes Report." -Color White, Green, White, Green, White, Green, White
    }
    If ($ReportDefinitions.ReportsAD.EventBased.LogsClearedSecurity.Enabled -eq $true) {
        $ExecutionTime = Start-TimeLog # Timer Start
        Write-Color @script:WriteParameters "[i] Running ", "Who Cleared Logs Report." -Color White, Green, White, Green, White, Green, White
        $TableEventLogClearedLogs = Get-EventLogClearedLogs -Events $Events -Type 'Security' -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.LogsClearedSecurity.IgnoreWords
        Write-Color @script:WriteParameters "[i] Ending ", "Who Cleared Logs Report." -Color White, Green, White, Green, White, Green, White
        $script:TimeToGenerateReports.Reports.LogsClearedSecurity.Total = Stop-TimeLog -Time $ExecutionTime
    }
    If ($ReportDefinitions.ReportsAD.EventBased.LogsClearedOther.Enabled -eq $true) {
        $ExecutionTime = Start-TimeLog # Timer Start
        Write-Color @script:WriteParameters "[i] Running ", "Who Cleared Logs Report." -Color White, Green, White, Green, White, Green, White
        $TableEventLogClearedLogsOther = Get-EventLogClearedLogs -Events $Events -Type 'Other' -IgnoreWords $ReportDefinitions.ReportsAD.EventBased.LogsClearedOther.IgnoreWords
        Write-Color @script:WriteParameters "[i] Ending ", "Who Cleared Logs Report." -Color White, Green, White, Green, White, Green, White
        $script:TimeToGenerateReports.Reports.LogsClearedOther.Total = Stop-TimeLog -Time $ExecutionTime
    }

    Send-ToTeams -Events $UsersEventsTable -TeamsID $TeamsID
    Send-ToTeams -Events $UsersLockoutsTable -TeamsID $TeamsID
    Send-ToTeams -Events $UsersEventsStatusesTable -TeamsID $TeamsID
    Send-ToTeams -Events $TableGroupPolicyChanges -TeamsID $TeamsID
    Send-ToTeams -Events $TableEventLogClearedLogs -TeamsID $TeamsID
    Send-ToTeams -Events $TableEventLogClearedLogsOther -TeamsID $TeamsID
    Send-ToTeams -Events $GroupsEventsTable -TeamsID $TeamsID
    Send-ToTeams -Events $GroupCreateDeleteTable -TeamsID $TeamsID
    Send-ToTeams -Events $LogonEvents -TeamsID $TeamsID
    Send-ToTeams -Events $LogonEventsKerberos -TeamsID $TeamsID
    Send-ToTeams -Events $RebootEventsTable -TeamsID $TeamsID
}

function Send-ToTeams {
    [CmdletBinding()]
    param(
        [System.Object] $Events,
        [string] $TeamsID
    )
    if ($Events -ne $null) {
        foreach ($Event in $Events) {

            $MessageTitle = 'Active Directory Changes'
            [string] $ActivityTitle = $($Event.Action).Trim()
            if ($ActivityTitle -like '*added*') {
                $Color = [System.Drawing.Color]::Green
                $ActivityImageLink = 'https://raw.githubusercontent.com/EvotecIT/PSTeams/master/Links/Asset%20120.png'
            } elseif ($ActivityTitle -like '*remove*') {
                $Color = [System.Drawing.Color]::Red
                $ActivityImageLink = 'https://raw.githubusercontent.com/EvotecIT/PSTeams/master/Links/Asset%20130.png'
            } else {
                $Color = [System.Drawing.Color]::Yellow
                $ActivityImageLink = 'https://raw.githubusercontent.com/EvotecIT/PSTeams/master/Links/Asset%20140.png'
            }

            $Facts = @()
            foreach ($Property in $event.PSObject.Properties) {
                if ($Property.Value -ne $null -and $Property.Value -ne '') {
                    if ($Property.Name -eq 'When') {
                        $Facts += New-TeamsFact -Name $Property.Name -Value $Property.Value.DateTime
                    } else {
                        $Facts += New-TeamsFact -Name $Property.Name -Value $Property.Value
                    }
                }
            }

            $Section1 = New-TeamsSection `
                -ActivityTitle $ActivityTitle `
                -ActivityImageLink $ActivityImageLink `
                -ActivityDetails $Facts

            Write-Color @script:WriteParameters -Text "[i] Sending to teams MessageTitle: ", "$MessageTitle", " Action: ", "$Action" -Color White, Green, White, Green, White, Green, White, Yellow, White, Yellow
            Write-Color @script:WriteParameters -Text "[i] Sending to teams MessageType: ", "$MessageType", " MessageBody: ", "" -Color White, Green, White, Green, White, Green, White, Yellow, White, Yellow

            $Data = Send-TeamsMessage `
                -URI $TeamsID `
                -MessageTitle $MessageTitle `
                -Color $Color `
                -Sections $Section1 `
                -Supress $false `
                -Verbose
            Write-Color @script:WriteParameters -Text $Data
        }
    }
}
