use [master]

go 

create or alter procedure USP_GEN_BKP_LOGINS 

as 

declare @LoginName             sysname 
declare @Type                  varchar(1) 
declare @DefaultDB             sysname  
declare @PswdVarbinary         varbinary(256)  
declare @PswdString            varchar(514)  
declare @SIDVarbinary          varbinary(85)  
declare @SIDString             varchar(514)  
declare @IsPolicyChecked       varchar(3)  
declare @IsExpirationChecked   varchar(3) 
declare @SQL                   varchar(1024)  
declare @HasAccess             int  
declare @DenyLogin             int  
declare @IsDisabled            int  

if object_id('TEMPDB..#TEM_AUX')               is not null drop table #TEM_AUX
if object_id('TEMPDB..#TEMP_LOGINS')           is not null drop table #TEMP_LOGINS
if object_id('TEMPDB..#TEMP_LOGINS_FUNCTIONS') is not null drop table #TEMP_LOGINS_FUNCTIONS
if object_id('TEMPDB..#TEMP_LOGINS_GRANTS')    is not null drop table #TEMP_LOGINS_GRANTS

create table #TEM_AUX 
           ( [SID]                  varbinary(85)
           , [Name]                 sysname
           , [Type]                 char(1)
           , [IsDisabled]           bit
           , [DefaultDataBase]      sysname
           , [HasAccess]            int
           , [DenyLogin]            int)

create table #TEMP_LOGINS 
           ( [ID]                   numeric(15) identity(1,1)
           , [InsertDate]           datetime
           , [UpdateDate]           datetime
           , [Active]               bit
           , [SID]                  varbinary(85)
           , [Name]                 sysname
           , [ServerName]           nvarchar(100)                          
           , [SQLCommand]           nvarchar(max))

create table #TEMP_LOGINS_FUNCTIONS 
           ( [LoginID]              nvarchar(100)
           , [LoginName]            nvarchar(120)
           , [SID]                  varbinary(85)
           , [PermissionID]         numeric(15)
           , [PermissionName]       nvarchar(100)
           , [InsertDate]           datetime
           , [UpdateDate]           datetime
           , [Active]               bit
           , [ServerName]           nvarchar(100)   
           , [SQLCommand]           nvarchar(max))

create table #TEMP_LOGINS_GRANTS 
           ( [InsertDate]           datetime
           , [UpdateDate]           datetime
           , [Active]               bit
           , [ServerName]           nvarchar(100)  
           , [SID]                  varbinary(85)
           , [LoginName]            nvarchar(100)    
           , [LoginType]            nvarchar(100)   
           , [PermissionName]       nvarchar(100)  
           , [SQLCommand]           nvarchar(max))   

     insert into #TEM_AUX ( [SID]                        
                          , [Name]                       
                          , [Type]                       
                          , [IsDisabled]                
                          , [DefaultDataBase] 
                          , [HasAccess]                  
                          , [DenyLogin])
     select p.[SID]
	        , p.[name]
          , p.[type]
		      , p.[is_disabled]
		      , p.[default_database_name]
		      , l.[hasaccess]
		      , l.[denylogin] 
       from sys.server_principals p
  left join sys.syslogins         l on ( l.Name = p.Name ) 
      where p.type IN ( 'S', 'G', 'U' ) 
        --and p.name <> 'sa'  
   order by p.name

