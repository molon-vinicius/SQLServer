create table [master].[dbo].tb_bkp_logins 
           ( [ID]                   numeric(15) identity(1,1)
           , [InsertDate]           datetime
           , [UpdateDate]           datetime
           , [Active]               bit
           , [SID]                  varbinary(85)
           , [Name]                 sysname
           , [ServerName]           nvarchar(100)                          
           , [SQLCommand]           nvarchar(max))

create table [master].[dbo].tb_bkp_logins_functions  
           ( [LoginID]              numeric(15)
           , [LoginName]            nvarchar(120)
           , [SID]                  varbinary(85)
           , [PermissionID]         numeric(15)
           , [PermissionName]       nvarchar(100)
           , [InsertDate]           datetime
           , [UpdateDate]           datetime
           , [Active]               bit
           , [ServerName]           nvarchar(100)   
           , [SQLCommand]           nvarchar(max))

create table [master].[dbo].tb_bkp_logins_grants 
           ( [InsertDate]           datetime
           , [UpdateDate]           datetime
           , [Active]               bit
           , [ServerName]           nvarchar(100)  
           , [SID]                  varbinary(85)
           , [LoginName]            nvarchar(100)    
           , [LoginType]            nvarchar(100)   
           , [PermissionName]       nvarchar(100)  
           , [SQLCommand]           nvarchar(max))   
