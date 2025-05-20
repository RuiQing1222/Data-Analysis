-- 秘境战力分位数

select dungeon_id as '秘境副本ID',count(distinct role_id) as '通关角色数',
round(avg(case when row_num<=0.25*cnt                      then min_points else null end ),0) as `通关角色平均战力1%~25%`,
round(avg(case when row_num<=0.50*cnt and row_num>0.25*cnt then min_points else null end ),0) as `通关角色平均战力25%~50%`,
round(avg(case when row_num<=0.75*cnt and row_num>0.50*cnt then min_points else null end ),0) as `通关角色平均战力50%~75%`,
round(avg(case when row_num<=cnt      and row_num>0.75*cnt then min_points else null end ),0) as `通关角色平均战力75%~100%`
from 
(select dungeon_id,role_id,min_points,row_number() over(partition by dungeon_id order by min_points asc) as row_num,
     count(1) over(partition by dungeon_id) as cnt 
from  
(select role_id,dungeon_id,min(battle_points) as min_points
from myth_server.server_dungeon_end
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
and game_type=2
and battle_result=1
group by 1,2) a 
) a 
group by 1
order by 1