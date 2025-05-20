select case list1.map_id
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
when 3001 then '飞鱼镇地图'
when 3101 then '万圣节地图'
when 3201 then '圣诞节地图'
Else '暂不开启'
End as '地图名称',
resource_id as '采矿任务ID',
case resource_id
when 0 then '采矿总任务'
when 8 then  '蘑菇任务'
when 10 then '煤矿任务'
when 11 then '铁矿任务'
when 12 then '石英任务'
when 13 then '魔晶任务'
when 14 then '汲水任务'
when 17 then '蜂巢任务'
end as '任务类型',
reward_id as '获得奖励ID',
完成地图用户数,
完成采矿任务用户数,
round(完成采矿任务用户数/完成地图用户数*100,2) as '采矿任务完成率(%)'
from
(select  map_id,
count(distinct role_id) as '完成地图用户数'
from 
(
(select round(cast(map_id as int)/10000,0)-2 as map_id,
role_id,role_level
from fairy_town_server.server_map_open
where round(cast(map_id as int)/10000,0) in (6,12,18)
and day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
)union all
(
select round(cast(map_id as int)/10000,0)-1 as map_id, 
role_id,role_level
from fairy_town_server.server_map_open
where round(cast(map_id as int)/10000,0) in (3,4,7,8,9,10,13,14,15,16,19)
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
)  union all
(
select 3001 as map_id,role_id,role_level
from fairy_town_server.server_task_completed
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and task_id='3001471'
)  union all
(
select 3101 as map_id,role_id,role_level
from fairy_town_server.server_task_completed
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and task_id='3101571'
)  

) b
group by 1
)list1  
left join 
(SELECT round(cast(map_id as int)/10000,0)  as map_id
 ,resource_id,reward_id,count(distinct user_id) as '完成采矿任务用户数'
FROM fairy_town_server.server_map_resource_mission_complete
where day_time between ${beginDate} and ${endDate}
and server_id in (${serverIds})
group by 1,2,3 ) list2
on list1.map_id=list2.map_id