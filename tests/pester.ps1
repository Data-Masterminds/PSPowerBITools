param (
	[bool]$TestGeneral = $true,
	[bool]$TestFunctions = $true,
	[ValidateSet('None', 'Normal', 'Detailed', 'Diagnostic')]
	[Alias('Show')]
	[string]$Output = "None",
	[string]$Include = "*",
	[string]$Exclude = "",
	[string]$TestResultDirectory,
	[switch]$OutputTestResult
)

Write-PSFMessage -Level Important -Message "Starting Tests"

Write-PSFMessage -Level Important -Message "Importing Module"

#$global:testroot = $PSScriptRoot
#$global:__pester_data = @{ }
#$global:moduleRoot = Join-PSFPath -Path $PSScriptRoot "\..\" -Normalize

if ($null -eq $TestResultDirectory -or $TestResultDirectory -eq '') {
	$TestResultDirectory = (Join-PSFPath -Path $PSScriptRoot "testresults" -Normalize)
}

Remove-Module PSPowerBITools -ErrorAction Ignore

# If ever needed you can preimport the modules here
Import-Module PSframework


Import-Module (Join-PSFPath -Path $PSScriptRoot "\..\PSPowerBITools\PSPowerBITools.psd1" -Normalize) -Force -ErrorAction SilentlyContinue
Import-Module (Join-PSFPath -Path $PSScriptRoot "\..\PSPowerBITools\PSPowerBITools.psm1" -Normalize) -Force

# Need to import explicitly so we can use the configuration class
Import-Module Pester

$totalFailed = 0
$totalRun = 0

$testresults = @()
$config = [PesterConfiguration]::Default
$config.TestResult.OutputFormat = 'NUnitXml'

if ($OutputTestResult) {
	$config.TestResult.Enabled = $true

	if (-not (Test-Path -Path $TestResultDirectory)) {
		Write-PSFMessage -Level Important -Message "Creating test result directory <c='em'>$TestResultDirectory</c>"
		$null = New-Item -Path $TestResultDirectory -ItemType Directory -Force
	}
}


#region Run General Tests
if ($TestGeneral) {
	Write-PSFMessage -Level Important -Message "Modules imported, proceeding with general tests"
	foreach ($file in (Get-ChildItem "$(Join-Path -Path $PSScriptRoot -ChildPath "general")" | Where-Object Name -Like "*.Tests.ps1")) {
		if ($file.Name -notlike $Include) {
			continue
		}

		if ($file.Name -like $Exclude) {
			continue
		}

		Write-PSFMessage -Level Significant -Message "  Executing <c='em'>$($file.Name)</c>"
		$config.TestResult.OutputPath = Join-Path $testResultDirectory "TEST-$($file.BaseName).xml"
		$config.Run.Path = $file.FullName
		$config.Run.PassThru = $true
		$config.Output.Verbosity = $Output
		$results = Invoke-Pester -Configuration $config
		foreach ($result in $results) {
			$totalRun += $result.TotalCount
			$totalFailed += $result.FailedCount
			$result.Tests | Where-Object Result -NE 'Passed' | ForEach-Object {
				$testresults += [pscustomobject]@{
					Block   = $_.Block
					Name    = "It $($_.Name)"
					Result  = $_.Result
					Message = $_.ErrorRecord.DisplayErrorMessage
				}
			}
		}
	}
}
#endregion Run General Tests

#$global:__pester_data.ScriptAnalyzer | Out-Host

#region Test Commands
if ($TestFunctions) {
	Write-PSFMessage -Level Important -Message "Proceeding with individual tests"
	foreach ($file in (Get-ChildItem "$(Join-Path -Path $PSScriptRoot -ChildPath "functions")" -Recurse -File | Where-Object Name -Like "*Tests.ps1")) {
		if ($file.Name -notlike $Include) {
			continue
		}

		if ($file.Name -like $Exclude) {
			continue
		}

		Write-PSFMessage -Level Significant -Message "  Executing $($file.Name)"
		$config.TestResult.OutputPath = Join-Path $testResultDirectory "TEST-$($file.BaseName).xml"
		$config.Run.Path = $file.FullName
		$config.Run.PassThru = $true
		$config.Output.Verbosity = $Output
		$results = Invoke-Pester -Configuration $config
		foreach ($result in $results) {
			$totalRun += $result.TotalCount
			$totalFailed += $result.FailedCount
			$result.Tests | Where-Object Result -NE 'Passed' | ForEach-Object {
				$testresults += [pscustomobject]@{
					Block   = $_.Block
					Name    = "It $($_.Name)"
					Result  = $_.Result
					Message = $_.ErrorRecord.DisplayErrorMessage
				}
			}
		}
	}
}
#endregion Test Commands

$testresults | Sort-Object Describe, Context, Name, Result, Message | Format-List

if ($OutputTestResult) {
	$testFileCount = Get-ChildItem -Path $testResultDirectory -Filter "TEST-*.xml" | Measure-Object | Select-Object -ExpandProperty Count

	if ($testFileCount -lt 1) {
		Stop-PSFFunction -Message "No test results found in '$testResultDirectory'!" -EnableException:$true
	}
	else {
		Write-PSFMessage -Level Important -Message "Found <c='em'>$testFileCount</c> test result files in '$TestResultDirectory'!"
	}
}

if ($totalFailed -eq 0) {
	Write-PSFMessage -Level Critical -Message "All <c='em'>$totalRun</c> tests executed without a single failure!"
}
else {
	Write-PSFMessage -Level Critical -Message "<c='em'>$totalFailed tests</c> out of <c='sub'>$totalRun</c> tests failed!"
}

if ($totalFailed -gt 0) {
	throw "$totalFailed / $totalRun tests failed!"
}