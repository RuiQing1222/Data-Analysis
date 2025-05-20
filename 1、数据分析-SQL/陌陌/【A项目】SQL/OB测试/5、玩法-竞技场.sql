玩法系统数据分析  

玩法——4->竞技场
 
select PVP生命周期, 
       case when 胜率 >= 0 and 胜率 < 50 then '0-49'
            when 胜率 >= 50 and 胜率 < 70 then '50-69'
            when 胜率 >= 70 and 胜率 < 80 then '70-79'
            when 胜率 >= 80 and 胜率 < 90 then '80-89'
            when 胜率 >= 90 then '90+'
            else NULL
       end as '胜率分布',
       count(distinct role_id) as '参与人数',
       sum(num) as '参与次数',
       count(distinct case when auto_num > 0 then role_id else null end) as '自动战斗使用人数',
       sum(auto_num) as '自动战斗使用次数'
from 
(
select a.role_id as role_id,birth_dt,datediff(pvp_dt,birth_dt)+1 as 'PVP生命周期',
       round(count(case when fighting_result=1 then 1 else null end)/count(1)*100,2) as '胜率',
       count(start_time) as num,
       count(case when auto_battle =1 then start_time else null end) as auto_num
from

(select role_id,birth_dt
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and version_name ='1.5.0'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${endDate}
and version_name ='1.5.0'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
) a 

left join
( -- 参与竞技场的玩家  若fighting_result为空则是无日志
select b1.role_id as role_id,pvp_dt,fighting_result,auto_battle,b1.start_time as start_time
from
(select role_id,to_date(cast(date_time as timestamp)) as pvp_dt,start_time
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 4
and version_name ='1.5.0'
and country not in ('CN','HK')
group by 1,2,3
) b1
left join
(select role_id,start_time,fighting_result,auto_battle
from myth_server.server_arena
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and version_name ='1.5.0'
and country not in ('CN','HK')     
) b2
on b1.role_id = b2.role_id and b1.start_time = b2.start_time
group by 1,2,3,4,5
) b
on a.role_id=b.role_id
where datediff(pvp_dt,birth_dt) is not null
group by 1,2,3
order by 1,2
) as a 
group by 1,2





竞技场的首次胜率


select  auto_battle,fighting_result,count(distinct a.role_id)
from 
(select role_id,birth_dt
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and version_name ='1.5.0'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${endDate}
and version_name ='1.5.0'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id --and a1.birth_dt = a2.device_birth_dt
) a 

left join

(select b.role_id,pvp_dt,fighting_result,auto_battle,b.start_time
  from 
( -- 参与竞技场的玩家  若fighting_result为空则是无日志
select role_id,pvp_dt,start_time
from
(select role_id,to_date(cast(date_time as timestamp)) as pvp_dt,start_time,
  row_number()over(partition by role_id order by log_time asc) as row_num1
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 4
and version_name ='1.5.0'
and country not in ('CN','HK')
) b1
where row_num1 =1 
) b 
left join
(
select role_id,start_time,fighting_result,auto_battle
from 
(select role_id,start_time,fighting_result,auto_battle,
  row_number()over(partition by role_id order by log_time asc) as row_num2
from myth_server.server_arena
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and version_name ='1.5.0'
and country not in ('CN','HK')     
) c1
where row_num2 =1 
) c 
on b.role_id = c.role_id and b.start_time = c.start_time
group by 1,2,3,4,5
) d 
on a.role_id = d.role_id
where d.role_id  is not null 
group by 1,2













整体情况 胜率分布->时长分布
select PVP生命周期,duration,fighting_result,auto_battle,
count(distinct role_id) as users,
count(start_time) as nums  
from 
(
select a.role_id as role_id,datediff(pvp_dt,birth_dt)+1 as 'PVP生命周期',duration,fighting_result,start_time,auto_battle
from

(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name ='1.5.0'
and channel_id in (1000,2000)
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name ='1.5.0'
and channel_id in (1000,2000)
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id --and a1.birth_dt = a2.device_birth_dt
) as a

left join
( -- 参与竞技场的玩家  若fighting_result为空则是无日志
select b1.role_id as role_id,pvp_dt,fighting_result,auto_battle,b1.start_time as start_time,--参与次数
       case when (end_time-b1.start_time)/60000 is null then '无日志'
            when (end_time-b1.start_time)/60000 > 1                                             then '1超时'
            when (end_time-b1.start_time)/60000 > 0.4 and (end_time-b1.start_time)/60000 <= 1   then '2困难'
            when (end_time-b1.start_time)/60000 > 0.2 and (end_time-b1.start_time)/60000 <= 0.4 then '3较难'
            when (end_time-b1.start_time)/60000 > 0   and (end_time-b1.start_time)/60000 <= 0.2 then '4一般'
            else '无日志'
       end as duration
from
(select role_id,to_date(cast(date_time as timestamp)) as pvp_dt,start_time
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 4
and version_name ='1.5.0'
and channel_id in (1000,2000)
and country not in ('CN','HK')
group by 1,2,3
) b1
left join
(select role_id,start_time,fighting_result,auto_battle,log_time as end_time
from myth_server.server_arena
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and version_name ='1.5.0'
and channel_id in (1000,2000)
and country not in ('CN','HK') 
group by 1,2,3,4,5    
) b2
on b1.role_id = b2.role_id and b1.start_time = b2.start_time
group by 1,2,3,4,5,6
) b
on a.role_id=b.role_id
group by 1,2,3,4,5,6
) as a 
group by 1,2,3,4



