# 活动弹窗 相当于接取任务人数
SELECT count(DISTINCT role_id)
FROM fairy_town_server.server_activity_triggered
WHERE server_id IN (10001,10002,10003)
AND activity_id = 14

# 至少参与过一次活动的人数
SELECT count(DISTINCT role_id)
FROM fairy_town_server.server_activity_triggered
WHERE server_id IN (10001,10002,10003)
AND activity_id = 14
and role_id in (select distinct role_id from fairy_town_server.server_physical_consume where
                server_id in (10001,10002,10003) and consume_count > 0
                and map_id in ('30010001','40010001','40020001','40030001','40040001','40050001','40060001',
                    '40070001','40080001','40090001','40100001','40110001','40120001','31010001','30020001','31020001'))





# 进入地图人数
select
    count(distinct role_id)
from 
    fairy_town_server.server_map_enter
where map_id = '31030001' and server_id in (10001,10002,10003)




# 活动参与率 日参与率
SELECT
    a.birth_dt as day_dt
    ,a.num as `日参与人数`
    ,b.num as `日可参与人数`
    ,a.num / b.num as `日参与率`
FROM
    (SELECT 
        to_date(cast(date_time as timestamp)) as birth_dt,
        count(distinct role_id) as num
    FROM 
        fairy_town_server.server_physical_consume 
    where map_id = '31030001' and consume_count > 0 and server_id in (10001,10002,10003)
    GROUP BY birth_dt
    ORDER BY birth_dt) as a,
    
    (SELECT 
        to_date(cast(date_time as timestamp)) as birth_dt,
        count(distinct role_id) as num
    FROM
        (
             (
             SELECT 
                 role_id,
                 date_time
             FROM 
                 fairy_town_server.server_physical_consume 
             where map_id = '31030001' and consume_count > 0 and server_id in (10001,10002,10003)
             )   
         union all
             (
             SELECT
                 role_id,
                 date_time
             from 
                 fairy_town.server_role_login
             WHERE role_level >= 10 and server_id in (10001,10002,10003) and log_time >= 1645243200000 and log_time <= 1645556400000
             )
        ) c
    group by 1
    ) as b
where a.birth_dt = b.birth_dt
order by day_dt



活动体力总消耗
SELECT day_time,sum(consume_count) from fairy_town_server.server_physical_consume
where map_id = '31030001' and server_id in (10001,10002,10003) and role_level >= 10
and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1645556400000)
GROUP BY 1 ORDER BY 1

免费体力获得
SELECT day_time,sum(recovery_count) from fairy_town_server.server_physical_recovery
where log_time >= 1645243200000 and log_time <= 1645556400000
and server_id in (10001,10002,10003) and role_level >= 10 --and map_id = '31030001'
and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume where map_id = '31030001' and server_id in (10001,10002,10003))
and recovery_method in ('4','5','6','13','14','15','17','19','20','22','23','27','28','29','67','71','72','75','77','78','80','83','88','90','91','93',
                        '94','97','101','108','111','116','118','119')
and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1645556400000)
group by 1 order by 1

历史付费参与活动角色数量
SELECT count(DISTINCT role_id) from fairy_town_server.server_physical_consume
where map_id = '31030001' and server_id in (10001,10002,10003) and role_level >= 10
and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1645556400000)
 

