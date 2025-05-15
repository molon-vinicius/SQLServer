/* Script to search for an object in every database */
declare @nameObj nvarchar(100) = 'fn'; 
declare @typeObj char(1) = 'F'; -- 'F' = Function | 'P' = Procedure | 'V' = View | 'T' = Trigger

declare @aux nvarchar(100);
set @aux = case when @typeobj = 'f' 
                then '''fn'',''if'',''tf''' 
                when @typeobj = 'p' 
                then '''p'',''pc'''
                when @typeobj = 'v' 
                then '''v'''
                when @typeobj = 't' 
                then '''tr'''
                else ''
           end;

if object_id('tempdb..##Result') is not null drop table ##Result;

create table ##Result 
            (DatabaseName sysname
            ,SchemaName sysname
            ,ObjectName sysname
            ,ObjectType nvarchar(60))

declare @SQLCommand nvarchar(max) = '
if ''?'' not in (''model'',''tempdb'')
begin
    insert into ##Result
    select ''?''       as DatabaseName
         , s.name      as SchemaName
         , o.name      as ObjectName
         , o.type_desc as ObjectType
    from [?].sys.objects o
    join [?].sys.schemas s ON o.schema_id = s.schema_id
   where o.type in (' + @aux + ')
     and o.name like ''%' + @nameObj + '%''
end
';

select @sqlCommand
exec sp_msforeachdb @SQLCommand;

    select DatabaseName
         , SchemaName
         , ObjectName
         , ObjectType
      from ##Result
     order by DatabaseName, SchemaName, ObjectName;
