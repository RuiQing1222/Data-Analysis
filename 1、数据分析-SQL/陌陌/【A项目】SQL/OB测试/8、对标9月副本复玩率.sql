生命周期  玩法留存

秘境、地精宝库

select a.role_id,birth_dt,生命周期,datediff(done_date,done_dt)+1 as '留存天数'
from
(
select c.role_id as role_id,birth_dt,done_dt, datediff(done_dt,birth_dt)+1 as '生命周期'
from

(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
)as a

left join --达到可参与的条件
(select role_id,to_date(cast(date_time as timestamp)) as done_dt
     from myth_server.server_dungeon_end
     where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
     and game_type =3 
     and battle_result = 1
     and dungeon_id = 27 --27 3-8开启秘境 10 2-3开启地精  digistore24
     and version_name in ('1.5.1','1.5.2')
     and channel_id in (1000,2000)
     and country not in ('CN','HK')
) b
on a.role_id = b.role_id

left join --参与玩法，与达到条件时间一致，生命周期新增口径
(select role_id,to_date(cast(date_time as timestamp)) as enter_dt
     from myth_server.server_enter_dungeon
     where  day_time between ${beginDate} and ${endDate} 
     and server_id in (${serverIds})
     and game_type = 2 -- 2秘境  7地精宝库
     and version_name in ('1.5.1','1.5.2')
     and channel_id in (1000,2000)
     and country not in ('CN','HK')
) c

on b.role_id = c.role_id and b.done_dt = c.enter_dt
where datediff(done_dt,birth_dt) <= 6
group by 1,2,3
) as a


left join   -- 留存玩法进入
-- 秘境、地精宝库要合并 正常进入关卡的  和 直接扫荡的玩家
-- (select role_id,done_date
-- from
-- (select role_id,to_date(cast(date_time as timestamp)) as done_date
--      from myth_server.server_enter_dungeon
--      where day_time between ${beginDate} and ${endDate}
--      and server_id in (${serverIds})
--      and game_type = 2
--      and version_name in ('1.5.1','1.5.2')
--      and channel_id in (1000,2000)
--      and country not in ('CN','HK')
-- group by 1,2
-- union all
-- select role_id,to_date(cast(date_time as timestamp)) as done_date
--      from myth_server.server_dungeon_blitz
--      where day_time between ${beginDate} and ${endDate}
--      and server_id in (${serverIds})
--      and game_type = 2 
--      and version_name in ('1.5.1','1.5.2')
--      and channel_id in (1000,2000)
--      and country not in ('CN','HK')
-- group by 1,2
-- ) as b1
-- group by 1,2
-- ) as b

--  留存登录
(select role_id,to_date(cast(date_time as timestamp)) as done_date
from myth.server_role_login
where day_time between ${beginDate} and ${endDate}   
and server_id in (${serverIds})
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) as b

on a.role_id = b.role_id
where datediff(done_date,done_dt) in (0,1,2,3,4,5,6)
group by 1,2,3,4





诸神试炼
生命周期  玩法留存
select a.role_id,birth_dt,生命周期,datediff(done_date,done_dt)+1 as '留存天数'
from
(
select c.role_id as role_id,birth_dt,done_dt, datediff(done_dt,birth_dt)+1 as '生命周期'
from

(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
)as a

left join --达到可参与的条件
(select role_id,to_date(cast(date_time as timestamp)) as done_dt
     from myth_server.server_dungeon_end
     where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
     and game_type =3 
     and battle_result = 1
     and dungeon_id = 104  -- 诸神试炼可参与的条件 通关6-25
     and version_name in ('1.5.1','1.5.2')
     and country not in ('CN','HK')
) b
on a.role_id = b.role_id

left join --参与玩法，与达到条件时间一致，生命周期新增口径
(select role_id,to_date(cast(date_time as timestamp)) as enter_dt
     from myth_server.server_enter_dungeon
     where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
     and game_type in (8,9,10,11,12,13) -- 8-13诸神试炼 
     and version_name in ('1.5.1','1.5.2')
     and country not in ('CN','HK')
) c

on b.role_id = c.role_id and b.done_dt = c.enter_dt
where datediff(done_dt,birth_dt) <= 6
group by 1,2,3
) as a


