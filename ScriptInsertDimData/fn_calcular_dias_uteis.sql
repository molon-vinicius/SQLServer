create or alter function fn_calcular_dias_uteis (@data date, @tipo tinyint) 
/* 0 Mensal | 1 Primeira Quinzena | 2 Segunda Quinzena */

returns int 

as

begin

    set @data = dateadd(day,1,eomonth(@data,-1))

declare @q1  int = 0
declare @q2  int = 0
declare @rtn int 
declare @ini int = day(@data)
declare @fim int

if @q1 = 0
and @tipo in (0, 1)
begin
set @fim = 15

   while (@ini <= @fim)
   begin
     if ( select datepart(weekday, @data)
        ) between 2 and 6
     and ( select 1
            from tb_feriados_nacionais with(nolock)
           where mes_dia = right(concat('0', day(@data)),2) + '/' + right(concat('0', month(@data)),2)
        ) is null
     and ( select feriado
            from dbo.fn_feriados_nacionais_moveis(year(@data))
           where format(feriado,'dd/MM/yyyy') = @data 
        ) is null
     begin           

	   set @q1 = @q1 + 1

     end
   	
     set @ini = @ini + 1
     set @data = dateadd(day,1,@data)

   end
end

if @tipo = 2
begin
  set @data = dateadd(day,15,@data)
end

if @q2 = 0
and @tipo in (0, 2)
begin
set @ini = 16
set @fim = day(eomonth(@data))

   while (@ini <= @fim)
   begin
     if ( select datepart(weekday, @data)
        ) between 2 and 6
     and ( select 1
            from tb_feriados_nacionais with(nolock)
           where mes_dia = right(concat('0', day(@data)),2) + '/' + right(concat('0', month(@data)),2)
        ) is null
     and ( select feriado
            from dbo.fn_feriados_nacionais_moveis(year(@data))
           where format(feriado,'dd/MM/yyyy') = @data 
        ) is null
     begin           

	   set @q2 = @q2 + 1

     end
   	
     set @ini = @ini + 1
     set @data = dateadd(day,1,@data)

   end
end

if @tipo = 1
begin
  set @rtn = @q1
end

if @tipo = 2
begin
  set @rtn = @q2
end

if @tipo = 0
begin
  set @rtn = @q1+@q2
end

  return @rtn
end

