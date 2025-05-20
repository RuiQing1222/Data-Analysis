select dungeon_id as '战役关卡ID',count(distinct role_id) as '挑战玩家数',count(1) as '挑战次数',
round(avg(duration)/60000,2) as '关卡时长平均值(分)',
round(appx_median(duration)/60000,2) as '关卡时长中位数(分)'
from 
(select role_id,battle_result,dungeon_id,(log_time -start_time) as duration
from myth_server.server_dungeon_end
where day_time>=20220118 and day_time<=20220124 
and channel_id=1000
and server_id in (20001,20002,20003)
and game_type=3  ) a 
group by 1 
order by 1 asc 