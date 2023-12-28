function Test-PSBILogin {

    <#
    .SYNOPSIS
        Test the login of Power BI

    .DESCRIPTION
        Test if the current login of Power BI is still valid.

        To re-login with PowerBI set the configuration to reload the login:
            Set-PSFConfig -FullName PSPowerBITools.Login.Reload -Value $true

    .PARAMETER EnableException
        By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
        This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
        Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

    .PARAMETER WhatIf
        If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.

    .PARAMETER Confirm
        If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.

    .NOTES
        Author: Sander Stad
        Website: http://datamasterminds.io

    .EXAMPLE

    #>

    [CmdletBinding()]

    param (
        [switch]$EnableException
    )

    if ($global:PowerBILogin) {
        return $true
    }
    else {
        return $false
    }
}