left join   -- 留存玩法进入
(select role_id,to_date(cast(date_time as timestamp)) as done_date
     from myth_server.server_enter_dungeon
     where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
     and game_type in (8,9,10,11,12,13) -- 8-13诸神试炼
     and version_name in ('1.5.1','1.5.2')
     and channel_id in (1000,2000)
     and country not in ('CN','HK')
group by 1,2
) as b


--  留存登录
-- (select role_id,to_date(cast(date_time as timestamp)) as done_date
-- from myth.server_role_login
-- where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
-- and version_name in ('1.5.1','1.5.2')
-- and channel_id in (1000,2000)
-- and country not in ('CN','HK')
-- ) as b

on a.role_id = b.role_id
where datediff(done_date,done_dt) in (0,1,2,3,4,5,6)
group by 1,2,3,4









竞技场
生命周期  玩法留存
select a.role_id,birth_dt,生命周期,datediff(done_date,done_dt)+1 as '留存天数'
from
(
select c.role_id as role_id,birth_dt,done_dt, datediff(done_dt,birth_dt)+1 as '生命周期'
from

(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
) as a

left join 
(select role_id,to_date(cast(date_time as timestamp)) as done_dt
     from myth_server.server_dungeon_end
     where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
     and game_type =3 
     and battle_result = 1
     and dungeon_id = 15 -- 通关2-8可参与
     and version_name in ('1.5.1','1.5.2')
     and channel_id in (1000,2000)
     and country not in ('CN','HK')
) b
on a.role_id = b.role_id

left join
(select role_id,to_date(cast(date_time as timestamp)) as enter_dt
     from myth_server.server_enter_dungeon
     where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
     and game_type = 4
     and version_name in ('1.5.1','1.5.2')
     and channel_id in (1000,2000)
     and country not in ('CN','HK')
) c
on b.role_id = c.role_id and b.done_dt = c.enter_dt
where datediff(done_dt,birth_dt) <= 6
group by 1,2,3
) as a

left join   -- 留存玩法进入
(select role_id,to_date(cast(date_time as timestamp)) as done_date
     from myth_server.server_enter_dungeon
     where  day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
     and game_type = 4
     and version_name in ('1.5.1','1.5.2')
     and channel_id in (1000,2000)
     and country not in ('CN','HK')
group by 1,2
) as b


--  留存登录
-- (select role_id,to_date(cast(date_time as timestamp)) as done_date
-- from myth.server_role_login
-- where day_time between ${beginDate} and ${endDate}   
-- and server_id in (${serverIds})
-- and version_name in ('1.5.1','1.5.2')
-- and channel_id in (1000,2000)
-- and country not in ('CN','HK')
-- ) as b

on a.role_id = b.role_id
where datediff(done_date,done_dt) in (0,1,2,3,4,5,6)
group by 1,2,3,4







远古战场
生命周期  玩法留存
select a.role_id,birth_dt,生命周期,datediff(done_date,done_dt)+1 as '留存天数'
from
(
select c.role_id as role_id,birth_dt,done_dt, datediff(done_dt,birth_dt)+1 as '生命周期'
from

(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
) as a

left join 
(select role_id,to_date(cast(date_time as timestamp)) as done_dt
from myth_server.server_dungeon_end
where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type =3 
and battle_result = 1
and dungeon_id = 23  -- 通关3-4可参与
and version_name in ('1.5.1','1.5.2')
and channel_id in (1000,2000)
and country not in ('CN','HK')
) b
on a.role_id = b.role_id

left join
(select role_id,to_date(cast(date_time as timestamp)) as enter_dt
from myth_server.server_enter_dungeon
where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 6
and version_name in ('1.5.1','1.5.2')
and channel_id in (1000,2000)
and country not in ('CN','HK')
) c
on b.role_id = c.role_id and b.done_dt = c.enter_dt
where datediff(done_dt,birth_dt) <= 6
group by 1,2,3
) as a

