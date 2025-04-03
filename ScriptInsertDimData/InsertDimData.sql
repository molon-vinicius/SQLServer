declare @ini       date
declare @fim       date
declare @year      varchar(4)
declare @month     varchar(2)
declare @monthname varchar(15)
declare @day       varchar(2)
declare @weekday   varchar(15)
declare @week      int
declare @holiday   int = 0
declare @q         varchar(2)
declare @qaux      int
select @ini = '01/01/2024'
select @fim = getdate()

if (select count(CodDimData) as qtd from DimData) > 0
begin
  
  truncate table DimData
  /* redefinir a pk CodDimData para iniciar no valor 1 */
  dbcc checkident('[DimData]', reseed, 1)
  
  /* como é uma tabela de BI geralmente o índice 0 é para informações fora do padrão */
  set identity_insert DimData on

  insert into DimData
             ([CodDimData]
             ,[DataCompleta]
             ,[AnoMes]
             ,[Ano]
             ,[Mes]
             ,[Dia]
             ,[DiaSemanaDesc]
             ,[NumeroSemana]
             ,[Feriado]
             ,[DiaUtil]
             ,[MesDesc]
             ,[Trimestre]
             ,[Semestre]
             ,[Quinzena]
             ,[DiasUteisQ1]
             ,[DiasUteisQ2]
             ,[DiasUteisMes])

       select 0            as [CodDimData]
             ,'01/01/1900' as [DataCompleta]
             ,'190001'     as [AnoMes]
             ,'1900 '      as [Ano]
             ,'01'         as [Mes]
             ,'01'         as [Dia]
             ,'Domingo'    as [DiaSemanaDesc]
             ,1            as [NumeroSemana]
             ,'S'          as [Feriado]
             ,'N'          as [DiaUtil]
             ,'Janeiro'    as [MesDesc]
             ,'T1'         as [Trimestre]
             ,'S1'         as [Semestre]
             ,'Q1'         as [Quinzena]
             ,0            as [DiasUteisQ1]
             ,0            as [DiasUteisQ2]
             ,0            as [DiasUteisMes]
			 
  set identity_insert DimData off

end

while @ini <= @fim
begin
     set @year       = convert(varchar(4), year(@ini))
     set @month      = right(concat('0',month(@ini)),2) 
     set @monthname  = case when month(@ini) =  1 then 'Janeiro'
                            when month(@ini) =  2 then 'Fevereiro'
                            when month(@ini) =  3 then 'Março'
                            when month(@ini) =  4 then 'Abril'
                            when month(@ini) =  5 then 'Maio'
                            when month(@ini) =  6 then 'Junho'
                            when month(@ini) =  7 then 'Julho'
                            when month(@ini) =  8 then 'Agosto'
                            when month(@ini) =  9 then 'Setembro'
                            when month(@ini) = 10 then 'Outubro'
                            when month(@ini) = 11 then 'Novembro'
                            when month(@ini) = 12 then 'Dezembro'
                       end
     set @day        = right(concat('0',  day(@ini)),2)
     set @weekday    = case when datepart(weekday, @ini) = 1 then 'Domingo'
                            when datepart(weekday, @ini) = 2 then 'Segunda-feira'
                            when datepart(weekday, @ini) = 3 then 'Terça-feira'
                            when datepart(weekday, @ini) = 4 then 'Quarta-feira'
                            when datepart(weekday, @ini) = 5 then 'Quinta-feira'
                            when datepart(weekday, @ini) = 6 then 'Sexta-feira'
                            when datepart(weekday, @ini) = 7 then 'Sábado'
                       end
     set @week       = datepart(week, @ini)
     set @qaux       = day(eomonth(@ini)) / 2
     set @q          = iif(@day <= @qaux, 'Q1','Q2')

if ( select 1
       from tb_feriados_nacionais with(nolock)
      where mes_dia = concat(@day,'/',@month) ) is not null
or ( select 1
       from dbo.fn_feriados_nacionais_moveis(@year)
      where feriado = @ini ) is not null
begin 
   set @holiday = 1
end
else
begin
   set @holiday = 0
end

  insert into DimData
             ([DataCompleta]
             ,[AnoMes]
             ,[Ano]
             ,[Mes]
             ,[Dia]
             ,[DiaSemanaDesc]
             ,[NumeroSemana]
             ,[Feriado]
             ,[DiaUtil]
             ,[MesDesc]
             ,[Trimestre]
             ,[Semestre]
             ,[Quinzena]
             ,[DiasUteisQ1]
             ,[DiasUteisQ2]
             ,[DiasUteisMes])

  select @ini                                  as [Data]
       , concat(@year, @month)                 as [AnoMes]
       , @year                                 as [Ano]
       , @month                                as [Mes]
       , @day                                  as [Dia]
       , @weekday                              as [DiaSemana]
       , @week                                 as [NumeroSemana]
       , iif(@holiday = 1, 'S', 'N')           as [Feriado]
       , iif(@holiday = 0 and @weekday not in ('Sábado', 'Domingo'), 'S', 'N') as [DiaUtil]
       , @monthname                            as [MesNome]
       , case when @month < 4 
              then 'T1'
              when @month > 3 and @month < 7
              then 'T2'
              when @month > 6 and @month < 10
              then 'T3'
              else 'T4' 
         end                                   as [Trimestre]
       , iif(@month <=  6, 'S1','S2')          as [Semestre]
       , @q                                    as [Quinzena]
       , dbo.fn_calcular_dias_uteis(@ini,1)    as [DiasUteisQ1]
       , dbo.fn_calcular_dias_uteis(@ini,2)    as [DiasUteisQ2]
       , dbo.fn_calcular_dias_uteis(@ini,0)    as [DiasUteisMes]
 
 set @ini = dateadd(day,1,@ini)

end
