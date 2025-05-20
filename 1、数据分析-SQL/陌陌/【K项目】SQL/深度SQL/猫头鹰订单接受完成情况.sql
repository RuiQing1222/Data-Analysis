select 
l1.order_id as '猫头鹰订单ID',
生成订单数,
完成订单数,
`订单完成率%`,
账户平均完成订单数,
`完成订单平均时长（分钟）`,
生成订单账户平均等级,
完成订单账户平均等级
from
(
select a.order_id as 'order_id', 
count(a.user_id) as '生成订单数', 
count(b.user_id) as '完成订单数',
round(count(b.user_id)/count(a.user_id)*100,2) as '订单完成率%', 
count(distinct a.user_id) as '生成订单账户数',
count(distinct b.user_id) as '完成订单账户数',
round(count(distinct b.user_id)/count(distinct a.user_id)*100,2) as '订单派发率%',
round(count(a.user_id)/count(distinct a.user_id),2) as '账户平均生成订单数', 
round(count(b.user_id)/count(distinct b.user_id),2) as '账户平均完成订单数'
from 
(select order_id, user_id
from fairy_town_server.server_order_accepted
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and order_type = '1' 
) a left join 
(select order_id, user_id
from fairy_town_server.server_order_owl
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
) b
on a.order_id = b.order_id and a.user_id = b.user_id
group by a.order_id
)l1
left join
(
select 
order_id,
round(avg(`时长`),2) as '完成订单平均时长（分钟）',
round(avg(t1.accept_level),2) as '生成订单账户平均等级',
round(avg(t1.complete_level),2) as '完成订单账户平均等级'
from
(
select l1.day_time as 'day_time', l1.user_id as 'user_id', l1.order_id as 'order_id', 
round(avg(complete_time-start_time)/60000,2) as '时长', 
avg(l1.role_level) as 'accept_level', 
avg(l2.role_level) as 'complete_level'
from
(select day_time, user_id, order_id, avg(log_time) as 'start_time', avg(role_level) as 'role_level'
from fairy_town_server.server_order_accepted
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
      and order_type = '1' 
group by day_time, user_id, order_id
)l1
right join
(select day_time, user_id, order_id, avg(log_time) as 'complete_time', avg(role_level) as 'role_level'
from fairy_town_server.server_order_owl
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})  
group by day_time, user_id, order_id
)l2 on l1.day_time=l2.day_time and l1.user_id=l2.user_id and l1.order_id=l2.order_id
and start_time<complete_time 
group by l1.day_time, l1.user_id, l1.order_id
)t1
group by order_id
)l2 on l1.order_id=l2.order_id
order by 生成订单数 desc
