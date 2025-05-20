2022.5.13 12:00    2022.5.24 5:00
1652414400000      1653339600000

# 活动弹窗 相当于接取任务人数
SELECT count(DISTINCT role_id)
FROM fairy_town_server.server_activity_triggered
WHERE server_id IN (10001,10002,10003)
AND activity_id = 27



历史付费参与活动角色数量
SELECT count(DISTINCT role_id) from fairy_town_server.server_physical_consume
where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001') 
and server_id in (10001,10002,10003) and role_level >= 10 and log_time >= 1652414400000
and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1653339600000)



进入地图人数
select
    count(distinct role_id)
from 
    fairy_town_server.server_map_enter
where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001') 
and server_id in (10001,10002,10003) and log_time >= 1652414400000

体力消耗
SELECT 
    count(distinct role_id) as num
FROM 
    fairy_town_server.server_physical_consume 
where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001') 
and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1652414400000



老用户参与情况

select count(DISTINCT role_id) from fairy_town_server.server_physical_consume 
where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001')
and consume_count>0 and server_id in (10001,10002,10003) and log_time >= 1652414400000
AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time < 1652414400000)


and role_id not in (select distinct role_id from fairy_town_server.server_physical_consume 
                where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001')
                and consume_count>0 and server_id in (10001,10002,10003) and day_time >= 20211125 and day_time <= 20211203)

and role_id not in (select distinct role_id from fairy_town_server.server_physical_consume 
                where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001')
                and consume_count>0 and server_id in (10001,10002,10003) and day_time >= 20220303 and day_time <= 20220311)



SELECT sum(pay_price)
    FROM fairy_town.order_pay
WHERE server_id IN (10001,10002,10003)
  AND log_time >= 1652414400000 and log_time <= 1653339600000
  AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time < 1652414400000)
  and role_id in (SELECT DISTINCT role_id FROM fairy_town_server.server_activity_triggered WHERE server_id IN (10001,10002,10003) AND activity_id = 27 AND log_time >= 1652414400000)
  and role_id in (select distinct role_id from fairy_town_server.server_physical_consume 
                  where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001') 
                  and consume_count>0 and server_id in (10001,10002,10003) and log_time >= 1652414400000)
  and product_name <> '战令'

and role_id not in (select distinct role_id from fairy_town_server.server_physical_consume 
                where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001')
                and consume_count>0 and server_id in (10001,10002,10003) and day_time >= 20211125 and day_time <= 20211203)

and role_id not in (select distinct role_id from fairy_town_server.server_physical_consume 
                where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001')
                and consume_count>0 and server_id in (10001,10002,10003) and day_time >= 20220303 and day_time <= 20220311)









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
    and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1652414400000
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
             and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1652414400000
             )   
         union all
             (
             SELECT
                 role_id,
                 date_time
             from 
                 fairy_town.server_role_login    
             WHERE role_level >= 10 and server_id in (10001,10002,10003) and log_time >= 1652414400000 and log_time <= 1653339600000
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
and server_id in (10001,10002,10003) and role_level >= 10 and log_time >= 1652414400000
and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1653339600000)

union all 

SELECT day_time,consume_physical_count as physical_consume from fairy_town_server.server_hunt       -- 打猎
where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001')
and server_id in (10001,10002,10003) and role_level >= 10 and log_time >= 1652414400000
and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1653339600000)
) a
group by 1
order by 1




免费体力获得
SELECT day_time,sum(recovery_count) from fairy_town_server.server_physical_recovery
where log_time >= 1652414400000 and log_time <= 1653339600000
and server_id in (10001,10002,10003) and role_level >= 10 
--and map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001') 
and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001',
                                                                                                        '40030001','40040001','40050001','40060001','40070001','40080001') 
                and server_id in (10001,10002,10003) and log_time >= 1652414400000)
and recovery_method in ('4','5','6','13','14','15','17','19','20','22','23','27','28','29','67','71','72','75','77','78','80','83','88','90','91','93',
                        '94','97','101','108','111','116','118','119')
