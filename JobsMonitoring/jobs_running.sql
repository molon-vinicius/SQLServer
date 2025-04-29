/******************/
--	Jobs Running --
/******************/

create or alter procedure [dbo].[USP_Jobs_Running]

as

begin
    
	set nocount on

if object_id('tempdb..#Return') is not null drop table #Return

   select j.[name] as [Job_Name]
        , convert(varchar(16), start_execution_date,120) as [Start_Date]
        , rtrim(convert(char(17), datediff(second, convert(datetime, start_execution_date), getdate()) / 86400)) + ' Day(s) ' +
          right('00' + rtrim(convert(char(7), datediff(second, convert(datetime, start_execution_date), getdate()) % 86400 / 3600)), 2) + ' Hour(s) ' +
          right('00' + rtrim(convert(char(7), datediff(second, convert(datetime, start_execution_date), getdate()) % 86400 % 3600 / 60)), 2) + ' Minute(s) ' as [Job_Duration]
        , js.[step_name] as [Step_Name]
     into #Return
     from [msdb].[dbo].[sysjobactivity] ja with(nolock) 
left join [msdb].[dbo].[sysjobhistory]  jh with(nolock)on ja.[job_history_id] = jh.[instance_id]
     join [msdb].[dbo].[sysjobs]        j  with(nolock)on ja.[job_id] = j.[job_id]
     join [msdb].[dbo].[sysjobsteps]    js with(nolock)on ja.[job_id] = js.[job_id]
                                                      and isnull(ja.[last_executed_step_id], 0)+1 = js.[step_id]
    where ja.[session_id] = (select top 1 [session_id] from msdb.dbo.syssessions order by agent_start_date desc)
      and start_execution_date is not null
      and stop_execution_date is null
      and datediff(minute,start_execution_date, getdate()) >= 10 --minutes

    if (@@ROWCOUNT = 0)
    begin
      select 'No jobs in execution more than 10 minutes'  as [Job_Name]
           , null                                         as [Start_Date]
           , null                                         as [Job_Duration]
           , null                                         as [Step_Name] 
    end	
    else
    begin
      select [Job_Name]
           , [Start_Date]
           , [Job_Duration]
           , [Step_Name]
        from #Return
    end
  
end