活跃维度 战力比在0.9到1.1之间的胜率和时长

select cycle_id,auto_battle,
case when fighting_result=1 then '胜利'
     when fighting_result=2 then '失败'
     else '无日志'
     end as '胜率',
case when role_level<30  then '30-'
     when role_level>=30 and role_level<40 then '30'
     when role_level>=40 and role_level<50 then '40'
     when role_level>=50 and role_level<60 then '50'
     when role_level>=60 and role_level<70 then '60'
     when role_level>=70 and role_level<80 then '70'
     when role_level>=80 and role_level<90 then '80'
     when role_level>=90                   then '90'
   end as level_zone,
   appx_median(battle_time) as median_battle_time,
   count(1) as nums
from 

(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name ='1.5.0'
and channel_id in (1000,2000)
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name ='1.5.0'
and channel_id in (1000,2000)
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id --and a1.birth_dt = a2.device_birth_dt
) as a
left join 
(select a.role_id,a.cycle_id,auto_battle,role_level,fighting_result,battle_points,def_battle_points,battle_time
  from 
(select role_id,start_time,cycle_id,role_level
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and game_type = 4
and channel_id in (1000,2000)
and version_name ='1.5.0'
and country not in ('CN','HK')
group by 1,2,3,4
) a
left  join 
(
select role_id,def_role_pos,case auto_battle
when 0 then '手动'
when 1 then '自动'
else '未知'
end as auto_battle,start_time,
fighting_result,cycle_id,battle_points,def_battle_points,(log_time-start_time)/1000 as battle_time
from myth_server.server_arena
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id in (1000,2000)
and version_name ='1.5.0'
and country not in ('CN','HK')
and battle_points/def_battle_points>=0.9
and battle_points/def_battle_points<=1.1     
) b
on a.cycle_id=b.cycle_id and a.role_id = b.role_id and a.start_time =b.start_time 
) c 
on a.role_id =c.role_id 
where c.role_id is not null 
group by 1,2,3,4




超时的比例

select cycle_id,auto_battle,
case when fighting_result=1 then '胜利'
     when fighting_result=2 then '失败'
     else '无日志'
     end as '胜率',
case when role_level<30  then '30-'
     when role_level>=30 and role_level<40 then '30'
     when role_level>=40 and role_level<50 then '40'
     when role_level>=50 and role_level<60 then '50'
     when role_level>=60 and role_level<70 then '60'
     when role_level>=70 and role_level<80 then '70'
     when role_level>=80 and role_level<90 then '80'
     when role_level>=90                   then '90'
   end as level_zone,
   count(1) as nums
from 

(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name ='1.5.0'
and channel_id in (1000,2000)
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name ='1.5.0'
and channel_id in (1000,2000)
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id --and a1.birth_dt = a2.device_birth_dt
) as a
left join 
(select a.role_id,a.cycle_id,auto_battle,role_level,fighting_result,battle_points,def_battle_points,battle_time
  from 
(select role_id,start_time,cycle_id,role_level
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and game_type = 4
and channel_id in (1000,2000)
and version_name ='1.5.0'
and country not in ('CN','HK')
group by 1,2,3,4
) a
left  join 
(
select role_id,def_role_pos,case auto_battle
when 0 then '手动'
when 1 then '自动'
else '未知'
end as auto_battle,start_time,
fighting_result,cycle_id,battle_points,def_battle_points,(log_time-start_time)/1000 as battle_time
from myth_server.server_arena
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id in (1000,2000)
and version_name ='1.5.0'
and country not in ('CN','HK')
and battle_points/def_battle_points>=0.9
and battle_points/def_battle_points<=1.1     
) b
on a.cycle_id=b.cycle_id and a.role_id = b.role_id and a.start_time =b.start_time 
where battle_time >=60
) c 
on a.role_id =c.role_id 
where c.role_id is not null 
group by 1,2,3,4




