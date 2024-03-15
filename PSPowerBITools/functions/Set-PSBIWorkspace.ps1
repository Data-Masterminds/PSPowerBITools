function Set-PSBIWorkspace {

    <#
    .SYNOPSIS
        Change information in a Power BI workspace

    .DESCRIPTION
        Change information in a Power BI workspace

    .PARAMETER WorkspaceId
        The id of the workspace

    .PARAMETER WorkspaceName
        The name of the workspace

    .PARAMETER Name
        The new name of the workspace

    .PARAMETER Description
        The new description of the workspace

    .PARAMETER CapacityId
        The id of the capacity the workspace should be on
    #>

    [CmdletBinding()]

    param(
        [string[]]$WorkspaceId,
        [string[]]$WorkspaceName,
        [string]$Name,
        [string]$CapacityId
    )

    begin {
        if (-not $WorkspaceId -and -not $WorkspaceName) {
            Stop-PSFFunction -Message "You need to specify either a WorkspaceId or a WorkspaceName"
        }

        $workspaces = @()

        # Get the workspace(s)
        if ($WorkspaceId) {
            $workspaces += Get-PSBIWorkspace -WorkspaceId $WorkspaceId -Verbose:$false
        }

        if ($WorkspaceName) {
            $workspaces += Get-PSBIWorkspace -WorkspaceName $WorkspaceName -Verbose:$false
        }
    }

    process {
        if (Test-PSFFunctionInterrupt) { return }

        if ($workspaces.Count -eq 0) {
            Write-PSFMessage -Level Host -Message "No workspace(s) found with the specified id(s) or name(s)"
            return
        }
        else {
            foreach ($workspace in $workspaces) {
                Write-PSFMessage -Level Verbose -Message "Changing information in workspace '$($workspace.Name)'"


                if ($Name) {
                    Write-PSFMessage -Level Verbose -Message "- Changing the name of the workspace to '$Name'"

                    # Set the url for the request
                    $url = "https://api.powerbi.com/v1.0/myorg/groups/$($workspace.Id)"

                    $body = @{
                        name = $Name
                    }

                    # Change the workspace
                    try {
                        $response = Invoke-PowerBIRestMethod -Url $url -Method Patch -Body $($body | ConvertTo-Json)
                    }
                    catch {
                        Stop-PSFFunction -Message "Something went wrong changing the name of the workspace`n$($_.Exception.Message)"
                    }
                }

                if ($CapacityId) {
                    Write-PSFMessage -Level Verbose -Message "- Changing the capacity of the workspace to '$CapacityId'"

                    # Set the url for the request
                    $url = "https://api.powerbi.com/v1.0/myorg/groups/$($workspace.Id)/AssignToCapacity"

                    $body = @{
                        capacityId = $CapacityId
                    }

                    # Change the workspace
                    try {
                        $response = Invoke-PowerBIRestMethod -Url $url -Method Post -Body $($body | ConvertTo-Json)
                    }
                    catch {
                        Stop-PSFFunction -Message "Something went wrong changing the capacity of the workspace`n$($_.Exception.Message)"
                    }
                }

            } # End of foreach ($workspace in $workspaces)
        } # End of else
    } # End of process

    end {

    }
}