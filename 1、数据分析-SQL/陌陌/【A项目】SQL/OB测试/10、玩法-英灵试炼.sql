----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
英灵试炼(勇者试炼)
 

-- select difficulty,level_zone,dungeon_id,count(distinct role_id) as '参与人数', 
-- count(1) as '参与次数',
-- count(case when battle_result = 1 then 1 else null end ) as '胜利次数',
-- count(case when hp ='死亡' then 1 else null end ) as '死亡次数',
-- count(case when battle_result =2  then 1 else null end ) as '死亡/主动退出/超时次数',
-- count(case when auto_battle =1   then 1 else null end ) as '自动次数',
-- count(case when auto_battle =0   then 1 else null end ) as '手动次数',
-- count(case when 时长 ='[0-20]' and battle_result =1    then 1 else null end) as '通关[0-20]',
-- count(case when 时长 ='(20-40]' and battle_result =1   then 1 else null end) as '通关(20-40]',
-- count(case when 时长 ='(40-80]' and battle_result =1   then 1 else null end) as '通关(40-80]',
-- count(case when 时长 ='(80-120]' and battle_result =1  then 1 else null end) as '通关(80-120]',
-- count(case when 时长 ='(120-160]' and battle_result =1  then 1 else null end) as '通关(120-160]',
-- count(case when 时长 ='160+'     and battle_result =1   then 1 else null end) as '通关160+',
-- count(case when 时长 ='[0-20]' and battle_result =2    and hp='死亡'  then 1 else null end) as '死亡[0-20]',
-- count(case when 时长 ='(20-40]' and battle_result =2   and hp='死亡'  then 1 else null end) as '死亡(20-40]',
-- count(case when 时长 ='(40-80]' and battle_result =2   and hp='死亡'  then 1 else null end) as '死亡(40-80]',
-- count(case when 时长 ='(80-120]' and battle_result =2  and hp='死亡' then 1 else null end) as '死亡(80-120]',
-- count(case when 时长 ='(120-160]' and battle_result =2 and hp='死亡' then 1 else null end) as '死亡(120-160]',
-- count(case when 时长 ='160+'     and battle_result =2  and hp='死亡' then 1 else null end) as '死亡160+',
-- count(case when 时长 ='[0-20]' and battle_result =2    and hp<>'死亡'  then 1 else null end) as '主动退出[0-20]',
-- count(case when 时长 ='(20-40]' and battle_result =2   and hp<>'死亡'  then 1 else null end) as '主动退出(20-40]',
-- count(case when 时长 ='(40-80]' and battle_result =2   and hp<>'死亡'  then 1 else null end) as '主动退出(40-80]',
-- count(case when 时长 ='(80-120]' and battle_result =2  and hp<>'死亡' then 1 else null end) as '主动退出(80-120]',
-- count(case when 时长 ='(120-160]' and battle_result =2 and hp<>'死亡' then 1 else null end) as '主动退出(120-160]',
-- count(case when 时长 ='160+'     and battle_result =2  and hp<>'死亡' then 1 else null end) as '超时160+',
-- appx_median(battle_time) as '时长中文数',
-- appx_median(case when battle_result =1 then battle_time  else null end) as '通关时长中位数'
-- from 
-- (select dungeon_id,a.role_id,difficulty,
-- case when tag_level< 60                      then 1 
--      when tag_level>=60   and tag_level<90   then 2
--      when tag_level>=90   and tag_level<120  then 3 
--      when tag_level>=120  and tag_level<150  then 4
--      when tag_level>=150  and tag_level<180  then 5 
--      when tag_level>=180  and tag_level<210  then 6
--      when tag_level>=210  and tag_level<240  then 7
--      when tag_level>=240  and tag_level<270  then 8
--      when tag_level>=270  and tag_level<300  then 9
--      when tag_level=300                      then 10
--      end as level_zone
--     ,auto_battle,battle_result,battle_time,
-- case when remain_hp = 0  then '死亡'
--      when remain_hp is null then '无日志'
--      else '主动退出或超时'
--      end as hp,
--        case when battle_time is null then '无日志'
--             when battle_time > 160 then '160+'
--             when battle_time > 120 and battle_time <= 160  then '(120-160]'
--             when battle_time > 80 and battle_time <= 120  then '(80-120]'
--             when battle_time > 40 and battle_time <= 80  then '(40-80]'
--             when battle_time > 20 and battle_time <= 40  then '(20-40]'
--             when battle_time >= 0 and battle_time <= 20  then '[0-20]'
--             end as '时长'
-- from 
-- (select a.cycle_id,a.role_id,start_time,dungeon_id,a.role_level as tag_level
-- from 
-- (select cycle_id,role_id,max(role_level) as role_level
--     from 
-- (select cycle_id,role_id,role_level,duration,rank()over(partition by cycle_id,role_id order by duration asc) as rank
-- from 
-- (select cycle_id,a.role_id,role_level,
-- case when cycle_id=2 then log_time-1679004000000 
--      when cycle_id=3 then log_time-1679306400000
--      when cycle_id=4 then log_time-1679608800000
-- end as duration
-- from 
-- (select role_id,cycle_id
-- from myth_server.server_enter_dungeon
-- where day_time>=${beginDate} and day_time<=${endDate}
-- and channel_id=1000  --Android
-- and server_id in (${serverIds}) 
-- and version_name ='1.5.0'
-- and country not in ('CN','HK')
-- and game_type =17
-- and cycle_id in (25,26,27,28,29)
-- group by 1,2 
-- ) a 

-- left join 

-- (select role_id,role_level,log_time
-- from myth.server_role_upgrade
-- where  day_time>=${startDate} and day_time<=${endDate}
-- and channel_id=1000  --Android
-- and server_id in (${serverIds}) 
-- and version_name ='1.5.0'
-- and country not in ('CN','HK')
-- union all 
-- select role_id,role_level,log_time 
-- from myth.server_role_login 
-- where day_time>=${startDate} and day_time<=${endDate}
-- and channel_id=1000  --Android
-- and country not in ('CN','HK')
-- and version_name ='1.4.7'
-- union all 
-- select role_id,role_level,log_time 
-- from myth_server.server_enter_dungeon 
-- where day_time>=${startDate} and day_time<=${endDate}
-- and channel_id=1000  --Android
-- and country not in ('CN','HK')
-- and version_name ='1.4.7'
-- )  b  
-- on a.role_id = b.role_id
-- ) a1 
-- where duration>0
-- ) a2
-- where rank=1 
-- group by 1,2 ) a 
-- left join 
-- (select cycle_id,role_id,start_time,dungeon_id
-- from myth_server.server_enter_dungeon
-- where day_time>=${beginDate} and day_time<=${endDate}
-- and channel_id=1000  --Android
-- and server_id in (${serverIds}) 
-- and version_name ='1.4.7'
-- and country not in ('CN','HK')
-- and game_type =17
-- and cycle_id in (25,26,27,28,29)
-- ) b  
-- on a.role_id = b.role_id and a.cycle_id = b.cycle_id
-- ) a 
-- left join 

-- -- (
-- -- select role_id,start_time,cast(difficulty as int) as difficulty,grade_num+100 as grade_num,cast(split_part(remain_hp,',',1) as int) as remain_hp,
-- -- auto_battle,battle_result,battle_time
-- -- from myth_server.server_endless_abyss_junior
-- -- where day_time>=${beginDate} and day_time<=${endDate}
-- -- and channel_id=1000  --Android
-- -- and server_id in (${serverIds}) 
-- -- and version_name ='1.4.7'
-- -- and country not in ('CN','HK')
-- -- and cycle_id in (25,26,27,28,29)
-- -- ) b 

-- (
-- select role_id,start_time,cast(difficulty as int) as difficulty,level_zone,grade_num+200 as grade_num,cast(split_part(remain_hp,',',1) as int) as remain_hp,
-- auto_battle,battle_result,battle_time
-- from myth_server.server_endless_abyss_senior
-- where day_time>=${beginDate} and day_time<=${endDate}
-- and channel_id=1000  --Android
-- and server_id in (${serverIds}) 
-- and version_name ='1.4.7'
-- and country not in ('CN','HK')
-- and cycle_id in (25,26,27,28,29)
-- ) b  

-- on a.start_time=b.start_time and a.role_id =b.role_id and a.dungeon_id =b.grade_num
-- ) t 
-- group by 1,2,3





 




