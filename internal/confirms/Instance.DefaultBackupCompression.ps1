. $PSScriptRoot/../internal/functions/Convert-ConfigValueToBoolean.ps1

function Get-ConfigForDefaultBackupCompressionCheck {
    return @{
        DefaultBackupCompression = (Get-DbcConfigValue policy.backup.defaultbackupcompression | Convert-ConfigValueToBoolean)
    }
}

function Confirm-DefaultBackupCompression {
    param (
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [object[]]$TestObject,
        [parameter(Mandatory=$true)][Alias("With")]
        [object]$config,
        [string]$Because
    )
    process {
        $TestObject.ConfiguredValue | Convert-ConfigValueToBoolean | Should -Be $config.DefaultBackupCompression -Because $Because 
        $TestObject.ConfiguredValue | Should -Be $config.RunningValue -Because "running config values should be the same as configured values when you test them"
    }
}
