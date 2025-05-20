--1646280000000  1646938800000

# 活动弹窗 相当于接取任务人数
SELECT count(DISTINCT role_id)
FROM fairy_town_server.server_activity_triggered
WHERE server_id IN (10001,10002,10003)
AND activity_id = 15


-- # 至少参与过一次活动的人数
-- SELECT count(DISTINCT role_id)
-- FROM fairy_town_server.server_activity_triggered
-- WHERE server_id IN (10001,10002,10003)
-- AND activity_id = 15
-- and role_id in (select distinct role_id from fairy_town_server.server_physical_consume 
--                 where server_id in (10001,10002,10003) and consume_count > 0
--                 and log_time < 1646280000000
--                 and map_id in ('40010001','40020001','40030001','40040001','40050001','40060001',
--                                '40070001','40080001','40090001','40100001','40110001','40120001',
--                                '31010001','30010001','30020001','31020001','31030001'))


历史付费参与活动角色数量
SELECT count(DISTINCT role_id) from fairy_town_server.server_physical_consume
where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001') 
and server_id in (10001,10002,10003) and role_level >= 10 and log_time >= 1646280000000
and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1646938800000)



进入地图人数
select
    count(distinct role_id)
from 
    fairy_town_server.server_map_enter
where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001') 
and server_id in (10001,10002,10003) and log_time >= 1646280000000

体力消耗
SELECT 
    count(distinct role_id) as num
FROM 
    fairy_town_server.server_physical_consume 
where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001') 
and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1646280000000



活动参与率 日参与率
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
    where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001') 
    and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1646280000000
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
             where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001') 
             and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1646280000000
             )   
         union all
             (
             SELECT
                 role_id,
                 date_time
             from 
                 fairy_town.server_role_login    
             WHERE role_level >= 10 and server_id in (10001,10002,10003) and log_time >= 1646280000000 and log_time <= 1646938800000
             )
        ) c
    group by 1
    ) as b
where a.birth_dt = b.birth_dt
order by day_dt

地图分布情况  安老师算



活动体力总消耗
SELECT day_time,sum(physical_consume)
from
(SELECT day_time,consume_count as physical_consume from fairy_town_server.server_physical_consume   -- 采集
where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001')
and server_id in (10001,10002,10003) and role_level >= 10 and log_time >= 1646280000000
and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1646938800000)

union all 

SELECT day_time,consume_physical_count as physical_consume from fairy_town_server.server_hunt       -- 打猎
where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001')
and server_id in (10001,10002,10003) and role_level >= 10 and log_time >= 1646280000000
and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1646938800000)
) a
group by 1
order by 1


免费体力获得
SELECT day_time,sum(recovery_count) from fairy_town_server.server_physical_recovery
where log_time >= 1646280000000 and log_time <= 1646938800000
and server_id in (10001,10002,10003) and role_level >= 10 
--and map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001') 
and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001',
                                                                                                        '40030001','40040001','40050001','40060001','40070001','40080001') 
                and server_id in (10001,10002,10003) and log_time >= 1646280000000)
and recovery_method in ('4','5','6','13','14','15','17','19','20','22','23','27','28','29','67','71','72','75','77','78','80','83','88','90','91','93',
                        '94','97','101','108','111','116','118','119')
