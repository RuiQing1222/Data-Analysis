

# 查询role_id 身上有几个任务
SELECT day_time,
       task_id
FROM fairy_town_server.server_task_accept 
WHERE role_id = '1000200000000128273' and task_id NOT IN (SELECT task_id from fairy_town_server.server_task_completed where role_id = '1000200000000128273')
GROUP BY 1,2
ORDER BY day_time DESC

#用户登录情况
SELECT day_time,
       role_id
FROM fairy_town.role_login
WHERE role_id = '1000100000000023415' and day_time >= 20210901
GROUP BY 1,2           
ORDER BY day_time ASC

# 床的消耗记录
SELECT 
    role_id
    ,day_time
    ,change_type
    ,change_count
FROM 
    fairy_town.server_prop
WHERE 
    role_id = '1000300000000197011'
    AND prop_id = '118004'
    AND day_time >= 20211020



# 宝石月卡
select 
    role_id,
    day_time,
    product_name
from 
    fairy_town.order_pay
where 
    (product_name = '80宝石' or product_name = '宝石月卡')
    and role_id = '1000100000000128785'
order by day_time desc


# 体力获取
SELECT
    day_time,
    change_method,
    sum(change_count)
from fairy_town.server_currency
WHERE role_id = '1000300000000227371'
and server_id in (10001,10002,10003)
and currency_id = '3'
and day_time >= 20211107
and day_time <= 20211108
and change_type = 'PRODUCE'
GROUP BY 1,2
ORDER BY 1


-- 肥料获取消耗
SELECT 
    day_time
    ,change_type
    ,sum(change_count) AS num
FROM 
    fairy_town.server_prop
WHERE 
    role_id = '1000300000000136637'
    and prop_id = '127019'
    AND day_time >= 20211027
    AND day_time <= 20211028
GROUP BY 1,2


-- 1000100000000171873 能帮忙查一下这个玩家昨天和今天猫头鹰订单的完成和奖励记录吗？
SELECT 
    day_time,
    order_id,
    consume_props_ids,
    consume_props_count,
    get_rewards,
    get_count
FROM 
    fairy_town_server.server_order_owl
where 
    role_id = '1000100000000171873'
    and day_time >= 20211103
    and day_time <= 20211104
ORDER BY day_time




-- 等级提升的奖励
SELECT day_time from fairy_town.server_role_upgrade where role_id = '1000200000000037964' and role_level = 32

SELECT 
    change_method,
    sum(change_count)
FROM fairy_town.server_currency
WHERE role_id = '1000300000000106013'
  AND day_time >= 20211108
  and day_time <= 20111109
  and change_type = 'PRODUCE'
  and currency_id = '3'
 GROUP BY 1
  

SELECT prop_id,
sum(change_count)
FROM fairy_town.server_prop
WHERE role_id = '1000300000000000905'
  AND day_time = 20211105 
  and change_type = 'PRODUCE'
  and change_method = '6'
 GROUP BY 1
  
  
 -- 通过篝火获取体力
SELECT 
    prop_id
    ,sum(change_count)
FROM 
    fairy_town.server_prop
WHERE 
    role_id = '1000100000000135450'
    AND prop_id in ('110001','110002','110003','110004','110005')
    AND day_time = 20211105
    and change_type = 'PRODUCE'
GROUP BY 1
ORDER BY 1


# 游戏登录奖励
SELECT 
    prop_id
    ,sum(change_count) AS num
FROM 
    fairy_town.server_prop   -- server_currency
WHERE 
    role_id = '1000300000000154818'
    and day_time = 20211108
    and change_method in ('70','71') and change_type = 'PRODUCE'
GROUP BY 1







select
    a.birth_dt as `日期`,
    b.day1 as day1,
    b.day2 as day2,
    b.day3 as day3,
    b.day4 as day4,
    b.day5 as day5,
    b.day6 as day6,
    b.day7 as day7
from
    (
    -- 1、af_push表和device_activate表 device_id 关联查询
    select 
        to_date(cast(b.date_time as timestamp)) as birth_dt,
        b.device_id as device_id
    from 
        fairy_town.af_push as a, fairy_town.device_activate as b 
    where a.customer_user_id = b.device_id and a.day_time >= 20211011 and a.day_time <= ${endDate} and b.country in ('ES','IT') and b.channel_id = 2000 and a.media_source = 'Apple Search Ads'
    ) as a 

join
    -- 2、按照device_id,时间计算每天收入 order_pay自关联
    
(
    select
        device_id,
        a.dates_a as dates,
        round(sum(if(datediff(dates_b,dates_a)=0, pay_price_2, 0)),2) as day1,
        round(sum(if(datediff(dates_b,dates_a)<=1, pay_price_2, 0)),2) as day2,
        round(sum(if(datediff(dates_b,dates_a)<=2, pay_price_2, 0)),2) as day3,
        round(sum(if(datediff(dates_b,dates_a)<=3, pay_price_2, 0)),2) as day4,
        round(sum(if(datediff(dates_b,dates_a)<=4, pay_price_2, 0)),2) as day5,
        round(sum(if(datediff(dates_b,dates_a)<=5, pay_price_2, 0)),2) as day6,
        round(sum(if(datediff(dates_b,dates_a)<=6, pay_price_2, 0)),2) as day7
    from
        (
        select
            op1.device_id as device_id,
            op1.dates as dates_a,
            op2.dates as dates_b,
            op2.pay_price as pay_price_2,
            datediff(op2.dates,op1.dates) as p
        from
            (select
                device_id,
                to_date(cast(date_time as timestamp)) as dates
             from
                fairy_town.device_activate
            where day_time >= 20211011 and day_time <= ${endDate} 
            and country in  ('ES','IT') and channel_id = 2000  
            and device_id not in (SELECT customer_user_id from fairy_town.af_push where day_time >= 20211011 and day_time <= 20211031)
            ) as op1 ,

            (select
                device_id,
                sum(pay_price) as pay_price,
                to_date(cast(date_time as timestamp)) as dates
             from
                fairy_town.order_pay
             where
                day_time >= 20211011 and day_time <= ${endDate}
             group by device_id,dates
             ) as op2 
        where op1.device_id = op2.device_id and op2.dates >= op1.dates
        ) as a  
 
    group by
        a.device_id,a.dates_a
) as b
on a.device_id = b.device_id
order by 1





