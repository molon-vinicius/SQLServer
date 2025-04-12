create or alter procedure USP_GEN_BKP_JOBS

as

declare @SQL nvarchar(max) = '' 
declare @name nvarchar(120) 
/* replace jobs owners */
declare @replaceOwner char = 'N' --Y/N
declare @ownerName nvarchar(100) = null
declare @serverName nvarchar(100) = (select @@SERVERNAME)
/*****************************/

declare @email nvarchar(500)
declare @jobID uniqueidentifier
declare @jobName varchar(200)
declare @auxID int 
declare @auxUID uniqueidentifier

if object_id('tempdb..#JOBS_HEADER')    is not null drop table #JOBS_HEADER
if object_id('tempdb..#JOBS_STEPS')     is not null drop table #JOBS_STEPS
if object_id('tempdb..#JOBS_SCHEDULES') is not null drop table #JOBS_SCHEDULES
if object_id('tempdb..#JOBS_ALERTS')    is not null drop table #JOBS_ALERTS

if object_id('tempdb..#AUX_HEADER')     is not null drop table #AUX_HEADER
if object_id('tempdb..#AUX_STEPS')      is not null drop table #AUX_STEPS
if object_id('tempdb..#AUX_SCHEDULES')  is not null drop table #AUX_SCHEDULES
if object_id('tempdb..#AUX_ALERTS')     is not null drop table #AUX_ALERTS

create table #JOBS_HEADER
            ( [ID] numeric(15) identity
            , [JobID] uniqueidentifier
            , [JobName] nvarchar(200)
            , [JobEnabled] char
            , [JobDescription] nvarchar(1000)
            , [ServerName] nvarchar(max)
            , [InsertDate] datetime
            , [UpdateDate] datetime
            , [StartStepID] int
            , [CategoryName] nvarchar(100)
            , [OwnerName] nvarchar(100)
            , [OperatorName] nvarchar(100)
            , [EmailAddress] nvarchar(500)
            , [NotifyLevelEventlog] int
            , [NotifyLevelEmail] int
            , [NotifyLevelNetsend] int
            , [NotifyLevelPage] int
            , [NotifyEmailOperatorID] int
            , [NotifyNetsendOperatorID] int
            , [NotifyPageOperatorID] int
            , [NotifyNetsendOperatorName] nvarchar(100)
            , [NotifyPageOperatorName] nvarchar(100)
            , [DeleteLevel] int
            , [SQLCommand] nvarchar(max))

create table #JOBS_STEPS
            ( [JobID] uniqueidentifier
            , [JobName] nvarchar(200)
            , [StepID] int
            , [StepName] nvarchar(max)
            , [StepActive] char
            , [InsertDate] datetime
            , [UpdateDate] datetime
            , [Subsystem] nvarchar(max)
            , [Command] nvarchar(max)
            , [Flags] int
            , [AdditionalParameters] nvarchar(max)
            , [CMDExecSuccessCode] int
            , [OnSuccessAction] tinyint
            , [OnSuccessStepID] int
            , [OnFailAction] tinyint
            , [OnFailStepID] int
            , [ServerName] nvarchar(max)
            , [DatabaseName] nvarchar(max)
            , [DatabaseUserName] nvarchar(max)
            , [RetryAttempts] int
            , [RetryInterval] int
            , [OSRunPriority] int
            , [OutputFileName] nvarchar(max)
            , [LastRunOutcome] int
            , [LastRunDuration] int
            , [LastRunRetries] int
            , [LastRunDate] int
            , [LastRunTime] int
            , [ProxyID] int
            , [StepUID] uniqueidentifier 
            , [SQLCommand] nvarchar(max))

