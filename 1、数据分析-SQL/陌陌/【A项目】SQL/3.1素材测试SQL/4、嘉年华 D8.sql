--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
嘉年华

完成任务人数



select datediff(done_dt,birth_dt)+1 as '天数',
avg(integral) as avg_integral,
count(distinct case when task_num>10 then  a.role_id else null end ) as '超过10个',
count(distinct case when task_num=10 then  a.role_id else null end ) as '完成10个',
count(distinct case when task_num=9  then  a.role_id else null end ) as '完成9个',
count(distinct case when task_num=8  then  a.role_id else null end ) as '完成8个',
count(distinct case when task_num=7  then  a.role_id else null end ) as '完成7个',
count(distinct case when task_num=6  then  a.role_id else null end ) as '完成6个',
count(distinct case when task_num=5  then  a.role_id else null end ) as '完成5个',
count(distinct case when task_num=4  then  a.role_id else null end ) as '完成4个',
count(distinct case when task_num=3  then  a.role_id else null end ) as '完成3个',
count(distinct case when task_num=2  then  a.role_id else null end ) as '完成2个',
count(distinct case when task_num=1 then  a.role_id else null end ) as '完成1个'
from 
(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(hours_add(date_time,-18)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(hours_add(date_time,-18)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
group by 1,2
)  a
left join 
(
select role_id,to_date(hours_add(date_time,-18)) as done_dt,count(distinct task_id) as task_num,max(integral) as integral
from myth_server.server_carnival_task_completed
where day_time>=${beginDate} and day_time<=${EndDate}
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2
) b 
on a.role_id=b.role_id
group by 1


select 
count(case when D1完成=10 then role_id else null end ) as 'D1人数',
count(case when D2完成=20 then role_id else null end ) as 'D2人数',
count(case when D3完成=30 then role_id else null end ) as 'D3人数',
count(case when D4完成=40 then role_id else null end ) as 'D4人数',
count(case when D5完成=50 then role_id else null end ) as 'D5人数',
count(case when D6完成=60 then role_id else null end ) as 'D6人数',
count(case when D7完成=70 then role_id else null end ) as 'D7人数',
count(case when D8完成=70 then role_id else null end ) as 'D8人数',
count(case when D9完成=70 then role_id else null end ) as 'D9人数',
count(case when D10完成=70 then role_id else null end ) as 'D10人数',
count(case when 全部完成=70                 then role_id else null end ) as '全部完成人数',
count(case when 全部完成>=53 and 全部完成<70 then role_id else null end ) as '75%完成人数',
count(case when 全部完成>=35 and 全部完成<53 then role_id else null end ) as '50%完成人数',
count(case when 全部完成>=18 and 全部完成<35 then role_id else null end ) as '25%完成人数'
from 
(select a.role_id,
count(distinct case when datediff(done_dt,birth_dt)=0   then  task_id else null end ) as 'D1完成',
count(distinct case when datediff(done_dt,birth_dt)<=1  then  task_id else null end ) as 'D2完成',
count(distinct case when datediff(done_dt,birth_dt)<=2  then  task_id else null end ) as 'D3完成',
count(distinct case when datediff(done_dt,birth_dt)<=3  then  task_id else null end ) as 'D4完成',
count(distinct case when datediff(done_dt,birth_dt)<=4  then  task_id else null end ) as 'D5完成',
count(distinct case when datediff(done_dt,birth_dt)<=5  then  task_id else null end ) as 'D6完成',
count(distinct case when datediff(done_dt,birth_dt)<=6  then  task_id else null end ) as 'D7完成',
count(distinct case when datediff(done_dt,birth_dt)<=7  then  task_id else null end ) as 'D8完成',
count(distinct case when datediff(done_dt,birth_dt)<=8  then  task_id else null end ) as 'D9完成',
count(distinct case when datediff(done_dt,birth_dt)<=9  then  task_id else null end ) as 'D10完成',
count(distinct task_id) as '全部完成'
from 
(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(hours_add(date_time,-18)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(hours_add(date_time,-18)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
group by 1,2
)  a
left join 
(
select role_id,to_date(hours_add(date_time,-18)) as done_dt,task_id
from myth_server.server_carnival_task_completed
where day_time>=${beginDate} and day_time<=${EndDate}
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3
) b 
on a.role_id=b.role_id
group by 1) t 



积分进度
select count(case when max_integral=350                       then a.role_id else null end ) as '350进度',
       count(case when max_integral>=300 and max_integral<350 then a.role_id else null end ) as '300进度',
       count(case when max_integral>=250 and max_integral<300 then a.role_id else null end ) as '250进度',
       count(case when max_integral>=200 and max_integral<250 then a.role_id else null end ) as '200进度',
       count(case when max_integral>=150 and max_integral<200 then a.role_id else null end ) as '150进度',
       count(case when max_integral>=100 and max_integral<150 then a.role_id else null end ) as '100进度',
       count(case when max_integral>=50  and max_integral<100 then a.role_id else null end ) as '50进度'
from 
(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(hours_add(date_time,-18)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(hours_add(date_time,-18)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
group by 1,2
)  a
left join 
(
select role_id,max(integral) as max_integral
from myth_server.server_carnival_task_completed
where day_time>=${beginDate} and day_time<=${EndDate}
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1
) b 
on a.role_id=b.role_id
 


任务完成率

select task_id,count(distinct a.role_id)
from 
(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(hours_add(date_time,-18)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(hours_add(date_time,-18)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
group by 1,2
)  a
left join 
-- (
-- select role_id,to_date(hours_add(date_time,-18)) as done_dt,task_id
-- from myth_server.server_complete_task
-- where day_time>=${beginDate} and day_time<=${EndDate}
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- and task_type = 8 
-- group by 1,2,3
-- ) c 
(
select role_id,to_date(hours_add(date_time,-18)) as done_dt,task_id
from myth_server.server_carnival_task_completed
where day_time>=${beginDate} and day_time<=${EndDate}
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3
) c 
on a.role_id=c.role_id
where task_id is not null 
group by 1

次日活跃
select 
-- count(distinct case when datediff(online_dt,birth_dt)>=1 and datediff(online_dt,birth_dt)<13 then a.role_id else null end ) as '2日活跃',
-- count(distinct case when datediff(online_dt,birth_dt)>=2 and datediff(online_dt,birth_dt)<13 then a.role_id else null end ) as '3日活跃',
-- count(distinct case when datediff(online_dt,birth_dt)>=3 and datediff(online_dt,birth_dt)<13 then a.role_id else null end ) as '4日活跃',
-- count(distinct case when datediff(online_dt,birth_dt)>=4 and datediff(online_dt,birth_dt)<13 then a.role_id else null end ) as '5日活跃',
-- count(distinct case when datediff(online_dt,birth_dt)>=5 and datediff(online_dt,birth_dt)<13 then a.role_id else null end ) as '6日活跃',
-- count(distinct case when datediff(online_dt,birth_dt)>=6 and datediff(online_dt,birth_dt)<13 then a.role_id else null end ) as '7日活跃',
-- count(distinct case when datediff(online_dt,birth_dt)>=7 and datediff(online_dt,birth_dt)<13 then a.role_id else null end ) as '8日活跃',
-- count(distinct case when datediff(online_dt,birth_dt)>=8 and datediff(online_dt,birth_dt)<13 then a.role_id else null end ) as '9日活跃',
-- count(distinct case when datediff(online_dt,birth_dt)>=9 and datediff(online_dt,birth_dt)<13 then a.role_id else null end ) as '10日活跃'
count(distinct case when datediff(online_dt,birth_dt)=1 then a.role_id else null end ) as '2日活跃',
count(distinct case when datediff(online_dt,birth_dt)=2 then a.role_id else null end ) as '3日活跃',
count(distinct case when datediff(online_dt,birth_dt)=3 then a.role_id else null end ) as '4日活跃',
count(distinct case when datediff(online_dt,birth_dt)=4 then a.role_id else null end ) as '5日活跃',
count(distinct case when datediff(online_dt,birth_dt)=5 then a.role_id else null end ) as '6日活跃',
count(distinct case when datediff(online_dt,birth_dt)=6 then a.role_id else null end ) as '7日活跃',
count(distinct case when datediff(online_dt,birth_dt)=7 then a.role_id else null end ) as '8日活跃',
count(distinct case when datediff(online_dt,birth_dt)=8 then a.role_id else null end ) as '9日活跃',
count(distinct case when datediff(online_dt,birth_dt)=9 then a.role_id else null end ) as '10日活跃'
from 
-- (select birth_dt,a.role_id
-- from
(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(hours_add(date_time,-18)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(hours_add(date_time,-18)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
group by 1,2
) as a
left join 
-- (select role_id,to_date(hours_add(date_time,-18)) as done_dt
-- from myth_server.server_dungeon_end
-- where day_time between 20230105 and ${doneDate} and server_id in (${serverIds})
-- and game_type = 3 -- 3->战役
-- and channel_id=1000  --Android
-- and dungeon_id = 6 
-- and battle_result = 1
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- group by 1,2
-- )  d 
-- on a.role_id=d.role_id  and a.birth_dt=d.done_dt
-- where d.role_id is not null 
-- group by 1,2 ) a 
-- left join 
(
select role_id,to_date(hours_add(date_time,-18)) as online_dt
from myth.client_online 
where day_time between 20230105 and ${onlineDate} and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) e 
on a.role_id = e.role_id
 


 
--验证
-- select task_num ,count(distinct role_id)
-- from 
-- (
-- select role_id,count(distinct task_id) as task_num
-- from myth_server.server_carnival_task_completed
-- where day_time>=${beginDate} and day_time<=${EndDate}
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- and role_id in 
-- (  --新增
-- select role_id
-- from
-- (select role_id,device_id,to_date(hours_add(date_time,-18)) as birth_dt
-- from myth.server_role_create 
-- where day_time>=${beginDate} and day_time<=${birthEndDate} 
-- and server_id in (${serverIds}) 
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- ) as a1
-- right join
-- (select device_id,to_date(hours_add(date_time,-18)) as device_birth_dt
-- from myth.device_activate
-- where day_time>=${beginDate} and day_time<=${birthEndDate}
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- ) as a2 
-- on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
-- group by 1
-- )  
-- group by 1
-- ) t 
-- group by 1