参与人数/次数/胜率/时长
 
select theme_id,difficulty,level_zone,dungeon_id,count(distinct role_id) as '参与人数', 
count(1) as '参与次数',
count(case when battle_result = 1 then 1 else null end ) as '胜利次数',
count(case when hp ='死亡' then 1 else null end ) as '死亡次数',
count(case when battle_result =2  then 1 else null end ) as '死亡/主动退出/超时次数',
appx_median(battle_time) as '时长中位数',
appx_median(case when battle_result =1 then battle_time  else null end) as '通关时长中位数',
count(case when auto_battle =1   then 1 else null end ) as '自动次数',
count(case when auto_battle =0   then 1 else null end ) as '手动次数',
count(case when 时长 ='[0-20]' and battle_result =1    then 1 else null end) as '通关[0-20]',
count(case when 时长 ='(20-40]' and battle_result =1   then 1 else null end) as '通关(20-40]',
count(case when 时长 ='(40-80]' and battle_result =1   then 1 else null end) as '通关(40-80]',
count(case when 时长 ='(80-120]' and battle_result =1  then 1 else null end) as '通关(80-120]',
count(case when 时长 ='(120-160]' and battle_result =1  then 1 else null end) as '通关(120-160]',
count(case when 时长 ='160+'     and battle_result =1   then 1 else null end) as '通关160+',
count(case when 时长 ='[0-20]' and battle_result =2    and hp='死亡'  then 1 else null end) as '死亡[0-20]',
count(case when 时长 ='(20-40]' and battle_result =2   and hp='死亡'  then 1 else null end) as '死亡(20-40]',
count(case when 时长 ='(40-80]' and battle_result =2   and hp='死亡'  then 1 else null end) as '死亡(40-80]',
count(case when 时长 ='(80-120]' and battle_result =2  and hp='死亡' then 1 else null end) as '死亡(80-120]',
count(case when 时长 ='(120-160]' and battle_result =2 and hp='死亡' then 1 else null end) as '死亡(120-160]',
count(case when 时长 ='160+'     and battle_result =2  and hp='死亡' then 1 else null end) as '死亡160+',
count(case when 时长 ='[0-20]' and battle_result =2    and hp<>'死亡'  then 1 else null end) as '主动退出[0-20]',
count(case when 时长 ='(20-40]' and battle_result =2   and hp<>'死亡'  then 1 else null end) as '主动退出(20-40]',
count(case when 时长 ='(40-80]' and battle_result =2   and hp<>'死亡'  then 1 else null end) as '主动退出(40-80]',
count(case when 时长 ='(80-120]' and battle_result =2  and hp<>'死亡' then 1 else null end) as '主动退出(80-120]',
count(case when 时长 ='(120-160]' and battle_result =2 and hp<>'死亡' then 1 else null end) as '主动退出(120-160]',
count(case when 时长 ='160+'     and battle_result =2  and hp<>'死亡' then 1 else null end) as '超时160+'

