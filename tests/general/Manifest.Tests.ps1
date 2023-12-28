$moduleRoot = Join-PSFPath -Path $PSScriptRoot "\..\..\PSPowerBITools" -Normalize

Describe "Validating the module manifest" {
	#$global:moduleRoot = (Resolve-Path "$global:testroot\..").Path
	#$manifest = ((Get-Content (Join-Path -Path $global:moduleRoot -ChildPath "PSPowerBITools.psd1")) -join "`n") | Invoke-Expression

	$manifestFile = (Get-ChildItem PSPowerBITools.psd1 -Recurse).FullName
	$manifest = ((Get-Content ($manifestFile)) -join "`n") | Invoke-Expression
	Context "Basic resources validation" {
		#$files = Get-ChildItem (Join-Path -Path $global:moduleRoot -ChildPath "functions") -Recurse -File | Where-Object Name -like "*.ps1"
		$files = Get-ChildItem (Join-Path -Path $moduleRoot -ChildPath "functions") -Recurse -File | Where-Object Name -Like "*.ps1"
		It "Exports all functions in the public folder" -TestCases @{ files = $files; manifest = $manifest } {

			$functions = (Compare-Object -ReferenceObject $files.BaseName -DifferenceObject $manifest.FunctionsToExport | Where-Object SideIndicator -Like '<=').InputObject
			$functions | Should -BeNullOrEmpty
		}
		It "Exports no function that isn't also present in the public folder" -TestCases @{ files = $files; manifest = $manifest } {
			$functions = (Compare-Object -ReferenceObject $files.BaseName -DifferenceObject $manifest.FunctionsToExport | Where-Object SideIndicator -Like '=>').InputObject
			$functions | Should -BeNullOrEmpty
		}

		#It "Exports none of its internal functions" -TestCases @{ moduleRoot = $global:moduleRoot; manifest = $manifest } {
		It "Exports none of its internal functions" -TestCases @{ moduleRoot = $moduleRoot; manifest = $manifest } {
			#$files = Get-ChildItem (Join-Path -Path $global:moduleRoot -ChildPath "internal/functions") -Recurse -File -Filter "*.ps1"
			$files = Get-ChildItem (Join-Path -Path (Get-ChildItem Internal -Recurse).FullName -ChildPath "functions") -Recurse -File -Filter "*.ps1"
			$files | Where-Object BaseName -In $manifest.FunctionsToExport | Should -BeNullOrEmpty
		}
	}

	Context "Individual file validation" {
		#It "The root module file exists" -TestCases @{ moduleRoot = $global:moduleRoot; manifest = $manifest } {
		It "The root module file exists" -TestCases @{ moduleRoot = $moduleRoot; manifest = $manifest } {
			Test-Path (Join-Path -Path $moduleRoot -ChildPath "$($manifest.RootModule)") | Should -Be $true
		}

		foreach ($format in $manifest.FormatsToProcess) {
			#It "The file $format should exist" -TestCases @{ moduleRoot = $global:moduleRoot; format = $format } {
			It "The file $format should exist" -TestCases @{ moduleRoot = $moduleRoot; format = $format } {
				Test-Path (Join-Path -Path $moduleRoot -ChildPath "$format") | Should -Be $true
			}
		}

		foreach ($type in $manifest.TypesToProcess) {
			#It "The file $type should exist" -TestCases @{ moduleRoot = $global:moduleRoot; type = $type } {
			It "The file $type should exist" -TestCases @{ moduleRoot = $moduleRoot; type = $type } {
				Test-Path (Join-Path -Path $moduleRoot -ChildPath "$type") | Should -Be $true
			}
		}

		foreach ($assembly in $manifest.RequiredAssemblies) {
			if ($assembly -like "*.dll") {
				#It "The file $assembly should exist" -TestCases @{ moduleRoot = $global:moduleRoot; assembly = $assembly } {
				It "The file $assembly should exist" -TestCases @{ moduleRoot = $moduleRoot; assembly = $assembly } {
					Test-Path (Join-Path -Path $moduleRoot -ChildPath "$assembly") | Should -Be $true
				}
			}
			else {
				#It "The file $assembly should load from the GAC" -TestCases @{ moduleRoot = $global:moduleRoot; assembly = $assembly } {
				It "The file $assembly should load from the GAC" -TestCases @{ moduleRoot = $moduleRoot; assembly = $assembly } {
					{ Add-Type -AssemblyName $assembly } | Should -Not -Throw
				}
			}
		}

		foreach ($tag in $manifest.PrivateData.PSData.Tags) {
			It "Tags should have no spaces in name" -TestCases @{ tag = $tag } {
				$tag -match " " | Should -Be $false
			}
		}
	}
}