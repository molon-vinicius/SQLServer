use [master]

create or alter procedure [dbo].[USP_Queries_Running]

as

begin
	set nocount on 

	if ( object_id('tempdb..#Result_WhoisActive') is not null )
		drop table #Result_WhoisActive
				
	create table #Result_WhoisActive 
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

            exec [dbo].[sp_WhoIsActive]
                 @get_outer_command = 1
               , @output_column_list = '[dd hh:mm:ss.mss][database_name][login_name][host_name][start_time][status][session_id][blocking_session_id][wait_info][open_tran_count][CPU][reads][writes][sql_command]'
               , @destination_table = '#Result_WhoisActive'

	alter table #Result_WhoisActive
	alter column [sql_command] varchar(max)
	
	update #Result_WhoisActive
	   set [sql_command] = replace( replace( replace( replace( cast([sql_command] as varchar(1000)), '<?query --', ''), '--?>', ''), '&gt;', '>'), '&lt;', '')
  
    delete #Result_WhoisActive	
     where datediff(minute, [start_time], getdate()) < 5 --minutes
	
  truncate table [dbo].[tb_Queries_Running]

	insert into [dbo].[tb_Queries_Running]
	
	     select [dd hh:mm:ss.mss]     
              , [database_name]       
              , [login_name]          
              , [host_name]           
              , [start_time]          
              , [status]              
              , [session_id]          
              , [blocking_session_id] 
              , [wait_info]           
              , [open_tran_count]     
              , [CPU]                 
              , [reads]               
              , [writes]              
              , [sql_command]         
		   
		   from #Result_WhoisActive

	if (@@rowcount = 0)
	begin
		insert into [dbo].[tb_Queries_Running]
                  ( [dd hh:mm:ss.mss]
                  , [database_name]
                  , [login_name]
                  , [host_name]
                  , [start_time]
                  , [status]
                  , [session_id]
                  , [blocking_session_id]
                  , [wait_info]
                  , [open_tran_count]
                  , [CPU]
                  , [reads]
                  , [writes]
                  , [sql_command] )
		     
			 select null                                          as [dd hh:mm:ss.mss]
                  , 'No queries running for more than 5 minutes.' as [database_name]
                  , null                                          as [login_name]
                  , null                                          as [host_name]
                  , null                                          as [start_time]
                  , null                                          as [status]
                  , null                                          as [session_id]
                  , null                                          as [blocking_sessio_id]
                  , null                                          as [wait_info]
                  , null                                          as [open_tran_count]
                  , null                                          as [CPU]
                  , null                                          as [reads]
                  , null                                          as [writes]
                  , null                                          as [sql_command]
	end

end

