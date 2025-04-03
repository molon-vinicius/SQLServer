create function [dbo].[fn_feriados_nacionais_moveis](@ano int)      
      
returns @feriados table       
       (feriado date    
       ,descricao varchar(100))       
as       
      
begin         
      
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
      
      
declare @retorno table (data_feriado date      
                       ,descricao varchar(100))
					   
insert into @retorno      
      
    values (dateadd(dd,  -2, @pascoa),'Paixão de Cristo')      
         , (dateadd(dd, -47, @pascoa),'Terça Carnaval')      
         --, (dateadd(dd, -48, @pascoa),'Segunda Carnaval')  
         , (dateadd(dd,  60, @pascoa),'Corpus Christi')      
      
insert into @feriados      
     select data_feriado, descricao   
       from @retorno      
      
   return      
      
end 

/* a função do cálculo de feriados com datas móveis foi encontrada no blog do Dirceu Resende e apenas adaptada para receber o parâmetro @ano */
/* https://dirceuresende.com/blog/como-criar-uma-tabela-com-os-feriados-nacionais-estaduais-e-moveis-no-sql-server/ */
