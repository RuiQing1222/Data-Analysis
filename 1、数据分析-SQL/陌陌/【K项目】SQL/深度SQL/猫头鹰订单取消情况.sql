select 
l1.order_id as '猫头鹰订单ID',
生成订单数,
完成订单数,
取消订单数,
`订单完成率%`,
`订单取消率%`,
角色平均完成订单数,
角色平均取消订单数,
`完成订单平均时长（分钟）`,
`取消订单平均时长（分钟）`,
生成订单角色平均等级,
完成订单角色平均等级,
取消订单角色平均等级
from
(
select a.order_id as order_id, 
count(a.role_id) as '生成订单数', 
count(b.role_id) as '完成订单数',
count(c.role_id) as '取消订单数',
round(count(b.role_id)/count(a.role_id)*100,2) as '订单完成率%', 
round(count(c.role_id)/count(a.role_id)*100,2) as '订单取消率%', 
count(distinct a.role_id) as '生成订单角色数',
count(distinct b.role_id) as '完成订单角色数',
count(distinct c.role_id) as '取消订单角色数',
round(count(distinct b.role_id)/count(distinct a.role_id)*100,2) as '订单派发率%',
round(count(a.role_id)/count(distinct a.role_id),2) as '角色平均生成订单数', 
round(count(b.role_id)/count(distinct b.role_id),2) as '角色平均完成订单数',
round(count(c.role_id)/count(distinct c.role_id),2) as '角色平均取消订单数'
from 
(select order_id, role_id
from fairy_town_server.server_order_accepted
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and order_type = '1' 
) a 
left outer join 
(select order_id, role_id
from fairy_town_server.server_order_owl
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
) b
on a.order_id = b.order_id and a.role_id = b.role_id
left join 
(select order_id, role_id
from fairy_town_server.server_order_canceled
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
) c
on a.order_id = c.order_id and a.role_id = c.role_id
group by a.order_id
)l1
left  join
(
select 
order_id,
round(avg(`完成时长`),2) as '完成订单平均时长（分钟）',
round(avg(`取消时长`),2) as '取消订单平均时长（分钟）',
round(avg(t1.accept_level),2) as '生成订单角色平均等级',
round(avg(t1.complete_level),2) as '完成订单角色平均等级',
round(avg(t1.cancel_level),2) as '取消订单角色平均等级'
from
(
select l1.day_time as 'day_time', l1.role_id as 'role_id', l1.order_id as 'order_id', 
round(avg(complete_time-start_time)/60000,2) as '完成时长', 
round(avg(cancel_time-start_time)/60000,2) as '取消时长',
avg(l1.role_level) as 'accept_level', 
avg(l2.role_level) as 'complete_level',
avg(l3.role_level) as 'cancel_level'
from
(select day_time, role_id, order_id, avg(log_time) as 'start_time', avg(role_level) as 'role_level'
from fairy_town_server.server_order_accepted
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
      and order_type = '1' 
group by day_time, role_id, order_id
)l1
left join
(select day_time, role_id, order_id, avg(log_time) as 'complete_time', avg(role_level) as 'role_level'
from fairy_town_server.server_order_owl
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})  
group by day_time, role_id, order_id
)l2 on l1.day_time=l2.day_time and l1.role_id=l2.role_id and l1.order_id=l2.order_id and start_time<complete_time
left join 
(select day_time, role_id, order_id, avg(log_time) as 'cancel_time', avg(role_level) as 'role_level'
from fairy_town_server.server_order_canceled
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})  
group by day_time, role_id, order_id
)l3 on l1.day_time=l3.day_time and l1.role_id=l3.role_id and l1.order_id=l3.order_id
and start_time<cancel_time 
group by l1.day_time, l1.role_id, l1.order_id
)t1
group by order_id
)l2 on l1.order_id=l2.order_id
order by 生成订单数 desc
