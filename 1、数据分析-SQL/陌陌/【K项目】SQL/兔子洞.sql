4.22 12:00 -  5.3 5:00

1650600000000   1651525200000


需要加上台湾的数据，就不直接union all了  直接分开算 Excel处理了


活动弹窗 相当于接取任务人数 (√)
SELECT count(DISTINCT role_id)
FROM fairy_town_server.server_activity_triggered
WHERE server_id IN (10001,10002,10003)
and log_time >= 1650600000000
AND activity_id = 17



历史付费参与活动角色数量(√)
SELECT count(DISTINCT role_id) from fairy_town_server.server_physical_consume
where map_id in ('31040001','31050001','31060001')
and server_id in (10001,10002,10003) and role_level >= 10 and log_time >= 1650600000000
and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1651525200000)



进入地图人数(√)
select
    count(distinct role_id)
from 
    fairy_town_server.server_map_enter
where map_id in ('31040001','31050001','31060001')
and server_id in (10001,10002,10003) and log_time >= 1650600000000



体力消耗(√)
SELECT 
    count(distinct role_id) as num
FROM 
    fairy_town_server.server_physical_consume 
where map_id in ('31040001','31050001','31060001')
and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1650600000000



活动参与率 日参与率(√)
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
    where map_id in ('31040001','31050001','31060001')
    and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1650600000000
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
             where map_id in ('31040001','31050001','31060001')
             and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1650600000000
             )   
         union all
             (
             SELECT
                 role_id,
                 date_time
             from 
                 fairy_town.server_role_login    
             WHERE role_level >= 10 and server_id in (10001,10002,10003) and log_time >= 1650600000000 and log_time <= 1651525200000
             )
        ) c
    group by 1
    ) as b
where a.birth_dt = b.birth_dt
order by day_dt




活动体力总消耗(√)
SELECT day_time,sum(physical_consume)
from
(SELECT day_time,consume_count as physical_consume from fairy_town_server.server_physical_consume   -- 采集
where map_id in ('31040001','31050001','31060001')
and server_id in (10001,10002,10003) and role_level >= 10 and log_time >= 1650600000000
and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1651525200000)

union all 

SELECT day_time,consume_physical_count as physical_consume from fairy_town_server.server_hunt       -- 打猎
where map_id in ('31040001','31050001','31060001')
and server_id in (10001,10002,10003) and role_level >= 10 and log_time >= 1650600000000
and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1651525200000)
) a
group by 1
order by 1


免费体力获得(√)
SELECT day_time,sum(recovery_count) from fairy_town_server.server_physical_recovery
where log_time >= 1650600000000 and log_time <= 1651525200000
and server_id in (10001,10002,10003) and role_level >= 10 
--and map_id in ('31040001','31050001','31060001') 
and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume where map_id in ('31040001','31050001','31060001') 
                and server_id in (10001,10002,10003) and log_time >= 1650600000000)
and recovery_method in ('4','5','6','13','14','15','17','19','20','22','23','27','28','29','67','71','72','75','77','78','80','83','88','90','91','93',
                        '94','97','101','108','111','116','118','119')
and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1651525200000)
group by 1 order by 1

 


体力净值消耗区间分布(√)
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
        where map_id in ('31040001','31050001','31060001')
        and server_id in (10001,10002,10003) and role_level >= 10 and log_time >= 1650600000000
        and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1651525200000)
        
        union all 

        SELECT role_id,consume_physical_count as physical_consume from fairy_town_server.server_hunt
        where map_id in ('31040001','31050001','31060001')
        and server_id in (10001,10002,10003) and role_level >= 10 and log_time >= 1650600000000
        and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1651525200000)
        ) as a
        group by 1
        order by 1) as a
        left join
        -- 免费体力获得
        (SELECT role_id,sum(recovery_count) as recovery_count from fairy_town_server.server_physical_recovery
        where log_time >= 1650600000000 and log_time <= 1651525200000
        and server_id in (10001,10002,10003) and role_level >= 10
        and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume where map_id in ('31040001','31050001','31060001')
                        and server_id in (10001,10002,10003) and log_time >= 1650600000000)
        and recovery_method in ('4','5','6','13','14','15','17','19','20','22','23','27','28','29','67','71','72','75',
                                '77','78','80','83','88','90','91','93','94','97','101','108','111','116','118','119')
        and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1651525200000)
        group by 1 order by 1) as b
        on a.role_id = b.role_id
        ) as aa
        where role_id in (SELECT DISTINCT role_id FROM fairy_town_server.server_task_completed   -- 通关
                          where server_id IN (10001,10002,10003) and log_time >= 1650600000000 and task_group_id = '310634')
) bb




