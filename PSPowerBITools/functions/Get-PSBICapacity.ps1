function Get-PSBICapacity {

    <#
    .SYNOPSIS
        Get the capacities in Power BI

    .DESCRIPTION
        Get the capacities in Power BI

    .PARAMETER State
        The state of the capacity

    .PARAMETER Sku
        The sku of the capacity

    .PARAMETER AsAdmin
        If this switch is enabled, the capacities will be returned as an admin

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
        [string]$State,
        [string]$Sku,
        [switch]$AsAdmin
    )

    begin {
        # Set the uri
        if ($AsAdmin) {
            $uri = "https://api.powerbi.com/v1.0/myorg/admin/capacities"
        }
        else {
            $uri = "https://api.powerbi.com/v1.0/myorg/capacities"
        }

        # Get the access token
        $headers = Get-PowerBIAccessToken
    }

    process {
        # Get the capacities
        try {
            $capacities = (Invoke-RestMethod -Uri $uri -Header $headers -Method Get).value
        }
        catch {
            if ($_.Exception.Response.StatusCode -eq 'Unauthorized') {
                Stop-PSFFunction -Message "You are not authorized to get the capacities. Please check your permissions." -Continue
            }
            else {
                Stop-PSFFunction -Message "An error occurred while getting the capacities. Please try again.`n$($_.Exception.Message)" -Continue
            }
        }

        # Filter the capacities
        if ($State) {
            $capacities = $capacities | Where-Object { $_.state -eq $State }
        }

        if ($Sku) {
            $capacities = $capacities | Where-Object { $_.sku -eq $Sku }
        }

        # Rename the properties
        $capacities | ForEach-Object {
            $id = $_.id
            $_.PSObject.Properties.Remove('id')
            $_ | Add-Member -MemberType NoteProperty -Name 'Id' -Value $id -Force

            $name = $_.displayName
            $_.PSObject.Properties.Remove('displayName')
            $_ | Add-Member -MemberType NoteProperty -Name 'Name' -Value $name -Force

            $sku = $_.sku
            $_.PSObject.Properties.Remove('sku')
            $_ | Add-Member -MemberType NoteProperty -Name 'Sku' -Value $sku -Force

            $state = $_.state
            $_.PSObject.Properties.Remove('state')
            $_ | Add-Member -MemberType NoteProperty -Name 'State' -Value $state -Force

            $region = $_.region
            $_.PSObject.Properties.Remove('region')
            $_ | Add-Member -MemberType NoteProperty -Name 'Region' -Value $region -Force

            $admins = $_.admins
            $_.PSObject.Properties.Remove('admins')
            $_ | Add-Member -MemberType NoteProperty -Name 'Admins' -Value $admins -Force

            $users = $_.users
            $_.PSObject.Properties.Remove('users')
            $_ | Add-Member -MemberType NoteProperty -Name 'Users' -Value $users -Force

            $useraccesright = $_.capacityUserAccessRight
            $_.PSObject.Properties.Remove('capacityUserAccessRight')
            $_ | Add-Member -MemberType NoteProperty -Name 'UserAccessRight' -Value $useraccesright -Force
        }

        return $capacities
    }

    end {

    }

}