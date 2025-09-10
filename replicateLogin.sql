DECLARE @model_member NVARCHAR(30) = 'sa'         --login that will be copied
DECLARE @new_member   NVARCHAR(30) = 'newMember'  --login that will be created


DECLARE @member_id NUMERIC(15) = (select principal_id from sys.database_principals where [name] = @model_member)
DECLARE @active VARCHAR(1) = (
   select is_disabled
     from sys.server_principals 
    where [name] = @model_member
)
    SET @active = CASE WHEN @active = 0 
                       THEN 'S'
                       ELSE 'N'
                  END
DECLARE @DataBaseMemberName NVARCHAR(30) = (SELECT dbname from syslogins where loginname = @model_member)
DECLARE @db_user_perm NVARCHAR(MAX)
DECLARE @SQL_LOGIN NUMERIC(15)

IF OBJECT_ID('TEMPDB..#DB')  IS NOT NULL DROP TABLE #DB
IF OBJECT_ID('TEMPDB..#AUX')  IS NOT NULL DROP TABLE #AUX
IF OBJECT_ID('TEMPDB..#SCRIPTS')  IS NOT NULL DROP TABLE #SCRIPTS
IF OBJECT_ID('TEMPDB..##DB_USER_PERM')  IS NOT NULL DROP TABLE ##DB_USER_PERM
       
CREATE TABLE ##DB_USER_PERM (RolePrincipalID NUMERIC(15)
                           , RolePrincipalName NVARCHAR(128)
                           , MemberPrincipalID NUMERIC(15)
                           , MemberPrincipalName NVARCHAR(128)
                           , LoginType NVARCHAR(1)
                           , LanguageId NUMERIC(15)
                           , DataBaseName NVARCHAR(128))

CREATE TABLE #SCRIPTS (Script NVARCHAR(MAX))

      SELECT @db_user_perm = 
     'USE [?] 
      INSERT INTO ##DB_USER_PERM (RolePrincipalID
                                         , RolePrincipalName
                                         , MemberPrincipalID
                                         , MemberPrincipalName
                                         , LoginType
                                         , LanguageId
                                         , DataBaseName)
      SELECT roles.principal_id                          AS RolePrincipalID
           , roles.[name]                                AS RolePrincipalName
           , database_role_members.member_principal_id   AS MemberPrincipalID
           , members.[name]                              AS MemberPrincipalName
           , CASE WHEN perm.[type] = ''U''
                  THEN 1
                  ELSE 2
             END                                         AS LoginType
           , lang.[langid]+1                             AS LanguageId 
           , DB_NAME()                                   AS DataBaseName
        FROM sys.database_role_members AS database_role_members  
        JOIN sys.database_principals   AS roles                 ON database_role_members.role_principal_id   = roles.principal_id  
        JOIN sys.database_principals   AS members               ON database_role_members.member_principal_id = members.principal_id  
        JOIN sys.server_principals     AS perm                  ON members.[name]                            = perm.[name] COLLATE SQL_Latin1_General_CP1_CI_AS
        JOIN sys.syslanguages          AS lang                  ON perm.default_language_name                = lang.[name] COLLATE SQL_Latin1_General_CP1_CI_AS              
       WHERE members.[name] = ''' + @model_member + '''
       ORDER BY database_role_members.member_principal_id
         
       '
        EXEC sp_MSforeachdb @db_user_perm    

        SELECT RolePrincipalName
             , DataBaseName 
          INTO #AUX 
          FROM ##DB_USER_PERM

        SELECT DISTINCT DataBaseName 
          INTO #DB 
          FROM #AUX

DECLARE @COMANDO_PERM NVARCHAR(MAX) = ''
DECLARE @RoleName NVARCHAR(30)
DECLARE @DataBase NVARCHAR(30)

IF NOT EXISTS(
   SELECT [name] as Nome
     FROM sys.server_principals
    WHERE [name] = @new_member
)
BEGIN
     INSERT INTO #SCRIPTS (SCRIPT)
     SELECT 'USE [master]
             CREATE LOGIN ['+@new_member+'] FROM WINDOWS WITH DEFAULT_DATABASE = ['+@DataBaseMemberName+'], DEFAULT_LANGUAGE=[Português (Brasil)]'
END

     INSERT INTO #SCRIPTS (SCRIPT)
     SELECT DISTINCT 
           'USE ' + QUOTENAME(DataBaseName) + ';
            CREATE USER ' + QUOTENAME(@new_member) + ' FOR LOGIN ' + QUOTENAME(@new_member) + ' WITH DEFAULT_SCHEMA=[dbo];' AS SCRIPT
       FROM #AUX

WHILE (SELECT COUNT(*) FROM #AUX) > 0
BEGIN

SET @RoleName = (SELECT TOP 1 RolePrincipalName FROM #AUX)
SET @Database = (SELECT TOP 1 DataBaseName      FROM #AUX)

       INSERT INTO #SCRIPTS (SCRIPT)
            SELECT 'USE ' + @Database + ';
                    EXEC sys.sp_addrolemember  '''+ @RoleName + ''',''' + @new_member + ''';'                   
DELETE FROM #AUX WHERE DataBaseName = @DataBase AND RolePrincipalName = @RoleName  
        
END


WHILE (SELECT COUNT(*) FROM #DB) > 0
BEGIN

SET @Database = (SELECT TOP 1 DataBaseName FROM #DB)

       INSERT INTO #SCRIPTS (SCRIPT)
            SELECT 'USE ' + @Database + ';
                    GRANT CREATE TABLE TO ['+ @new_member +'];'
            
DELETE FROM #DB WHERE DataBaseName = @DataBase 
        
END
       
SELECT * FROM #SCRIPTS