from 
(select theme_id,dungeon_id,a.role_id,difficulty,level_zone,auto_battle,battle_result,battle_time,
case when remain_hp = 0  then '死亡'
     when remain_hp is null then '无日志'
     else '主动退出或超时'
     end as hp,
       case when battle_time is null then '无日志'
            when battle_time > 160 then '160+'
            when battle_time > 120 and battle_time <= 160  then '(120-160]'
            when battle_time > 80 and battle_time <= 120  then '(80-120]'
            when battle_time > 40 and battle_time <= 80  then '(40-80]'
            when battle_time > 20 and battle_time <= 40  then '(20-40]'
            when battle_time >= 0 and battle_time <= 20  then '[0-20]'
            end as '时长'
from 
(select role_id,start_time,dungeon_id
from myth_server.server_enter_dungeon
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id=1000  --Android
and server_id in (${serverIds}) 
and version_name ='1.5.0'
and country not in ('CN','HK')
and game_type =17
--and cycle_id in (25,26,27,28,29)
) a 
left join 

(
select role_id,theme_id,start_time,cast(difficulty as int) as difficulty,level_zone,grade_num+100 as grade_num,cast(split_part(remain_hp,',',1) as int) as remain_hp,
auto_battle,battle_result,battle_time
from myth_server.server_endless_abyss_junior
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id=1000  --Android
and server_id in (${serverIds}) 
and version_name ='1.5.0'
and country not in ('CN','HK')
and cycle_id in (25,26,27,28,29)
) b 

-- (
-- select role_id,theme_id,start_time,cast(difficulty as int) as difficulty,level_zone,grade_num+200 as grade_num,cast(split_part(remain_hp,',',1) as int) as remain_hp,
-- auto_battle,battle_result,battle_time
-- from myth_server.server_endless_abyss_senior
-- where day_time>=${beginDate} and day_time<=${endDate}
-- and channel_id=1000  --Android
-- and server_id in (${serverIds}) 
-- and version_name ='1.5.0'
-- and country not in ('CN','HK')
-- and cycle_id in (25,26,27,28,29)
-- ) b  

on a.start_time=b.start_time and a.role_id =b.role_id and a.dungeon_id =b.grade_num
) t 
group by 1,2,3,4






-- 天复玩率