体力净值消耗区间分布
SELECT
     count(case when consume_count_sum < 0 then role_id else null end) as '<0'
    ,count(case when consume_count_sum >=0 and consume_count_sum < 500 then role_id else null end) as '0-499'
    ,count(case when consume_count_sum >=500 and consume_count_sum < 1000 then role_id else null end) as '500-999'
    ,count(case when consume_count_sum >=1000 and consume_count_sum < 2000 then role_id else null end) as '1000-1999'
    ,count(case when consume_count_sum >=2000 and consume_count_sum < 4000 then role_id else null end) as '2000-3999'
    ,count(case when consume_count_sum >=4000 and consume_count_sum < 6000 then role_id else null end) as '4000-5999'
    ,count(case when consume_count_sum >=6000 and consume_count_sum < 8000 then role_id else null end) as '6000-7999'
    ,count(case when consume_count_sum >=8000 and consume_count_sum < 10000 then role_id else null end) as '8000-9999'
    ,count(case when consume_count_sum >=10000 and consume_count_sum < 12000 then role_id else null end) as '10000-11999'
    ,count(case when consume_count_sum >=12000 and consume_count_sum < 14000 then role_id else null end) as '12000-13999'
    ,count(case when consume_count_sum >=14000 and consume_count_sum < 16000 then role_id else null end) as '14000-15999'
    ,count(case when consume_count_sum >=16000 and consume_count_sum < 18000 then role_id else null end) as '16000-17999'
    ,count(case when consume_count_sum >=18000 and consume_count_sum < 20000 then role_id else null end) as '18000-19999'
    ,count(case when consume_count_sum >=20000 and consume_count_sum < 22000 then role_id else null end) as '20000-21999'
    ,count(case when consume_count_sum >=22000 and consume_count_sum < 24000 then role_id else null end) as '22000-23999'
    ,count(case when consume_count_sum >=24000 and consume_count_sum < 26000 then role_id else null end) as '24000-25999'
    ,count(case when consume_count_sum >=26000 and consume_count_sum < 28000 then role_id else null end) as '26000-27999'
    ,count(case when consume_count_sum >=28000 and consume_count_sum < 30000 then role_id else null end) as '28000-29999'
    ,count(case when consume_count_sum >=30000 and consume_count_sum < 32000 then role_id else null end) as '30000-31999'
    ,count(case when consume_count_sum >=32000 and consume_count_sum < 36000 then role_id else null end) as '32000-35999'
from
    (
        select role_id,net_value as consume_count_sum
        from
        (select a.role_id as role_id,(consume_count - recovery_count) as net_value
        from
        -- 活动消耗
        (SELECT role_id,sum(consume_count) as consume_count from fairy_town_server.server_physical_consume
        where map_id = '31030001' and server_id in (10001,10002,10003) and role_level >= 10
        and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1645556400000)
        GROUP BY 1 ORDER BY 1) as a
        left join
        -- 免费体力获得
        (SELECT role_id,sum(recovery_count) as recovery_count from fairy_town_server.server_physical_recovery
        where log_time >= 1645243200000 and log_time <= 1645556400000
        and server_id in (10001,10002,10003) and role_level >= 10
        and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume where map_id = '31030001' and server_id in (10001,10002,10003))
        and recovery_method in ('4','5','6','13','14','15','17','19','20','22','23','27','28','29','67','71','72','75','77','78','80','83','88','90','91','93',
                                '94','97','101','108','111','116','118','119')
        and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1645556400000)
        group by 1 order by 1) as b
        on a.role_id = b.role_id
        ) as aa
        where role_id in (SELECT DISTINCT a.role_id from
                            (SELECT role_id FROM fairy_town_server.server_task_completed
                            where server_id IN (10001,10002,10003) and log_time >= 1645243200000 and task_id = '3103191') as a 
                            join 
                            (SELECT role_id FROM fairy_town_server.server_task_completed
                            where server_id IN (10001,10002,10003) and log_time >= 1645243200000 and task_id = '3103192') as b
                            on a.role_id = b.role_id)
) bb



活动钻石总消耗
SELECT day_time,sum(consume_count) from fairy_town_server.server_gem_consume
where map_id = '31030001' and server_id in (10001,10002,10003) and role_level >= 10
and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1645556400000)
GROUP BY 1 ORDER BY 1

免费钻石获得
SELECT day_time,sum(recovery_count) from fairy_town_server.server_gem_recovery
where log_time >= 1645243200000 and log_time <= 1645556400000 and map_id = '31030001'
and server_id in (10001,10002,10003) and role_level >= 10
and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume where map_id = '31030001' and server_id in (10001,10002,10003))
and recovery_method in ('4','5','6','13','14','15','17','19','20','22','23','27','28','29','67','71','72','75','77','78','80','83','88','90','91','93',
                        '94','97','101','108','111','116','118','119')
and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1645556400000)
group by 1 order by 1




通关用户 (√) ****************************************
SELECT count(DISTINCT a.role_id)
from
(SELECT role_id FROM fairy_town_server.server_task_completed
where server_id IN (10001,10002,10003) and log_time >= 1645243200000 and task_id = '3103191') as a 
join 
(SELECT role_id FROM fairy_town_server.server_task_completed
where server_id IN (10001,10002,10003) and log_time >= 1645243200000 and task_id = '3103192') as b
on a.role_id = b.role_id



