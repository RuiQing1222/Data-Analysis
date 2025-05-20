----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
勇者试炼


select a.role_id,grade_num,difficulty,level_zone
from
-- 玩法参与
(select role_id,start_time,dungeon_id
from
(select role_id,start_time,dungeon_id,row_number() over(partition by role_id order by log_time desc) as num
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and game_type = 17
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and cycle_id = ${ID}
) as a1
where num = 1
group by 1,2,3
) as a

left join
(select role_id,grade_num,scene_id,difficulty,level_zone,auto_battle,battle_result,battle_time,时长分布,start_time,log_time
from
(
select role_id,grade_num,scene_id,difficulty,level_zone,auto_battle,battle_result,battle_time,
       case when battle_time is null then '无日志'
            when battle_time > 40 then '40+'
            when battle_time > 30 and battle_time <= 40  then '(30-40]'
            when battle_time > 20 and battle_time <= 30  then '(20-30]'
            when battle_time > 15 and battle_time <= 20  then '(15-20]'
            when battle_time > 10 and battle_time <= 15  then '(10-15]'
            when battle_time >= 0 and battle_time <= 10  then '[0-10]'
       end as '时长分布',start_time*1000 as start_time,log_time       
from myth_server.server_endless_abyss_junior  
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and cycle_id = ${ID}
union all
select role_id,grade_num+100 as grade_num,scene_id,difficulty,level_zone,auto_battle,battle_result,battle_time,
       case when battle_time is null then '无日志'
            when battle_time > 40 then '40+'
            when battle_time > 30 and battle_time <= 40  then '(30-40]'
            when battle_time > 20 and battle_time <= 30  then '(20-30]'
            when battle_time > 15 and battle_time <= 20  then '(15-20]'
            when battle_time > 10 and battle_time <= 15  then '(10-15]'
            when battle_time >= 0 and battle_time <= 10  then '[0-10]'
       end as '时长分布',start_time*1000 as start_time,log_time  
from myth_server.server_endless_abyss_senior
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and cycle_id = ${ID}
) as b1
group by 1,2,3,4,5,6,7,8,9,10,11
) as b
on a.role_id = b.role_id and a.dungeon_id = b.scene_id and a.start_time = b.start_time 
group by 1,2,3,4










英灵试炼  玩法留存/复玩率
二周期 20230106 - 20230108
三周期 20230110 - 20230112
四周期 20230113 - 20230115
五周期 20230117 - 20230119
六周期 20230120 - 20230122
七周期 20230124 - 20230126

登录
select case when b.role_id is null then 0 else 1 end as tag,count(distinct a.role_id)
from 
(select role_id
from myth_server.server_enter_dungeon
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and game_type = 17
and cycle_id = 1
group by 1) a 
left join 
(
select role_id
from myth.server_role_login 
where day_time>=${begin2Date} and day_time<=${end2Date} 
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1) b 
on a.role_id=b.role_id
group by 1


复玩
select case when b.role_id is null then 0 else 1 end as tag,count(distinct a.role_id)
from 
(select role_id
from myth_server.server_enter_dungeon
where server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and game_type = 17
and cycle_id = ${ID1}
group by 1) a 
left join 
(
select role_id
from myth_server.server_enter_dungeon
where server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and game_type = 17
and cycle_id = ${ID2}
group by 1) b 
on a.role_id=b.role_id
group by 1