and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1653339600000)
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
        and server_id in (10001,10002,10003) and role_level >= 10 and log_time >= 1652414400000
        and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1653339600000)
        
        union all 

        SELECT role_id,consume_physical_count as physical_consume from fairy_town_server.server_hunt
        where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001')
        and server_id in (10001,10002,10003) and role_level >= 10 and log_time >= 1652414400000
        and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1653339600000)
        ) as a
        group by 1
        order by 1) as a
        left join
        -- 免费体力获得
        (SELECT role_id,sum(recovery_count) as recovery_count from fairy_town_server.server_physical_recovery
        where log_time >= 1652414400000 and log_time <= 1653339600000
        and server_id in (10001,10002,10003) and role_level >= 10
        and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001',
                                                                                                                '40030001','40040001','40050001','40060001','40070001','40080001')
                        and server_id in (10001,10002,10003) and log_time >= 1652414400000)
        and recovery_method in ('4','5','6','13','14','15','17','19','20','22','23','27','28','29','67','71','72','75',
                                '77','78','80','83','88','90','91','93','94','97','101','108','111','116','118','119')
        and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1653339600000)
        group by 1 order by 1) as b
        on a.role_id = b.role_id
        ) as aa
        where role_id in (SELECT DISTINCT role_id FROM fairy_town_server.server_task_completed   -- 通关
                          where server_id IN (10001,10002,10003) and log_time >= 1652414400000 and task_group_id = '1000027')
) bb




通关用户 (√) ****************************************
SELECT count(DISTINCT a.role_id)
from
(SELECT role_id FROM fairy_town_server.server_task_completed
where server_id IN (10001,10002,10003) and log_time >= 1652414400000 and task_id = '1000027') as a 




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
      and log_time >= 1652414400000
      AND task_group_id IN ('1000018','1000019','1000020','1000021','1000022','1000023','1000024','1000025','1000026','1000027')
      and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume 
          where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001') 
          and server_id in (10001,10002,10003) and log_time >= 1652414400000)
    group by 1
    ) a
left join
    (SELECT
        task_id as task_id,
        count(distinct role_id) as task_group_id_num
    FROM fairy_town_server.server_task_completed
    WHERE server_id IN (10001,10002,10003)
      and log_time >= 1652414400000
      AND task_group_id IN ('1000018','1000019','1000020','1000021','1000022','1000023','1000024','1000025','1000026','1000027')
      and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume 
          where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001') 
          and server_id in (10001,10002,10003) and log_time >= 1652414400000)
    group by 1
    ) b
on a.task_id = b.task_id
order by  1



活动礼包购买行为  (√)  ****************************************
SELECT 
    day_time,
    game_product_id,
    count(game_product_id) as `购买数量`,
    sum(pay_price) as `流水`
FROM 
    fairy_town.order_pay
where game_product_id in ('com.managames.fairytown.iap_3.99ve','com.managames.fairytown.iap_9.99ve','com.managames.fairytown.iap_19.99ve',
                          'com.managames.fairytown.iap_4.99vb','com.managames.fairytown.iap_9.99vb','com.managames.fairytown.iap_19.99vb')
and server_id in (10001,10002,10003) and day_time >= 20220513 and day_time >= 20220524
GROUP BY 1,2
ORDER BY 1,2



# 活动收入
—————————————————————————————— 参与 ——————————————————————————————
********************************************************************************

活跃人数
新用户
SELECT count(DISTINCT role_id) FROM fairy_town_server.server_activity_triggered WHERE server_id IN (10001,10002,10003) AND activity_id = 27
AND log_time >= 1652414400000 and log_time <= 1653339600000
AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time >= 1652414400000 and log_time <= 1653339600000) 
and role_id in (select distinct role_id from fairy_town_server.server_physical_consume 
                where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001')
                and consume_count>0 and server_id in (10001,10002,10003) and log_time >= 1652414400000)

老用户
SELECT count(DISTINCT role_id) FROM fairy_town_server.server_activity_triggered WHERE server_id IN (10001,10002,10003) AND activity_id = 27
AND log_time >= 1652414400000 and log_time <= 1653339600000
AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time < 1652414400000)
and role_id in (select distinct role_id from fairy_town_server.server_physical_consume 
                where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001')
                and consume_count>0 and server_id in (10001,10002,10003) and log_time >= 1652414400000)



