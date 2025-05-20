商业化分析
一、首充活动
生命周期首充情况
select a.role_id as role_id,birth_dt,product_name,vip_level,
       case when b.role_id is not null then '破冰首充'
            else '未首充'
            end as '是否首充',
       datediff(pay_dt,birth_dt)+1 as '生命周期',datediff(login_dt,pay_dt)+1 as '留存'
from
(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name ='1.3.5'
and channel_id=1000  --Android
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name ='1.3.5'
and channel_id=1000  --Android
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
group by 1,2
) as a

left join
(
select role_id,product_name,vip_level,pay_dt
from
(select role_id,pay_price,vip_level,product_name,to_date(cast(date_time as timestamp)) as pay_dt,row_number()over(partition by role_id order by log_time asc) as num
from myth.order_pay
where day_time between ${beginDate} and ${endDate} and server_id in (20001,20002)
and channel_id=1000  --Android
and country not in ('CN','HK')
) as a 
where num = 1
group by 1,2,3,4
) as b
on a.role_id = b.role_id

left join 
(select role_id,to_date(cast(date_time as timestamp)) as login_dt
from myth.server_role_login
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and version_name ='1.3.5'
and channel_id=1000  --Android
and country not in ('CN','HK')
group by 1,2
) as c
on b.role_id = c.role_id
where datediff(pay_dt,birth_dt) in (0,1,2,3,4,5,6) and datediff(login_dt,pay_dt) in (0,1,2,3,4,5,6)
group by 1,2,3,4,5,6,7


首充奖励领取情况  首充之后第几天领取的，领取到几级

select a.role_id,vip_level,currency_id,datediff(get_dt,pay_dt)+1 as '首充-领取天数'
from
(
select role_id,product_name,vip_level,pay_dt -- 首充时间
from
(select role_id,pay_price,vip_level,product_name,to_date(cast(date_time as timestamp)) as pay_dt,row_number()over(partition by role_id order by log_time asc) as num
from myth.order_pay
where day_time between ${beginDate} and ${endDate} and server_id in (20001,20002)
and channel_id=1000  --Android
and country not in ('CN','HK')
) as a 
where num = 1
group by 1,2,3,4
) as a

left join
(select role_id,currency_id,to_date(cast(date_time as timestamp)) as get_dt
from myth.server_currency
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and version_name ='1.3.5'
and channel_id=1000  --Android
and country not in ('CN','HK')
and change_type = 'PRODUCE'
and change_method = '' -- 首充奖励领取
group by 1,2,3
) as b
on a.role_id = b.role_id
group by 1,2,3,4


二、战令系统
每日战令购买情况-看购买时间趋势
select day_time,product_name,count(distinct role_id)
from myth.order_pay
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and country not in ('CN','HK')
and product_name in ('一级战令','二级战令')
group by 1,2
order by 1,2


战令任务完成情况  日常-周常
select task_id,count(distinct role_id)
from myth_server.server_battle_pass_task_completed
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and version_name ='1.3.5'
and channel_id=1000  --Android
and country not in ('CN','HK')
group by 1
order by 1


购买渗透率
可购买人数
需要问策划

购买人数
select product_name,vip_level,count(distinct role_id)
from myth.order_pay
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and country not in ('CN','HK')
and product_name in ('一级战令','二级战令')
group by 1,2
order by 1,2



几天达到满级 从完成第一个任务开始到满级的时间 买/没买战令的
SELECT
    a.role_id,
    (a.min_log_time - b.min_log_time) / 1000 / 3600 / 24 -- 天
from

(
SELECT
    role_id,vip_level,min(log_time) as min_log_time
from
    myth_server.server_battle_pass_task_completed
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and version_name ='1.3.5'
and channel_id=1000  --Android
and country not in ('CN','HK')
and battle_pass_level = 25 -- 满级
and role_id in 
       (select distinct role_id 
        from myth.order_pay 
        where day_time>=${beginDate} and day_time<=${endDate} 
        and server_id in (${serverIds}) 
        and channel_id=1000  --Android
        and country not in ('CN','HK')
        and product_name = '战令')
group by 1,2
) a

left join
(
SELECT 
    role_id,min(log_time) as min_log_time
from 
    myth_server.server_battle_pass_task_completed
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and version_name ='1.3.5'
and channel_id=1000  --Android
and country not in ('CN','HK')
and battle_pass_level = 25 -- 满级
and role_id in 
       (select distinct role_id 
        from myth.order_pay 
        where day_time>=${beginDate} and day_time<=${endDate} 
        and server_id in (${serverIds}) 
        and channel_id=1000  --Android
        and country not in ('CN','HK')
        and product_name = '战令')
GROUP BY 1
) b
on a.role_id = b.role_id


活跃指标  在线时长-登录次数
购买战令用户登录时长，登陆次数
-- 在线时长
select
    day_time,
    count(role_id) as role_num,
    avg(num) as num_avg,
    appx_median(num) as num_median
