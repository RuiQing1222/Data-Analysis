
玩法——2->秘境  16号新增用户在16、17两天的战役数据


select dungeon_id,

-- 战力压制 按照颜色 只算俩数据
count(distinct case when suppression = '绿色' then start_time else null end) as '绿色进入关卡次数',
count(distinct case when battle_result=1 and suppression = '绿色' then b.role_id else null end ) / count(distinct case when suppression = '绿色' then start_time else null end) as '绿色通关率',
count(distinct case when suppression = '白色' then start_time else null end) as '白色进入关卡次数',
count(distinct case when battle_result=1 and suppression = '白色' then b.role_id else null end ) / count(distinct case when suppression = '白色' then start_time else null end) as '白色通关率',
count(distinct case when suppression = '黄色' then start_time else null end) as '黄色进入关卡次数',
count(distinct case when battle_result=1 and suppression = '黄色' then b.role_id else null end ) / count(distinct case when suppression = '黄色' then start_time else null end) as '黄色通关率',
count(distinct case when suppression = '橙色' then start_time else null end) as '橙色进入关卡次数',
count(distinct case when battle_result=1 and suppression = '橙色' then b.role_id else null end ) / count(distinct case when suppression = '橙色' then start_time else null end) as '橙色通关率',
count(distinct case when suppression = '红色' then start_time else null end) as '红色进入关卡次数',
count(distinct case when battle_result=1 and suppression = '红色' then b.role_id else null end ) / count(distinct case when suppression = '红色' then start_time else null end) as '红色通关率',
--整体
count(distinct a.role_id) as '进入关卡人数',
count(distinct case when battle_result=1 then b.role_id else null end ) as '通关人数',
count(distinct case when battle_result=1 then b.role_id else null end ) / count(distinct a.role_id) as '通关率',
count(distinct case when battle_result=2 then b.role_id else null end ) as '失败人数',
count(distinct case when battle_result=2 then b.role_id else null end ) / count(distinct a.role_id) as '失败率',
count(distinct case when battle_result is null then b.role_id else null end ) as '无日志人数',
count(distinct case when battle_result is null then b.role_id else null end ) / count(distinct a.role_id) as '无日志率'

-- 复玩人数
-- count(distinct e.role_id)

-- 复玩通关人数 
 -- count(distinct f.role_id)


-- 时长 通关-死亡-主动退出remain_hp 是否为0
-- count(distinct case when battle_result = 2 and remain_hp = 0 then a.role_id else null end) as '死亡人数',
-- count(distinct case when battle_result = 2 and battle_time = '1超时' then a.role_id else null end) as '超时人数',
-- count(distinct case when battle_result = 2 and remain_hp <> 0 and battle_time <> '1超时' then a.role_id else null end) as '主动退出人数',
-- count(case when battle_result = 1 and battle_time = '1超时' then start_time else null end) as '通关1超时次数',
-- count(case when battle_result = 1 and battle_time = '2困难' then start_time else null end) as '通关2困难次数',
-- count(case when battle_result = 1 and battle_time = '3较难' then start_time else null end) as '通关3较难次数',
-- count(case when battle_result = 1 and battle_time = '4一般' then start_time else null end) as '通关4一般次数',
-- count(case when battle_result = 1 then start_time else null end) as '通关汇总次数',
-- count(case when battle_result = 2 and battle_time = '1超时' and remain_hp = 0 then start_time else null end) as '死亡1超时次数',
-- count(case when battle_result = 2 and battle_time = '2困难' and remain_hp = 0 then start_time else null end) as '死亡2困难次数',
-- count(case when battle_result = 2 and battle_time = '3较难' and remain_hp = 0 then start_time else null end) as '死亡3较难次数',
-- count(case when battle_result = 2 and battle_time = '4一般' and remain_hp = 0 then start_time else null end) as '死亡4一般次数',
-- count(case when battle_result = 2 and remain_hp = 0  then start_time else null end) as '死亡汇总次数',
-- count(case when battle_result = 2 and remain_hp <> 0 and battle_time = '1超时'  then start_time else null end) as '超时未通关次数',
-- count(case when battle_result = 2 and battle_time = '2困难' and remain_hp <> 0  then start_time else null end) as '主动退出2困难次数',
-- count(case when battle_result = 2 and battle_time = '3较难' and remain_hp <> 0  then start_time else null end) as '主动退出3较难次数',
-- count(case when battle_result = 2 and battle_time = '4一般' and remain_hp <> 0  then start_time else null end) as '主动退出4一般次数',
-- count(case when battle_result = 2 and remain_hp <> 0 and battle_time <> '1超时' then start_time else null end) as '主动退出汇总次数',
-- count(case when auto_battle is null then b.role_id else null end) as '无日志次数',
-- count(distinct start_time) as '总次数'

