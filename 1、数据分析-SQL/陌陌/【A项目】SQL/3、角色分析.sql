-- 仅支持单天查询


select role_type as '职业编号',
case when role_type='1' then '索尔'
     when role_type='2' then '布伦希尔德'
     when role_type='3' then '齐格飞'
     when role_type='4' then '乌勒尔'
     when role_type='5' then '芙蕾雅'
     end as '职业名',
count(distinct l1.role_id) as '角色数',     
--count(distinct case when 留存编号='留存' then l1.role_id else null end ) as '活跃角色数',
count(distinct case when 留存编号='流失' then l1.role_id else null end ) as '流失角色数'
from
(select a.role_type,a.role_id,
case when datediff(cast(b.date_time as timestamp),cast(a.date_time as timestamp))>0 and datediff(cast(b.date_time as timestamp),cast(a.date_time as timestamp))<=3  then '留存'
     else  '流失'
     end as 留存编号
from 
(select role_id,role_type,min(date_time) as date_time
from myth.server_role_login
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
group by 1,2) a 
left outer join 
(select role_id,role_type,date_time
from myth.server_role_login   
where day_time >= ${beginDate}    and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
) b 
on a.role_id=b.role_id  and a.role_type=b.role_type and b.date_time>a.date_time
group by 1,2,3
) l1
where 留存编号 is not null
group by 1,2
order by 1