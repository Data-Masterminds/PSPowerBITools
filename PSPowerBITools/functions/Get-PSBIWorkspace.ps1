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

    .PARAMETER IsOrphaned
        If this switch is enabled, only the orphaned workspaces will be returned.

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

    .EXAMPLE
        Get-PSBIWorkspace -IsOrphaned

        Get the orphaned workspaces in the organization

    #>

    [CmdletBinding()]

    param (
        [Parameter()]
        [string[]]$WorkspaceId,
        [string[]]$WorkspaceName,
        [switch]$IsOrphaned,
        [switch]$Detailed,
        [switch]$EnableException
    )

    begin {
        $workspaces = @()
        try {
            if (-not $WorkspaceId -and -not $WorkspaceName) {
                $workspaces += Get-PowerBIWorkspace -Scope Organization
            }
            else {
                foreach ($WId in $WorkspaceId) {
                    $guid = [guid]::Parse($WId)
                    $workspaces += Get-PowerBIWorkspace -Id $guid
                }

                foreach ($WName in $WorkspaceName) {
                    $workspaces += Get-PowerBIWorkspace -Name $WName
                }
            }
        }
        catch {
            Stop-PSFFunction -Message "Something went wrong retrieving the workspace(s)`n$($_.Exception.Message)" -EnableException:$EnableException
        }

        # Filter the workspaces if the IsOrphaned switch is enabled
        if ($IsOrphaned) {
            $workspaces = $workspaces | Where-Object { $_.IsOrphaned -eq $true }
        }
    }

    process {
        # Create an array to store the workspaces
        $wsResult = @()

        # Loop through the workspaces and get the detailed information
        foreach ($ws in $workspaces) {

            $dashboards = Get-PowerBIDashboard -Scope Organization -WorkspaceId $ws.Id
            $dataFlows = Get-PowerBIDataflow -Scope Organization -WorkspaceId $ws.Id
            $dataSets = Get-PowerBIDataset -Scope Organization -WorkspaceId $ws.Id
            $reports = Get-PowerBIReport -Scope Organization -WorkspaceId $ws.Id

            if ($Detailed) {
                $wsObject = [PSCustomObject]@{
                    Id                    = $ws.Id
                    Name                  = $ws.Name
                    CapacityId            = $ws.CapacityId
                    Type                  = $ws.Type
                    Dashboards            = $dashboards
                    Dataflows             = $dataFlows
                    Datasets              = $dataSets
                    Reports               = $reports
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
                    Dashboards            = $dashboards.Count
                    Dataflows             = $dataFlows.Count
                    Datasets              = $dataSets.Count
                    Reports               = $ws.Reports.Count
                    Users                 = $ws.Users.Identifier.Count
                    IsReadOnly            = $ws.IsReadOnly
                    IsOnDedicatedCapacity = $ws.IsOnDedicatedCapacity
                    IsOrphaned            = $ws.IsOrphaned
                }
            }

            # Add the workspace to the array
            $wsResult += $wsObject
        }
    }

    end {
        return $wsResult
    }

}