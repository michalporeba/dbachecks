function Get-InstanceConfig {
    param (
        [DbaInstanceParameter[]]$SqlInstance,
        [String]$ConfigName
    )
    begin {
        if (!(test-path variable:script:results)) {
            $script:results = @{}
        }
    }
    process {
        foreach ($instance in $SqlInstance) {
            try {
                if (!($script:results.ContainsKey($instance))) {
                    $server = Connect-DbaInstance -SqlInstance $instance -SqlCredential $sqlcredential

                    $configValues = Get-DbaSpConfigure -SqlInstance $instance 

                    foreach($db in $dbs) {
                        $db | Add-Member -Force -MemberType NoteProperty -Name InstanceCompatibilityLevel -Value "$($server.VersionMajor)0"
                        $db | Add-Member -Force -MemberType NoteProperty -Name SqlInstance -Value $server.DomainInstanceName
                        $db | Add-Member -Force -MemberType NoteProperty -Name SqlVersion -Value $server.VersionMajor
                    }
                    
                    # make sure the -ExcludeDatabase of Invoke-DbcCheck is honoured
                    $script:results.Add($instance, $dbs.Where{($ExcludedDatabases -notcontains $PsItem.Database)})
                }

                return $script:results[$instance] | Where-Object { $ConfigName -eq $null -or $psItem.Name -eq $ConfigName }
            }
            catch {
                throw
            }
        }
    }
}