活动钻石总消耗(√)
SELECT day_time,sum(consume_count) from fairy_town_server.server_gem_consume
where map_id in ('31040001','31050001','31060001')
and server_id in (10001,10002,10003) and role_level >= 10
and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1651525200000)
GROUP BY 1 ORDER BY 1

免费钻石获得(√)
SELECT day_time,sum(recovery_count) from fairy_town_server.server_gem_recovery
where log_time >= 1650600000000 and log_time <= 1651525200000 
--and map_id in ('31040001','31050001','31060001')
and server_id in (10001,10002,10003) and role_level >= 10
and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume where map_id in ('31040001','31050001','31060001') and server_id in (10001,10002,10003))
and recovery_method in ('4','5','6','13','14','15','17','19','20','22','23','27','28','29','67','71','72','75','77','78','80','83','88','90','91','93',
                        '94','97','101','108','111','116','118','119')
and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1651525200000)
group by 1 order by 1




通关用户 (√) ****************************************(√)
SELECT count(DISTINCT a.role_id)
from
(SELECT role_id FROM fairy_town_server.server_task_completed
where server_id IN (10001,10002,10003) and log_time >= 1650600000000 and task_group_id = '310634') as a 


-- 任务   (√) 
积分任务  ****************************************(√)
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
      and log_time >= 1650600000000
      AND task_group_id IN ('1004001','1004002','1004003','1004009','1004011','1004012','1004013','1004017','1004004',
                            '1004005','1004006','1004007','1004008','1004010','1004022','1004023','1004024','1004014',
                            '1004015','1004016','1004018','1004019','1004020','1004021')
      and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume 
          where map_id in ('31040001','31050001','31060001') 
          and server_id in (10001,10002,10003) and log_time >= 1650600000000)
    group by 1
    ) a
left join
    (SELECT
        task_id as task_id,
        count(distinct role_id) as task_group_id_num
    FROM fairy_town_server.server_task_completed
    WHERE server_id IN (10001,10002,10003)
      and log_time >= 1650600000000
      AND task_group_id IN ('1004001','1004002','1004003','1004009','1004011','1004012','1004013','1004017','1004004',
                            '1004005','1004006','1004007','1004008','1004010','1004022','1004023','1004024','1004014',
                            '1004015','1004016','1004018','1004019','1004020','1004021')
      and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume 
          where map_id in ('31040001','31050001','31060001') 
          and server_id in (10001,10002,10003) and log_time >= 1650600000000)
    group by 1
    ) b
on a.task_id = b.task_id
order by  1




主线任务  ****************************************(√)
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
      and log_time >= 1650600000000
      AND task_id IN ('3104001','3104011','3104021','3104022','3104031','3104041','3105021','3105031','3105041',
                      '3105051','3105052','3105061','3105071','3105072','3105081','3105082','3105091','3105101',
                      '3105111','3105141','3105142','3106011','3106021','3106022','3106031','3106032','3106041',
                      '3106042','3106051','3106061','3106071','3106081','3106091','3106101','3106111','3106121',
                      '3106122','3106131','3106132','3106141','3106151','3106152','3106153','3106161','3106162',
                      '3106163','3106171','3106181','3106182','3106183','3106191','3106201','3106211','3106212',
                      '3106221','3106222','3106231','3106233','3106241','3106251','3106261','3106271','3106281',
                      '3106291','3106301','3106302','3106311','3106321','3106331','3106332','3104051','3105011',
                      '3105102','3105121','3105131','3105132','3106232','3104061','3106341','3106351','3106361')
      and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume 
          where map_id in ('31040001','31050001','31060001')  and server_id in (10001,10002,10003) and log_time >= 1650600000000)
    group by 1
    ) a
