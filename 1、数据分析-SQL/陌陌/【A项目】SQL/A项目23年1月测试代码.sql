---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
1、1 KPI——新增、留存  市场投放——BI新增、留存 （整体、付费、免费）
国家
GB+CA+IE
NO+SE+FI+DK
AU+NZ
PH
MY

select birth_dt,datediff(login_dt,birth_dt) as datediffs,country,素材名称,素材类型,投放方式,
       case when campaign is not null then '广告量' 
            else '自然量' 
            end as campaign,
       case when c.device_id is null then '免费'
            else '付费'
            end as pay_or_not,
     count(distinct a.device_id)
from 
(select to_date(cast (date_time as timestamp)) as birth_dt,device_id, -- 新增
case when country= 'PH' then 'PH'
     when country in ('AU','NZ')  then 'Oceania'
     when country in ('GB','IE')  then 'GB'
     when country ='CA'  then 'CA'
     when country ='MY'  then 'MY'
     when country in ('NO','SE','FI','DK')  then 'Nordic'
     else    'others'
     end as country
from myth.device_activate
where day_time between ${beginDate} and ${endDate}
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3) a 

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
group by 1,2,3,4,5) b 
on a.device_id=customer_user_id

left join
(select device_id,to_date(cast (date_time as timestamp)) as pay_dt --付费
from myth.order_pay
where day_time between ${beginDate} and ${endDate} and server_id in (20001,20002)
and channel_id=1000  --Android
and country not in ('CN','HK')
) as c
on a.device_id = c.device_id and a.birth_dt = c.pay_dt

left join  -- 留存
(select to_date(cast (date_time as timestamp)) as login_dt,device_id
from myth.device_launch
where day_time between ${beginDate} and ${endDate} 
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2
) d 
on a.device_id=d.device_id
where login_dt>=birth_dt
group by 1,2,3,4,5,6,7,8


1、2 KPI——ARPU、ARPPU、PR -- 新增口径  市场投放 ARPU、ARPPU、PR
select birth_dt,country,素材名称,素材类型,投放方式,
       case when campaign is not null then '广告量' 
            else '自然量' 
            end as campaign,
       count(distinct a.device) as '新增',
       sum(case when datediff(pay_dt,birth_dt)=0 then pay_price end) as '第一天付费总收入',
       sum(case when datediff(pay_dt,birth_dt)=1 then pay_price end) as '第二天付费总收入',
       sum(case when datediff(pay_dt,birth_dt)=2 then pay_price end) as '第三天付费总收入',
       sum(case when datediff(pay_dt,birth_dt)=6 then pay_price end) as '第七天付费总收入',
       sum(case when datediff(pay_dt,birth_dt)=13 then pay_price end) as '第十四天付费总收入',
       sum(case when datediff(pay_dt,birth_dt)=29 then pay_price end) as '第三十天付费总收入',
       count(distinct case when datediff(pay_dt,birth_dt)=0 then b.role_id end) as '第一天新增付费用户数',
       count(distinct case when datediff(pay_dt,birth_dt)=2 then b.role_id end) as '第三天新增付费用户数',
       count(distinct case when datediff(pay_dt,birth_dt)=6 then b.role_id end) as '第七天新增付费用户数'
from

(  --新增
select a2.device_id as device_id, role_id,birth_dt,country
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
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt,
     case when country= 'PH' then 'PH'
     when country in ('AU','NZ')  then 'Oceania'
     when country in ('GB','IE')  then 'GB'
     when country ='CA'  then 'CA'
     when country ='MY'  then 'MY'
     when country in ('NO','SE','FI','DK')  then 'Nordic'
     else    'others'
     end as country
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
group by 1,2,3,4
) as a

left join
(select role_id,pay_price,to_date(cast (date_time as timestamp)) as pay_dt --付费
from myth.order_pay
where day_time between ${beginDate} and ${endDate} and server_id in (20001,20002)
and channel_id=1000  --Android
and country not in ('CN','HK')
group by 1,2,3
) as b
on a.role_id = b.role_id

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
group by 1,2,3,4,5) c 
on a.device_id=customer_user_id
group by 1,2,3,4,5,6
order by 1


1、3
活跃指标，在线时长、登录次数

每日新增在线时长均值、中位数
select birth_dt,country,datediff(login_dt,birth_dt) as diffs,
-- case when campaign is not null then '广告量'
--      else '自然量' end as campaign, 
 case when d.device_id is null then '免费用户'
      else '付费用户' end as pay_or_not,
count(distinct a.device_id) as devices,
round(avg(duration),2) as avg_duration,appx_median(duration) as median_duration
from 
(select to_date(cast (date_time as timestamp)) as birth_dt,device_id,
case when country= 'PH' then 'PH'
     when country in ('AU','NZ')  then 'Oceania'
     when country in ('GB','IE')  then 'GB'
     when country ='CA'  then 'CA'
     when country ='MY'  then 'MY'
     when country in ('NO','SE','FI','DK')  then 'Nordic'
     else    'others'
     end as country
from myth.device_activate
where day_time>=${beginDate} and day_time<${endDate} 
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3) a 
left join 
(select customer_user_id,  
case when split_part(campaign,'-',5)='ARPG' then '核心受众'
     when media_source ='restricted'        then '未知'
     else  '自然量'
     end  as campaign,
     split_part(af_ad,'-',8) as '素材类型',
     split_part(af_ad,'-',10) as '素材名称' 
from myth.af_push
where  day_time>=${beginDate} and day_time<=${endDate} 
group by 1,2,3,4) b 
on a.device_id=customer_user_id
left join 
(
select device_id,to_date(cast (date_time as timestamp)) as login_dt,count(ping) as duration 
from myth.client_online
where day_time>=${beginDate} and day_time<=${end2Date} 
and channel_id=1000
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2) c 
on a.device_id=c.device_id and login_dt>=birth_dt

left join 
(
select device_id,to_date(cast (date_time as timestamp)) as pay_dt
from myth.order_pay
where day_time>=${beginDate} and day_time<=${end2Date} 
and channel_id=1000
and country not in ('CN','HK')
group by 1,2) d 
on a.device_id=d.device_id and pay_dt>=birth_dt and pay_dt <= login_dt
where datediff(login_dt,birth_dt)  is not null 
group by 1,2,3,4



次留用户的首日时长均值、中位数
select birth_dt,bi_day2,country,datediff(online_dt,birth_dt) as diffs,
 case when e.role_id is null then '免费用户'
      else '付费用户' end as pay_or_not,
count(distinct a.role_id) as role_id,
round(avg(duration),2) as avg_duration,
appx_median(duration) as median_duration
from 
(select birth_dt,country,a.role_id,
count(distinct case when datediff(login_dt,birth_dt) = 1 then c.role_id else null end) as bi_day2
from 
(select birth_dt,role_id,country from 
(select to_date(cast (date_time as timestamp)) as birth_dt,device_id,
case when country= 'PH' then 'PH'
     when country in ('AU','NZ')  then 'Oceania'
     when country in ('GB','IE')  then 'GB'
     when country ='CA'  then 'CA'
     when country ='MY'  then 'MY'
     when country in ('NO','SE','FI','DK')  then 'Nordic'
     else    'others'
     end as country
from myth.device_activate
where day_time>=${beginDate} and day_time<=${endDate} 
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3) a 
left join 
(select  device_id,role_id
from myth.server_role_create
where day_time>=${beginDate} and day_time<=${endDate} 
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
and server_id in (20001,20002)
group by 1,2
) b
on a.device_id=b.device_id
) a 
left join 
(
select to_date(cast (date_time as timestamp)) as login_dt,role_id
from myth.server_role_login
where day_time>=${beginDate} and day_time<=${end2Date} 
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
and server_id in (20001,20002)
) c 
on a.role_id=c.role_id and login_dt>=birth_dt
group by 1,2,3
) a 
left join 
(
select role_id,to_date(cast (date_time as timestamp)) as online_dt,count(ping) as duration 
from myth.client_online
where day_time>=${beginDate} and day_time<=${end2Date} 
and channel_id=1000
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2) d 
on a.role_id=d.role_id and online_dt>=birth_dt

left join 
(
select role_id,to_date(cast (date_time as timestamp)) as pay_dt
from myth.order_pay
where day_time>=${beginDate} and day_time<=${end2Date} 
and channel_id=1000
and country not in ('CN','HK')
group by 1,2) e 
on a.role_id=e.role_id and pay_dt>=birth_dt and pay_dt <= online_dt
where datediff(online_dt,birth_dt)  is not null 
group by 1,2,3,4,5



登录次数均值、中位数
select  birth_dt,datediff(login_dt,birth_dt) as diffs,
-- country,
-- case when campaign is not null then '广告量'
--      else '自然量' end as campaign,
 case when d.device_id is null then '免费用户'
      else '付费用户' end as pay_or_not,
round(avg(sessions),2) as avg_sessions,appx_median(sessions) as median_sessions
from 
(select to_date(cast (date_time as timestamp)) as birth_dt,device_id,
case when country= 'PH' then 'PH'
     when country in ('AU','NZ')  then 'Oceania'
     when country in ('GB','IE')  then 'GB'
     when country ='CA'  then 'CA'
     when country ='MY'  then 'MY'
     when country in ('NO','SE','FI','DK')  then 'Nordic'
     else    'others'
     end as country
from myth.device_activate
where day_time>=${beginDate} and day_time<${endDate} 
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3) a 
left join 
(select customer_user_id,  
case when split_part(campaign,'-',5)='ARPG' then '核心受众'
     when media_source ='restricted'        then '未知'
     else  '自然量'
     end  as campaign,
     split_part(af_ad,'-',8) as '素材类型',
     split_part(af_ad,'-',10) as '素材名称' 
from myth.af_push
where  day_time>=${beginDate} and day_time<=${endDate} 
group by 1,2,3,4) b 
on a.device_id=customer_user_id
left join 
(select to_date(cast (date_time as timestamp)) as login_dt
,device_id
,count(distinct log_time) as sessions
from myth.device_launch
where day_time>=${beginDate} and day_time<=${end2Date}  
and channel_id=1000
and version_name ='1.3.5'
group by 1,2) c 
on a.device_id=c.device_id and login_dt>=birth_dt