and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1646938800000)
group by 1 order by 1

 


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
        (SELECT role_id,sum(physical_consume) as consume_count
        from
        (SELECT role_id,consume_count as physical_consume from fairy_town_server.server_physical_consume
        where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001')
        and server_id in (10001,10002,10003) and role_level >= 10 and log_time >= 1646280000000
        and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1646938800000)
        
        union all 

        SELECT role_id,consume_physical_count as physical_consume from fairy_town_server.server_hunt
        where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001')
        and server_id in (10001,10002,10003) and role_level >= 10 and log_time >= 1646280000000
        and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1646938800000)
        ) as a
        group by 1
        order by 1) as a
        left join
        -- 免费体力获得
        (SELECT role_id,sum(recovery_count) as recovery_count from fairy_town_server.server_physical_recovery
        where log_time >= 1646280000000 and log_time <= 1646938800000
        and server_id in (10001,10002,10003) and role_level >= 10
        and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001',
                                                                                                                '40030001','40040001','40050001','40060001','40070001','40080001')
                        and server_id in (10001,10002,10003) and log_time >= 1646280000000)
        and recovery_method in ('4','5','6','13','14','15','17','19','20','22','23','27','28','29','67','71','72','75',
                                '77','78','80','83','88','90','91','93','94','97','101','108','111','116','118','119')
        and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1646938800000)
        group by 1 order by 1) as b
        on a.role_id = b.role_id
        ) as aa
        where role_id in (SELECT DISTINCT role_id FROM fairy_town_server.server_task_completed   -- 通关
                          where server_id IN (10001,10002,10003) and log_time >= 1646280000000 and task_id = '1000017')
) bb




活动钻石总消耗
SELECT day_time,sum(consume_count) from fairy_town_server.server_gem_consume
where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001')
and server_id in (10001,10002,10003) and role_level >= 10
and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1646938800000)
GROUP BY 1 ORDER BY 1

免费钻石获得
SELECT day_time,sum(recovery_count) from fairy_town_server.server_gem_recovery
where log_time >= 1646280000000 and log_time <= 1646938800000 
--and map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001')
and server_id in (10001,10002,10003) and role_level >= 10
and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001')
and server_id in (10001,10002,10003))
and recovery_method in ('4','5','6','13','14','15','17','19','20','22','23','27','28','29','67','71','72','75','77','78','80','83','88','90','91','93',
                        '94','97','101','108','111','116','118','119')
and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1646938800000)
group by 1 order by 1




通关用户 (√) ****************************************
SELECT count(DISTINCT a.role_id)
from
(SELECT role_id FROM fairy_town_server.server_task_completed
where server_id IN (10001,10002,10003) and log_time >= 1646280000000 and task_id = '1000017') as a 




-- 任务   (√) 
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
      and log_time >= 1646280000000
      AND task_group_id IN ('1000008','1000009','1000010','1000011','1000012','1000013','1000014','1000015','1000016','1000017')
      and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume 
          where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001') 
          and server_id in (10001,10002,10003) and log_time >= 1646280000000)
    group by 1
    ) a
left join
    (SELECT
        task_id as task_id,
        count(distinct role_id) as task_group_id_num
    FROM fairy_town_server.server_task_completed
    WHERE server_id IN (10001,10002,10003)
      and log_time >= 1646280000000
      AND task_group_id IN ('1000008','1000009','1000010','1000011','1000012','1000013','1000014','1000015','1000016','1000017')
      and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume 
          where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001') 
          and server_id in (10001,10002,10003) and log_time >= 1646280000000)
    group by 1
    ) b
on a.task_id = b.task_id
order by  1



活动奖励领取情况   (√) ****************************************

装饰+可持续生产  放置人数
SELECT 装饰物,count(distinct role_id)
from
(SELECT
    role_id,
    case when building_id in ('4001036','4001040') then '金钻石奖杯'
         when building_id in ('4001037','4001041') then '银钻石奖杯'
         when building_id in ('4001038','4001042') then '铜钻石奖杯'
         when building_id in ('4001039','4001043') then '木钻石奖杯'
         when building_id in ('4001034','4001035') then '鲁道夫'
    end as '装饰物'
from 
(SELECT 
    building_id,
    role_id
FROM 
    fairy_town_server.server_building_get
WHERE building_id in ('4001036','4001037','4001038','4001039','4001040','4001041','4001042','4001043','4001034','4001035') 
      and server_id in (10001,10002,10003)
      and log_time >= 1646280000000
) as aa
) as bb
group by 1



活动评价数据   (√) ****************************************
SELECT 
    role_id,
    scores