while (select count(*) as qtd 
         from #TEM_AUX) > 0 
begin  

     select @LoginName = min([Name]) 
       from #TEM_AUX

     select @Type          = [Type]
          , @DefaultDB     = [DefaultDataBase]
	    	  , @SIDVarbinary  = [SID]
       from #TEM_AUX
	    where [Name] = @LoginName
 
     if (@Type in ( 'G', 'U'))  
     begin -- NT AUTHENTICATED ACCOUNT/GROUP  
       set @SQL = 'CREATE LOGIN ' + quotename( @LoginName ) + ' FROM WINDOWS WITH DEFAULT_DATABASE = [' + @DefaultDB + ']'  
     end  
     else
	   begin -- SQL SERVER AUTHENTICATION  
           -- OBTAIN PASSWORD AND SID  
          set @PswdVarbinary = cast( loginproperty( @LoginName, 'PASSWORDHASH' ) as varbinary(256) )  
          exec sp_hexadecimal @PswdVarbinary, @PswdString OUT  
          exec sp_hexadecimal @SIDVarbinary,@SIDString OUT  
          
          -- OBTAIN PASSWORD POLICY STATE  
          select @IsPolicyChecked = case is_policy_checked when 1 then 'ON' 
                                                           when 0 then 'OFF' 
                                                           else null 
                                    end 
            from sys.sql_logins 
           where [name] = @LoginName  

          select @IsExpirationChecked = case is_expiration_checked when 1 then 'ON' 
                                                                   when 0 then 'OFF' 
                                                                   else null 
                                        end 
            from sys.sql_logins 
           where [name] = @LoginName  
   
          set @SQL = 'CREATE LOGIN ' + quotename( @LoginName ) + ' WITH PASSWORD = ' + @PswdString + ' HASHED, SID = ' + @SIDString + ', DEFAULT_DATABASE = [' + @DefaultDB + ']'  
  
          if ( @IsPolicyChecked is not null )  
          begin  
               set @SQL = @SQL + ', CHECK_POLICY = ' + @IsPolicyChecked  
          end  
          if ( @IsExpirationChecked is not null )  
          begin  
               set @SQL = @SQL + ', CHECK_EXPIRATION = ' + @IsExpirationChecked  
          end  
	 end  

	 if (@DenyLogin = 1)  
	 begin -- LOGIN IS DENIED ACCESS  
	 	 set @SQL = @SQL + '; DENY CONNECT SQL TO ' + quotename( @LoginName )  
	 end  
	 else if (@HasAccess = 0)  
	 begin -- LOGIN EXISTS BUT DOES NOT HAVE ACCESS  
	 	 set @SQL = @SQL + '; REVOKE CONNECT SQL TO ' + quotename( @LoginName )  
	 end  
	 if (@IsDisabled = 1)  
	 begin -- LOGIN IS DISABLED  
	 	 set @SQL = @SQL + '; ALTER LOGIN ' + quotename( @LoginName ) + ' DISABLE'  
	 end  
    
	 insert into #TEMP_LOGINS ( [SID]
                            , [InsertDate]
                            , [UpdateDate]
                            , [Active]
                            , [ServerName]
                            , [Name]
                            , [SQLCommand] ) 
     select @SIDVarbinary
          , getdate()
          , getdate()
          , 1
          , @@SERVERNAME
          , @LoginName
          , @SQL  

	 delete from #TEM_AUX where [Name] = @LoginName
end  

     merge [master].[dbo].tb_bkp_logins   as target 
     using #TEMP_LOGINS                   as source
      on ( source.[Name]          = target.[Name]
       and source.[ServerName]    = target.[ServerName] )
      when matched 
       and target.[SQLCommand]   <> source.[SQLCommand] 
      then update 
       set target.[UpdateDate]    = source.[UpdateDate]
         , target.[SQLCommand]    = source.[SQLCommand]
      when not matched by target then 
    insert ( [InsertDate]
           , [Active]
           , [ServerName]
           , [SID]
           , [Name]
           , [SQLCommand] ) 
    values ( source.[InsertDate]
           , source.[Active]
           , source.[ServerName]
           , source.[SID]
           , source.[Name] 
           , source.[SQLCommand] )
      when not matched by source 
      then update 
       set target.[UpdateDate] = getdate()
         , target.[Active]     = 0;
                             
