create table data(a text, b text);
.mode csv
.import input data

with data2 as (
select *, instr(a,'-') as a_mid, instr(b,'-') as b_mid
from data
),

data3 as (
select  
    cast(substr(a,1,a_mid-1) as int) as a1,
    cast(substr(a,a_mid+1) as int)   as a2,
    cast(substr(b,1,b_mid-1) as int) as b1, 
    cast(substr(b,b_mid+1) as int)   as b2
from data2
),

stats as (
select count(1) as total,
       sum((a2 < b1) | (a1 > b2)) as no_overlaps,
       sum((a1 >= b1) & (a2 <= b2)) as a_in_b,
       sum((b1 >= a1) & (b2 <= a2)) as b_in_a,
       sum((a1==b1) & (a2==b2)) as equal
from data3)

select a_in_b + b_in_a - equal, total - no_overlaps 
from stats
