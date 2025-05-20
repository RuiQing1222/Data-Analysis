select 秘境层数,进入秘境人数,
通关率 as '通关率%', 
round(下一关进入人数/进入秘境人数*100,2) as '通过率%'
from 
(select 秘境层数,
进入秘境人数,
lead(进入秘境人数,1,0)over(order by 秘境层数 asc) as '下一关进入人数',
通关率
from 
(select a.dungeon_id as '秘境层数',
count(distinct a.role_id) as '进入秘境人数',
count(distinct b.role_id) as '通关人数',
round(count(distinct b.role_id)/count(distinct a.role_id)*100,2) as '通关率'
from
(select country,dungeon_id,role_id
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and game_type=2

and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')

group by 1,2,3) a 
left join 
(select dungeon_id,role_id
from myth_server.server_dungeon_end
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and game_type=2
and battle_result=1

and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')

group by 1,2) b 
on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id
group by 1
order by 1) a 
) t 
