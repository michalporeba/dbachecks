function Get-FrkVersion {
    param (
        [DbaInstanceParameter]$SqlInstance
    )
    $frkdb = Get-DbcConfigValue policy.frk.database

    $server = Connect-DbaInstance -SqlInstance $SqlInstance -SqlCredential $sqlcredential -Database $frkdb

    $sql = "
select object_id, [Name], modify_date ModifedOn, v.*
from sys.procedures p
outer apply (
    select 
            substring([definition], VersionIndex, charindex('''', [definition], VersionIndex)-VersionIndex) Version
        ,convert(date, substring([definition], VersionDateIndex, charindex('''', [definition], VersionDateIndex)-VersionDateIndex)) VersionDate
    from (
        select [definition]
            ,charindex('''', [definition], VersionIndex)+1 VersionIndex
            ,charindex('''', [definition], VersionDateIndex)+1 VersionDateIndex
        from (
            select 
                    [definition]
                ,charindex('SET @Version = ''', [definition]) VersionIndex
                ,charindex('SET @VersionDate = ''', [definition]) VersionDateIndex
            from sys.sql_modules m
            where m.object_id = p.object_id
        ) t
    ) t
) v
where type = 'P' 
and [Name] in (
        'sp_AllNightLog'
    ,'sp_AllNightLog_Setup'
    ,'sp_Blitz'
    ,'sp_BlitzBackups'
    ,'sp_BlitzCache'
    ,'sp_BlitzFirst'
    ,'sp_BlitzIndex'
    ,'sp_BlitzLock'
    ,'sp_BlitzQueryStore'
    ,'sp_BlitzWho'
    ,'sp_DatabaseRestore'
)"

    return $server.Query($sql)
}
