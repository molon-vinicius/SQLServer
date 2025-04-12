create or alter procedure USP_RESTORE_BKP_JOBS 

as 

  /* This version executes the commands in [master] tables */
declare @aux numeric(15)
declare @SQL nvarchar(max)


if object_id('TEMPDB..#JOBS')           is not null drop table #JOBS
if object_id('TEMPDB..#JOBS_STEPS')     is not null drop table #JOBS_STEPS
if object_id('TEMPDB..#JOBS_SCHEDULES') is not null drop table #JOBS_SCHEDULES
if object_id('TEMPDB..#JOBS_ALERTS')    is not null drop table #JOBS_ALERTS

create table #JOBS
            ([ID] numeric(15)
            ,[JobID] varbinary(85)
            ,[JobName] sysname 
            ,[InsertDate] datetime
            ,[UpdateDate] datetime
            ,[JobEnabled] bit
            ,[OwnerName] nvarchar(100)
            ,[CategoryName] nvarchar(100)
            ,[OperatorName] nvarchar(100)
            ,[EmailAddress] nvarchar(500)
            ,[ServerName] nvarchar(100) 
            ,[SQLCommand]  nvarchar(max))

create table #JOBS_STEPS
            ([ID] numeric(15) identity
            ,[InsertDate] datetime
            ,[UpdateDate] datetime
            ,[ServerName] nvarchar(100)
            ,[JobID] varbinary(85)
            ,[StepID] numeric(15)
            ,[StepName] nvarchar(200)
            ,[SQLCommand] nvarchar(max))

create table #JOBS_SCHEDULES
            ([ID] numeric(15) identity
            ,[InsertDate] datetime
            ,[UpdateDate] datetime
            ,[ScheduleEnabled] bit
            ,[ServerName] nvarchar(100)
            ,[JobID] varbinary(85)
            ,[ScheduleID] numeric(15)
            ,[ScheduleName] nvarchar(100)
            ,[SQLCommand] nvarchar(max))

create table #JOBS_ALERTS
            ([ID] numeric(15) identity
            ,[InsertDate] datetime
            ,[UpdateDate] datetime
            ,[AlertEnabled] bit
            ,[ServerName] nvarchar(100)
            ,[JobID] varbinary(85)
            ,[AlertID] numeric(15) 
            ,[AlertName] nvarchar(100)
            ,[SQLCommand] nvarchar(max))   
   
insert into #JOBS
           ([ID]
           ,[JobID]
           ,[JobName]
           ,[InsertDate]
           ,[UpdateDate]
           ,[JobEnabled]
           ,[OwnerName]
           ,[CategoryName]
           ,[OperatorName]
           ,[EmailAddress]
           ,[ServerName]
           ,[SQLCommand])
     
     select [ID]
          , [JobID]
          , [JobName]
          , [InsertDate]
          , [UpdateDate]
          , [JobEnabled]
          , [OwnerName]
          , [CategoryName]
          , [OperatorName]
          , [EmailAddress]
          , [ServerName]
          , [SQLCommand]
       from [master].[dbo].[tb_bkp_jobs] with(nolock)

insert into #JOBS_STEPS
            ([InsertDate]
            ,[UpdateDate]
            ,[ServerName]
            ,[JobID]
            ,[StepID]
            ,[StepName]
            ,[SQLCommand])

      select [InsertDate]
           , [UpdateDate]
           , [ServerName]
           , [JobID]
           , [StepID]
           , [StepName]
           , [SQLCommand]
        from [master].[dbo].[tb_bkp_jobs_steps] with(nolock)

 insert into #JOBS_SCHEDULES
            ([InsertDate]
            ,[UpdateDate]
            ,[ScheduleEnabled]
            ,[ServerName]
            ,[JobID]
            ,[ScheduleID]
            ,[ScheduleName]
            ,[SQLCommand])

      select [InsertDate]
           , [UpdateDate]
           , [ScheduleEnabled]
           , [ServerName]
           , [JobID]
           , [ScheduleID]
           , [ScheduleName]
           , [SQLCommand]
        from [master].[dbo].[tb_bkp_jobs_schedules] with(nolock)        

 insert into #JOBS_ALERTS
            ([InsertDate]
           , [UpdateDate]
           , [AlertEnabled]
           , [ServerName]
           , [JobID]
           , [AlertID]
           , [AlertName]
           , [SQLCommand])

      select [InsertDate]
           , [UpdateDate]
           , [AlertEnabled]
           , [ServerName]
           , [JobID]
           , [AlertID]
           , [AlertName]
           , [SQLCommand]
        from [master].[dbo].[tb_bkp_jobs_alerts] with(nolock)        

while (select count([ID]) as qtd from #JOBS) > 0
begin

       select @aux = min([ID])    from #JOBS 
       select @SQL = [SQLCommand] from #JOBS where [ID] = @aux
	
         exec sp_executesql @SQL

      delete from #JOBS where [ID] = @aux 

end

while (select count([ID]) as qtd from #JOBS_STEPS) > 0
begin

       select @aux = min([ID])    from #JOBS_STEPS 
       select @SQL = [SQLCommand] from #JOBS_STEPS where [ID] = @aux
	
         exec sp_executesql @SQL

       delete from #JOBS_STEPS where [ID] = @aux 

end                                             

while (select count([ID]) as qtd from #JOBS_SCHEDULES) > 0
begin

       select @aux = min([ID])    from #JOBS_SCHEDULES 
       select @SQL = [SQLCommand] from #JOBS_SCHEDULES where [ID] = @aux
	
         exec sp_executesql @SQL

       delete from #JOBS_SCHEDULES where [ID] = @aux 

end              

while (select count([ID]) as qtd from #JOBS_ALERTS) > 0
begin

       select @aux = min([ID])    from #JOBS_ALERTS 
       select @SQL = [SQLCommand] from #JOBS_ALERTS where [ID] = @aux
	
         exec sp_executesql @SQL

       delete from #JOBS_ALERTS where [ID] = @aux 

end

