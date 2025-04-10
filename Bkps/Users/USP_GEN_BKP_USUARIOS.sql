use [master]

go 

create or alter procedure USP_GEN_BKP_USUARIOS 

as 

declare @SQLCommand nvarchar(max)

if object_id('TEMPDB..##TEMP_USERS')           is not null drop table ##TEMP_USERS
if object_id('TEMPDB..##TEMP_USERS_FUNCTIONS') is not null drop table ##TEMP_USERS_FUNCTIONS
if object_id('TEMPDB..##TEMP_USERS_GRANTS')    is not null drop table ##TEMP_USERS_GRANTS

create table ##TEMP_USERS
           ( [DatabaseName]   nvarchar(120)
           , [UserName]       varchar(100)
           , [SID]            varbinary(85)
           , [SQLCommand]     nvarchar(max) )
create table ##TEMP_USERS_FUNCTIONS 
           ( [DatabaseName]   nvarchar(120)
           , [PermissionName] nvarchar(100)
           , [userName]       varchar(100)
           , [SID]            varbinary(85)
           , [SQLCommand]     nvarchar(max) )
create table ##TEMP_USERS_GRANTS 
           ( [DatabaseName]   nvarchar(120)
           , [PermissionName] nvarchar(100)
           , [PermissionType] nvarchar(100)
           , [userName]       varchar(100)
           , [SID]            varbinary(85)
           , [SQLCommand]     nvarchar(max) )

      set @SQLCommand = 
	
    'use [?];     
     insert into ##TEMP_USERS ( [DatabaseName]
                                 , [userName]
                                 , [SID]
                                 , [SQLCommand] )
     select db_name()  as [DatabaseName]
         , dp.[name]   as [UserName]
         , dp.[SID]    as [SID]
         , ''use [?]; CREATE USER ['' + dp.[name] collate LATIN1_GENERAL_CI_AS + ''] FOR LOGIN ['' + sp.[name] collate LATIN1_GENERAL_CI_AS + ''];'' as [SQLCommand]
       from sys.database_principals dp with(nolock) 
       join sys.server_principals   sp with(nolock) on dp.[SID] = sp.[SID]'

     exec sp_msforeachdb @SQLCommand
    	
      set @SQLCommand = 

    'use [?];
     insert into ##TEMP_USERS_FUNCTIONS ( [DatabaseName]
                                        , [userName]
                                        , [SID]
                                        , [PermissionName]
                                        , SQLCommand )
     select db_name()     as [DatabaseName]
          , dp.[name]     as [userName]
          , dp.[SID]      as [SID]
          , dr.[name]     as [PermissionName]
          , ''use [?]; ALTER ROLE ['' + dr.name collate LATIN1_GENERAL_CI_AS + ''] ADD MEMBER ['' + dp.[name] collate LATIN1_GENERAL_CI_AS + ''];'' as [SQLCommand]
       from sys.database_role_members drm with(nolock) 
       join sys.database_principals   dp  with(nolock) on drm.member_principal_id = dp.principal_id
       join sys.database_principals   dr  with(nolock) on drm.role_principal_id   = dr.principal_id'
    
      exec sp_msforeachdb @SQLCommand
	  
       set @SQLCommand = 
	 
    'use [?];
     insert into ##TEMP_USERS_GRANTS  ( [DatabaseName]
                                         , [PermissionName]
                                         , [PermissionType]
                                         , [userName]
                                         , [SID] 
                                         , [SQLCommand] )
     select distinct 
           db_name()               as [DatabaseName]
          , case when perm.[major_id] = 0 then ''DATABASE::['' + db_name() collate LATIN1_GENERAL_CI_AS + '']'' else obj.[name] collate LATIN1_GENERAL_CI_AS end as [PermissionName]
          , perm.[permission_name] as [PermissionType]
          , dp.[name]              as [userName]
          , dp.[SID]               as [SID] 
          , ''use [?]; '' +char(13)+ ''
            GRANT '' + perm.[permission_name] collate LATIN1_GENERAL_CI_AS + '' ON '' + case when perm.[major_id] = 0 then ''DATABASE::['' + db_name() collate LATIN1_GENERAL_CI_AS + '']'' else obj.[name] collate LATIN1_GENERAL_CI_AS end + '' TO ['' + dp.[name] collate LATIN1_GENERAL_CI_AS + ''];''  as [SQLCommand]
       from sys.database_permissions perm with(nolock)
       join sys.database_principals  dp   with(nolock) on perm.[grantee_principal_id] = dp.[principal_id]
  left join sys.objects              obj  with(nolock) on perm.[major_id] = obj.[object_id]
      where (perm.[major_id] = 0
	     or obj.[name] is not null)'

      exec sp_msforeachdb @SQLCommand

     merge [master].[dbo].[tb_bkp_users]    as target 
     using ##TEMP_USERS           as source
      on ( @@SERVERNAME          = target.[ServerName]    
       and source.[DatabaseName] = target.[DatabaseName]
       and source.[userName]     = target.[userName] )
      when matched 
       and target.[SQLCommand] <> source.[SQLCommand] 
      then update 
       set target.[updateDate] = getdate()
         , target.[SQLCommand] = source.[SQLCommand]
      when not matched by target then 
    insert ( [insertDate]    
           , [Active]         
           , [ServerName]    
           , [DatabaseName]
           , [userName]
           , [SID]
           , [SQLCommand] ) 
    values ( getdate()      
           , convert(bit, 1)
           , @@SERVERNAME  
           , source.[DatabaseName]
           , source.[userName]    
           , source.[SID]          
           , source.[SQLCommand] )
      when not matched by source 
      then update 
       set target.[updateDate] = getdate()
         , target.[Active]     = 0;

     merge [master].[dbo].[tb_bkp_users_functions]   as target 
     using ##TEMP_USERS_FUNCTIONS                    as source
      on ( @@SERVERNAME            = target.[ServerName]    
       and source.[DatabaseName]   = target.[DatabaseName]
       and source.[userName]       = target.[userName] 
       and source.[PermissionName] = target.[PermissionName] )
      when matched 
       and target.[SQLCommand] <> source.[SQLCommand] 
      then update 
       set target.[updateDate] = getdate()
         , target.[SQLCommand] = source.[SQLCommand]
      when not matched by target then 
    insert ( [insertDate]    
           , [Active]         
           , [ServerName]    
           , [DatabaseName]
           , [userName]
           , [PermissionName]
           , [SID]
           , [SQLCommand] ) 
    values ( getdate()      
           , convert(bit, 1)
           , @@SERVERNAME  
           , source.[DatabaseName]
           , source.[userName] 
           , source.[PermissionName]
           , source.[SID]          
           , source.[SQLCommand] )
      when not matched by source 
      then update 
       set target.[updateDate] = getdate()
         , target.[Active]     = 0;

     merge [master].[dbo].[tb_bkp_users_grants] as target 
     using ##TEMP_USERS_GRANTS               as source
      on ( @@SERVERNAME            = target.[ServerName]    
       and source.[DatabaseName]   = target.[DatabaseName]
       and source.[userName]       = target.[userName] 
       and source.[PermissionName] = target.[PermissionName] 
       and source.[PermissionType] = target.[PermissionType])
      when matched 
       and target.[SQLCommand] <> source.[SQLCommand]
      then update 
       set target.[updateDate] = getdate()
         , target.[SQLCommand] = source.[SQLCommand]
      when not matched by target then 
    insert ( [insertDate]    
           , [Active]         
           , [ServerName]    
           , [DatabaseName]
           , [userName]
           , [PermissionName]
           , [PermissionType]
           , [SID]
           , [SQLCommand] ) 
    values ( getdate()      
           , convert(bit, 1)
           , @@SERVERNAME   
           , source.[DatabaseName]
           , source.[userName] 
           , source.[PermissionName]
           , source.[PermissionType]
           , source.[SID]          
           , source.[SQLCommand])
      when not matched by source 
      then update 
       set target.[updateDate] = getdate()
         , target.[Active]     = 0 ;