位置胜率

select cycle_id,def_role_pos,auto_battle,
sum(win_roles) as wins,sum(join_roles) as joins 
-- fighting_result,
-- sum(battle_points) as battle_points,
-- sum(def_battle_points) as def_battle_points
from 


(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name ='1.5.0'
and channel_id in (1000,2000)
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name ='1.5.0'
and channel_id in (1000,2000)
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id --and a1.birth_dt = a2.device_birth_dt
) as a

left join

(select a.cycle_id,def_role_pos,auto_battle,a.role_id,
count(a.role_id) as 'join_roles',
count(case when fighting_result =1 then b.role_id else null end ) as 'win_roles'
-- fighting_result,battle_points,def_battle_points
from 

(select role_id,start_time,cycle_id -- 不取第一次进入（新手引导）
from
(select role_id,start_time,cycle_id,row_number() over(partition by role_id order by log_time asc) as row_num
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and game_type = 4
and channel_id in (1000,2000)
and version_name ='1.5.0'
and country not in ('CN','HK')
) a1
where row_num <> 1 
group by 1,2,3
) a

left join 
(
select role_id,start_time,def_role_pos,
case auto_battle
when 0 then '手动'
when 1 then '自动'
else '未知'
end as auto_battle,
fighting_result,cycle_id,log_time as end_time,battle_points,def_battle_points
from myth_server.server_arena
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id in (1000,2000)
and version_name ='1.5.0'
and country not in ('CN','HK')     
) b
on a.cycle_id=b.cycle_id and a.role_id = b.role_id and a.start_time =b.start_time 
where def_role_pos is not null 
group by 1,2,3,4
) c 
on a.role_id =c.role_id
group by 1,2,3











天复玩率
整体 -- 复玩率
select 积分,胜率分布,count(distinct a.role_id) as '进入总人数',count(distinct case when 是否复玩 = '是' then a.role_id else null) as '复玩人数'
from

(select cycle_id,role_id,case when a2.role_id is null then '否' else '是' end as '是否复玩'
from
(select role_id,cycle_id,to_date(cast(date_time as timestamp)) as done_dt
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 4 -- 4->竞技场
and channel_id in (1000,2000)
and version_name ='1.5.0'
and country not in ('CN','HK')
group by 1,2,3
) as a1
left join
(select role_id,cycle_id,to_date(cast(date_time as timestamp)) as done_dt
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 4 -- 4->竞技场
and channel_id in (1000,2000)
and version_name ='1.5.0'
and country not in ('CN','HK')
group by 1,2,3
) as a2
on a1.role_id = a2.role_id and datediff(a2.done_dt,a1.done_dt)=1
group by 1,2,3
) as a

left join -- 积分分布
(select role_id,case when change_count >=0 and change_count <1000 then '[0,1000)'
                    when change_count >=0 and change_count <1000 then '[0,1000)'
                    when change_count >=0 and change_count <1000 then '[0,1000)'
                    when change_count >=0 and change_count <1000 then '[0,1000)'
                    when change_count >=0 and change_count <1000 then '[0,1000)' -- 积分分段也要等和策划对
                    end as '积分'
from
(SELECT role_id,sum(change_count) as change_count
FROM myth.server_prop
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id in (1000,2000)
and version_name ='1.5.0'
and country not in ('CN','HK')
and prop_id = '3' -- 竞技场积分道具，要和策划要
AND change_type = 'PRODUCE'
and change_method = '51' --竞技场获取方式，要和策划确定是哪一个
group by 1
) as b1
group by 1,2
) as b
on a.role_id = b.role_id

left join -- 胜率分布
(select role_id,cycle_id,
       case when 胜率 >= 0 and 胜率 <= 25 then '0-25'
            when 胜率 >= 26 and 胜率 <= 50 then '26-50'
            when 胜率 >= 51 and 胜率 <= 75 then '51-75'
            when 胜率 >= 76 and 胜率 <= 100 then '76-100'
            else NULL
       end as '胜率分布'
from 
(
select role_id,cycle_id,
       round(count(case when fighting_result=1 then 1 else null end)/count(1)*100,0) as '胜率'
from
( -- 参与竞技场的玩家  若fighting_result为空则是无日志
select c1.role_id as role_id,cycle_id,fighting_result
from
(select role_id,start_time,cycle_id
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 4
and channel_id in (1000,2000)
and version_name ='1.5.0'
and country not in ('CN','HK')
group by 1,2,3
) c1
left join
(select role_id,start_time,cycle_id,fighting_result
from myth_server.server_arena
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id in (1000,2000)
and version_name ='1.5.0'
and country not in ('CN','HK')   
group by 1,2,3,4  
) c2
on c1.role_id = c2.role_id and c1.cycle_id = c2.cycle_id and c1.start_time = c2.start_time
group by 1,2,3
) c3
group by 1,2
) c4
group by 1,2,3
) as c
on a.role_id = c.role_id and a.cycle_id = c.cycle_id

