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
       sum(case when datediff(pay_dt,birth_dt)<=1 then pay_price end) as '前二天付费总收入',
       sum(case when datediff(pay_dt,birth_dt)<=2 then pay_price end) as '前三天付费总收入',
       sum(case when datediff(pay_dt,birth_dt)<=6 then pay_price end) as '前七天付费总收入',
       sum(case when datediff(pay_dt,birth_dt)<=13 then pay_price end) as '前十四天付费总收入',
       sum(case when datediff(pay_dt,birth_dt)<=29 then pay_price end) as '前三十天付费总收入',
       count(distinct case when datediff(pay_dt,birth_dt)=0 then b.role_id end) as '第一天新增付费用户数',
       count(distinct case when datediff(pay_dt,birth_dt)<=2 then b.role_id end) as '前三天新增付费用户数',
       count(distinct case when datediff(pay_dt,birth_dt)<=6 then b.role_id end) as '前七天新增付费用户数'
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
活跃指标-> 在线时长、登录次数

整体 - 每日新增在线时长均值、中位数
select birth_dt,country,datediff(login_dt,birth_dt) as diffs,
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
where datediff(login_dt,birth_dt)  is not null 
group by 1,2,3



付费 - 每日新增在线时长均值、中位数
select birth_dt,country,datediff(login_dt,birth_dt) as diffs,
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
where datediff(login_dt,birth_dt)  is not null and c.role_id is not null
group by 1,2,3




整体 - 次留用户的首日时长均值、中位数
select birth_dt,bi_day2,country,datediff(online_dt,birth_dt) as diffs,
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
where datediff(online_dt,birth_dt)  is not null 
group by 1,2,3,4



付费 - 次留用户的首日时长均值、中位数
select birth_dt,bi_day2,country,datediff(online_dt,birth_dt) as diffs,
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
where datediff(online_dt,birth_dt)  is not null and e.role_id is not null
group by 1,2,3,4




整体 - 登录次数均值、中位数
select  birth_dt,datediff(login_dt,birth_dt) as diffs,
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
where datediff(login_dt,birth_dt)  is not null 
group by 1,2



付费 - 登录次数均值、中位数
select  birth_dt,datediff(login_dt,birth_dt) as diffs,
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
where datediff(login_dt,birth_dt)  is not null and d.device_id is not null
group by 1,2



整体 - 次留用户的首日登录次数均值、中位数
select birth_dt,bi_day2,country,datediff(login_num_dt,birth_dt) as diffs,
count(distinct a.role_id) as role_id,
round(avg(sessions),2) as avg_duration,
appx_median(sessions) as median_duration
from 
(select birth_dt,country,a.role_id,a.device_id
count(distinct case when datediff(login_dt,birth_dt) = 1 then c.role_id else null end) as bi_day2
from 
(select birth_dt,a.device_id,role_id,country from 
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
group by 1,2,3,4
) a 

left join 
(
select device_id,to_date(cast (date_time as timestamp)) as login_num_dt,count(distinct log_time) as sessions
from myth.device_launch
where day_time>=${beginDate} and day_time<=${end2Date} 
and channel_id=1000
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2) d 
on a.device_id=d.device_id and login_dt>=birth_dt
where datediff(login_num_dt,birth_dt)  is not null 
group by 1,2,3,4




付费 - 次留用户的首日登录次数均值、中位数
select birth_dt,bi_day2,country,datediff(login_num_dt,birth_dt) as diffs,
count(distinct a.role_id) as role_id,
round(avg(sessions),2) as avg_duration,
appx_median(sessions) as median_duration
from 
(select birth_dt,country,a.role_id,a.device_id
count(distinct case when datediff(login_dt,birth_dt) = 1 then c.role_id else null end) as bi_day2
from 
(select birth_dt,a.device_id,role_id,country from 
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
group by 1,2,3,4
) a 

left join 
(
select device_id,to_date(cast (date_time as timestamp)) as login_num_dt,count(distinct log_time) as sessions
from myth.device_launch
where day_time>=${beginDate} and day_time<=${end2Date} 
and channel_id=1000
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2) d 
on a.device_id=d.device_id and login_dt>=birth_dt

left join 
(
select role_id,to_date(cast (date_time as timestamp)) as pay_dt
from myth.order_pay
where day_time>=${beginDate} and day_time<=${end2Date} 
and channel_id=1000
and country not in ('CN','HK')
group by 1,2) e 
on a.role_id=e.role_id and pay_dt>=birth_dt and pay_dt <= online_dt
where datediff(login_num_dt,birth_dt)  is not null and e.role_id is not null
group by 1,2,3,4