# 日活异常
1、确认数据准确性
2、拆解新老用户，谁导致日活下降

SELECT distinct device_id from fairy_town.device_activate where day_time >=20211118 and day_time <= 20211122 -- 新用户
SELECT distinct device_id from fairy_town.device_activate where day_time <=20211117 -- 老用户

DAU
新用户日活
SELECT
    b.day_time,
    count(distinct b.device_id)
from

(SELECT 
    day_time,
    device_id
from fairy_town.device_activate 
where day_time >=20211117 and day_time <= 20211122
) as a
left join 
(SELECT
    day_time,
    device_id
from fairy_town.server_role_login
where day_time >= 20211117 and day_time <= 20211122
) as b
on a.device_id = b.device_id
group by 1
order by 1



老用户日活
SELECT 
    day_time,
    count(distinct device_id)
from fairy_town.server_role_login
where
    day_time >= 20211117 and day_time <= 20211122
    and device_id in (SELECT distinct device_id from fairy_town.device_activate where day_time <=20211116)
group by 1
order by 1




-- 10号、11号新增的设备，在第二天流失用户的设备内存（安卓 广告 GG 俄罗斯）
SELECT
    day_time,
    device_id,
    device_total_ram
from

(
select
    a.day_time as day_time,
    a.device_id as device_id,
    a.device_total_ram as device_total_ram
from
(SELECT
    day_time,
    device_id,
    device_total_ram
from fairy_town.device_activate
where day_time = 20211110
) as a
left join
(SELECT
    customer_user_id
from fairy_town.af_push
where 
    media_source = 'googleadwords_int'
    and platform = 'android'
    and country_code = 'RU'
) as b on a.device_id = b.customer_user_id
order by day_time
) c
where device_id not in (SELECT distinct device_id from fairy_town.device_launch where day_time = 20211111)


设备信息
select device_id,device_cpu,device_total_ram,device_brand,device_model,os_version
from fairy_town.device_launch
where day_time>=20211201
and device_id in (select device_id from fairy_town.role_login
where role_id='1000300000000278629' 
and day_time>=20211201
group by 1)
group by 1,2,3,4,5,6



战令验证
SELECT date_time,battle_pass_level from fairy_town_server.server_battle_pass_points where role_id = '1000200000000133143' and day_time >= 20211209
ORDER BY 1

SELECT date_time,task_id from fairy_town_server.server_battle_pass_task_completed where role_id = '1000200000000133143' and day_time >= 20211209
ORDER BY 1

SELECT date_time,product_name,sum(pay_price) from fairy_town.order_pay where role_id = '1000200000000066015' and day_time = 20211230
GROUP BY 1,2 ORDER BY 1




select
    b.ranks as ranks,
    b.day_time_a as day_time,
    sum(case when by_day = 0 then 1 else 0 end) '新增',
    sum(case when by_day = 1 then 1 else 0 end) day_2,
    -- sum(case when by_day = 2 then 1 else 0 end) day_3,
    -- sum(case when by_day = 3 then 1 else 0 end) day_4,
    -- sum(case when by_day = 4 then 1 else 0 end) day_5,
    -- sum(case when by_day = 5 then 1 else 0 end) day_6,
    sum(case when by_day = 6 then 1 else 0 end) day_7,
    -- sum(case when by_day = 14 then 1 else 0 end) day_14,
    sum(case when by_day = 30 then 1 else 0 end) day_30
from
(
    select 
        device_id_b as device_id,
        day_time_a,-- first_day
        day_time_b,
        datediff(day_time_b,day_time_a) as by_day, -- 间隔
        ranks
    from
        (select 
            b.device_id as device_id_b,
            a.day_times as day_time_a,
            b.day_times as day_time_b,
            a.ranks as ranks
        from
             (
             select 
                device_id,
                to_date(cast(date_time as timestamp)) as day_times 
             from fairy_town.device_launch
             where day_time >= ${start_time} and day_time <= ${endDate}
             group by 
                device_id,
                day_times
            ) b 
        right join 
            (select 
                device_id,
                to_date(cast(date_time as timestamp)) as day_times,
                case when country='US' then 1
                     when country='DE' then 2
                     when country in ('UK','GB') then 3
                     when country='AU' then 4
                     when country='FR' then 5
                     when country='CA' then 6
                     when country='NL' then 7
                     when country='TH' then 8
                     when country='NO' then 9
                     when country='SE' then 10
                     when country='AT' then 11
                     when country='DK' then 12
                     when country='CH' then 13
                     when country='IT' then 14
                     when country='BR' then 15
                     when country='NZ' then 16
                     when country='RU' then 17
                     when country='BE' then 18
                     when country='ES' then 19
                     when country='MY' then 20
                end as ranks
            from 
                fairy_town.device_activate
            where day_time >= ${start_time} and day_time <= ${endDate} and channel_id = 1000
            group by 1,2,3
            ) a
            on a.device_id = b.device_id
        ) as reu
    order by device_id_b,day_time_b      
) as b

group by 1,2
order by 1,2


国家收入排名
SELECT 
    case
        when country = 'US' then '美国'
        when country = 'DE' then '德国'
        when country = 'FR' then '法国'
        when country = 'GB' then '英国'
        when country = 'AU' then '澳大利亚'
        when country = 'CA' then '加拿大'
        when country = 'NZ' then '新西兰'
        when country = 'SE' then '瑞典'
        when country = 'DK' then '丹麦'
        when country = 'NO' then '挪威'
        when country = 'FI' then '芬兰'
        when country = 'IT' then '意大利'
        when country = 'ES' then '西班牙'
        when country = 'RU' then '俄罗斯'
        when country = 'NL' then '荷兰'
        when country = 'BE' then '比利时'
        when country = 'PL' then '波兰'
        when country = 'AT' then '奥地利'
        when country = 'CH' then '瑞士'
        when country = 'TH' then '泰国'
        when country = 'BR' then '巴西'
        when country = 'SG' then '新加坡'
        when country = 'MY' then '马来西亚'
    end as country,sum(pay_price) as '总收入' from fairy_town.order_pay 
