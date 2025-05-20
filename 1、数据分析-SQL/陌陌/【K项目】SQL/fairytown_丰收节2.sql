

时间 2022年5月13日12点至18日5点
1652414400000    1652821200000

参与率 (√)
SELECT count(DISTINCT role_id)
FROM fairy_town_server.server_activity_triggered
WHERE server_id IN (10001,10002,10003)
AND activity_id = 28

弹窗没完活动
SELECT role_level,count(DISTINCT role_id)
from
(
SELECT role_id,role_level
from
(
SELECT role_id,role_level,row_number() over(PARTITION BY role_id ORDER BY log_time asc) as num
FROM fairy_town_server.server_activity_triggered
WHERE server_id IN (10001,10002,10003)
AND activity_id = 28
and role_id NOT IN
(
select distinct role_id
from fairy_town.server_prop
where day_time>=20220513 and day_time<=20220518
and server_id in (10001,10002,10003)
and prop_id='340001'
and change_type='PRODUCE'
)
) as a
where num = 1
GROUP BY 1,2 ORDER BY 2
) as a
GROUP BY 1 ORDER BY 1




日参与率 (√)
select day_time,count(distinct role_id)
from fairy_town.server_prop
where day_time>=20220513 and day_time<=20220518
and server_id in (10001,10002,10003)
and prop_id='340001'
and change_type='PRODUCE'
group by 1 order by 1


select day_time,count(distinct role_id) from 
(select day_time,role_id,sum(nums)over(partition by role_id)  as total_nums
from 
(select day_time,role_id,sum(change_count) as nums
from fairy_town.server_prop
where day_time>=20220513 and day_time<=20220518
and server_id in (10001,10002,10003)
and prop_id='340001'
and change_type='PRODUCE'
group by 1,2) a 
) a 
where total_nums>=20
group by 1 order by 1


10级以上活跃 (√)


select  day_time,count(distinct role_id) as activers
from 
(select day_time,role_id
from fairy_town.server_role_login
where day_time>=20220513 and day_time<=20220518
and log_time>=1652414400000  and  log_time<=1652821200000
and server_id in (10001,10002,10003)
and role_level>=10
union
select day_time,role_id
from fairy_town.server_prop
where day_time>=20220513 and day_time<=20220518
and server_id in (10001,10002,10003)
and prop_id='340001'
and change_type='PRODUCE'
group by 1,2
)  a 
group by 1 order by 1



总参与率 (√)

select  count(distinct role_id)
from fairy_town.server_prop
where day_time>=20220513 and day_time<=20220518
and server_id in (10001,10002,10003)
and prop_id='340001'
and change_type='PRODUCE'


总活跃 (√)
select  count(distinct role_id) as activers
from 
(select role_id
from fairy_town.server_role_login
where day_time>=20220513 and day_time<=20220518
and log_time>=1652414400000  and  log_time<=1652821200000
and server_id in (10001,10002,10003)
and role_level>=10
union
select role_id
from fairy_town.server_prop
where day_time>=20220513 and day_time<=20220518
and server_id in (10001,10002,10003)
and prop_id='340001'
and change_type='PRODUCE'
group by 1
)  a 



礼包
SELECT 
    day_time,
    game_product_id,
    count(game_product_id) as `购买数量`,
    sum(pay_price) as `流水`
FROM 
    fairy_town.order_pay
where game_product_id in ('com.managames.fairytown.iap_3.99nydh1','com.managames.fairytown.iap_9.99nydh2','com.managames.fairytown.iap_19.99nydh3')
and server_id in (10001,10002,10003) and day_time >= 20220513 and day_time >= 20220518
GROUP BY 1,2
ORDER BY 1,2





积分区间
=IF(C2>=12000,5,IF(C2>=6000,4,IF(C2>=2000,3,IF(C2>=600,2,IF(C2>=20,1,0)))))


宽表 (√)