create table #JOBS_SCHEDULES 
            ( [JobID] uniqueidentifier
            , [JobName] nvarchar(200)
            , [ScheduleID] int
            , [ScheduleUID] uniqueidentifier
            , [ScheduleName] varchar(200) 
            , [ScheduleEnabled] char
            , [ServerName] nvarchar(max)
            , [InsertDate] datetime
            , [UpdateDate] datetime
            , [FreqType] int
            , [FreqInterval] int
            , [FreqSubdayType] int
            , [FreqSubdayInterval] int
            , [FreqRelativeInterval] int
            , [FreqRecurrenceFactor] int
            , [ActiveStartDate] int
            , [ActiveEndDate] int
            , [ActiveStartTime] int
            , [ActiveEndTime] int
            , [SQLCommand] nvarchar(max))

create table #JOBS_ALERTS 
            ( [AlertID] int	
            , [AlertName] nvarchar(max)	
            , [ServerName] nvarchar(max)
            , [Eventsource] nvarchar(100)	
            , [EventCategoryID] int	
            , [EventID] int	
            , [MessageID] int	
            , [Severity] int	
            , [AlertEnabled] tinyint	
            , [InsertDate] datetime
            , [UpdateDate] datetime
            , [DelayBetweenResponses] int	
            , [LastOccurrenceDate] int	
            , [LastOccurrenceTime] int	
            , [LastResponseDate] int	
            , [LastResponseTime] int	
            , [NotificationMessage] nvarchar(512)	
            , [IncludeEventDescription] tinyint	
            , [DatabaseName] nvarchar(512)	
            , [EventDescriptionKeyword] nvarchar(100)	
            , [OccurrenceCount] int	
            , [CountResetDate] int	
            , [CountResetTime] int	
            , [JobID] uniqueidentifier
            , [JobName] varchar(200)
            , [HasNotification] int	
            , [Flags] int
            , [PerformanceCondition] nvarchar(512)
            , [CategoryID] int
            , [SQLCommand] nvarchar(max))

  insert into #JOBS_HEADER
             ([JobID]
            , [JobName]
            , [JobEnabled]
            , [JobDescription]
            , [ServerName]
            , [StartStepID]
            , [CategoryName]
            , [OwnerName]
            , [OperatorName]
            , [EmailAddress]
            , [NotifyLevelEventlog]
            , [NotifyLevelEmail]
            , [NotifyLevelNetsend]
            , [NotifyLevelPage]
            , [NotifyEmailOperatorID]
            , [NotifyNetsendOperatorID]
            , [NotifyPageOperatorID]
            , [NotifyNetsendOperatorName]
            , [NotifyPageOperatorName]
            , [DeleteLevel])

	   select a.[job_id]  
            , a.[name]
            , a.[enabled]
            , a.[description]
            , @serverName
            , a.[start_step_id]
            , b.[name]
            , suser_sname(a.[owner_sid])
            , c.[name]
            , c.[email_address]
            , a.[notify_level_eventlog]
            , a.[notify_level_email]
            , a.[notify_level_netsend]
            , a.[notify_level_page]
            , a.[notify_email_operator_ID]
            , a.[notify_netsend_operator_ID]
            , a.[notify_page_operator_ID]
            , d.[name]
            , e.[name]
            , a.[delete_level]
         from [msdb].[dbo].[sysjobs]        a with(nolock)
    left join [msdb].[dbo].[syscategories]  b with(nolock)on b.[category_ID] = a.[category_ID]
    left join [msdb].[dbo].[sysoperators]   c with(nolock)on c.[ID] = a.[notify_email_operator_ID]
    left join [msdb].[dbo].[sysoperators]   d with(nolock)on d.[ID] = a.[notify_netsend_operator_ID]
    left join [msdb].[dbo].[sysoperators]   e with(nolock)on e.[ID] = a.[notify_page_operator_ID]
        where 1 = 1

  insert into #JOBS_STEPS 
             ([JobID]
            , [JobName]				  
            , [StepID]	            
            , [StepName]	        
            , [Subsystem]	        
            , [Command]	            
            , [Flags]	            
            , [AdditionalParameters]
            , [CMDExecSuccessCode]	
            , [OnSuccessAction]	
            , [OnSuccessStepID]	
            , [OnFailAction]	    
            , [OnFailStepID]	    
            , [ServerName]	            
            , [DatabaseName]	    
            , [DatabaseUserName]	
            , [RetryAttempts]	    
            , [RetryInterval]	    
            , [OSRunPriority]	    
            , [OutputFileName]	    
            , [LastRunOutcome]	    
            , [LastRunDuration]	
            , [LastRunRetries]	    
            , [LastRunDate]	    
            , [LastRunTime]	    
            , [ProxyID]             
            , [StepUID])
        
       select b.[job_id]	
            , a.[name]			
            , b.[step_id]	            
            , b.[step_name]	        
            , b.[subsystem]	        
            , b.[command]	            
            , b.[flags]	            
            , b.[additional_parameters]
            , b.[cmdexec_success_code]	
            , b.[on_success_action]	
            , b.[on_success_step_id]	
            , b.[on_fail_action]	    
            , b.[on_fail_step_id]	    
            , @serverName	            
            , b.[database_name]	    
            , b.[database_user_name]	
            , b.[retry_attempts]	    
            , b.[retry_interval]	    
            , b.[os_run_priority]	    
            , b.[output_file_name]	    
            , b.[last_run_outcome]	    
            , b.[last_run_duration]	
            , b.[last_run_retries]	    
            , b.[last_run_date]	    
            , b.[last_run_time]	    
            , b.[proxy_id]             
            , b.[step_uid]             
         from [msdb].[dbo].[sysjobs]        a with(nolock)  
         join [msdb].[dbo].[sysjobsteps]    b with(nolock) on b.[job_id] = a.[job_id]
        where 1 = 1

  insert into #JOBS_SCHEDULES
            ( [JobID]
            , [JobName]
            , [ScheduleID]
            , [ScheduleUID]
            , [ScheduleName]
            , [ScheduleEnabled]
            , [ServerName]
            , [FreqType]
            , [FreqInterval]
            , [FreqSubdayType]
            , [FreqSubdayInterval]
            , [FreqRelativeInterval]
            , [FreqRecurrenceFactor]
            , [ActiveStartDate]
            , [ActiveEndDate]
            , [ActiveStartTime]
            , [ActiveEndTime])

       select a.[job_id]
            , a.[name]
            , b.[schedule_ID]
            , c.[schedule_uid]
            , c.[name]
            , c.[enabled]
            , @serverName
            , c.[freq_type]
            , c.[freq_interval]
            , c.[freq_subday_type]
            , c.[freq_subday_interval]
            , c.[freq_relative_interval]
            , c.[freq_recurrence_factor]
            , c.[active_start_date]
            , c.[active_end_date]
            , c.[active_start_time]
            , c.[active_end_time]
         from [msdb].[dbo].[sysjobs]           a with(nolock) 
         join [msdb].[dbo].[sysjobschedules]   b with(nolock) on b.[job_id] = a.[job_id]
         join [msdb].[dbo].[sysschedules]      c with(nolock) on c.[schedule_ID] = b.[schedule_ID]
        where 1 = 1

  insert into #JOBS_ALERTS
            ( [AlertID]                        	
            , [AlertName]    
            , [ServerName]			
            , [Eventsource]              
            , [EventCategoryID]         	
            , [EventID]                  	
            , [MessageID]                	
            , [Severity]                  	
            , [AlertEnabled]                   	
            , [DelayBetweenResponses]   	
            , [LastOccurrenceDate]      	
            , [LastOccurrenceTime]      	
            , [LastResponseDate]        	
            , [LastResponseTime]        	
            , [NotificationMessage]      	
            , [IncludeEventDescription] 	
            , [DatabaseName]             	
            , [EventDescriptionKeyword] 	
            , [OccurrenceCount]          	
            , [CountResetDate]          	
            , [CountResetTime]          	
            , [JobID]                    	
            , [JobName]                    	
            , [HasNotification]          	
            , [Flags]                     
            , [PerformanceCondition]     
            , [CategoryID])
                      
       select b.[id]                
            , b.[name]          
            , @serverName			
            , b.[event_source]              
            , b.[event_category_id]         	
            , b.[event_id]                  	
            , b.[message_id]                	
            , b.[severity]                  	
            , b.[enabled]                   	
            , b.[delay_between_responses]   	
            , b.[last_occurrence_date]      	
            , b.[last_occurrence_time]      	
            , b.[last_response_date]        	
            , b.[last_response_time]        	
            , b.[notification_message]      	
            , b.[include_event_description] 	
            , b.[database_name]             	
            , b.[event_description_keyword] 	
            , b.[occurrence_count]          	
            , b.[count_reset_date]          	
            , b.[count_reset_time]          	
            , b.[job_id]                    	
            , a.[name]                    	
            , b.[has_notification]          	
            , b.[flags]                     
            , b.[performance_condition]     
            , b.[category_id]
         from [msdb].[dbo].[sysjobs]      a with(nolock)  
         join [msdb].[dbo].[sysalerts]    b with(nolock) on b.[job_id] = a.[job_id]
        where 1 = 1

       select distinct 
              [JobID]
            , [JobName]
         into #AUX_HEADER
         from #JOBS_HEADER

       select distinct 
              [JobID]
            , [JobName]
            , [StepID]
            , [StepUID]
         into #AUX_STEPS
         from #JOBS_STEPS

       select distinct 
              [JobID]
            , [JobName]
            , [ScheduleID]
            , [ScheduleUID]
         into #AUX_SCHEDULES
         from #JOBS_SCHEDULES

       select distinct 
              [JobID]
            , [JobName]
            , [AlertID]
         into #AUX_ALERTS
         from #JOBS_ALERTS