left join 
(
select device_id,to_date(cast (date_time as timestamp)) as pay_dt
from myth.order_pay
where day_time>=${beginDate} and day_time<=${end2Date} 
and channel_id=1000
and country not in ('CN','HK')
group by 1,2) d 
on a.device_id=d.device_id and pay_dt>=birth_dt and pay_dt <= login_dt
where datediff(login_dt,birth_dt)  is not null 
group by 1,2,3



---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

2、引导流失：先算新手引导绝对人数、再算各个关卡的进入+通关的绝对人数，最后按照节奏表整理数据

-- 新手引导流程  （节点通过率=下个节点/上个节点人数、整体通过率=每个节点人数/最开始节点的人数、流失点位=下面节点整体通过率-上面节点整体通过率）
select birth_dt,step,付费档位,count(distinct a.role_id)
from

(  --新增 直接生命周期全部算出来，但是新手引导是单天看
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
) as a

left join

(    
select role_id,step_dt,step
from
(select role_id,day_time,step,to_date(cast(date_time as timestamp)) as step_dt
from myth.server_newbie
where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
and role_id in 
              (select role_id
              from
              (select device_id from myth.device_activate where day_time between ${beginDate} and ${endDate}
              and channel_id=1000
              and version_name ='1.3.5'   
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
union all

select role_id,day_time,step,to_date(cast(date_time as timestamp)) as step_dt
from myth_server.server_event_guide
where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
and role_id in 
              (select role_id from (select device_id from myth.device_activate where day_time between ${beginDate} and ${endDate}
              and channel_id=1000
              and version_name ='1.3.5'   
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
) as b1
) as b
on a.role_id = b.role_id

left join -- 付费分档
(select role_id,
       case when sum_pay > 0 and sum_pay <= 30 then '付费第一档'
            when sum_pay > 30 and sum_pay <= 106 then '付费第二档'
            when sum_pay > 106 and sum_pay <= 900 then '付费第三档'
            when sum_pay > 900 and sum_pay <= 9500 then '付费第四档'
            when sum_pay > 9500 then '付费第五档'
            else '免费'
            end as '付费档位'
from
(select role_id,to_date(cast(date_time as timestamp)) as pay_dt,sum(pay_price) as sum_pay
from myth.order_pay
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and country not in ('CN','HK')
group by 1,2
) c1
group by 1,2
) c
on a.role_id = c.role_id
where datediff(step_dt,birth_dt) = 0
group by 1,2,3
order by 1,2,3


-- 各个关卡的进入\通关人数  要一天一天算  excel透视表按照dungeon_id即是进入关卡人数，胜利即为通关人数
select birth_dt,付费档位,dungeon_id,battle_result,count(distinct a.role_id)
from

(  --新增 直接生命周期全部算出来，但是新手引导是单天看
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
) as a

left join
(select role_id,enter_dt,dungeon_id,battle_result
from
(select role_id,dungeon_id,battle_result,enter_dt
from
(select a.role_id as role_id,enter_dt,a.dungeon_id as dungeon_id,battle_result,row_number() over(partition by a.role_id,a.dungeon_id,enter_dt order by log_time desc) as num --取最后一条是因为关卡只能打一次
from
(select dungeon_id,role_id,to_date(cast(date_time as timestamp)) as enter_dt
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type=3
and channel_id=1000
and version_name ='1.3.5'   
and country not in ('CN','HK')) a 
left join 
(select dungeon_id,role_id,battle_result,log_time
from myth_server.server_dungeon_end
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type=3
and channel_id=1000
and version_name ='1.3.5'   
and country not in ('CN','HK')) b 
on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id
) as c
where num = 1
group by 1,2,3,4
) as b1
) as b
on a.role_id = b.role_id

left join -- 付费分档
(select role_id,
       case when sum_pay > 0 and sum_pay <= 30 then '付费第一档'
            when sum_pay > 30 and sum_pay <= 106 then '付费第二档'
            when sum_pay > 106 and sum_pay <= 900 then '付费第三档'
            when sum_pay > 900 and sum_pay <= 9500 then '付费第四档'
            when sum_pay > 9500 then '付费第五档'
            else '免费'
            end as '付费档位'
from
(select role_id,to_date(cast(date_time as timestamp)) as pay_dt,sum(pay_price) as sum_pay
from myth.order_pay
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and country not in ('CN','HK')
group by 1,2
) c1
group by 1,2
) c
on a.role_id = c.role_id
where datediff(b.enter_dt,a.birth_dt) = 0
group by 1,2,3,4
order by 1,2,3




-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

3、玩法系统数据分析  

玩法——2->秘境 3->战役 7->地精宝库 8-13->诸神试炼 14->宝石矿坑

整体、付费-- 人数维度、次数维度分生命周期参与关卡数据
select birth_dt,b.role_id,dungeon_id,scene_id,start_time,game_type,battle_result,battle_time,auto_battle,bottle_num,done_dt,datediff(done_dt,birth_dt)+1 as '生命周期',付费档位
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
-- 关卡参与情况
(select dungeon_id,scene_id,role_id,start_time,game_type,battle_result,battle_time,auto_battle,bottle_num,done_dt, 
from
(select a.dungeon_id,a.scene_id,a.role_id,a.start_time,a.game_type,battle_result,battle_time,auto_battle,bottle_num,done_dt
from 
(select dungeon_id,scene_id,role_id,start_time,to_date(cast(date_time as timestamp)) as done_dt,game_type -- start_time也可用统计参与次数
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 3 -- 2->秘境 3->战役 7->地精宝库 8-13->诸神试炼 14->宝石矿坑
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5,6
) as a
left join     
(select dungeon_id,scene_id,role_id,start_time,battle_result,
        case when battle_time/60000 is null then '无日志'
             when battle_time/60000 > 3  then '1超时'
             when battle_time/60000 > 2 and battle_time/60000 <= 3  then '2困难'
             when battle_time/60000 > 1.5 and battle_time/60000 <= 2  then '3较难'
             when battle_time/60000 > 1 and battle_time/60000 <= 1.5  then '4一般'
             when battle_time/60000 > 0.5 and battle_time/60000 <= 1  then '5简单'
             when battle_time/60000 > 0 and battle_time/60000 <= 0.5  then '6超简单'
             else '无日志'
        end as battle_time,auto_battle,game_type,bottle_num --药瓶使用数
from myth_server.server_dungeon_end
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 3 -- 2->秘境 3->战役 7->地精宝库 8-13->诸神试炼 14->宝石矿坑
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5,6,7,8,9
) b 
on a.dungeon_id=b.dungeon_id and a.scene_id = b.scene_id and a.role_id=b.role_id and a.start_time=b.start_time and a.game_type = b.game_type 
order by a.role_id,a.start_time asc 
) as e  
group by 1,2,3,4,5,6,7,8,9,10
) as b 
on a.role_id = b.role_id

left join -- 付费分档
(select role_id,
       case when sum_pay > 0 and sum_pay <= 30 then '付费第一档'
            when sum_pay > 30 and sum_pay <= 106 then '付费第二档'
            when sum_pay > 106 and sum_pay <= 900 then '付费第三档'
            when sum_pay > 900 and sum_pay <= 9500 then '付费第四档'
            when sum_pay > 9500 then '付费第五档'
            else '免费'
            end as '付费档位'
from
(select role_id,to_date(cast(date_time as timestamp)) as pay_dt,sum(pay_price) as sum_pay
from myth.order_pay
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and country not in ('CN','HK')
group by 1,2
) c1
group by 1,2
) c
on a.role_id = c.role_id
where datediff(b.done_dt,a.birth_dt) <= 6  and pay_dt>=birth_dt and pay_dt<=done_dt

group by 1,2,3,4,5,6,7,8,9,10,11,12,13



扫荡数据 2->秘境 7->地精宝库
扫荡单独算参与人数（去重）扫荡人数、次数
select birth_dt,b.role_id as role_id,date_time,datediff(enter_dt,birth_dt)+1 as '生命周期',dungeon_id,标签,付费档位
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

left join --参与地精宝库/秘境（扫荡+关卡进入）
(select role_id,dungeon_id,date_time,enter_dt,标签
from
(select role_id,dungeon_id,date_time,to_date(cast(date_time as timestamp)) as enter_dt,'正常进入' as '标签'
     from myth_server.server_enter_dungeon
     where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
     and channel_id=1000  --Android
     and game_type =7 --2秘境进入关卡
     and version_name ='1.3.5'
     and country not in ('CN','HK')
group by 1,2,3,4,5
union all
select role_id,dungeon_id,date_time,to_date(cast(date_time as timestamp)) as enter_dt,'扫荡' as '标签'
     from myth_server.server_dungeon_blitz
     where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
     and channel_id=1000  --Android
     and game_type =7 -- 2秘境扫荡
     and version_name ='1.3.5'
     and country not in ('CN','HK')
group by 1,2,3,4,5
) as b1
group by 1,2,3,4,5
) as b
on a.role_id = b.role_id

left join -- 付费分档
(select role_id,
       case when sum_pay > 0 and sum_pay <= 30 then '付费第一档'
            when sum_pay > 30 and sum_pay <= 106 then '付费第二档'
            when sum_pay > 106 and sum_pay <= 900 then '付费第三档'
            when sum_pay > 900 and sum_pay <= 9500 then '付费第四档'
            when sum_pay > 9500 then '付费第五档'
            else '免费'
            end as '付费档位'
from
(select role_id,to_date(cast(date_time as timestamp)) as pay_dt,sum(pay_price) as sum_pay
from myth.order_pay
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and country not in ('CN','HK')
group by 1,2
) c1
group by 1,2
) c
on a.role_id = c.role_id
where datediff(enter_dt,birth_dt) <= 6 and pay_dt>=birth_dt and pay_dt<=enter_dt
group by 1,2,3,4,5,6,7



*********************************************************************************************等会改
生命周期  玩法留存 2->秘境 8-13->诸神试炼 7->地精宝库
select a.role_id,birth_dt,生命周期,datediff(done_date,done_dt)+1 as '留存天数'
from
(
select c.role_id as role_id,birth_dt,done_dt, datediff(done_dt,birth_dt)+1 as '生命周期'
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

left join --达到可参与的条件
(select role_id,to_date(cast(date_time as timestamp)) as done_dt
     from myth_server.server_dungeon_end
     where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
     and game_type =3 
     and battle_result = 1
     and dungeon_id = 30
     and channel_id=1000  --Android
     and version_name ='1.3.5'
     and country not in ('CN','HK')
) b
on a.role_id = b.role_id

left join --参与玩法，与达到条件时间一致，生命周期新增口径
(select role_id,to_date(cast(date_time as timestamp)) as enter_dt
     from myth_server.server_enter_dungeon
     where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
     and game_type = 2 -- 2秘境 8-13诸神试炼 7地精宝库
     and version_name ='1.3.5'
     and country not in ('CN','HK')
) c

on b.role_id = c.role_id and b.done_dt = c.enter_dt
where datediff(done_dt,birth_dt) <= 6
group by 1,2,3
) as a

left join   -- 留存玩法进入
(select role_id,to_date(cast(date_time as timestamp)) as done_date
     from myth_server.server_enter_dungeon
     where  day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
     and game_type =2 -- 2秘境 8-13诸神试炼 7地精宝库
group by 1,2
) as b

-- -- 地精宝库/秘境要合并 正常进入关卡的  和 直接扫荡的玩家
-- (select role_id,done_date
-- from
-- (select role_id,to_date(cast(date_time as timestamp)) as done_date
--      from myth_server.server_enter_dungeon
--      where day_time between ${beginDate} and ${endDate}
--      and server_id in (20001,20002,20003)
--      and game_type =7 
--      and version_name ='1.3.5'
--      and country not in ('CN','HK')
-- group by 1,2
-- union all
-- select role_id,to_date(cast(date_time as timestamp)) as done_date
--      from myth_server.server_dungeon_blitz
--      where day_time between ${beginDate} and ${endDate}
--      and server_id in (20001,20002,20003)
--      and game_type =7 
--      and version_name ='1.3.5'
--      and country not in ('CN','HK')
-- group by 1,2
-- ) as b1
-- group by 1,2
-- ) as b

--  留存登录
-- (select role_id,to_date(cast(date_time as timestamp)) as done_date
-- from myth.server_role_login
-- where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
-- and version_name ='1.3.5'
-- and country not in ('CN','HK')
-- ) as b

on a.role_id = b.role_id
where datediff(done_date,done_dt) in (0,1,2,3,4,5,6)
group by 1,2,3,4






分天参与率
select count(distinct c.role_id)
from
(select role_id,day_time
from myth.server_role_login -- 活跃
where day_time = ${dt}
and server_id in (20001,20002,20003)
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
and device_id in (select distinct device_id from myth.device_activate where day_time >= 20220915 and day_time <= 20220919)
) as a 

left join --  关联此表 可参与人数
(select role_id,day_time
from myth_server.server_dungeon_end
where day_time >= 20220915 and day_time <= ${dt}
and server_id in (20001,20002,20003)
and game_type =3 
and battle_result = 1
and dungeon_id = 90 -- 30  --地精宝库完成2-3（11）
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) b
on a.role_id = b.role_id


当天参与
select count(distinct role_id)
from myth_server.server_enter_dungeon
where day_time = ${dt}
and server_id in (20001,20002)
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
and game_type = 2 -- in (8,9,10,11,12,13)
and device_id in (select distinct device_id from myth.device_activate where day_time >= 20220915 and day_time <= ${dt} and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK'))


-- 地精宝库要合并 正常进入关卡的  和 直接扫荡的玩家
select count(distinct role_id)
from
(select role_id
from myth_server.server_enter_dungeon
where day_time = ${dt}
and server_id in (20001,20002)
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
and game_type = 7
and device_id in (select distinct device_id from myth.device_activate where day_time >= 20220915 and day_time <= ${dt} and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK'))
union all
select role_id
from myth_server.server_dungeon_blitz
where day_time = ${dt}
and server_id in (20001,20002)
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
and game_type = 7
and device_id in (select distinct device_id from myth.device_activate where day_time >= 20220915 and day_time <= ${dt} and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK'))
) as b




生命周期，D1-D7玩法细拆各个数据
存在失败日志的人数  失败
select a.role_id as role_id,birth_dt,game_type,dungeon_id,scene_id,datediff(done_dt,birth_dt)+1 as '天数',付费档位,失败人数,无日志人数
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


left join --存在失败记录的
(
select role_id,done_dt,game_type,dungeon_id,scene_id,
       count(distinct case when battle_result = 2 then role_id else null end) as '失败人数',
       count(distinct case when battle_result is NULL then role_id else null end) as '无日志人数'
from
(select role_id,done_dt,dungeon_id,scene_id,battle_result,game_type
from
(select a.role_id as role_id,done_dt,a.dungeon_id as dungeon_id,a.scene_id,battle_result,a.game_type as game_type
from
(select dungeon_id,scene_id,role_id,to_date(cast(date_time as timestamp)) as done_dt,start_time,game_type
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (20001,20002,20003)
and game_type =3 -- 2秘境 3战役 8-13诸神试炼 7地精宝库
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5,6
) a 
left join 
(select dungeon_id,scene_id,role_id,battle_result,log_time,start_time,game_type
from myth_server.server_dungeon_end
where day_time between ${beginDate} and ${endDate}   and server_id in (20001,20002,20003)
and game_type =3 -- 2秘境 3战役 8-13诸神试炼 7地精宝库
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5,6,7
) b 
on a.game_type = b.game_type and a.dungeon_id=b.dungeon_id and a.scene_id = b.scene_id and a.role_id=b.role_id and a.start_time = b.start_time
) as c
group by 1,2,3,4,5,6
) as b
group by 1,2,3,4,5
) as b
on a.role_id = b.role_id

left join -- 付费分档
(select role_id,
       case when sum_pay > 0 and sum_pay <= 30 then '付费第一档'
            when sum_pay > 30 and sum_pay <= 106 then '付费第二档'
            when sum_pay > 106 and sum_pay <= 900 then '付费第三档'
            when sum_pay > 900 and sum_pay <= 9500 then '付费第四档'
            when sum_pay > 9500 then '付费第五档'
            else '免费'
            end as '付费档位'
from
(select role_id,to_date(cast(date_time as timestamp)) as pay_dt,sum(pay_price) as sum_pay
from myth.order_pay
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and country not in ('CN','HK')
group by 1,2
) c1
group by 1,2
) c
on a.role_id = c.role_id
where datediff(b.done_dt,a.birth_dt) <= 6 and pay_dt>=birth_dt and pay_dt<=done_dt
group by 1,2,3,4,5,6,7,8,9



失败后 多次进入关卡的人数 生命周期  多次进入人数=1统计
select birth_dt,datediff(done_dt,birth_dt)+1 as '天数',付费档位,game_type,dungeon_id,scene_id,多次进入人数,count(distinct a.role_id)
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
(
select role_id,done_dt,game_type,dungeon_id,scene_id,
       count(distinct case when 进入次数 > 1 then role_id else null end) as '多次进入人数'
from
(select c.role_id,c.done_dt,c.dungeon_id,c.scene_id,c.game_type,进入次数
from
(select a.role_id,a.done_dt,a.dungeon_id,a.game_type -- 有失败的玩家
from
(select dungeon_id,scene_id,role_id,to_date(cast(date_time as timestamp)) as done_dt,start_time,game_type
from myth_server.server_enter_dungeon
where day_time>=${beginDate} and day_time<=${end2Date} and server_id in (20001,20002)
and game_type =3 -- 2秘境 3战役 8-13诸神试炼 7地精宝库
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5,6) a 
left join 
(select dungeon_id,scene_id,role_id,battle_result,log_time,start_time,game_type
from myth_server.server_dungeon_end
where day_time>=${beginDate} and day_time<=${end2Date}   and server_id in (20001,20002)
and game_type =3 -- 2秘境 3战役 8-13诸神试炼 7地精宝库
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5,6,7) b 
on a.game_type = b.game_type and a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time = b.start_time
where battle_result =2 -- =2是有失败记录的/is null是无日志记录的
group by 1,2,3,4 
) c 
left join 
(select a.role_id as role_id,done_dt,a.game_type as game_type,a.dungeon_id as dungeon_id,a.scene_id as scene_id,count(a.start_time) as '进入次数'
from
(select dungeon_id,scene_id,role_id,to_date(cast(date_time as timestamp)) as done_dt,start_time,game_type
from myth_server.server_enter_dungeon
where day_time>=${beginDate} and day_time<=${end2Date} and server_id in (20001,20002)
and game_type =3 -- 2秘境 3战役 8-13诸神试炼 7地精宝库
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5,6) a 
left join 
(select dungeon_id,scene_id,role_id,battle_result,log_time,start_time,game_type
from myth_server.server_dungeon_end
where day_time>=${beginDate} and day_time<=${end2Date}   and server_id in (20001,20002)
and game_type =3 -- 2秘境 3战役 8-13诸神试炼 7地精宝库
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5,6,7) b 
on a.game_type = b.game_type and a.dungeon_id=b.dungeon_id and a.scene_id = b.scene_id and a.role_id=b.role_id and a.start_time = b.start_time
group by 1,2,3,4
) as d 
on c.game_type = d.game_type and c.dungeon_id=d.dungeon_id and a.scene_id = d.scene_id and c.role_id=d.role_id and c.done_dt=d.done_dt
group by 1,2,3,4,5,6
) as  e 
group by 1,2,3,4,5
) as f 
on a.role_id = f.role_id 

left join -- 付费分档
(select role_id,
       case when sum_pay > 0 and sum_pay <= 30 then '付费第一档'
            when sum_pay > 30 and sum_pay <= 106 then '付费第二档'
            when sum_pay > 106 and sum_pay <= 900 then '付费第三档'
            when sum_pay > 900 and sum_pay <= 9500 then '付费第四档'
            when sum_pay > 9500 then '付费第五档'
            else '免费'
            end as '付费档位'
from
(select role_id,to_date(cast(date_time as timestamp)) as pay_dt,sum(pay_price) as sum_pay
from myth.order_pay
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and country not in ('CN','HK')
group by 1,2
) c1
group by 1,2
) c
on a.role_id = c.role_id
where datediff(b.done_dt,a.birth_dt) <= 6 and pay_dt>=birth_dt and pay_dt<=done_dt
group by 1,2,3,4,5,6,7






失败后通关人数 去重日志条数 = 2 -- 2代表有失败记录最后通关的  1代表无日志记录最后通关的

select role_id,birth_dt,game_type,dungeon_id,scene_id,天数
from

(select a.role_id as role_id,birth_dt,game_type,dungeon_id,scene_id,num,datediff(done_dt,birth_dt)+1 as '天数',付费档位
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
(select c.role_id,c.done_dt,c.dungeon_id,c.scene_id,c.game_type,count(distinct battle_result) as num -- 去重日志条数
from
(select a.role_id,a.done_dt,a.dungeon_id,a.game_type -- 有失败/无日志的玩家
from
(select dungeon_id,scene_id,role_id,to_date(cast(date_time as timestamp)) as done_dt,start_time,game_type
from myth_server.server_enter_dungeon
where day_time>=${beginDate} and day_time<=${end2Date} and server_id in (20001,20002)
and game_type =3 -- 2秘境 3战役 8-13诸神试炼 7地精宝库
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5,6) a 
left join 
(select dungeon_id,scene_id,role_id,battle_result,log_time,start_time,game_type
from myth_server.server_dungeon_end
where day_time>=${beginDate} and day_time<=${end2Date} and server_id in (20001,20002)
and game_type =3 -- 2秘境 3战役 8-13诸神试炼 7地精宝库
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5,6,7) b 
on a.game_type = b.game_type and a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time = b.start_time
where battle_result =2 -- =2是有失败记录的/is null是无日志记录的
group by 1,2,3,4 
) c 
left join 
(select a.role_id as role_id,done_dt,a.game_type as game_type,a.dungeon_id as dungeon_id,a.scene_id as scene_id,battle_result
from
(select dungeon_id,scene_id,role_id,to_date(cast(date_time as timestamp)) as done_dt,start_time,game_type
from myth_server.server_enter_dungeon
where day_time>=${beginDate} and day_time<=${end2Date} and server_id in (20001,20002)
and game_type =3 -- 2秘境 3战役 8-13诸神试炼 7地精宝库
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5,6) a 
left join 
(select dungeon_id,scene_id,role_id,battle_result,log_time,start_time,game_type
from myth_server.server_dungeon_end
where day_time>=${beginDate} and day_time<=${end2Date}   and server_id in (20001,20002)
and game_type =3 -- 2秘境 3战役 8-13诸神试炼 7地精宝库
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5,6,7) b 
on a.game_type = b.game_type and a.dungeon_id=b.dungeon_id and a.scene_id = b.scene_id and a.role_id=b.role_id and a.start_time = b.start_time
where battle_result = 1 -- 有成功日志的
group by 1,2,3,4,5,6
) as d 
on c.game_type = d.game_type and c.dungeon_id=d.dungeon_id and a.scene_id = d.scene_id and c.role_id=d.role_id and c.done_dt=d.done_dt
group by 1,2,3,4,5
) as f 
on a.role_id = f.role_id 

left join -- 付费分档
(select role_id,
       case when sum_pay > 0 and sum_pay <= 30 then '付费第一档'
            when sum_pay > 30 and sum_pay <= 106 then '付费第二档'
            when sum_pay > 106 and sum_pay <= 900 then '付费第三档'
            when sum_pay > 900 and sum_pay <= 9500 then '付费第四档'
            when sum_pay > 9500 then '付费第五档'
            else '免费'
            end as '付费档位'
from
(select role_id,to_date(cast(date_time as timestamp)) as pay_dt,sum(pay_price) as sum_pay
from myth.order_pay
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and country not in ('CN','HK')
group by 1,2
) c1
group by 1,2
) c
on a.role_id = c.role_id
where datediff(f.done_dt,a.birth_dt) <= 6 and pay_dt>=birth_dt and pay_dt<=done_dt

) as new
and num = 2 -- 2代表有失败记录最后通关的  1代表无日志记录最后通关的
group by 1,2,3,4,5,6




生命周期   未通关的人，没玩其他玩法人数
select role_id,birth_dt,game_type,dungeon_id,天数
from
(
select a.role_id as role_id,birth_dt,done_dt,game_type,dungeon_id,天数,玩法类型
from
(
select b.role_id as role_id,game_type,dungeon_id,birth_dt,done_dt,end_time,datediff(done_dt,birth_dt)+1 as '天数'
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
(select role_id,done_dt,game_type,dungeon_id,log_time as end_time
from
(select a.role_id as role_id,done_dt,a.game_type as game_type,a.dungeon_id as dungeon_id,log_time,battle_result,row_number() over(partition by a.role_id,a.game_type,a.dungeon_id,done_dt order by log_time desc) as num
from
(select dungeon_id,role_id,to_date(cast(date_time as timestamp)) as done_dt,start_time,game_type
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (20001,20002,20003)
and game_type =2 -- 2秘境 8-13诸神试炼
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5) a 
left join 
(select dungeon_id,role_id,battle_result,log_time,start_time,game_type
from myth_server.server_dungeon_end
where day_time between ${beginDate} and ${endDate}   and server_id in (20001,20002,20003)
and game_type =2 -- 2秘境 8-13诸神试炼
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5,6) b 
on a.game_type = b.game_type and a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time = b.start_time
) as c
where num = 1 and battle_result <> 1
group by 1,2,3,4,5
) as b
on a.role_id = b.role_id
where b.role_id is not null and datediff(done_dt,birth_dt) <= 6
) as a


left join
(
select role_id,to_date(cast(date_time as timestamp)) as enter_dt,start_time,
case game_type 
           -- when 2 then '秘境'
           when 3 then '战役'
           when 4 then '竞技场'
           when 6 then '远古战场'
           when 7 then '地精宝库'
           when 8 then '诸神试炼'
           when 9 then '诸神试炼'
           when 10 then '诸神试炼'
           when 11 then '诸神试炼'
           when 12 then '诸神试炼'
           when 13 then '诸神试炼'
           when 14 then '宝石矿坑'
           when 16 then '公会领主'
           when 17 then '无尽深渊'
           when 18 then '公会远征'
           when 19 then '次元危机'
           else 'others'
           end as '玩法类型'
from myth_server.server_enter_dungeon
where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type in (3,4,6,7,8,9,10,11,12,13,14,16,17,18,19)
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) as c
on a.role_id = c.role_id and a.done_dt = c.enter_dt and c.start_time > a.end_time
group by 1,2,3,4,5,6,7

) as c  
where 玩法类型 is null
group by 1,2,3,4,5




未进入其他玩法，第二天登录 做减法就是第二天未登录
select aaa.role_id,birth_dt,game_type,dungeon_id,生命周期,datediff(login_dt,birth_dt)+1 as '留存天数'
from

(
select role_id,birth_dt,game_type,dungeon_id,生命周期
from
(
select a.role_id as role_id,birth_dt,done_dt,game_type,dungeon_id,生命周期,玩法类型
from
(
select b.role_id as role_id,game_type,dungeon_id,birth_dt,done_dt,end_time,datediff(done_dt,birth_dt)+1 as '生命周期'
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
(select role_id,done_dt,game_type,dungeon_id,log_time as end_time
from
(select a.role_id as role_id,done_dt,a.game_type as game_type,a.dungeon_id as dungeon_id,log_time,battle_result,row_number() over(partition by a.role_id,a.game_type,a.dungeon_id,done_dt order by log_time desc) as num
from
(select dungeon_id,role_id,to_date(cast(date_time as timestamp)) as done_dt,start_time,game_type
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (20001,20002,20003)
and game_type =2 -- 2秘境 8-13诸神试炼
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5) a 
left join 
(select dungeon_id,role_id,battle_result,log_time,start_time,game_type
from myth_server.server_dungeon_end
where day_time between ${beginDate} and ${endDate}   and server_id in (20001,20002,20003)
and game_type =2 -- 2秘境 8-13诸神试炼
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5,6) b 
on a.game_type = b.game_type and a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time = b.start_time
) as c
where num = 1 and battle_result <> 1
group by 1,2,3,4,5
) as b
on a.role_id = b.role_id
where b.role_id is not null and datediff(done_dt,birth_dt) <= 6
) as a


left join
(
select role_id,to_date(cast(date_time as timestamp)) as enter_dt,start_time,
case game_type 
           -- when 2 then '秘境'
           when 3 then '战役'
           when 4 then '竞技场'
           when 6 then '远古战场'
           when 7 then '地精宝库'
           when 8 then '诸神试炼'
           when 9 then '诸神试炼'
           when 10 then '诸神试炼'
           when 11 then '诸神试炼'
           when 12 then '诸神试炼'
           when 13 then '诸神试炼'
           when 14 then '宝石矿坑'
           when 16 then '公会领主'
           when 17 then '无尽深渊'
           when 18 then '公会远征'
           when 19 then '次元危机'
           else 'others'
           end as '玩法类型'
from myth_server.server_enter_dungeon
where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type in (3,4,6,7,8,9,10,11,12,13,14,16,17,18,19)
) as c
on a.role_id = c.role_id and a.done_dt = c.enter_dt and c.start_time > a.end_time
group by 1,2,3,4,5,6,7

) as c  
where 玩法类型 is null
group by 1,2,3,4,5
) as aaa


left join
(select role_id,to_date(cast(date_time as timestamp)) as login_dt
from myth.server_role_login
where day_time between ${beginDate} and ${loginDate} and server_id in (${serverIds})
) as bbb
on aaa.role_id = bbb.role_id
where datediff(login_dt,birth_dt) in (0,1)
group by 1,2,3,4,5,6




--------------------------------------------------------------------------------------------------------------------------------------------------------------------
地精宝库通关时长分布
select birth_dt,a.role_id,datediff(login_dt,birth_dt)+1 as '天数',dungeon_id,duration,评级,battle_result,auto_battle,date_time
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
) as a

left join
(select role_id,login_dt,dungeon_id,duration,评级,battle_result,auto_battle,date_time
from
(select a.dungeon_id as dungeon_id ,a.role_id as role_id,a.start_time,end_time,battle_time/60000 as duration,
       case when battle_time/60000 is null then '无日志'
            when battle_time/60000 > 3  then '1超时'
            when battle_time/60000 > 2 and battle_time/60000 <= 3  then '2困难'
            when battle_time/60000 > 1.5 and battle_time/60000 <= 2  then '3较难'
            when battle_time/60000 > 1 and battle_time/60000 <= 1.5  then '4一般'
            when battle_time/60000 > 0.5 and battle_time/60000 <= 1  then '5简单'
            when battle_time/60000 > 0 and battle_time/60000 <= 0.5  then '6超简单'
            else '无日志'
       end as '评级',battle_result,auto_battle,a.day_time as day_time,login_dt,date_time
from 
(select dungeon_id,role_id,day_time,start_time,to_date(cast(date_time as timestamp)) as login_dt,date_time
     from myth_server.server_enter_dungeon
     where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
     and game_type=7
     and version_name ='1.3.5'
     and country not in ('CN','HK')
group by 1,2,3,4,5,6
) as a

left join     
(select dungeon_id,role_id,day_time,log_time  as end_time,start_time,battle_result,auto_battle
     from myth_server.server_dungeon_end
     where  day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
     and game_type=7
     and version_name ='1.3.5'
     and country not in ('CN','HK')
) b 
on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time=b.start_time
order by a.role_id,a.start_time asc 
) as e 
) as b 

on a.role_id = b.role_id
where datediff(login_dt,birth_dt) <= 6
group by 1,2,3,4,5,6,7,8,9



----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
远古战场  伤害分布
select birth_dt,role_id,date_time,生命周期,boss_id,auto_battle,damage_value,max_damage_value,
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
select birth_dt,b.role_id as role_id,date_time,datediff(done_dt,birth_dt)+1 as '生命周期',boss_id,auto_battle,damage_value,max_damage_value
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
) as a

left join

(select * from
(select a.dungeon_id as boss_id,a.role_id as role_id,date_time,end_time,auto_battle,done_dt,damage_value,max_damage_value
from 
(select day_time,dungeon_id,role_id,start_time,date_time,to_date(cast(date_time as timestamp)) as done_dt
     from myth_server.server_enter_dungeon
     where  day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
     and game_type =6 -- 6远古战场
     and version_name ='1.3.5'
     and country not in ('CN','HK')
group by 1,2,3,4,5,6
) as a

left join     
(select boss_id,role_id,log_time as end_time,start_time,auto_battle,damage_value
     from myth_server.server_world_boss
     where  day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
     and version_name ='1.3.5'
     and country not in ('CN','HK')
) b 
on a.dungeon_id=b.boss_id and a.role_id=b.role_id and a.start_time=b.start_time

left join
(select boss_id,role_id,day_time,max(damage_value) as max_damage_value
     from myth_server.server_world_boss
     where  day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
     and version_name ='1.3.5'
     and country not in ('CN','HK')
     group by 1,2,3
) as c 
on a.day_time = c.day_time and b.boss_id = c.boss_id and b.role_id = c.role_id and b.damage_value = c.max_damage_value
) as e  
) as b 
on a.role_id = b.role_id
where datediff(done_dt,birth_dt) <= 6
group by 1,2,3,4,5,6,7,8
) as ab
group by 1,2,3,4,5,6,7,8,9
order by 2,3,5,6,7,8




整体钻石消耗
select b.role_id as role_id,birth_dt,datediff(consume_dt,birth_dt) + 1 as '天数',change_count
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
) as a

left join
(SELECT role_id,to_date(cast(date_time as timestamp)) as consume_dt,sum(change_count) as change_count FROM
myth.server_currency
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
and currency_id = '3'
AND change_type = 'CONSUME'
and change_method = '56'
group by 1,2
) as b
on a.role_id = b.role_id

where datediff(consume_dt,birth_dt) <= 6
group by 1,2,3,4



日参与率
分天参与率
select count(distinct c.role_id)
from
(select role_id,day_time
from myth.server_role_login -- 活跃
where day_time = ${dt}
and server_id in (20001,20002,20003)
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
and device_id in (select distinct device_id from myth.device_activate where day_time >= 20220915 and day_time <= 20220919 and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK'))
) as a 

left join --  关联此表 可参与人数
(select role_id,day_time
from myth_server.server_dungeon_end
where day_time >= 20220915 and day_time <= ${dt}
and server_id in (20001,20002,20003)
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
and game_type =3 
and battle_result = 1
and dungeon_id = 24 
) b
on a.role_id = b.role_id


分天参与
select count(distinct role_id)
from myth_server.server_enter_dungeon
where day_time = ${dt}
and server_id in (20001,20002)
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
and game_type = 6
and device_id in (select distinct device_id from myth.device_activate where day_time >= 20220915 and day_time <= ${dt} and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK'))




远古战场
生命周期  玩法留存
select a.role_id,birth_dt,生命周期,datediff(done_date,done_dt)+1 as '留存天数'
from
(
select c.role_id as role_id,birth_dt,done_dt, datediff(done_dt,birth_dt)+1 as '生命周期'
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
) as a

left join 
(select role_id,to_date(cast(date_time as timestamp)) as done_dt
from myth_server.server_dungeon_end
where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type =3 
and battle_result = 1
and dungeon_id = 24
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) b
on a.role_id = b.role_id

left join
(select role_id,to_date(cast(date_time as timestamp)) as enter_dt
from myth_server.server_enter_dungeon
where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 6
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) c
on b.role_id = c.role_id and b.done_dt = c.enter_dt
where datediff(done_dt,birth_dt) <= 6
group by 1,2,3
) as a

left join   -- 留存玩法进入
(select role_id,to_date(cast(date_time as timestamp)) as done_date
from myth_server.server_enter_dungeon
where  day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and game_type = 6
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2
) as b


--  留存登录
-- (select role_id,to_date(cast(date_time as timestamp)) as done_date
-- from myth.server_role_login
-- where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
-- and version_name ='1.3.5'
-- and country not in ('CN','HK')
-- ) as b

on a.role_id = b.role_id
where datediff(done_date,done_dt) in (0,1,2,3,4,5,6)
group by 1,2,3,4



远古战场时间划分，不同时间段的结算，来看boss的难度情况
select birth_dt,a.role_id,datediff(login_dt,birth_dt)+1 as '天数',dungeon_id,duration,评级,auto_battle,date_time
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
) as a

left join
(select role_id,login_dt,dungeon_id,duration,评级,auto_battle,date_time
from
(select a.dungeon_id as dungeon_id ,a.role_id as role_id,a.start_time,end_time,battle_time/60000 as duration,
       case when battle_time/60000 is null then '无日志'
            when battle_time/60000 >= 1.5  then '1结算'
            when battle_time/60000 > 1 and battle_time/60000 < 1.5  then '2一般'
            when battle_time/60000 > 0.5 and battle_time/60000 <= 1  then '3较难'
            when battle_time/60000 > 0 and battle_time/60000 <= 0.5  then '4困难'
            else '无日志'
       end as '评级',auto_battle,a.day_time as day_time,login_dt,date_time
from 
(select dungeon_id,role_id,day_time,start_time,to_date(cast(date_time as timestamp)) as login_dt,date_time
     from myth_server.server_enter_dungeon
     where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
     and game_type=6
     and version_name ='1.3.5'
     and country not in ('CN','HK')
) as a

left join     
(select boss_id as dungeon_id,role_id,day_time,log_time as end_time,start_time,auto_battle
     from myth_server.server_world_boss
     where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
     and version_name ='1.3.5'
     and country not in ('CN','HK')
) b 
on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time=b.start_time
order by a.role_id,a.start_time asc 
) as e 
) as b 

on a.role_id = b.role_id
where datediff(login_dt,birth_dt) <= 6
group by 1,2,3,4,5,6,7,8





-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
竞技场
PVP生命周期计算参与人数、次数，自动战斗等
select role_id,birth_dt,PVP生命周期,胜率,
       case when 胜率 >= 0 and 胜率 < 50 then '0-49'
            when 胜率 >= 50 and 胜率 < 70 then '50-69'
            when 胜率 >= 70 and 胜率 < 80 then '70-79'
            when 胜率 >= 80 and 胜率 < 90 then '80-89'
            when 胜率 >= 90 then '90+'
            else NULL
       end as '胜率分布',
       num as '参与次数',
       auto_num as '自动战斗次数',
       case when auto_num > 0 then '是'
            else '否'
            end as '是否使用过自动战斗'  
from 
(
select a.role_id as role_id,birth_dt,datediff(pvp_dt,birth_dt)+1 as 'PVP生命周期',
       round(count(case when fighting_result=1 then 1 else null end)/count(1)*100,2) as '胜率',
       count(start_time) as num,
       count(case when auto_battle =1 then start_time else null end) as auto_num
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
) as a

left join
( -- 参与竞技场的玩家  若fighting_result为空则是无日志
select b1.role_id as role_id,pvp_dt,fighting_result,auto_battle,b1.start_time as start_time
from
(select role_id,to_date(cast(date_time as timestamp)) as pvp_dt,start_time
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 4
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3
) b1
left join
(select role_id,start_time,fighting_result,auto_battle
from myth_server.server_arena
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')     
) b2
on b1.role_id = b2.role_id and b1.start_time = b2.start_time
group by 1,2,3,4,5
) b
on a.role_id=b.role_id
where datediff(pvp_dt,birth_dt) is not null and datediff(pvp_dt,birth_dt) <= 6
group by 1,2,3
order by 1,2
) as a 
group by 1,2,3,4,5,6,7,8





参与玩法玩家的钻石 消耗
select b.role_id as role_id,birth_dt,datediff(pvp_dt,birth_dt) + 1 as '天数',change_count
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
) as a

left join

(
select b2.role_id,pvp_dt,change_count
from
(select role_id,to_date(cast(date_time as timestamp)) as pvp_dt
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 4
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2
) b1

left join
(SELECT role_id,to_date(cast(date_time as timestamp)) as consume_dt,sum(change_count) as change_count FROM
myth.server_currency
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
and currency_id = '3'
AND change_type = 'CONSUME'
and change_method = '50'
group by 1,2
) as b2
on b1.role_id = b2.role_id and b1.pvp_dt = b2.consume_dt
) as b

on a.role_id = b.role_id
where datediff(pvp_dt,birth_dt) <= 6
group by 1,2,3,4





整体的钻石 消耗
select b.role_id as role_id,birth_dt,datediff(consume_dt,birth_dt) + 1 as '天数',change_count
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
) as a

