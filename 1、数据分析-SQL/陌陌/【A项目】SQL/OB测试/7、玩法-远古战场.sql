分boss来算

玩法——6->远古战场
远古战场  伤害分布  计算参与人数、次数，未通关、中途退出(评级无日志)、操作、时长

select dungeon_id as 'BOSS',case role_type 
             when   '1' then '3雷'
             when   '2' then '1瓦'
             when   '3' then '2齐'
             when   '4' then '4乌'
             when   '5' then '5芙'
             when   '6' then '6贝'   
             when   '7' then '7海'
        end as role_type,auto_battle,评级,最高伤害分层,
       count(distinct a.role_id) as '人数',
       count(start_time) as '进入次数',
       count(distinct e.role_id) as '钻石进入人数',
       sum(change_count) as '钻石消耗',
       sum(consume_nums) as '钻石进入次数'
from
(select dungeon_id,role_type,done_dt,birth_dt,auto_battle,评级,最高伤害分层,
       a.role_id,start_time
from
(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(date_time) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id in (1000,2000)
and version_name ='1.5.0'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(date_time) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id in (1000,2000)
and version_name ='1.5.0'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id --and a1.birth_dt = a2.device_birth_dt
group by 1,2
)  a

left join
(select a.role_id,a.dungeon_id,role_type,a.start_time,end_time,auto_battle,a.done_dt,
  case when 最高伤害分层 is null then '无日志'
  else 最高伤害分层 
  end as 最高伤害分层,
        case when (end_time-a.start_time)/60000 is null then '无日志'
             when (end_time-a.start_time)/60000 >= 1.5  then '1>= 1.5分钟'
             when (end_time-a.start_time)/60000 > 1 and (end_time-a.start_time)/60000 < 1.5  then '2(1,1.5)分钟'
             when (end_time-a.start_time)/60000 > 0.5 and (end_time-a.start_time)/60000 <= 1  then '3(0.5,1]分钟'
             when (end_time-a.start_time)/60000 > 0 and (end_time-a.start_time)/60000 <= 0.5  then '4(0,0.5]分钟'
             else '无日志'
       end as '评级'
from 
(select dungeon_id,role_id,role_type,start_time,to_date(date_time) as done_dt
     from myth_server.server_enter_dungeon
     where  day_time between ${beginDate} and ${endDate} 
     and server_id in (${serverIds})
     and game_type =6 -- 6远古战场
     and channel_id in (1000,2000)
     and version_name ='1.5.0'
     and country not in ('CN','HK')
group by 1,2,3,4,5
) a

left join     
(select boss_id,role_id,log_time as end_time,start_time,auto_battle,to_date(date_time) as done_dt
     from myth_server.server_world_boss
     where  day_time between ${beginDate} and ${endDate} 
     and server_id in (${serverIds})
     and channel_id in (1000,2000)
     and version_name ='1.5.0'
     and country not in ('CN','HK')
) b 
on dungeon_id = b.boss_id and a.role_id=b.role_id and a.start_time=b.start_time and a.done_dt = b.done_dt

left join
(select boss_id,role_id,done_dt,
  case when max_damage_value >= 0          and max_damage_value <= 3000        then '1.0~3000'
       when max_damage_value > 3000        and max_damage_value <= 5000        then '2.3001~5000'
       when max_damage_value > 5000        and max_damage_value <= 9000        then '3.5001~9000'
       when max_damage_value > 9000        and max_damage_value <= 17000       then '4.9001~17000'
       when max_damage_value > 17000       and max_damage_value <= 33000       then '5.17001~33000'
       when max_damage_value > 33000       and max_damage_value <= 55000       then '6.33001~55000'
       when max_damage_value > 55000       and max_damage_value <= 84000       then '7.55001~84000'
       when max_damage_value > 84000       and max_damage_value <= 120000      then '8.84001~120000'
       when max_damage_value > 120000      and max_damage_value <= 210000      then '9.120001~210000'
       when max_damage_value > 210000      and max_damage_value <= 290000      then '10.210001~290000'
       when max_damage_value > 290000      and max_damage_value <= 390000      then '11.290001~390000'
       when max_damage_value > 390000      and max_damage_value <= 560000      then '12.390001~560000'
       when max_damage_value > 560000      and max_damage_value <= 1700000     then '13.560001~1700000'
       when max_damage_value > 1700000     and max_damage_value <= 2800000     then '14.1700001~2800000'
       when max_damage_value > 2800000     and max_damage_value <= 3700000     then '15.2800001~3700000'
       when max_damage_value > 3700000     and max_damage_value <= 5300000     then '16.3700001~5300000'
       when max_damage_value > 5300000     and max_damage_value <= 7600000     then '17.5300001~7600000'
       when max_damage_value > 7600000     and max_damage_value <= 12000000    then '18.7600001~12000000'
       when max_damage_value > 12000000    and max_damage_value <= 18000000    then '19.12000001~18000000'
       when max_damage_value > 18000000    and max_damage_value <= 28000000    then '20.18000001~28000000'
       when max_damage_value > 28000000    and max_damage_value <= 42000000    then '21.28000001~42000000'
       when max_damage_value > 42000000    and max_damage_value <= 57000000    then '22.42000001~57000000'
       when max_damage_value > 57000000    and max_damage_value <= 83000000    then '23.57000001~83000000'
       when max_damage_value > 83000000    and max_damage_value <= 110000000   then '24.83000001~110000000'
       when max_damage_value > 110000000   and max_damage_value <= 150000000   then '25.110000001~150000000'
       when max_damage_value > 150000000   and max_damage_value <= 200000000   then '26.150000001~200000000'
       when max_damage_value > 200000000   and max_damage_value <= 270000000   then '27.200000001~270000000'
       when max_damage_value > 270000000   and max_damage_value <= 350000000   then '28.270000001~350000000'
       when max_damage_value > 350000000   and max_damage_value <= 510000000   then '29.350000001~510000000'
       when max_damage_value > 510000000   and max_damage_value <= 660000000   then '30.510000001~660000000'
       when max_damage_value > 660000000   and max_damage_value <= 880000000   then '31.660000001~880000000'
       when max_damage_value > 880000000   and max_damage_value <= 1200000000  then '32.880000001~1200000000'
       when max_damage_value > 1200000000  and max_damage_value <= 1600000000  then '33.1200000001~1600000000'
       when max_damage_value > 1600000000  and max_damage_value <= 2200000000  then '34.1600000001~2200000000'
       when max_damage_value > 2200000000  and max_damage_value <= 2700000000  then '35.2200000001~2700000000'
       when max_damage_value > 2700000000  and max_damage_value <= 3500000000  then '36.2700000001~3500000000'
       when max_damage_value > 3500000000                                      then '37.3500000001~+∞'
       when max_damage_value is null then '无日志'
       else NULL
       end as '最高伤害分层'
  from
 (select boss_id,role_id,to_date(date_time) as done_dt,max(damage_value) as max_damage_value
     from myth_server.server_world_boss
     where  day_time between ${beginDate} and ${endDate} 
     and server_id in (${serverIds})
     and channel_id in (1000,2000)
     and version_name ='1.5.0'
     and country not in ('CN','HK')
     group by 1,2,3
) c1 
) c 
on a.done_dt = c.done_dt and a.dungeon_id = c.boss_id and a.role_id = c.role_id
) d 
on a.role_id = d.role_id
where d.role_id is not null 
group by 1,2,3,4,5,6,7,8,9
) a 
left join 
 