group by 1,2
order by 1,2



整体的钻石 消耗人数、次数
select 积分,胜率分布,count(distinct a.role_id) as '钻石消耗人数',sum(change_num) as '钻石消耗次数',sum(change_count) as '钻石消耗总数'
from
(SELECT role_id,count(log_time) as change_num,sum(change_count) as change_count
FROM myth.server_currency
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id in (1000,2000)
and version_name ='1.5.0'
and country not in ('CN','HK')
and currency_id = '3'
AND change_type = 'CONSUME'
and change_method = '50'
group by 1,2
) as a

left join -- 积分分布
(select role_id,case when change_count >=0 and change_count <1000 then '[0,1000)'
                    when change_count >=0 and change_count <1000 then '[0,1000)'
                    when change_count >=0 and change_count <1000 then '[0,1000)'
                    when change_count >=0 and change_count <1000 then '[0,1000)'
                    when change_count >=0 and change_count <1000 then '[0,1000)' -- 积分分段也要等和策划对
                    end as '积分'
from
(SELECT role_id,sum(change_count) as change_count
FROM myth.server_prop
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id in (1000,2000)
and version_name ='1.5.0'
and country not in ('CN','HK')
and prop_id = '3' -- 竞技场积分道具，要和策划要
AND change_type = 'PRODUCE'
and change_method = '51' --竞技场获取方式，要和策划确定是哪一个
group by 1
) as b1
group by 1,2
) as b
on a.role_id = b.role_id

left join -- 胜率分布
(select role_id,cycle_id,
       case when 胜率 >= 0 and 胜率 <= 25 then '0-25'
            when 胜率 >= 26 and 胜率 <= 50 then '26-50'
            when 胜率 >= 51 and 胜率 <= 75 then '51-75'
            when 胜率 >= 76 and 胜率 <= 100 then '76-100'
            else NULL
       end as '胜率分布'
from 
(
select role_id,cycle_id,
       round(count(case when fighting_result=1 then 1 else null end)/count(1)*100,0) as '胜率'
from
( -- 参与竞技场的玩家  若fighting_result为空则是无日志
select c1.role_id as role_id,cycle_id,fighting_result
from
(select role_id,start_time,cycle_id
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 4
and channel_id in (1000,2000)
and version_name ='1.5.0'
and country not in ('CN','HK')
group by 1,2,3
) c1
left join
(select role_id,start_time,cycle_id,fighting_result
from myth_server.server_arena
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id in (1000,2000)
and version_name ='1.5.0'
and country not in ('CN','HK')   
group by 1,2,3,4  
) c2
on c1.role_id = c2.role_id and c1.cycle_id = c2.cycle_id and c1.start_time = c2.start_time
group by 1,2,3
) c3
group by 1,2
) c4
group by 1,2,3
) as c
on a.role_id = c.role_id and a.cycle_id = c.cycle_id
group by 1,2
order by 1,2

活跃维度 战力比所有的胜率和时长

select 战力区间,
case when fighting_result=1 then '胜利'
     when fighting_result=2 then '失败'
     else '无日志'
     end as '胜率',
case when role_level<30  then '30-'
     when role_level>=30 and role_level<40 then '30'
     when role_level>=40 and role_level<50 then '40'
     when role_level>=50 and role_level<60 then '50'
     when role_level>=60 and role_level<70 then '60'
     when role_level>=70 and role_level<80 then '70'
     when role_level>=80 and role_level<90 then '80'
     when role_level>=90                   then '90'
   end as level_zone,
   appx_median(battle_time) as median_battle_time,
   min(battle_time) as min_battle,
   max(battle_time) as max_battle,
   count(1) as nums
from 

