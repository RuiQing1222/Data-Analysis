select a.role_id as '账号id',country as '注册国家',case when c.role_id is not null then '通关' else '未通关' end as '完成204413',pay as '总付费',
last_login as '最后登录时间'
from 
(select a.role_id,country
from 
(select role_id 
from 
(select role_id,max(round(cast(map_id as int)/10000,0)) as map_id
from fairy_town_server.server_map_enter
where day_time between 20210901 and ${endDate}
and server_id in (${serverIds})
group by 1 ) a1 
where map_id=21
group by 1) a 
join 
(select role_id,country
from fairy_town.server_role_create
where day_time  between  20210420 and ${endDate}
and server_id in (${serverIds})
group by 1,2
) b 
on a.role_id=b.role_id
) a 
left join 
(select role_id,task_group_id,task_id
from fairy_town_server.server_task_accept
where   day_time between 20210901 and ${endDate} 
and task_group_id ='204413'
and server_id in (${serverIds})
) c 
on a.role_id=c.role_id
left join 
(
select role_id,round(sum(pay_price),2) as pay
from fairy_town.order_pay 
where day_time  between  20210420 and ${endDate}
and server_id in (${serverIds})
group by 1
) d 
on a.role_id=d.role_id 
left join 
(
select role_id,max(to_date(cast (date_time as timestamp))) as last_login
from fairy_town.server_role_login 
where day_time between 20210901 and ${endDate}
and server_id in (${serverIds})
group by 1
) e 
on a.role_id=e.role_id 
order by 3 desc