where  day_time >= 20211001 and day_time <= 20220113
and server_id in (10001,10002,10003)
group by 1






select 副本ID,进入关卡人数,
通关率 as '通关率%', 
round(下一关进入人数/进入关卡人数*100,2) as '通过率%'
from 
(select 副本ID,
进入关卡人数,
lead(进入关卡人数,1,0)over(order by 副本ID asc) as '下一关进入人数',
通关率
from 
(select a.dungeon_id as '副本ID',
count(distinct a.role_id) as '进入关卡人数',
count(distinct b.role_id) as '通关人数',
round(count(distinct b.role_id)/count(distinct a.role_id)*100,2) as '通关率'
from
(select dungeon_id,role_id
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and game_type=3
group by 1,2) a 
left join 
(select dungeon_id,role_id
from myth_server.server_dungeon_end
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and game_type=3
and battle_result=1
group by 1,2) b 
on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id
group by 1
order by 1) a 
) t 






新手引导
SELECT step,act_num, count(DISTINCT role_id) from myth_server.server_event_guide
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
GROUP BY 1,2
ORDER BY 1,2


A项目设备流失
select device_total_ram,code,count(distinct a.device_id) as '通过数量'
from
(SELECT code,device_id FROM myth.client_event WHERE day_time = 20220118) as a
left join
(SELECT device_id, 
case when device_total_ram>0  and device_total_ram<=1    then '0-1'
     when device_total_ram>1  and device_total_ram<=2    then '1-2'
     when device_total_ram>2  and device_total_ram<=4    then '2-4'
     when device_total_ram>4  and device_total_ram<=8    then '4-8'
     when device_total_ram>8                             then '8+'
     end as device_total_ram
FROM myth.device_launch WHERE day_time = 20220118) as b
on a.device_id = b.device_id
group by 1,2
order by 1,2


再营销安卓 IDFA
SELECT device_id2
from
(SELECT a.device_id as device_id,device_id2,
    case when max_time < 20220112 then '流失'
         else '留存'
         end as lost
from

(SELECT device_id from fairy_town.device_activate where day_time >= 20210601 and day_time <= 20220111) as a
left join 
(select device_id,device_id2,max(day_time) as max_time from fairy_town.device_launch where day_time >= 20210601 and channel_id = 1000 GROUP BY 1,2) as b
on a.device_id = b.device_id
GROUP BY 1,2,3) as aa
WHERE lost = '流失'
GROUP BY 1



角色LTV
select
    b.day_time_a as day_time,
    count(distinct role_id_a) as '新增',
    sum(if(by_day=0, pay_sum,0)) day_1,
    sum(if(by_day<=3, pay_sum,0)) day_3,
    sum(if(by_day<=7, pay_sum,0)) day_7
from
(
    select 
        role_id_b as role_id,
        role_id_a,
        day_time_a,-- first_day
        day_time_b,
        pay_sum,
        datediff(day_time_b,day_time_a) as by_day -- 间隔
    from
        (select 
            b.role_id as role_id_b,
            a.role_id as role_id_a,
            a.day_times as day_time_a,
            b.day_times as day_time_b,
            pay_sum
        from
             (
             select 
                role_id,
                to_date(cast(date_time as timestamp)) as day_times,
                sum(pay_price) as pay_sum
             from fairy_town.order_pay
             where day_time >= ${start_time} and day_time <= ${endDate}
             group by 
                role_id,
                day_times
            ) b 
        right join 
            (select 
                role_id,
                to_date(cast(date_time as timestamp)) as day_times
            from 
                fairy_town.server_role_create
            where day_time >= ${start_time} and day_time <= ${endDate}
            group by 
                role_id,
                day_times
            ) a
            on a.role_id = b.role_id
        ) as reu
    order by role_id_b,day_time_b      
) as b

group by 1
order by 1



select
    b.day_time_a as day_time,
    count(distinct case when by_day = 0 then role_id else null end) '新增付费人数',
from
(
    select 
        role_id_b as role_id,
        day_time_a,-- first_day
        day_time_b,
        datediff(day_time_b,day_time_a) as by_day -- 间隔
    from
        (select 
            b.role_id as role_id_b,
            a.day_times as day_time_a,
            b.day_times as day_time_b
        from
             (
             select 
                role_id,
                to_date(cast(date_time as timestamp)) as day_times 
             from fairy_town.order_pay
             where day_time >= ${start_time} and day_time <= ${endDate}
             group by 
                role_id,
                day_times
            ) b 
        right join 
            (select 
                role_id,
                to_date(cast(date_time as timestamp)) as day_times
            from 
                fairy_town.server_role_create
            where day_time >= ${start_time} and day_time <= ${endDate}
            group by 
                role_id,
                day_times
            ) a
            on a.role_id = b.role_id
        ) as reu
    order by role_id_b,day_time_b      
) as b

group by 1
order by 1




付费用户
select distinct role_id from fairy_town.order_pay where day_time >= 20210916 and day_time <= 20220126


第一次获取钻石的方式
select change_method,count(distinct role_id) as '用户数'
from
( 
select role_id,change_method,row_number() over(partition by role_id order by log_time asc) as row_num
from
(
(select role_id,cast(change_method as int) as change_method,log_time from fairy_town.server_currency
where change_type = 'PRODUCE' and currency_id = '2' and server_id in (10001,10002,10003)
and change_method in ('1','2','7','8','9','25','26','31','68','73','74','87','89','94','102')
and day_time >= ${start_time} and day_time <= ${end_time}
and role_id in (select distinct role_id from fairy_town.order_pay where day_time >= ${start_time} and day_time <= ${end_time})
and role_id in (select distinct role_id from fairy_town.server_role_create where server_id in (10001,10002,10003) and day_time >= ${start_time} and day_time <= ${end_time})
group by 1,2,3
)
union all
(select role_id,cast(recovery_method as int) as change_method,log_time from fairy_town_server.server_gem_recovery
where server_id in (10001,10002,10003) and day_time >= ${start_time} and day_time <= ${end_time}
and recovery_method in ('1','2','7','8','9','25','26','31','68','73','74','87','89','94','102')
and role_id in (select distinct role_id from fairy_town.order_pay where day_time >= ${start_time} and day_time <= ${end_time})
and role_id in (select distinct role_id from fairy_town.server_role_create where server_id in (10001,10002,10003) and day_time >= ${start_time} and day_time <= ${end_time})
group by 1,2,3
) 
) as bb
) as aa 
where row_num = 1 
group by 1 order by 1 