left join
(SELECT role_id,to_date(cast(date_time as timestamp)) as consume_dt,sum(change_count) as change_count FROM
myth.server_currency
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
and currency_id = '3'
AND change_type = 'CONSUME'
and change_method = '50'
group by 1,2
) as b
on a.role_id = b.role_id
where datediff(consume_dt,birth_dt) <= 6
group by 1,2,3,4






日参与率
分天参与率
select count(distinct c.role_id)
from
(select role_id,day_time
from myth.server_role_login -- 活跃
where day_time = ${dt}
and server_id in (20001,20002,20003)
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
and device_id in (select distinct device_id from myth.device_activate where day_time >= 20220915 and day_time <= 20220919)
) as a 

left join --  关联此表 可参与人数
(select role_id,day_time
from myth_server.server_dungeon_end
where day_time >= 20220915 and day_time <= ${dt}
and server_id in (20001,20002,20003)
and game_type =3 
and battle_result = 1
and dungeon_id = 16 
) b
on a.role_id = b.role_id


分天参与
select count(distinct role_id)
from myth_server.server_enter_dungeon
where day_time = ${dt}
and server_id in (20001,20002)
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
and game_type = 4
and device_id in (select distinct device_id from myth.device_activate where day_time >= 20220915 and day_time <= ${dt} and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK'))


竞技场
生命周期  玩法留存
select a.role_id,birth_dt,生命周期,datediff(done_date,done_dt)+1 as '留存天数'
from
(
select c.role_id as role_id,birth_dt,done_dt, datediff(done_dt,birth_dt)+1 as '生命周期'
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
) as a

left join 
(select role_id,to_date(cast(date_time as timestamp)) as done_dt
     from myth_server.server_dungeon_end
     where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
     and game_type =3 
     and battle_result = 1
     and dungeon_id = 16
     and version_name ='1.3.5'
     and country not in ('CN','HK')
) b
on a.role_id = b.role_id

left join
(select role_id,to_date(cast(date_time as timestamp)) as enter_dt
     from myth_server.server_enter_dungeon
     where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
     and game_type = 4
     and version_name ='1.3.5'
     and country not in ('CN','HK')
) c
on b.role_id = c.role_id and b.done_dt = c.enter_dt
where datediff(done_dt,birth_dt) <= 6
group by 1,2,3
) as a