FROM fairy_town_server.server_event_rate
where role_id in (select distinct role_id from fairy_town_server.server_physical_consume 
                  where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001') 
                  and server_id in (10001,10002,10003) and day_time >= 20220303 and day_time <= 20220311)
      and activity_id = 15
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
and server_id in (10001,10002,10003) and day_time >= 20220303 and day_time <= 20220311
GROUP BY 1,2
ORDER BY 1,2



# 活动收入
—————————————————————————————— 参与 ——————————————————————————————
********************************************************************************

活跃人数
新用户
SELECT count(DISTINCT role_id) FROM fairy_town_server.server_activity_triggered WHERE server_id IN (10001,10002,10003) AND activity_id = 15
AND log_time >= 1646280000000 and log_time <= 1646938800000
AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time >= 1646280000000 and log_time <= 1646938800000) 
and role_id in (select distinct role_id from fairy_town_server.server_physical_consume 
                where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001')
                and consume_count>0 and server_id in (10001,10002,10003) and log_time >= 1646280000000)

老用户
SELECT count(DISTINCT role_id) FROM fairy_town_server.server_activity_triggered WHERE server_id IN (10001,10002,10003) AND activity_id = 15
AND log_time >= 1646280000000 and log_time <= 1646938800000
AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time < 1646280000000)
and role_id in (select distinct role_id from fairy_town_server.server_physical_consume 
                where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001')
                and consume_count>0 and server_id in (10001,10002,10003) and log_time >= 1646280000000)




当期充值人数
新用户
SELECT count(DISTINCT role_id)
FROM fairy_town.order_pay
WHERE server_id IN (10001,10002,10003)
  AND log_time >= 1646280000000 and log_time <= 1646938800000
  AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time >= 1646280000000 and log_time <= 1646938800000)
  and role_id in (SELECT DISTINCT role_id FROM fairy_town_server.server_activity_triggered WHERE server_id IN (10001,10002,10003) AND activity_id = 15 AND log_time >= 1646280000000)
  and role_id in (select distinct role_id from fairy_town_server.server_physical_consume 
                  where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001') 
                  and consume_count>0 and server_id in (10001,10002,10003) and log_time >= 1646280000000)
  and product_name <> '战令'


老用户
SELECT count(DISTINCT role_id)
FROM fairy_town.order_pay
WHERE server_id IN (10001,10002,10003)
  AND log_time >= 1646280000000 and log_time <= 1646938800000
  AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time < 1646280000000)
  and role_id in (SELECT DISTINCT role_id FROM fairy_town_server.server_activity_triggered WHERE server_id IN (10001,10002,10003) AND activity_id = 15 AND log_time >= 1646280000000)
  and role_id in (select distinct role_id from fairy_town_server.server_physical_consume 
                  where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001') 
                  and consume_count>0 and server_id in (10001,10002,10003) and log_time >= 1646280000000)
  and product_name <> '战令'





当期充值金额
新用户
SELECT sum(pay_price)
    FROM fairy_town.order_pay
WHERE server_id IN (10001,10002,10003)
  AND log_time >= 1646280000000 and log_time <= 1646938800000
  AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time >= 1646280000000 and log_time <= 1646938800000)
  and role_id in (SELECT DISTINCT role_id FROM fairy_town_server.server_activity_triggered WHERE server_id IN (10001,10002,10003) AND activity_id = 15 AND log_time >= 1646280000000)
  and role_id in (select distinct role_id from fairy_town_server.server_physical_consume 
                  where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001') 
                  and consume_count>0 and server_id in (10001,10002,10003) and log_time >= 1646280000000)
  and product_name <> '战令'


老用户
SELECT sum(pay_price)
    FROM fairy_town.order_pay
WHERE server_id IN (10001,10002,10003)
  AND log_time >= 1646280000000 and log_time <= 1646938800000
  AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time < 1646280000000)
  and role_id in (SELECT DISTINCT role_id FROM fairy_town_server.server_activity_triggered WHERE server_id IN (10001,10002,10003) AND activity_id = 15 AND log_time >= 1646280000000)
  and role_id in (select distinct role_id from fairy_town_server.server_physical_consume 
                  where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001') 
                  and consume_count>0 and server_id in (10001,10002,10003) and log_time >= 1646280000000)
  and product_name <> '战令'





