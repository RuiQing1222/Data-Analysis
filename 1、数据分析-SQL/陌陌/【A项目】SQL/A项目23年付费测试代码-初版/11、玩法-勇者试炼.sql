----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
勇者试炼

select cycle_id,level_zone,difficulty,dungeon_id,
       count(distinct role_id) as '参与人数',
       count(distinct start_time) as '参与次数',
       round(count(distinct case when battle_result = 1 then role_id else null end) / count(distinct role_id),2) as '通关率',
       round(count(case when battle_result is null then 1 else 0 end) / count(distinct start_time),2) as '无日志率',
       round(sum(battle_time) / count(distinct role_id),2) as '人均时长',
       count(distinct case when auto_battle = 1 then start_time else null end) as '自动次数',
       count(distinct case when auto_battle = 0 then start_time else null end) as '手动次数',
       count(distinct case when 时长分布 = '[0-10]' then start_time else null end) as '[0-10]次数',
       count(distinct case when 时长分布 = '(10-15]' then start_time else null end) as '(10-15]次数',
       count(distinct case when 时长分布 = '(15-20]' then start_time else null end) as '(15-20]次数',
       count(distinct case when 时长分布 = '(20-30]' then start_time else null end) as '(20-30]次数',
       count(distinct case when 时长分布 = '(30-40]' then start_time else null end) as '(30-40]次数',
       count(distinct case when 时长分布 = '40+' then start_time else null end) as '40+次数'

(
select a.role_id,a.cycle_id,b.dungeon_id,b.scene_id,a.start_time,auto_battle,battle_result,battle_time,时长分布,difficulty,level_zone
from

(select role_id,cycle_id,dungeon_id,scene_id,start_time
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and game_type = 17
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5
) as a

left join
(
select role_id,cycle_id,dungeon_id,scene_id,auto_battle,battle_result,battle_time,时长分布,start_time,difficulty,level_zone
from
(select role_id,cycle_id,dungeon_id,scene_id,auto_battle,battle_result,battle_time,时长分布,start_time,difficulty,level_zone,row_number() over(partition by role_id,cycle_id order by log_time desc) as num -- 周期最高层数
from
(
select role_id,cycle_id,scene_id,grade_num as dungeon_id,auto_battle,battle_result,battle_time,
       case when battle_time/60000 is null then '无日志'
            when battle_time/60000 > 40 then '40+'
            when battle_time/60000 > 30 and battle_time/60000 <= 40  then '(30-40]'
            when battle_time/60000 > 20 and battle_time/60000 <= 30  then '(20-30]'
            when battle_time/60000 > 15 and battle_time/60000 <= 20  then '(15-20]'
            when battle_time/60000 > 10 and battle_time/60000 <= 15  then '(10-15]'
            when battle_time/60000 >= 0 and battle_time/60000 <= 10  then '[0-10]'
       end as '时长分布',
       start_time,log_time,difficulty,level_zone         
from myth_server.server_endless_abyss_junior  
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
union all
select role_id,cycle_id,scene_id,
       case when grade_num = 1 then 8
            when grade_num = 2 then 9
            when grade_num = 3 then 10
            when grade_num = 4 then 11
            when grade_num = 5 then 12
          end as dungeon_id
            ,auto_battle,battle_result,battle_time,
       case when battle_time/60000 is null then '无日志'
            when battle_time/60000 > 40 then '40+'
            when battle_time/60000 > 30 and battle_time/60000 <= 40  then '(30-40]'
            when battle_time/60000 > 20 and battle_time/60000 <= 30  then '(20-30]'
            when battle_time/60000 > 15 and battle_time/60000 <= 20  then '(15-20]'
            when battle_time/60000 > 10 and battle_time/60000 <= 15  then '(10-15]'
            when battle_time/60000 >= 0 and battle_time/60000 <= 10  then '[0-10]'
       end as '时长分布',
            start_time,log_time,difficulty,level_zone    
from myth_server.server_endless_abyss_senior
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) as b1
) as b2
group by 1,2,3,4,5,6,7,8,9,10,11
where num = 1
) as b
on a.role_id = b.role_id and a.cycle_id = b.cycle_id and a.dungeon_id = b.dungeon_id and a.scene_id = b.scene_id and a.start_time=b.start_time
group by 1,2,3,4,5,6,7,8,9,10,11

) as new
group by 1,2,3,4



天复玩率
select cycle_id,dungeon_id,difficulty,level_zone,count(distinct a.role_id) as '总人数',count(distinct case when b.role_id is not null then a.role else null end) as '复玩人数'
from
(
select role_id,cycle_id,dungeon_id,difficulty,level_zone,done_dt
from
(select role_id,cycle_id,dungeon_id,difficulty,level_zone,done_dt,row_number() over(partition by role_id,cycle_id order by log_time desc) as num -- 周期最高层数
from
(
select role_id,cycle_id,grade_num as dungeon_id,difficulty,level_zone,to_date(cast(date_time as timestamp)) as done_dt,log_time      
from myth_server.server_endless_abyss_junior  
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
union all
select role_id,cycle_id,
       case when grade_num = 1 then 8
            when grade_num = 2 then 9
            when grade_num = 3 then 10
            when grade_num = 4 then 11
            when grade_num = 5 then 12
          end as dungeon_id,difficulty,level_zone,to_date(cast(date_time as timestamp)) as done_dt,log_time
from myth_server.server_endless_abyss_senior
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) as a1
) as a2
group by 1,2,3,4,5,6
where num = 1
) as a

left join
(select role_id,to_date(cast(date_time as timestamp)) as enter_dt
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
and game_type = 17
group by 1,2
) as b
on a.role_id = b.role_id
where datediff(enter_dt,done_dt)=1


