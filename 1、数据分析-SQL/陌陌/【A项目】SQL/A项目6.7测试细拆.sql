-- -- 原
-- -- 战役关卡时长

select a.dungeon_id,a.role_id,a.start_time,end_time,(end_time-a.start_time)/60000 as duration ,battle_result,auto_battle
from 

(select dungeon_id,role_id,day_time,start_time,role_type
     from myth_server.server_enter_dungeon
     where  day_time between ${beginDate} and ${endDate}   and server_id in (20001,20002,20003)
     and game_type=3
     and role_id in (select role_id
                    from myth.server_role_create 
                    where day_time>=${beginDate} and day_time<=${endDate}
                    and server_id in (20001,20002,20003) 
                    and version_name ='1.3.0'
                    and country not in ('CN','HK') )
                    and device_id in 
                                   (select device_id
                                   from myth.device_activate
                                   where day_time>=${beginDate} and day_time<=${endDate}
                                   and version_name ='1.3.0'
                                   and country not in ('CN','HK')) 
                                   group by 1,2,3,4,5
                                   ) a

left join     
(select dungeon_id,role_id,day_time,log_time as end_time,start_time,battle_result,role_type,auto_battle
     from myth_server.server_dungeon_end
     where  day_time between ${beginDate} and ${endDate}   and server_id in (20001,20002,20003)
     and game_type=3
     and role_id in (select role_id
                    from myth.server_role_create 
                    where day_time>=${beginDate} and day_time<=${endDate}
                    and server_id in (20001,20002,20003) 
                    and version_name ='1.3.0'
                    and country not in ('CN','HK') )
                    and device_id in (select device_id
                                   from myth.device_activate
                                   where day_time>=${beginDate} and day_time<=${endDate}
                                   and version_name ='1.3.0'
                                   and country not in ('CN','HK')) 
                                   ) b 
on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time=b.start_time
group by 1,2,3,4,5,6,7
order by a.role_id,a.start_time asc 



不同玩法 不同关卡 自动非自动  通关未通关绝对次数
select a.game_type, a.dungeon_id,a.role_id,a.start_time,end_time,(end_time-a.start_time)/60000 as duration ,battle_result,auto_battle
from 

(select dungeon_id,role_id,day_time,start_time,role_type,game_type
     from myth_server.server_enter_dungeon
     where  day_time between ${beginDate} and ${endDate}   and server_id in (20001,20002,20003)
     -- and game_type=3
     and role_id in (select role_id
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${endDate}
and server_id in (20001,20002,20003) 
and version_name ='1.3.0'
and country not in ('CN','HK') )
     and device_id in 
(select device_id
from myth.device_activate
where day_time>=${beginDate} and day_time<=${endDate}
and version_name ='1.3.0'
and country not in ('CN','HK')) 
group by 1,2,3,4,5,6
) a

left join     
(select dungeon_id,role_id,day_time,log_time as end_time,start_time,battle_result,role_type,auto_battle,game_type
     from myth_server.server_dungeon_end
     where  day_time between ${beginDate} and ${endDate}   and server_id in (20001,20002,20003)
     -- and game_type=3
     and role_id in (select role_id
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${endDate}
and server_id in (20001,20002,20003) 
and version_name ='1.3.0'
and country not in ('CN','HK') )
     and device_id in 
(select device_id
from myth.device_activate
where day_time>=${beginDate} and day_time<=${endDate}
and version_name ='1.3.0'
and country not in ('CN','HK')) 
) b 
on a.game_type = b.game_type and a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time=b.start_time

group by 1,2,3,4,5,6,7,8

order by a.role_id,a.start_time asc 






