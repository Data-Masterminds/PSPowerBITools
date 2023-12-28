[CmdletBinding()]
Param (
	[switch]
	$SkipTest,

	[string[]]
	$CommandPath
)

if ($SkipTest) {
 return
}

$global:__pester_data = @{ }
$global:__pester_data.ScriptAnalyzer = New-Object System.Collections.ArrayList

$testroot = Join-PSFPath -Path $PSScriptRoot "\..\" -Normalize

# Import the exclusions
#. "$global:testroot\general\PSScriptAnalyzer.Exceptions.ps1"
. (Join-PSFPath -Path $testroot "general" "PSScriptAnalyzer.Exceptions.ps1" -Normalize)

Describe 'Invoking PSScriptAnalyzer against commandbase' {
	if (-not $CommandPath) {
		#$CommandPath = @((Join-PSFPath -Path $global:testroot "\..\" "functions" -Normalize), (Join-PSFPath -Path $global:testroot "\..\" "internal" "functions" -Normalize))
		$CommandPath = @((Join-PSFPath -Path $testroot "\..\PSPowerBITools\" "functions" -Normalize), (Join-PSFPath -Path $testroot "\..\PSPowerBITools" "internal" "functions" -Normalize))
	}

	$commandFiles = Get-ChildItem -Path $CommandPath -Recurse | Where-Object Name -Like "*.ps1"
	$scriptAnalyzerRules = Get-ScriptAnalyzerRule

	foreach ($file in $commandFiles) {
		Context "Analyzing $($file.BaseName)" {
			# Get all the exclusions for this file
			$commandExcludes = $global:MayContainScriptAnalyzerError[$file.BaseName] + $global:ScriptAnalyzerExcludes

			# Run the analyser
			$analysis = Invoke-ScriptAnalyzer -Path $file.FullName -ExcludeRule $commandExcludes

			forEach ($rule in $scriptAnalyzerRules) {
				It "Should pass $rule" -TestCases @{ analysis = $analysis; rule = $rule } {
					If ($analysis.RuleName -contains $rule) {
						$analysis | Where-Object RuleName -EQ $rule -OutVariable failures | ForEach-Object { $null = $global:__pester_data.ScriptAnalyzer.Add($_) }

						1 | Should -Be 0
					}
					else {
						0 | Should -Be 0
					}
				}
			}
		}
	}
}