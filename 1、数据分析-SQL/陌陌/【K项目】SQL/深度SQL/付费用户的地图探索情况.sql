select list1.map_id as '地图ID',
case list1.map_id
when 1 then  '家园'
when 2 then  '第一章1'
when 3 then  '第一章2'
when 4 then  '第一章3'
when 5 then  '野餐聚会'
when 6 then  '第二章1'
when 7 then  '第二章2'
when 8 then  '第二章3'
when 9 then  '第二章4'
when 10 then '第二章5'
when 11 then '成人礼'
when 12 then '第三章1'
when 13 then '第三章2'
when 14 then '第三章3'
when 15 then '第三章4'
when 16 then '第三章5'
when 18 then '第四章1'
when 19 then '第四章2'
when 20 then '第四章3'
Else '暂不开启'
end as '地图名称',
开启地图付费账户数,
完成地图付费账户数,
round(完成地图付费账户数/开启地图付费账户数*100,2) as '地图完成率%',
完成地图付费账户平均进入地图次数, 
完成地图付费账户平均开启地图等级,
付费账户平均完成等级,
完成地图付费账户平均消耗体力数,
`付费账户平均完成地图时长(分钟)`,
`每次地图进离平均时长(分钟)`
from
(
select map_id, 开启地图付费账户数
from
(
(select 1 as 'map_id', count(distinct user_id) as '开启地图付费账户数'
from fairy_town.order_pay
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
)union all
(select map_id, 
count(distinct user_id) as '开启地图付费账户数'
from
(
select map_id, a.user_id
from 
(
select user_id
from fairy_town.order_pay 
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by user_id
)a
left join 
(
select round(cast(map_id as int)/10000,0) as 'map_id', user_id
from fairy_town_server.server_map_open
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by round(cast(map_id as int)/10000,0), user_id
)b on a.user_id=b.user_id
)t1
group by map_id)
)a
)list1 left join 
(select map_id, 完成地图付费账户数, 付费账户平均完成等级
from
(
(select map_id, 
count(distinct user_id) as '完成地图付费账户数',
round(avg(role_level),2) as '付费账户平均完成等级'
from
(
select map_id, a.user_id, role_level
from 
(
select user_id
from fairy_town.order_pay 
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by user_id
)a
left join 
(
select round(cast(map_id as int)/10000,0)-2 as 'map_id', user_id, avg(role_level) as role_level
from fairy_town_server.server_map_open
where round(cast(map_id as int)/10000,0) in (3,6)
and day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by round(cast(map_id as int)/10000,0), user_id
)b on a.user_id=b.user_id
)l2
group by map_id
)union all
(
select map_id, 
count(distinct user_id) as '完成地图付费账户数',
round(avg(role_level),2) as '付费账户平均完成等级'
from
(
select map_id, a.user_id, role_level
from 
(
select user_id
from fairy_town.order_pay 
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by user_id
)a
left join 
(
select round(cast(map_id as int)/10000,0)-1 as 'map_id', user_id, avg(role_level) as role_level
from fairy_town_server.server_map_open
where round(cast(map_id as int)/10000,0) not in (2,5,6,11,12,16)
and day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by round(cast(map_id as int)/10000,0), user_id
)b on a.user_id=b.user_id
)l2
group by map_id
)union all
(select map_id, 
count(distinct user_id) as '完成地图付费账户数',
round(avg(role_level),2) as '付费账户平均完成等级'
from
(
select map_id, a.user_id, role_level
from 
(
select user_id
from fairy_town.order_pay 
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by user_id
)a
left join 
(
select round(cast(map_id as int)/10000,0)-2 as 'map_id', user_id, avg(role_level) as role_level
from fairy_town_server.server_map_open
where round(cast(map_id as int)/10000,0)=12
and day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by round(cast(map_id as int)/10000,0), user_id
)b on a.user_id=b.user_id
)l2
group by map_id)
union all
(
select map_id, 
count(distinct user_id) as '完成地图付费账户数',
round(avg(role_level),2) as '付费账户平均完成等级'
from
(
select map_id, a.user_id, role_level
from 
(
select user_id
from fairy_town.order_pay 
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by user_id
)a
left join 
(
select round(cast(map_id as int)/10000,0) as 'map_id', user_id, avg(role_level) as role_level
from fairy_town_server.server_physical_consume
where round(cast(map_id as int)/10000,0)=5
and day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by round(cast(map_id as int)/10000,0), user_id
having sum(consume_count)>4000
)b on a.user_id=b.user_id
)l2
group by map_id
)
)t
)list2 on list1.map_id=list2.map_id
left join
(select map_id, round(sum(consume_count)/count(distinct user_id),2) as '完成地图付费账户平均消耗体力数'
from(
select t1.map_id, t1.user_id, consume_count
from
(
select map_id, user_id
from
(
(
select map_id, a.user_id
from 
(
select user_id
from fairy_town.order_pay 
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by user_id
)a
left join 
(
select round(cast(map_id as int)/10000,0)-2 as 'map_id', user_id
from fairy_town_server.server_map_open
where round(cast(map_id as int)/10000,0) in (3,6)
and day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by round(cast(map_id as int)/10000,0), user_id
)b on a.user_id=b.user_id
)
union all
(
select map_id, a.user_id
from 
(
select user_id
from fairy_town.order_pay 
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by user_id
)a
left join 
(
select round(cast(map_id as int)/10000,0)-1 as 'map_id', user_id
from fairy_town_server.server_map_open
where round(cast(map_id as int)/10000,0) not in (2,5,6,11,12,16)
and day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by round(cast(map_id as int)/10000,0), user_id
)b on a.user_id=b.user_id
)union all
(
select map_id, a.user_id
from 
(
select user_id
from fairy_town.order_pay 
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by user_id
)a
left join 
(
select round(cast(map_id as int)/10000,0)-2 as 'map_id', user_id
from fairy_town_server.server_map_open
where round(cast(map_id as int)/10000,0)=12
and day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by round(cast(map_id as int)/10000,0), user_id
)b on a.user_id=b.user_id
)
union all
(
select map_id, a.user_id
from 
(
select user_id
from fairy_town.order_pay 
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by user_id
)a
left join 
(
select round(cast(map_id as int)/10000,0) as 'map_id', user_id
from fairy_town_server.server_physical_consume
where round(cast(map_id as int)/10000,0)=5
and day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by round(cast(map_id as int)/10000,0), user_id
having sum(consume_count)>4000
)b on a.user_id=b.user_id
)
)t
)t1 left join
(
select round(cast(map_id as int)/10000,0) as 'map_id', user_id, sum(consume_count) as 'consume_count'
from fairy_town_server.server_physical_consume
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by round(cast(map_id as int)/10000,0), user_id
)t2 on t1.map_id=t2.map_id and t1.user_id=t2.user_id
)l3
group by map_id
)list3 on list1.map_id=list3.map_id
left join
(
select map_id, 
round(sum(`付费账户完成地图时长(分钟)`)/count(distinct user_id),2) as '付费账户平均完成地图时长(分钟)'
from
(
select map_id, ta2.user_id,`付费账户完成地图时长(分钟)`
from (
select t1.map_id as 'map_id', t1.user_id as 'user_id', 
round(avg(地图完成时间-地图开启时间)/60000,2) as '付费账户完成地图时长(分钟)'
from
(
select map_id, user_id, 地图开启时间
from
(
(select 1 as 'map_id', user_id, min(log_time) as '地图开启时间'
from fairy_town.role_create
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by user_id
)union all
(select round(cast(map_id as int)/10000,0) as 'map_id', 
user_id, min(log_time) as '地图开启时间'
from fairy_town_server.server_map_open
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by round(cast(map_id as int)/10000,0), user_id)
)a
)t1 left join
(
select map_id, user_id, 地图完成时间
from
(
(select round(cast(map_id as int)/10000,0)-2 as 'map_id', 
user_id, min(log_time) as '地图完成时间'
from fairy_town_server.server_map_open
where round(cast(map_id as int)/10000,0) in (3,6)
and day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by round(cast(map_id as int)/10000,0), user_id
)union all
(
select round(cast(map_id as int)/10000,0)-1 as 'map_id', 
user_id, min(log_time) as '地图完成时间'
from fairy_town_server.server_map_open
where round(cast(map_id as int)/10000,0) not in (2,5,6,11,12,16)
and day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by round(cast(map_id as int)/10000,0), user_id
)union all
(select round(cast(map_id as int)/10000,0)-2 as 'map_id', 
user_id, min(log_time) as '地图完成时间'
from fairy_town_server.server_map_open
where round(cast(map_id as int)/10000,0)=12
and day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by round(cast(map_id as int)/10000,0), user_id)
union all
(select round(cast(map_id as int)/10000,0) as 'map_id', 
user_id, max(log_time) as '地图完成时间'
from fairy_town_server.server_physical_consume
where round(cast(map_id as int)/10000,0)=5
and day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by round(cast(map_id as int)/10000,0), user_id
having sum(consume_count)>4000)
)b
)t2 on t1.map_id=t2.map_id and t1.user_id=t2.user_id
group by map_id, user_id
) ta1
right join
(
select user_id
from fairy_town.order_pay 
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by user_id
)ta2 on ta1.user_id=ta2.user_id
)l4
group by map_id
)list4 on list1.map_id=list4.map_id
left join
(
select map_id, 
round(avg(ms)/60000,2) as '每次地图进离平均时长(分钟)'
from 
(
select user_id
from fairy_town.order_pay 
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by user_id
)a left join
(
select round(cast(map_id as int)/10000,0) as 'map_id', 
user_id, log_time, min(ms) as 'ms'
from
(
select sme.map_id, sme.user_id, sme.log_time, (sml.log_time - sme.log_time) as 'ms'
from fairy_town_server.server_map_enter sme
left join fairy_town_server.server_map_leave sml
on sme.map_id = sml.map_id and sme.user_id = sml.user_id
where sml.user_id is not null
and sme.day_time between ${beginDate} and ${endDate} and sme.server_id in (${serverIds})
and sml.day_time between ${beginDate} and ${endDate} and sml.server_id in (${serverIds})
having (sml.log_time - sme.log_time)>0
) t1
group by round(cast(map_id as int)/10000,0), user_id, log_time
)b on a.user_id=b.user_id
group by map_id
)list5 on list1.map_id=list5.map_id
left join
(
select map_id, 
round(sum(times)/count(distinct user_id),2) as '完成地图付费账户平均进入地图次数',
round(avg(role_level),2) as '完成地图付费账户平均开启地图等级'
from(
select t1.map_id, t3.user_id, times, role_level
from
(
select map_id, user_id
from
(
(select round(cast(map_id as int)/10000,0)-2 as 'map_id', user_id
from fairy_town_server.server_map_open
where round(cast(map_id as int)/10000,0) in (3,6)
and day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by round(cast(map_id as int)/10000,0), user_id
)union all
(
select round(cast(map_id as int)/10000,0)-1 as 'map_id', user_id
from fairy_town_server.server_map_open
where round(cast(map_id as int)/10000,0) not in (2,5,6,11,12,16)
and day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by round(cast(map_id as int)/10000,0), user_id
)union all
(select round(cast(map_id as int)/10000,0)-2 as 'map_id', user_id
from fairy_town_server.server_map_open
where round(cast(map_id as int)/10000,0)=12
and day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by round(cast(map_id as int)/10000,0), user_id)
union all
(select round(cast(map_id as int)/10000,0) as 'map_id', user_id
from fairy_town_server.server_physical_consume
where round(cast(map_id as int)/10000,0)=5
and day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by round(cast(map_id as int)/10000,0), user_id
having sum(consume_count)>4000)
)b
)t1 left join
(
select round(cast(map_id as int)/10000,0) as 'map_id', 
user_id, count(1) as times
from fairy_town_server.server_map_enter
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by round(cast(map_id as int)/10000,0), user_id
)t2 on t1.map_id=t2.map_id and t1.user_id=t2.user_id
left join
(
(select 1 as 'map_id', user_id, 1 as 'role_level'
from fairy_town_server.server_map_open
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by user_id
)union all
(select round(cast(map_id as int)/10000,0) as 'map_id', 
user_id, min(role_level) as role_level
from fairy_town_server.server_map_open
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by round(cast(map_id as int)/10000,0), user_id
)
)t3 on t1.map_id=t3.map_id and t1.user_id=t3.user_id
right join
(
select user_id
from fairy_town.order_pay 
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by user_id
)t4 on t1.user_id=t4.user_id
)l6
group by map_id
)list6 on list1.map_id=list6.map_id
order by list1.map_id