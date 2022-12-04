create table data(a text, b text);
.mode csv
.import input data

with data2 as (
select *, instr(a,'-') as a_mid, instr(b,'-') as b_mid
from data
),

data3 as (
select 
    cast(substr(a,1,a_mid-1) as int) as a_start, 
    cast(substr(a,a_mid+1) as int)   as a_end,
    cast(substr(b,1,b_mid-1) as int) as b_start, 
    cast(substr(b,b_mid+1) as int)   as b_end
from data2
)

select count(1) from data3
where 
    (a_start <= b_start and a_end >= b_end)
    or (b_start <= a_start and b_end >= a_end)
