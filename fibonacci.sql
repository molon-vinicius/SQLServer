/* Sequência de Fibonacci exibida em uma string concatenada */
declare @atual   int = 1
declare @penul   int = 0
declare @antep   int = 0
declare @qtd     int = 20 --quantidade de valores que será retornada
declare @cont    int = 1
declare @result  nvarchar(max)

while @cont <= @qtd
begin

  select @result = concat(@result,',',@atual) 
  
  set @antep = @penul
  set @penul = @atual   
  set @atual = @penul + @antep

  set @cont = @cont + 1
end

  select substring(@result,2,len(@result))
