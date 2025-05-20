玩法系统数据分析  

玩法系统数据分析  

玩法——2->秘境

整体、付费、免费
-- 人数维度进入关卡人数、通关率

D1

select birth_dt,country,dungeon_id,是否付费,

-- count(distinct a.role_id)  as '挑战关卡人数',
-- count(distinct case when battle_result=1 then c.role_id else null end ) as '成功用户',
-- count(distinct case when battle_result=2 then c.role_id else null end ) as '失败用户',
-- count(distinct case when battle_result is null  then c.role_id else null end ) as '无日志人数'

--流失人数流失率
-- datediff(login_dt,enter_dt) as diffs,count(distinct a.role_id) as '角色数'

-- 失败复玩人数 无日志复玩人数
-- count(distinct f.role_id) as '复玩人数',sum(进入次数) as '失败复玩次数'
count(distinct f.role_id) as '无日志人数',sum(进入次数) as '无日志复玩次数'

-- 扫荡
-- count(distinct a.role_id)  as '扫荡人数'
-- ,sum(fights) as '扫荡次数'

-- 时长 自动手动
        -- battle_result,
        -- battle_time,
        -- count(distinct start_time) as '总次数',
        -- count(case when auto_battle = 1 and battle_result = 1 then b.role_id else null end) as '自动战斗通关次数',
        -- count(case when auto_battle = 1 and battle_result = 2 then b.role_id else null end) as '自动战斗未通关次数',
        -- count(case when auto_battle = 0 and battle_result = 1 then b.role_id else null end) as '手动战斗通关次数',
        -- count(case when auto_battle = 0 and battle_result = 2 then b.role_id else null end) as '手动战斗未通关次数',
        -- count(case when auto_battle is null then b.role_id else null end) as '无日志次数'