select a.role_id,day_time,nums,b.pay as '当期收入',otherpay,c.pay as '上期收入'
from 
(select role_id,sum(change_count) as nums 
from fairy_town.server_prop
where day_time>=20220513 and day_time<=20220518
and server_id in (10001,10002,10003)
and prop_id='340001'
and change_type='PRODUCE'
group by 1) a 
left join 
(select day_time,role_id
from fairy_town.server_role_create
where day_time>=20220513 and day_time<=20220518
and server_id in (10001,10002,10003)
group by 1,2
) e 
on a.role_id=e.role_id
left join 
(select role_id,
sum(pay_price) as pay,
sum(case when product_name<>'战令' then pay_price else 0 end ) as otherpay
from fairy_town.order_pay
where day_time>=20220513 and day_time<=20220518
and server_id in (10001,10002,10003)
and log_time>=1652414400000  and  log_time<=1652821200000
group by 1
) b 
on a.role_id=b.role_id
left join 
(select role_id,
sum(pay_price) as pay
from fairy_town.order_pay
where day_time>=20220506 and day_time<=20220511   -- 5.6 12：00 - 5.11 5：00
and server_id in (10001,10002,10003)
and log_time>=1651809600000  and  log_time<=1652216400000
group by 1
) c 
on a.role_id=c.role_id
group by 1,2,3,4,5,6



台湾服 (√)
select a.role_id,day_time,nums,b.pay as '当期收入',otherpay,c.pay as '上期收入'
from 
(select role_id,sum(change_count) as nums 
from fairy_town_tw.server_prop
where day_time>=20220513 and day_time<=20220518
and server_id in (10001,10002,10003)
and prop_id='340001'
and change_type='PRODUCE'
group by 1) a 
left join 
(select day_time,role_id
from fairy_town_tw.server_role_create
where day_time>=20220513 and day_time<=20220518
and server_id in (10001,10002,10003)
group by 1,2
) e 
on a.role_id=e.role_id
left join 
(select role_id,
sum(pay_price) as pay,
sum(case when product_name<>'战令' then pay_price else 0 end ) as otherpay
from fairy_town_tw.order_pay
where day_time>=20220513 and day_time<=20220518
and server_id in (10001,10002,10003)
and log_time>=1652414400000  and  log_time<=1652821200000
group by 1
) b 
on a.role_id=b.role_id
left join 
(select role_id,
sum(pay_price) as pay
from fairy_town_tw.order_pay
where day_time>=20220506 and day_time<=20220511   -- 5.6 12：00 - 5.11 5：00
and server_id in (10001,10002,10003)
and log_time>=1651809600000  and  log_time<=1652216400000
group by 1
) c 
on a.role_id=c.role_id
group by 1,2,3,4,5,6


新用户往期收入 (√)
select count(distinct role_id),sum(pay_price) as pay
from fairy_town.order_pay
where day_time>=20220506 and day_time<=20220511
and server_id in (10001,10002,10003)
and log_time>=1651809600000  and  log_time<=1652216400000
and role_id in (select role_id
from fairy_town.server_role_create
where day_time>=20220506 and day_time<=20220511
and server_id in (10001,10002,10003))



实际领取人数(√)

select recovery_count,count(distinct role_id)
from fairy_town_server.server_gem_recovery
where  day_time>=20220513 and day_time<=20220518
and server_id in (10001,10002,10003)
and recovery_count in (2,3,4,5)
and recovery_method='108'
group by 1

select count(distinct role_id)
from fairy_town_server.server_building_get
where day_time>=20220513 and day_time<=20220518
and server_id in (10001,10002,10003)
and building_id = '200017'



瞬时化肥道具使用情况 (√)
select day_time,count(distinct t.role_id) as users,sum(nums) as nums 
from  
(select a.role_id from 
(select role_id
from fairy_town.server_role_login
where day_time>=20220506 and day_time<=20220511
and server_id in (10001,10002,10003)
and role_level>=10 
union 
select role_id
from fairy_town.server_role_upgrade
where day_time>=20220506 and day_time<=20220511
and server_id in (10001,10002,10003)
and role_level=10 
) a 
join 
(select role_id
from fairy_town.server_role_login
where day_time>=20220513 and day_time<=20220518
and server_id in (10001,10002,10003)
and role_level>=10 
union 
select role_id
from fairy_town.server_role_upgrade
where day_time>=20220513 and day_time<=20220518
and server_id in (10001,10002,10003)
and role_level=10 
) b 
on a.role_id=b.role_id
) t 
join 
(select day_time,role_id,sum(change_count) as nums 
from fairy_town.server_prop
where day_time>=20220506 and day_time<=20220518
and server_id in (10001,10002,10003)
and prop_id='127019'
and change_type='CONSUME'
group by 1,2) l 
on t.role_id=l.role_id
group by 1


 
瞬时化肥整体消耗 (√)
SELECT day_time,sum(change_count) FROM fairy_town.server_prop
where day_time>=20220506 and day_time<=20220518
and server_id in (10001,10002,10003)
and prop_id='127019'
and change_type='CONSUME'
GROUP BY 1 ORDER BY 1