left join   -- 留存玩法进入
-- (select role_id,to_date(cast(date_time as timestamp)) as done_date
--      from myth_server.server_enter_dungeon
--      where  day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
--      and game_type = 4
--      and version_name ='1.3.5'
--      and country not in ('CN','HK')
-- group by 1,2
-- ) as b


--  留存登录
(select role_id,to_date(cast(date_time as timestamp)) as done_date
from myth.server_role_login
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) as b

on a.role_id = b.role_id
where datediff(done_date,done_dt) in (0,1,2,3,4,5,6)
group by 1,2,3,4





--------------------------------------------------------------------------------------------------------------------------------------------------------------------
信徒心愿  &  春之庭院


信徒心愿 参与数据
select a.role_id as role_id,birth_dt,datediff(believer_dt,birth_dt)+1 as '天数',
       count(num)
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
) as a


left join
( -- 参与信徒心愿的玩家  消耗心愿值大于0
select role_id,believer_dt,num,consume_believer
from
(select role_id,to_date(cast(date_time as timestamp)) as believer_dt,log_time as num,consume_believer
from myth_server.server_bless_believer
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) b1
where consume_believer > 0
) b
on a.role_id=b.role_id
where datediff(believer_dt,birth_dt) <= 6

group by 1,2,3
order by 1,2,3



