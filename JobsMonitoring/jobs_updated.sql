/******************/
--	Jobs Updated --
/******************/

create or alter procedure [dbo].[USP_Jobs_Updated]

as

begin

    set nocount on

declare @today varchar(8)
declare @yesterday varchar(8)

if object_id('tempdb..#Return') is not null drop table #Return

    select @yesterday = convert(varchar(8),(dateadd (day, -1, getdate())), 112)
         , @today = convert(varchar(8), getdate()+1, 112)

    select [name] as [Job_Name]
         , convert(smallint, [enabled]) as [Enabled]
         , convert(smalldatetime, [date_created]) as [Create_Date]
	       , convert(smalldatetime, [date_modified]) as [Update_Date]
         , [version_number] as [Version]
      into #Return
      from [msdb].[dbo].[sysjobs]  with(nolock)     
     where ([date_created] >= @yesterday and [date_created] < @today) 
        or ([date_modified] >= @yesterday and [date_modified] < @today)	
	 
	if (@@ROWCOUNT = 0)
	begin
		select 'No job registers updated' as [Job_Name]
          , null                      as [Enabled] 
          , null                      as [Create_Date]
          , null                      as [Update_Date]
          , null                      as [Version]
	end
  else
  begin
    select [Job_Name]
         , [Enabled]		
         , [Create_Date]
         , [Update_Date]		
         , [Version]
      from #Return
  end

end