当期充值人数
新用户
SELECT count(DISTINCT role_id)
FROM fairy_town.order_pay
WHERE server_id IN (10001,10002,10003)
  AND log_time >= 1652414400000 and log_time <= 1653339600000
  AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time >= 1652414400000 and log_time <= 1653339600000)
  and role_id in (SELECT DISTINCT role_id FROM fairy_town_server.server_activity_triggered WHERE server_id IN (10001,10002,10003) AND activity_id = 27 AND log_time >= 1652414400000)
  and role_id in (select distinct role_id from fairy_town_server.server_physical_consume 
                  where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001') 
                  and consume_count>0 and server_id in (10001,10002,10003) and log_time >= 1652414400000)
  and product_name <> '战令'


老用户
SELECT count(DISTINCT role_id)
FROM fairy_town.order_pay
WHERE server_id IN (10001,10002,10003)
  AND log_time >= 1652414400000 and log_time <= 1653339600000
  AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time < 1652414400000)
  and role_id in (SELECT DISTINCT role_id FROM fairy_town_server.server_activity_triggered WHERE server_id IN (10001,10002,10003) AND activity_id = 27 AND log_time >= 1652414400000)
  and role_id in (select distinct role_id from fairy_town_server.server_physical_consume 
                  where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001') 
                  and consume_count>0 and server_id in (10001,10002,10003) and log_time >= 1652414400000)
  and product_name <> '战令'





当期充值金额
新用户
SELECT sum(pay_price)
    FROM fairy_town.order_pay
WHERE server_id IN (10001,10002,10003)
  AND log_time >= 1652414400000 and log_time <= 1653339600000
  AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time >= 1652414400000 and log_time <= 1653339600000)
  and role_id in (SELECT DISTINCT role_id FROM fairy_town_server.server_activity_triggered WHERE server_id IN (10001,10002,10003) AND activity_id = 27 AND log_time >= 1652414400000)
  and role_id in (select distinct role_id from fairy_town_server.server_physical_consume 
                  where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001') 
                  and consume_count>0 and server_id in (10001,10002,10003) and log_time >= 1652414400000)
  and product_name <> '战令'


老用户
SELECT sum(pay_price)
    FROM fairy_town.order_pay
WHERE server_id IN (10001,10002,10003)
  AND log_time >= 1652414400000 and log_time <= 1653339600000
  AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time < 1652414400000)
  and role_id in (SELECT DISTINCT role_id FROM fairy_town_server.server_activity_triggered WHERE server_id IN (10001,10002,10003) AND activity_id = 27 AND log_time >= 1652414400000)
  and role_id in (select distinct role_id from fairy_town_server.server_physical_consume 
                  where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001') 
                  and consume_count>0 and server_id in (10001,10002,10003) and log_time >= 1652414400000)
  and product_name <> '战令'





存量分析

SELECT day_time,avg(physical) as physical_avg,appx_median(physical) as physical_appx,
                avg(gold) as gold_avg,appx_median(gold) as gold_appx,
                avg(gem) as gem_avg,appx_median(gem) as gem_appx,
                avg(bomb) as bomb_avg,appx_median(bomb) as bomb_appx 
                from fairy_town_server.server_login_snap_shot 
where day_time >= 20220509 and day_time <= 20220528
and server_id in (10001,10002,10003)
and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume 
                where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001') 
                and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1652414400000)
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
AND activity_id = 27 and role_level >= 10
and role_id not in (select distinct role_id from fairy_town_server.server_map_enter
                    where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001') 
                    and server_id in (10001,10002,10003) and log_time >= 1652414400000)
and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1653339600000)) as a