信徒心愿日参与率

select count(distinct c.role_id)
from
(select role_id,day_time
from myth.server_role_login -- 活跃
where day_time = ${dt}
and server_id in (20001,20002,20003)
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
and device_id in (select distinct device_id from myth.device_activate where day_time >= 20220915 and day_time <= 20220919)
) as a 

left join --  关联此表 可参与人数
(select role_id,day_time
from myth_server.server_dungeon_end
where day_time >= 20220915 and day_time <= ${dt}
and server_id in (20001,20002,20003)
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
and game_type =3 
and battle_result = 1
and dungeon_id = 28 
) b
on a.role_id = b.role_id



分天参与
select count(distinct role_id)
from
(select role_id,consume_believer
from myth_server.server_bless_believer
where day_time = ${dt}
and server_id in (20001,20002,20003)
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
and device_id in (select distinct device_id from myth.device_activate where day_time >= 20220915 and day_time <= ${dt} and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK'))
) b1
where consume_believer > 0




信徒心愿
生命周期  玩法留存
select a.role_id,birth_dt,生命周期,datediff(done_date,done_dt)+1 as '留存天数'
from
(
select c.role_id as role_id,birth_dt,done_dt, datediff(done_dt,birth_dt)+1 as '生命周期'
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
) as a

left join 
(select role_id,to_date(cast(date_time as timestamp)) as done_dt
     from myth_server.server_dungeon_end
     where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
     and game_type =3 
     and battle_result = 1
     and dungeon_id = 28
     and version_name ='1.3.5'
     and country not in ('CN','HK')
) b
on a.role_id = b.role_id

left join

(select role_id,enter_dt
from
(select role_id,day_time,consume_believer,to_date(cast(date_time as timestamp)) as enter_dt
from myth_server.server_bless_believer
where day_time between ${beginDate} and ${endDate}
and server_id in (20001,20002,20003)
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) b1
where consume_believer > 0
) as c

on b.role_id = c.role_id and b.done_dt = c.enter_dt
where datediff(done_dt,birth_dt) <= 6
group by 1,2,3
) as a

