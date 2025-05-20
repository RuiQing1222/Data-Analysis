房间切换
select birth_dt,country,dungeon_id,post_scene,count(distinct b.role_id)
from
(  --新增
select role_id,birth_dt,country
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name in('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt, 
     case when country= 'PH' then 'PH'
     when country in ('AU','NZ')  then 'Oceania'
     when country in ('GB','IE')  then 'GB'
     when country ='CA'  then 'CA'
     when country ='MY'  then 'MY'
     when country in ('NO','SE','FI','DK')  then 'Nordic'
     else 'others'
     end as country
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name in('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
) as a

left join
(select role_id,dungeon_id,pre_scene,post_scene,battle_time,start_time
from myth_server.server_scene_enter
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 3 -- 3->战役
and channel_id=1000  --Android
and version_name in('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3,4,5,6
) as b 
on a.role_id = b.role_id
group by 1,2,3,4
order by 1,2,3,4







引导流失：先算新手引导绝对人数、再算各个关卡的进入+通关的绝对人数，最后按照节奏表整理数据

-- 新手引导流程
select datediff(login_dt,birth_dt)+1 as by_day,country,step,count(distinct a.role_id)
from

(  --新增 直接生命周期全部算出来，但是新手引导是单天看
select role_id,birth_dt,country
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name in('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt, 
     case when country= 'PH' then 'PH'
     when country in ('AU','NZ')  then 'Oceania'
     when country in ('GB','IE')  then 'GB'
     when country ='CA'  then 'CA'
     when country ='MY'  then 'MY'
     when country in ('NO','SE','FI','DK')  then 'Nordic'
     else 'others'
     end as country
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name in('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
) as a

left join
(select role_id,login_dt,step from
(
       
select b1.role_id as role_id,login_dt,step
from
(select role_id,to_date(cast(date_time as timestamp)) as login_dt,day_time
from myth.server_role_login
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and version_name in('1.4.0','1.4.1')
and country not in ('CN','HK')
and role_id in 
              (select role_id
              from
              (select device_id from myth.device_activate where day_time between ${beginDate} and ${endDate}
              and channel_id=1000
              and version_name in('1.4.0','1.4.1')   
              and country not in ('CN','HK')
              group by 1
              ) as a
              left join
              (select device_id,role_id
              from myth.server_role_create
              where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
              group by 1,2) as b
              on a.device_id = b.device_id
              group by 1)
group by 1,2,3) as b1

left join

(select role_id,day_time,step
from myth.server_newbie
where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and version_name in('1.4.0','1.4.1')
and country not in ('CN','HK')
and role_id in 
              (select role_id
              from
              (select device_id from myth.device_activate where day_time between ${beginDate} and ${endDate}
              and channel_id=1000
              and version_name in('1.4.0','1.4.1')   
              and country not in ('CN','HK')
              group by 1
              ) as a
              left join
              (select device_id,role_id
              from myth.server_role_create
              where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
              group by 1,2) as b
              on a.device_id = b.device_id
              group by 1)
group by 1,2,3
order by 3

union all

select role_id,day_time,step
from myth_server.server_event_guide
where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and version_name in('1.4.0','1.4.1')
and country not in ('CN','HK')
and role_id in 
              (select role_id
              from
              (select device_id from myth.device_activate where day_time between ${beginDate} and ${endDate}
              and channel_id=1000
              and version_name in('1.4.0','1.4.1')   
              and country not in ('CN','HK')
              group by 1
              ) as a
              left join
              (select device_id,role_id
              from myth.server_role_create
              where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
              group by 1,2) as b
              on a.device_id = b.device_id
              group by 1)
group by 1,2,3
order by 3
) as b2

on b1.role_id = b2.role_id and b1.day_time = b2.day_time
group by 1,2,3
) as b3
) as b

on a.role_id = b.role_id
group by 1,2,3
order by 1,2





-- 各个关卡的进入通关人数    生命周期，要一天一天算   excel透视表按照dungeon_id即是进入关卡人数，胜利即为通关人数（节点通过率=下个节点/上个节点人数、整体通过率=每个节点人数/最开始节点的人数、流失点位=下面节点整体通过率-上面节点整体通过率）
select birth_dt, datediff(login_dt,birth_dt)+1 as by_day,country,dungeon_id,battle_result,count(distinct a.role_id)
from

(  --新增 直接生命周期全部算出来，但是新手引导是单天看
select role_id,birth_dt,country
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name in('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt, 
     case when country= 'PH' then 'PH'
     when country in ('AU','NZ')  then 'Oceania'
     when country in ('GB','IE')  then 'GB'
     when country ='CA'  then 'CA'
     when country ='MY'  then 'MY'
     when country in ('NO','SE','FI','DK')  then 'Nordic'
     else 'others'
     end as country
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name in('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
) as a
left join

(select b1.role_id as role_id,login_dt,dungeon_id,battle_result
from
(select role_id,to_date(cast(date_time as timestamp)) as login_dt,day_time
from myth.server_role_login
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and version_name in('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3
) as b1
left join

(select role_id,day_time,dungeon_id,battle_result
from
(select a.role_id as role_id,day_time,a.dungeon_id as dungeon_id,battle_result,row_number() over(partition by a.role_id,a.dungeon_id,day_time order by log_time desc) as num
from
(select dungeon_id,role_id,day_time
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and game_type=3
and channel_id=1000
and version_name in('1.4.0','1.4.1')   
and country not in ('CN','HK')
group by 1,2,3) a 
left join 
(select dungeon_id,role_id,battle_result,log_time
from myth_server.server_dungeon_end
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and game_type=3
and channel_id=1000
and version_name in('1.4.0','1.4.1')   
and country not in ('CN','HK')
group by 1,2,3,4) b 
on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id
) as c
where num = 1
group by 1,2,3,4
) as b2 
on b1.role_id = b2.role_id and b1.day_time = b2.day_time
group by 1,2,3,4
) as b

on a.role_id = b.role_id
group by 1,2,3,4,5
order by 1,2,3






CG对话
select birth_dt,country
,cg_id,play_type -- CG
-- ,dialog_id --对话
,count(distinct a.role_id) 
from 

(  --新增 直接生命周期全部算出来，但是新手引导是单天看
select role_id,birth_dt,country,素材名称
from 
(select role_id,birth_dt,country,a1.device_id
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt, 
     case when country= 'PH' then 'PH'
     when country in ('AU','NZ')  then 'Oceania'
     when country in ('GB','IE')  then 'GB'
     when country ='CA'  then 'CA'
     when country ='MY'  then 'MY'
     when country in ('NO','SE','FI','DK')  then 'Nordic'
     else 'others'
     end as country
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
) as a
left join 
(select customer_user_id,  -- 广告
case when split_part(campaign,'-',5)='ARPG' then '核心受众'
     when media_source ='restricted'        then '未知'
     else  '自然量'
     end  as campaign,
     split_part(af_ad,'-',4) as '投放方式',
     split_part(af_ad,'-',8) as '素材类型',
     split_part(af_ad,'-',10) as '素材名称' 
from myth.af_push
where day_time between ${beginDate} and ${endDate}
group by 1,2,3,4,5) t 
on a.device_id = t.customer_user_id
) a 

left join 
(
select cg_id,play_type,to_date(cast(date_time as timestamp)) as done_dt,role_id
from myth_server.server_cg
where day_time>=${beginDate} and day_time<=${doneDate} 
and server_id in (${serverIds}) 
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3,4
) d 
on a.role_id = d.role_id and birth_dt = done_dt
group by 1,2,3,4

-- left join 
-- (
-- select dialog_id,to_date(cast(date_time as timestamp)) as done_dt,role_id
-- from myth_server.server_dialog
-- where day_time>=${beginDate} and day_time<=${doneDate} 
-- and server_id in (${serverIds}) 
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- group by 1,2,3
-- ) e 
-- on a.role_id = e.role_id and birth_dt = done_dt
-- group by 1,2