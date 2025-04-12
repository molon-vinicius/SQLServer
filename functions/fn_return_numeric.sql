create function [dbo].[fn_return_numeric] 
(@word nvarchar(100))

returns varchar(100)

as

begin 

/* test */
--declare @word nvarchar(100) = 'AS1M2KJ3~4Ç%5OO678BN9ZXTIJ0'

declare @ret  varchar(30)   = ''
declare @char nvarchar(100)
declare @aux  int = 1
declare @len  int 

  select @len = len(@word)

if isnumeric(@word) = 1 
begin
  set @ret = @word
end
else
begin
  while @aux <= @len
  begin
    if isnumeric(substring(@word,@aux,1)) = 1
    begin
      set @ret = @ret + (substring(@word,@aux,1))
    end	
    set @aux = @aux + 1
  end
end

  return @ret

end