left join
    (SELECT
        task_id as task_id,
        count(distinct role_id) as task_group_id_num
    FROM fairy_town_server.server_task_completed
    WHERE server_id IN (10001,10002,10003)
      and log_time >= 1650600000000
      AND task_id IN ('3104001','3104011','3104021','3104022','3104031','3104041','3105021','3105031','3105041',
                      '3105051','3105052','3105061','3105071','3105072','3105081','3105082','3105091','3105101',
                      '3105111','3105141','3105142','3106011','3106021','3106022','3106031','3106032','3106041',
                      '3106042','3106051','3106061','3106071','3106081','3106091','3106101','3106111','3106121',
                      '3106122','3106131','3106132','3106141','3106151','3106152','3106153','3106161','3106162',
                      '3106163','3106171','3106181','3106182','3106183','3106191','3106201','3106211','3106212',
                      '3106221','3106222','3106231','3106233','3106241','3106251','3106261','3106271','3106281',
                      '3106291','3106301','3106302','3106311','3106321','3106331','3106332','3104051','3105011',
                      '3105102','3105121','3105131','3105132','3106232','3104061','3106341','3106351','3106361')
      and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume 
          where map_id in ('31040001','31050001','31060001')  and server_id in (10001,10002,10003) and log_time >= 1650600000000)
    group by 1
    ) b
on a.task_id = b.task_id
order by  1







活动奖励领取情况  ****************************************(√)

装饰+可持续生产  放置人数
SELECT 装饰物,count(distinct role_id)
from
(SELECT
    role_id,
    case when building_id = '4007128' then '复活节彩蛋1 - 家园'
         when building_id = '4007129' then '复活节彩蛋2 - 家园'
         when building_id = '4007130' then '复活节彩蛋3 - 家园'
         when building_id = '4007131' then '复活节彩蛋4 - 家园'
    end as '装饰物'
from 
(SELECT 
    building_id,
    role_id
FROM 
    fairy_town_server.server_building_get
WHERE building_id in ('4007128','4007129','4007130','4007131') 
      and server_id in (10001,10002,10003)
      and log_time >= 1650600000000
) as aa
) as bb
group by 1




限时商店****************************************(√)

SELECT 装饰物,count(distinct role_id)
from
(SELECT
    role_id,
    case  when building_id = '4007033' then '彩蛋路灯'
          when building_id = '4007032' then '彩蛋树篱雕像'
          when building_id = '4007035' then '彩蛋花坛'
          when building_id = '4007038' then '小兔与蘑菇'
          when building_id = '4007039' then '小兔与彩蛋'
          when building_id = '4007037' then '小兔婴儿车'
          when building_id = '4007100' then '发条青蛙'
          when building_id = '4007097' then '小兔烛灯'
          when building_id = '4007101' then '小兔鼓手'
          when building_id = '4007098' then '彩蛋屋'
          when building_id = '4007099' then '惊喜彩蛋'
          when building_id = '4007036' then '复活节礼物堆'
    end as '装饰物'
from 
(SELECT 
    building_id,
    role_id
FROM 
    fairy_town_server.server_building_get
WHERE building_id in ('4007033','4007032','4007035','4007038','4007039','4007037','4007100','4007097','4007101','4007098','4007099','4007036')
      and server_id in (10001,10002,10003)
      and log_time >= 1650600000000
) as aa
) as bb
group by 1




活动评价数据   ****************************************(√)
SELECT 
    role_id,
    scores
FROM fairy_town_server.server_event_rate
where role_id in (select distinct role_id from fairy_town_server.server_physical_consume 
                  where map_id in ('31040001','31050001','31060001') 
                  and server_id in (10001,10002,10003) and day_time >= 20220422 and day_time <= 20220503)
      and activity_id = 17
group by 1,2


活动礼包购买行为  *************************************** (√) 
SELECT 
    day_time,
    game_product_id,
    count(game_product_id) as `购买数量`,
    sum(pay_price) as `流水`
from
(
SELECT day_time,game_product_id,pay_price
FROM 
    fairy_town.order_pay
where game_product_id in ('com.managames.fairytown.iap_3.99ve','com.managames.fairytown.iap_9.99ve','com.managames.fairytown.iap_19.99ve')
and server_id in (10001,10002,10003) and day_time >= 20220422 and day_time <= 20220503
union all
SELECT day_time,game_product_id,pay_price
FROM 
    fairy_town_tw.order_pay
where game_product_id in ('com.managames.fairytown.iap_3.99ve','com.managames.fairytown.iap_9.99ve','com.managames.fairytown.iap_19.99ve')
and server_id in (10001,10002,10003) and day_time >= 20220422 and day_time <= 20220503
) as a
GROUP BY 1,2
ORDER BY 1,2