-- 任务   (√)   1645243200000   1645556400000
积分任务  ****************************************
SELECT
    a.task_id as task_id,
    a.task_group_id_num as '接取角色数',
    b.task_group_id_num as '完成角色数',
    b.task_group_id_num / a.task_group_id_num as '任务完成率'
FROM
    (SELECT
        task_id as task_id,
        count(distinct role_id) as task_group_id_num
    FROM fairy_town_server.server_task_accept
    WHERE server_id IN (10001,10002,10003)
      and log_time >= 1645243200000
      AND task_group_id IN ('1002001','1002002','1002003','1002004','1002005','1002006','1002007','1002008','1002009','1002010','1002011','1002012','1002014','1002015','1002016','1002017')
      and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume 
          where map_id = '31030001' and server_id in (10001,10002,10003) and log_time >= 1645243200000)
    group by 1
    ) a
left join
    (SELECT
        task_id as task_id,
        count(distinct role_id) as task_group_id_num
    FROM fairy_town_server.server_task_completed
    WHERE server_id IN (10001,10002,10003)
      and log_time >= 1645243200000
      AND task_group_id IN ('1002001','1002002','1002003','1002004','1002005','1002006','1002007','1002008','1002009','1002010','1002011','1002012','1002014','1002015','1002016','1002017')
      and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume 
          where map_id = '31030001' and server_id in (10001,10002,10003) and log_time >= 1645243200000)
    group by 1
    ) b
on a.task_id = b.task_id
order by  1




任务  ****************************************
SELECT
    a.task_id as task_id,
    a.task_group_id_num as '接取角色数',
    b.task_group_id_num as '完成角色数',
    b.task_group_id_num / a.task_group_id_num as '任务完成率'
FROM
    (SELECT
        task_id as task_id,
        count(distinct role_id) as task_group_id_num
    FROM fairy_town_server.server_task_accept
    WHERE server_id IN (10001,10002,10003)
      and log_time >= 1645243200000
      AND task_group_id IN ('310301','310302','310303','310304','310305','310306','310307','310308','310309','310310','310311','310312','310313','310314','310315','310316','310317','310318','310319')
      and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume 
          where map_id = '31030001' and server_id in (10001,10002,10003) and log_time >= 1645243200000)
    group by 1
    ) a
left join
    (SELECT
        task_id as task_id,
        count(distinct role_id) as task_group_id_num
    FROM fairy_town_server.server_task_completed
    WHERE server_id IN (10001,10002,10003)
      and log_time >= 1645243200000
      AND task_group_id IN ('310301','310302','310303','310304','310305','310306','310307','310308','310309','310310','310311','310312','310313','310314','310315','310316','310317','310318','310319')
      and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume 
          where map_id = '31030001' and server_id in (10001,10002,10003) and log_time >= 1645243200000)
    group by 1
    ) b
on a.task_id = b.task_id
order by  1






活动奖励领取情况   (√) ****************************************
SELECT 
    building_id,
    count(distinct role_id) as num
FROM 
    fairy_town_server.server_building_get
WHERE building_id in ('4006040','4006041') 
      and server_id in (10001,10002,10003)
      and log_time >= 1645243200000
GROUP BY 1
order by 1

获得建筑去重的用户数  分母
SELECT count(DISTINCT role_id)
from fairy_town_server.server_building_get
WHERE building_id in ('4006040','4006041') 
      and server_id in (10001,10002,10003)
      and log_time >= 1645243200000 


活动评价数据   (√) ****************************************
SELECT 
    role_id,
    scores
FROM fairy_town_server.server_event_rate
where role_id in (select distinct role_id from fairy_town_server.server_physical_consume 
                  where map_id = '31030001' and server_id in (10001,10002,10003) and day_time >= 20220219 and day_time <= 20220223)
      and activity_id = 14
group by 1,2


活动礼包购买行为  (√)  ****************************************
SELECT 
    day_time,
    game_product_id,
    count(game_product_id) as `购买数量`,
    sum(pay_price) as `流水`
FROM 
    fairy_town.order_pay
where game_product_id in ('com.managames.fairytown.iap_3.99ve','com.managames.fairytown.iap_9.99ve','com.managames.fairytown.iap_19.99ve')
and server_id in (10001,10002,10003) and day_time >= 20220219 and day_time <= 20220223
GROUP BY 1,2
ORDER BY 1,2




