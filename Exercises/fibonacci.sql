/* Fibonacci returned in a concat string */
declare @current   int = 1
declare @penult    int = 0
declare @antepen   int = 0
declare @ret       int = 20 --amount of values that will be allocated in the string
declare @aux       int = 1
declare @result nvarchar(max)

while @aux <= @ret
begin

  select @result = concat(@result,',',@current) 
  
  set @antepen = @penult
  set @penult = @current   
  set @current = @penult + @antepen

  set @aux = @aux + 1
end

  select substring(@result,2,len(@result))
