alter function [fn_feriados](@ano int)      
      
returns @retorno table       
       (feriado date    
       ,descricao varchar(100)
       ,tipo_feriado varchar(20))       
as       
      
begin         

-----------      
-- Teste --
-----------

--declare @retorno table
--      ( data_Feriado date
--      , descricao varchar(50)
--      , tipo_feriado varchar(50)) 

-- declare @ano int = getdate() 

declare @seculo int      
declare @g int
declare @k int      
declare @i int      
declare @h int      
declare @j int      
declare @l int      
declare @mesdepascoa int      
declare @diadepascoa int      
declare @pascoa date      
      
set @seculo = @ano / 100      
set @g = @ano % 19       
set @k = ( @seculo - 17 ) / 25       
set @i = ( @seculo - cast(@seculo / 4 as int) - cast(( @seculo - @k ) / 3 as int) + 19 * @g + 15 ) % 30       
set @h = @i - cast(@i / 28 as int) * ( 1 * -cast(@i / 28 as int) * cast(29 / ( @i + 1 ) as int) ) * cast(( ( 21 - @g ) / 11 ) as int)       
set @j = (@ano + cast(@ano / 4 as int) + @h + 2 - @seculo + cast(@seculo / 4 as int) ) % 7       
set @l = @h - @j        
set @mesdepascoa = 3 + cast(( @l + 40 ) / 44 as int)       
set @diadepascoa = @l + 28 - 31 * cast(( @mesdepascoa / 4 ) as int)       
set @pascoa = cast(@ano as varchar(4)) + '-' + cast(@mesdepascoa as varchar(2)) + '-' + cast(@diadepascoa as varchar(2))       
      
      
declare @feriados_moveis table ( data_feriado date      
                               , descricao varchar(100)
                               , tipo_feriado varchar(20)) -- 1 Nacional | 2 Estadual | 3 Municipal
					   
insert into @feriados_moveis      
      
    values (dateadd(dd,  -2, @pascoa),'Paixão de Cristo', 'Nacional')      
         , (dateadd(dd, -47, @pascoa),'Terça Carnaval', 'Nacional')      
         , (dateadd(dd, -48, @pascoa),'Segunda Carnaval', 'Nacional')  
         , (dateadd(dd,  60, @pascoa),'Corpus Christi', 'Nacional')      

-- a função do cálculo de feriados com datas móveis foi encontrada no blog do Dirceu Resende e apenas adaptada para receber o parâmetro @ano 
-- https://dirceuresende.com/blog/como-criar-uma-tabela-com-os-feriados-nacionais-estaduais-e-moveis-no-sql-server/ 

---------------------------------------------------
------------------ Feriados Fixos -----------------
---------------------------------------------------

declare @feriados_fixos table
       ( mes_dia varchar(5)
       , dia varchar(2)
       , mes varchar(2)
       , tipo_feriado varchar(20) -- 1 Nacional | 2 Estadual | 3 Municipal
       , descricao varchar(50) 
       , observacao varchar(100))
			
insert into @feriados_fixos (dia, mes, tipo_feriado, descricao, observacao)
     values ('01','01', 'Nacional','Confraternização Universal', null)
          , ('25','01', 'Municipal','Aniversário da Cidade de São Paulo', null)
          , ('21','04', 'Nacional','Tiradentes', null)
          , ('01','05', 'Nacional','Dia do Trabalho', null)
          , ('09','07', 'Estadual','Revolução Constitucionalista', null)
          , ('07','09', 'Nacional','Independência do Brasil', null)
          , ('12','10', 'Nacional','Nossa Senhora Aparecida', null)
          , ('02','11', 'Nacional','Finados', null)
          , ('15','11', 'Nacional','Proclamação da República', null)
          , ('20','11', 'Estadual','Dia da Consciência Negra','Feriado Nacional a partir de 2024.')
          , ('25','12', 'Nacional','Natal', null)
 
 insert into @retorno 
      select data_feriado            
           , descricao
           , tipo_feriado
        from @feriados_moveis           
       
	   union

      select convert(Date,concat(Dia,'/',Mes,'/',@ano), 103) as data_feriado
           , descricao
           , tipo_feriado
        from @feriados_fixos     
       order by data_feriado

---------------------------     
-- Verificar os feriados --
---------------------------  
      --select data_feriado, descricao, tipo_feriado
      --  from @retorno 
      -- order by convert(date, data_feriado)
             
   return 
        
end 

--------------------Utilizar------------------------------------------------------
--  select data_feriado, descricao, tipo_feriado from [admin].fn_feriados(2025)
----------------------------------------------------------------------------------