# 活动收入
—————————————————————————————— 参与 ——————————————————————————————
********************************************************************************

活跃人数
新用户
SELECT count(DISTINCT role_id) FROM fairy_town_server.server_activity_triggered WHERE server_id IN (10001,10002,10003) AND activity_id = 14
AND log_time >= 1645243200000 and log_time <= 1645556400000
AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time >= 1645243200000 and log_time <= 1645556400000) 
and role_id in (select distinct role_id from fairy_town_server.server_physical_consume where map_id = '31030001' and consume_count>0 
                  and server_id in (10001,10002,10003))

老用户
SELECT count(DISTINCT role_id) FROM fairy_town_server.server_activity_triggered WHERE server_id IN (10001,10002,10003) AND activity_id = 14
AND log_time >= 1645243200000 and log_time <= 1645556400000
AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time < 1645243200000)
and role_id in (select distinct role_id from fairy_town_server.server_physical_consume where map_id = '31030001' and consume_count>0 
                  and server_id in (10001,10002,10003))




当期充值人数
新用户
SELECT count(DISTINCT role_id)
FROM fairy_town.order_pay
WHERE server_id IN (10001,10002,10003)
  AND log_time >= 1645243200000 and log_time <= 1645556400000
  AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time >= 1645243200000 and log_time <= 1645556400000)
  and role_id in (SELECT DISTINCT role_id FROM fairy_town_server.server_activity_triggered WHERE server_id IN (10001,10002,10003) AND activity_id = 14 AND log_time >= 1645243200000)
  and role_id in (select distinct role_id from fairy_town_server.server_physical_consume where map_id = '31030001' and consume_count>0 
                  and server_id in (10001,10002,10003))
  and product_name <> '战令'


老用户
SELECT count(DISTINCT role_id)
FROM fairy_town.order_pay
WHERE server_id IN (10001,10002,10003)
  AND log_time >= 1645243200000 and log_time <= 1645556400000
  AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time < 1645243200000)
  and role_id in (SELECT DISTINCT role_id FROM fairy_town_server.server_activity_triggered WHERE server_id IN (10001,10002,10003) AND activity_id = 14 AND log_time >= 1645243200000)
  and role_id in (select distinct role_id from fairy_town_server.server_physical_consume where map_id = '31030001' and consume_count>0 
                  and server_id in (10001,10002,10003))
  and product_name <> '战令'





当期充值金额
新用户
SELECT sum(pay_price)
    FROM fairy_town.order_pay
WHERE server_id IN (10001,10002,10003)
  AND log_time >= 1645243200000 and log_time <= 1645556400000
  AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time >= 1645243200000 and log_time <= 1645556400000)
  and role_id in (SELECT DISTINCT role_id FROM fairy_town_server.server_activity_triggered WHERE server_id IN (10001,10002,10003) AND activity_id = 14 AND log_time >= 1645243200000)
  and role_id in (select distinct role_id from fairy_town_server.server_physical_consume where map_id = '31030001' and consume_count>0 
                  and server_id in (10001,10002,10003))
  and product_name <> '战令'


老用户
SELECT sum(pay_price)
    FROM fairy_town.order_pay
WHERE server_id IN (10001,10002,10003)
  AND log_time >= 1645243200000 and log_time <= 1645556400000
  AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time < 1645243200000)
  and role_id in (SELECT DISTINCT role_id FROM fairy_town_server.server_activity_triggered WHERE server_id IN (10001,10002,10003) AND activity_id = 14 AND log_time >= 1645243200000)
  and role_id in (select distinct role_id from fairy_town_server.server_physical_consume where map_id = '31030001' and consume_count>0 
                  and server_id in (10001,10002,10003))
  and product_name <> '战令'






登录次数  ****************************************
select 
    day_time,
    count(distinct role_id),
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
        day_time >= 20220214 and day_time <= 20220223
        and server_id IN (10001,10002,10003)
        and role_id in
        (SELECT
            distinct role_id
         FROM fairy_town_server.server_physical_consume 
         where map_id = '31030001' and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1645243200000)
    group by 1,2
    ) a
group by day_time
order by day_time