from
(
    SELECT
        role_id,
        day_time,
        count(ping) as num
    from 
        myth.client_online
    where day_time>=${beginDate} and day_time<=${endDate} 
          and server_id in (${serverIds}) 
          and version_name ='1.3.5'
          and channel_id=1000  --Android
          and country not in ('CN','HK')
          and role_id in  -- 购买/未购买
          (select distinct role_id
           from myth.order_pay 
           where day_time>=${beginDate} and day_time<=${endDate} 
           and server_id in (${serverIds}) 
           and channel_id=1000  --Android
           and country not in ('CN','HK')
           and product_name='战令'
          )
    group by 1,2
) a
group by 1 order by 1



登陆次数
select
    day_time,
    count(role_id),
    avg(cishu) cishu_avg,
    appx_median(cishu) cishu_median
from
    (select
        day_time,
        role_id,
        count(role_id) as cishu
    from
        myth.server_role_login
    where day_time>=${beginDate} and day_time<=${endDate} 
          and server_id in (${serverIds}) 
          and version_name ='1.3.5'
          and channel_id=1000  --Android
          and country not in ('CN','HK')
          and role_id in -- 购买/未购买
          (select distinct role_id
           from myth.order_pay 
           where day_time>=${beginDate} and day_time<=${endDate} 
           and server_id in (${serverIds}) 
           and channel_id=1000  --Android
           and country not in ('CN','HK')
           and product_name='战令'
          )
    group by 1,2
    ) a
group by 1 order by 1


购买战令的次留
select a.role_id,datediff(login_dt,pay_dt)+1 as '天数'
from
(select role_id,to_date(cast(date_time as timestamp)) as pay_dt
from myth.order_pay
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and country not in ('CN','HK')
and product_name = '战令'
group by 1,2) as a

left join 
(select role_id,to_date(cast(date_time as timestamp)) as login_dt
from myth.server_role_login
where day_time>=${beginDate} and day_time<=${end2Date} 
and server_id in (${serverIds}) 
and version_name ='1.3.5'
and channel_id=1000  --Android
and country not in ('CN','HK')
group by 1,2
) as b
on a.role_id = b.role_id
where datediff(login_dt,pay_dt) in (0,1)



























1、首次付费转化
等级分布
select role_level,product_name,count(distinct role_id)
from
(select role_level,role_id,pay_price,product_name,row_number()over(partition by role_id order by log_time asc) as num
from myth.order_pay
where day_time between ${beginDate} and ${endDate} and server_id in (20001,20002)
and channel_id=1000  --Android
and country not in ('CN','HK')
) as a 
where num = 1
group by 1,2
order by 1 

金额分布-按照礼包价格casewhen
select pay_price,product_name,count(distinct role_id)
from
(select role_level,role_id,pay_price,product_name,row_number()over(partition by role_id order by log_time asc) as num
from myth.order_pay
where day_time between ${beginDate} and ${endDate} and server_id in (20001,20002)
and channel_id=1000  --Android
and country not in ('CN','HK')
) as a 
where num = 1
group by 1,2
order by 1 

周期分布
select 付费周期,product_name,count(distinct role_id)
from
(
select a.role_id,birth_dt,datediff(pay_dt,birth_dt) + 1 as '付费周期',product_name,pay_price
from
(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name ='1.3.5'
and channel_id=1000  --Android
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name ='1.3.5'
and channel_id=1000  --Android
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
group by 1,2
) as a

left join

(
select role_id,product_name,pay_price,pay_dt
from
(select role_id,pay_price,product_name,to_date(cast(date_time as timestamp)) as pay_dt,row_number()over(partition by role_id order by log_time asc) as num
from myth.order_pay
where day_time between ${beginDate} and ${endDate} and server_id in (20001,20002)
and channel_id=1000  --Android
and country not in ('CN','HK')
) as a 
where num = 1
) as b
on a.role_id = b.role_id
group by 1,2,3,4,5
) as aa
group by 1,2
order by 1



主线关卡分布
select dungeon_id,product_name,count(a.role_id)
from

(select role_id,log_time,product_name,pay_price
from
(select role_id,log_time,pay_price,product_name,row_number()over(partition by role_id order by log_time asc) as num
from myth.order_pay
where day_time between ${beginDate} and ${endDate} and server_id in (20001,20002)
and channel_id=1000  --Android
and country not in ('CN','HK')
) as a 
where num = 1
group by 1,2,3,4
) as a 

left join

(select role_id,dungeon_id,log_time,battle_result,auto_battle
from
(select dungeon_id,role_id,log_time,battle_result,auto_battle,row_number() over(partition by role_id order by log_time desc) as num1
from myth_server.server_dungeon_end
where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 3
and version_name ='1.3.5'
and channel_id=1000  --Android
and country not in ('CN','HK')
) b1
where num1 = 1 
group by 1,2,3,4,5
) as b

on a.role_id = b.role_id and a.log_time >= b.log_time


首日在线时长分布

select case when 首日在线时长 >= 0 and 首日在线时长 < 5 then '[0,5)'
            when 首日在线时长 >= 5 and 首日在线时长 < 10 then '[5,10)'
            when 首日在线时长 >= 10 and 首日在线时长 < 20 then '[10,20)'
            when 首日在线时长 >= 20 and 首日在线时长 < 30 then '[20,30)'
            when 首日在线时长 >= 30 then '30+',product_name,count(distinct b.role_id)