insert into #TEMP_LOGINS_FUNCTIONS 
           ( [LoginID]         
           , [LoginName]       
           , [SID]             
           , [PermissionID]    
           , [PermissionName]  
           , [InsertDate]      
           , [UpdateDate]      
           , [Active]          
           , [ServerName]      
           , [SQLCommand] )

     select serv_role_members.[member_principal_id]     as [LoginID]
          , members.[name]							              	as [LoginName]
          , members.[SID]                               as [SID]
          , roles.[principal_id]      					        as [PermissionID]
          , roles.[name]						                		as [PermissionName]
          , getdate()                                   as [InsertDate]  
          , getdate()                                   as [UpdateDate] 
          , 1                                           as [Active]       
          , @@SERVERNAME                                as [ServerName]  
          , concat( 'USE [MASTER] ALTER SERVER ROLE '
	                , quotename(roles.[name])
			            , ' ADD MEMBER '
			            , quotename(members.[name]))          as [SQLCommand]
       from sys.server_role_members as serv_role_members
       join sys.server_principals   as roles   on serv_role_members.role_principal_id = roles.principal_id
       join sys.server_principals   as members on serv_role_members.member_principal_id = members.principal_id  
       join #temp_logins            as logins  on logins.[SID] = members.[SID]

     merge [master].[dbo].tb_bkp_logins_functions   as target 
     using #TEMP_LOGINS_FUNCTIONS                   as source
      on ( source.[LoginName]        = target.[LoginName]
       and source.[ServerName]       = target.[ServerName] 
       and source.[PermissionName]   = target.[PermissionName] )
      when matched 
       and target.[SQLCommand] <> source.[SQLCommand] 
      then update 
       set target.[UpdateDate]  = source.[UpdateDate]
         , target.[SQLCommand]  = source.[SQLCommand]
      when not matched by target then 
    insert ( [InsertDate]
           , [Active]
           , [ServerName]
           , [SID]
           , [LoginID]
           , [LoginName]
           , [PermissionID]
           , [PermissionName]
           , [SQLCommand] ) 
    values ( source.[InsertDate]
           , source.[Active]
           , source.[ServerName]
           , source.[SID]
           , source.[LoginID]
           , source.[LoginName] 
           , source.[PermissionID]
           , source.[PermissionName]
           , source.[SQLCommand] )
      when not matched by source 
      then update 
       set target.[UpdateDate] = getdate()
         , target.[Active]     = 0;

insert into #TEMP_LOGINS_GRANTS 
          ( [InsertDate]       
          , [UpdateDate]     
          , [Active]         
          , [ServerName]     
          , [SID]            
          , [LoginName]      
          , [LoginType]        
          , [PermissionName]  
          , [SQLCommand] )

     select getdate()                                                                                          as [InsertDate]      
          , getdate()                                                                                          as [UpdateDate]     
          , 1                                                                                                  as [Active]           
          , @@SERVERNAME                                                                                       as [ServerName]      
          , sp.[SID]                                                                                           as [SID]
          , sp.[name] collate SQL_LATIN1_GENERAL_CP1_CI_AS                                                     as [LoginName]
          , sp.[type_desc]                                                                                     as [LoginType]
          , spr.[permission_name] collate SQL_LATIN1_GENERAL_CP1_CI_AS                                         as [PermissionName]
          , 'GRANT ' + spr.[permission_name] + ' TO [' + sp.[name] + '];' collate SQL_LATIN1_GENERAL_CP1_CI_AS as [SQLCommand]
       from sys.server_permissions spr
       join sys.server_principals  sp on spr.grantee_principal_id = sp.principal_id
      where sp.[type] in ('S', 'U', 'G')
   order by sp.[name], spr.[permission_name];

 
     merge [master].[dbo].tb_bkp_logins_grants as target 
     using #TEMP_LOGINS_GRANTS                 as source
      on ( source.[LoginName]      = target.[LoginName]
       and source.[ServerName]     = target.[ServerName] 
       and source.[LoginType]      = target.[LoginType]
       and source.[PermissionName] = target.[PermissionName])
      when matched 
       and target.[SQLCommand] <> source.[SQLCommand]
      then update 
       set target.[UpdateDate]  = source.[UpdateDate]
         , target.[SQLCommand]  = source.[SQLCommand]
      when not matched by target then 
    insert ( [InsertDate]
           , [Active]
           , [ServerName]
           , [SID]
           , [LoginName]
           , [LoginType]
           , [PermissionName]
           , [SQLCommand] ) 
    values ( source.[InsertDate]
           , source.[Active]
           , source.[ServerName]
           , source.[SID]
           , source.[LoginName]
           , source.[LoginType]
           , source.[PermissionName]
           , source.[SQLCommand])
      when not matched by source then update 
       set target.[UpdateDate] = getdate()
         , target.[Active]     = 0;
            
