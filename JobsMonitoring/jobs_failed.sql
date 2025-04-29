/*****************/
--	Jobs Failed --
/*****************/

create or alter procedure [dbo].[USP_Jobs_Failed]

as

begin

set nocount on
	
if object_id('tempdb..#Result_History_Jobs') is not null drop table #Result_History_Jobs
if object_id('tempdb..#Return')              is not null drop table #Return

create table #Result_History_Jobs 
            ([Cod] int identity(1,1)
            ,[Instance_Id] int
            ,[Job_Id] varchar(255)
            ,[Job_Name] varchar(255)
            ,[Step_Id] int
            ,[Step_Name] varchar(255)
            ,[SQl_Message_Id] int
            ,[Sql_Severity] int
            ,[SQl_Message] varchar(4490)
            ,[Run_Status] int
            ,[Run_Date] varchar(20)
            ,[Run_Time] varchar(20)
            ,[Run_Duration] int
            ,[Operator_Emailed] varchar(100)
            ,[Operator_NetSent] varchar(100)
            ,[Operator_Paged] varchar(100)
            ,[Retries_Attempted] int
            ,[Nm_Server] varchar(100))

declare @today varchar(8)
declare @yesterday varchar(8)	

 select @yesterday = convert(varchar(8),(dateadd (day, -1, getdate())), 112)
      , @today = convert(varchar(8), getdate() + 1, 112)

          insert into #Result_History_Jobs
            exec [msdb].[dbo].[sp_help_jobhistory] @mode = 'FULL', @start_run_date = @yesterday

 select Nm_Server as [Server]
      , [Job_Name]
      , case when [Run_Status] = 0 then 'Failed'
             when [Run_Status] = 1 then 'Succeeded'
             when [Run_Status] = 2 then 'Retry (step only)'
             when [Run_Status] = 3 then 'Cancelled'
             when [Run_Status] = 4 then 'In-progress message'
             when [Run_Status] = 5 then 'Unknown' 
        end [Status]
      , cast([Run_Date] + ' ' +
        right('00' + substring([Run_Time],(len([Run_Time])-5), 2), 2) + ':' +
        right('00' + substring([Run_Time],(len([Run_Time])-3), 2), 2) + ':' +
        right('00' + substring([Run_Time],(len([Run_Time])-1), 2), 2) as varchar) as [Dt_Execucao]
      , right('00' + substring(cast([Run_Duration] as varchar),(len([Run_Duration])-5),2), 2) + ':' +
        right('00' + substring(cast([Run_Duration] as varchar),(len([Run_Duration])-3),2), 2) + ':' +
        right('00' + substring(cast([Run_Duration] as varchar),(len([Run_Duration])-1),2), 2) as [Run_Duration]
      ,	cast([SQl_Message] AS VARCHAR(3990)) as [SQl_Message]
   into #Return
   from #Result_History_Jobs 
  where cast([Run_Date] + ' ' + right('00' + substring([Run_Time],(len([Run_Time])-5), 2), 2) + ':' +
        right('00' + SUBSTRING([Run_Time],(len([Run_Time])-3), 2), 2) + ':' +
        right('00' + SUBSTRING([Run_Time],(len([Run_Time])-1), 2), 2) as datetime) >= @yesterday + ' 08:00' 
        and  
        cast([Run_Date] + ' ' + right('00' + SUBSTRING([Run_Time],(LEN([Run_Time])-5), 2), 2) + ':' +
        right('00' + substring([Run_Time],(len([Run_Time])-3), 2), 2) + ':' +
        right('00' + substring([Run_Time],(len([Run_Time])-1), 2), 2) as datetime) < @today
		  --and [Step_Id] = 0
          and [Step_Id] <> 0
          and [Run_Status] <> 1
	 
	if (@@ROWCOUNT = 0)
	begin
              select null               as [Server]
                   , 'No job registers' as [Job_Name]
                   , null               as [Status]
                   , null               as [Dt_Execucao]
                   , null               as [Run_Duration]
                   , null               as [SQL_Message]
				   
	  end
    else
    begin
              select [Server]
                   , [Job_Name]
                   , [Status]
                   , [Dt_Execucao]
                   , [Run_Duration]
                   , [SQL_Message]
                from #Return
    end
 
end
