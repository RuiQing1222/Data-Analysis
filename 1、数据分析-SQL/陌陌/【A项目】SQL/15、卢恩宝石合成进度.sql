select case datediff(rune_dt,birth_dt)  
when 0 then '第1天'
when 1 then '第2天'
when 2 then '第3天'
when 3 then '第4天'
when 4 then '第5天'
when 5 then '第6天'
when 6 then '第7天' end as '新增留存天数',
count(distinct case when rune_level=2  then a.role_id else null end) as '2级合成人数',
count(distinct case when rune_level=3  then a.role_id else null end) as '3级合成人数',
count(distinct case when rune_level=4  then a.role_id else null end) as '4级合成人数',
count(distinct case when rune_level=5  then a.role_id else null end) as '5级合成人数',
count(distinct case when rune_level=6  then a.role_id else null end) as '6级合成人数',
count(distinct case when rune_level=7  then a.role_id else null end) as '7级合成人数',
count(distinct case when rune_level=8  then a.role_id else null end) as '8级合成人数',
count(distinct case when rune_level=9  then a.role_id else null end) as '9级合成人数',
count(distinct case when rune_level=10 then a.role_id else null end) as '10级合成人数'
from 
(select to_date(cast (date_time as timestamp)) as birth_dt,role_id
from myth.server_role_create
where  day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
group by 1,2) a  
left join 
(select to_date(cast (date_time as timestamp)) as rune_dt,role_id,rune_level

from myth_server.server_rune_evolution
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and success=1
group by 1,2,3) b 
on a.role_id=b.role_id
where datediff(rune_dt,birth_dt) >=0 and datediff(rune_dt,birth_dt)  <=6
group by 1