-- select datediff(done_dt,abyss_dt)+1 as datediffs,difficulty,level_zone,grade_num,count(distinct a.role_id)
-- from 
-- (select a.abyss_dt,difficulty,level_zone,grade_num,a.role_id

-- from 
-- (select to_date(date_time) as abyss_dt,cycle_id,role_id,start_time,dungeon_id
-- from myth_server.server_enter_dungeon
-- where day_time>=${beginDate} and day_time<=${endDate}
-- and channel_id=1000  --Android
-- and server_id in (${serverIds}) 
-- and version_name ='1.5.0'
-- and country not in ('CN','HK')
-- and game_type =17
-- and cycle_id in (25,26,27,28,29)
-- ) a 
-- left join 
-- (
-- select to_date(date_time) as abyss_dt,cycle_id,role_id,start_time,cast(difficulty as int) as difficulty,level_zone,grade_num+100 as grade_num
-- --grade_num+200 as grade_num,
-- from myth_server.server_endless_abyss_junior
-- --from myth_server.server_endless_abyss_senior
-- where day_time>=${beginDate} and day_time<=${endDate}
-- and channel_id=1000  --Android
-- and server_id in (${serverIds}) 
-- and version_name ='1.5.0'
-- and country not in ('CN','HK')
-- and cycle_id in (25,26,27,28,29)
-- ) b 
-- on a.start_time=b.start_time and a.role_id =b.role_id and a.dungeon_id =b.grade_num
-- group by 1,2,3,4,5,6
-- ) a 
-- left join 
-- (
-- select  role_id,to_date(date_time) as done_dt
-- from myth_server.server_enter_dungeon
-- where day_time>=${beginDate} and day_time<=${endDate}
-- and channel_id=1000  --Android
-- and server_id in (${serverIds}) 
-- and version_name ='1.5.0'
-- and country not in ('CN','HK')
-- and game_type =17
-- group by 1,2) c 
-- on a.role_id =c.role_id
-- where datediff(done_dt,abyss_dt) in (0,1)
-- group by 1,2,3,4


 





-- 时长分布

-- select cycle_id,difficulty,level_zone,grade_num,auto_battle,battle_result,时长分布,count(1) as battles 
-- from
-- (
-- select cycle_id,role_id,grade_num,difficulty,level_zone,auto_battle,battle_result,
--        -- case when battle_time is null then '无日志'
--           case when battle_time > 160 then '160+'
--             when battle_time > 120 and battle_time <= 160  then '(120-160]'
--             when battle_time > 80 and battle_time <= 120  then '(80-120]'
--             when battle_time > 40 and battle_time <= 80  then '(40-80]'
--             when battle_time > 20 and battle_time <= 40  then '(20-40]'
--             when battle_time >= 0 and battle_time <= 20  then '[0-20]'
 
--        end as '时长分布'    
-- from myth_server.server_endless_abyss_junior  
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and channel_id=1000  --Android
-- and version_name ='1.5.0'
-- and country not in ('CN','HK')
-- -- and cycle_id = ${ID}
-- union all
-- select cycle_id,role_id,grade_num+10 as grade_num,difficulty,level_zone,auto_battle,battle_result,
--        -- case when battle_time is null then '无日志'
--        --      when battle_time > 40 then '40+'
--        --      when battle_time > 30 and battle_time <= 40  then '(30-40]'
--        --      when battle_time > 20 and battle_time <= 30  then '(20-30]'
--        --      when battle_time > 15 and battle_time <= 20  then '(15-20]'
--        --      when battle_time > 10 and battle_time <= 15  then '(10-15]'
--        --      when battle_time >= 0 and battle_time <= 10  then '[0-10]'
--                                case when battle_time > 160 then '160+'
--             when battle_time > 120 and battle_time <= 160  then '(120-160]'
--             when battle_time > 80 and battle_time <= 120  then '(80-120]'
--             when battle_time > 40 and battle_time <= 80  then '(40-80]'
--             when battle_time > 20 and battle_time <= 40  then '(20-40]'
--             when battle_time >= 0 and battle_time <= 20  then '[0-20]'
--        end as '时长分布' 
-- from myth_server.server_endless_abyss_senior
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and channel_id=1000  --Android
-- and version_name ='1.5.0'
-- and country not in ('CN','HK')
-- -- and cycle_id = ${ID}
-- ) as b1
-- group by 1,2,3,4,5,6,7 


-- 通关率

