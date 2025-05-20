select day_time,a.role_id,职业,天赋方案,副本ID,战斗结果
from
(
select day_time,role_id
from
(select day_time, device_id 
from myth.device_activate where day_time between ${beginDate} and ${endDate}
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
group by 1,2
) as a
left join
(select device_id,role_id
from myth.server_role_create
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
group by 1,2) as b
on a.device_id = b.device_id
group by 1,2
) as a

left join 

(
select role_id,role_type as '职业',fate_plan as '天赋方案',dungeon_id as '副本ID',battle_result as '战斗结果'
from myth_server.server_dungeon_end
where day_time between ${beginDate} and ${endDate}
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
-- and game_type = ${game_types}
) as b

on a.role_id = b.role_id