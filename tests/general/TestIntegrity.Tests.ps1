Describe "Validate test integrity" {
    BeforeAll {
        $global:moduleRoot = Join-PSFPath -Path $PSScriptRoot "\..\..\" -Normalize
    }

    Context "Test available unit tests" {
        It "All functions should have a unit test" {
            # Get all the files
            $params = @{
                Path    = @((Join-PSFPath -Path $global:moduleRoot "PSPowerBITools" "functions"), (Join-PSFPath -Path $global:moduleRoot "PSPowerBITools" "internal" "functions"))
                Recurse = $true
                File    = $true
            }
            [string[]]$functionFiles = Get-ChildItem @params | Where-Object Name -Like "*.ps1" | Select-Object -ExpandProperty BaseName

            $params = @{
                Path    = Join-PSFPath -Path $global:moduleRoot "tests" "functions"
                Recurse = $true
                File    = $true
            }
            [string[]]$testFiles = Get-ChildItem @params | Where-Object Name -Like "*.Tests.ps1" | Select-Object -ExpandProperty BaseName

            # Cleanup the values to only have the function name
            $functionFiles = $functionFiles -replace ".ps1", ""
            $testFiles = $testFiles -replace ".Tests", ""

            $compare = (Compare-Object -ReferenceObject $functionFiles -DifferenceObject $testFiles | Where-Object SideIndicator -Like '<=').InputObject
            $compare | Should -BeNullOrEmpty
        }
    }
}