-- select cycle_id,difficulty,level_zone,grade_num,count(distinct role_id) as wins 
-- from
-- (
-- select cycle_id,role_id,grade_num,difficulty,level_zone,auto_battle,battle_result,
--        -- case when battle_time is null then '无日志'
--        --      when battle_time > 40 then '40+'
--        --      when battle_time > 30 and battle_time <= 40  then '(30-40]'
--        --      when battle_time > 20 and battle_time <= 30  then '(20-30]'
--        --      when battle_time > 15 and battle_time <= 20  then '(15-20]'
--        --      when battle_time > 10 and battle_time <= 15  then '(10-15]'
--        --      when battle_time >= 0 and battle_time <= 10  then '[0-10]'
--        case when battle_time > 160 then '160+'
--             when battle_time > 120 and battle_time <= 160  then '(120-160]'
--             when battle_time > 80 and battle_time <= 120  then '(80-120]'
--             when battle_time > 40 and battle_time <= 80  then '(40-80]'
--             when battle_time > 20 and battle_time <= 40  then '(20-40]'
--             when battle_time >= 0 and battle_time <= 20  then '[0-20]'
--        end as '时长分布'    
-- from myth_server.server_endless_abyss_junior  
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and channel_id=1000  --Android
-- and version_name ='1.5.0'
-- and country not in ('CN','HK')
-- -- and cycle_id = ${ID}
-- union all
-- select cycle_id,role_id,grade_num+10 as grade_num,difficulty,level_zone,auto_battle,battle_result,
--        -- case when battle_time is null then '无日志'
--        --      when battle_time > 40 then '40+'
--        --      when battle_time > 30 and battle_time <= 40  then '(30-40]'
--        --      when battle_time > 20 and battle_time <= 30  then '(20-30]'
--        --      when battle_time > 15 and battle_time <= 20  then '(15-20]'
--        --      when battle_time > 10 and battle_time <= 15  then '(10-15]'
--        --      when battle_time >= 0 and battle_time <= 10  then '[0-10]'
--        case when battle_time > 160 then '160+'
--             when battle_time > 120 and battle_time <= 160  then '(120-160]'
--             when battle_time > 80 and battle_time <= 120  then '(80-120]'
--             when battle_time > 40 and battle_time <= 80  then '(40-80]'
--             when battle_time > 20 and battle_time <= 40  then '(20-40]'
--             when battle_time >= 0 and battle_time <= 20  then '[0-20]'
--        end as '时长分布' 
-- from myth_server.server_endless_abyss_senior
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and channel_id=1000  --Android
-- and version_name ='1.5.0'
-- and country not in ('CN','HK')
-- -- and cycle_id = ${ID}
-- ) as a
-- where battle_result = 1
-- group by 1,2,3,4 


-- 人均时长
-- select level_zone,difficulty,grade_num,appx_median(battle_time)
-- from myth_server.server_endless_abyss_junior  
-- -- from myth_server.server_endless_abyss_senior
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and channel_id=1000  --Android
-- and version_name ='1.5.0'
-- and country not in ('CN','HK')
-- group by 1,2,3 
 

-- select level_zone,difficulty,grade_num,appx_median(battle_time)
-- from myth_server.server_endless_abyss_junior  
-- -- from myth_server.server_endless_abyss_senior
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and channel_id=1000  --Android
-- and version_name ='1.5.0'
-- and country not in ('CN','HK')
-- and battle_result = 1
-- group by 1,2,3 
 



-- 打过等级3困难3的用户 在等级3困难2的数据表现


-- 人均时长
-- select level_zone,difficulty,grade_num,appx_median(battle_time)
-- from myth_server.server_endless_abyss_junior  
-- -- from myth_server.server_endless_abyss_senior
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and channel_id=1000  --Android
-- and version_name ='1.5.0'
-- and country not in ('CN','HK')
-- group by 1,2,3 
 

-- select level_zone,difficulty,grade_num,appx_median(battle_time)
-- from myth_server.server_endless_abyss_junior  
-- -- from myth_server.server_endless_abyss_senior
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and channel_id=1000  --Android
-- and version_name ='1.5.0'
-- and country not in ('CN','HK')
-- and battle_result = 1
-- and difficulty = 2
-- and level_zone = 3 
-- and role_id in ( 
-- select role_id
-- from myth_server.server_endless_abyss_junior  
-- -- from myth_server.server_endless_abyss_senior
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and channel_id=1000  --Android
-- and version_name ='1.5.0'
-- and country not in ('CN','HK')
-- and battle_result = 1
-- and difficulty = 2
-- and level_zone = 3 )
-- group by 1,2,3 



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




补充数据