引导拆分，点了新手引导 没进关卡的人出去干了啥
select a.day_time,a.role_id,btn_type,row_number()over(partition by a.role_id order by log_time asc) as row_num
from
(select a.role_id,a.day_time,end_time
from 
(select role_id,day_time,log_time as end_time
     from myth.server_newbie
     where  day_time between ${beginDate} and ${endDate}   and server_id in (20001,20002,20003)
     and version_name ='1.3.0'
     and step='1014020'
     and role_id in (select role_id
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${endDate}
and server_id in (20001,20002,20003) 
and version_name ='1.3.0'
and country not in ('CN','HK') )
     and device_id in 
(select device_id
from myth.device_activate
where day_time>=${beginDate} and day_time<=${endDate}
and version_name ='1.3.0'
and country not in ('CN','HK')) 
group by 1,2,3) a 
left join 
(select role_id,day_time
      from myth_server.server_enter_dungeon
     where  day_time between ${beginDate} and ${endDate}   and server_id in (20001,20002,20003)
     and game_type=4
     and role_id in (select role_id
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${endDate}
and server_id in (20001,20002,20003) 
and version_name ='1.3.0'
and country not in ('CN','HK') )
     and device_id in 
(select device_id
from myth.device_activate
where day_time>=${beginDate} and day_time<=${endDate}
and version_name ='1.3.0'
and country not in ('CN','HK'))  ) c  
on a.role_id=c.role_id and a.day_time=c.day_time
where c.role_id is null 
) a 
left join
(
select role_id,day_time,log_time,btn_type
from myth_server.server_hud_click
where  day_time between ${beginDate} and ${endDate}   and server_id in (20001,20002,20003)
and btn_style =1
--and btn_type not in ('pray','character','mail','settle','quest','divine','bag','world')
union all
select role_id,day_time,log_time, 
case when game_type =3 then '战役'
     when game_type =2 then '秘境'
     when game_type =4 then '竞技场'
     when game_type =6 then '远古战场'
     when game_type =7 then '地精宝库'
     else '其他'
     end as btn_type
      from myth_server.server_enter_dungeon
     where  day_time between ${beginDate} and ${endDate}   and server_id in (20001,20002,20003)
      
) d 
on a.role_id=d.role_id
where d.log_time>end_time  and a.day_time=d.day_time
 







-- 生命周期看关卡难度
select birth_dt,a.role_id,datediff(login_dt,birth_dt)+1 as '天数',dungeon_id,duration,评级,battle_result
from

(
select role_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (20001,20002,20003) 
and version_name ='1.3.0'
and country not in ('CN','HK')
and device_id in 
               (select device_id
               from myth.device_activate
               where day_time>=${beginDate} and day_time<=${endDate}
               and version_name ='1.3.0'
               and country not in ('CN','HK')) 
               group by 1,2
               )as a

left join

(select * from
(
select b.role_id as role_id,login_dt,dungeon_id,duration ,评级,battle_result
from
(select role_id,to_date(cast(date_time as timestamp)) as login_dt,day_time
from myth.server_role_login
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (20001,20002,20003) 
and version_name ='1.3.0'
and country not in ('CN','HK')
group by 1,2,3) as b
left join
(select * from
(select a.dungeon_id as dungeon_id ,a.role_id,a.start_time,end_time,(end_time-a.start_time)/60000 as duration,
       case when (end_time-a.start_time)/60000 is null then '无日志'
            when (end_time-a.start_time)/60000 > 3  then '超时'
            when (end_time-a.start_time)/60000 > 2 and (end_time-a.start_time)/60000 <= 3  then '困难'
            when (end_time-a.start_time)/60000 > 1 and (end_time-a.start_time)/60000 <= 2  then '一般'
            when (end_time-a.start_time)/60000 > 0 and (end_time-a.start_time)/60000 <= 1  then '轻松'
            else '无日志'
       end as '评级',battle_result,a.day_time as day_time
from 
(select dungeon_id,role_id,day_time,start_time
     from myth_server.server_enter_dungeon
     where  day_time between ${beginDate} and ${endDate}   and server_id in (20001,20002,20003)
     and game_type=3
group by 1,2,3,4
) as a

left join     
(select dungeon_id,role_id,day_time,log_time  as end_time,start_time,battle_result
     from myth_server.server_dungeon_end
     where  day_time between ${beginDate} and ${endDate}   and server_id in (20001,20002,20003)
     and game_type=3
) b 
on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time=b.start_time
order by a.role_id,a.start_time asc 
) as e ) as c
on b.role_id = c.role_id and b.day_time = c.day_time
) as d 
) as b 
on a.role_id = b.role_id
group by 1,2,3,4,5,6,7










-- -- 点击某新手引导，未进入关卡的人，第二天有没有登录 一条一条一天一天算

-- select a.day_times,count(distinct case when (datediff(b.day_times,a.day_times) = 1) then a.role_id else null end) as num
-- from
-- (
-- select a.role_id as role_id,day_times
-- from 

-- (select role_id,day_time,to_date(cast(date_time as timestamp)) as day_times
--      from myth.server_newbie
--      where  day_time between ${beginDate} and ${endDate}   and server_id in (20001,20002,20003)
--      and version_name ='1.3.0'
--      and step='1025020'
--      and role_id in (select role_id
-- from myth.server_role_create 
-- where day_time>=${beginDate} and day_time<=${endDate}
-- and server_id in (20001,20002,20003) 
-- and version_name ='1.3.0'
-- and country not in ('CN','HK'))
-- and device_id in 
-- (select device_id
-- from myth.device_activate
-- where day_time>=${beginDate} and day_time<=${endDate}
-- and version_name ='1.3.0'
-- and country not in ('CN','HK')) 
-- group by 1,2,3) a 


-- left join 
-- (select role_id,day_time
--       from myth_server.server_enter_dungeon
--      where  day_time between ${beginDate} and ${endDate}   and server_id in (20001,20002,20003)
--      and game_type=3
--      and dungeon_id = 35
--      and role_id in (select role_id
-- from myth.server_role_create 
-- where day_time>=${beginDate} and day_time<=${endDate}
-- and server_id in (20001,20002,20003) 
-- and version_name ='1.3.0'
-- and country not in ('CN','HK') )
--      and device_id in 
-- (select device_id
-- from myth.device_activate
-- where day_time>=${beginDate} and day_time<=${endDate}
-- and version_name ='1.3.0'
-- and country not in ('CN','HK'))  
-- ) c  
-- on a.day_time=c.day_time and a.role_id=c.role_id
-- where c.role_id is null 
-- group by 1,2
-- ) a 

