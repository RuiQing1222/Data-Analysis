分boss来算

玩法——6->远古战场
远古战场  伤害分布  计算参与人数、次数，未通关、中途退出(评级无日志)、操作、时长

select birth_dt,role_id,boss_id,start_time,天数,auto_battle,评级,damage_value,max_damage_value,
  case when max_damage_value >= 0 and damage_value <= 2000 then '0~2000'
       when max_damage_value > 2000 and damage_value <= 4000 then '2001~4000'
       when max_damage_value > 4000 and damage_value <= 7000 then '4001~7000'
       when max_damage_value > 7000 and damage_value <= 10000 then '7001~10000'
       when max_damage_value > 10000 and damage_value <= 15000 then '10001~15000'
       when max_damage_value > 15000 and damage_value <= 20000 then '15001~20000'
       when max_damage_value > 20000 and damage_value <= 30000 then '20001~30000'
       when max_damage_value > 30000 and damage_value <= 45000 then '30001~45000'
       when max_damage_value > 45000 and damage_value <= 67000 then '45001~67000'
       when max_damage_value > 67000 and damage_value <= 95000 then '67001~95000'
       when max_damage_value > 95000 and damage_value <= 130000 then '95001~130000'
       when max_damage_value > 130000 and damage_value <= 180000 then '130001~180000'
       when max_damage_value > 180000 and damage_value <= 340000 then '180001~340000'
       when max_damage_value > 340000 and damage_value <= 550000 then '340001~550000'
       when max_damage_value > 550000 and damage_value <= 910000 then '550001~910000'
       when max_damage_value > 910000 and damage_value <= 1300000 then '910001~1300000'
       when max_damage_value > 1300000 and damage_value <= 2000000 then '1300001~2000000'
       when max_damage_value > 2000000 and damage_value <= 2800000 then '2000001~2800000'
       when max_damage_value > 2800000 and damage_value <= 3700000 then '2800001~3700000'
       when max_damage_value > 3700000 and damage_value <= 4900000 then '3700001~4900000'
       when max_damage_value > 4900000 and damage_value <= 6400000 then '4900001~6400000'
       when max_damage_value > 6400000 and damage_value <= 8800000 then '6400001~8800000'
       when max_damage_value > 8800000 and damage_value <= 12000000 then '8800001~12000000'
       when max_damage_value > 12000000 and damage_value <= 15000000 then '12000001~15000000'
       when max_damage_value > 15000000 and damage_value <= 19000000 then '15000001~19000000'
       when max_damage_value > 19000000 and damage_value <= 23000000 then '19000001~23000000'
       when max_damage_value > 23000000 and damage_value <= 31000000 then '23000001~31000000'
       when max_damage_value > 31000000 and damage_value <= 42000000 then '31000001~42000000'
       when max_damage_value > 42000000 and damage_value <= 55000000 then '42000001~55000000'
       when max_damage_value > 55000000 and damage_value <= 70000000 then '55000001~70000000'
       when max_damage_value > 70000000 and damage_value <= 85000000 then '70000001~85000000'
       when max_damage_value > 85000000 and damage_value <= 100000000 then '85000001~100000000'
       when max_damage_value > 100000000 and damage_value <= 150000000 then '100000001~150000000'
       when max_damage_value > 150000000 and damage_value <= 200000000 then '150000001~200000000'
       when max_damage_value > 200000000 and damage_value <= 250000000 then '200000001~250000000'
       when max_damage_value > 250000000 and damage_value <= 300000000 then '250000001~300000000'
       when damage_value is null then '无日志'
       else NULL
       end as '最高伤害分层'
from

(
select birth_dt,b.role_id,boss_id,start_time,datediff(done_dt,birth_dt)+1 as '天数',auto_battle,评级,damage_value,max_damage_value
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
(select role_id,boss_id,start_time,auto_battle,done_dt,damage_value,max_damage_value,评级
from
(select a.role_id,a.dungeon_id as boss_id,a.start_time,end_time,auto_battle,done_dt,damage_value,max_damage_value,
        case when (end_time-a.start_time)/60000 is null then '无日志'
            when (end_time-a.start_time)/60000 >= 1.5  then '1>= 1.5分钟'
            when (end_time-a.start_time)/60000 > 1 and (end_time-a.start_time)/60000 < 1.5  then '2(1,1.5)分钟'
            when (end_time-a.start_time)/60000 > 0.5 and (end_time-a.start_time)/60000 <= 1  then '3(0.5,1]分钟'
            when (end_time-a.start_time)/60000 > 0 and (end_time-a.start_time)/60000 <= 0.5  then '4(0,0.5]分钟'
            else '无日志'
       end as '评级'
from 
(select day_time,dungeon_id,role_id,start_time,date_time,to_date(cast(date_time as timestamp)) as done_dt
     from myth_server.server_enter_dungeon
     where  day_time between ${beginDate} and ${endDate} 
     and server_id in (${serverIds})
     and game_type =6 -- 6远古战场
     and channel_id=1000  --Android
     and version_name ='1.3.5'
     and country not in ('CN','HK')
group by 1,2,3,4,5,6
) as a

left join     
(select boss_id,role_id,log_time as end_time,start_time,auto_battle,damage_value
     from myth_server.server_world_boss
     where  day_time between ${beginDate} and ${endDate} 
     and server_id in (${serverIds})
     and channel_id=1000  --Android
     and version_name ='1.3.5'
     and country not in ('CN','HK')
group by 1,2,3,4,5,6
) b 
on a.dungeon_id = b.boss_id and a.role_id=b.role_id and a.start_time=b.start_time

left join
(select boss_id,role_id,day_time,max(damage_value) as max_damage_value
     from myth_server.server_world_boss
     where  day_time between ${beginDate} and ${endDate} 
     and server_id in (${serverIds})
     and channel_id=1000  --Android
     and version_name ='1.3.5'
     and country not in ('CN','HK')
     group by 1,2,3
) as c 
on a.day_time = c.day_time and a.dungeon_id = c.boss_id and b.role_id = c.role_id and b.damage_value = c.max_damage_value
) as e  
) as b 
on a.role_id = b.role_id
group by 1,2,3,4,5,6,7,8,9
) as ab
group by 1,2,3,4,5,6,7,8,9,10
order by 1,2,3,5,6,7,8,9,10