left join
(select role_id,day_time,count(ping) as zxsc
from fairy_town.client_online 
where day_time >= 20220509 and day_time <= 20220528
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
AND activity_id = 27 and role_level >= 10
and role_id not in (select distinct role_id from fairy_town_server.server_map_enter
                    where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001') 
                    and server_id in (10001,10002,10003) and log_time >= 1652414400000)
and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1653339600000)) as a
left join
(select role_id,day_time,max(cast(dlcs as int)) as dlcs
from
(select role_id,day_time,count(role_id) as dlcs
from fairy_town.server_role_login
where day_time >= 20220509 and day_time <= 20220528
and server_id IN (10001,10002,10003) group by 1,2) as aa group by 1,2) as c   

on a.role_id = c.role_id
group by 1,2,3
order by 2,1) as bb   
group by 1 order by 1






排行榜
SELECT c.role_id,change_sum as '积分数量',activity_group_id as '小组',physical_sum as '活动体力总消耗', 
recovery_count as '免费体力获得',(physical_sum - recovery_count) as '体力净消耗',country as '注册国家',paysum as '历史总付费',pay_2 as '当期付费'   
from

(SELECT role_id,sum(physical_consume) as physical_sum   -- 活动体力总消耗
from
(SELECT role_id,consume_count as physical_consume from fairy_town_server.server_physical_consume   -- 采集
where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001')
and server_id in (10001,10002,10003) and log_time >= 1652414400000

union all 

SELECT role_id,consume_physical_count as physical_consume from fairy_town_server.server_hunt       -- 打猎
where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001')
and server_id in (10001,10002,10003) and log_time >= 1652414400000
) a
group by 1
order by 1) as c

left join
(SELECT role_id,country, sum(change_count) as change_sum from fairy_town.server_prop 
where prop_id = '300203' and change_type = 'PRODUCE' and day_time >= 20220513 and day_time <= 20220524 group by 1,2) as a
on c.role_id = a.role_id

left join
(SELECT role_id,activity_group_id from fairy_town_server.server_activity_group WHERE activity_id = 27 GROUP BY 1,2) as b
on c.role_id = b.role_id

left join
(SELECT role_id,sum(recovery_count) as recovery_count  from fairy_town_server.server_physical_recovery
where log_time >= 1652414400000 and log_time <= 1653339600000
and server_id in (10001,10002,10003) and role_level >= 10  
and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume 
                where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001')
                and server_id in (10001,10002,10003) and log_time >= 1652414400000)
and recovery_method in ('4','5','6','13','14','15','17','19','20','22','23','27','28','29','67','71','72','75','77','78','80','83','88','90','91','93',
                        '94','97','101','108','111','116','118','119')

group by 1 order by 1) as d
on c.role_id = d.role_id
left join 
(select role_id,sum(pay_price) as paysum from fairy_town.order_pay where log_time <=1653339600000  group by 1) as f 
on c.role_id = f.role_id
left join 
(select role_id,sum(pay_price) as pay_2 from fairy_town.order_pay where day_time >= 20220513 and day_time >= 20220524 group by 1) as g 
on c.role_id = g.role_id

GROUP BY 1,2,3,4,5,6,7,8,9







SELECT c.role_id,change_sum as '积分数量',activity_group_id as '小组',physical_sum as '活动体力总消耗', 
recovery_count as '免费体力获得',(physical_sum - recovery_count) as '体力净消耗',country as '注册国家',paysum as '历史总付费',pay_2 as '当期付费'   
from

(SELECT role_id,sum(physical_consume) as physical_sum   -- 活动体力总消耗
from
(SELECT role_id,consume_count as physical_consume from fairy_town_server_tw.server_physical_consume   -- 采集
where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001')
and server_id in (10001,10002,10003) and log_time >= 1652414400000

union all 

SELECT role_id,consume_physical_count as physical_consume from fairy_town_server_tw.server_hunt       -- 打猎
where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001')
and server_id in (10001,10002,10003) and log_time >= 1652414400000
) a
group by 1
order by 1) as c

left join
(SELECT role_id,country, sum(change_count) as change_sum from fairy_town_tw.server_prop 
where prop_id = '300203' and change_type = 'PRODUCE' and day_time >= 20220513 and day_time <= 20220524 group by 1,2) as a
on c.role_id = a.role_id