# 活动收入
—————————————————————————————— 参与 ——————————————————————————————(√) 
********************************************************************************

活跃人数
新用户
SELECT count(DISTINCT role_id) FROM fairy_town_server.server_activity_triggered WHERE server_id IN (10001,10002,10003) AND activity_id = 17
AND log_time >= 1650600000000 and log_time <= 1651525200000
AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time >= 1650600000000 and log_time <= 1651525200000) 
and role_id in (select distinct role_id from fairy_town_server.server_physical_consume 
                where map_id in ('31040001','31050001','31060001')
                and consume_count>0 and server_id in (10001,10002,10003) and log_time >= 1650600000000)

老用户
SELECT count(DISTINCT role_id) FROM fairy_town_server.server_activity_triggered WHERE server_id IN (10001,10002,10003) AND activity_id = 17
AND log_time >= 1650600000000 and log_time <= 1651525200000
AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time < 1650600000000)
and role_id in (select distinct role_id from fairy_town_server.server_physical_consume 
                where map_id in ('31040001','31050001','31060001')
                and consume_count>0 and server_id in (10001,10002,10003) and log_time >= 1650600000000)




当期充值人数
新用户
SELECT count(DISTINCT role_id)
FROM fairy_town.order_pay
WHERE server_id IN (10001,10002,10003)
  AND log_time >= 1650600000000 and log_time <= 1651525200000
  AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time >= 1650600000000 and log_time <= 1651525200000)
  and role_id in (SELECT DISTINCT role_id FROM fairy_town_server.server_activity_triggered WHERE server_id IN (10001,10002,10003) AND activity_id = 17 AND log_time >= 1650600000000)
  and role_id in (select distinct role_id from fairy_town_server.server_physical_consume 
                  where map_id in ('31040001','31050001','31060001')
                  and consume_count>0 and server_id in (10001,10002,10003) and log_time >= 1650600000000)
  and product_name <> '战令'


老用户
SELECT count(DISTINCT role_id)
FROM fairy_town.order_pay
WHERE server_id IN (10001,10002,10003)
  AND log_time >= 1650600000000 and log_time <= 1651525200000
  AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time < 1650600000000)
  and role_id in (SELECT DISTINCT role_id FROM fairy_town_server.server_activity_triggered WHERE server_id IN (10001,10002,10003) AND activity_id = 17 AND log_time >= 1650600000000)
  and role_id in (select distinct role_id from fairy_town_server.server_physical_consume 
                  where map_id in ('31040001','31050001','31060001') 
                  and consume_count>0 and server_id in (10001,10002,10003) and log_time >= 1650600000000)
  and product_name <> '战令'





当期充值金额
新用户
SELECT sum(pay_price)
    FROM fairy_town.order_pay
WHERE server_id IN (10001,10002,10003)
  AND log_time >= 1650600000000 and log_time <= 1651525200000
  AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time >= 1650600000000 and log_time <= 1651525200000)
  and role_id in (SELECT DISTINCT role_id FROM fairy_town_server.server_activity_triggered WHERE server_id IN (10001,10002,10003) AND activity_id = 17 AND log_time >= 1650600000000)
  and role_id in (select distinct role_id from fairy_town_server.server_physical_consume 
                  where map_id in ('31040001','31050001','31060001') 
                  and consume_count>0 and server_id in (10001,10002,10003) and log_time >= 1650600000000)
  and product_name <> '战令'


老用户
SELECT sum(pay_price)
    FROM fairy_town.order_pay