select difficulty,level_zone,dungeon_id,a.role_id
from 
(select role_id,start_time,dungeon_id
from myth_server.server_enter_dungeon
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id=1000  --Android
and server_id in (${serverIds}) 
and version_name ='1.5.0'
and country not in ('CN','HK')
and game_type =17
and cycle_id in (25,26,27,28,29)
) a 
left join 

-- (
-- select role_id,start_time,cast(difficulty as int) as difficulty,level_zone,grade_num+100 as grade_num,cast(split_part(remain_hp,',',1) as int) as remain_hp,
-- auto_battle,battle_result,battle_time
-- from myth_server.server_endless_abyss_junior
-- where day_time>=${beginDate} and day_time<=${endDate}
-- and channel_id=1000  --Android
-- and server_id in (${serverIds}) 
-- and version_name ='1.5.0'
-- and country not in ('CN','HK')
-- and cycle_id in (25,26,27,28,29)
-- ) b 

(
select role_id,start_time,cast(difficulty as int) as difficulty,level_zone,grade_num+200 as grade_num,cast(split_part(remain_hp,',',1) as int) as remain_hp,
auto_battle,battle_result,battle_time
from myth_server.server_endless_abyss_senior
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id=1000  --Android
and server_id in (${serverIds}) 
and version_name ='1.5.0'
and country not in ('CN','HK')
and cycle_id in (25,26,27,28,29)
) b  

on a.start_time=b.start_time and a.role_id =b.role_id and a.dungeon_id =b.grade_num

group by 1,2,3,4






付费分档计算数据


select theme_id,difficulty,level_zone,dungeon_id,count(distinct role_id) as '参与人数', 
count(1) as '参与次数',
count(case when battle_result = 1 then 1 else null end ) as '胜利次数',
count(case when hp ='死亡' then 1 else null end ) as '死亡次数',
count(case when battle_result =2  then 1 else null end ) as '死亡/主动退出/超时次数',
appx_median(battle_time) as '时长中位数',
appx_median(case when battle_result =1 then battle_time  else null end) as '通关时长中位数',
count(case when auto_battle =1   then 1 else null end ) as '自动次数',
count(case when auto_battle =0   then 1 else null end ) as '手动次数',
count(case when 时长 ='[0-20]' and battle_result =1    then 1 else null end) as '通关[0-20]',
count(case when 时长 ='(20-40]' and battle_result =1   then 1 else null end) as '通关(20-40]',
count(case when 时长 ='(40-80]' and battle_result =1   then 1 else null end) as '通关(40-80]',
count(case when 时长 ='(80-120]' and battle_result =1  then 1 else null end) as '通关(80-120]',
count(case when 时长 ='(120-160]' and battle_result =1  then 1 else null end) as '通关(120-160]',
count(case when 时长 ='160+'     and battle_result =1   then 1 else null end) as '通关160+',
count(case when 时长 ='[0-20]' and battle_result =2    and hp='死亡'  then 1 else null end) as '死亡[0-20]',
count(case when 时长 ='(20-40]' and battle_result =2   and hp='死亡'  then 1 else null end) as '死亡(20-40]',
count(case when 时长 ='(40-80]' and battle_result =2   and hp='死亡'  then 1 else null end) as '死亡(40-80]',
count(case when 时长 ='(80-120]' and battle_result =2  and hp='死亡' then 1 else null end) as '死亡(80-120]',
count(case when 时长 ='(120-160]' and battle_result =2 and hp='死亡' then 1 else null end) as '死亡(120-160]',
count(case when 时长 ='160+'     and battle_result =2  and hp='死亡' then 1 else null end) as '死亡160+',
count(case when 时长 ='[0-20]' and battle_result =2    and hp<>'死亡'  then 1 else null end) as '主动退出[0-20]',
count(case when 时长 ='(20-40]' and battle_result =2   and hp<>'死亡'  then 1 else null end) as '主动退出(20-40]',
count(case when 时长 ='(40-80]' and battle_result =2   and hp<>'死亡'  then 1 else null end) as '主动退出(40-80]',
count(case when 时长 ='(80-120]' and battle_result =2  and hp<>'死亡' then 1 else null end) as '主动退出(80-120]',
count(case when 时长 ='(120-160]' and battle_result =2 and hp<>'死亡' then 1 else null end) as '主动退出(120-160]',
count(case when 时长 ='160+'     and battle_result =2  and hp<>'死亡' then 1 else null end) as '超时160+'

from 

