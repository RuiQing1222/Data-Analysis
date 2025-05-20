玩法系统数据分析  

玩法——7->地精宝库

整体-- 人数维度进入关卡人数、通关率、中途退出率，D1次数维度数据
select b.role_id,dungeon_id,scene_id,start_time,game_type,battle_result,battle_time,auto_battle,bottle_num,done_dt
from

-- 活跃维度
(select role_id
from myth.client_online 
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1
)as a

left join
-- 关卡参与情况
(select dungeon_id,scene_id,role_id,start_time,game_type,battle_result,battle_time,auto_battle,bottle_num,done_dt
from
(select a.dungeon_id,a.scene_id,a.role_id,a.start_time,a.game_type,battle_result,battle_time,auto_battle,bottle_num,done_dt
from 
(select dungeon_id,scene_id,role_id,start_time,to_date(cast(date_time as timestamp)) as done_dt,game_type -- start_time也可用统计参与次数
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 7 -- 7->地精宝库
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5,6
) as a
left join     
(select dungeon_id,scene_id,role_id,start_time,battle_result,
        case when battle_time/60000 is null then '无日志'
             when battle_time/60000 > 3  then '1超时'
             when battle_time/60000 > 2 and battle_time/60000 <= 3  then '2困难'
             when battle_time/60000 > 1 and battle_time/60000 <= 2  then '3较难'
             when battle_time/60000 > 0 and battle_time/60000 <= 1  then '4一般'
             else '无日志'
        end as battle_time,auto_battle,game_type,bottle_num --药瓶使用数
from myth_server.server_dungeon_end
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 7 -- 7->地精宝库
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5,6,7,8,9
) b 
on a.dungeon_id=b.dungeon_id and a.scene_id = b.scene_id and a.role_id=b.role_id and a.start_time=b.start_time and a.game_type = b.game_type 
order by a.role_id,a.start_time asc 
) as e  
group by 1,2,3,4,5,6,7,8,9,10
) as b 
on a.role_id = b.role_id
group by 1,2,3,4,5,6,7,8,9,10




整体 --人数维度 流失人数、流失率
流失：活跃当天最高关卡，次日未登录
select b.role_id,最高关卡,是否流失
from

-- 活跃维度
(select role_id,to_date(cast(date_time as timestamp)) as online_dt
from myth.client_online 
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2
)as a

left join
(select a.role_id,done_dt,最高关卡,
        case when b.role_id is null then '流失' 
             else '留存'
             end as '是否流失'
from
(select role_id,to_date(cast(date_time as timestamp)) as done_dt,max(dungeon_id) as '最高关卡'
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 7 -- 7->地精宝库 
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2
) as a
left join
(select role_id,to_date(cast(date_time as timestamp)) as login_dt
from myth.server_role_login
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2
) as b 
on a.role_id = b.role_id
where datediff(login_dt,done_dt) = 1
group by 1,2,3,4
) as b
on a.role_id = b.role_id
group by 1,2,3



复玩率
整体、付费 -- 复玩率
select dungeon_id,count(distinct role_id) as '进入总人数',count(distinct case when 进入次数 > 1 then role_id else null) as '复玩人数'
from

(select dungeon_id,role_id,count(distinct start_time) as '进入次数'
from
(select dungeon_id,role_id,start_time -- start_time也可用统计参与次数
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 7 -- 7->地精宝库
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3
union all
select dungeon_id,role_id,log_time as start_time -- log_time也可用统计参与次数
from myth_server.server_dungeon_blitz
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 7 -- 7->地精宝库
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3
) as a
) as b
group by 1
order by 1




扫荡数据 7->地精宝库 整体
扫荡单独算
select b.role_id as role_id,date_time,dungeon_id
from

-- 活跃维度
(select role_id,to_date(cast(date_time as timestamp)) as online_dt
from myth.client_online 
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2
)as a

left join --地精宝库扫荡
(select role_id,dungeon_id,date_time,to_date(cast(date_time as timestamp)) as enter_dt
from myth_server.server_dungeon_blitz
where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id=1000  --Android
and game_type = 7 -- 7地精宝库扫荡
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4
) as b
on a.role_id = b.role_id
group by 1,2,3