WHERE server_id IN (10001,10002,10003)
  AND log_time >= 1650600000000 and log_time <= 1651525200000
  AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time < 1650600000000)
  and role_id in (SELECT DISTINCT role_id FROM fairy_town_server.server_activity_triggered WHERE server_id IN (10001,10002,10003) AND activity_id = 17 AND log_time >= 1650600000000)
  and role_id in (select distinct role_id from fairy_town_server.server_physical_consume 
                  where map_id in ('31040001','31050001','31060001') 
                  and consume_count>0 and server_id in (10001,10002,10003) and log_time >= 1650600000000)
  and product_name <> '战令'





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
        day_time >= 20220410 and day_time <= 20220503
        and server_id IN (10001,10002,10003)
        and role_id in
        (SELECT
            distinct role_id
         FROM fairy_town_server.server_physical_consume 
         where map_id in ('31040001','31050001','31060001') 
         and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1650600000000)
    group by 1,2

    union all

    select
        day_time,
        role_id,
        count(role_id) as cishu
    from
        fairy_town_tw.server_role_login
    where 
        day_time >= 20220410 and day_time <= 20220503
        and server_id IN (10001,10002,10003)
        and role_id in
        (SELECT
            distinct role_id
         FROM fairy_town_server_tw.server_physical_consume 
         where map_id in ('31040001','31050001','31060001') 
         and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1650600000000)
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
        day_time >= 20220410 and day_time <= 20220503
        and server_id IN (10001,10002,10003)
        and role_id in
        (SELECT
            distinct role_id
         FROM fairy_town_server.server_physical_consume 
         where map_id in ('31040001','31050001','31060001') 
         and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1650600000000
        )
    group by 1,2

    union all 

    SELECT
        role_id,
        day_time,
        count(ping) as num
    from 
        fairy_town_tw.client_online
    where 
        day_time >= 20220410 and day_time <= 20220503
        and server_id IN (10001,10002,10003)
        and role_id in
        (SELECT
            distinct role_id
         FROM fairy_town_server_tw.server_physical_consume 
         where map_id in ('31040001','31050001','31060001') 
         and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1650600000000
        )
    group by 1,2
) a
group by day_time
order by day_time



留存
当周数据&过去一周数据(√)
select channel_id,media_source,level_dt,role_level,datediff(login_dt,level_dt) as datediffs,count(distinct c.role_id)
from
(select channel_id,role_id,
 case when media_source is null then 'Organic'
         else media_source end as media_source,
         role_level,level_dt
 from 
(select channel_id,role_id,device_id,role_level,to_date(cast(date_time as timestamp)) as level_dt
from fairy_town.server_role_upgrade
where day_time>=20220415 and day_time<=20220428
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
where day_time>=20220415 and day_time<=20220429
and server_id in (10001,10002,10003)
group by 1,2
) d 
on c.role_id=d.role_id and login_dt>=level_dt
where datediff(login_dt,level_dt) <=1
group by 1,2,3,4,5



存量分析(√)

SELECT day_time,avg(physical) as physical_avg,appx_median(physical) as physical_appx,
                avg(gold) as gold_avg,appx_median(gold) as gold_appx,
                avg(gem) as gem_avg,appx_median(gem) as gem_appx,
                avg(bomb) as bomb_avg,appx_median(bomb) as bomb_appx 
from 
(
select day_time,physical,gold,gem,bomb
from fairy_town_server.server_login_snap_shot 
where day_time >= ${start_time} and day_time <= ${end_time}
and server_id in (10001,10002,10003)
and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume 
                where map_id in ('31040001','31050001','31060001') 
                and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1650600000000)
union all
select day_time,physical,gold,gem,bomb
from fairy_town_server_tw.server_login_snap_shot 
where day_time >= ${start_time} and day_time <= ${end_time}
and server_id in (10001,10002,10003)
and role_id in (SELECT distinct role_id FROM fairy_town_server_tw.server_physical_consume 
                where map_id in ('31040001','31050001','31060001') 
                and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1650600000000)
) as a
group by 1
order by 1


体力道具存量
SELECT day_time,role_id,phy_items
from 
(
select day_time,role_id,phy_items
from fairy_town_server.server_login_snap_shot 
where day_time >= ${start_time} and day_time <= ${end_time}
and server_id in (10001,10002,10003)
and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume 
                where map_id in ('31040001','31050001','31060001') 
                and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1650600000000)