登陆次数  ****************************************
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
        day_time >= 20220224 and day_time <= 20220309
        and server_id IN (10001,10002,10003)
        and role_id in
        (SELECT
            distinct role_id
         FROM fairy_town_server.server_physical_consume 
         where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001') 
         and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1646280000000)
    group by 1,2
    ) a
group by day_time
order by day_time



在线时长  ****************************************
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
        day_time >= 20220224 and day_time <= 20220309
        and server_id IN (10001,10002,10003)
        and role_id in
        (SELECT
            distinct role_id
         FROM fairy_town_server.server_physical_consume 
         where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001') 
         and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1646280000000
        )
    group by 1,2
) a
group by day_time
order by day_time




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
where day_time>=20220224 and day_time<=20220309
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
where day_time>=20220224 and day_time<=20220310
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
                where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001') 
                and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1646280000000)
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
AND activity_id = 15 and role_level >= 10
and role_id not in (select distinct role_id from fairy_town_server.server_map_enter
                    where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001') 
                    and server_id in (10001,10002,10003) and log_time >= 1646280000000)
and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1646938800000)) as a

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
AND activity_id = 15 and role_level >= 10
and role_id not in (select distinct role_id from fairy_town_server.server_map_enter
                    where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001') 
                    and server_id in (10001,10002,10003) and log_time >= 1646280000000)
and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1646938800000)) as a
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




排行榜
SELECT a.role_id,change_sum as '积分数量',activity_group_id as '小组',physical_sum as '活动体力总消耗', 
recovery_count as '免费体力获得',(physical_sum - recovery_count) as '体力净消耗',country as '注册国家',paysum as '历史总付费',pay_2 as '当期付费'   
from

(SELECT role_id,country, sum(change_count) as change_sum from fairy_town.server_prop 
where prop_id = '300203' and change_type = 'PRODUCE' and day_time >= 20220303 and day_time <= 20220311 group by 1,2) as a
left join
(SELECT role_id,activity_group_id from fairy_town_server.server_activity_group WHERE activity_id = 15 GROUP BY 1,2) as b
on a.role_id = b.role_id
left join
(SELECT role_id,sum(physical_consume) as physical_sum   -- 活动体力总消耗
from
(SELECT role_id,consume_count as physical_consume from fairy_town_server.server_physical_consume   -- 采集
where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001')
and server_id in (10001,10002,10003) and role_level >= 10 and log_time >= 1646280000000

union all 

SELECT role_id,consume_physical_count as physical_consume from fairy_town_server.server_hunt       -- 打猎
where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001')
and server_id in (10001,10002,10003) and role_level >= 10 and log_time >= 1646280000000
) a
group by 1
order by 1) as c
on a.role_id = c.role_id
left join
(SELECT role_id,sum(recovery_count) as recovery_count  from fairy_town_server.server_physical_recovery
where log_time >= 1646280000000 and log_time <= 1646938800000
and server_id in (10001,10002,10003) and role_level >= 10  
and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume 
                where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001')
                and server_id in (10001,10002,10003) and log_time >= 1646280000000)
and recovery_method in ('4','5','6','13','14','15','17','19','20','22','23','27','28','29','67','71','72','75','77','78','80','83','88','90','91','93',
                        '94','97','101','108','111','116','118','119')

group by 1 order by 1) as d
on a.role_id = d.role_id
left join 
(select role_id,sum(pay_price) as paysum from fairy_town.order_pay where log_time <=1646938800000  group by 1) as f 
on a.role_id = f.role_id
left join 
(select role_id,sum(pay_price) as pay_2 from fairy_town.order_pay where day_time >= ${d1} and day_time <= ${d2} group by 1) as g 
on a.role_id = g.role_id

GROUP BY 1,2,3,4,5,6,7,8,9