第一次获取体力的方式
select change_method,count(distinct role_id) as '用户数'
from
( 
select role_id,change_method,row_number() over(partition by role_id order by log_time asc) as row_num
from
(
(select role_id,change_method,log_time from fairy_town.server_currency  -- 12.9号以前的
where change_type = 'PRODUCE' and currency_id = '3' and server_id in (10001,10002,10003)
and change_method in ('1','2','7','8','9','25','26','31','68','73','74','87','89','94','102')
and day_time >= ${start_time} and day_time <= ${end_time}
and role_id in (select distinct role_id from fairy_town.order_pay where day_time >= ${start_time} and day_time <= ${end_time})
and role_id in (select distinct role_id from fairy_town.server_role_create where server_id in (10001,10002,10003) and day_time >= ${start_time} and day_time <= ${end_time})
group by 1,2,3
)
union all
(select role_id,recovery_method as change_method,log_time from fairy_town_server.server_physical_recovery -- 12.9号以后的
where server_id in (10001,10002,10003) and day_time >= ${start_time} and day_time <= ${end_time}
and recovery_method in ('1','2','7','8','9','25','26','31','68','73','74','87','89','94','102')
and role_id in (select distinct role_id from fairy_town.order_pay where day_time >= ${start_time} and day_time <= ${end_time})
and role_id in (select distinct role_id from fairy_town.server_role_create where server_id in (10001,10002,10003) and day_time >= ${start_time} and day_time <= ${end_time})
group by 1,2,3
) 
union all
(select role_id,product_name as change_method,log_time from fairy_town.order_pay -- 购买礼包的
where server_id in (10001,10002,10003) and day_time >= ${start_time} and day_time <= ${end_time}
and game_product_id in 
('com.managames.fairytown.iap_0.99b','com.managames.fairytown.iap_2.99b','com.managames.fairytown.iap_0.99s','com.managames.fairytown.iap_1.99s',
'com.managames.fairytown.iap_3.99s','com.managames.fairytown.iap_7.99s','com.managames.fairytown.iap_9.99s','com.managames.fairytown.iap_12.99s',
'com.managames.fairytown.iap_19.99s','com.managames.fairytown.iap_39.99s','com.managames.fairytown.iap_69.99s','com.managames.fairytown.iap_99.99s',
'com.managames.fairytown.iap_0.99vc','com.managames.fairytown.iap_1.99v','com.managames.fairytown.iap_2.99v','com.managames.fairytown.iap_3.99vg',
'com.managames.fairytown.iap_3.99ve','com.managames.fairytown.iap_4.99vb','com.managames.fairytown.iap_4.99vgc','com.managames.fairytown.iap_4.99veg',
'com.managames.fairytown.iap_7.99v','com.managames.fairytown.iap_9.99vg','com.managames.fairytown.iap_9.99vb','com.managames.fairytown.iap_9.99vgc',
'com.managames.fairytown.iap_9.99vp','com.managames.fairytown.iap_9.99ve','com.managames.fairytown.iap_14.99v','com.managames.fairytown.iap_14.99veg',
'com.managames.fairytown.iap_19.99vb','com.managames.fairytown.iap_19.99vgc','com.managames.fairytown.iap_19.99ve','com.managames.fairytown.iap_29.99veg',
'com.managames.fairytown.iap_30.99v','com.managames.fairytown.iap_39.99vg','com.managames.fairytown.iap_54.99v','com.managames.fairytown.iap_84.99v',
'com.managames.fairytown.iap_1.99v2','com.managames.fairytown.iap_6.99v','com.managames.fairytown.iap_12.99v','com.managames.fairytown.iap_26.99v',
'com.managames.fairytown.iap_45.99v','com.managames.fairytown.iap_59.99v','com.managames.fairytown.iap_0.99g','com.managames.fairytown.iap_1.99g',
'com.managames.fairytown.iap_3.99g','com.managames.fairytown.iap_9.99g','com.managames.fairytown.iap_19.99g','com.managames.fairytown.iap_39.99g',
'com.managames.fairytown.iap_69.99g','com.managames.fairytown.iap_3.99e','com.managames.fairytown.iap_9.99m','com.managames.fairytown.iap_4.99sd',
'com.managames.fairytown.iap_4.99xn','com.managames.fairytown.iap_0.99hg1','com.managames.fairytown.iap_4.99hg2','com.managames.fairytown.iap_9.99hg3',
'com.managames.fairytown.iap_2.99hg4','com.managames.fairytown.iap_6.99hg5','com.managames.fairytown.iap_12.99hg6','com.managames.fairytown.iap_39.99hg7',
'com.managames.fairytown.iap_69.99hg8','com.managames.fairytown.iap_99.99hg9','com.managames.fairytown.iap_1.99rlb1','com.managames.fairytown.iap_1.99rlb2',
'com.managames.fairytown.iap_1.99rlb3','com.managames.fairytown.iap_9.99zlb','com.managames.fairytown.iap_9.99axh','com.managames.fairytown.iap_19.99fht',
'com.managames.fairytown.iap_9.99aqy','com.managames.fairytown.iap_9.99axm','com.managames.fairytown.iap_9.99aqn')
and role_id in (select distinct role_id from fairy_town.order_pay where day_time >= ${start_time} and day_time <= ${end_time})
and role_id in (select distinct role_id from fairy_town.server_role_create where server_id in (10001,10002,10003) and day_time >= ${start_time} and day_time <= ${end_time})
group by 1,2,3
)
union all
(select role_id,ad_position as change_method,log_time from fairy_town_server.server_ad_rewards -- 广告发奖的
where server_id in (10001,10002,10003) and day_time >= ${start_time} and day_time <= ${end_time}
and role_id in (select distinct role_id from fairy_town.order_pay where day_time >= ${start_time} and day_time <= ${end_time})
and role_id in (select distinct role_id from fairy_town.server_role_create where server_id in (10001,10002,10003) and day_time >= ${start_time} and day_time <= ${end_time})
group by 1,2,3
)
union all
(select role_id,
       case when recovery_count = 100 then '小蛋糕'
            when recovery_count = 250 then '中蛋糕'
            when recovery_count = 500 then '大蛋糕'
       end as change_method,
       log_time
from
(select role_id,recovery_count,log_time from fairy_town_server.server_physical_recovery
where server_id in (10001,10002,10003) and day_time >= ${start_time} and day_time <= ${end_time}
and recovery_method = '1'
and role_id in (select distinct role_id from fairy_town.order_pay where day_time >= ${start_time} and day_time <= ${end_time})
and role_id in (select distinct role_id from fairy_town.server_role_create where server_id in (10001,10002,10003) and day_time >= ${start_time} and day_time <= ${end_time})
group by 1,2,3) as s
group by 1,2,3
)

) as bb
) as aa 
where row_num = 1 
group by 1 order by 1 




