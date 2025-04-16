declare @num int = 1
declare @aux int = 1
declare @div int = 0
declare @msg varchar(20) = ''
 
while @aux <= @num
begin
  if @num % @aux = 0
  begin
    set @div = @div + 1
  end
  set @aux = @aux + 1
end

if @div = 2 or @num = 1
begin
  set @msg = ' it''s a prime number.'
end
else 
begin
  set @msg = ' it''s not a prime number.'
end

select concat(@num, @msg)