(SELECT role_id,to_date(date_time) as consume_dt,sum(change_count) as change_count,count(1) as consume_nums  
FROM myth.server_currency
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id in (1000,2000)
and version_name ='1.5.0'
and country not in ('CN','HK')
and currency_id = '3'
AND change_type = 'CONSUME'
and change_method = '56'
group by 1,2
) e 
on a.role_id = e.role_id and consume_dt=done_dt 
where datediff(done_dt,birth_dt)<${lifeTime}
group by 1,2,3,4,5 





战力分布
select boss_id,case role_type 
             when   '1' then '3雷'
             when   '2' then '1瓦'
             when   '3' then '2齐'
             when   '4' then '4乌'
             when   '5' then '5芙'
        end as role_type,最高伤害分层,
appx_median(battle_points) as '战力中位数',
round(avg(case when rank1<=0.25*cnt                     then battle_points else null end ),0) as `角色平均战力1%~25%`,
round(avg(case when rank1<=0.50*cnt and rank1>0.25*cnt  then battle_points else null end ),0) as `角色平均战力25%~50%`,
round(avg(case when rank1<=0.75*cnt and rank1>0.50*cnt  then battle_points else null end ),0) as `角色平均战力50%~75%`,
round(avg(case when rank1<=cnt      and rank1>0.75*cnt  then battle_points else null end ),0) as `角色平均战力75%~100%`
from
(select boss_id,role_id,role_type,done_dt,battle_points,最高伤害分层,
 rank()over(partition by boss_id,done_dt,最高伤害分层 order by battle_points asc) as rank1,
count(1) over(partition by boss_id,done_dt,最高伤害分层) as cnt 
from 
(select boss_id,a.role_id,done_dt,battle_points,max_damage_value,role_type,
  case when max_damage_value >= 0          and max_damage_value <= 3000        then '1.0~3000'
       when max_damage_value > 3000        and max_damage_value <= 5000        then '2.3001~5000'
       when max_damage_value > 5000        and max_damage_value <= 9000        then '3.5001~9000'
       when max_damage_value > 9000        and max_damage_value <= 17000       then '4.9001~17000'
       when max_damage_value > 17000       and max_damage_value <= 33000       then '5.17001~33000'
       when max_damage_value > 33000       and max_damage_value <= 55000       then '6.33001~55000'
       when max_damage_value > 55000       and max_damage_value <= 84000       then '7.55001~84000'
       when max_damage_value > 84000       and max_damage_value <= 120000      then '8.84001~120000'
       when max_damage_value > 120000      and max_damage_value <= 210000      then '9.120001~210000'
       when max_damage_value > 210000      and max_damage_value <= 290000      then '10.210001~290000'
       when max_damage_value > 290000      and max_damage_value <= 390000      then '11.290001~390000'
       when max_damage_value > 390000      and max_damage_value <= 560000      then '12.390001~560000'
       when max_damage_value > 560000      and max_damage_value <= 1700000     then '13.560001~1700000'
       when max_damage_value > 1700000     and max_damage_value <= 2800000     then '14.1700001~2800000'
       when max_damage_value > 2800000     and max_damage_value <= 3700000     then '15.2800001~3700000'
       when max_damage_value > 3700000     and max_damage_value <= 5300000     then '16.3700001~5300000'
       when max_damage_value > 5300000     and max_damage_value <= 7600000     then '17.5300001~7600000'
       when max_damage_value > 7600000     and max_damage_value <= 12000000    then '18.7600001~12000000'
       when max_damage_value > 12000000    and max_damage_value <= 18000000    then '19.12000001~18000000'
       when max_damage_value > 18000000    and max_damage_value <= 28000000    then '20.18000001~28000000'
       when max_damage_value > 28000000    and max_damage_value <= 42000000    then '21.28000001~42000000'
       when max_damage_value > 42000000    and max_damage_value <= 57000000    then '22.42000001~57000000'
       when max_damage_value > 57000000    and max_damage_value <= 83000000    then '23.57000001~83000000'
       when max_damage_value > 83000000    and max_damage_value <= 110000000   then '24.83000001~110000000'
       when max_damage_value > 110000000   and max_damage_value <= 150000000   then '25.110000001~150000000'
       when max_damage_value > 150000000   and max_damage_value <= 200000000   then '26.150000001~200000000'
       when max_damage_value > 200000000   and max_damage_value <= 270000000   then '27.200000001~270000000'
       when max_damage_value > 270000000   and max_damage_value <= 350000000   then '28.270000001~350000000'
       when max_damage_value > 350000000   and max_damage_value <= 510000000   then '29.350000001~510000000'
       when max_damage_value > 510000000   and max_damage_value <= 660000000   then '30.510000001~660000000'
       when max_damage_value > 660000000   and max_damage_value <= 880000000   then '31.660000001~880000000'
       when max_damage_value > 880000000   and max_damage_value <= 1200000000  then '32.880000001~1200000000'
       when max_damage_value > 1200000000  and max_damage_value <= 1600000000  then '33.1200000001~1600000000'
       when max_damage_value > 1600000000  and max_damage_value <= 2200000000  then '34.1600000001~2200000000'
       when max_damage_value > 2200000000  and max_damage_value <= 2700000000  then '35.2200000001~2700000000'
       when max_damage_value > 2700000000  and max_damage_value <= 3500000000  then '36.2700000001~3500000000'
       when max_damage_value > 3500000000                                      then '37.3500000001~+∞'
       when max_damage_value is null then '无日志'
       else NULL
       end as '最高伤害分层'
from 
(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(date_time) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id in (1000,2000)
and version_name ='1.5.0'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(date_time) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id in (1000,2000)
and version_name ='1.5.0'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id --and a1.birth_dt = a2.device_birth_dt
group by 1,2
)  a

left join
 
 (select boss_id,role_id,to_date(date_time) as done_dt,battle_points,damage_value as max_damage_value,role_type,
  rank()over(partition by role_id,day_time,boss_id order by damage_value desc) as row_num1
     from myth_server.server_world_boss
     where  day_time between ${beginDate} and ${endDate} 
     and server_id in (${serverIds})
     and channel_id in (1000,2000)
     and version_name ='1.5.0'
     and country not in ('CN','HK')  
)  b 
on a.role_id = b.role_id 
 where row_num1 = 1 --求每一个人分天分BOSS的最大伤害
 and datediff(done_dt,birth_dt)<${lifeTime}
) c 
) a 
group by 1,2,3