新用户等级分布  根绝绝对游戏天数计算
select
    role_level,
    count(case when row_num = 1 then role_id else null end) '第1天',
    count(case when row_num = 2 then role_id else null end)  '第2天',
    count(case when row_num = 3 then role_id else null end)  '第3天',
    count(case when row_num = 4 then role_id else null end)  '第4天',
    count(case when row_num = 5 then role_id else null end)  '第5天',
    count(case when row_num = 6 then role_id else null end)  '第6天',
    count(case when row_num = 7 then role_id else null end)  '第7天',
    count(case when row_num = 8 then role_id else null end)  '第8天',
    count(case when row_num = 9 then role_id else null end)  '第9天',
    count(case when row_num = 10 then role_id else null end) '第10天',
    count(case when row_num = 11 then role_id else null end) '第11天',
    count(case when row_num = 12 then role_id else null end) '第12天',
    count(case when row_num = 13 then role_id else null end) '第13天',
    count(case when row_num = 14 then role_id else null end) '第14天',
    count(case when row_num = 15 then role_id else null end) '第15天',
    count(case when row_num = 16 then role_id else null end) '第16天',
    count(case when row_num = 17 then role_id else null end) '第17天',
    count(case when row_num = 18 then role_id else null end) '第18天',
    count(case when row_num = 19 then role_id else null end) '第19天',
    count(case when row_num = 20 then role_id else null end) '第20天',
    count(case when row_num = 21 then role_id else null end) '第21天',
    count(case when row_num = 22 then role_id else null end) '第22天',
    count(case when row_num = 23 then role_id else null end) '第23天',
    count(case when row_num = 24 then role_id else null end) '第24天',
    count(case when row_num = 25 then role_id else null end) '第25天',
    count(case when row_num = 26 then role_id else null end) '第26天',
    count(case when row_num = 27 then role_id else null end) '第27天',
    count(case when row_num = 28 then role_id else null end) '第28天',
    count(case when row_num = 29 then role_id else null end) '第29天',
    count(case when row_num = 30 then role_id else null end) '第30天'
from
    (select 
        role_id_a as role_id,
        role_level,
        row_num
    from
        (
        select 
            a.role_id as role_id_a,
            role_level,
            row_num
        from

            (select role_id,day_time
            from fairy_town.server_role_create 
            where server_id in (10001,10002,10003) and day_time >= 20211115 and day_time <= 20211215
            and role_id in (select distinct role_id from fairy_town.order_pay where day_time >= 20211115 and day_time <= 20220126)
            group by 1,2) as a

            left join 

            (
            select role_id,role_level,dense_rank() over(partition by role_id order by day_time asc) as row_num
            from
            (select role_id,day_time,max(role_level) as role_level
            from
            (
            (select role_id,role_level,day_time
            from fairy_town.server_role_login where server_id in (10001,10002,10003) 
            and role_id in (select distinct role_id from fairy_town.order_pay where day_time >= 20211115 and day_time <= 20220126)
            )
            union all 
            (select role_id,role_level,day_time
             from fairy_town.server_role_upgrade where server_id in (10001,10002,10003)
             and role_id in (select distinct role_id from fairy_town.order_pay where day_time >= 20211115 and day_time <= 20220126)
             ) 
            ) as aa
            group by 1,2
            ) as b
            ) as e

            on a.role_id = e.role_id
        ) as d
    group by 1,2,3
    ) as bb
group by 1
order by 1








付费玩家首次付费行为  根据绝对游戏天数计算

        select 
            a.role_id as role_id,
            game_product_id,
            b.row_num
        from
            
            (select role_id,day_time
            from fairy_town.server_role_create where 
            server_id in (10001,10002,10003) and day_time >= 20211204 and day_time <= 20211208
            and role_id in (select distinct role_id from fairy_town.order_pay where day_time >= 20211204 and day_time <= 20220126)
            group by 1,2) as a

            left join
            
            (select role_id,day_time,row_num
            from
            (select role_id,day_time,dense_rank() over(partition by role_id order by day_time asc) as row_num
             from fairy_town.server_role_login where server_id in (10001,10002,10003)
             and role_id in (select distinct role_id from fairy_town.order_pay where day_time >= 20211204 and day_time <= 20220126)) as aa
            group by 1,2,3
            ) as b
            on a.role_id = b.role_id

            left join

            (select day_time,role_id,game_product_id
            from
            (select role_id,game_product_id, day_time ,row_number() over(partition by role_id order by log_time asc) as row_num 
            from fairy_town.order_pay where server_id in (10001,10002,10003)
            ) as aa
            where row_num = 1
            group by 1,2,3) as c

            on b.role_id = c.role_id and b.day_time = c.day_time

        group by 1,2,3
        order by 3



