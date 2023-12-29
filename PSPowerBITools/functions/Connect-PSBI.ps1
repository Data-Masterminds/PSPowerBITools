function Connect-PSBI {

    <#
    .SYNOPSIS
        Login to Power BI

    .DESCRIPTION
        Login to Power BI and sets the global variable $global:PowerBILogin

        To re-login with PowerBI set the configuration to reload the login:
            Set-PSFConfig -FullName PSPowerBITools.Login.Reload -Value $true
            Connect-PSBI
            Set-PSFConfig -FullName PSPowerBITools.Login.Reload -Value $false

    .PARAMETER Credential
        The credential to login with

    .PARAMETER Tenant
        The tenant id to login to

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
        Connect-PSBI

        Login to Power BI

    .EXAMPLE
        Connect-PSBI -AsServiceAccount

        Login to Power BI with a service account

    #>

    [CmdletBinding()]

    param (
        [pscredential]$Credential,
        [string]$Tenant,
        [switch]$EnableException
    )

    begin {
        $loginParams = @{}

        if ($Credential) {
            $loginParams.Credential = $Credential
        }

        if ($Tenant) {
            $loginParams.Tenant = $Tenant
        }
    }

    process {
        # Check if the user wants to reload the login
        if ((Get-PSFConfigValue -FullName PSPowerBITools.Login.Reload) -eq $true) {
            Remove-Variable -Name PowerBILogin -ErrorAction Ignore

            Disconnect-PowerBIServiceAccount
        }

        if ($global:PowerBILogin) {
            $messageParams = @{
                Message         = "The login of Power BI is already loaded. If you want to re-login, set the configuration 'PSPowerBITools.Login.Reload' to true. See help."
                Level           = 'Warning'
                EnableException = [bool]$EnableException
            }
            Write-PSFMessage @messageParams
        }
        else {
            # Load the login of Power BI
            $global:PowerBILogin = Connect-PowerBIServiceAccount @loginParams
        }
    }
}