left join   -- 留存玩法进入
(select role_id,done_date
from
(select role_id,day_time,consume_believer,to_date(cast(date_time as timestamp)) as done_date
from myth_server.server_bless_believer
where day_time between ${beginDate} and ${endDate}
and server_id in (20001,20002,20003)
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) b1
where consume_believer > 0
) as b


--  留存登录
-- (select role_id,to_date(cast(date_time as timestamp)) as done_date
-- from myth.server_role_login
-- where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
-- and version_name ='1.3.5'
-- and country not in ('CN','HK')
-- ) as b

on a.role_id = b.role_id
where datediff(done_date,done_dt) in (0,1,2,3,4,5,6)
group by 1,2,3,4




信徒心愿刷新数据
和钻石消耗
select b.role_id as role_id,birth_dt,datediff(consume_dt,birth_dt) + 1 as '天数',date_time,change_count
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
) as a

left join
(SELECT role_id,to_date(cast(date_time as timestamp)) as consume_dt,date_time,change_count 
FROM myth.server_currency
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
and currency_id = '3'
AND change_type = 'CONSUME'
and change_method = '40' -- 刷新信徒心愿
group by 1,2,3,4
) as b
on a.role_id = b.role_id
where datediff(consume_dt,birth_dt) <= 6
group by 1,2,3,4,5





