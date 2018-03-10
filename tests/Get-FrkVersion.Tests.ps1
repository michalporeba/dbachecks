$commandname = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Write-Host -Object "Running $PSCommandpath" -ForegroundColor Cyan
. "$PSScriptRoot/../internal/functions/Get-FrkVersion.ps1"

$sqlinstance = "localhost"

Describe "Unit testing of $commandname" {
    InModuleScope dbachecks {
        Context "Get-FrkVersion depends on PSFConfiguration" {
            It "policy.frk.database needs to be set" {
                Get-DbcConfigValue policy.frk.database | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Describe "Integration testing of $commandname" -Tags IntegrationTests,SqlIntegrationTests,Integration {
    @($sqlinstance).ForEach{
        Context "Checking First Responder Kit Versions on $psitem" {
            It "Execution of Get-FrkVersion should not throw exceptions" {
                { Get-FrkVersion -SqlInstance $psitem } | Should -Not -Throw -Because "we expect data not exceptions"
            }
  
            It "Get-FrkVersion should return details of at least one stored procedure" {
                @(Get-FrkVersion -SqlInstance $psitem).Count | Should -BeGreaterOrEqual 1 -Because "we expect at least one stored procedure from the first responder kit"
            }

            It "Version information is collected for each FRK stored procedure" {
                @(Get-FrkVersion -SqlInstance $psitem).ForEach{
                    $psitem.Version | Should -Not -BeNullOrEmpty -Because "version information is important"
                    # if this doesn't work it is possible that the specific FRK script has changed.
                }
            }

            It "VersionDate information is collected for each FRK stored procedure" {
                @(Get-FrkVersion -SqlInstance $psitem).ForEach{
                    $psitem.VersionDate | Should -Not -BeNullOrEmpty -Because "version information is important"
                    # if this doesn't work it is possible that the specific FRK script has changed.
                }
            }
        }
    }
}