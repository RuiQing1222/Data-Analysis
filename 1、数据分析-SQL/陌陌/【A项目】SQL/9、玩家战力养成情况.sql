select  
round(avg(case when row_num<=0.25*cnt                      then battle_points else null end ),0) as `角色平均战力1%~25%`,
round(avg(case when row_num<=0.50*cnt and row_num>0.25*cnt then battle_points else null end ),0) as `角色平均战力25%~50%`,
round(avg(case when row_num<=0.75*cnt and row_num>0.50*cnt then battle_points else null end ),0) as `角色平均战力50%~75%`,
round(avg(case when row_num<=cnt      and row_num>0.75*cnt then battle_points else null end ),0) as `角色平均战力75%~100%`
from
(select role_id,battle_points,
  row_number() over(order by battle_points asc) as row_num,
  count(*) over() as cnt
from 
(select role_id,max(battle_points) as battle_points from 
(
select role_id,battle_points
from myth_server.server_login_snapshot
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
union all 
select role_id,battle_points
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
union all 
select role_id,battle_points
from myth_server.server_dungeon_end
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
union all 
select role_id,battle_points
from myth_server.server_world_boss
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
union all 
select role_id,battle_points
from myth_server.server_arena
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
) a   
group by 1) a 
group by 1,2) a 