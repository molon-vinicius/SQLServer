create table [master].[dbo].[tb_bkp_users]
           ( [ServerName]     nvarchar(120)
           , [DatabaseName]   nvarchar(120)
           , [InsertDate]     datetime 		   
           , [UpdateDate]     datetime		   
           , [Active]         bit	
           , [UserName]       varchar(100)
           , [SID]            varbinary(85)
           , [SQLCommand]     nvarchar(max) )

create table [master].[dbo].[tb_bkp_users_functions]
           ( [ServerName]     nvarchar(120)
           , [DatabaseName]   nvarchar(120)
           , [InsertDate]     datetime 		   
           , [UpdateDate]     datetime		   
           , [Active]         bit		   
           , [PermissionName] nvarchar(100)
           , [UserName]       varchar(100)
           , [SID]            varbinary(85)
           , [SQLCommand]     nvarchar(max) )

create table [master].[dbo].[tb_bkp_users_grants]
           ( [ServerName]     nvarchar(120)
           , [DatabaseName]   nvarchar(120)
           , [InsertDate]     datetime 		   
           , [UpdateDate]     datetime		   
           , [Active]         bit	
           , [PermissionName] nvarchar(100)
           , [PermissionType] nvarchar(100)
           , [UserName]       varchar(100)
           , [SID]            varbinary(85)
           , [SQLCommand]     nvarchar(max) )
