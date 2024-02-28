$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

Describe "$CommandName Unit Tests" -Tag 'UnitTests' {
    BeforeAll {
        $CommandName = 'Get-PSBIWorkspace'
    }

    Context "Validate known parameters" {
        It "Should only contain our specific parameters" {
            [string[]]$params = (Get-Command $CommandName).Parameters.Keys | Where-Object { $_ -notin ('whatif', 'confirm') }

            [string[]]$knownParameters = 'WorkspaceId', 'WorkspaceName', 'Detailed', 'EnableException'
            $knownParameters += [System.Management.Automation.PSCmdlet]::CommonParameters

            (@(Compare-Object -ReferenceObject ($knownParameters | Where-Object { $_ }) -DifferenceObject $params).Count ) | Should -Be 0
        }

        It "Should have the correct parameters" {
            Get-Command $CommandName | Should -HaveParameter WorkspaceId -Type string[]
            Get-Command $CommandName | Should -HaveParameter WorkspaceName -Type string[]
            Get-Command $CommandName | Should -HaveParameter Detailed -Type switch
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