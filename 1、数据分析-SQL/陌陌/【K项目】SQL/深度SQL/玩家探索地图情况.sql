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
开启地图账户数,
完成地图账户数,
round(完成地图账户数/开启地图账户数*100,2) as '地图完成率%',
完成地图账户平均进入地图次数, 
完成地图账户平均开启地图等级,
平均完成等级,
完成地图账户平均消耗体力数,
`账户平均完成地图时长(分钟)`,
`每次地图进离平均时长(分钟)`
from
(select map_id,开启地图账户数 
from 
(
(select 1 as map_id, count(distinct role_id) as '开启地图账户数'
   from fairy_town_server.server_map_open
   where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
   and map_id='20001'
group by 1
)union all
(select round(cast(map_id as int)/10000,0) as map_id, count(distinct role_id) as '开启地图账户数'
from fairy_town_server.server_map_open
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by 1
)
) a 
)list1 left join 
(select  map_id,
count(distinct role_id) as '完成地图账户数',
round(avg(role_level),2) as '平均完成等级'
from 
(
(select round(cast(map_id as int)/10000,0)-2 as map_id,
role_id,role_level
from fairy_town_server.server_map_open
where round(cast(map_id as int)/10000,0) in (3,6,12,18)
and day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
)union all
(
select round(cast(map_id as int)/10000,0)-1 as map_id, 
role_id,role_level
from fairy_town_server.server_map_open
where round(cast(map_id as int)/10000,0) in (3,4,7,8,9,10,13,14,15,16,19,20)
and day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
)union all
(
select 11 as map_id,role_id,role_level
from fairy_town_server.server_building_get
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and building_id='2011039'  
)union all
(
select 5 as map_id,role_id,role_level
from fairy_town_server.server_building_get
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and building_id='2005013'
)  
) b
group by 1
)list2 on list1.map_id=list2.map_id 
left join
(
select map_id, round(sum(consume_count)/count(distinct role_id),2) as '完成地图账户平均消耗体力数'
from
(
select t1.map_id, t1.role_id, consume_count
from
(
(select round(cast(map_id as int)/10000,0)-2 as map_id, role_id
from fairy_town_server.server_map_open
where round(cast(map_id as int)/10000,0) in (3,6,12,18)
and day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by round(cast(map_id as int)/10000,0), role_id
)union all
(
select round(cast(map_id as int)/10000,0)-1 as map_id, role_id
from fairy_town_server.server_map_open
where round(cast(map_id as int)/10000,0) not in (3,4,7,8,9,10,13,14,15,16,19,20)
and day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by round(cast(map_id as int)/10000,0), role_id
)union all
(select round(cast(map_id as int)/10000,0)-2 as map_id, role_id
from fairy_town_server.server_map_open
where round(cast(map_id as int)/10000,0)=12
and day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by round(cast(map_id as int)/10000,0), role_id)
union all
(select map_id,m.role_id
from 
(
select round(cast(map_id as int)/10000,0) as map_id, role_id
from fairy_town_server.server_physical_consume
where round(cast(map_id as int)/10000,0)=5
and day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by round(cast(map_id as int)/10000,0), role_id) m
join 
(select role_id
from fairy_town_server.server_building_get
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and building_id='2005013'
group by 1) n
on m.role_id=n.role_id
)
)t1 left join
(
select round(cast(map_id as int)/10000,0) as map_id, role_id, sum(consume_count) as 'consume_count'
from fairy_town_server.server_physical_consume
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by round(cast(map_id as int)/10000,0), role_id
)t2 on t1.map_id=t2.map_id and t1.role_id=t2.role_id
)l3
group by 1
)list3 on list1.map_id=list3.map_id 
left join
(
select map_id, 
round(sum(`账户完成地图时长(分钟)`)/count(distinct role_id),2) as `账户平均完成地图时长(分钟)`
from
(
select map_id, role_id, 
round(avg(地图完成时间-地图开启时间)/60000,2) as `账户完成地图时长(分钟)`
from 
(select t1.map_id,t1.role_id,地图开启时间,地图完成时间
from 
(select round(cast(map_id as int)/10000,0) as map_id, 
role_id, min(log_time) as '地图开启时间'
from fairy_town_server.server_map_open
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by round(cast(map_id as int)/10000,0), role_id
)t1 left join
(
(select round(cast(map_id as int)/10000,0)-2 as map_id, 
role_id, min(log_time) as '地图完成时间'
from fairy_town_server.server_map_open
where round(cast(map_id as int)/10000,0) in (3,6,12,18)
and day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by round(cast(map_id as int)/10000,0), role_id
)union all
(
select round(cast(map_id as int)/10000,0)-1 as map_id, 
role_id, min(log_time) as '地图完成时间'
from fairy_town_server.server_map_open
where round(cast(map_id as int)/10000,0) in (3,4,7,8,9,10,13,14,15,16,19,20)
and day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by round(cast(map_id as int)/10000,0), role_id
)union all
(select round(cast(map_id as int)/10000,0)-2 as map_id, 
role_id, min(log_time) as '地图完成时间'
from fairy_town_server.server_map_open
where round(cast(map_id as int)/10000,0)=12
and day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by round(cast(map_id as int)/10000,0), role_id)
union all
(select map_id,m.role_id,地图完成时间
from 
(select role_id
from fairy_town_server.server_building_get
where   day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and building_id='2005013'
group by 1
) m
join 
(select 5 as map_id, 
role_id, max(log_time) as '地图完成时间'
from fairy_town_server.server_physical_consume
where round(cast(map_id as int)/10000,0)=5
and day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by round(cast(map_id as int)/10000,0), role_id
) n 
on m.role_id=n.role_id
)
)t2 on t1.map_id=t2.map_id and t1.role_id=t2.role_id
) l4
group by 1,2) t
group by 1
)list4 on list1.map_id=list4.map_id 
left join
(
select round(cast(map_id as int)/10000,0)-2 as map_id, 
round(avg(ms)/60000,2) as '每次地图进离平均时长(分钟)'
from 
(
select sme.map_id, sme.role_id, sme.log_time, (sml.log_time - sme.log_time) as 'ms'
from fairy_town_server.server_map_enter sme
left join fairy_town_server.server_map_leave sml
on sme.map_id = sml.map_id and sme.role_id = sml.role_id
where sml.role_id is not null
and sme.day_time  between ${beginDate} and ${endDate} and sme.server_id in (${serverIds})
and sml.day_time  between ${beginDate} and ${endDate} and sml.server_id in (${serverIds})
having (sml.log_time - sme.log_time)>0
) t
group by 1
)list5 on list1.map_id=list5.map_id 
left join
(
select map_id,
round(sum(times)/count(distinct role_id),2) as '完成地图账户平均进入地图次数',
round(avg(role_level),2) as '完成地图账户平均开启地图等级'
from(
select t1.map_id, t1.role_id, times, role_level
from
(
(select round(cast(map_id as int)/10000,0)-2 as map_id, role_id
from fairy_town_server.server_map_open
where round(cast(map_id as int)/10000,0) in (3,6,12,18)
and day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by round(cast(map_id as int)/10000,0), role_id
)union all
(
select round(cast(map_id as int)/10000,0)-1 as map_id, role_id
from fairy_town_server.server_map_open
where round(cast(map_id as int)/10000,0) in (3,4,7,8,9,10,13,14,15,16,19,20)
and day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by round(cast(map_id as int)/10000,0), role_id
)union all
(select round(cast(map_id as int)/10000,0)-2 as map_id, role_id
from fairy_town_server.server_map_open
where round(cast(map_id as int)/10000,0)=12
and day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by round(cast(map_id as int)/10000,0), role_id)
union all
(select map_id,m.role_id
from 
(select role_id
from fairy_town_server.server_building_get
where   day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and building_id='2005013'
group by 1
) m
join 
(select 5 as map_id,role_id
from fairy_town_server.server_physical_consume
where round(cast(map_id as int)/10000,0)=5
and day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by round(cast(map_id as int)/10000,0), role_id
) n 
on m.role_id=n.role_id
)
)t1 
left join
(
select round(cast(map_id as int)/10000,0) as map_id, 
role_id, count(1) as times
from fairy_town_server.server_map_enter
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by round(cast(map_id as int)/10000,0), role_id
)t2 on t1.map_id=t2.map_id and t1.role_id=t2.role_id
left join
(
(select 1 as map_id, role_id, 1 as role_level
from fairy_town_server.server_map_open
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by 1,2
)union all
(select round(cast(map_id as int)/10000,0) as map_id, 
role_id, min(role_level) as role_level
from fairy_town_server.server_map_open
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by round(cast(map_id as int)/10000,0), role_id
)
)t3 on t1.map_id=t3.map_id and t1.role_id=t3.role_id
)l6
group by 1
)list6 on list1.map_id=list6.map_id  
order by list1.map_id 