left join
(SELECT role_id,activity_group_id from fairy_town_server_tw.server_activity_group WHERE activity_id = 27 GROUP BY 1,2) as b
on c.role_id = b.role_id

left join
(SELECT role_id,sum(recovery_count) as recovery_count  from fairy_town_server_tw.server_physical_recovery
where log_time >= 1652414400000 and log_time <= 1653339600000
and server_id in (10001,10002,10003) and role_level >= 10  
and role_id in (SELECT distinct role_id FROM fairy_town_server_tw.server_physical_consume 
                where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001')
                and server_id in (10001,10002,10003) and log_time >= 1652414400000)
and recovery_method in ('4','5','6','13','14','15','17','19','20','22','23','27','28','29','67','71','72','75','77','78','80','83','88','90','91','93',
                        '94','97','101','108','111','116','118','119')

group by 1 order by 1) as d
on c.role_id = d.role_id
left join 
(select role_id,sum(pay_price) as paysum from fairy_town_tw.order_pay where log_time <=1653339600000  group by 1) as f 
on c.role_id = f.role_id
left join 
(select role_id,sum(pay_price) as pay_2 from fairy_town_tw.order_pay where day_time >= 20220513 and day_time >= 20220524 group by 1) as g 
on c.role_id = g.role_id

GROUP BY 1,2,3,4,5,6,7,8,9




宽表 Global
select a.role_id as '角色id',
birth_dt as '注册日期',
country as '注册国家',
case when pay is null then 0 
     else round(pay,2) 
end as '历史付费金额($)',
case when acti_pay is null then 0 
     else round(acti_pay,2) 
end as '当期付费金额($)',
一日消耗,
二日消耗,
三日消耗,
四日消耗,
五日消耗,
六日消耗,
七日消耗,
八日消耗,
九日消耗,
十日消耗,
十一日消耗,
十二日消耗,
case when task_id is not null  then '通关'
     else '未通关'
end as '是否通关',
pass_dt as '通关时间'
from
(select role_id 
from fairy_town_server.server_physical_consume
where day_time>=20220513  and day_time<=20220524
and log_time >= 1639081800000 
and server_id in (10001,10002,10003)
and map_id in ('40090001','40100001','40110001','40120001','40010001','40020001',
  '40030001','40040001','40050001','40060001','40070001','40080001')
group by 1) a 
left join 
(select role_id,to_date(cast (date_time as timestamp)) as birth_dt,day_time as day_date,country
from fairy_town.server_role_create
where day_time>=20210420  and day_time<=20220524
and server_id in (10001,10002,10003)
) b 
on a.role_id=b.role_id
left join 
(select role_id,sum(pay_price) as pay 
from fairy_town.order_pay
where day_time>=20210420  and day_time<=20220524
and server_id in (10001,10002,10003)
and log_time<=1653339600000
group by 1) c 
on a.role_id=c.role_id
left join 
(select role_id,
sum( case when phy_dt=20220513 then consumes else 0 end ) as '一日消耗',
sum( case when phy_dt=20220514 then consumes else 0 end ) as '二日消耗',
sum( case when phy_dt=20220515 then consumes else 0 end ) as '三日消耗',
sum( case when phy_dt=20220516 then consumes else 0 end ) as '四日消耗',
sum( case when phy_dt=20220517 then consumes else 0 end ) as '五日消耗',
sum( case when phy_dt=20220518 then consumes else 0 end ) as '六日消耗',
sum( case when phy_dt=20220519 then consumes else 0 end ) as '七日消耗',
sum( case when phy_dt=20220520 then consumes else 0 end ) as '八日消耗',
sum( case when phy_dt=20220521 then consumes else 0 end ) as '九日消耗',
sum( case when phy_dt=20220522 then consumes else 0 end ) as '十日消耗',
sum( case when phy_dt=20220523 then consumes else 0 end ) as '十一日消耗',
sum( case when phy_dt=20220524 then consumes else 0 end ) as '十二日消耗'
from
(select role_id,day_time as phy_dt,consume_count as consumes
from fairy_town_server.server_physical_consume
where day_time>=20220513  and day_time<=20220524
and server_id in (10001,10002,10003)
and map_id in ('40090001','40100001','40110001','40120001','40010001','40020001',
  '40030001','40040001','40050001','40060001','40070001','40080001')
union all 
select role_id,day_time as phy_dt,consume_count as consumes
from fairy_town_server.server_stone_pillar_turn
where day_time>=20220513  and day_time<=20220524
and log_time >= 1639081800000  
and server_id in (10001,10002,10003)
and map_id in ('40090001','40100001','40110001','40120001','40010001','40020001',
  '40030001','40040001','40050001','40060001','40070001','40080001')
union all 
select role_id,day_time as phy_dt,consume_physical_count as consumes
from fairy_town_server.server_hunt
where day_time>=20220513  and day_time<=20220524
and log_time >= 1639081800000  
and server_id in (10001,10002,10003)
and map_id in ('40090001','40100001','40110001','40120001','40010001','40020001',
  '40030001','40040001','40050001','40060001','40070001','40080001')
) d1 
group by 1) d 
on a.role_id=d.role_id
left join 
(select task_id,role_id,to_date(cast (date_time as timestamp)) as pass_dt
from fairy_town_server.server_task_completed
where day_time>=20220513  and day_time<=20220524
and server_id in (10001,10002,10003)
and log_time >= 1639081800000  
and task_id ='1000027'
group by 1,2,3
) f
on a.role_id=f.role_id
left join 
(select role_id,sum(pay_price) as acti_pay 
from fairy_town.order_pay
where day_time>=20220513  and day_time<=20220524
and server_id in (10001,10002,10003)
and log_time >= 1652414400000 and log_time<=1653339600000        
group by 1) g 
on a.role_id=g.role_id





