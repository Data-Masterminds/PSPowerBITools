function Get-PSBIWorkspaceUser {

    <#
    .SYNOPSIS
        Get the users of the workspaces in Power BI

    .DESCRIPTION
        Get the users of the workspaces in Power BI

    .PARAMETER WorkspaceId
        The id of the workspace

    .PARAMETER WorkSpaceName
        The name of the workspace

    .PARAMETER Detailed
        If this switch is enabled, the detailed information of the users will be returned.

    # .PARAMETER EnableException
    #     By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
    #     This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
    #     Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

    .PARAMETER WhatIf
        If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.

    .PARAMETER Confirm
        If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.

    .NOTES
        Author: Sander Stad
        Website: http://datamasterminds.io

    .EXAMPLE
        Get-PSBIWorkspaceUser -WorkspaceId '12345678-1234-1234-1234-123456789012'

        Get the users of the workspace with the id '12345678-1234-1234-1234-123456789012'

    .EXAMPLE
        Get-PSBIWorkspaceUser -WorkspaceName 'My Workspace'

        Get the users of the workspace with the name 'My Workspace'

    .EXAMPLE
        Get-PSBIWorkspaceUser -Detailed

        Get the users of all the workspaces in the organization with detailed information

    #>

    [CmdletBinding()]

    param (
        [Parameter()]
        [string[]]$WorkspaceId,
        [string[]]$WorkspaceName,
        [switch]$Detailed
    )

    begin {
        if ($WorkspaceId) {
            [array]$Workspace = Get-PowerBIWorkspace -Id $WorkspaceId
        }
        elseif ($WorkspaceName) {
            [array]$Workspace = Get-PowerBIWorkspace -Name $WorkspaceName
        }
        else {
            [array]$Workspace = Get-PowerBIWorkspace -Scope Organization
        }
    }

    process {
        $workspaces = @()

        foreach ($ws in $Workspace) {
            # Reset the objects
            $wsObject = [PSCustomObject]@{
                Id    = $null
                Name  = $null
                Users = $null
            }

            # # Get the users of the workspace
            # try {
            #     $wsUsers += (Invoke-PowerBIRestMethod -Url "Groups/$($ws.Id)/users" -Method Get -ErrorAction SilentlyContinue | ConvertFrom-Json).Value
            # }
            # catch {
            #     Stop-PSFFunction -Message "Something went wrong retrieving the users of the workspace with the id '$($ws.Id)'`n$($_.Exception.Message)" -EnableException:$EnableException
            # }

            # Add the users to the workspace object
            if ($Detailed) {
                $wsObject = [PSCustomObject]@{
                    Id    = $ws.Id
                    Name  = $ws.Name
                    Users = $ws.Users
                }
            }
            else {
                $wsObject = [PSCustomObject]@{
                    Id    = $ws.Id
                    Name  = $ws.Name
                    Users = $ws.Users | Select-Object -ExpandProperty identifier
                }
            }

            # Add the workspace object to the array
            $workspaces += $wsObject
        }
    }

    end {
        # Return the workspaces
        return $workspaces
    }

}