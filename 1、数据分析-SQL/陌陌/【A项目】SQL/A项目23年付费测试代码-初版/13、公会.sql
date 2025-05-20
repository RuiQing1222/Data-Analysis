公会远征 - 普通
关卡ID	格子类型	参与人数	参与比例 人均参与次数	人均时长	通关率 无日志率	自动次数	手动次数
select cycle_id,dungeon_id,blank_type,
       count(distinct b.role_id) as '参与人数',
       round(count(distinct b.role_id) / count(distinct a.role_id),2) as '参与比例',
       round(count(b.start_time) / count(distinct b.role_id),2) as '人均参与次数',
       round(sum(battle_time) / count(distinct b.role_id),2) as '人均时长',
       round(count(distinct case when battle_result = 1 then b.role_id else null end) / count(distinct b.role_id),2) as '通关率',
       round(count(case when battle_result is null then b.start_time else null end) / count(b.start_time),2) as '无日志率',
       count(case when auto_battle = 1 then 1 else 0 end) as '自动次数',
       count(case when auto_battle = 0 then 1 else 0 end) as '手动次数'
from
(select role_id -- 拥有公会的玩家
from myth_server.server_login_snapshot
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
and guild_id <> 0 -- 表示有公会ID的玩家
) as a 

left join
-- 关卡参与情况
(select cycle_id,dungeon_id,role_id,start_time,battle_result,battle_time,auto_battle,blank_type
from
(select a.cycle_id,a.dungeon_id,a.role_id,a.start_time,battle_result,battle_time,auto_battle,blank_type
from 
(select cycle_id,dungeon_id,role_id,start_time -- start_time也可用统计参与次数
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and game_type = 18 -- 18->公会远征
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4
) as a
left join     
(select cycle_id,dungeon_id,role_id,start_time,battle_result,battle_time,auto_battle,blank_type
from myth_server.server_guild_challenge --普通结算
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5,6,7,8
) b 
on a.cycle_id = b.cycle_id and a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time=b.start_time
order by a.role_id,a.start_time asc 
) as e  
group by 1,2,3,4,5,6,7,8
) as b 
on a.role_id = b.role_id
group by 1,2,3
order by 1,2,3


天复玩率
select a.cycle_id,dungeon_id,blank_type,
       round(count(distinct b.role_id) / count(distinct a.role_id),2) as '天复玩率'
from
(select cycle_id,dungeon_id,blank_type,role_id,done_dt
from
(select cycle_id,dungeon_id,role_id,blank_type,done_dt,row_number() over(paitition by cycle_id,role_id order by log_time desc) as num
from
(select cycle_id,dungeon_id,role_id,log_time,blank_type,to_date(cast(date_time as timestamp)) as done_dt
from myth_server.server_guild_challenge --普通结算
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5,6
) a1 
) a2
where num = 1
group by 1,2,3,4,5
) as a 

left join
(select cycle_id,role_id,to_date(cast(date_time as timestamp)) as done_dt
from myth_server.server_guild_challenge --普通结算
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3
) b 
on a.cycle_id = b.cycle_id and a.role_id=b.role_id and datediff(b.done_dt,a.done_dt) = 1
group by 1,2,3
order by 1,2,3






公会远征 - 无尽
日期	参与人数	参与比例 人均参与次数	人均时长	人均伤害值 无日志率	自动次数	手动次数
select cycle_id,day_time,
       count(distinct b.role_id) as '参与人数',
       round(count(distinct b.role_id) / count(distinct a.role_id),2) as '参与比例',
       round(count(b.start_time) / count(distinct b.role_id),2) as '人均参与次数',
       round(sum(battle_time) / count(distinct b.role_id),2) as '人均时长',
       round(sum(damage_value) / count(distinct b.role_id),2) as '人均伤害值',
       round(count(case when battle_result is null then b.start_time else null end) / count(b.start_time),2) as '无日志率',
       count(case when auto_battle = 1 then 1 else 0 end) as '自动次数',
       count(case when auto_battle = 0 then 1 else 0 end) as '手动次数'
from
(select role_id -- 拥有公会的玩家
from myth_server.server_login_snapshot
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
and guild_id <> 0 -- 表示有公会ID的玩家
) as a 