SELECT cast(target_id as int) as '消耗途径ID',
case target_id
when '0' then 'unknown' 
when '1' then '商店购买' 
when '2' then '商店快买' 
when '3' then 'GM 命令' 
when '4' then '邮件附件' 
when '5' then '自然恢复体力' 
when '6' then '角色升级' 
when '7' then '客户端买体力' 
when '8' then '客户端填满体力' 
when '9' then '客户端快速买体力' 
when '10' then '云团解锁' 
when '11' then '购买建筑' 
when '12' then '收藏奖励' 
when '13' then '寻物装饰奖励' 
when '14' then '地图商人额外奖励' 
when '15' then '向商人出售限时物品' 
when '16' then '猫头鹰订单' 
when '17' then '地图宝箱' 
when '18' then '怪物宝箱' 
when '19' then '宝箱建筑' 
when '20' then '采矿任务' 
when '21' then '火车订单' 
when '22' then '码头订单' 
when '23' then '任务奖励' 
when '24' then '升级建筑' 
when '25' then '充值商城' 
when '26' then '宝石商城' 
when '27' then '工业生产2' 
when '28' then '工业生产1' 
when '29' then '持续生产建筑' 
when '30' then '市场' 
when '31' then '限时礼包' 
when '32' then '火车快速返回' 
when '33' then '收获牲畜' 
when '34' then '采矿' 
when '35' then '收获庄稼' 
when '36' then '收获养殖场' 
when '37' then '使用定点炸弹' 
when '38' then '出售物品' 
when '39' then '完成工业1生产' 
when '40' then '解锁人口建筑' 
when '41' then '出售地图上的物件' 
when '42' then '向商人出售普通物品' 
when '43' then '向商人出售限时物品' 
when '44' then '火车装箱' 
when '45' then '码头装箱' 
when '46' then '种庄稼' 
when '47' then '加速庄稼生长' 
when '48' then '加速工业1生产' 
when '49' then '扩充工业1队列' 
when '50' then '加速牲畜生产' 
when '51' then '购买商城物品' 
when '52' then '购买建筑到地图' 
when '53' then '购买牲畜到地图' 
when '54' then '移除人口建筑' 
when '55' then '使用炸弹' 
when '56' then '打猎' 
when '57' then '刷新市场' 
when '58' then '购买新的市场格子' 
when '59' then '市场商人搜索' 
when '60' then '购买市场商人物品' 
when '61' then '快速购买任务物品' 
when '62' then '刷新猫头鹰任务' 
when '63' then '解锁火车线路' 
when '64' then '码头订单刷新' 
when '65' then '加速工业2冷却'
when '66' then '礼物盒获得物品奖励'
when '67' then '支线任务'
when '68' then '储蓄罐'
when '69' then '从礼物盒取出建筑等放置奖励'
when '70' then '签到累积奖励'
when '71' then '每日签到奖励'
when '72' then '每日签到奖励广告'
when '73' then '定次钻石月卡'
when '74' then '定次体力月卡'
when '75' then '在线奖励'
when '76' then '任务与事件机制触发'
when '77' then '绑定Facebook'
when '78' then '调查问卷'
when '79' then '平台手动发奖'
when '80' then '活动结束兑换普通物品'
when '81' then '活动结束兑换堆礼物建筑'
when '82' then '旋转建筑消耗体力'
when '83' then 'CDKey兑换'
when '84' then '平台奖励（未知）'
when '85' then '建筑替换'
when '86' then '收取猎物宝箱'
when '87' then '成长基金'
when '88' then '战令等级普通奖励'
when '89' then '战令等级黄金奖励'
when '90' then '组排行'
when '91' then '全球排行'
when '92' then '刷新活动商店'
when '93' then '活动任务'
when '94' then '在活动商店购买'
when '95' then '限时建筑商店'
when '96' then  '商城广告'
when '97' then  '定时/家园宝箱广告'
when '98' then  '加速可持续生产建筑'
when '99' then  '好友送礼'
when '100' then  '邀请累计奖励'
when '101' then  '邀请单人奖励'
when '102' then  '资源礼盒商店'
when '103' then  '火车帮助装箱'
when '104' then  '码头帮助装箱'
when '105' then  '系统好友每日送礼'
when '106' then  '系统好友回馈送礼'
when '107' then  '订单积分奖励'
when '108' then  '丰收节积分奖励'
when '109' then  '工业大爆炸积分奖励'
when '110' then  '订单小组排名奖励'
when '111' then  '丰收节小组排名奖励'
when '112' then  '工业大爆炸小组排名奖励'
when '113' then  '订单全球排名奖励'
when '114' then  '丰收节全球排名奖励'
when '115' then  '工业大爆炸全球排名奖励'
when '116' then  '回流开启一次性奖励'
when '117' then  '回流任务奖励'
when '118' then  '回流累计积分奖励'
when '119' then  '回流签到奖励'
when '120' then  '回流礼包奖励'
end as '消耗途径',
sum(consume_count) as '消耗数量'
from
(select target_id,consume_count
FROM fairy_town_server.server_physical_consume
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})) as a
group by 1
order by 1


SELECT a.day_time as '日期', 采集消耗,转动消耗,打猎消耗,市场消耗
from

(SELECT day_time,sum(consume_count) as '采集消耗'
FROM fairy_town_server.server_physical_consume
WHERE server_id IN (10001,10002,10003) and day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
GROUP BY 1
ORDER BY 1) as a
left join
(SELECT day_time,sum(consume_count) as '转动消耗'
from fairy_town_server.server_stone_pillar_turn
where server_id IN (10001,10002,10003) and day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
GROUP BY 1
ORDER BY 1) as b
on a.day_time = b.day_time

left join
(SELECT day_time,sum(consume_physical_count) as '打猎消耗'
FROM fairy_town_server.server_hunt 
where server_id IN (10001,10002,10003) and day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
GROUP BY 1
ORDER BY 1) as c
on a.day_time = c.day_time

left join
(SELECT day_time,sum(consume_currency_count) as '市场消耗'
FROM fairy_town_server.server_market_buy 
where server_id IN (10001,10002,10003) and day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and consume_currency_id = '3'
GROUP BY 1
ORDER BY 1) as d
on a.day_time = d.day_time

group by 1
order by 1



