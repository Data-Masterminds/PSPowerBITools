function Get-PSBIAppUser {

    <#
    .SYNOPSIS
        Get the users of the apps in Power BI

    .DESCRIPTION
        Get the users of the apps in Power BI

    .PARAMETER AppName
        The name of the app

    .PARAMETER AppId
        The id of the app

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
        [string]$AppName,
        [string]$AppId,
        [switch]$EnableException
    )

    begin {
        try {
            # Get the apps
            if ($AppName) {
                [array]$apps = Invoke-PowerBIRestMethod -Url 'Apps' -Method Get | ConvertFrom-Json | Where-Object { $_.name -eq $AppName }
            }
            elseif ($AppId) {
                [array]$apps = Invoke-PowerBIRestMethod -Url "Apps/$($appId)" -Method Get | ConvertFrom-Json
            }
            else {
                [array]$apps = Invoke-PowerBIRestMethod -Url 'Apps' -Method Get | ConvertFrom-Json
            }
        }
        catch {
            Stop-PSFFunction -Message "Could not get the apps from Power BI.`n$_" -EnableException:$EnableException
        }

    }

    process {
        if (Test-PSFFunctionInterrupt) { return }

        if ($apps.Count -ge 1) {
            $appUsers = @()

            foreach ($app in $apps) {
                # Get the workspace name
                $workspace = Invoke-PowerBIRestMethod -Url "groups/$($app.workspaceId)" -Method Get | ConvertFrom-Json

                # Add the workspace name to the app object
                $app | Add-Member -MemberType NoteProperty -Name WorkspaceName -Value $workspace.name -Force

                # Get the users of the app
                foreach ($user in $app.users) {
                    $appUser = [PSCustomObject]@{
                        AppId             = $app.id
                        AppName           = $app.name
                        WorkspaceId       = $app.workspaceId
                        WorkspaceName     = $workspace.name
                        UserPrincipalName = $user.userPrincipalName
                        AccessRight       = $user.accessRight
                    }

                    # Add the app user to the array
                    $appUsers += $appUser
                }
            }
        }
        else {
            Write-PSFMessage -Message "No apps found in Power BI." -Level Warning
        }
    }

    end {
        if (Test-PSFFunctionInterrupt) { return }

        # Return the app users
        return $appUsers
    }
}