在线时长  ****************************************
select
    day_time,
    count(distinct role_id) as role_num,
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
        day_time >= 20220214 and day_time <= 20220223
        and server_id IN (10001,10002,10003)
        and role_id in
        (SELECT
            distinct role_id
         FROM fairy_town_server.server_physical_consume 
         where map_id = '31030001' and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1645243200000
        )
    group by 1,2
) a
group by day_time
order by day_time




整体次留
SELECT role_level,count(distinct device_id)
from
(SELECT aa.device_id as device_id,role_level
from
(SELECT device_id
from fairy_town.device_launch
where channel_id IN (1000,2000) and day_time = ${days_time}
) as aa
join
(select device_id,role_level
from
(select device_id,role_level from fairy_town_server.server_physical_consume 
where map_id = '31030001' and consume_count>0 and server_id in (10001,10002,10003)
and channel_id = 1000) as a
left join
(select customer_user_id,af_channel
from fairy_town.af_push
where af_channel is NULL
group by 1,2) as b
on a.device_id = b.customer_user_id) as bb
on aa.device_id = bb.device_id
) as c group by 1 order by 1



留存
当周数据&过去一周数据
select channel_id,media_source,level_dt,role_level,datediff(login_dt,level_dt) as datediffs,count(distinct c.role_id)
from
(select channel_id,role_id,
 case when media_source is null then 'Organic'
         else media_source end as media_source,
         role_level,level_dt
 from 
(select channel_id,role_id,device_id,role_level,to_date(cast(date_time as timestamp)) as level_dt
from fairy_town.server_role_upgrade
where day_time>=20220214 and day_time<=20220223
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
where day_time>=20220214 and day_time<=20220224
and server_id in (10001,10002,10003)
group by 1,2
) d 
on c.role_id=d.role_id and login_dt>=level_dt
where datediff(login_dt,level_dt) <=1
group by 1,2,3,4,5



存量分析

SELECT day_time,avg(physical) as physical_avg,appx_median(physical) as physical_appx,
                avg(gold) as gold_avg,appx_median(gold) as gold_appx,
                avg(gem) as gem_avg,appx_median(gem) as gem_appx,
                avg(bomb) as bomb_avg,appx_median(bomb) as bomb_appx 
                from fairy_town_server.server_login_snap_shot 
where day_time >= ${start_time} and day_time <= ${end_time}
and server_id in (10001,10002,10003)
and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume 
                where map_id = '31030001' and consume_count > 0 and server_id in (10001,10002,10003))
group by 1
order by 1



弹窗没进地图的玩家在线时长  历史付费用户
SELECT day_dt,count(distinct role_id) as '在线人数', avg(zxsc) as '平均在线时长',appx_median(zxsc) as '在线时长中位数'
from

(SELECT a.role_id as role_id,b.day_time as day_dt,zxsc
from

(SELECT role_id
FROM fairy_town_server.server_activity_triggered
WHERE server_id IN (10001,10002,10003)
AND activity_id = 14 and role_level >= 10
and role_id not in (select distinct role_id from fairy_town_server.server_map_enter
                    where map_id = '31030001' and server_id in (10001,10002,10003))
and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1645556400000)) as a

left join
(select role_id,day_time,count(ping) as zxsc
from fairy_town.client_online 
where day_time >= ${start_time} and day_time <= ${end_time}
and server_id IN (10001,10002,10003) group by 1,2) as b  
on a.role_id = b.role_id
group by 1,2,3
order by 2,1) as aa  
group by 1 order by 1



SELECT day_dt,count(distinct role_id) as '登录人数',avg(dlcs) as '平均登录次数',appx_median(dlcs) as '登录次数中位数'
from

(SELECT a.role_id as role_id,c.day_time as day_dt,dlcs
from
(SELECT role_id
FROM fairy_town_server.server_activity_triggered
WHERE server_id IN (10001,10002,10003)
AND activity_id = 14 and role_level >= 10
and role_id not in (select distinct role_id from fairy_town_server.server_map_enter
                    where map_id = '31030001' and server_id in (10001,10002,10003))
and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1645556400000)) as a
left join
(select role_id,day_time,max(cast(dlcs as int)) as dlcs
from
(select role_id,day_time,count(role_id) as dlcs
from fairy_town.server_role_login
where day_time >= ${start_time} and day_time <= ${end_time}
and server_id IN (10001,10002,10003) group by 1,2) as aa group by 1,2) as c   

on a.role_id = c.role_id
group by 1,2,3
order by 2,1) as bb   
group by 1 order by 1




