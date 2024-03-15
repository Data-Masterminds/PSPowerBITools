$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

Describe "$CommandName Unit Tests" -Tag 'UnitTests' {
    BeforeAll {
        $CommandName = 'Test-PSBILogin'
    }

    Context "Validate known parameters" {
        <# It "Should only contain our specific parameters" {
            [string[]]$params = (Get-Command $CommandName).Parameters.Keys | Where-Object { $_ -notin ('whatif', 'confirm') }

            [string[]]$knownParameters = 'EnableException'
            $knownParameters += [System.Management.Automation.PSCmdlet]::CommonParameters

            (@(Compare-Object -ReferenceObject ($knownParameters | Where-Object { $_ }) -DifferenceObject $params).Count ) | Should -Be 0
        }

        It "Should have the correct parameters" {
            Get-Command $CommandName | Should -HaveParameter EnableException -Type switch
        } #>
    }
}

Describe "$CommandName Integration Tests" -Tags "IntegrationTests" {

    BeforeAll {

    }

    Context "Tests" {
        It "Should return a message that the login is valid" {
            $global:PowerBILogin = $true

            $result = Test-PSBILogin

            $result | Should -Be $true
        }

        It "Should return a message that the login is not valid" {
            $global:PowerBILogin = $null

            $result = Test-PSBILogin

            $result | Should -Be $false
        }
    }

    AfterAll {

    }
}