select map_id as '地图ID',bomb_id as '炸弹ID',
case bomb_id
when '1' then '普通'
when '2' then '定点'
when '3' then '免费'
end as '炸弹类型',
case map_id
when '10001' then '梦想镇'
when '20001' then '睡美人1'
when '30001' then '睡美人2'
when '30002' then '睡美人2'
when '40001' then '睡美人3'
when '50001' then '睡美人支线'
when '50002' then '睡美人支线'
when '60001' then '美人鱼1'
when '70001' then '美人鱼2'
when '80001' then '美人鱼3'
when '90001' then '美人鱼4'
when '100001' then '美人鱼5'
when '110001' then '美人鱼支线'
when '120001' then '第三章1'
when '130001' then '第三章2'
when '140001' then '第三章3'
when '150001' then '第三章4'
when '160001' then '第三章4'
when '180001' then '第四章1'
when '190001' then '第四章2'
when '200001' then '第四章3'
when '210001' then '第四章4'
when '220001' then '第四章5'
when '30010001' then '飞鱼岛的宝藏'
when '30020001' then '雪人的故事'
when '31010001' then '怪物派对'
when '31020001' then '企鹅镇'
when '40010001' then '皇后迷宫-雪地1'
when '40020001' then '皇后迷宫-秋季草地1'
when '40030001' then '皇后迷宫-沙滩1'
when '40040001' then '皇后迷宫-森林1'
when '40050001' then '皇后迷宫-阴暗1'
when '40060001' then '皇后迷宫-森林2'
when '40070001' then '皇后迷宫-阴暗2'
when '40080001' then '皇后迷宫-雪地2'
when '40090001' then '皇后迷宫-沙滩1-固定'
when '40100001' then '皇后迷宫-森林2-固定'
when '40110001' then '皇后迷宫-阴暗2-固定'
when '40120001' then '皇后迷宫-雪地2-固定'
Else '暂不开启'
end as '地图名称',
count(bomb_id) as '炸弹消耗数量'
from
fairy_town_server.server_bomb_consume
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by 1
order by 1















select
    b.day_time_a as day_time,
    sum(recovery_count)
from
(
    select 
        role_id_b as role_id,
        day_time_a,-- first_day
        day_time_b,
        datediff(day_time_b,day_time_a) as by_day, -- 间隔
        recovery_count
    from
        (select 
            b.role_id as role_id_b,
            a.day_times as day_time_a,
            b.day_times as day_time_b,
            recovery_count
        from
            (
             select role_id,to_date(cast(date_time as timestamp)) as day_times, recovery_count
            from fairy_town_server.server_gold_recovery
            where server_id IN (10001,10002,10003)
            and recovery_method in ('4','5','6','13','14','15','17','19','20','22','23','27','28','29','67','71','72','75','77','78','80','83',
                       '88','90','91','93','94','97','101','108','111','116','117','118','119') group by 1,2,3
            ) b 
        right join 
            (SELECT role_id,to_date(cast(date_time as timestamp)) as day_times
            FROM fairy_town_server.server_gold_recovery
            WHERE server_id IN (10001,10002,10003)
            AND day_time >= 20220203 and day_time <= 20220209
            and recovery_method = '116' GROUP BY 1,2
            ) a
            on a.role_id = b.role_id
        ) as reu
    order by 1,3      
) as b
where by_day <= 6

group by 1
order by 1



******************************************************以新增为起点的 付费用户留存******************************************************
select
    b.day_time_a as day_time,
    sum(case when by_day = 0 then 1 else 0 end) '新增',
    sum(case when by_day = 1 then 1 else 0 end) day_2,
    sum(case when by_day = 2 then 1 else 0 end) day_3,
    sum(case when by_day = 3 then 1 else 0 end) day_4,
    sum(case when by_day = 4 then 1 else 0 end) day_5,
    sum(case when by_day = 5 then 1 else 0 end) day_6,
    sum(case when by_day = 6 then 1 else 0 end) day_7,
    sum(case when by_day = 13 then 1 else 0 end) day_14,
    sum(case when by_day = 29 then 1 else 0 end) day_30,
    sum(case when by_day = 44 then 1 else 0 end) day_45,
    sum(case when by_day = 59 then 1 else 0 end) day_60,
    sum(case when by_day = 89 then 1 else 0 end) day_90,
    sum(case when by_day = 119 then 1 else 0 end) day_120
from
(
    select 
        device_id_b as device_id,
        day_time_a,-- first_day
        day_time_b,
        datediff(day_time_b,day_time_a) as by_day -- 间隔
    from
        (select 
            b.device_id as device_id_b,
            a.day_times as day_time_a,
            b.day_times as day_time_b
        from
             (
             select 
                device_id,
                to_date(cast(date_time as timestamp)) as day_times 
             from fairy_town.device_launch
             where day_time >= ${start_time} and day_time <= ${endDate} and channel_id in (1000,2000)
             group by 
                device_id,
                day_times
            ) b 
        right join 
            (select a.device_id as device_id,day_times
            from
                (select 
                device_id,
                to_date(cast(date_time as timestamp)) as day_times,
                day_time
            from 
                fairy_town.device_activate
            where day_time >= ${start_time} and day_time <= ${endDate} and channel_id in (1000,2000)
            group by 1,2,3) as a
                join 
                (select device_id,day_time from fairy_town.order_pay
                 where day_time >= ${start_time} and day_time <= ${endDate}
                 and server_id in (10001,10002,10003)
                 group by 1,2 ) as b
                on a.device_id = b.device_id and a.day_time = b.day_time
            ) a
            on a.device_id = b.device_id
        ) as reu
    order by device_id_b,day_time_b      
) as b

group by 1
order by 1


******************************************************以付费为起点的 付费用户留存******************************************************
select
    b.day_time_a as day_time,
    sum(case when by_day = 0 then 1 else 0 end) '首次付费',
    sum(case when by_day = 1 then 1 else 0 end) day_2,
    sum(case when by_day = 2 then 1 else 0 end) day_3,
    sum(case when by_day = 3 then 1 else 0 end) day_4,
    sum(case when by_day = 4 then 1 else 0 end) day_5,
    sum(case when by_day = 5 then 1 else 0 end) day_6,
    sum(case when by_day = 6 then 1 else 0 end) day_7,
    sum(case when by_day = 13 then 1 else 0 end) day_14,
    sum(case when by_day = 29 then 1 else 0 end) day_30,
    sum(case when by_day = 44 then 1 else 0 end) day_45,
    sum(case when by_day = 59 then 1 else 0 end) day_60,
    sum(case when by_day = 89 then 1 else 0 end) day_90,
    sum(case when by_day = 119 then 1 else 0 end) day_120
