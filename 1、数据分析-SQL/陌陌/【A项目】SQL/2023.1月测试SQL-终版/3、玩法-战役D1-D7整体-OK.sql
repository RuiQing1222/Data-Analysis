-- 生命周期D1-D7整体数据
select dungeon_id,

-- 进入关卡人数、通关率、失败人数、失败率、无日志人数、无日志率
-- count(distinct a.role_id) as '进入关卡人数',
-- count(distinct case when battle_result=1 then b.role_id else null end ) as '通关人数',
-- count(distinct case when battle_result=1 then b.role_id else null end ) / count(distinct a.role_id) as '通关率',
-- count(distinct case when battle_result=2 then b.role_id else null end ) as '失败人数',
-- count(distinct case when battle_result=2 then b.role_id else null end ) / count(distinct a.role_id) as '失败率',
-- count(distinct case when battle_result is null then b.role_id else null end ) as '无日志人数',
-- count(distinct case when battle_result is null then b.role_id else null end ) / count(distinct a.role_id) as '无日志率'

-- 失败复玩率、无日志复玩率  battle_result =2是有失败记录的/is null是无日志记录的
-- count(distinct f.role_id) as '复玩人数'

-- 最高关卡停留且无通关记录的人数且未去其他玩法
num,
-- count(distinct f.role_id)

-- 最高关卡停留且无通关记录的人数且未去其他玩法,7天登录过的玩家
count(distinct case when datediff(login_dt,enter_dt) <= 6 then a.role_id else null end) as '7日内登录角色数'

-- 时长、自动手动
-- battle_result,
-- battle_time,
-- count(distinct start_time) as '总次数',
-- count(case when auto_battle = 1 and battle_result = 1 then b.role_id else null end) as '自动战斗通关次数',
-- count(case when auto_battle = 1 and battle_result = 2 then b.role_id else null end) as '自动战斗未通关次数',
-- count(case when auto_battle = 0 and battle_result = 1 then b.role_id else null end) as '手动战斗通关次数',
-- count(case when auto_battle = 0 and battle_result = 2 then b.role_id else null end) as '手动战斗未通关次数',
-- count(case when auto_battle is null then b.role_id else null end) as '无日志次数'

-- 重复进入人数
-- count(distinct e.role_id)

-- 重复进入最终通关人数
-- count(distinct f.role_id)


from

