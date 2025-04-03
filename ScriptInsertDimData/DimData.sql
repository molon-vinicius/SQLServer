create table DimData
             ([CodDimData] numeric(15) identity
             ,[DataCompleta] date
             ,[AnoMes] varchar(6)
             ,[Ano] varchar(4)
             ,[Mes] varchar(2)
             ,[Dia] varchar(2)
             ,[DiaSemanaDesc] varchar(15)
             ,[NumeroSemana] tinyint
             ,[Feriado] varchar(1)
             ,[DiaUtil] varchar(1)
             ,[MesDesc] varchar(15)
             ,[Trimestre] varchar(2)
             ,[Semestre] varchar(2)
             ,[Quinzena] varchar(2) 
             ,[DiasUteisQ1] tinyint
             ,[DiasUteisQ2] tinyint
             ,[DiasUteisMes] tinyint
             ,constraint pk_DimData primary key (CodDimData))