while (select count([JobID]) as qtd from #AUX_HEADER) > 0
begin

   select @jobID = min([JobID]) from #AUX_HEADER
   select @jobName = [JobName]  from #AUX_HEADER where JobID = @jobID 

   select @SQL = 
'EXEC dbo.sp_add_job
   @jobName = N'''            + [JobName]                  +''''                + char(13) +  char(13)  
+',@enabled = '               + convert(nvarchar(max), [JobEnabled])            + char(13) +  char(13)  
+',@notify_level_eventlog = ' + convert(nvarchar(max), [NotifyLevelEventlog])   + char(13) +  char(13) 
+',@notify_level_email = '    + convert(nvarchar(max), [NotifyLevelEmail])      + char(13) +  char(13) 
+',@notify_level_netsend = '  + convert(nvarchar(max), [NotifyLevelNetsend])    + char(13) +  char(13) 
+',@notify_level_page = '     + convert(nvarchar(max), [NotifyLevelPage])       + char(13) +  char(13) 
+ iif([JobDescription] is not null, ',@description = N'''+ [JobDescription] +'''', '' )  + char(13) +  char(13)   
+',@[CategoryName] = N'''      + [CategoryName]             +''''
+',@owner_login_name = N''' + iif(isnull(@replaceOwner,'N') = 'Y', @ownerName , [OwnerName]) +''''
                            + iif([NotifyLevelEmail]   > 0, ',@notify_email_[OperatorName] = N'''+ [OperatorName] +''' ', '' )  
                            + iif([NotifyLevelNetsend] > 0, ',@notify_email_[OperatorName] = N'''+ [NotifyNetsendOperatorName] +''' ', '' )  	   
                            + iif([NotifyLevelPage] > 0, ',@notify_email_[OperatorName] = N'''+ [NotifyPageOperatorName] +''' ', '' ) + ''    
      from #JOBS_HEADER 
     where [JobID] = @jobID

    update a
       set [InsertDate] = getdate()
         , [SQLCommand] = @SQL
      from #JOBS_HEADER   a
     where [JobID] = @jobID     
	
   /* loop para verificar todas as etapas da @jobID atual */
   while (select count([StepID]) as qtd from #AUX_STEPS where [JobID] = @jobID) > 0
   begin
      
	  select @auxID  = min([StepID]) from #AUX_STEPS where JobID = @jobID
	  select @auxUID = [StepUID]     from #AUX_STEPS where JobID = @jobID and [StepID] = @auxID
	     set @SQL = ''

    select @SQL =  
 'EXEC msdb.dbo.sp_add_jobstep
    @jobName='''            + a.[JobName]                         + ''''       + char(13) +  char(13)  
+', @step_name=N'''         + replace(a.[StepName], '''', '''''') + ''''       + char(13) +  char(13)     
+', @step_id='              + convert(nvarchar(max), a.[StepID])               + char(13) +  char(13)  
+', @cmdexec_success_code=' + convert(nvarchar(max), a.[CMDExecSuccessCode])   + char(13) +  char(13)  
+', @on_success_action='    + convert(nvarchar(max), a.[OnSuccessAction])      + char(13) +  char(13)  
+', @on_success_step_id='   + convert(nvarchar(max), a.[OnSuccessStepID])      + char(13) +  char(13)  
+', @on_fail_action='       + convert(nvarchar(max), a.[OnFailAction])         + char(13) +  char(13)  
+', @on_fail_step_id='      + convert(nvarchar(max), a.[OnFailStepID])         + char(13) +  char(13)  
+', @retry_attempts='       + convert(nvarchar(max), a.[RetryAttempts])        + char(13) +  char(13)  
+', @retry_interval='       + convert(nvarchar(max), a.[RetryInterval])        + char(13) +  char(13)  
+', @os_run_priority='      + convert(nvarchar(max), a.[OSRunPriority])        + char(13) +  char(13)  
+', @subsystem=N'''         + a.[Subsystem]                      + ''''        + char(13) +  char(13)  
+', @command=N'''           + replace(a.[Command], '''', '''''') + ''''        + char(13) +  char(13)  
+ iif(a.[DatabaseName] is not null, ',@database_name = N'''+ a.[DatabaseName] +'''', '' )  + char(13) +  char(13)  
+', @flags='                + convert(nvarchar(max), a.[Flags])                + char(13) +  char(13) 
	    from #JOBS_STEPS  a
     where [StepUID] = @auxUID 

    update a
       set [InsertDate] = getdate()
         , [SQLCommand] = @SQL
      from #JOBS_STEPS   a
     where [jobID] = @jobID 
       and [StepUID] = @auxUID

	  delete 
	    from #AUX_STEPS 
	   where [JobID] = @jobID
       and [StepUID] = @auxUID

   end

   /* loop para verificar agendas da @jobID atual */
   while (select count([ScheduleID]) as qtd from #AUX_SCHEDULES where JobID = @jobID) > 0
   begin
      
	  select @auxID = min([ScheduleID]) from #AUX_SCHEDULES where JobID = @jobID
	  select @auxUID = [ScheduleUID]    from #AUX_SCHEDULES where JobID = @jobID and [ScheduleID] = @auxID
	     set @SQL = ''

    select @SQL = 
'EXEC msdb.dbo.sp_add_jobschedule @jobName='''  + [jobName] + ''''              + char(13) +  char(13) +                                                
', @name=N'''                + replace(a.[ScheduleName], '''', '''''') + ''''   + char(13) +  char(13) +    
', @enabled='                + convert(nvarchar(max), a.[ScheduleEnabled])      + char(13) +  char(13) +  
', @freq_type='              + convert(nvarchar(max), a.[FreqType])             + char(13) +  char(13) + 
', @freq_interval='          + convert(nvarchar(max), a.[FreqInterval])         + char(13) +  char(13) + 
', @freq_subday_type='       + convert(nvarchar(max), a.[FreqSubdayType])       + char(13) +  char(13) + 
', @freq_subday_interval='   + convert(nvarchar(max), a.[FreqSubdayInterval])   + char(13) +  char(13) + 
', @freq_relative_interval=' + convert(nvarchar(max), a.[FreqRelativeInterval]) + char(13) +  char(13) + 
', @freq_recurrence_factor=' + convert(nvarchar(max), a.[FreqRecurrenceFactor]) + char(13) +  char(13) + 
', @active_start_date='      + convert(nvarchar(max), a.[ActiveStartDate])      + char(13) +  char(13) + 
', @active_end_date='        + convert(nvarchar(max), a.[ActiveEndDate])        + char(13) +  char(13) + 
', @active_start_time='      + convert(nvarchar(max), a.[ActiveStartTime])      + char(13) +  char(13) + 
', @active_end_time='        + convert(nvarchar(max), a.[ActiveEndTime])        + char(13) +  char(13) + 
', @schedule_uid=N'''        + convert(nvarchar(max), a.[ScheduleUID]) + ''''   + char(13)  

	    from #JOBS_SCHEDULES       a
     where [ScheduleUID] = @auxUID

    update a
       set [InsertDate] = getdate()
         , [SQLCommand] = @SQL
      from #JOBS_SCHEDULES a
     where [jobID] = @jobID  
       and [ScheduleUID] = @auxUID

	  delete 
	    from #AUX_SCHEDULES
	   where JobID = @jobID
       and [ScheduleUID] = @auxUID

   end

   /* loop para verificar todos os alertas da @jobID atual */
   while (select count([AlertID]) as qtd from #AUX_ALERTS where JobID = @jobID) > 0
   begin
      
	  select @auxID = min([AlertID]) from #AUX_ALERTS where JobID = @jobID	  
	     set @SQL = ''

    select @SQL = 
'EXEC msdb.dbo.sp_add_alert'                                    + char(13) +  char(13) + 
', @name =n'''   + replace(a.[AlertName], '''', '''''') + ''''  + char(13) +  char(13) +  
', @message_id =' + convert(nvarchar(max), a.[MessageID])       + char(13) +  char(13) + 
', @severity = ' + convert(nvarchar(max), a.[Severity])         + char(13) +  char(13) + 
', @notification_message = n''Erro encontrado.'                 + char(13) +  char(13) + 
', @jobName = n''' + a.[JobName] + ''''                         + char(13) +  char(13) 
	    from #JOBS_ALERTS   a
     where [AlertID] = @auxID

    update a
       set [InsertDate] = getdate()
         , [SQLCommand] = @SQL
      from #JOBS_ALERTS   a
     where jobID = @jobID     

	  delete 
	    from #AUX_ALERTS
	   where JobID = @jobID
       and [AlertID] = @auxID

   end

    delete from #AUX_HEADER where JobID = @jobID
   
   set @SQL = ''

end


     merge [master].[dbo].[tb_bkp_jobs]  as target 
     using #JOBS_HEADER                  as source
      on ( source.[JobID]       = target.[JobID]
       and source.[ServerName]  = target.[ServerName] )
      when MATCHED 
       and target.[SQLCommand]   <> source.[SQLCommand]
        or target.[JobEnabled]   <> source.[JobEnabled]
        or target.[JobName]      <> source.[JobName]
        or target.[OwnerName]    <> source.[OwnerName]
        or target.[CategoryName] <> source.[CategoryName]
        or target.[OperatorName] <> source.[OperatorName]
        or target.[EmailAddress] <> source.[EmailAddress]
      then update 
       set target.[UpdateDate]   = getdate()
         , target.[SQLCommand]   = source.[SQLCommand]
         , target.[JobName]      = source.[JobName]
         , target.[JobEnabled]   = source.[JobEnabled]
         , target.[OwnerName]    = source.[OwnerName]
         , target.[CategoryName] = source.[CategoryName]
         , target.[OperatorName] = source.[OperatorName]
         , target.[EmailAddress] = source.[EmailAddress]
      when not matched by target then 
    insert ( [JobID]
           , [JobName]
           , [JobEnabled]
           , [InsertDate]
           , [OwnerName]
           , [CategoryName]
           , [OperatorName]
           , [EmailAddress]
           , [ServerName] 
           , [SQLCommand] ) 
    values ( source.[JobID]
           , source.[JobName]
           , source.[JobEnabled]
           , getdate()
           , source.[OwnerName]
           , source.[CategoryName]
           , source.[OperatorName]
           , source.[EmailAddress]
           , @serverName
           , source.[SQLCommand] )
      when not matched by source 
      then update 
       set target.[UpdateDate] = getdate()
         , target.[JobEnabled] = 0;
                             
     merge [master].[dbo].[tb_bkp_jobs_steps]  as target 
     using #JOBS_STEPS                         as source
      on ( source.[JobID]         = target.[JobID]
       and source.[ServerName]    = target.[ServerName] 
       and source.[StepID]        = target.[StepID] )
      when matched 
       and target.[SQLCommand]   <> source.[SQLCommand]
        or target.[StepName]     <> source.[StepName]
	  then update 
       set target.[UpdateDate]  = getdate()
         , target.[SQLCommand]  = source.[SQLCommand]
         , target.[StepName]    = source.[StepName]
      when not matched by target then 
    insert ( [InsertDate]
           , [ServerName]
           , [DatabaseName]
           , [JobID]
           , [JobName]
           , [StepID]
           , [StepName]
           , [StepUID]
           , [SQLCommand] ) 
    values ( getdate()
           , @serverName
           , source.[DatabaseName]
           , source.[JobID]
           , source.[JobName]
           , source.[StepID]
           , source.[StepName]
           , source.[StepUID]
           , source.[SQLCommand] )
      when not matched by source       
      then update 
       set target.[UpdateDate] = getdate();         
                           
     merge [master].[dbo].[tb_bkp_jobs_schedules]  as target 
     using #JOBS_SCHEDULES                         as source
      on ( source.[JobID]       = target.[JobID]
       and source.[ServerName]  = target.[ServerName] 
       and source.[ScheduleID]  = target.[ScheduleID] )
      when matched 
       and target.[SQLCommand]      <> source.[SQLCommand]
        or target.[ScheduleEnabled] <> source.[ScheduleEnabled]
        or target.[ScheduleName]    <> source.[ScheduleName]
      then update 
       set target.[UpdateDate]       = getdate()
         , target.[SQLCommand]       = source.[SQLCommand]
         , target.[ScheduleEnabled]  = source.[ScheduleEnabled]
         , target.[ScheduleName]     = source.[ScheduleName]
      when not matched by target then 
    insert ( [InsertDate]
           , [ScheduleEnabled]
           , [ServerName]
           , [JobID]
           , [ScheduleID]
           , [ScheduleName]
           , [SQLCommand] ) 
    values ( getdate()
           , source.[ScheduleEnabled]
           , @serverName
           , source.[JobID]
           , source.[ScheduleID]
           , source.[ScheduleName]           
           , source.[SQLCommand] )
      when not matched by source
      then update 
       set target.[UpdateDate] = getdate()
         , target.[ScheduleEnabled] = 0;
                              
     merge [master].[dbo].[tb_bkp_jobs_alerts]  as target 
     using #JOBS_ALERTS                         as source
      on ( source.[JobID]         = target.[JobID]
       and source.[ServerName]    = target.[ServerName] 
       and source.[AlertID]       = target.[AlertID] )
      when matched 
       and target.[SQLCommand]   <> source.[SQLCommand]
        or target.[AlertEnabled] <> source.[AlertEnabled]
        or target.[AlertName]    <> source.[AlertName]
      then update 
       set target.[UpdateDate]    = getdate()
         , target.[SQLCommand]    = source.[SQLCommand]
         , target.[AlertEnabled]  = source.[AlertEnabled]
         , target.[AlertName]     = source.[AlertName]
      when not matched by target then 
    insert ( [InsertDate]
           , [AlertEnabled]
           , [ServerName]
           , [JobID]
           , [AlertID]
           , [AlertName]
           , [SQLCommand] ) 
    values ( getdate()
           , source.[AlertEnabled]
           , source.[ServerName]
           , source.[JobID]
           , source.[AlertID]
           , source.[AlertName]
           , source.[SQLCommand] )
      when not matched by source 
      then update 
       set target.[UpdateDate] = getdate()
         , target.[AlertEnabled] = 0;                             