宽表 台湾
select a.role_id as '角色id',
birth_dt as '注册日期',
country as '注册国家',
case when pay is null then 0 
     else round(pay,2) 
end as '历史付费金额($)',
case when acti_pay is null then 0 
     else round(acti_pay,2) 
end as '当期付费金额($)',
一日消耗,
二日消耗,
三日消耗,
四日消耗,
五日消耗,
六日消耗,
七日消耗,
八日消耗,
九日消耗,
十日消耗,
十一日消耗,
十二日消耗,
case when task_id is not null  then '通关'
     else '未通关'
end as '是否通关',
pass_dt as '通关时间'
from
(select role_id 
from fairy_town_server_tw.server_physical_consume
where day_time>=20220513  and day_time<=20220524
and server_id in (10001,10002,10003)
and map_id in ('40090001','40100001','40110001','40120001','40010001','40020001',
  '40030001','40040001','40050001','40060001','40070001','40080001')
group by 1) a 
left join 
(select role_id,to_date(cast (date_time as timestamp)) as birth_dt,day_time as day_date,country
from fairy_town_tw.server_role_create
where day_time>=20210420  and day_time<=20220524
and server_id in (10001,10002,10003)
) b 
on a.role_id=b.role_id
left join 
(select role_id,sum(pay_price) as pay 
from fairy_town_tw.order_pay
where day_time>=20210420  and day_time<=20220524
and server_id in (10001,10002,10003)
and log_time<=1653339600000
group by 1) c 
on a.role_id=c.role_id
left join 
(select role_id,
sum( case when phy_dt=20220513 then consumes else 0 end ) as '一日消耗',
sum( case when phy_dt=20220514 then consumes else 0 end ) as '二日消耗',
sum( case when phy_dt=20220515 then consumes else 0 end ) as '三日消耗',
sum( case when phy_dt=20220516 then consumes else 0 end ) as '四日消耗',
sum( case when phy_dt=20220517 then consumes else 0 end ) as '五日消耗',
sum( case when phy_dt=20220518 then consumes else 0 end ) as '六日消耗',
sum( case when phy_dt=20220519 then consumes else 0 end ) as '七日消耗',
sum( case when phy_dt=20220520 then consumes else 0 end ) as '八日消耗',
sum( case when phy_dt=20220521 then consumes else 0 end ) as '九日消耗',
sum( case when phy_dt=20220522 then consumes else 0 end ) as '十日消耗',
sum( case when phy_dt=20220523 then consumes else 0 end ) as '十一日消耗',
sum( case when phy_dt=20220524 then consumes else 0 end ) as '十二日消耗'
from
(select role_id,day_time as phy_dt,consume_count as consumes
from fairy_town_server_tw.server_physical_consume
where day_time>=20220513  and day_time<=20220524
and server_id in (10001,10002,10003)
and map_id in ('40090001','40100001','40110001','40120001','40010001','40020001',
  '40030001','40040001','40050001','40060001','40070001','40080001')
union all 
select role_id,day_time as phy_dt,consume_count as consumes
from fairy_town_server_tw.server_stone_pillar_turn
where day_time>=20220513  and day_time<=20220524 
and server_id in (10001,10002,10003)
and map_id in ('40090001','40100001','40110001','40120001','40010001','40020001',
  '40030001','40040001','40050001','40060001','40070001','40080001')
union all 
select role_id,day_time as phy_dt,consume_physical_count as consumes
from fairy_town_server_tw.server_hunt
where day_time>=20220513  and day_time<=20220524 
and server_id in (10001,10002,10003)
and map_id in ('40090001','40100001','40110001','40120001','40010001','40020001',
  '40030001','40040001','40050001','40060001','40070001','40080001')
) d1 
group by 1) d 
on a.role_id=d.role_id
left join 
(select task_id,role_id,to_date(cast (date_time as timestamp)) as pass_dt
from fairy_town_server_tw.server_task_completed
where day_time>=20220513  and day_time<=20220524
and server_id in (10001,10002,10003)
and log_time >= 1639081800000  
and task_id ='1000027'
group by 1,2,3
) f
on a.role_id=f.role_id
left join 
(select role_id,sum(pay_price) as acti_pay 
from fairy_town_tw.order_pay
where day_time>=20220513  and day_time<=20220524
and server_id in (10001,10002,10003)
and log_time >= 1652414400000 and log_time<=1653339600000        
group by 1) g 
on a.role_id=g.role_id