from
--流失人数，流失率
-- (select a.role_id,是否付费,birth_dt,enter_dt,country,dungeon_id,datediff(enter_dt,birth_dt) + 1 as '天数'
--  from
(select a.role_id,case when b.role_id is not null then '付费'
      else '免费'
      end as '是否付费',
      birth_dt,country
from 
(  --新增
select role_id,birth_dt,country
from
(select role_id,device_id,to_date(hours_add(date_time,-18)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(hours_add(date_time,-18)) as device_birth_dt, 
     case when country in ('PH','MY') then 'PH+MY'
     when country in ('GB','IE','CA')  then 'GB+CA'
     else  'others'
     end as country
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
) as a
left join -- 付费免费拆分
(select role_id,to_date(hours_add(date_time,-18)) as pay_dt
from myth.order_pay
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and country not in ('CN','HK')
group by 1,2) b 
on birth_dt=pay_dt and a.role_id=b.role_id
group by 1,2,3,4
) a 

left join
-- 挑战关卡人数、失败人数
-- (select a.dungeon_id,a.role_id,a.start_time,battle_result,battle_time,auto_battle,done_dt
-- from 
-- (select dungeon_id,role_id,start_time,to_date(hours_add(date_time,-18)) as done_dt-- start_time也可用统计参与次数
-- from myth_server.server_enter_dungeon
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and game_type = 2
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- group by 1,2,3,4
-- ) as a
-- left join     
-- (select dungeon_id,role_id,start_time,battle_result,battle_time,auto_battle
-- from myth_server.server_dungeon_end
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and game_type = 2
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- group by 1,2,3,4,5,6
-- ) b 
-- on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time=b.start_time 
-- ) as c 
-- on a.role_id = c.role_id and birth_dt=done_dt
-- where c.role_id is not null 
-- group by 1,2,3,4 

--流失人数，流失率
-- (select  to_date(hours_add(date_time,-18)) as enter_dt,role_id, max(dungeon_id)  as  dungeon_id
-- from myth_server.server_enter_dungeon
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and game_type = 2 
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- group by 1,2
-- )  c 
-- on a.role_id = c.role_id and datediff(enter_dt,birth_dt) = 0
-- ) a 
-- left join 
-- (
-- select role_id,to_date(hours_add(date_time,-18)) as login_dt
-- from myth.server_role_login
-- where day_time>=${beginDate} and day_time<=${doneDate} 
-- and server_id in (${serverIds}) 
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- group by  1,2
-- ) d 
-- on a.role_id = d.role_id and login_dt>=enter_dt
-- where datediff(login_dt,enter_dt) <=1
-- group by 1,2,3,4,5

失败复玩人数 无日志复玩人数
(
select role_id,done_dt,game_type,dungeon_id,进入次数 -- 对应着复玩人数、次数
from
(select d.role_id,c.done_dt,c.dungeon_id,c.game_type,进入次数
from
(select a.role_id,a.done_dt,a.dungeon_id,a.game_type -- 有失败的玩家
from
(select dungeon_id,role_id,to_date(hours_add(date_time,-18)) as done_dt,start_time,game_type
from myth_server.server_enter_dungeon
where day_time>=${beginDate} and day_time<=${end2Date} and server_id in (${serverIds})
and game_type =2 -- 2秘境
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3,4,5) a 
left join 
(select dungeon_id,role_id,battle_result,log_time,start_time,game_type
from myth_server.server_dungeon_end
where day_time>=${beginDate} and day_time<=${end2Date}   and server_id in (${serverIds})
and game_type =2 -- 2秘境
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3,4,5,6) b 
on a.game_type = b.game_type and a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time = b.start_time
-- where battle_result = 2      -- =2是有失败记录的
where battle_result is null  -- is null是无日志记录的
group by 1,2,3,4 
) c 
left join 
(select a.role_id as role_id,done_dt,a.game_type as game_type,a.dungeon_id as dungeon_id,count(a.start_time) as '进入次数'
from
(select dungeon_id,role_id,to_date(hours_add(date_time,-18)) as done_dt,start_time,game_type
from myth_server.server_enter_dungeon
where day_time>=${beginDate} and day_time<=${end2Date} and server_id in (${serverIds})
and game_type =2 -- 2秘境
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3,4,5) a 
left join 
(select dungeon_id,role_id,battle_result,log_time,start_time,game_type
from myth_server.server_dungeon_end
where day_time>=${beginDate} and day_time<=${end2Date}   and server_id in (${serverIds})
and game_type =2 -- 2秘境
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3,4,5,6) b 
on a.game_type = b.game_type and a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time = b.start_time
group by 1,2,3,4
) as d 
on c.game_type = d.game_type and c.dungeon_id=d.dungeon_id and c.role_id=d.role_id and c.done_dt=d.done_dt
group by 1,2,3,4,5
) as  e 
group by 1,2,3,4,5
) as f 
on a.role_id = f.role_id 

where datediff(done_dt,birth_dt) = 0 and 进入次数 > 1
group by 1,2,3,4

-- 扫荡人数
-- (
-- select to_date(hours_add(date_time,-18)) as dungeon_dt,role_id,dungeon_id,count(distinct log_time) as fights  
-- from myth_server.server_dungeon_blitz
-- where  day_time between ${beginDate} and ${endDate} 
-- and server_id in (${serverIds})
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- and game_type =2
-- group by 1,2,3
-- ) c 
-- on a.role_id =c.role_id and dungeon_dt = birth_dt
-- group by 1,2,3,4

-- 时长 自动手动
-- (select dungeon_id,role_id,start_time,battle_result,battle_time,auto_battle,done_dt
-- from
-- (select a.dungeon_id,a.role_id,a.start_time,battle_result,battle_time,auto_battle,done_dt
-- from 
-- (select dungeon_id,role_id,start_time,to_date(hours_add(date_time,-18)) as done_dt
-- from myth_server.server_enter_dungeon
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and game_type = 2 
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
--              when battle_time/60 > 0 and battle_time/60 <= 1  then '4一般'
--              else '无日志'
--         end as battle_time,auto_battle
-- from myth_server.server_dungeon_end
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and game_type = 2
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

-- where datediff(done_dt,birth_dt) = 0
-- group by 1,2,3,4,5,6






D2

select birth_dt,country,dungeon_id,是否付费,
-- count(distinct a.role_id)  as '挑战关卡人数',
-- count(distinct case when battle_result=1 then c.role_id else null end ) as '成功用户',
-- count(distinct case when battle_result=2 then c.role_id else null end ) as '失败用户',
-- count(distinct case when battle_result is null  then c.role_id else null end ) as '无日志人数'

--流失人数流失率
-- datediff(login_dt,enter_dt) as diffs,count(distinct a.role_id) as '角色数'

-- 失败复玩人数 无日志复玩人数
-- count(distinct f.role_id) as '复玩人数',sum(进入次数) as '失败复玩次数'
count(distinct f.role_id) as '无日志人数',sum(进入次数) as '无日志复玩次数'

-- 扫荡
-- count(distinct a.role_id)  as '扫荡人数'
-- ,sum(fights) as '扫荡次数'

-- 时长 自动手动
        -- battle_result,
        -- battle_time,
        -- count(distinct start_time) as '总次数',
        -- count(case when auto_battle = 1 and battle_result = 1 then b.role_id else null end) as '自动战斗通关次数',
        -- count(case when auto_battle = 1 and battle_result = 2 then b.role_id else null end) as '自动战斗未通关次数',
        -- count(case when auto_battle = 0 and battle_result = 1 then b.role_id else null end) as '手动战斗通关次数',
        -- count(case when auto_battle = 0 and battle_result = 2 then b.role_id else null end) as '手动战斗未通关次数',
        -- count(case when auto_battle is null then b.role_id else null end) as '无日志次数'

from

-- 流失人数，流失率
-- (select a.role_id,是否付费,birth_dt,enter_dt,country,dungeon_id,datediff(enter_dt,birth_dt) + 1 as '天数'
-- from

(select a.role_id,birth_dt,country,
case when datediff(pay_dt,birth_dt)<=1 and b.role_id is not null then '付费'
      else '免费'
      end as '是否付费'

from 
(  --新增
select role_id,birth_dt,country
from
(select role_id,device_id,to_date(hours_add(date_time,-18)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(hours_add(date_time,-18)) as device_birth_dt, 
     case when country in ('PH','MY') then 'PH+MY'
     when country in ('GB','IE','CA')  then 'GB+CA'
     else  'others'
     end as country
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
) as a
left join -- 付费免费拆分
(select role_id,to_date(hours_add(date_time,-18)) as pay_dt
from myth.order_pay
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and country not in ('CN','HK')
group by 1,2) b 
on a.role_id=b.role_id
group by 1,2,3,4 
) a 

left join
-- 挑战关卡人数、失败人数
-- (select a.dungeon_id,a.role_id,a.start_time,battle_result,battle_time,auto_battle,done_dt
-- from 
-- (select dungeon_id,role_id,start_time,to_date(hours_add(date_time,-18)) as done_dt-- start_time也可用统计参与次数
-- from myth_server.server_enter_dungeon
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and game_type = 2
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- group by 1,2,3,4
-- ) as a
-- left join     
-- (select dungeon_id,role_id,start_time,battle_result,battle_time,auto_battle
-- from myth_server.server_dungeon_end
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and game_type = 2
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- group by 1,2,3,4,5,6
-- ) b 
-- on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time=b.start_time 
-- ) as c 
-- on a.role_id = c.role_id 
-- where c.role_id is not null 
-- and datediff(c.done_dt,birth_dt)=1  
-- group by 1,2,3,4 

--流失人数，流失率
-- (select  to_date(hours_add(date_time,-18)) as enter_dt,role_id, max(dungeon_id)  as  dungeon_id
-- from myth_server.server_enter_dungeon
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and game_type = 2 
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- group by 1,2
-- )  c 
-- on a.role_id = c.role_id and datediff(enter_dt,birth_dt) = 1
-- ) a 
-- left join 
-- (
-- select role_id,to_date(hours_add(date_time,-18)) as login_dt
-- from myth.server_role_login
-- where day_time>=${beginDate} and day_time<=${doneDate} 
-- and server_id in (${serverIds}) 
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- group by  1,2
-- ) d 
-- on a.role_id = d.role_id and login_dt>=enter_dt
-- where datediff(login_dt,enter_dt) <=1
-- group by 1,2,3,4,5

--失败复玩人数 无日志复玩人数
(
select role_id,done_dt,game_type,dungeon_id,进入次数 -- 对应着复玩人数、次数
from
(select d.role_id,c.done_dt,c.dungeon_id,c.game_type,进入次数
from
(select a.role_id,a.done_dt,a.dungeon_id,a.game_type -- 有失败的玩家
from
(select dungeon_id,role_id,to_date(hours_add(date_time,-18)) as done_dt,start_time,game_type
from myth_server.server_enter_dungeon
where day_time>=${beginDate} and day_time<=${end2Date} and server_id in (${serverIds})
and game_type =2 -- 2秘境
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3,4,5) a 
left join 
(select dungeon_id,role_id,battle_result,log_time,start_time,game_type
from myth_server.server_dungeon_end
where day_time>=${beginDate} and day_time<=${end2Date}   and server_id in (${serverIds})
and game_type =2 -- 2秘境
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3,4,5,6) b 
on a.game_type = b.game_type and a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time = b.start_time
--where battle_result = 2     -- =2是有失败记录的
where battle_result is null -- is null是无日志记录的
group by 1,2,3,4 
) c 
left join 
(select a.role_id as role_id,done_dt,a.game_type as game_type,a.dungeon_id as dungeon_id,count(a.start_time) as '进入次数'
from
(select dungeon_id,role_id,to_date(hours_add(date_time,-18)) as done_dt,start_time,game_type
from myth_server.server_enter_dungeon
where day_time>=${beginDate} and day_time<=${end2Date} and server_id in (${serverIds})
and game_type =2 -- 2秘境
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3,4,5) a 
left join 
(select dungeon_id,role_id,battle_result,log_time,start_time,game_type
from myth_server.server_dungeon_end
where day_time>=${beginDate} and day_time<=${end2Date}   and server_id in (${serverIds})
and game_type =2 -- 2秘境
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3,4,5,6) b 
on a.game_type = b.game_type and a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time = b.start_time
group by 1,2,3,4
) as d 
on c.game_type = d.game_type and c.dungeon_id=d.dungeon_id and c.role_id=d.role_id and c.done_dt=d.done_dt
group by 1,2,3,4,5
) as  e 
group by 1,2,3,4,5
) as f 
on a.role_id = f.role_id 

where datediff(done_dt,birth_dt) = 1 and 进入次数 > 1
group by 1,2,3,4

-- 扫荡人数
-- (
-- select to_date(hours_add(date_time,-18)) as dungeon_dt,role_id,dungeon_id,count(distinct log_time) as fights  
-- from myth_server.server_dungeon_blitz
-- where  day_time between ${beginDate} and ${endDate} 
-- and server_id in (${serverIds})
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- and game_type =2
-- group by 1,2,3
-- ) c 
-- on a.role_id =c.role_id  
-- and datediff(c.dungeon_dt,birth_dt)=1 
-- group by 1,2,3,4

-- 时长 自动手动
-- (select dungeon_id,role_id,start_time,battle_result,battle_time,auto_battle,done_dt
-- from
-- (select a.dungeon_id,a.role_id,a.start_time,battle_result,battle_time,auto_battle,done_dt
-- from 
-- (select dungeon_id,role_id,start_time,to_date(hours_add(date_time,-18)) as done_dt
-- from myth_server.server_enter_dungeon
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and game_type = 2 
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
--              when battle_time/60 > 0 and battle_time/60 <= 1  then '4一般'
--              else '无日志'
--         end as battle_time,auto_battle
-- from myth_server.server_dungeon_end
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and game_type = 2
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

-- where datediff(done_dt,birth_dt) = 1
-- group by 1,2,3,4,5,6


 


D3

select birth_dt,country,dungeon_id,是否付费,

--挑战人数
-- count(distinct a.role_id)  as '挑战关卡人数',
-- count(distinct case when battle_result=1 then c.role_id else null end ) as '成功用户',
-- count(distinct case when battle_result=2 then c.role_id else null end ) as '失败用户',
-- count(distinct case when battle_result is null  then c.role_id else null end ) as '无日志人数'

--流失人数流失率
-- datediff(login_dt,enter_dt) as diffs,count(distinct a.role_id) as '角色数'

-- 失败复玩人数 无日志复玩人数
--count(distinct f.role_id) as '复玩人数',sum(进入次数) as '失败复玩次数'
-- count(distinct f.role_id) as '无日志人数',sum(进入次数) as '无日志复玩次数'

-- 扫荡
-- count(distinct a.role_id)  as '扫荡人数'
-- ,sum(fights) as '扫荡次数'

-- 时长 自动手动
        battle_result,
        battle_time,
        count(distinct start_time) as '总次数',
        count(case when auto_battle = 1 and battle_result = 1 then b.role_id else null end) as '自动战斗通关次数',
        count(case when auto_battle = 1 and battle_result = 2 then b.role_id else null end) as '自动战斗未通关次数',
        count(case when auto_battle = 0 and battle_result = 1 then b.role_id else null end) as '手动战斗通关次数',
        count(case when auto_battle = 0 and battle_result = 2 then b.role_id else null end) as '手动战斗未通关次数',
        count(case when auto_battle is null then b.role_id else null end) as '无日志次数'

from
-- 流失人数，流失率
-- (select a.role_id,是否付费,birth_dt,enter_dt,country,dungeon_id,datediff(enter_dt,birth_dt) + 1 as '天数'
-- from

(select a.role_id,birth_dt,country,
case when datediff(pay_dt,birth_dt)<=2 and b.role_id is not null then '付费'
      else '免费'
      end as '是否付费'

from 
(  --新增
select role_id,birth_dt,country
from
(select role_id,device_id,to_date(hours_add(date_time,-18)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(hours_add(date_time,-18)) as device_birth_dt, 
     case when country in ('PH','MY') then 'PH+MY'
     when country in ('GB','IE','CA')  then 'GB+CA'
     else  'others'
     end as country
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
) as a
left join -- 付费免费拆分
(select role_id,to_date(hours_add(date_time,-18)) as pay_dt
from myth.order_pay
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and country not in ('CN','HK')
group by 1,2) b 
on a.role_id=b.role_id
group by 1,2,3,4 
) a 

left join
-- -- 挑战关卡人数、失败人数
-- (select a.dungeon_id,a.role_id,a.start_time,battle_result,battle_time,auto_battle,done_dt
-- from 
-- (select dungeon_id,role_id,start_time,to_date(hours_add(date_time,-18)) as done_dt-- start_time也可用统计参与次数
-- from myth_server.server_enter_dungeon
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and game_type = 2
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- group by 1,2,3,4
-- ) as a
-- left join     
-- (select dungeon_id,role_id,start_time,battle_result,battle_time,auto_battle
-- from myth_server.server_dungeon_end
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and game_type = 2
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- group by 1,2,3,4,5,6
-- ) b 
-- on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time=b.start_time 
-- ) as c 
-- on a.role_id = c.role_id  
-- and datediff(c.done_dt,birth_dt)=2
-- where c.role_id is not null 
-- group by 1,2,3,4 

--流失人数，流失率
-- (select  to_date(hours_add(date_time,-18)) as enter_dt,role_id, max(dungeon_id)  as  dungeon_id
-- from myth_server.server_enter_dungeon
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and game_type = 2 
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- group by 1,2
-- )  c 
-- on a.role_id = c.role_id and datediff(enter_dt,birth_dt) = 2
-- ) a 
-- left join 
-- (
-- select role_id,to_date(hours_add(date_time,-18)) as login_dt
-- from myth.server_role_login
-- where day_time>=${beginDate} and day_time<=${doneDate} 
-- and server_id in (${serverIds}) 
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- group by  1,2
-- ) d 
-- on a.role_id = d.role_id and login_dt>=enter_dt
-- where datediff(login_dt,enter_dt) <=1
-- group by 1,2,3,4,5

-- 失败复玩人数 无日志复玩人数
-- (
-- select role_id,done_dt,game_type,dungeon_id,进入次数 -- 对应着复玩人数、次数
-- from
-- (select d.role_id,c.done_dt,c.dungeon_id,c.game_type,进入次数
-- from
-- (select a.role_id,a.done_dt,a.dungeon_id,a.game_type -- 有失败的玩家
-- from
-- (select dungeon_id,role_id,to_date(hours_add(date_time,-18)) as done_dt,start_time,game_type
-- from myth_server.server_enter_dungeon
-- where day_time>=${beginDate} and day_time<=${end2Date} and server_id in (${serverIds})
-- and game_type =2 -- 2秘境
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- group by 1,2,3,4,5) a 
-- left join 
-- (select dungeon_id,role_id,battle_result,log_time,start_time,game_type
-- from myth_server.server_dungeon_end
-- where day_time>=${beginDate} and day_time<=${end2Date}   and server_id in (${serverIds})
-- and game_type =2 -- 2秘境
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- group by 1,2,3,4,5,6) b 
-- on a.game_type = b.game_type and a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time = b.start_time
--where battle_result = 2      -- =2是有失败记录的
-- where battle_result is null  -- is null是无日志记录的
-- group by 1,2,3,4 
-- ) c 
-- left join 
-- (select a.role_id as role_id,done_dt,a.game_type as game_type,a.dungeon_id as dungeon_id,count(a.start_time) as '进入次数'
-- from
-- (select dungeon_id,role_id,to_date(hours_add(date_time,-18)) as done_dt,start_time,game_type
-- from myth_server.server_enter_dungeon
-- where day_time>=${beginDate} and day_time<=${end2Date} and server_id in (${serverIds})
-- and game_type =2 -- 2秘境
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- group by 1,2,3,4,5) a 
-- left join 
-- (select dungeon_id,role_id,battle_result,log_time,start_time,game_type
-- from myth_server.server_dungeon_end
-- where day_time>=${beginDate} and day_time<=${end2Date}   and server_id in (${serverIds})
-- and game_type =2 -- 2秘境
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- group by 1,2,3,4,5,6) b 
-- on a.game_type = b.game_type and a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time = b.start_time
-- group by 1,2,3,4
-- ) as d 
-- on c.game_type = d.game_type and c.dungeon_id=d.dungeon_id and c.role_id=d.role_id and c.done_dt=d.done_dt
-- group by 1,2,3,4,5
-- ) as  e 
-- group by 1,2,3,4,5
-- ) as f 
-- on a.role_id = f.role_id 
-- where datediff(done_dt,birth_dt) = 2 and 进入次数 > 1
-- group by 1,2,3,4

-- 扫荡人数
-- (
-- select to_date(hours_add(date_time,-18)) as dungeon_dt,role_id,dungeon_id,count(distinct log_time) as fights  
-- from myth_server.server_dungeon_blitz
-- where  day_time between ${beginDate} and ${endDate} 
-- and server_id in (${serverIds})
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- and game_type =2
-- group by 1,2,3
-- ) c 
-- on a.role_id =c.role_id 
-- and datediff(c.dungeon_dt,birth_dt)=2
-- group by 1,2,3,4 

-- 时长 自动手动
(select dungeon_id,role_id,start_time,battle_result,battle_time,auto_battle,done_dt
from
(select a.dungeon_id,a.role_id,a.start_time,battle_result,battle_time,auto_battle,done_dt
from 
(select dungeon_id,role_id,start_time,to_date(hours_add(date_time,-18)) as done_dt
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 2 
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3,4
) as a
left join     
(select dungeon_id,role_id,start_time,battle_result,
        case when battle_time is null then '无日志'
             when battle_time/60 > 3  then '1超时'
             when battle_time/60 > 2 and battle_time/60 <= 3  then '2困难'
             when battle_time/60 > 1 and battle_time/60 <= 2  then '3较难'
             when battle_time/60 > 0 and battle_time/60 <= 1  then '4一般'
             else '无日志'
        end as battle_time,auto_battle
from myth_server.server_dungeon_end
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 2
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3,4,5,6
) b 
on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time=b.start_time
order by a.role_id,a.start_time asc 
) as e  
group by 1,2,3,4,5,6,7
) as b 
on a.role_id = b.role_id

where datediff(done_dt,birth_dt) = 2
group by 1,2,3,4,5,6









-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

生命周期的秘境参与人数 扫荡参与人数 秘境成功闯关次数  扫荡次数  
D1-D3
D1
select  birth_dt,country,是否付费,count(distinct a.role_id) as users
,sum(fights) as fights
,sum(tui)  as tui
from
(select a.role_id,birth_dt,country,
case when b.role_id is not null then '付费'
      else '免费'
      end as '是否付费'
from 
(  --新增
select role_id,birth_dt,country
from
(select role_id,device_id,to_date(hours_add(date_time,-18)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(hours_add(date_time,-18)) as device_birth_dt, 
     case when country in ('PH','MY') then 'PH+MY'
     when country in ('GB','IE','CA')  then 'GB+CA'
     else 'others'
     end as country
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
) as a
left join -- 付费免费拆分
(select role_id,to_date(hours_add(date_time,-18)) as pay_dt
from myth.order_pay
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and country not in ('CN','HK')
group by 1,2
) b 
on a.role_id=b.role_id and  birth_dt = pay_dt
group by 1,2,3,4
) a 
 join 
(
select to_date(hours_add(date_time,-18)) as dungeon_dt,role_id
from myth_server.server_enter_dungeon
where  day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and game_type =2
union   
select to_date(hours_add(date_time,-18)) as dungeon_dt,role_id
from myth_server.server_dungeon_blitz
where  day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and game_type =2
) c 
-- (
-- select to_date(hours_add(date_time,-18)) as dungeon_dt,role_id,count(distinct start_time) as fights
-- from myth_server.server_dungeon_end
-- where  day_time between ${beginDate} and ${endDate} 
-- and server_id in (${serverIds})
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- and game_type =2
-- and battle_result =1
-- group by 1,2
-- ) c 
-- (
-- select to_date(hours_add(date_time,-18)) as dungeon_dt,role_id,count(distinct log_time) as fights  
-- from myth_server.server_dungeon_blitz
-- where  day_time between ${beginDate} and ${endDate} 
-- and server_id in (${serverIds})
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- and game_type =2
-- group by 1,2
-- ) c 

(select role_id,to_date(hours_add(date_time,-18)) as dungeon_dt,sum(change_count) as 'fights'
from myth.server_prop
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and change_type = 'CONSUME'
and prop_id = '100535'
group by 1,2
) c 
on a.role_id =c.role_id and dungeon_dt = birth_dt

left join 
(select role_id,to_date(hours_add(date_time,-18)) as dungeon_dt,sum(change_count) as 'tui'
from myth.server_prop
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and change_method ='4'
and change_type = 'PRODUCE'
and prop_id = '100535'
group by 1,2
) d 
on a.role_id =d.role_id and dungeon_dt = birth_dt
group by 1,2,3



D2
select  birth_dt,country,是否付费,
count(distinct a.role_id) as users
,sum(fights) as fights
,sum(tui) as tui
from
(select a.role_id,birth_dt,country,
case when datediff(pay_dt,birth_dt)<=1 and b.role_id is not null then '付费'
      else '免费'
      end as '是否付费'
from 
(  --新增
select role_id,birth_dt,country
from
(select role_id,device_id,to_date(hours_add(date_time,-18)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(hours_add(date_time,-18)) as device_birth_dt, 
     case when country in ('PH','MY') then 'PH+MY'
     when country in ('GB','IE','CA')  then 'GB+CA'
          else 'others'
     end as country
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
) as a
left join -- 付费免费拆分
(select role_id,to_date(hours_add(date_time,-18)) as pay_dt
from myth.order_pay
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and country not in ('CN','HK')
group by 1,2) b 
on a.role_id=b.role_id 
group by 1,2,3,4
) a 
 join 
(
select to_date(hours_add(date_time,-18)) as dungeon_dt,role_id
from myth_server.server_enter_dungeon
where  day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and game_type =2
--group by 1,2 ) c 
union   
select to_date(hours_add(date_time,-18)) as dungeon_dt,role_id
from myth_server.server_dungeon_blitz
where  day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and game_type =2
) c 
-- (
-- select to_date(hours_add(date_time,-18)) as dungeon_dt,role_id,count(distinct start_time) as fights
-- from myth_server.server_dungeon_end
-- where  day_time between ${beginDate} and ${endDate} 
-- and server_id in (${serverIds})
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- and game_type =2
-- and battle_result =1
-- group by 1,2
-- ) c 
-- (
-- select to_date(hours_add(date_time,-18)) as dungeon_dt,role_id,count(distinct log_time) as fights  
-- from myth_server.server_dungeon_blitz
-- where  day_time between ${beginDate} and ${endDate} 
-- and server_id in (${serverIds})
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- and game_type =2
-- group by 1,2
-- ) c
left join 
(select role_id,to_date(hours_add(date_time,-18)) as dungeon_dt,sum(change_count) as 'fights'
from myth.server_prop
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and change_type = 'CONSUME'
and prop_id = '100535'
group by 1,2
) c 
on a.role_id =c.role_id 

left join 
(select role_id,to_date(hours_add(date_time,-18)) as dungeon_dt,sum(change_count) as 'tui'
from myth.server_prop
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and change_method ='4'
and change_type = 'PRODUCE'
and prop_id = '100535'
group by 1,2
) d 
on a.role_id =d.role_id 
where datediff(c.dungeon_dt,birth_dt)=1 
and datediff(d.dungeon_dt,birth_dt)=1
group by 1,2,3


D3
select  birth_dt,country,是否付费,
count(distinct a.role_id) as users,sum(fights) as fights
from
(select a.role_id,birth_dt,country,
case when datediff(pay_dt,birth_dt)<=2 and b.role_id is not null then '付费'
      else '免费'
      end as '是否付费'
from 
(  --新增
select role_id,birth_dt,country
from
(select role_id,device_id,to_date(hours_add(date_time,-18)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(hours_add(date_time,-18)) as device_birth_dt, 
     case when country in ('PH','MY') then 'PH+MY'
     when country in ('GB','IE','CA')  then 'GB+CA'
          else 'others'
     end as country
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
) as a
left join -- 付费免费拆分
(select role_id,to_date(hours_add(date_time,-18)) as pay_dt
from myth.order_pay
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and country not in ('CN','HK')
group by 1,2) b 
on a.role_id=b.role_id 
group by 1,2,3,4
) a 
 join 
(
select to_date(hours_add(date_time,-18)) as dungeon_dt,role_id
from myth_server.server_enter_dungeon
where  day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and game_type =2
union   
select to_date(hours_add(date_time,-18)) as dungeon_dt,role_id
from myth_server.server_dungeon_blitz
where  day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and game_type =2
) c 
-- (
-- select to_date(hours_add(date_time,-18)) as dungeon_dt,role_id,count(distinct start_time) as fights
-- from myth_server.server_dungeon_end
-- where  day_time between ${beginDate} and ${endDate} 
-- and server_id in (${serverIds})
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- and game_type =2
-- and battle_result =1
-- group by 1,2 
-- ) c 
-- (
-- select to_date(hours_add(date_time,-18)) as dungeon_dt,role_id,count(distinct log_time) as fights  
-- from myth_server.server_dungeon_blitz
-- where  day_time between ${beginDate} and ${endDate} 
-- and server_id in (${serverIds})
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- and game_type =2
-- group by 1,2
-- ) c

left join 
(select role_id,to_date(hours_add(date_time,-18)) as dungeon_dt,sum(change_count) as 'fights'
from myth.server_prop
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and change_type = 'CONSUME'
and prop_id = '100535'
group by 1,2
) c 
on a.role_id =c.role_id 

left join 
(select role_id,to_date(hours_add(date_time,-18)) as dungeon_dt,sum(change_count) as 'tui'
from myth.server_prop
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and change_method ='4'
and change_type = 'PRODUCE'
and prop_id = '100535'
group by 1,2
) d 
on a.role_id =d.role_id 
where datediff(c.dungeon_dt,birth_dt)=2
and datediff(d.dungeon_dt,birth_dt)=2
group by 1,2,3