left join
-- 关卡参与情况
(select cycle_id,day_time,role_id,start_time,battle_time,auto_battle,damage_value
from
(select a.cycle_id,day_time,a.role_id,a.start_time,(end_time-a.start_time)/60000 as battle_time,auto_battle,damage_value
from 
(select cycle_id,dungeon_id,role_id,day_time,start_time -- start_time也可用统计参与次数
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and game_type = 18 -- 18->公会远征
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5
) as a
left join     
(select cycle_id,role_id,start_time,auto_battle,damage_value,log_time as end_time
from myth_server.server_guild_endless --无尽结算
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5,6
) b 
on a.cycle_id = b.cycle_id and a.role_id=b.role_id and a.start_time=b.start_time
order by a.role_id,a.start_time asc 
) as e  
group by 1,2,3,4,5,6,7
) as b 
on a.role_id = b.role_id
group by 1,2
order by 1,2



天复玩率
select a.cycle_id,a.done_dt,
       round(count(distinct b.role_id) / count(distinct a.role_id),2) as '天复玩率'
from

(select cycle_id,role_id,to_date(cast(date_time as timestamp)) as done_dt
from myth_server.server_guild_endless --无尽结算
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3
) as a 

left join
(select cycle_id,role_id,to_date(cast(date_time as timestamp)) as done_dt
from myth_server.server_guild_endless --无尽结算
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3
) b 
on a.cycle_id = b.cycle_id and a.role_id=b.role_id and datediff(b.done_dt,a.done_dt) = 1
group by 1,2
order by 1,2






公会领主
BOSS	参与人数	参与比例 人均参与次数	人均时长	人均伤害值	无日志率	自动次数	手动次数
select cycle_id,boss_id,
       count(distinct b.role_id) as '参与人数',
       round(count(distinct b.role_id) / count(distinct a.role_id),2) as '参与比例',
       round(count(b.start_time) / count(distinct b.role_id),2) as '人均参与次数',
       round(sum(battle_time) / count(distinct b.role_id),2) as '人均时长',
       round(sum(damage_value) / count(distinct b.role_id),2) as '人均伤害值',
       round(count(case when battle_result is null then b.start_time else null end) / count(b.start_time),2) as '无日志率',
       count(case when auto_battle = 1 then 1 else 0 end) as '自动次数',
       count(case when auto_battle = 0 then 1 else 0 end) as '手动次数'
from
(select role_id -- 拥有公会的玩家
from myth_server.server_login_snapshot
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
and guild_id <> 0 -- 表示有公会ID的玩家
) as a 

left join
-- 关卡参与情况
(select cycle_id,boss_id,role_id,start_time,battle_time,auto_battle,damage_value
from
(select a.cycle_id,a.boss_id,a.role_id,a.start_time,(end_time-a.start_time)/60000 as battle_time,auto_battle,damage_value
from 
(select cycle_id, dungeon_id as boss_id,role_id,start_time -- start_time也可用统计参与次数
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and game_type = 16 -- 16->公会领主
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4
) as a
left join     
(select cycle_id,boss_id,role_id,start_time,auto_battle,damage_value
from myth_server.server_guild_endless --无尽结算
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5,6
) b 
on a.cycle_id = b.cycle_id and a.boss_id = b.boss_id and a.role_id=b.role_id and a.start_time=b.start_time
order by a.role_id,a.start_time asc 
) as e  
group by 1,2,3,4,5,6,7
) as b 
on a.role_id = b.role_id
group by 1,2
order by 1,2


天复玩率
select a.cycle_id,a.dungeon_id,
       round(count(distinct b.role_id) / count(distinct a.role_id),2) as '天复玩率'
from

(select cycle_id,dungeon_id,role_id,to_date(cast(date_time as timestamp)) as done_dt
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and game_type = 16 -- 16->公会领主
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4
) as a

left join
(select cycle_id,role_id,to_date(cast(date_time as timestamp)) as done_dt
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and game_type = 16 -- 16->公会领主
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2
) as b
on a.cycle_id = b.cycle_id and a.role_id=b.role_id and datediff(b.done_dt,a.done_dt) = 1
group by 1,2
order by 1,2