整体钻石消耗
select birth_dt,b.role_id as role_id,boss_id,log_time,datediff(consume_dt,birth_dt)+1 as '天数',max_damage_value,最高伤害分层,change_count
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
(select b.role_id,boss_id,max_damage_value,最高伤害分层,change_count,consume_dt,log_time
from
(select role_id,boss_id,max_damage_value,
  case when max_damage_value >= 0 and max_damage_value <= 2000 then '0~2000'
       when max_damage_value > 2000 and max_damage_value <= 4000 then '2001~4000'
       when max_damage_value > 4000 and max_damage_value <= 7000 then '4001~7000'
       when max_damage_value > 7000 and max_damage_value <= 10000 then '7001~10000'
       when max_damage_value > 10000 and max_damage_value <= 15000 then '10001~15000'
       when max_damage_value > 15000 and max_damage_value <= 20000 then '15001~20000'
       when max_damage_value > 20000 and max_damage_value <= 30000 then '20001~30000'
       when max_damage_value > 30000 and max_damage_value <= 45000 then '30001~45000'
       when max_damage_value > 45000 and max_damage_value <= 67000 then '45001~67000'
       when max_damage_value > 67000 and max_damage_value <= 95000 then '67001~95000'
       when max_damage_value > 95000 and max_damage_value <= 130000 then '95001~130000'
       when max_damage_value > 130000 and max_damage_value <= 180000 then '130001~180000'
       when max_damage_value > 180000 and max_damage_value <= 340000 then '180001~340000'
       when max_damage_value > 340000 and max_damage_value <= 550000 then '340001~550000'
       when max_damage_value > 550000 and max_damage_value <= 910000 then '550001~910000'
       when max_damage_value > 910000 and max_damage_value <= 1300000 then '910001~1300000'
       when max_damage_value > 1300000 and max_damage_value <= 2000000 then '1300001~2000000'
       when max_damage_value > 2000000 and max_damage_value <= 2800000 then '2000001~2800000'
       when max_damage_value > 2800000 and max_damage_value <= 3700000 then '2800001~3700000'
       when max_damage_value > 3700000 and max_damage_value <= 4900000 then '3700001~4900000'
       when max_damage_value > 4900000 and max_damage_value <= 6400000 then '4900001~6400000'
       when max_damage_value > 6400000 and max_damage_value <= 8800000 then '6400001~8800000'
       when max_damage_value > 8800000 and max_damage_value <= 12000000 then '8800001~12000000'
       when max_damage_value > 12000000 and max_damage_value <= 15000000 then '12000001~15000000'
       when max_damage_value > 15000000 and max_damage_value <= 19000000 then '15000001~19000000'
       when max_damage_value > 19000000 and max_damage_value <= 23000000 then '19000001~23000000'
       when max_damage_value > 23000000 and max_damage_value <= 31000000 then '23000001~31000000'
       when max_damage_value > 31000000 and max_damage_value <= 42000000 then '31000001~42000000'
       when max_damage_value > 42000000 and max_damage_value <= 55000000 then '42000001~55000000'
       when max_damage_value > 55000000 and max_damage_value <= 70000000 then '55000001~70000000'
       when max_damage_value > 70000000 and max_damage_value <= 85000000 then '70000001~85000000'
       when max_damage_value > 85000000 and max_damage_value <= 100000000 then '85000001~100000000'
       when max_damage_value > 100000000 and max_damage_value <= 150000000 then '100000001~150000000'
       when max_damage_value > 150000000 and max_damage_value <= 200000000 then '150000001~200000000'
       when max_damage_value > 200000000 and max_damage_value <= 250000000 then '200000001~250000000'
       when max_damage_value > 250000000 and max_damage_value <= 300000000 then '250000001~300000000'
       when damage_value is null then '无日志'
       else NULL
       end as '最高伤害分层'
from
(select role_id,boss_id,max(damage_value) as max_damage_value
from myth_server.server_world_boss
where  day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2
) as c 
group by 1,2,3,4
) as a

left join
(SELECT role_id,to_date(cast(date_time as timestamp)) as consume_dt,log_time,change_count 
FROM myth.server_currency
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
and currency_id = '3'
AND change_type = 'CONSUME'
and change_method = '56'
group by 1,2,3,4
) as b
on a.role_id = b.role_id
group by 1,2,3,4,5,6,7
) as b
on a.role_id = b.role_id
group by 1,2,3,4,5,6,7,8

