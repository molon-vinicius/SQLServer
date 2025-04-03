create table [tb_feriados_nacionais]
            (mes_dia varchar(5)
            ,dia varchar(2)
            ,mes varchar(2)
            ,descricao varchar(50) 
            ,observacao varchar(100))
			
insert into [tb_feriados_nacionais] (mes_dia, dia, mes, descricao, observacao)
     values ('01/01','01','01','Confraternização Universal',null)
          , ('21/04','21','04','Tiradentes',null)
          , ('01/05','01','05','Dia do Trabalho',null)
          , ('07/09','07','09','Independência do Brasil',null)
          , ('12/10','12','10','Nossa Senhora Aparecida',null)
          , ('02/11','02','11','Finados',null)
          , ('15/11','15','11','Proclamação da República',null)
          , ('20/11','20','11','Dia da Consciência Negra','Feriado Nacional a partir de 2024.')
          , ('25/12','25','12','Natal',null)

