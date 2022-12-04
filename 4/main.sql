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

select 
    sum(case 
        when (a_start <= b_start and a_end >= b_end) then 1
        when (b_start <= a_start and b_end >= a_end) then 1
        else 0
    end) as total_a,
    
    sum(case
        when (a_end < b_start) then 0
        when (b_end < a_start) then 0
        else 1
    end) as total_b

from data3
