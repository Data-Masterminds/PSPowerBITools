﻿function Get-PSBIWorkspace {

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

    .PARAMETER Top
        The number of items to return. Maximum is 5000 based on the documentation of the API.

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
        [int]$Top = 5000,
        [switch]$EnableException
    )

    begin {
        # $workspaces = @()
        # try {
        #     if (-not $WorkspaceId -and -not $WorkspaceName) {
        #         $workspaces += Get-PowerBIWorkspace -Scope Organization
        #     }
        #     else {
        #         foreach ($WId in $WorkspaceId) {
        #             $guid = [guid]::Parse($WId)
        #             $workspaces += Get-PowerBIWorkspace -Id $guid -Scope Organization
        #         }

        #         foreach ($WName in $WorkspaceName) {
        #             $workspaces += Get-PowerBIWorkspace -Name $WName -Scope Organization
        #         }
        #     }
        # }
        # catch {
        #     Stop-PSFFunction -Message "Something went wrong retrieving the workspace(s)`n$($_.Exception.Message)" -EnableException:$EnableException
        # }

        # Set the uri

        # Filter the workspaces if the IsOrphaned switch is enabled
        if ($IsOrphaned) {
            $uri = "https://api.powerbi.com/v1.0/myorg/admin/groups?`$expand=dashboards,datasets,dataflows,reports,users&`$top=$($Top)&&$filter=(not users/any()) or (not users/any(u: u/groupUserAccessRight eq Microsoft.PowerBI.ServiceContracts.Api.GroupUserAccessRight'Admin'))"
            #$workspaces = $workspaces | Where-Object { $_.IsOrphaned -eq $true }
        }
        else {
            $uri = "https://api.powerbi.com/v1.0/myorg/admin/groups?`$expand=dashboards,datasets,dataflows,reports,users&`$top=$($Top)"
        }

        $workspaces = (Invoke-PowerBIRestMethod -Url $uri -Method Get | ConvertFrom-Json).value
    }

    process {
        # Loop through the workspaces and get the detailed information
        foreach ($ws in $workspaces) {
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