from

(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name ='1.3.5'
and channel_id=1000  --Android
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name ='1.3.5'
and channel_id=1000  --Android
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
group by 1,2
) as a

left join

(
select role_id,product_name,pay_price,pay_dt
from
(select role_id,pay_price,product_name,to_date(cast(date_time as timestamp)) as pay_dt,row_number()over(partition by role_id order by log_time asc) as num
from myth.order_pay
where day_time between ${beginDate} and ${endDate} and server_id in (20001,20002)
and channel_id=1000  --Android
and country not in ('CN','HK')
) as a 
where num = 1
) as b
on a.role_id = b.role_id and a.birth_dt = b.pay_dt

left join  -- 在线时长  分钟
(
select role_id,to_date(cast(date_time as timestamp)) as online_dt,count(ping) as '首日在线时长' 
from myth.client_online
where day_time between ${beginDate} and ${endDate}
and channel_id=1000
and version_name ='1.3.5'   
and channel_id=1000  --Android
and country not in ('CN','HK')
group by 1,2
) as c  
on b.role_id = c.role_id and b.pay_dt = c.online_dt

group by 1,2
order by 1



2、礼包复够率
-- select product_name 
--       ,count(distinct role_id) 总用户数
--       ,count(distinct case when 是否7天内复购=1 then role_id end) 7日内复购用户数
--       ,count(distinct case when 是否7天内复购=1 then role_id end)/count(distinct role_id) 7日复购率
-- from 
-- (select product_name
--        ,role_id
--        ,date_time -- 本次购买时间
--        ,lead(date_time) over(partition by role_id order by date_time) -- 下次购买时间
--        ,case when (unix_timestamp(lead(date_time) over(partition by role_id order by date_time))-unix_timestamp(date_time))/(24*60*60)<=7 then 1 end 是否7天内复购 
-- from myth.order_pay
-- where day_time between ${beginDate} and ${endDate} and server_id in (20001,20002)
-- and channel_id=1000  --Android
-- and country not in ('CN','HK')
-- group by 1,2,3,4,5
-- ) as a
-- group by 1


  
select product_name 
      ,count(distinct role_id) 总用户数
      ,count(distinct case when 是否7天内复购=1 then role_id end) 7日内复购用户数
      ,count(distinct case when 是否7天内复购=1 then role_id end)/count(distinct role_id) 7日复购率
from 

(select a.role_id,a.product_name,
       case when (unix_timestamp(b.date_time)-unix_timestamp(a.date_time))/(24*60*60)<=7 then 1 end 是否7天内复购
from
(select role_id,product_name,date_time 
from myth.order_pay
where day_time between ${beginDate} and ${endDate} and server_id in (20001,20002)
and channel_id=1000  --Android
and country not in ('CN','HK')
) as a 

left join
(select role_id,product_name,date_time 
from myth.order_pay
where day_time between ${beginDate} and ${endDate2} and server_id in (20001,20002)
and channel_id=1000  --Android
and country not in ('CN','HK')
) as b 
on a.role_id = b.role_id and a.product_name = b.product_name and a.date_time < b.date_time
group by 1,2,3
) as a
group by 1





3、在线领奖
只有一次，领取奖励后开启下一次计时，计时都是10分钟

每个阶段领取人数  整体-付费-免费
select bonus_num,count(distinct role_id) as '整体用户数',
       count(distibct case when pay_or_not = 'free_user' then role_id) as '免费用户数',
       count(distibct case when pay_or_not = 'pay_user' then role_id) as '付费用户数'
from

(select bonus_num,a.role_id as role_id,
       case when b.role_id is NULL then 'free_user'
            when b.role_id not is NULL then 'pay_user'
       end as pay_or_not
from
(select bonus_num,role_id
from myth_server.server_online_bonus
where day_time between ${beginDate} and ${endDate2} and server_id in (20001,20002)
and version_name ='1.3.5'
and channel_id=1000  --Android
and country not in ('CN','HK')
group by 1,2) as a

left join
(select role_id
from myth.order_pay
where day_time between ${beginDate} and ${endDate2} and server_id in (20001,20002)
and channel_id=1000  --Android
and country not in ('CN','HK')
group by 1
) as b
on a.role = b.role_id
group by 1,2,3
) as aa
group by 1
order by 1



生命周期阶段领取
select datediff(get_dt,birth_dt) + 1 as '天数',bonus_num,count(distinct a.role_id)
from
(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name ='1.3.5'
and channel_id=1000  --Android
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name ='1.3.5'
and channel_id=1000  --Android
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
group by 1,2
) as a

left join
(select bonus_num,role_id,to_date(cast(date_time as timestamp)) as get_dt
from myth_server.server_online_bonus
where day_time between ${beginDate} and ${endDate2} and server_id in (20001,20002)
and version_name ='1.3.5'
and channel_id=1000  --Android
and country not in ('CN','HK')
group by 1,2,3
) as b
on a.role_id = b.role_id  
group by 1,2
order by 1,2
where datediff(get_dt,birth_dt) in (0,1,2,3,4,5,6)
