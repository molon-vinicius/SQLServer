-- Code retrieved on 2021-07-01 
-- from https://docs.microsoft.com/en-us/troubleshoot/sql/security/transfer-logins-passwords-between-instances
-- Originally published in knowledge base article KB918992
-- Copyright Microsoft

USE [master]
GO
IF OBJECT_ID ('sp_hexadecimal') IS NOT NULL
DROP PROCEDURE sp_hexadecimal
GO
CREATE PROCEDURE sp_hexadecimal
@binvalue varbinary(256),
@hexvalue varchar (514) OUTPUT
AS
DECLARE @charvalue varchar (514)
DECLARE @i int
DECLARE @length int
DECLARE @hexstring char(16)
SELECT @charvalue = '0x'
SELECT @i = 1
SELECT @length = DATALENGTH (@binvalue)
SELECT @hexstring = '0123456789ABCDEF'
WHILE (@i <= @length)
BEGIN
DECLARE @tempint int
DECLARE @firstint int
DECLARE @secondint int
SELECT @tempint = CONVERT(int, SUBSTRING(@binvalue,@i,1))
SELECT @firstint = FLOOR(@tempint/16)
SELECT @secondint = @tempint - (@firstint*16)
SELECT @charvalue = @charvalue +
SUBSTRING(@hexstring, @firstint+1, 1) +
SUBSTRING(@hexstring, @secondint+1, 1)
SELECT @i = @i + 1
END

SELECT @hexvalue = @charvalue
GO
