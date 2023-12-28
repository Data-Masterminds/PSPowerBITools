function Get-PSBIAppUser {

    <#
    .SYNOPSIS
        Get the app users from the Power BI Service

    .DESCRIPTION
        Get the app users from the Power BI Service and returns a list of users.

    .PARAMETER param1


    .PARAMETER param2


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
        [Parameter()]
        [TypeName]$ParameterName,
        [switch]$EnableException
    )

    begin {

    }

    process {
        if (Test-PSFFunctionInterrupt) { return }
    }

    end {
        if (Test-PSFFunctionInterrupt) { return }
    }

}