春之庭院
参与情况

select a.role_id as role_id,birth_dt,datediff(reward_dt,birth_dt)+1 as '天数',
       count(num)
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
) as a

left join
( -- 参与春之庭院的玩家  有领取挂机奖励的日志
select role_id,to_date(cast(date_time as timestamp)) as reward_dt,log_time as num
from myth_server.server_claim_hang_reward
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) b
on a.role_id=b.role_id
where datediff(reward_dt,birth_dt) <= 6

group by 1,2,3
order by 1,2,3




挂机加速数据
select a.role_id as role_id,birth_dt,datediff(reward_dt,birth_dt)+1 as '天数',
       count(num),sum(consume_currency_num)
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
) as a

left join
( 
select role_id,to_date(cast(date_time as timestamp)) as reward_dt,log_time as num,consume_currency_num
from myth_server.server_quicken_hang
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) b
on a.role_id=b.role_id
where datediff(reward_dt,birth_dt) <= 6

group by 1,2,3
order by 1,2,3





春之庭院挂机   日参与率

select count(distinct c.role_id)
from
(select role_id,day_time
from myth.server_role_login -- 活跃
where day_time = ${dt}
and server_id in (20001,20002,20003)
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
and device_id in (select distinct device_id from myth.device_activate where day_time >= 20220915 and day_time <= 20220919)
) as a 

left join --  关联此表 可参与人数
(select role_id,day_time
from myth_server.server_dungeon_end
where day_time >= 20220915 and day_time <= ${dt}
and server_id in (20001,20002,20003)
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
and game_type =3 
and battle_result = 1
and dungeon_id = 6 
) b
on a.role_id = b.role_id


当天参与
select count(distinct role_id)
from myth_server.server_claim_hang_reward
where day_time = ${dt}
and server_id in (20001,20002)
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
and device_id in (select distinct device_id from myth.device_activate where day_time >= 20220915 and day_time <= ${dt} and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK'))





春之庭院挂机 
生命周期  玩法留存
select a.role_id,birth_dt,生命周期,datediff(done_date,done_dt)+1 as '留存天数'
from
(
select c.role_id as role_id,birth_dt,done_dt, datediff(done_dt,birth_dt)+1 as '生命周期'
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
) as a

left join 
(select role_id,to_date(cast(date_time as timestamp)) as done_dt
     from myth_server.server_dungeon_end
     where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
     and game_type =3 
     and battle_result = 1
     and dungeon_id = 6
     and version_name ='1.3.5'
     and country not in ('CN','HK')
) b
on a.role_id = b.role_id

left join
(select role_id,to_date(cast(date_time as timestamp)) as enter_dt
from myth_server.server_claim_hang_reward
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) c
on b.role_id = c.role_id and b.done_dt = c.enter_dt
where datediff(done_dt,birth_dt) <= 6
group by 1,2,3
) as a

left join   -- 留存玩法进入
-- (select role_id,to_date(cast(date_time as timestamp)) as done_date
-- from myth_server.server_claim_hang_reward
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and version_name ='1.3.5'
-- and country not in ('CN','HK')
-- group by 1,2
-- ) as b


--  留存登录
(select role_id,to_date(cast(date_time as timestamp)) as done_date
from myth.server_role_login
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) as b

on a.role_id = b.role_id
where datediff(done_date,done_dt) in (0,1,2,3,4,5,6)
group by 1,2,3,4



--------------------------------------------------------------------------------------------------------------------------------------------------------------------
宝石矿坑

日参与率
select count(distinct c.role_id)
from
(select role_id,day_time
from myth.server_role_login -- 活跃
where day_time = ${dt}
and server_id in (20001,20002,20003)
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
and device_id in (select distinct device_id from myth.device_activate where day_time >= 20220915 and day_time <= 20220919)
) as a 

left join --  关联此表 可参与人数
(select role_id,day_time
from myth_server.server_dungeon_end
where day_time >= 20220915 and day_time <= ${dt}
and server_id in (20001,20002,20003)
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
and game_type =3 
and battle_result = 1
and dungeon_id = 48 
) b
on a.role_id = b.role_id


当天参与 参加矿坑挖矿

select count(distinct role_id)
from myth_server.server_gem_mine_start
where day_time = ${dt}
and server_id in (20001,20002)
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
and device_id in (select distinct device_id from myth.device_activate where day_time >= 20220915 and day_time <= ${dt} and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK'))





宝石矿坑
生命周期  玩法留存
select a.role_id,birth_dt,生命周期,datediff(done_date,done_dt)+1 as '留存天数'
from

(
select c.role_id as role_id,birth_dt,done_dt, datediff(done_dt,birth_dt)+1 as '生命周期'
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
) as a

left join 
(select role_id,to_date(cast(date_time as timestamp)) as done_dt
     from myth_server.server_dungeon_end
     where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
     and game_type =3 
     and battle_result = 1
     and dungeon_id = 48
     and version_name ='1.3.5'
     and country not in ('CN','HK')
) b
on a.role_id = b.role_id

left join
(select role_id,to_date(cast(date_time as timestamp)) as enter_dt
     from myth_server.server_gem_mine_start
     where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
     and version_name ='1.3.5'
     and country not in ('CN','HK')
) c
on b.role_id = c.role_id and b.done_dt = c.enter_dt
where datediff(done_dt,birth_dt) <= 6
group by 1,2,3
) as a

left join   -- 留存玩法进入
(select role_id,to_date(cast(date_time as timestamp)) as done_date
     from myth_server.server_gem_mine_start
     where  day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
     and version_name ='1.3.5'
     and country not in ('CN','HK')
group by 1,2
) as b


--  留存登录
-- (select role_id,to_date(cast(date_time as timestamp)) as done_date
-- from myth.server_role_login
-- where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
-- and version_name ='1.3.5'
-- and country not in ('CN','HK')
-- ) as b

on a.role_id = b.role_id
where datediff(done_date,done_dt) in (0,1,2,3,4,5,6)
group by 1,2,3,4





最高层数

select a.role_id as role_id,birth_dt,datediff(done_dt,birth_dt)+1 as '天数',max_dungeon_id
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
) as a

left join
-- 进入关卡最大值即为最高层数
(select role_id,to_date(cast(date_time as timestamp)) as done_dt,max(dungeon_id) as max_dungeon_id
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (20001,20002)
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
and game_type = 14
group by 1,2) as b

on a.role_id = b.role_id
where datediff(done_dt,birth_dt) <= 6
group by 1,2,3,4




挖矿数据
select a.role_id as role_id,birth_dt,datediff(enter_dt,birth_dt)+1 as '天数',mine_id,consume_currency_id,
       count(log_time) as '次数',sum(consume_currency_num) as '消耗数量'
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
) as a


left join 
(select role_id,to_date(cast(date_time as timestamp)) as enter_dt,log_time,mine_id,consume_currency_id,consume_currency_num
from myth_server.server_gem_mine_start
where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5,6
) b
on a.role_id = b.role_id
where datediff(enter_dt,birth_dt) <= 6
group by 1,2,3,4,5






挖矿秒CD消耗钻石
select b.role_id as role_id,birth_dt,datediff(consume_dt,birth_dt) + 1 as '天数',date_time,change_count
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
) as a


left join
(SELECT role_id,to_date(cast(date_time as timestamp)) as consume_dt,date_time,change_count 
FROM myth.server_currency
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
and currency_id = '3'
AND change_type = 'CONSUME'
and change_method = '70' -- 挖矿秒CD
group by 1,2,3,4
) as b
on a.role_id = b.role_id
where datediff(consume_dt,birth_dt) <= 6
group by 1,2,3,4,5



挖矿战役数据
select birth_dt,b.role_id as role_id,date_time,datediff(done_dt,birth_dt)+1 as '生命周期',dungeon_id,battle_result,auto_battle,game_type
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
) as a


left join

(select dungeon_id ,role_id,date_time,end_time,battle_result,auto_battle,done_dt,game_type 
from
(select a.dungeon_id as dungeon_id ,a.role_id as role_id,date_time,end_time,battle_result,auto_battle,done_dt,a.game_type as game_type
from 
(select dungeon_id,role_id,start_time,date_time,to_date(cast(date_time as timestamp)) as done_dt,game_type
     from myth_server.server_enter_dungeon
     where  day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
     and game_type = 14 --宝石矿坑
     and version_name ='1.3.5'
     and country not in ('CN','HK')
group by 1,2,3,4,5,6
) as a

left join     
(select dungeon_id,role_id,log_time  as end_time,start_time,battle_result,auto_battle,game_type
     from myth_server.server_dungeon_end
     where  day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
     and game_type = 14 --宝石矿坑
     and version_name ='1.3.5'
     and country not in ('CN','HK')
) b 
on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time=b.start_time and a.game_type = b.game_type 
order by a.role_id,a.start_time asc 
) as e  
) as b 
on a.role_id = b.role_id
where datediff(done_dt,birth_dt) <= 6
group by 1,2,3,4,5,6,7,8
order by 2,3,5,6,7


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
勇者试炼