-- select cycle_id,level_zone,difficulty,dungeon_id,标签,
--        count(distinct role_id) as '参与人数',
--        count(1) as '参与次数',
--        count(1) / count(distinct role_id) as '人均参与次数',
--        round(count(distinct case when battle_result = 1 then role_id else null end) / count(distinct role_id),2) as '通关率',
--        round(count(case when battle_result is null then 1 else 0 end) / count(distinct start_time),2) as '无日志率',
--        round(sum(battle_time) / count(distinct role_id),2) as '人均时长',
--        count(distinct case when auto_battle = 1 then 1 else 0 end) as '自动次数',
--        count(distinct case when auto_battle = 0 then 1 else 0 end) as '手动次数',
--        count(distinct case when 时长分布 = '[0-10]' then 1 else 0 end) as '[0-10]次数',
--        count(distinct case when 时长分布 = '(10-15]' then 1 else 0 end) as '(10-15]次数',
--        count(distinct case when 时长分布 = '(15-20]' then 1 else 0 end) as '(15-20]次数',
--        count(distinct case when 时长分布 = '(20-30]' then 1 else 0 end) as '(20-30]次数',
--        count(distinct case when 时长分布 = '(30-40]' then 1 else 0 end) as '(30-40]次数',
--        count(distinct case when 时长分布 = '40+' then 1 else 0 end) as '40+次数'
-- from
-- -- 参与人数 人均参与次数 通关率 无日志率 人均时长 自动次数 手动次数 时长分布
-- (select a.role_id,a.cycle_id,b.dungeon_id,a.start_time,auto_battle,battle_result,battle_time,时长分布,difficulty,level_zone,标签
-- from

-- -- 玩法参与
-- (select role_id,cycle_id,start_time,scene_id
-- from myth_server.server_enter_dungeon
-- where day_time between ${beginDate} and ${endDate} 
-- and server_id in (${serverIds})
-- and game_type = 17
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- group by 1,2,3,4
-- ) as a


-- -- 参与人数 人均参与次数 通关率 无日志率 人均时长 自动次数 手动次数 时长分布
-- left join
-- (
-- select role_id,cycle_id,dungeon_id,scene_id,auto_battle,battle_result,battle_time,时长分布,start_time,difficulty,level_zone,标签
-- from
-- (select role_id,cycle_id,dungeon_id,scene_id,auto_battle,battle_result,battle_time,时长分布,start_time,difficulty,level_zone,标签,row_number() over(partition by role_id,cycle_id order by log_time desc) as num -- 周期最高层数
-- from
-- (
-- select role_id,cycle_id,grade_num as dungeon_id,scene_id,auto_battle,battle_result,battle_time,
--        case when battle_time is null then '无日志'
--             when battle_time > 40 then '40+'
--             when battle_time > 30 and battle_time <= 40  then '(30-40]'
--             when battle_time > 20 and battle_time <= 30  then '(20-30]'
--             when battle_time > 15 and battle_time <= 20  then '(15-20]'
--             when battle_time > 10 and battle_time <= 15  then '(10-15]'
--             when battle_time >= 0 and battle_time <= 10  then '[0-10]'
--        end as '时长分布',
--        start_time,log_time,difficulty,level_zone,'普通' as '标签'         
-- from myth_server.server_endless_abyss_junior  
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- union all
-- select role_id,cycle_id,grade_num+100 as dungeon_id,scene_id
--             ,auto_battle,battle_result,battle_time,
--        case when battle_time is null then '无日志'
--             when battle_time > 40 then '40+'
--             when battle_time > 30 and battle_time <= 40  then '(30-40]'
--             when battle_time > 20 and battle_time <= 30  then '(20-30]'
--             when battle_time > 15 and battle_time <= 20  then '(15-20]'
--             when battle_time > 10 and battle_time <= 15  then '(10-15]'
--             when battle_time >= 0 and battle_time <= 10  then '[0-10]'
--        end as '时长分布',
--             start_time,log_time,difficulty,level_zone,'深渊' as '标签'    
-- from myth_server.server_endless_abyss_senior
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- ) as b1
-- ) as b2
-- where num = 1
-- group by 1,2,3,4,5,6,7,8,9,10,11,12
-- ) as b
-- on a.cycle_id = b.cycle_id and a.scene_id = b.scene_id and a.role_id = b.role_id and a.start_time=b.start_time
-- group by 1,2,3,4,5,6,7,8,9,10,11
-- ) as new
-- group by 1,2,3,4,5
-- order by 1,2,3,4,5








-- 天复玩率
-- select cycle_id,dungeon_id,difficulty,level_zone,count(distinct a.role_id) as '总人数',count(distinct case when b.role_id is not null then a.role else null end) as '复玩人数'
-- from
-- (
-- select role_id,cycle_id,dungeon_id,difficulty,level_zone,done_dt
-- from
-- (select role_id,cycle_id,dungeon_id,difficulty,level_zone,done_dt,row_number() over(partition by role_id,cycle_id order by log_time desc) as num -- 周期最高层数
-- from
-- (
-- select role_id,cycle_id,grade_num as dungeon_id,difficulty,level_zone,to_date(cast(date_time as timestamp)) as done_dt,log_time      
-- from myth_server.server_endless_abyss_junior  
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- union all
-- select role_id,cycle_id,
--        case when grade_num = 1 then 8
--             when grade_num = 2 then 9
--             when grade_num = 3 then 10
--             when grade_num = 4 then 11
--             when grade_num = 5 then 12
--           end as dungeon_id,difficulty,level_zone,to_date(cast(date_time as timestamp)) as done_dt,log_time
-- from myth_server.server_endless_abyss_senior
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- ) as a1
-- ) as a2
-- group by 1,2,3,4,5,6
-- where num = 1
-- ) as a

-- left join
-- (select role_id,to_date(cast(date_time as timestamp)) as enter_dt
-- from myth_server.server_enter_dungeon
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- and game_type = 17
-- group by 1,2
-- ) as b
-- on a.role_id = b.role_id
-- where datediff(enter_dt,done_dt)=1


