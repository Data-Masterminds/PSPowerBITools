# Check if the user wants to reload the login
if ((Get-PSFConfigValue -FullName PSPowerBITools.Login.Reload) -eq $true) {
    Remove-Variable -Name PowerBILogin -Scope Global -ErrorAction Ignore
}
elseif ($global:PowerBILogin) {
    return
}
else {
    # Load the login of Power BI
    $global:PowerBILogin = Login-PowerBI
}