(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name ='1.5.0'
and channel_id in (1000,2000)
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name ='1.5.0'
and channel_id in (1000,2000)
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
) as a
left join 
(select a.role_id,a.cycle_id,auto_battle,role_level,fighting_result,battle_points,def_battle_points,battle_time,战力区间
  from 
(select role_id,start_time,cycle_id,role_level
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and game_type = 4
and channel_id in (1000,2000)
and version_name ='1.5.0'
and country not in ('CN','HK')
group by 1,2,3,4
) a
left  join 
(select role_id,def_role_pos,
auto_battle,start_time,
case when 战力比>0     and 战力比<0.5    then '0.5'
     when 战力比>=0.5  and 战力比<=0.7   then '0.7'
     when 战力比>0.7   and 战力比<=0.9   then '0.9'
     when 战力比>0.9   and 战力比<=1.1   then '1.1'
     when 战力比>1.1   and 战力比<=2     then '2'
     when 战力比>2     and 战力比<=5     then '5'
     when 战力比>5                      then '10'
     end as '战力区间',
fighting_result,cycle_id,battle_points,def_battle_points,battle_time
from      
 (
select role_id,def_role_pos,case auto_battle
when 0 then '手动'
when 1 then '自动'
else '未知'
end as auto_battle,start_time,
battle_points/def_battle_points as '战力比',
fighting_result,cycle_id,battle_points,def_battle_points,(log_time-start_time)/1000 as battle_time
from myth_server.server_arena
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id in (1000,2000)
and version_name ='1.5.0'
and country not in ('CN','HK')
-- and battle_points/def_battle_points>=0.9
-- and battle_points/def_battle_points<=1.1     
) b1
 ) b 
on a.cycle_id=b.cycle_id and a.role_id = b.role_id and a.start_time =b.start_time 
) c 
on a.role_id =c.role_id 
where c.role_id is not null 
group by 1,2,3 


活跃维度 付费档位2&3用户战力比所有的胜率和时长

select cycle_id,auto_battle,战力区间,
case when fighting_result=1 then '胜利'
     when fighting_result=2 then '失败'
     else '无日志'
     end as '胜率',
case when role_level<30  then '30-'
     when role_level>=30 and role_level<40 then '30'
     when role_level>=40 and role_level<50 then '40'
     when role_level>=50 and role_level<60 then '50'
     when role_level>=60 and role_level<70 then '60'
     when role_level>=70 and role_level<80 then '70'
     when role_level>=80 and role_level<90 then '80'
     when role_level>=90                   then '90'
   end as level_zone,
   min(battle_time) as '最短时间',
   appx_median(battle_time) as median_battle_time,
   max(battle_time) as  '最长时间',
   count(1) as nums
from 

(select vip,birth_dt,role_id,total_pay
from 
(select birth_dt,role_id,total_pay,
case when total_pay>0  and total_pay<=8   then 1
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
and channel_id in (1000,2000)
and version_name = '1.4.7'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(date_time) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id in (1000,2000)
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
where total_pay>0 
and vip in (2,3)
) a 

left join 
(select a.role_id,a.cycle_id,auto_battle,role_level,fighting_result,battle_points,def_battle_points,battle_time,战力区间
  from 
(select role_id,start_time,cycle_id,role_level
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and game_type = 4
and channel_id in (1000,2000)
and version_name ='1.5.0'
and country not in ('CN','HK')
group by 1,2,3,4
) a
left  join 
(select role_id,def_role_pos,
auto_battle,start_time,
case when 战力比>0     and 战力比<0.5    then '0.5'
     when 战力比>=0.5  and 战力比<=0.7   then '0.7'
     when 战力比>0.7   and 战力比<=0.9   then '0.9'
     when 战力比>0.9   and 战力比<=1.1   then '1.1'
     when 战力比>1.1   and 战力比<=2     then '2'
     when 战力比>2     and 战力比<=5     then '5'
     when 战力比>5                      then '10'
     end as '战力区间',
fighting_result,cycle_id,battle_points,def_battle_points,battle_time
from      
 (
select role_id,def_role_pos,case auto_battle
when 0 then '手动'
when 1 then '自动'
else '未知'
end as auto_battle,start_time,
battle_points/def_battle_points as '战力比',
fighting_result,cycle_id,battle_points,def_battle_points,(log_time-start_time)/1000 as battle_time
from myth_server.server_arena
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id in (1000,2000)
and version_name ='1.5.0'
and country not in ('CN','HK')
-- and battle_points/def_battle_points>=0.9
-- and battle_points/def_battle_points<=1.1     
) b1
 ) b 
on a.cycle_id=b.cycle_id and a.role_id = b.role_id and a.start_time =b.start_time 
) c 
on a.role_id =c.role_id 
where c.role_id is not null 
group by 1,2,3,4,5




 