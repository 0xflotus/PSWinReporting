Import-Module .\..\PsWinReporting.psd1 -Force
Import-Module PSEventViewer -Force
Import-Module PSSharedGoods -Force

$Events = Find-Events -Report GroupMembershipChanges -DatesRange CurrentMonth -Servers AD1   #-Server AD1, AD2 #-Verbose
$Events | Format-Table -Property * #-AutoSize
#$Events | Out-GridView
