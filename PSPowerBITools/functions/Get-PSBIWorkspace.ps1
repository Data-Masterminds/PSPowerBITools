function Get-PSBIWorkspace {

    <#
    .SYNOPSIS
        Get the workspaces in Power BI

    .DESCRIPTION
        Get the workspaces in Power BI

    .PARAMETER WorkspaceId
        The id of the workspace

    .PARAMETER WorkspaceName
        The name of the workspace

    .PARAMETER Detailed
        If this switch is enabled, the detailed information of the workspaces will be returned.

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
        Get-PSBIWorkspace

        Get the workspaces in the organization

    .EXAMPLE
        Get-PSBIWorkspace -WorkspaceId '12345678-1234-1234-1234-123456789012'

        Get the workspace with the id '12345678-1234-1234-1234-123456789012'

    .EXAMPLE
        Get-PSBIWorkspace -WorkspaceName 'My Workspace'

        Get the workspace with the name 'My Workspace'

    .EXAMPLE
        Get-PSBIWorkspace -Detailed

        Get the workspaces in the organization with detailed information

    #>

    [CmdletBinding()]

    param (
        [Parameter()]
        [string[]]$WorkspaceId,
        [string[]]$WorkspaceName,
        [switch]$Detailed,
        [switch]$EnableException
    )

    begin {
        try {
            if (-not $Workspace) {
                [array]$Workspace = Get-PowerBIWorkspace -Scope Organization
            }
            elseif ($WorkspaceId) {
                [array]$Workspace = Get-PowerBIWorkspace -Id $WorkspaceId
            }
            elseif ($WorkspaceName) {
                [array]$Workspace = Get-PowerBIWorkspace -Name $WorkspaceName
            }
        }
        catch {
            Stop-PSFFunction -Message "Something went wrong retrieving the workspace(s)`n$($_.Exception.Message)" -EnableException:$EnableException
        }
    }

    process {
        # Create an array to store the workspaces
        $workspaces = @()

        # Loop through the workspaces and get the detailed information
        foreach ($ws in $Workspace) {
            if ($Detailed) {
                $wsObject = [PSCustomObject]@{
                    Id                    = $ws.Id
                    Name                  = $ws.Name
                    CapacityId            = $ws.CapacityId
                    Type                  = $ws.Type
                    Dashboards            = $ws.Dashboards
                    Dataflows             = $ws.Dataflows
                    Datasets              = $ws.Datasets
                    Reports               = $ws.Reports
                    Workbooks             = $ws.Workbooks
                    Users                 = $ws.Users
                    IsReadOnly            = $ws.IsReadOnly
                    IsOnDedicatedCapacity = $ws.IsOnDedicatedCapacity
                    IsOrphaned            = $ws.IsOrphaned
                }
            }
            else {
                $wsObject = [PSCustomObject]@{
                    Id                    = $ws.Id
                    Name                  = $ws.Name
                    CapacityId            = $ws.CapacityId
                    Type                  = $ws.Type
                    Dashboards            = $ws.Dashboards.Count
                    Dataflows             = $ws.Dataflows.Count
                    Datasets              = $ws.Datasets.Count
                    Reports               = $ws.Reports.Count
                    Workbooks             = $ws.Workbooks.Count
                    Users                 = $ws.Users.Count
                    IsReadOnly            = $ws.IsReadOnly
                    IsOnDedicatedCapacity = $ws.IsOnDedicatedCapacity
                    IsOrphaned            = $ws.IsOrphaned
                }
            }

            # Add the workspace to the array
            $workspaces += $wsObject
        }
    }

    end {
        return $workspaces
    }

}