left join   -- 留存玩法进入
(select role_id,to_date(cast(date_time as timestamp)) as done_date
from myth_server.server_enter_dungeon
where  day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and game_type = 6
and version_name in ('1.5.1','1.5.2')
and channel_id in (1000,2000)
and country not in ('CN','HK')
group by 1,2
) as b


--  留存登录
-- (select role_id,to_date(cast(date_time as timestamp)) as done_date
-- from myth.server_role_login
-- where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
-- and version_name in ('1.5.1','1.5.2')
-- and channel_id in (1000,2000)
-- and country not in ('CN','HK')
-- ) as b

on a.role_id = b.role_id
where datediff(done_date,done_dt) in (0,1,2,3,4,5,6)
group by 1,2,3,4




信徒心愿
生命周期  玩法留存
select a.role_id,birth_dt,生命周期,datediff(done_date,done_dt)+1 as '留存天数'
from
(
select c.role_id as role_id,birth_dt,done_dt, datediff(done_dt,birth_dt)+1 as '生命周期'
from

(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
) as a

left join 
(select role_id,to_date(cast(date_time as timestamp)) as done_dt
     from myth_server.server_dungeon_end
     where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
     and game_type =3 
     and battle_result = 1
     and dungeon_id = 25  -- 通关3-6可参与
     and version_name in ('1.5.1','1.5.2')
     and channel_id in (1000,2000)
     and country not in ('CN','HK')
) b
on a.role_id = b.role_id

left join

(select role_id,enter_dt
from
(select role_id,day_time,consume_believer,to_date(cast(date_time as timestamp)) as enter_dt
from myth_server.server_bless_believer
where day_time between ${beginDate} and ${endDate}
and server_id in (${serverIds})
and version_name in ('1.5.1','1.5.2')
and channel_id in (1000,2000)
and country not in ('CN','HK')
) b1
where consume_believer > 0
) as c

on b.role_id = c.role_id and b.done_dt = c.enter_dt
where datediff(done_dt,birth_dt) <= 6
group by 1,2,3
) as a

left join   -- 留存玩法进入
(select role_id,done_date
from
(select role_id,day_time,consume_believer,to_date(cast(date_time as timestamp)) as done_date
from myth_server.server_bless_believer
where day_time between ${beginDate} and ${endDate}
and server_id in (${serverIds})
and version_name in ('1.5.1','1.5.2')
and channel_id in (1000,2000)
and country not in ('CN','HK')
) b1
where consume_believer > 0
) as b


--  留存登录
-- (select role_id,to_date(cast(date_time as timestamp)) as done_date
-- from myth.server_role_login
-- where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
-- and version_name in ('1.5.1','1.5.2')
-- and channel_id in (1000,2000)
-- and country not in ('CN','HK')
-- ) as b

on a.role_id = b.role_id
where datediff(done_date,done_dt) in (0,1,2,3,4,5,6)
group by 1,2,3,4



宝石矿坑
生命周期  玩法留存
select a.role_id,birth_dt,生命周期,datediff(done_date,done_dt)+1 as '留存天数'
from

(
select c.role_id as role_id,birth_dt,done_dt, datediff(done_dt,birth_dt)+1 as '生命周期'
from
(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
) as a

left join 
(select role_id,to_date(cast(date_time as timestamp)) as done_dt
     from myth_server.server_dungeon_end
     where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
     and game_type =3 
     and battle_result = 1
     and dungeon_id = 45  -- 通关4-10
     and version_name in ('1.5.1','1.5.2')
     and channel_id in (1000,2000)
     and country not in ('CN','HK')
) b
on a.role_id = b.role_id

left join
(select role_id,to_date(cast(date_time as timestamp)) as enter_dt
     from myth_server.server_gem_mine_start
     where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
     and version_name in ('1.5.1','1.5.2')
     and channel_id in (1000,2000)
     and country not in ('CN','HK')
) c
on b.role_id = c.role_id and b.done_dt = c.enter_dt
where datediff(done_dt,birth_dt) <= 6
group by 1,2,3
) as a

