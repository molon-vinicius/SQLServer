create or alter procedure USP_RESTORE_BKP_LOGINS

as 

/* This version executes the commands in [master] tables */
  
declare @aux numeric(15)
declare @SQL nvarchar(max)

if object_id('TEMPDB..#LOGINS')         is not null drop table #LOGINS
if object_id('TEMPDB..#LOGINS_FUNCOES') is not null drop table #LOGINS_FUNCOES
if object_id('TEMPDB..#LOGINS_GRANTS')  is not null drop table #LOGINS_GRANTS

create table #LOGINS
            ([bkp_login] numeric(15)
            ,[InsertDate] datetime
            ,[updateDate] datetime
            ,[Active] int
            ,[ServerName] varchar(100)
            ,[SID] varbinary(85)
            ,[LoginName] varchar(100)
            ,[SQLCommand] nvarchar(MAX))

create table #LOGINS_FUNCOES
            ([bkp_login_function] numeric(15) identity
            ,[InsertDate] datetime
            ,[updateDate] datetime
            ,[Active] int
            ,[ServerName] varchar(100)
            ,[SID] varbinary(85)
            ,[LoginID] numeric(15)
            ,[LoginName] varchar(100)
            ,[PermissionID] numeric(15)
            ,[PermissionName] varchar(100)
            ,[SQLCommand] nvarchar(MAX))

create table #LOGINS_GRANTS
            ([bkp_login_grant] numeric(15) identity
            ,[InsertDate] datetime
            ,[updateDate] datetime
            ,[Active] int
            ,[ServerName] varchar(100)            
            ,[SID] varbinary(85)
            ,[LoginName] varchar(100)
            ,[LoginType] varchar(30)
            ,[PermissionName] varchar(100)
            ,[SQLCommand] Nvarchar(MAX))

insert into #LOGINS
            ([bkp_login] 
            ,[InsertDate]
            ,[updateDate]
            ,[Active]
            ,[ServerName]
            ,[SID]
            ,[LoginName]
            ,[SQLCommand])   
   
      select [ID] 
            ,[InsertDate]
            ,[updateDate]
            ,[Active]
            ,[ServerName]
            ,[SID]
            ,[Name]
            ,[SQLCommand]
        from [master].[dbo].[tb_bkp_logins] with(nolock)

insert into #LOGINS_FUNCOES
            ([InsertDate]
            ,[updateDate]
            ,[Active]
            ,[ServerName]
            ,[SID]
            ,[LoginID]
            ,[LoginName]
            ,[PermissionID]
            ,[PermissionName]
            ,[SQLCommand])

      select [InsertDate]
            ,[updateDate]
            ,[Active]
            ,[ServerName]
            ,[SID]
            ,[LoginID]
            ,[LoginName]
            ,[PermissionID]
            ,[PermissionName]
            ,[SQLCommand]
        from [master].[dbo].[tb_bkp_logins_functions] with(nolock)

 insert into #LOGINS_GRANTS
            ([InsertDate]
            ,[updateDate]
            ,[Active]
            ,[ServerName]
            ,[SID]
            ,[LoginName]
            ,[LoginType]
            ,[PermissionName]
            ,[SQLCommand])

      select [InsertDate]
            ,[updateDate]
            ,[Active]
            ,[ServerName]
            ,[SID]
            ,[LoginName]
            ,[LoginType]
            ,[PermissionName]
            ,[SQLCommand]
        from [master].[dbo].[tb_bkp_logins_grants] with(nolock)      
                                               
while (select count([bkp_login]) as qtd from #LOGINS) > 0
begin

    select @aux = min([bkp_login]) from #LOGINS 
    select @SQL = [SQLCommand]     from #LOGINS where [bkp_login] = @aux
	
      exec sp_executesql @SQL

	  delete from #LOGINS where [bkp_login] = @aux 

end    

while (select count([bkp_login_function]) as qtd from #LOGINS_FUNCOES) > 0
begin

    select @aux = min([bkp_login_function]) from #LOGINS_FUNCOES 
    select @SQL = [SQLCommand]              from #LOGINS_FUNCOES where [bkp_login_function] = @aux
	
      exec sp_executesql @SQL

  	delete from #LOGINS_FUNCOES where [bkp_login_function] = @aux 

end

while (select count([bkp_login_grant]) as qtd from #LOGINS_GRANTS) > 0
begin

    select @aux = min([bkp_login_grant]) from #LOGINS_GRANTS
    select @SQL = [SQLCommand]           from #LOGINS_GRANTS where [bkp_login_grant] = @aux
	
	    exec sp_executesql @SQL

  	delete from #LOGINS_GRANTS where [bkp_login_grant] = @aux 

end