弹窗没进入地图

SELECT role_level,count(DISTINCT role_id)
from
(
SELECT role_id,role_level
from
(
SELECT role_id,role_level,row_number() over(PARTITION BY role_id ORDER BY log_time asc) as num
FROM fairy_town_server.server_activity_triggered
WHERE server_id IN (10001,10002,10003)
AND activity_id = 15
and role_id NOT IN
(
select distinct role_id
from 
    fairy_town_server.server_map_enter
where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001') 
and server_id in (10001,10002,10003) and log_time >= 1646280000000 and log_time <= 1646938800000
)
) as a
where num = 1
GROUP BY 1,2 ORDER BY 2
) as a
GROUP BY 1 ORDER BY 1


弹窗未进入内存分布
SELECT channel_id,c.device_id,device_total_ram,device_model from 

(SELECT device_id from
(SELECT role_id
from
(
SELECT role_id,role_level
from
(
SELECT role_id,role_level,row_number() over(PARTITION BY role_id ORDER BY log_time asc) as num
FROM fairy_town_server.server_activity_triggered
WHERE server_id IN (10001,10002,10003)
AND activity_id = 27
and role_id NOT IN
(
select distinct role_id
from 
    fairy_town_server.server_map_enter
where map_id in ('40090001','40100001','40110001','40120001','40010001','40020001','40030001','40040001','40050001','40060001','40070001','40080001') 
and server_id in (10001,10002,10003) and log_time >= 1652414400000
)
) as a
where num = 1
GROUP BY 1,2 ORDER BY 2
) as a  )as a

left join

(SELECT device_id,role_id from fairy_town.server_role_create where server_id in (10001,10002,10003)
GROUP BY 1,2) as b
on a.role_id = b.role_id
GROUP BY 1
) as c

left join 
(SELECT device_id,channel_id, device_total_ram,device_model FROM fairy_town.device_launch where channel_id in (1000,2000) GROUP BY 1,2,3,4) as d
on c.device_id = d.device_id 
GROUP BY 1,2,3,4
order by 2