from
(
    select 
        device_id_b as device_id,
        day_time_a,-- first_day
        day_time_b,
        datediff(day_time_b,day_time_a) as by_day -- 间隔
    from
        (select 
            b.device_id as device_id_b,
            a.day_times as day_time_a,
            b.day_times as day_time_b
        from
             (
             select 
                device_id,
                to_date(cast(date_time as timestamp)) as day_times 
             from fairy_town.device_launch
             where day_time >= ${start_time} and day_time <= ${endDate} and channel_id in (1000,2000)
             group by 
                device_id,
                day_times
            ) b 
        right join 
            (select device_id,day_times
                from
                (select device_id,to_date(cast(date_time as timestamp)) as day_times,row_number() over(partition by device_id order by log_time) as row_num
                from fairy_town.order_pay 
                where day_time >= ${start_time} and day_time <= ${endDate} and server_id in (10001,10002,10003) 
                and device_id in (select distinct device_id from fairy_town.device_activate
                                  where day_time >= ${start_time} and day_time <= ${endDate} and channel_id in (1000,2000))
                ) as aaa where row_num = 1 group by 1,2

            ) a
            on a.device_id = b.device_id
        ) as reu
    order by device_id_b,day_time_b      
) as b

group by 1
order by 1






按天回收 计算ROAS
select
    a.dates_a as dates,
    round(sum(if(datediff(dates_b,dates_a)=0, pay_price_2, 0)),2) as day1,
    round(sum(if(datediff(dates_b,dates_a)<=1, pay_price_2, 0)),2) as day2,
    round(sum(if(datediff(dates_b,dates_a)<=2, pay_price_2, 0)),2) as day3,
    round(sum(if(datediff(dates_b,dates_a)<=3, pay_price_2, 0)),2) as day4,
    round(sum(if(datediff(dates_b,dates_a)<=4, pay_price_2, 0)),2) as day5,
    round(sum(if(datediff(dates_b,dates_a)<=5, pay_price_2, 0)),2) as day6,
    round(sum(if(datediff(dates_b,dates_a)<=6, pay_price_2, 0)),2) as day7,
    round(sum(if(datediff(dates_b,dates_a)<=7, pay_price_2, 0)),2) as day8,
    round(sum(if(datediff(dates_b,dates_a)<=8, pay_price_2, 0)),2) as day9,
    round(sum(if(datediff(dates_b,dates_a)<=9, pay_price_2, 0)),2) as day10,
    round(sum(if(datediff(dates_b,dates_a)<=10, pay_price_2, 0)),2)  as day11,
    round(sum(if(datediff(dates_b,dates_a)<=11, pay_price_2, 0)),2)  as day12,
    round(sum(if(datediff(dates_b,dates_a)<=12, pay_price_2, 0)),2)  as day13,
    round(sum(if(datediff(dates_b,dates_a)<=13, pay_price_2, 0)),2)  as day14,
    round(sum(if(datediff(dates_b,dates_a)<=14, pay_price_2, 0)),2)  as day15,
    round(sum(if(datediff(dates_b,dates_a)<=29, pay_price_2, 0)),2)  as day30,
    round(sum(if(datediff(dates_b,dates_a)<=44, pay_price_2, 0)),2)  as day45,
    round(sum(if(datediff(dates_b,dates_a)<=59, pay_price_2, 0)),2)  as day60,
    round(sum(if(datediff(dates_b,dates_a)<=89, pay_price_2, 0)),2)  as day90,
    round(sum(if(datediff(dates_b,dates_a)<=119, pay_price_2, 0)),2)  as day120
from
    (
    select
        op1.device_id as device_id,
        op1.dates as dates_a,
        op2.dates as dates_b,
        op2.pay_price as pay_price_2,
        datediff(op2.dates,op1.dates) as p
    from
        (select
            device_id,
            to_date(cast(date_time as timestamp)) as dates
         from
            fairy_town.device_activate
        where day_time >= 20210916 and day_time <= ${endDate} and country not in  ('CN','HK') and channel_id in (1000,2000)
        ) as op1 ,

        (select
            device_id,
            sum(pay_price) as pay_price,
            to_date(cast(date_time as timestamp)) as dates
         from
            fairy_town.order_pay
         where
            day_time >= 20210916 and day_time <= ${endDate} and server_id in (10001,10002,10003)
         group by device_id,dates
         ) as op2 
    where op1.device_id = op2.device_id and op2.dates >= op1.dates
    ) as a  
 
group by 1
order by 1




select game_product_id,product_name,count(role_id) as '数量',sum(pay_price) as '金额' from fairy_town.order_pay
where day_time >= 20210916 and day_time <= ${end_time}
and server_id in (10001,10002,10003)
group by 1,2
order by 4


完成皇后迷宫地图1  但是没完成1000008
select count(distinct a.role_id )
from
(select role_id from fairy_town_server.server_task_completed where day_time >= 20220303 and task_id = '1000010') as a
join
(SELECT role_id FROM fairy_town_server.server_task_accept 
WHERE task_id = '1000008' and day_time >= 20220303 and role_id NOT IN (SELECT role_id from fairy_town_server.server_task_completed where task_id = '1000008' and day_time >= 20220303)) as b
on a.role_id = b.role_id 




领取奖励节点4  但是没完成1000008
select count(distinct a.role_id )
from
(select role_id from
(select role_id,day_time, change_count from fairy_town.server_prop where day_time >= 20220303 and prop_id = '300202' and change_type = 'PRODUCE') as a  
where change_count = 3) as a
join
(SELECT role_id FROM fairy_town_server.server_task_accept 
WHERE task_id = '1000008' and role_id NOT IN (SELECT role_id from fairy_town_server.server_task_completed where task_id = '1000008')) as b
on a.role_id = b.role_id 



