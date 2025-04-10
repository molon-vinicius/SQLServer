create or alter procedure USP_RESTORE_BKP_USERS

as 

/* This version compares the scripts of [master] tables to linked server tables with intention to update the scripts of [master] tables */

declare @aux numeric(15)
declare @SQL nvarchar(max)

if object_id('TEMPDB..#USERS')           is not null drop table #USERS
if object_id('TEMPDB..#USERS_FUNCTIONS') is not null drop table #USERS_FUNCTIONS
if object_id('TEMPDB..#USERS_GRANTS')    is not null drop table #USERS_GRANTS

create table #USERS
            ([bkp_user] numeric(15) identity
            ,[InsertDate] datetime
            ,[UpdateDate] datetime
            ,[Active] INT
            ,[ServerName] varchar(100)
            ,[DatabaseName] varchar(100)
            ,[UserName] varchar(100)
            ,[SID] varbinary(85)
            ,[SQLCommand] nvarchar(max))

create table #USERS_FUNCTIONS
            ([bkp_user_function] numeric(15) identity
            ,[InsertDate] datetime
            ,[UpdateDate] datetime
            ,[Active] INT
            ,[ServerName] varchar(100)
            ,[DatabaseName] varchar(100)
            ,[PermissionName] varchar(100)
            ,[UserName] varchar(100)
            ,[SID] varbinary(85)
            ,[SQLCommand] nvarchar(max))

create table #USERS_GRANTS
            ([bkp_user_grant] numeric(15) identity
            ,[insertDate] datetime
            ,[updateDate] datetime
            ,[Active] INT
            ,[ServerName] varchar(100)
            ,[DatabaseName] varchar(100)
            ,[PermissionName] varchar(100)
            ,[PermissionType] varchar(100)
            ,[UserName] varchar(100)
            ,[SID] varbinary(85)
            ,[SQLCommand] nvarchar(max))

insert into #USERS
           ([InsertDate] 
           ,[UpdateDate] 
           ,[Active] 
           ,[ServerName] 
           ,[DatabaseName] 
           ,[UserName]
           ,[SID] 
           ,[SQLCommand])   
   
     select [InsertDate] 
           ,[UpdateDate] 
           ,[Active] 
           ,[ServerName] 
           ,[DatabaseName] 
           ,[UserName]
           ,[SID] 
           ,[SQLCommand]
       from [LinkedServerName].[DataBaseName].[dbo].[tb_bkp_users] with(nolock)

insert into #USERS_FUNCTIONS
            ([InsertDate] 
            ,[UpdateDate] 
            ,[Active] 
            ,[ServerName] 
            ,[DatabaseName] 
            ,[PermissionName] 
            ,[UserName] 
            ,[SID] 
            ,[SQLCommand])

      select [InsertDate] 
            ,[UpdateDate] 
            ,[Active] 
            ,[ServerName] 
            ,[DatabaseName] 
            ,[PermissionName] 
            ,[userName] 
            ,[SID] 
            ,[SQLCommand]
        from [LinkedServerName].[DataBaseName].[dbo].[tb_bkp_users_functions] with(nolock)

 insert into #USERS_GRANTS
            ([InsertDate] 
            ,[UpdateDate] 
            ,[Active] 
            ,[ServerName] 
            ,[DatabaseName] 
            ,[PermissionName] 
            ,[PermissionType] 
            ,[UserName] 
            ,[SID] 
            ,[SQLCommand])

      select [InsertDate] 
            ,[UpdateDate] 
            ,[Active] 
            ,[ServerName] 
            ,[DatabaseName] 
            ,[PermissionName] 
            ,[PermissionType] 
            ,[userName] 
            ,[SID] 
            ,[SQLCommand]
        from [LinkedServerName].[DataBaseName].[dbo].[tb_bkp_users_grants] with(nolock)        

			     /*********/
           /* Users */
			     /*********/
      
      update b
         set [Active]     = a.[Active]
           , [SQLCommand] = a.[SQLCommand] 
        from #USERS                        a with(nolock)
        join [master].[dbo].[tb_bkp_users] b with(nolock)on b.[UserName] = a.[UserName]
                                                        and b.[DatabaseName] = a.[DatabaseName]
       where b.[SQLCommand] <> a.[SQLCommand]
         and 1 = 1

      delete a
        from #USERS                        a with(nolock)
        join [master].[dbo].[tb_bkp_users] b with(nolock)on b.[UserName] = a.[UserName]
                                                        and b.[DatabaseName] = a.[DatabaseName]
                                                        and b.[SQLCommand] = a.[SQLCommand]


