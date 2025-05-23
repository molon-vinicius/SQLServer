create table [master].[dbo].[tb_bkp_jobs] 
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
            , [SQLCommand] nvarchar(max))

create table [master].[dbo].[tb_bkp_jobs_steps] 
            ( [JobID] uniqueidentifier
            , [JobName] nvarchar(200)
            , [StepID] int
            , [StepName] nvarchar(max)
            , [InsertDate] datetime
            , [UpdateDate] datetime
            , [ServerName] nvarchar(max)
            , [DatabaseName] nvarchar(max)
            , [StepUID] uniqueidentifier 
            , [SQLCommand] nvarchar(max))

create table [master].[dbo].[tb_bkp_jobs_schedules] 
            ( [JobID] uniqueidentifier
            , [JobName] nvarchar(200)
            , [ScheduleID] int
            , [ScheduleUID] uniqueidentifier
            , [ScheduleName] varchar(200) 
            , [ScheduleEnabled] char
            , [ServerName] nvarchar(max)                        
            , [InsertDate] datetime
            , [UpdateDate] datetime
            , [SQLCommand] nvarchar(max))

create table [master].[dbo].[tb_bkp_jobs_alerts] 
           ( [AlertID] int	
           , [AlertName] nvarchar(max)	
           , [AlertEnabled] tinyint	
           , [ServerName] nvarchar(max)                        
           , [InsertDate] datetime
           , [UpdateDate] datetime
           , [DatabaseName] nvarchar(512)	
           , [JobID] uniqueidentifier
           , [JobName] varchar(200)
           , [SQLCommand] nvarchar(max))
