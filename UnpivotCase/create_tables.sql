                     /* table target */
create table [master].[dbo].[tb_user_permissions_MERGE]
            ([userID] numeric(15)
            ,[ReadMainMenu] char
            ,[WriteMainMenu] char
            ,[EditMainMenu] char
            ,[ReadAccountMod] char 
            ,[WriteAccountMod] char 
            ,[EditAccountMod] char 
            ,[ReadStockMod] char 
            ,[WriteStockMod] char 
            ,[EditStockMod] char 
            ,[ReadHRMod] char 
            ,[WriteHRMod] char 
            ,[EditHRMod] char 
            ,[ReadFinMod] char 
            ,[WriteFinMod] char 
            ,[EditFinMod] char 
            ,[ReadITMod] char 
            ,[WriteITMod] char 
            ,[EditITMod] char)

                      /* source table */ 
create table [master].[dbo].[tb_user_permissions]
            ([userID] numeric(15)
            ,[permission] varchar(100)
            ,[active] char)

 insert into [master].[dbo].[tb_user_permissions]
            ([userID], [permission], [active])

      values (1, 'ReadMainMenu', 'Y')
            ,(1, 'WriteMainMenu', 'N') 
            ,(1, 'EditMainMenu', 'N')
            ,(1, 'ReadAccountMod', 'Y')
            ,(1, 'WriteAccountMod', 'Y')
            ,(1, 'EditAccountMod', 'Y')
            ,(1, 'ReadStockMod', 'N')
            ,(1, 'WriteStockMod', 'N')
            ,(1, 'EditStockMod', 'N')
            ,(1, 'ReadHRMod', 'N') 
            ,(1, 'WriteHRMod', 'N')
            ,(1, 'EditHRMod', 'N')
            ,(1, 'ReadFinMod', 'Y')
            ,(1, 'WriteFinMod', 'N')
            ,(1, 'EditFinMod', 'N')
            ,(1, 'ReadITMod', 'N')
            ,(1, 'WriteITMod', 'N')
            ,(1, 'EditITMod', 'N')

            ,(2, 'ReadMainMenu', 'S')
            ,(2, 'WriteMainMenu', 'N') 
            ,(2, 'EditMainMenu', 'N')
            ,(2, 'ReadAccountMod', 'S')
            ,(2, 'WriteAccountMod', 'N')
            ,(2, 'EditAccountMod', 'N')
            ,(2, 'ReadStockMod', 'S')
            ,(2, 'WriteStockMod', 'N')
            ,(2, 'EditStockMod', 'N')
            ,(2, 'ReadHRMod', 'N') 
            ,(2, 'WriteHRMod', 'N')
            ,(2, 'EditHRMod', 'N')
            ,(2, 'ReadFinMod', 'S')
            ,(2, 'WriteFinMod', 'N')
            ,(2, 'EditFinMod', 'N')
            ,(2, 'ReadITMod', 'N')
            ,(2, 'WriteITMod', 'N')
            ,(2, 'EditITMod', 'N')

            ,(3, 'ReadMainMenu', 'N')
            ,(3, 'WriteMainMenu', 'N') 
            ,(3, 'EditMainMenu', 'N')
            ,(3, 'ReadAccountMod', 'N')
            ,(3, 'WriteAccountMod', 'N')
            ,(3, 'EditAccountMod', 'N')
            ,(3, 'ReadStockMod', 'Y')
            ,(3, 'WriteStockMod', 'Y')
            ,(3, 'EditStockMod', 'Y')
            ,(3, 'ReadHRMod', 'N') 
            ,(3, 'WriteHRMod', 'N')
            ,(3, 'EditHRMod', 'N')
            ,(3, 'ReadFinMod', 'N')
            ,(3, 'WriteFinMod', 'N')
            ,(3, 'EditFinMod', 'N')
            ,(3, 'ReadITMod', 'N')
            ,(3, 'WriteITMod', 'N')
            ,(3, 'EditITMod', 'N')

            ,(4, 'ReadMainMenu', 'Y')
            ,(4, 'WriteMainMenu', 'N') 
            ,(4, 'EditMainMenu', 'N')
            ,(4, 'ReadAccountMod', 'Y')
            ,(4, 'WriteAccountMod', 'N')
            ,(4, 'EditAccountMod', 'N')
            ,(4, 'ReadStockMod', 'N')
            ,(4, 'WriteStockMod', 'N')
            ,(4, 'EditStockMod', 'N')
            ,(4, 'ReadHRMod', 'Y') 
            ,(4, 'WriteHRMod', 'Y')
            ,(4, 'EditHRMod', 'Y')
            ,(4, 'ReadFinMod', 'Y')
            ,(4, 'WriteFinMod', 'N')
            ,(4, 'EditFinMod', 'N')
            ,(4, 'ReadITMod', 'N')
            ,(4, 'WriteITMod', 'N')
            ,(4, 'EditITMod', 'N')

            ,(5, 'ReadMainMenu', 'Y')
            ,(5, 'WriteMainMenu', 'Y') 
            ,(5, 'EditMainMenu', 'Y')
            ,(5, 'ReadAccountMod', 'Y')
            ,(5, 'WriteAccountMod', 'Y')
            ,(5, 'EditAccountMod', 'Y')
            ,(5, 'ReadStockMod', 'Y')
            ,(5, 'WriteStockMod', 'Y')
            ,(5, 'EditStockMod', 'Y')
            ,(5, 'ReadHRMod', 'Y') 
            ,(5, 'WriteHRMod', 'Y')
            ,(5, 'EditHRMod', 'Y')
            ,(5, 'ReadFinMod', 'Y')
            ,(5, 'WriteFinMod', 'Y')
            ,(5, 'EditFinMod', 'Y')
            ,(5, 'ReadITMod', 'Y')
            ,(5, 'WriteITMod', 'Y')
            ,(5, 'EditITMod', 'Y')