钻石消耗 (√)
select day_time,count(distinct t.role_id) as users,sum(nums) as nums 
from  
(select a.role_id from 
(select role_id
from fairy_town.server_role_login
where day_time>=20220506 and day_time<=20220511
and server_id in (10001,10002,10003)
and role_level>=10 
union 
select role_id
from fairy_town.server_role_upgrade
where day_time>=20220506 and day_time<=20220511
and server_id in (10001,10002,10003)
and role_level=10 
) a 
join 
(select role_id
from fairy_town.server_role_login
where day_time>=20220513 and day_time<=20220518
and server_id in (10001,10002,10003)
and role_level>=10 
union 
select role_id
from fairy_town.server_role_upgrade
where day_time>=20220513 and day_time<=20220518
and server_id in (10001,10002,10003)
and role_level=10 
) b 
on a.role_id=b.role_id
) t 
join 
(select day_time,role_id,sum(consume_count) as nums 
from fairy_town_server.server_gem_consume
where day_time>=20220506 and day_time<=20220518
and server_id in (10001,10002,10003)
and consume_method='47'
group by 1,2) l 
on t.role_id=l.role_id
group by 1


钻石整体用户消耗 (√)
SELECT day_time,sum(consume_count) FROM fairy_town_server.server_gem_consume
where day_time>=20220506 and day_time<=20220518
and server_id in (10001,10002,10003)
and consume_method = '47'
GROUP BY 1 ORDER BY 1



货币存量 整体用户 (√)

select day_time,count(distinct role_id),
avg(gold) as avg_gold,appx_median(gold) as median_gold,
avg(gem) as gem ,appx_median(gem) as median_gem 
from
(
select day_time,role_id,gold,gem
from fairy_town_server.server_login_snap_shot
where day_time>=20220506 and day_time<=20220518
and server_id in (10001,10002,10003)
and role_level>=10
group by 1,2,3,4

union all

select day_time,role_id,gold,gem
from fairy_town_server_tw.server_login_snap_shot
where day_time>=20220113 and day_time<=20220125
and server_id in (10001,10002,10003)
and role_level>=10
group by 1,2,3,4
) as a
group by 1 order by 1


货币存量  历史付费用户 (√)
select day_time,count(distinct role_id),
avg(gold) as avg_gold,appx_median(gold) as median_gold,
avg(gem) as gem ,appx_median(gem) as median_gem 
from
(
select day_time,role_id,gold,gem
from fairy_town_server.server_login_snap_shot
where day_time>=20220506 and day_time<=20220518
and server_id in (10001,10002,10003)
and role_level>=10
and role_id in (select role_id 
from fairy_town.order_pay
where day_time>=20210420 and day_time<=20220518
and server_id in (10001,10002,10003))
group by 1,2,3,4

union all

select day_time,role_id,gold,gem
from fairy_town_server_tw.server_login_snap_shot
where day_time>=20220506 and day_time<=20220518
and server_id in (10001,10002,10003)
and role_level>=10
and role_id in (select role_id 
from fairy_town_tw.order_pay
where day_time>=20210420 and day_time<=20220518
and server_id in (10001,10002,10003))
group by 1,2,3,4
) as a
group by 1 order by 1




