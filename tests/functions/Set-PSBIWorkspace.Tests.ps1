$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

Describe "$CommandName Unit Tests" -Tag 'UnitTests' {
    BeforeAll {
        $CommandName = 'Set-PSBIWorkspace'
    }

    Context "Validate known parameters" {
        It "Should only contain our specific parameters" {
            [string[]]$params = (Get-Command $CommandName).Parameters.Keys | Where-Object { $_ -notin ('whatif', 'confirm') }

            [string[]]$knownParameters = 'WorkspaceId', 'WorkspaceName', 'Name', 'CapacityId'
            $knownParameters += [System.Management.Automation.PSCmdlet]::CommonParameters

            (@(Compare-Object -ReferenceObject ($knownParameters | Where-Object { $_ }) -DifferenceObject $params).Count ) | Should -Be 0
        }

        It "Should have the correct parameters" {
            Get-Command $CommandName | Should -HaveParameter WorkspaceId -Type string[]
            Get-Command $CommandName | Should -HaveParameter WorkspaceName -Type string[]
            Get-Command $CommandName | Should -HaveParameter Name -Type string
            Get-Command $CommandName | Should -HaveParameter CapacityId -Type string
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