(select birth_dt,role_id,total_pay,
case when total_pay<=8                    then 1
     when total_pay>8  and total_pay<=70  then 2
     when total_pay>70                    then 3 
     else 0 
     end as vip --D7 
from 
(select birth_dt,a.role_id
,sum(case when datediff(vip_dt,birth_dt)< ${lifeTime}  then pay else 0 end ) as 'total_pay'
from

(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(date_time) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name = '1.4.7'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(date_time) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id=1000  --Android
and version_name = '1.4.7'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id   --and a1.birth_dt = a2.device_birth_dt
group by 1,2
)  a
left join
(
select role_id,to_date(date_time) as vip_dt,sum(pay_price) pay 
from myth.order_pay
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
group by 1,2 ) b 
on a.role_id =b.role_id
where b.role_id  is not null 
group by 1,2
) a1 
) a 


left join 
(select theme_id,dungeon_id,a.role_id,difficulty,level_zone,auto_battle,battle_result,battle_time,
case when remain_hp = 0  then '死亡'
     when remain_hp is null then '无日志'
     else '主动退出或超时'
     end as hp,
       case when battle_time is null then '无日志'
            when battle_time > 160 then '160+'
            when battle_time > 120 and battle_time <= 160  then '(120-160]'
            when battle_time > 80 and battle_time <= 120  then '(80-120]'
            when battle_time > 40 and battle_time <= 80  then '(40-80]'
            when battle_time > 20 and battle_time <= 40  then '(20-40]'
            when battle_time >= 0 and battle_time <= 20  then '[0-20]'
            end as '时长'
from 
(select role_id,start_time,dungeon_id
from myth_server.server_enter_dungeon
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id=1000  --Android
and server_id in (${serverIds}) 
and version_name ='1.5.0'
and country not in ('CN','HK')
and game_type =17
and cycle_id in (25,26,27,28,29)
) a 
left join 

(
select role_id,theme_id,start_time,cast(difficulty as int) as difficulty,level_zone,grade_num+100 as grade_num,cast(split_part(remain_hp,',',1) as int) as remain_hp,
auto_battle,battle_result,battle_time
from myth_server.server_endless_abyss_junior
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id=1000  --Android
and server_id in (${serverIds}) 
and version_name ='1.5.0'
and country not in ('CN','HK')
and cycle_id in (25,26,27,28,29)
) b 

-- (
-- select role_id,theme_id,start_time,cast(difficulty as int) as difficulty,level_zone,grade_num+200 as grade_num,cast(split_part(remain_hp,',',1) as int) as remain_hp,
-- auto_battle,battle_result,battle_time
-- from myth_server.server_endless_abyss_senior
-- where day_time>=${beginDate} and day_time<=${endDate}
-- and channel_id=1000  --Android
-- and server_id in (${serverIds}) 
-- and version_name ='1.5.0'
-- and country not in ('CN','HK')
-- and cycle_id in (25,26,27,28,29)
-- ) b  

on a.start_time=b.start_time and a.role_id =b.role_id and a.dungeon_id =b.grade_num
) t 
group by 1,2,3,4





分付费看难度 不看主题和等级段




付费分档计算数据


select vip,difficulty,dungeon_id,count(distinct a.role_id) as '参与人数', 
count(1) as '参与次数',
count(distinct case when battle_result = 1 then a.role_id else null end ) as '胜利人数',
count(distinct case when battle_result = 1 then 1 else null end ) as '胜利次数',
count(distinct case when hp ='死亡' then a.role_id else null end ) as '死亡人数',
count(distinct case when hp ='死亡' then 1 else null end ) as '死亡次数',
-- count(case when battle_result =2  then 1 else null end ) as '主动退出/超时次数',
appx_median(battle_time) as '时长中位数',
appx_median(case when battle_result =1 then battle_time  else null end) as '通关时长中位数',
count(case when auto_battle =1   then 1 else null end ) as '自动次数',
count(case when auto_battle =0   then 1 else null end ) as '手动次数',
count(case when 时长 ='[0-20]' and battle_result =1    then 1 else null end) as '通关[0-20]',
count(case when 时长 ='(20-40]' and battle_result =1   then 1 else null end) as '通关(20-40]',
count(case when 时长 ='(40-80]' and battle_result =1   then 1 else null end) as '通关(40-80]',
count(case when 时长 ='(80-120]' and battle_result =1  then 1 else null end) as '通关(80-120]',
count(case when 时长 ='(120-160]' and battle_result =1  then 1 else null end) as '通关(120-160]',
count(case when 时长 ='160+'     and battle_result =1   then 1 else null end) as '通关160+',
count(case when 时长 ='[0-20]' and battle_result =2    and hp='死亡'  then 1 else null end) as '死亡[0-20]',
count(case when 时长 ='(20-40]' and battle_result =2   and hp='死亡'  then 1 else null end) as '死亡(20-40]',
count(case when 时长 ='(40-80]' and battle_result =2   and hp='死亡'  then 1 else null end) as '死亡(40-80]',
count(case when 时长 ='(80-120]' and battle_result =2  and hp='死亡' then 1 else null end) as '死亡(80-120]',
count(case when 时长 ='(120-160]' and battle_result =2 and hp='死亡' then 1 else null end) as '死亡(120-160]',
count(case when 时长 ='160+'     and battle_result =2  and hp='死亡' then 1 else null end) as '死亡160+',
count(case when 时长 ='[0-20]' and battle_result =2    and hp<>'死亡'  then 1 else null end) as '主动退出[0-20]',
count(case when 时长 ='(20-40]' and battle_result =2   and hp<>'死亡'  then 1 else null end) as '主动退出(20-40]',
count(case when 时长 ='(40-80]' and battle_result =2   and hp<>'死亡'  then 1 else null end) as '主动退出(40-80]',
count(case when 时长 ='(80-120]' and battle_result =2  and hp<>'死亡' then 1 else null end) as '主动退出(80-120]',
count(case when 时长 ='(120-160]' and battle_result =2 and hp<>'死亡' then 1 else null end) as '主动退出(120-160]',
count(case when 时长 ='160+'     and battle_result =2  and hp<>'死亡' then 1 else null end) as '超时160+'

