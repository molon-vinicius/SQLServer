use [master] 

	create table tb_Queries_Running 
                ([dd hh:mm:ss.mss]      varchar(20)
                ,[database_name]        nvarchar(128)		
                ,[login_name]           nvarchar(128)
                ,[host_name]            nvarchar(128)
                ,[start_time]           datetime
                ,[status]               varchar(30)
                ,[session_id]           int
                ,[blocking_session_id]  int
                ,[wait_info]            varchar(max)
                ,[open_tran_count]      int
                ,[CPU]                  varchar(max)
                ,[reads]                varchar(max)
                ,[writes]               varchar(max)
                ,[sql_command]          xml)
