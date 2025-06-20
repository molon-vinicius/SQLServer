CREATE OR ALTER FUNCTION dbo.fn_ConvertBytesValor
(
    @Bytes BIGINT,
    @Un NVARCHAR(10) --'Bytes', 'KB', 'MB', 'GB', 'TB'
)
RETURNS DECIMAL(20,2)
AS
BEGIN
    DECLARE @Resultado DECIMAL(20,2)

    SET @Resultado = 
        CASE WHEN UPPER(@Un) = 'BYTES' 
             THEN CAST(@Bytes AS DECIMAL(20,2))
             WHEN UPPER(@Un) = 'KB'    
             THEN CAST(@Bytes / 1024.0 AS DECIMAL(20,2))
             WHEN UPPER(@Un) = 'MB'    
             THEN CAST(@Bytes / 1048576.0 AS DECIMAL(20,2))      
             WHEN UPPER(@Un) = 'GB'
             THEN CAST(@Bytes / 1073741824.0 AS DECIMAL(20,2))   
             WHEN UPPER(@Un) = 'TB'
             THEN CAST(@Bytes / 1099511627776.0 AS DECIMAL(20,2))
             ELSE NULL
        END

    RETURN @Resultado

END

