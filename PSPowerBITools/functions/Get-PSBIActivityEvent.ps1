function Get-PSBIActivityEvent {

    <#
    .SYNOPSIS
        Get the activity events in Power BI

    .DESCRIPTION
        Get the activity events in Power BI

    .PARAMETER StartDate
        The start date of the activity events

    .PARAMETER EndDate
        The end date of the activity events

    .PARAMETER Operation
        The operation of the activity event

    .PARAMETER UserId
        The user id of the activity event

    .PARAMETER ClientIP
        The client ip of the activity event

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
        Get-PSBIActivityEvent

        Get the activity events for the current day

    .EXAMPLE
        Get-PSBIActivityEvent -StartDate (Get-Date).AddDays(-1)

        Get the activity events for the previous day up to now

    .EXAMPLE
        Get-PSBIActivityEvent -StartDate (Get-Date).AddDays(-30) -EndDate (Get-Date).AddDays(-10)

        Get the activity events for 30 days ago up to 10 days ago
    #>

    [CmdletBinding()]

    param (
        [datetime]$StartDate,
        [datetime]$EndDate,
        [string]$Operation,
        [string]$UserId,
        [string]$ClientIP,
        [switch]$EnableException
    )

    begin {
        if (-not $StartDate) {
            $StartDate = (Get-Date)
        }

        if (-not $EndDate) {
            $EndDate = (Get-Date)
        }

        if ($StartDate -gt $EndDate) {
            Stop-PSFFunction -Message "The start date is greater than the end date. Please provide a valid date range."
        }
    }

    process {
        if (Test-PSFFunctionInterrupt) { return }

        $activityEvents = @()

        if ((New-TimeSpan -Start $StartDate -End $EndDate).Days -eq 0) {
            $StartDateString = $StartDate.ToString("yyyy-MM-ddT00:00:00Z")
            $EndDateString = $EndDate.ToString("yyyy-MM-ddT23:59:59Z")

            try {
                [array]$activityEvents += Get-PowerBIActivityEvent -StartDateTime $StartDateString -EndDateTime $EndDateString | ConvertFrom-Json
            }
            catch {
                Stop-PSFFunction -Message "Something went wrong retrieving the activity events.`n$($_.Exception.Message)" -EnableException:$EnableException
            }

        }
        else {
            $date = $StartDate
            while ($date -le $EndDate) {
                $StartDateString = $date.ToString("yyyy-MM-ddT00:00:00Z")
                $EndDateString = $date.ToString("yyyy-MM-ddT23:59:59Z")

                try {
                    $activityEvents += Get-PowerBIActivityEvent -StartDateTime $StartDateString -EndDateTime $EndDateString | ConvertFrom-Json
                }
                catch {
                    Stop-PSFFunction -Message $_.Exception.Message -EnableException:$EnableException
                }



                $date = $date.AddDays(1)
            }
        }

        if ($Operation) {
            $activityEvents = $activityEvents | Where-Object { $_.Operation -eq $Operation }
        }

        if ($UserId) {
            $activityEvents = $activityEvents | Where-Object { $_.UserId -eq $UserId }
        }

        if ($ClientIP) {
            $activityEvents = $activityEvents | Where-Object { $_.ClientIP -eq $ClientIP }
        }

    }

    end {
        return $activityEvents
    }

}