全球留存 (√)
select channel_id,media_source,level_dt,role_level,datediff(login_dt,level_dt) as datediffs,count(distinct c.role_id)
from
(select channel_id,role_id,
     case when media_source is null then 'Organic'
         else media_source end as media_source,
         role_level,level_dt
 from 
(select channel_id,role_id,device_id,role_level,to_date(cast(date_time as timestamp)) as level_dt
from fairy_town.server_role_upgrade
where day_time>=20220428 and day_time<=20220518
and server_id in (10001,10002,10003)
and role_level in (10,11,12,13,14,15) 
group by 1,2,3,4,5
) a 
left outer join 
(select customer_user_id,  --设备ID
case when media_source in ('Facebook Ads','restricted') then 'FB'
     when media_source = 'googleadwords_int'            then 'GG'
     when media_source = 'applovin_int'                 then 'Applovin'
     when media_source = 'ironsource_int'               then 'IronSource'
     else  'others'
     end  as media_source                                        
from fairy_town.af_push
group by 1,2) b
on device_id=customer_user_id
) c 
left join 
(select role_id,to_date(cast(date_time as timestamp)) as login_dt
from fairy_town.server_role_login
where day_time>=20220428  and day_time<=20220519
and server_id in (10001,10002,10003)
group by 1,2
) d 
on c.role_id=d.role_id and login_dt>=level_dt
where datediff(login_dt,level_dt) <=1
group by 1,2,3,4,5

 
台湾服留存 (√)
select channel_id,media_source,level_dt,role_level,datediff(login_dt,level_dt) as datediffs,count(distinct c.role_id)
from
(select channel_id,role_id,
     case when media_source is null then 'Organic'
         else media_source end as media_source,
         role_level,level_dt
 from 
(select channel_id,role_id,device_id,role_level,to_date(cast(date_time as timestamp)) as level_dt
from fairy_town_tw.server_role_upgrade
where day_time>=20220428 and day_time<=20220518
and server_id in (10001,10002,10003)
and role_level in (10,11,12,13,14,15) 
group by 1,2,3,4,5
) a 
left outer join 
(select customer_user_id,  --设备ID
case when media_source in ('Facebook Ads','restricted') then 'FB'
     when media_source = 'googleadwords_int'            then 'GG'
     when media_source = 'applovin_int'                 then 'Applovin'
     when media_source = 'ironsource_int'               then 'IronSource'
     else  'others'
     end  as media_source                                        
from fairy_town_tw.af_push
group by 1,2) b
on device_id=customer_user_id
) c 
left join 
(select role_id,to_date(cast(date_time as timestamp)) as login_dt
from fairy_town_tw.server_role_login
where day_time>=20220428  and day_time<=20220519
and server_id in (10001,10002,10003)
group by 1,2
) d 
on c.role_id=d.role_id and login_dt>=level_dt
where datediff(login_dt,level_dt) <=1
group by 1,2,3,4,5



*******************************************************************************






新增对应周期内收入


select count(distinct role_id),sum(pay_price) as pay
from fairy_town.order_pay
where day_time>=20220113 and day_time<=20220118
and server_id in (10001,10002,10003)
and log_time>=1642046400000  and  log_time<=1642446000000
and role_id in (select day_time,role_id
from fairy_town.server_role_create
where day_time>=20220113 and day_time<=20220118
and server_id in (10001,10002,10003))



新增用户的等级分布
select role_level,count(distinct role_id)
from 
(select role_id,max(role_level) as role_level
from fairy_town.server_role_upgrade
where  day_time>=20220113 and day_time<=20220118
and server_id in (10001,10002,10003)
and role_id in (select role_id from 
fairy_town.server_role_create where  day_time>=20220113 and day_time<=20220118
and server_id in (10001,10002,10003))
group by 1) a 
group by 1

 



登录次数  ****************************************(√) 
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
        fairy_town.server_role_login
    where 
        day_time >= 20220513 and day_time <= 20220518
        and server_id IN (10001,10002,10003)
        and role_id in
        (select distinct role_id
                    from fairy_town.server_prop
                    where day_time>=20220513 and day_time<=20220518
                    and server_id in (10001,10002,10003)
                    and prop_id='340001'
                    and change_type='PRODUCE')
    group by 1,2

    union all

    select
        day_time,
        role_id,
        count(role_id) as cishu
    from
        fairy_town_tw.server_role_login
    where 
        day_time >= 20220513 and day_time <= 20220518
        and server_id IN (10001,10002,10003)
        and role_id in
        (select distinct role_id
                    from fairy_town_tw.server_prop
                    where day_time>=20220513 and day_time<=20220518
                    and server_id in (10001,10002,10003)
                    and prop_id='340001'
                    and change_type='PRODUCE')
    group by 1,2

    ) a
group by day_time
order by day_time



在线时长  ****************************************(√) 
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
        fairy_town.client_online
    where 
        day_time >= 20220513 and day_time <= 20220518
        and server_id IN (10001,10002,10003)
        and role_id in
        (select distinct role_id
                    from fairy_town.server_prop
                    where day_time>=20220513 and day_time<=20220518
                    and server_id in (10001,10002,10003)
                    and prop_id='340001'
                    and change_type='PRODUCE')
    group by 1,2

    union all 

    SELECT
        role_id,
        day_time,
        count(ping) as num
    from 
        fairy_town_tw.client_online
    where 
        day_time >= 20220513 and day_time <= 20220518
        and server_id IN (10001,10002,10003)
        and role_id in
        (select distinct role_id
                    from fairy_town_tw.server_prop
                    where day_time>=20220513 and day_time<=20220518
                    and server_id in (10001,10002,10003)
                    and prop_id='340001'
                    and change_type='PRODUCE')
    group by 1,2
) a
group by day_time
order by day_time