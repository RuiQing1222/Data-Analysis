--------------------------------------------------------------------------------------------------------------------------------------------------------------------
宝石矿坑
玩法——14->宝石矿坑

整体-- 人数维度进入关卡人数、通关率、中途退出率，D1次数维度数据
select birth_dt,b.role_id,dungeon_id,scene_id,start_time,game_type,battle_result,auto_battle,bottle_num,datediff(done_dt,birth_dt)+1 as '天数'
from

(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
group by 1,2
)as a


left join
-- 关卡参与情况
(select dungeon_id,scene_id,role_id,start_time,game_type,battle_result,auto_battle,bottle_num,done_dt
from
(select a.dungeon_id,a.scene_id,a.role_id,a.start_time,a.game_type,battle_result,auto_battle,bottle_num,done_dt
from 
(select dungeon_id,scene_id,role_id,start_time,to_date(cast(date_time as timestamp)) as done_dt,game_type -- start_time也可用统计参与次数
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 14 -- 14->宝石矿坑
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5,6
) as a
left join     
(select dungeon_id,scene_id,role_id,start_time,battle_result,auto_battle,game_type,bottle_num --药瓶使用数
from myth_server.server_dungeon_end
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 14 -- 14->宝石矿坑
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5,6,7,8
) b 
on a.dungeon_id=b.dungeon_id and a.scene_id = b.scene_id and a.role_id=b.role_id and a.start_time=b.start_time and a.game_type = b.game_type 
order by a.role_id,a.start_time asc 
) as e  
group by 1,2,3,4,5,6,7,8,9
) as b 
on a.role_id = b.role_id
where datediff(b.done_dt,a.birth_dt) <= 6
group by 1,2,3,4,5,6,7,8,9,10



整体 -- 复玩率
select birth_dt,datediff(done_dt,birth_dt)+1 as '天数',count(distinct b.role_id) as '进入总人数',count(distinct case when 进入次数 > 1 then b.role_id else null) as '复玩人数'
from

(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
group by 1,2
)as a

left join
(select dungeon_id,scene_id,role_id,to_date(cast(date_time as timestamp)) as done_dt,count(distinct start_time) as '进入次数' -- start_time也可用统计参与次数
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 14 -- 14->宝石矿坑
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4
) as b
on a.role_id = b.role_id
where datediff(b.done_dt,a.birth_dt) <= 6
group by 1,2








挖矿数据
select birth_dt,b.role_id as role_id,mine_id,consume_currency_id,datediff(enter_dt,birth_dt)+1 as '天数'
       count(log_time) as '次数',sum(consume_currency_num) as '消耗数量'
from

(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
group by 1,2
)as a

left join 
(select role_id,to_date(cast(date_time as timestamp)) as enter_dt,log_time,mine_id,consume_currency_id,consume_currency_num
from myth_server.server_gem_mine_start
where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5,6
) b
on a.role_id = b.role_id
where datediff(b.done_dt,a.birth_dt) <= 6
group by 1,2,3,4,5