union all
select day_time,role_id,phy_items
from fairy_town_server_tw.server_login_snap_shot 
where day_time >= ${start_time} and day_time <= ${end_time}
and server_id in (10001,10002,10003)
and role_id in (SELECT distinct role_id FROM fairy_town_server_tw.server_physical_consume 
                where map_id in ('31040001','31050001','31060001') 
                and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1650600000000)
) as a
group by 1,2,3
order by 1


弹窗没进地图的玩家在线时长  历史付费用户
SELECT day_dt,count(distinct role_id) as '在线人数', avg(zxsc) as '平均在线时长',appx_median(zxsc) as '在线时长中位数'
from

(SELECT a.role_id as role_id,b.day_time as day_dt,zxsc
from

(SELECT role_id
FROM fairy_town_server.server_activity_triggered
WHERE server_id IN (10001,10002,10003)
AND activity_id = 17 and role_level >= 10
and role_id not in (select distinct role_id from fairy_town_server.server_map_enter
                    where map_id in ('31040001','31050001','31060001')
                    and server_id in (10001,10002,10003) and log_time >= 1650600000000)
and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1651525200000)) as a

left join
(select role_id,day_time,count(ping) as zxsc
from fairy_town.client_online 
where day_time >= ${start_time} and day_time <= ${end_time}
and server_id IN (10001,10002,10003) group by 1,2) as b  
on a.role_id = b.role_id
group by 1,2,3
order by 2,1

union all
SELECT a.role_id as role_id,b.day_time as day_dt,zxsc
from

(SELECT role_id
FROM fairy_town_server_tw.server_activity_triggered
WHERE server_id IN (10001,10002,10003)
AND activity_id = 17 and role_level >= 10
and role_id not in (select distinct role_id from fairy_town_server_tw.server_map_enter
                    where map_id in ('31040001','31050001','31060001')
                    and server_id in (10001,10002,10003) and log_time >= 1650600000000)
and role_id in (select distinct role_id from fairy_town_tw.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1651525200000)) as a

left join
(select role_id,day_time,count(ping) as zxsc
from fairy_town_tw.client_online 
where day_time >= ${start_time} and day_time <= ${end_time}
and server_id IN (10001,10002,10003) group by 1,2) as b  
on a.role_id = b.role_id
group by 1,2,3
order by 2,1
) as aa  
group by 1 order by 1




SELECT day_dt,count(distinct role_id) as '登录人数',avg(dlcs) as '平均登录次数',appx_median(dlcs) as '登录次数中位数'
from

(SELECT a.role_id as role_id,c.day_time as day_dt,dlcs
from
(SELECT role_id
FROM fairy_town_server.server_activity_triggered
WHERE server_id IN (10001,10002,10003)
AND activity_id = 17 and role_level >= 10
and role_id not in (select distinct role_id from fairy_town_server.server_map_enter
                    where map_id in ('31040001','31050001','31060001')
                    and server_id in (10001,10002,10003) and log_time >= 1650600000000)
and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1651525200000)) as a
left join
(select role_id,day_time,max(cast(dlcs as int)) as dlcs
from
(select role_id,day_time,count(role_id) as dlcs
from fairy_town.server_role_login
where day_time >= ${start_time} and day_time <= ${end_time}
and server_id IN (10001,10002,10003) group by 1,2) as aa group by 1,2) as c   

on a.role_id = c.role_id
group by 1,2,3
order by 2,1

union all 

SELECT a.role_id as role_id,c.day_time as day_dt,dlcs
from
(SELECT role_id
FROM fairy_town_server_tw.server_activity_triggered
WHERE server_id IN (10001,10002,10003)
AND activity_id = 17 and role_level >= 10
and role_id not in (select distinct role_id from fairy_town_server_tw.server_map_enter
                    where map_id in ('31040001','31050001','31060001')
                    and server_id in (10001,10002,10003) and log_time >= 1650600000000)
and role_id in (select distinct role_id from fairy_town_tw.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1651525200000)) as a
left join
(select role_id,day_time,max(cast(dlcs as int)) as dlcs
from
(select role_id,day_time,count(role_id) as dlcs
from fairy_town_tw.server_role_login
where day_time >= ${start_time} and day_time <= ${end_time}
and server_id IN (10001,10002,10003) group by 1,2) as aa group by 1,2) as c   

on a.role_id = c.role_id
group by 1,2,3
order by 2,1
) as bb   
group by 1 order by 1




排行榜安老师算的