from

(  --新增
select role_id,birth_dt,country
from
(select role_id,device_id,to_date(hours_add(date_time,-18)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name ='1.5.0'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(hours_add(date_time,-18)) as device_birth_dt, 
     case when country in ('PH','MY') then 'PH+MY'
     when country in ('GB','IE','CA')  then 'GB+CA'
     end as country
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name ='1.5.0'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id --and a1.birth_dt = a2.device_birth_dt
) as a


 -- 进入关卡人数、通关率
left join
 -- 关卡参与情况
(select a.dungeon_id,a.role_id,a.start_time,battle_result,battle_time,auto_battle,done_dt,suppression
from 
(select dungeon_id,role_id,start_time,to_date(hours_add(date_time,-18)) as done_dt
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 2
and channel_id=1000  --Android
and version_name ='1.5.0'
and country not in ('CN','HK')
group by 1,2,3,4
) as a
left join     
(select dungeon_id,role_id,start_time,battle_result,battle_time,auto_battle,
        case when suppression = 2 then '绿色'
             when suppression >= 3 and suppression <= 13 then '白色'
             when suppression >= 14 and suppression <= 23 then '黄色'
             when suppression >= 24 and suppression <= 53 then '橙色'
             when suppression >= 54 and suppression <= 83 then '红色'
        end as suppression
from myth_server.server_dungeon_end
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 2 
and channel_id=1000  --Android
and version_name ='1.5.0'
and country not in ('CN','HK')
group by 1,2,3,4,5,6,7
) c 
on a.dungeon_id=c.dungeon_id and a.role_id=c.role_id and a.start_time=c.start_time 
) as b 
on a.role_id = b.role_id and datediff(done_dt,birth_dt) <=${lifeTime}-1
where b.role_id is not null 
group by 1 order by 1


-- left join
-- -- 重复进入（复玩）人数
-- (select role_id,dungeon_id,done_dt
-- from
-- (select dungeon_id,role_id,to_date(hours_add(date_time,-18)) as done_dt,count(distinct start_time) as '进入次数'
-- from myth_server.server_enter_dungeon
-- where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
-- and game_type = 2 
-- and channel_id=1000  --Android
-- and version_name ='1.5.0'
-- and country not in ('CN','HK')
-- group by 1,2,3
-- ) c1
-- where 进入次数 > 1
-- group by 1,2,3 
-- ) as e
-- on a.role_id = e.role_id
-- where datediff(done_dt,birth_dt) <=${lifeTime}-1
-- group by 1 order by 1




-- -- 重复进入（复玩）最终通关人数
-- left join
-- (select d.role_id,d.dungeon_id,d.done_dt
-- from
-- (select role_id,dungeon_id,done_dt
-- from
-- (select dungeon_id,role_id,to_date(hours_add(date_time,-18)) as done_dt,count(distinct start_time) as '进入次数'
-- from myth_server.server_enter_dungeon
-- where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
-- and game_type = 2 
-- and channel_id=1000  --Android
-- and version_name ='1.5.0'
-- and country not in ('CN','HK')
-- group by 1,2,3
-- ) c1
-- where 进入次数 > 1
-- group by 1,2,3 
-- ) as c
-- left join 
-- (select a.role_id as role_id,done_dt,a.dungeon_id as dungeon_id,battle_result
-- from
-- (select dungeon_id,role_id,to_date(hours_add(date_time,-18)) as done_dt,start_time
-- from myth_server.server_enter_dungeon
-- where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
-- and game_type = 2 
-- and channel_id=1000  --Android
-- and version_name ='1.5.0'
-- and country not in ('CN','HK')
-- group by 1,2,3,4) a 
-- left join 
-- (select dungeon_id,role_id,battle_result,log_time,start_time
-- from myth_server.server_dungeon_end
-- where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
-- and game_type = 2 
-- and channel_id=1000  --Android
-- and version_name ='1.5.0'
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
-- where datediff(f.done_dt,a.birth_dt) <=${lifeTime}-1
-- group by 1
-- order by 1




-- left join 
-- -- 时长 通关-死亡-主动退出remain_hp 是否为0
-- (select dungeon_id,role_id,start_time,battle_result,battle_time,auto_battle,done_dt,cast(split_part(remain_hp,',',1) as int) as remain_hp
-- from
-- (select a.dungeon_id,a.role_id,a.start_time,battle_result,battle_time,auto_battle,done_dt,remain_hp
-- from 
-- (select dungeon_id,role_id,start_time,to_date(hours_add(date_time,-18)) as done_dt
-- from myth_server.server_enter_dungeon
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and game_type = 2 
-- and channel_id=1000  --Android
-- and version_name ='1.5.0'
-- and country not in ('CN','HK')
-- group by 1,2,3,4
-- ) as a
-- left join     
-- (select dungeon_id,role_id,start_time,battle_result,
--         case when battle_time is null then '无日志'
--              when battle_time/60 >=2  then '1超时'
--              when battle_time/60 >=1   and battle_time/60 < 2     then '2困难'
--              when battle_time/60 >=0.5 and battle_time/60 < 1   then '3较难'
--              when battle_time/60 >=0   and battle_time/60 < 0.5  then '4一般'
--              else '无日志'
--         end as battle_time,auto_battle,remain_hp
-- from myth_server.server_dungeon_end
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and game_type = 2
-- and channel_id=1000  --Android
-- and version_name ='1.5.0'
-- and country not in ('CN','HK')
-- group by 1,2,3,4,5,6,7
-- ) b 
-- on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time=b.start_time
-- order by a.role_id,a.start_time asc 
-- ) as e  
-- group by 1,2,3,4,5,6,7,8
-- ) as b 
-- on a.role_id = b.role_id

-- where datediff(done_dt,birth_dt) < ${lifeTime}
-- group by 1
-- order by 1




活跃活跃用户，16、17两天活跃的用户
select dungeon_id,

-- 战力压制 按照颜色 只算俩数据
count(distinct case when suppression = '绿色' then start_time else null end) as '绿色进入关卡次数',
count(distinct case when battle_result=1 and suppression = '绿色' then b.role_id else null end ) / count(distinct case when suppression = '绿色' then start_time else null end) as '绿色通关率',
count(distinct case when suppression = '白色' then start_time else null end) as '白色进入关卡次数',
count(distinct case when battle_result=1 and suppression = '白色' then b.role_id else null end ) / count(distinct case when suppression = '白色' then start_time else null end) as '白色通关率',
count(distinct case when suppression = '黄色' then start_time else null end) as '黄色进入关卡次数',
count(distinct case when battle_result=1 and suppression = '黄色' then b.role_id else null end ) / count(distinct case when suppression = '黄色' then start_time else null end) as '黄色通关率',
count(distinct case when suppression = '橙色' then start_time else null end) as '橙色进入关卡次数',
count(distinct case when battle_result=1 and suppression = '橙色' then b.role_id else null end ) / count(distinct case when suppression = '橙色' then start_time else null end) as '橙色通关率',
count(distinct case when suppression = '红色' then start_time else null end) as '红色进入关卡次数',
count(distinct case when battle_result=1 and suppression = '红色' then b.role_id else null end ) / count(distinct case when suppression = '红色' then start_time else null end) as '红色通关率',
--整体
count(distinct a.role_id) as '进入关卡人数',
count(distinct case when battle_result=1 then b.role_id else null end ) as '通关人数',
count(distinct case when battle_result=1 then b.role_id else null end ) / count(distinct a.role_id) as '通关率',
count(distinct case when battle_result=2 then b.role_id else null end ) as '失败人数',
count(distinct case when battle_result=2 then b.role_id else null end ) / count(distinct a.role_id) as '失败率',
count(distinct case when battle_result is null then b.role_id else null end ) as '无日志人数',
count(distinct case when battle_result is null then b.role_id else null end ) / count(distinct a.role_id) as '无日志率'

-- 复玩人数
-- count(distinct e.role_id)

-- 复玩通关人数 
 -- count(distinct f.role_id)


-- 时长 通关-死亡-主动退出remain_hp 是否为0
-- count(distinct case when battle_result = 2 and remain_hp = 0 then a.role_id else null end) as '死亡人数',
-- count(distinct case when battle_result = 2 and battle_time = '1超时' then a.role_id else null end) as '超时人数',
-- count(distinct case when battle_result = 2 and remain_hp <> 0 and battle_time <> '1超时' then a.role_id else null end) as '主动退出人数',
-- count(case when battle_result = 1 and battle_time = '1超时' then start_time else null end) as '通关1超时次数',
-- count(case when battle_result = 1 and battle_time = '2困难' then start_time else null end) as '通关2困难次数',
-- count(case when battle_result = 1 and battle_time = '3较难' then start_time else null end) as '通关3较难次数',
-- count(case when battle_result = 1 and battle_time = '4一般' then start_time else null end) as '通关4一般次数',
-- count(case when battle_result = 1 then start_time else null end) as '通关汇总次数',
-- count(case when battle_result = 2 and battle_time = '1超时' and remain_hp = 0 then start_time else null end) as '死亡1超时次数',
-- count(case when battle_result = 2 and battle_time = '2困难' and remain_hp = 0 then start_time else null end) as '死亡2困难次数',
-- count(case when battle_result = 2 and battle_time = '3较难' and remain_hp = 0 then start_time else null end) as '死亡3较难次数',
-- count(case when battle_result = 2 and battle_time = '4一般' and remain_hp = 0 then start_time else null end) as '死亡4一般次数',
-- count(case when battle_result = 2 and remain_hp = 0  then start_time else null end) as '死亡汇总次数',
-- count(case when battle_result = 2 and remain_hp <> 0 and battle_time = '1超时'  then start_time else null end) as '超时未通关次数',
-- count(case when battle_result = 2 and battle_time = '2困难' and remain_hp <> 0  then start_time else null end) as '主动退出2困难次数',
-- count(case when battle_result = 2 and battle_time = '3较难' and remain_hp <> 0  then start_time else null end) as '主动退出3较难次数',
-- count(case when battle_result = 2 and battle_time = '4一般' and remain_hp <> 0  then start_time else null end) as '主动退出4一般次数',
-- count(case when battle_result = 2 and remain_hp <> 0 and battle_time <> '1超时' then start_time else null end) as '主动退出汇总次数',
-- count(case when auto_battle is null then b.role_id else null end) as '无日志次数',
-- count(distinct start_time) as '总次数'

from


 -- 进入关卡人数、通关率
(select a.dungeon_id,a.role_id,a.start_time,battle_result,battle_time,auto_battle,done_dt,suppression
from 
(select dungeon_id,role_id,start_time,to_date(hours_add(date_time,-18)) as done_dt
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 2
and channel_id=1000  --Android
and version_name ='1.5.0'
and country not in ('CN','HK')
group by 1,2,3,4
) as a
left join     
(select dungeon_id,role_id,start_time,battle_result,battle_time,auto_battle,
        case when suppression = 2 then '绿色'
             when suppression >= 3 and suppression <= 13 then '白色'
             when suppression >= 14 and suppression <= 23 then '黄色'
             when suppression >= 24 and suppression <= 53 then '橙色'
             when suppression >= 54 and suppression <= 83 then '红色'
        end as suppression
from myth_server.server_dungeon_end
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 2 
and channel_id=1000  --Android
and version_name ='1.5.0'
and country not in ('CN','HK')
group by 1,2,3,4,5,6,7
) c 
on a.dungeon_id=c.dungeon_id and a.role_id=c.role_id and a.start_time=c.start_time 
) as b 
where b.role_id is not null 
group by 1 order by 1



-- -- 重复进入（复玩）人数
-- (select role_id,dungeon_id,done_dt
-- from
-- (select dungeon_id,role_id,to_date(hours_add(date_time,-18)) as done_dt,count(distinct start_time) as '进入次数'
-- from myth_server.server_enter_dungeon
-- where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
-- and game_type = 2 
-- and channel_id=1000  --Android
-- and version_name ='1.5.0'
-- and country not in ('CN','HK')
-- group by 1,2,3
-- ) c1
-- where 进入次数 > 1
-- group by 1,2,3 
-- ) as e
-- group by 1 order by 1




-- -- 重复进入（复玩）最终通关人数
-- (select d.role_id,d.dungeon_id,d.done_dt
-- from
-- (select role_id,dungeon_id,done_dt
-- from
-- (select dungeon_id,role_id,to_date(hours_add(date_time,-18)) as done_dt,count(distinct start_time) as '进入次数'
-- from myth_server.server_enter_dungeon
-- where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
-- and game_type = 2 
-- and channel_id=1000  --Android
-- and version_name ='1.5.0'
-- and country not in ('CN','HK')
-- group by 1,2,3
-- ) c1
-- where 进入次数 > 1
-- group by 1,2,3 
-- ) as c
-- left join 
-- (select a.role_id as role_id,done_dt,a.dungeon_id as dungeon_id,battle_result
-- from
-- (select dungeon_id,role_id,to_date(hours_add(date_time,-18)) as done_dt,start_time
-- from myth_server.server_enter_dungeon
-- where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
-- and game_type = 2 
-- and channel_id=1000  --Android
-- and version_name ='1.5.0'
-- and country not in ('CN','HK')
-- group by 1,2,3,4) a 
-- left join 
-- (select dungeon_id,role_id,battle_result,log_time,start_time
-- from myth_server.server_dungeon_end
-- where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
-- and game_type = 2 
-- and channel_id=1000  --Android
-- and version_name ='1.5.0'
-- and country not in ('CN','HK')
-- group by 1,2,3,4,5) b 
-- on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time = b.start_time
-- where battle_result = 1 -- 有成功日志的
-- group by 1,2,3,4
-- ) as d 
-- on c.dungeon_id=d.dungeon_id and c.role_id=d.role_id and c.done_dt=d.done_dt
-- group by 1,2,3
-- ) as f 
-- group by 1 order by 1




-- left join 
-- -- 时长 通关-死亡-主动退出remain_hp 是否为0
-- (select dungeon_id,role_id,start_time,battle_result,battle_time,auto_battle,done_dt,cast(split_part(remain_hp,',',1) as int) as remain_hp
-- from
-- (select a.dungeon_id,a.role_id,a.start_time,battle_result,battle_time,auto_battle,done_dt,remain_hp
-- from 
-- (select dungeon_id,role_id,start_time,to_date(hours_add(date_time,-18)) as done_dt
-- from myth_server.server_enter_dungeon
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and game_type = 2 
-- and channel_id=1000  --Android
-- and version_name ='1.5.0'
-- and country not in ('CN','HK')
-- group by 1,2,3,4
-- ) as a
-- left join     
-- (select dungeon_id,role_id,start_time,battle_result,
--         case when battle_time is null then '无日志'
--              when battle_time/60 >=2  then '1超时'
--              when battle_time/60 >=1   and battle_time/60 < 2     then '2困难'
--              when battle_time/60 >=0.5 and battle_time/60 < 1   then '3较难'
--              when battle_time/60 >=0   and battle_time/60 < 0.5  then '4一般'
--              else '无日志'
--         end as battle_time,auto_battle,remain_hp
-- from myth_server.server_dungeon_end
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and game_type = 2
-- and channel_id=1000  --Android
-- and version_name ='1.5.0'
-- and country not in ('CN','HK')
-- group by 1,2,3,4,5,6,7
-- ) b 
-- on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time=b.start_time
-- order by a.role_id,a.start_time asc 
-- ) as e  
-- group by 1,2,3,4,5,6,7,8
-- ) as b 
-- on a.role_id = b.role_id
-- group by 1 order by 1
