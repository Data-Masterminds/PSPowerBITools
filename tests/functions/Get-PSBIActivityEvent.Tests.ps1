$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

Describe "$CommandName Unit Tests" -Tag 'UnitTests' {
    BeforeAll {
        $CommandName = 'Get-PSBIActivityEvent'
    }

    Context "Validate known parameters" {
        It "Should only contain our specific parameters" {
            [string[]]$params = (Get-Command $CommandName).Parameters.Keys | Where-Object { $_ -notin ('whatif', 'confirm') }

            [string[]]$knownParameters = 'StartDate', 'EndDate', 'Operation', 'UserId', 'ClientIP', 'IncludeOwnAction', 'EnableException'
            $knownParameters += [System.Management.Automation.PSCmdlet]::CommonParameters

            (@(Compare-Object -ReferenceObject ($knownParameters | Where-Object { $_ }) -DifferenceObject $params).Count ) | Should -Be 0
        }

        It "Should have the correct parameters" {
            Get-Command $CommandName | Should -HaveParameter StartDate -Type datetime
            Get-Command $CommandName | Should -HaveParameter EndDate -Type datetime
            Get-Command $CommandName | Should -HaveParameter Operation -Type string
            Get-Command $CommandName | Should -HaveParameter UserId -Type string
            Get-Command $CommandName | Should -HaveParameter ClientIP -Type string
            Get-Command $CommandName | Should -HaveParameter IncludeOwnAction -Type switch
            Get-Command $CommandName | Should -HaveParameter EnableException -Type switch
        }
    }
}

Describe "$CommandName Integration Tests" -Tags "IntegrationTests" {

    BeforeAll {

    }

    Context "Tests" {

    }

    AfterAll {

    }
}