while (select count([bkp_user]) as qtd from #USERS) > 0
begin

    select @aux = min([bkp_user]) from #USERS 
    select @SQL = [SQLCommand]    from #USERS where [bkp_user] = @aux
		
      exec sp_executesql @SQL

    delete from #USERS where [bkp_user] = @aux 

end

				   /*******************/
           /* Users Functions */
				   /*******************/
     
	  update b
         set [Active]     = a.[Active]
           , [SQLCommand] = a.[SQLCommand] 
        from #USERS_FUNCTIONS                        a with(nolock)
        join [master].[dbo].[tb_bkp_users_functions] b with(nolock)on b.[userName] = a.[UserName]
                                                                  and b.[DatabaseName] = a.[DatabaseName]
                                                                  and b.[PermissionName] = a.[PermissionName]
       where b.[SQLCommand] <> a.[SQLCommand]
         and 1 = 1

      delete a
        from #USERS_FUNCTIONS                        a with(nolock)
        join [master].[dbo].[tb_bkp_users_functions] b with(nolock)on b.[UserName] = a.[UserName]
                                                                  and b.[DatabaseName] = a.[DatabaseName]
                                                                  and b.[PermissionName] = a.[PermissionName]
                                                                  and b.[SQLCommand] = a.[SQLCommand]

while (select count([bkp_user_function]) as qtd from #USERS_FUNCTIONS) > 0
begin

    select @aux = min([bkp_user_function]) from #USERS_FUNCTIONS 
    select @SQL = [SQLCommand]             from #USERS_FUNCTIONS where [bkp_user_function] = @aux
	
      exec sp_executesql @SQL

    delete from #USERS_FUNCTIONS where [bkp_user_function] = @aux 

end

                 /****************/
                 /* Users Grants */
                 /****************/
      update b
         set [Active]     = a.[Active]
           , [SQLCommand] = a.[SQLCommand] 
        from #USERS_GRANTS                        a with(nolock)
        join [master].[dbo].[tb_bkp_users_grants] b with(nolock)on B.[UserName] = a.[UserName]
                                                               and B.[DatabaseName] = a.[DatabaseName]
                                                               and B.[PermissionName] = a.[PermissionName]
                                                               and B.[PermissionType] = a.[PermissionType]
       where a.[SQLCommand] <> b.[SQLCommand]
         and 1 = 1

      delete a
        from #USERS_GRANTS                        a with(nolock)
        join [master].[dbo].[tb_bkp_users_grants] b with(nolock)on b.[UserName] = a.[UserName]
                                                               and b.[DatabaseName] = a.[DatabaseName]
                                                               and b.[PermissionName] = a.[PermissionName]
                                                               and b.[PermissionType] = a.[PermissionType]
                                                               and b.[SQLCommand] = a.[SQLCommand]

while (select count([bkp_user_grant]) as qtd from #USERS_GRANTS) > 0
begin

    select @aux = min([bkp_user_grant]) from #USERS_GRANTS
    select @SQL = [SQLCommand]          from #USERS_GRANTS where [bkp_user_grant] = @aux
		
	    exec sp_executesql @SQL

    delete from #USERS_GRANTS where [bkp_user_grant] = @aux 

end