-- left join     
-- (select role_id, to_date(cast(date_time as timestamp)) as day_times
-- from myth.server_role_login
-- where day_time between ${beginDate} and ${endDate}   and server_id in (20001,20002,20003)
-- and version_name ='1.3.0'
-- and country not in ('CN','HK')
-- group by 1,2
-- ) as b 

-- on a.role_id = b.role_id
-- group by 1





-- 生命周期，新手引导  要一天一天算
-- select datediff(login_dt,birth_dt)+1 as by_day,step,count(distinct a.role_id)
-- from
-- (
-- select role_id,to_date(cast(date_time as timestamp)) as birth_dt
-- from myth.server_role_create 
-- where day_time>=${beginDate} and day_time<=${endDate} 
-- and server_id in (20001,20002,20003) 
-- and version_name ='1.3.0'
-- and country not in ('CN','HK')
-- and device_id in 
-- (select device_id
-- from myth.device_activate
-- where day_time>=${beginDate} and day_time<=${endDate}
-- and version_name ='1.3.0'
-- and country not in ('CN','HK')) 
-- group by 1,2
-- ) as a

-- left join

-- (select * from
-- (
-- select b1.role_id as role_id,login_dt,step
-- from
-- (select role_id,to_date(cast(date_time as timestamp)) as login_dt,day_time
-- from myth.server_role_login
-- where day_time>=${beginDate} and day_time<=${endDate} 
-- and server_id in (20001,20002,20003) 
-- and version_name ='1.3.0'
-- and country not in ('CN','HK')
-- and role_id in 
--               (select role_id
--               from
--               (select device_id from myth.device_activate where day_time between ${beginDate} and ${endDate}
--               and channel_id=1000
--               and version_name ='1.3.0'   
--               and country not in ('CN','HK')
--               group by 1
--               ) as a
--               left join
--               (select device_id,role_id
--               from myth.server_role_create
--               where day_time between ${beginDate} and ${endDate} and server_id in (20001,20002,20003)
--               group by 1,2) as b
--               on a.device_id = b.device_id
--               group by 1)
-- group by 1,2,3) as b1

-- left join

-- (select role_id,day_time,step
-- from myth.server_newbie
-- where  day_time between ${beginDate} and ${endDate} and server_id in (20001,20002,20003)
-- and version_name ='1.3.0'
-- and country not in ('CN','HK')
-- and role_id in 
--               (select role_id
--               from
--               (select device_id from myth.device_activate where day_time between ${beginDate} and ${endDate}
--               and channel_id=1000
--               and version_name ='1.3.0'   
--               and country not in ('CN','HK')
--               group by 1
--               ) as a
--               left join
--               (select device_id,role_id
--               from myth.server_role_create
--               where day_time between ${beginDate} and ${endDate} and server_id in (20001,20002,20003)
--               group by 1,2) as b
--               on a.device_id = b.device_id
--               group by 1)
-- group by 1,2,3
-- order by 3

-- union all

-- select role_id,day_time,step
-- from myth_server.server_event_guide
-- where  day_time between ${beginDate} and ${endDate} and server_id in (20001,20002,20003)
-- and version_name ='1.3.0'
-- and country not in ('CN','HK')
-- and role_id in 
--               (select role_id
--               from
--               (select device_id from myth.device_activate where day_time between ${beginDate} and ${endDate}
--               and channel_id=1000
--               and version_name ='1.3.0'   
--               and country not in ('CN','HK')
--               group by 1
--               ) as a
--               left join
--               (select device_id,role_id
--               from myth.server_role_create
--               where day_time between ${beginDate} and ${endDate} and server_id in (20001,20002,20003)
--               group by 1,2) as b
--               on a.device_id = b.device_id
--               group by 1)
-- group by 1,2,3
-- order by 3
-- ) as b2

-- on b1.role_id = b2.role_id and b1.day_time = b2.day_time
-- group by 1,2,3
-- ) as b3
-- ) as b

