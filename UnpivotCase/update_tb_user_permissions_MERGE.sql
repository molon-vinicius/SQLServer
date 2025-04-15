use [master]

declare @user int = 1 
declare @targetTable varchar(50) = '[master].[dbo].[tb_user_permissions_MERGE]'

/* get the information of the source table through the 'userID' */
if object_id('TEMPDB..#TEMP_PERM') is not null drop table #TEMP_PERM

     select permission, active
       into #TEMP_PERM
       from [master].[dbo].[tb_user_permissions] with(nolock)
      where [userID] = @user

declare @cols nvarchar(max)
declare @SQL  nvarchar(max)

/* concat all the columns in a string variable with comma as separator and use it to create the global temp table ##TEMP_RESULT dynamically*/  
select @cols = stuff((
    select distinct ',' + quotename(permission)
      from #TEMP_PERM
       for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, '');
	
declare @SQLtable nvarchar(max) = 
'if object_id(''TEMPDB..##TEMP_RESULT'') is not null drop table ##TEMP_RESULT;

create table ##TEMP_RESULT (
    ' + replace(@cols, ',', ' varchar(1),') + ' varchar(1));'

exec sp_executesql @SQLtable;

/* the command 'select * from ##TEMP_RESULT' here will return the table empty 
   but the values in column 'permission' of the temp table ##TEMP_PERM now are the name of the columns */

/* inserting the status of each permission in the ##TEMP_RESULT */
set @SQL = '
insert into ##TEMP_RESULT
select ' + @cols + '
from 
(
    select permission, active
      from #TEMP_PERM
) as sourceTable
pivot
(
    max(active)
    for permission in (' + @cols + ')
) as pivotTable;
';
 
exec sp_executesql @SQL;

/* creating the variables to build the 'merge' command */
declare @perm nvarchar(150)
declare @merge_update nvarchar(max) =  
    'declare @user int = ' + convert(varchar(10),@user)  + char(13) +
    'merge ' + @targetTable + ' as target '              + char(13) +
    'using ##TEMP_RESULT        as source '              + char(13) +
      'on ( @user = target.[userID] )'                   + char(13) +
     'when matched'                                      + char(13) +
     'then update'                                       + char(13) +
      'set '

declare @merge_insert_cols nvarchar(MAX) = 	  
  ' when not matched by target then 
    insert (userID ' + char(13) + ','

declare @merge_insert_values nvarchar(MAX) = 
') values (' + convert(varchar(10), @user) + char(13) + ','

declare @SQL_merge nvarchar(MAX)

while (select count([permission]) as qtd from #TEMP_PERM) > 0
begin

   select @perm = MIN([permission]) from #TEMP_PERM     

      set @merge_update = @merge_update 
	    + 'target.' + @perm + ' = source.' + @perm + char(13) + ','

      set @merge_insert_cols = @merge_insert_cols
	    + @perm + char(13) + ','

      set @merge_insert_values = @merge_insert_values 
	    + 'source.' + @perm + char(13) + ','

    delete from #TEMP_PERM where [permission] = @perm

end

 set @merge_update = substring(@merge_update,0,len(@merge_update)-1)
 set @merge_insert_cols = substring(@merge_insert_cols,0,len(@merge_insert_cols)-1)
 set @merge_insert_values = substring(@merge_insert_values,0,len(@merge_insert_values)-1)
 set @merge_insert_values = replace(@merge_insert_values,'source.userID',@user)

 select @SQL_merge = concat(@merge_update, @merge_insert_cols, @merge_insert_values,');')

exec sp_executesql @SQL_merge;

