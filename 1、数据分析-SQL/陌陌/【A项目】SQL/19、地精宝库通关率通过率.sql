-- 整体用户

select 副本ID,进入关卡人数,
人均进入关卡次数,
通关率 as '通关率%', 
round(下一关进入人数/进入关卡人数*100,2) as '通过率%'
from 
(select 副本ID,
进入关卡人数,
round(人均进入关卡次数,2) as 人均进入关卡次数,
lead(进入关卡人数,1,0)over(order by 副本ID asc) as '下一关进入人数',
通关率
from 
(select a.dungeon_id as '副本ID',
count(distinct a.role_id) as '进入关卡人数',
avg(nums) '人均进入关卡次数',
count(distinct b.role_id) as '通关人数',
round(count(distinct b.role_id)/count(distinct a.role_id)*100,2) as '通关率'
from
(select dungeon_id,role_id,count(1) as nums
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and game_type=7

and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
group by 1,2) a 
left join 
(select dungeon_id,role_id
from myth_server.server_dungeon_end
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and game_type=7

and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
and battle_result=1
group by 1,2) b 
on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id
group by 1
order by 1) a 
) t 