-- on a.role_id = b.role_id
-- group by 1,2
-- order by 1,2






-- 生命周期，关卡通关  要一天一天算

-- select birth_dt, datediff(login_dt,birth_dt)+1 as by_day,dungeon_id,battle_result,count(distinct a.role_id)
-- from
-- (
-- select role_id,to_date(cast(date_time as timestamp)) as birth_dt
-- from myth.server_role_create 
-- where day_time>=${beginDate} and day_time<=${endDate} 
-- and server_id in (20001,20002,20003) 
-- and version_name ='1.3.0'
-- and country not in ('CN','HK')
-- and device_id in 
-- (select device_id
-- from myth.device_activate
-- where day_time>=${beginDate} and day_time<=${endDate}
-- and version_name ='1.3.0'
-- and country not in ('CN','HK')) 
-- group by 1,2
-- ) as a
-- left join

-- (select b1.role_id as role_id,login_dt,dungeon_id,battle_result
-- from
-- (select role_id,to_date(cast(date_time as timestamp)) as login_dt,day_time
-- from myth.server_role_login
-- where day_time>=${beginDate} and day_time<=${endDate} 
-- and server_id in (20001,20002,20003) 
-- and version_name ='1.3.0'
-- and country not in ('CN','HK')
-- group by 1,2,3
-- ) as b1
-- left join

-- (select role_id,day_time,dungeon_id,battle_result
-- from
-- (select a.role_id as role_id,day_time,a.dungeon_id as dungeon_id,battle_result,row_number() over(partition by a.role_id,a.dungeon_id,day_time order by log_time desc) as num
-- from
-- (select dungeon_id,role_id,day_time
-- from myth_server.server_enter_dungeon
-- where day_time between ${beginDate} and ${endDate}   and server_id in (20001,20002,20003)
-- and game_type=3
-- and channel_id=1000
-- and version_name ='1.3.0'   
-- and country not in ('CN','HK')
-- group by 1,2,3) a 
-- left join 
-- (select dungeon_id,role_id,battle_result,log_time
-- from myth_server.server_dungeon_end
-- where day_time between ${beginDate} and ${endDate}   and server_id in (20001,20002,20003)
-- and game_type=3
-- and channel_id=1000
-- and version_name ='1.3.0'   
-- and country not in ('CN','HK')
-- group by 1,2,3,4) b 
-- on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id
-- ) as c
-- where num = 1
-- group by 1,2,3,4
-- ) as b2 
-- on b1.role_id = b2.role_id and b1.day_time = b2.day_time

-- group by 1,2,3,4
-- ) as b

-- on a.role_id = b.role_id
-- group by 1,2,3,4
-- order by 1,2,3














在线时长次留
select
     b.day_time_a as day_time,
     on_time_interval,
     sum(case when by_day = 0 then 1 else 0 end) '新增',
     sum(case when by_day = 1 then 1 else 0 end) day_2
from
(
     select 
          device_id_b as device_id,
          day_time_a,-- first_day
          day_time_b,
          datediff(day_time_b,day_time_a) as by_day, -- 间隔
          on_time_interval
     from
          (select 
               b.device_id as device_id_b,
               a.day_times as day_time_a,
               b.day_times as day_time_b,
               on_time_interval
          from
                (
                select 
                    device_id,
                    to_date(cast(date_time as timestamp)) as day_times 
                from myth.device_launch
                where day_time >= ${start_time} and day_time <= ${endDate}
                group by 1,2
               ) b 

          right join 

               (
               select a.device_id as device_id,a.day_times as day_times,
               case when on_time <= 5 then '(0,5]'
                    when on_time > 5 and on_time <= 10 then '(5,10]'
                    when on_time > 10 and on_time <= 30 then '(10,30]'
                    when on_time > 30 then '30+'
               else 'other'
               end as on_time_interval
               from
               (select 
                    device_id,
                    to_date(cast(date_time as timestamp)) as day_times
               from 
                    myth.device_activate
               where day_time >= ${start_time} and day_time <= ${endDate}
               and channel_id=1000
               and version_name ='1.3.0'   
               and country not in ('CN','HK')
               group by 1,2) as a
               left join
               (select device_id,to_date(cast(date_time as timestamp)) as day_times,count(ping) as on_time 
               from myth.client_online
               where day_time >= ${start_time} and day_time <= ${endDate}
               and channel_id=1000
               and version_name ='1.3.0'   
               and country not in ('CN','HK')
               group by 1,2) as b
               on a.device_id = b.device_id and a.day_times = b.day_times
               ) a
               on a.device_id = b.device_id
          ) as reu
     order by device_id_b,day_time_b          
) as b

group by 1,2
order by 1