from 

(select birth_dt,role_id,total_pay,
case when total_pay<=8                    then 1
     when total_pay>8  and total_pay<=83  then 2
     when total_pay>83                    then 3 
     else 0 
     end as vip --D14 
from 
(select birth_dt,a.role_id
,sum(case when datediff(vip_dt,birth_dt)< ${lifeTime}  then pay else 0 end ) as 'total_pay'
from

(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(date_time) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name = '1.4.7'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(date_time) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id=1000  --Android
and version_name = '1.4.7'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id   --and a1.birth_dt = a2.device_birth_dt
group by 1,2
)  a
left join
(
select role_id,to_date(date_time) as vip_dt,sum(pay_price) pay 
from myth.order_pay
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
group by 1,2 ) b 
on a.role_id =b.role_id
where b.role_id  is not null 
group by 1,2
) a1 
) a 

left join 

(select dungeon_id,a.role_id,difficulty,auto_battle,battle_result,battle_time,
case when remain_hp = 0  then '死亡'
     when remain_hp is null then '无日志'
     else '主动退出或超时'
     end as hp,
       case when battle_time is null then '无日志'
            when battle_time > 160 then '160+'
            when battle_time > 120 and battle_time <= 160  then '(120-160]'
            when battle_time > 80 and battle_time <= 120  then '(80-120]'
            when battle_time > 40 and battle_time <= 80  then '(40-80]'
            when battle_time > 20 and battle_time <= 40  then '(20-40]'
            when battle_time >= 0 and battle_time <= 20  then '[0-20]'
            end as '时长'
from 
(select role_id,start_time,dungeon_id
from myth_server.server_enter_dungeon
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id=1000  --Android
and server_id in (${serverIds}) 
and version_name ='1.5.0'
and country not in ('CN','HK')
and game_type =17
and cycle_id in (25,26,27,28,29,30,31,32,33)
) a 
left join 

(
select role_id,theme_id,start_time,cast(difficulty as int) as difficulty,level_zone,grade_num+100 as grade_num,cast(split_part(remain_hp,',',1) as int) as remain_hp,
auto_battle,battle_result,battle_time
from myth_server.server_endless_abyss_junior
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id=1000  --Android
and server_id in (${serverIds}) 
and version_name ='1.5.0'
and country not in ('CN','HK')
and cycle_id in (25,26,27,28,29,30,31,32,33)
) b 

-- (
-- select role_id,theme_id,start_time,cast(difficulty as int) as difficulty,level_zone,grade_num+200 as grade_num,cast(split_part(remain_hp,',',1) as int) as remain_hp,
-- auto_battle,battle_result,battle_time
-- from myth_server.server_endless_abyss_senior
-- where day_time>=${beginDate} and day_time<=${endDate}
-- and channel_id=1000  --Android
-- and server_id in (${serverIds}) 
-- and version_name ='1.5.0'
-- and country not in ('CN','HK')
-- and cycle_id in (25,26,27,28,29,30,31,32,33)
-- ) b  

on a.start_time=b.start_time and a.role_id =b.role_id and a.dungeon_id =b.grade_num
) t 
on a.role_id = t.role_id 
group by 1,2,3 