周期参与情况
16日8点-17日20点
19日8点-20日20点
22日8点-23日20点

select a.role_id,a.cycle_id,grade_num,start_time,auto_battle,battle_result
from

(select role_id,cycle_id,dungeon_id,start_time
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and game_type = 17 --勇者试炼
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4
) as a

left join
(
select role_id,cycle_id,dungeon_id,grade_num,auto_battle,battle_result,start_time
from
(select role_id,cycle_id,dungeon_id,grade_num,auto_battle,battle_result,start_time,row_number() over(partition by role_id,cycle_id order by log_time desc) as num -- 周期最高层数
from
(
select role_id,cycle_id,dungeon_id,grade_num,auto_battle,battle_result,start_time,log_time         
from myth_server.server_endless_abyss_junior  
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
union all
select role_id,cycle_id,dungeon_id,
       case when grade_num = 1 then 8
            when grade_num = 2 then 9
            when grade_num = 3 then 10
            when grade_num = 4 then 11
            when grade_num = 5 then 12
          end as grade_num
            ,auto_battle,battle_result,start_time,log_time    
from myth_server.server_endless_abyss_senior
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) as b1
) as b2
where num = 1
) as b
on a.role_id = b.role_id and a.cycle_id = b.cycle_id and a.dungeon_id = b.dungeon_id and a.start_time=b.start_time
group by 1,2,3,4,5,6



勇者试炼关卡时长
select a.role_id,a.cycle_id,grade_num,difficulty,level_zone,battle_time,auto_battle,battle_result
from

(select role_id,cycle_id,dungeon_id,start_time
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and game_type = 17 --勇者试炼
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4
) as a

left join

(select role_id,cycle_id,dungeon_id,grade_num,auto_battle,battle_result,start_time,difficulty,level_zone,
        case when battle_time/60000 is null then '无日志'
            when battle_time/60000 >= 40 then '40+'
            when battle_time/60000 >= 35 and battle_time/60000 < 40  then '[35-40)'
            when battle_time/60000 >= 30 and battle_time/60000 < 35  then '[30-35)'
            when battle_time/60000 >= 25 and battle_time/60000 < 30  then '[25-30)'
            when battle_time/60000 >= 20 and battle_time/60000 < 25  then '[20-25)'
            when battle_time/60000 >= 15 and battle_time/60000 < 20  then '[15-20)'
            when battle_time/60000 >= 10 and battle_time/60000 < 15  then '[10-15)'
            when battle_time/60000 >= 5 and battle_time/60000 < 10  then '[5-10)'
            when battle_time/60000 >= 0 and battle_time/60000 < 5  then '[0-5)'
       end as battle_time
from
(
select role_id,cycle_id,dungeon_id,grade_num,auto_battle,battle_result,start_time,battle_time,difficulty,level_zone   
from myth_server.server_endless_abyss_junior  
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
union all
select role_id,cycle_id,dungeon_id,
       case when grade_num = 1 then 8
            when grade_num = 2 then 9
            when grade_num = 3 then 10
            when grade_num = 4 then 11
            when grade_num = 5 then 12
          end as grade_num
            ,auto_battle,battle_result,start_time,battle_time,difficulty,level_zone   
from myth_server.server_endless_abyss_senior
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) as b1
) as b
on a.role_id = b.role_id and a.cycle_id = b.cycle_id and a.dungeon_id = b.dungeon_id and a.start_time=b.start_time
group by 1,2,3,4,5,6,7,8


玩法周期留存
第一周期 
select count(distinct b.role_id)
from
(select role_id
from myth_server.server_enter_dungeon
where day_time >= ${beginDate} 
and log_time <= ${endLogTime} 
and server_id in (${serverIds})
and game_type = 17 --勇者试炼
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) as a 
left join
-- (select role_id -- 登录
-- from myth.server_role_login
-- where log_time between ${beginLogTime_2} and ${endLogTime_2}
-- and server_id in (${serverIds})
-- and version_name ='1.3.5'
-- and country not in ('CN','HK')
-- ) as b 

(select role_id -- 玩法进入
from myth_server.server_enter_dungeon
where log_time between ${beginLogTime_2} and ${endLogTime_2}
and server_id in (${serverIds})
and game_type = 17 --勇者试炼
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) as b 
on a.role_id = b.role_id


后面周期

select count(distinct b.role_id)
from
(select role_id
from myth_server.server_enter_dungeon
where log_time between ${beginLogTime} and ${endLogTime} 
and server_id in (${serverIds})
and game_type = 17 --勇者试炼
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
and role_id in (select distinct role_id
                from myth_server.server_dungeon_end
                log_time between ${beginLogTime} and ${endLogTime} 
                and server_id in (${serverIds})
                and game_type =3 
                and battle_result = 1
                and dungeon_id = 60
                and version_name ='1.3.5'
                and country not in ('CN','HK'))
) as a 
left join
-- (select role_id -- 登录
-- from myth.server_role_login
-- where log_time between ${beginLogTime_2} and ${endLogTime_2}
-- and server_id in (${serverIds})
-- and version_name ='1.3.5'
-- and country not in ('CN','HK')
-- ) as b 

(select role_id
from myth_server.server_enter_dungeon
where log_time between ${beginLogTime_2} and ${endLogTime_2}
and server_id in (${serverIds})
and game_type = 17 --勇者试炼
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) as b 
on a.role_id = b.role_id


周期参与率
1663286400000 - 1663416000000
1663545600000 - 1663675200000
1663804800000 - 1663934400000
可参与人数
select count(distinct role_id)
from myth_server.server_dungeon_end
where day_time >= ${beginDate} 
and log_time <= ${endLogTime} 
and server_id in (${serverIds})
and game_type =3 
and battle_result = 1
and dungeon_id = 60
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')


参与人数
select count(distinct role_id)
from myth_server.server_enter_dungeon
where log_time between ${beginLogTime} and ${endLogTime} 
and server_id in (${serverIds})
and game_type = 17 --勇者试炼
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')



--------------------------------------------------------------------------------------------------------------------------------------------------------------------
最后一个玩法，通过未通过的留存情况
逻辑：
1、生命周期
2、最后进入的是哪个玩法
3、这个玩法最后通没通关
4、通没通关的玩家第二天登没登录
玩法ID(2：秘境 3：剧情 4：竞技场进攻 6：远古战场 7：地精宝库 8-13：诸神试炼 14：宝石矿坑 16：公会领主 17:无尽深渊 18:公会远征 19:次元危机)

17:无尽深渊 19:次元危机 单独用role_id算
16：公会领主 18:公会远征 剔除掉

select aa.role_id,birth_dt,done_dt,生命周期,game_type,dungeon_id,battle_result,datediff(login_dt,done_dt)+1 as '留存天数'
from
(select a.role_id,birth_dt,done_dt,datediff(done_dt,birth_dt)+1 as '生命周期',game_type,dungeon_id,battle_result
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
) as a


left join     
(select b1.role_id as role_id,done_dt,b1.game_type,b1.dungeon_id,battle_result
from
-- 最后进入的玩法、关卡
(select role_id,done_dt,game_type,dungeon_id,end_time
from
(select a.role_id as role_id,done_dt,a.game_type as game_type,a.dungeon_id as dungeon_id,a.start_time as end_time,row_number() over(partition by a.role_id,done_dt order by a.start_time desc) as num
from
(select dungeon_id,role_id,to_date(cast(date_time as timestamp)) as done_dt,start_time,game_type
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (20001,20002)
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5) a 
left join 
(select dungeon_id,role_id,start_time,game_type
from myth_server.server_dungeon_end
where day_time between ${beginDate} and ${endDate}   and server_id in (20001,20002)
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4) b 
on a.game_type = b.game_type and a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time = b.start_time
) as c
where num = 1
group by 1,2,3,4,5
) b1

left join
-- 计算最后进入的玩法关卡是否通关
(select role_id,dungeon_id,battle_result,start_time,game_type -- 计算秘境、剧情、地精宝库、诸神试炼、宝石矿坑
from myth_server.server_dungeon_end
where day_time between ${beginDate} and ${endDate} and server_id in (20001,20002)
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5

union all

select role_id,0 as dungeon_id,fighting_result as battle_result,start_time,4 as game_type -- 结算竞技场
from myth_server.server_arena
where day_time between ${beginDate} and ${endDate} and server_id in (20001,20002)
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5

union all 

select role_id,boss_id as dungeon_id,1 as battle_result,start_time,6 as game_type -- 结算远古战场 肯定胜利
from myth_server.server_world_boss
where day_time between ${beginDate} and ${endDate} and server_id in (20001,20002)
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5

) b2
on b1.game_type = b2.game_type and b1.dungeon_id = b2.dungeon_id and b1.role_id = b2.role_id and b1.end_time = b2.start_time
group by 1,2,3,4,5
) b
on a.role_id = b.role_id  
where datediff(done_dt,birth_dt) <= 6
group by 1,2,3,4,5,6,7
) as aa 

left join
(select role_id,to_date(cast(date_time as timestamp)) as login_dt
from myth.server_role_login
where day_time between ${beginDate} and ${endDate} and server_id in (20001,20002)
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2
) bb
on aa.role_id = bb.role_id and bb.login_dt >= aa.done_dt
where datediff(login_dt,done_dt) in (0,1)
group by 1,2,3,4,5,6,7,8