-- 最高关卡停留且无通关记录的人数且未去其他玩法,7天登录过的玩家
(select a.role_id,enter_dt,dungeon_id,num
 from

(  --新增
select role_id,birth_dt,country
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt, 
     case when country in ('PH','MY') then 'PH+MY'
     when country in ('GB','IE','CA')  then 'GB+CA'
     end as country
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
) as a


-- -- 进入关卡人数、通关率
-- left join
-- -- 关卡参与情况
-- (select a.dungeon_id,a.role_id,a.start_time,battle_result,battle_time,auto_battle,done_dt
-- from 
-- (select dungeon_id,role_id,start_time,to_date(cast(date_time as timestamp)) as done_dt
-- from myth_server.server_enter_dungeon
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and game_type = 3 -- 3->战役
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- group by 1,2,3,4
-- ) as a
-- left join     
-- (select dungeon_id,role_id,start_time,battle_result,battle_time,auto_battle
-- from myth_server.server_dungeon_end
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and game_type = 3 -- 3->战役
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- group by 1,2,3,4,5,6
-- ) c 
-- on a.dungeon_id=c.dungeon_id and a.role_id=c.role_id and a.start_time=c.start_time 
-- ) as b 
-- on a.role_id = b.role_id and datediff(done_dt,birth_dt) <= 6
-- where b.role_id is not null 
-- group by 1 order by 1



-- -- 失败复玩率、无日志复玩率
-- left join
-- (
-- select role_id,done_dt,dungeon_id,进入次数 -- 对应着复玩人数
-- from
-- (select d.role_id,c.done_dt,c.dungeon_id,进入次数
-- from
-- (select a.role_id,a.done_dt,a.dungeon_id -- 有失败的玩家
-- from
-- (select dungeon_id,role_id,to_date(cast(date_time as timestamp)) as done_dt,start_time
-- from myth_server.server_enter_dungeon
-- where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
-- and game_type =3 -- 3战役
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- group by 1,2,3,4) a 
-- left join 
-- (select dungeon_id,role_id,battle_result,log_time,start_time
-- from myth_server.server_dungeon_end
-- where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
-- and game_type =3 -- 3战役
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- group by 1,2,3,4,5) b 
-- on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time = b.start_time
-- where battle_result is null -- =2是有失败记录的/is null是无日志记录的
-- group by 1,2,3
-- ) c 
-- left join 
-- (select a.role_id as role_id,done_dt,a.dungeon_id as dungeon_id,count(a.start_time) as '进入次数'
-- from
-- (select dungeon_id,role_id,to_date(cast(date_time as timestamp)) as done_dt,start_time
-- from myth_server.server_enter_dungeon
-- where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
-- and game_type =3 -- 3战役
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- group by 1,2,3,4) a 
-- left join 
-- (select dungeon_id,role_id,battle_result,log_time,start_time
-- from myth_server.server_dungeon_end
-- where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
-- and game_type =3 -- 3战役
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- group by 1,2,3,4,5) b 
-- on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time = b.start_time
-- group by 1,2,3
-- ) as d 
-- on c.dungeon_id=d.dungeon_id and c.role_id=d.role_id and datediff(d.done_dt,c.done_dt) <= 6
-- group by 1,2,3,4
-- ) as  e 
-- group by 1,2,3,4
-- ) as f 
-- on a.role_id = f.role_id 
-- where datediff(done_dt,birth_dt) <= 6 and 进入次数 > 1
-- group by 1 order by 1



-- 最高关卡停留且无通关记录的人数且未去其他玩法
-- left join 
-- (select role_id,dungeon_id,enter_dt,sum(标签) as num
-- from
-- (select c.role_id,c.enter_dt,dungeon_id,玩法类型,标签
-- from

-- (select c3.role_id,enter_dt,c2.dungeon_id,end_time,标签 -- 最高关卡且无通关记录的玩家
-- from
-- (select role_id,enter_dt,dungeon_id,start_time
-- from
-- (select to_date(cast(date_time as timestamp)) as enter_dt,role_id,start_time,dungeon_id,row_number() over(partition by role_id order by log_time desc) as num
-- from myth_server.server_enter_dungeon
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and game_type = 3 
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- ) c1 
-- where num = 1
-- ) c2

-- left join
-- (
-- select dungeon_id,role_id,start_time,end_time,标签
-- from
-- (
-- select a.role_id,a.start_time,a.dungeon_id,end_time,1 as '标签'
-- from
-- (select dungeon_id,role_id,to_date(cast(date_time as timestamp)) as done_dt,start_time
-- from myth_server.server_enter_dungeon
-- where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
-- and game_type =3 -- 3战役
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- group by 1,2,3,4) a 
-- left join 
-- (select dungeon_id,role_id,battle_result,log_time as end_time,start_time
-- from myth_server.server_dungeon_end
-- where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
-- and game_type =3 -- 3战役
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- group by 1,2,3,4,5) b 
-- on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time = b.start_time
-- where battle_result = 2 -- 有失败日志的

-- union all

-- select a.role_id,a.start_time,a.dungeon_id,end_time,2 as '标签'
-- from
-- (select dungeon_id,role_id,to_date(cast(date_time as timestamp)) as done_dt,start_time
-- from myth_server.server_enter_dungeon
-- where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
-- and game_type =3 -- 3战役
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- group by 1,2,3,4) a 
-- left join 
-- (select dungeon_id,role_id,battle_result,log_time as end_time,start_time
-- from myth_server.server_dungeon_end
-- where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
-- and game_type =3 -- 3战役
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- group by 1,2,3,4,5) b 
-- on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time = b.start_time
-- where battle_result is null -- 无日志的
-- ) c4
-- group by 1,2,3,4,5
-- ) c3 
-- on c2.role_id = c3.role_id and c2.dungeon_id=c3.dungeon_id and c2.start_time = c3.start_time
-- group by 1,2,3,4,5
-- ) as c

-- left join
-- (
-- select role_id,to_date(cast(date_time as timestamp)) as enter_dt,start_time,
-- case game_type 
--            when 2 then '秘境'
--            when 4 then '竞技场'
--            when 6 then '远古战场'
--            when 7 then '地精宝库'
--            when 8 then '诸神试炼'
--            when 9 then '诸神试炼'
--            when 10 then '诸神试炼'
--            when 11 then '诸神试炼'
--            when 12 then '诸神试炼'
--            when 13 then '诸神试炼'
--            when 14 then '宝石矿坑'
--            when 16 then '公会领主'
--            when 17 then '无尽深渊'
--            when 18 then '公会远征'
--            when 19 then '次元危机'
--            else 'others'
--            end as '玩法类型'
-- from myth_server.server_enter_dungeon
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and game_type in (2,4,6,7,8,9,10,11,12,13,14,16,17,18,19)
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- ) as d
-- on c.role_id = d.role_id and c.enter_dt = d.enter_dt and d.start_time > c.end_time
-- group by 1,2,3,4,5
-- ) as e  
-- where 玩法类型 is null
-- group by 1,2,3
-- ) f
-- on a.role_id = f.role_id and datediff(enter_dt,birth_dt) <= 6
-- group by 1,2 
-- order by 1,2


-- 最高关卡停留且无通关记录的人数且未去其他玩法,7天登录过的玩家
left join 
(select role_id,dungeon_id,enter_dt,sum(标签) as num
from
(select c.role_id,c.enter_dt,dungeon_id,玩法类型,标签
from

(select c3.role_id,enter_dt,c2.dungeon_id,end_time,标签 -- 最高关卡且无通关记录的玩家
from
(select role_id,enter_dt,dungeon_id,start_time
from
(select to_date(cast(date_time as timestamp)) as enter_dt,role_id,start_time,dungeon_id,row_number() over(partition by role_id order by log_time desc) as num
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 3 
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) c1 
where num = 1
) c2

left join
(
select dungeon_id,role_id,start_time,end_time,标签
from
(
select a.role_id,a.start_time,a.dungeon_id,end_time,1 as '标签'
from
(select dungeon_id,role_id,to_date(cast(date_time as timestamp)) as done_dt,start_time
from myth_server.server_enter_dungeon
where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
and game_type =3 -- 3战役
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3,4) a 
left join 
(select dungeon_id,role_id,battle_result,log_time as end_time,start_time
from myth_server.server_dungeon_end
where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
and game_type =3 -- 3战役
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3,4,5) b 
on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time = b.start_time
where battle_result = 2 -- 有失败日志的

union all

select a.role_id,a.start_time,a.dungeon_id,end_time,2 as '标签'
from
(select dungeon_id,role_id,to_date(cast(date_time as timestamp)) as done_dt,start_time
from myth_server.server_enter_dungeon
where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
and game_type =3 -- 3战役
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3,4) a 
left join 
(select dungeon_id,role_id,battle_result,log_time as end_time,start_time
from myth_server.server_dungeon_end
where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
and game_type =3 -- 3战役
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3,4,5) b 
on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time = b.start_time
where battle_result is null -- 无日志的
) c4
group by 1,2,3,4,5
) c3 
on c2.role_id = c3.role_id and c2.dungeon_id=c3.dungeon_id and c2.start_time = c3.start_time
group by 1,2,3,4,5
) as c

left join
(
select role_id,to_date(cast(date_time as timestamp)) as enter_dt,start_time,
case game_type 
           when 2 then '秘境'
           when 4 then '竞技场'
           when 6 then '远古战场'
           when 7 then '地精宝库'
           when 8 then '诸神试炼'
           when 9 then '诸神试炼'
           when 10 then '诸神试炼'
           when 11 then '诸神试炼'
           when 12 then '诸神试炼'
           when 13 then '诸神试炼'
           when 14 then '宝石矿坑'
           when 16 then '公会领主'
           when 17 then '无尽深渊'
           when 18 then '公会远征'
           when 19 then '次元危机'
           else 'others'
           end as '玩法类型'
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type in (2,4,6,7,8,9,10,11,12,13,14,16,17,18,19)
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as d
on c.role_id = d.role_id and c.enter_dt = d.enter_dt and d.start_time > c.end_time
group by 1,2,3,4,5
) as e  
where 玩法类型 is null
group by 1,2,3
) f
on a.role_id = f.role_id and datediff(enter_dt,birth_dt) <= 6
group by 1,2,3,4
) a

left join 
(
select role_id,to_date(cast(date_time as timestamp)) as login_dt
from myth.server_role_login
where day_time>=${beginDate} and day_time<=${doneDate} 
and server_id in (${serverIds}) 
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) d
on a.role_id = d.role_id and login_dt>enter_dt
group by 1,2
order by 1


-- left join 
-- -- 时长 自动手动
-- (select dungeon_id,role_id,start_time,battle_result,battle_time,auto_battle,done_dt
-- from
-- (select a.dungeon_id,a.role_id,a.start_time,battle_result,battle_time,auto_battle,done_dt
-- from 
-- (select dungeon_id,role_id,start_time,to_date(cast(date_time as timestamp)) as done_dt
-- from myth_server.server_enter_dungeon
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and game_type = 3 
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- group by 1,2,3,4
-- ) as a
-- left join     
-- (select dungeon_id,role_id,start_time,battle_result,
--         case when battle_time is null then '无日志'
--              when battle_time/60 > 3  then '1超时'
--              when battle_time/60 > 2 and battle_time/60 <= 3  then '2困难'
--              when battle_time/60 > 1 and battle_time/60 <= 2  then '3较难'
--              when battle_time/60 > 0.5 and battle_time/60 <= 1  then '4-30s-1m'

--              when battle_time > 20 and battle_time <= 30  then '5-20-30s'
--              when battle_time > 10 and battle_time <= 20  then '6-10-20s'
--              when battle_time > 0 and battle_time <= 10  then '7-0-10s'
--              else '无日志'
--         end as battle_time,auto_battle
-- from myth_server.server_dungeon_end
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and game_type = 3
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- group by 1,2,3,4,5,6
-- ) b 
-- on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time=b.start_time
-- order by a.role_id,a.start_time asc 
-- ) as e  
-- group by 1,2,3,4,5,6,7
-- ) as b 
-- on a.role_id = b.role_id

-- where datediff(done_dt,birth_dt) <= 6
-- group by 1,2,3
-- order by 1

-- left join
-- -- 重复进入人数
-- (select role_id,dungeon_id,done_dt
-- from
-- (select dungeon_id,role_id,to_date(cast(date_time as timestamp)) as done_dt,count(distinct start_time) as '进入次数'
-- from myth_server.server_enter_dungeon
-- where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
-- and game_type =3 -- 3战役
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- group by 1,2,3
-- ) c1
-- where 进入次数 > 1
-- group by 1,2,3 
-- ) as e
-- on a.role_id = e.role_id
-- group by 1 order by 1


-- -- 重复进入最终通关人数
-- left join
-- (select d.role_id,d.dungeon_id,d.done_dt
-- from
-- (select role_id,dungeon_id,done_dt
-- from
-- (select dungeon_id,role_id,to_date(cast(date_time as timestamp)) as done_dt,count(distinct start_time) as '进入次数'
-- from myth_server.server_enter_dungeon
-- where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
-- and game_type =3 -- 3战役
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- group by 1,2,3
-- ) c1
-- where 进入次数 > 1
-- group by 1,2,3 
-- ) as c
-- left join 
-- (select a.role_id as role_id,done_dt,a.dungeon_id as dungeon_id,battle_result
-- from
-- (select dungeon_id,role_id,to_date(cast(date_time as timestamp)) as done_dt,start_time
-- from myth_server.server_enter_dungeon
-- where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
-- and game_type =3 -- 3战役
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- group by 1,2,3,4) a 
-- left join 
-- (select dungeon_id,role_id,battle_result,log_time,start_time
-- from myth_server.server_dungeon_end
-- where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
-- and game_type =3 -- 3战役
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- group by 1,2,3,4,5) b 
-- on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time = b.start_time
-- where battle_result = 1 -- 有成功日志的
-- group by 1,2,3,4
-- ) as d 
-- on c.dungeon_id=d.dungeon_id and c.role_id=d.role_id and c.done_dt=d.done_dt
-- group by 1,2,3
-- ) as f 
-- on a.role_id = f.role_id 
-- where datediff(f.done_dt,a.birth_dt) <= 6 
-- group by 1
-- order by 1