left join   -- 留存玩法进入
(select role_id,to_date(cast(date_time as timestamp)) as done_date
     from myth_server.server_gem_mine_start
     where  day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
     and version_name in ('1.5.1','1.5.2')
     and channel_id in (1000,2000)
     and country not in ('CN','HK')
group by 1,2
) as b


--  留存登录
-- (select role_id,to_date(cast(date_time as timestamp)) as done_date
-- from myth.server_role_login
-- where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
-- and version_name in ('1.5.1','1.5.2')
-- and channel_id in (1000,2000)
-- and country not in ('CN','HK')
-- ) as b

on a.role_id = b.role_id
where datediff(done_date,done_dt) in (0,1,2,3,4,5,6)
group by 1,2,3,4



死亡迷宫

玩法新增  
26 2023-3-17 18:00 —— 2023-3-20 18:00   1679047200000-1679306400000
27 2023-3-20 18:00 —— 2023-3-23 18:00   1679306400000-1679565600000
28 2023-3-23 18:00 —— 2023-3-26 18:00   1679565600000-1679824800000
select cycle_id,count(distinct role_id)
from myth_server.server_enter_dungeon
where day_time>=${beginDate} and day_time<=${doneDate} 
and server_id in (${serverIds})
and game_type=19 --次元危机
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
group by 1
order by 1


下周期留存人数
select count(distinct role_id)
from myth.server_role_login
where log_time >= ${beginDate} and log_time < ${endDate}
and server_id in (${serverIds})
and version_name in ('1.5.1','1.5.2')
and channel_id in (1000,2000)
and country not in ('CN','HK')
and role_id in 
(select role_id
from myth_server.server_enter_dungeon
where server_id in (${serverIds})
and game_type=19 --次元危机
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
and channel_id in (1000,2000)
and cycle_id = ${cycle_id}
group by 1)


下周期复玩人数
select count(distinct role_id)
from myth_server.server_enter_dungeon
where server_id in (${serverIds})
and game_type=19 --次元危机
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
and channel_id in (1000,2000)
and cycle_id = ${next_cycle_id}
and role_id in 
(select distinct role_id
from myth_server.server_enter_dungeon
where server_id in (${serverIds})
and game_type=19 --次元危机
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
and channel_id in (1000,2000)
and cycle_id = ${cycle_id}
)




英灵试炼 
2 2023-3-17 23:30 —— 2023-3-20 11:00 1679067000000 - 1679281200000
3 2023-3-21 11:30 —— 2023-3-23 23:00 1679369400000 - 1679583600000
4 2023-3-24 23:30 —— 2023-3-27 11:00 1679671800000 - 1679886000000

玩法新增
select cycle_id,count(distinct role_id)
from myth_server.server_enter_dungeon
where day_time>=${beginDate} and day_time<=${doneDate} 
and server_id in (${serverIds})
and game_type=17 --英灵试炼
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
and channel_id in (1000,2000)
group by 1
order by 1


下周期留存人数
select count(distinct role_id)
from myth.server_role_login
where log_time >= ${beginDate} and log_time <= ${endDate}
and server_id in (${serverIds})
and version_name in ('1.5.1','1.5.2')
and channel_id in (1000,2000)
and country not in ('CN','HK')
and role_id in 
(select role_id
from myth_server.server_enter_dungeon
where server_id in (${serverIds})
and game_type=17
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
and channel_id in (1000,2000)
and cycle_id = ${cycle_id}
group by 1)


下周期复玩人数
select count(distinct role_id)
from myth_server.server_enter_dungeon
where server_id in (${serverIds})
and game_type=17
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
and channel_id in (1000,2000)
and cycle_id = ${next_cycle_id}
and role_id in 
(select distinct role_id
from myth_server.server_enter_dungeon
where server_id in (${serverIds})
and game_type=17
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
and channel_id in (1000,2000)
and cycle_id = ${cycle_id}
)


 

