$filename = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

Describe "First responder blitz checks" -Tags Blitz, $filename {
    $frkdb = Get-DbcConfigValue policy.frk.database
}