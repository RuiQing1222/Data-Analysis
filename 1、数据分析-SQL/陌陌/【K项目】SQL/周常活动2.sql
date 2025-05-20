6.29 12:00 -  7.3 5:00

1656475200000   1656795600000


需要加上台湾的数据，就不直接union all了  直接分开算 Excel处理了


活动弹窗 相当于接取任务人数 (√)
SELECT count(DISTINCT role_id)
FROM fairy_town_server.server_activity_triggered
WHERE server_id IN (10001,10002,10003)
and log_time >= 1656475200000
AND activity_id = 25



历史付费参与活动角色数量(√) 
SELECT count(DISTINCT role_id) from fairy_town_server.server_physical_consume
where map_id = '41020001'
and server_id in (10001,10002,10003) and role_level >= 10 and log_time >= 1656475200000
and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1656795600000)



进入地图人数(√)
select
    count(distinct role_id)
from 
    fairy_town_server.server_map_enter
where map_id = '41020001'
and server_id in (10001,10002,10003) and log_time >= 1656475200000



体力消耗(√)
SELECT 
    count(distinct role_id) as num
FROM 
    fairy_town_server.server_physical_consume 
where map_id = '41020001'
and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1656475200000



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
    where map_id = '41020001'
    and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1656475200000
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
             where map_id = '41020001'
             and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1656475200000
             )   
         union all
             (
             SELECT
                 role_id,
                 date_time
             from 
                 fairy_town.server_role_login    
             WHERE role_level >= 10 and server_id in (10001,10002,10003) and log_time >= 1656475200000 and log_time <= 1656795600000
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
where map_id = '41020001'
and server_id in (10001,10002,10003) and role_level >= 10 and log_time >= 1656475200000
and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1656795600000)

union all 

SELECT day_time,consume_physical_count as physical_consume from fairy_town_server.server_hunt       -- 打猎
where map_id = '41020001'
and server_id in (10001,10002,10003) and role_level >= 10 and log_time >= 1656475200000
and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1656795600000)
) a
group by 1
order by 1


免费体力获得(√)
SELECT day_time,sum(recovery_count) from fairy_town_server.server_physical_recovery
where log_time >= 1656475200000 and log_time <= 1656795600000
and server_id in (10001,10002,10003) and role_level >= 10 
--and map_id = '41020001' 
and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume where map_id = '41020001' 
                and server_id in (10001,10002,10003) and log_time >= 1656475200000)
and recovery_method in ('4','5','6','13','14','15','17','19','20','22','23','27','28','29','67','71','72','75','77','78','80','83','88','90','91','93',
                        '94','97','101','108','111','116','118','119','127','135','139')
and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1656795600000)
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
        where map_id = '41020001'
        and server_id in (10001,10002,10003) and role_level >= 10 and log_time >= 1656475200000
        and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1656795600000)
        
        union all 

        SELECT role_id,consume_physical_count as physical_consume from fairy_town_server.server_hunt
        where map_id = '41020001'
        and server_id in (10001,10002,10003) and role_level >= 10 and log_time >= 1656475200000
        and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1656795600000)
        ) as a
        group by 1
        order by 1) as a
        left join
        -- 免费体力获得
        (SELECT role_id,sum(recovery_count) as recovery_count from fairy_town_server.server_physical_recovery
        where log_time >= 1656475200000 and log_time <= 1656795600000
        and server_id in (10001,10002,10003) and role_level >= 10
        and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume where map_id = '41020001'
                        and server_id in (10001,10002,10003) and log_time >= 1656475200000)
        and recovery_method in ('4','5','6','13','14','15','17','19','20','22','23','27','28','29','67','71','72','75','77','78','80','83','88','90','91','93',
                        '94','97','101','108','111','116','118','119','127','135','139')
        and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1656795600000)
        group by 1 order by 1) as b
        on a.role_id = b.role_id
        ) as aa
        where role_id in (SELECT DISTINCT role_id FROM fairy_town_server.server_task_completed   -- 通关
                          where server_id IN (10001,10002,10003) and log_time >= 1656475200000 and task_group_id = '310910')
) bb





活动钻石总消耗(√)
SELECT day_time,sum(consume_count) from fairy_town_server.server_gem_consume
where map_id = '41020001'
and server_id in (10001,10002,10003) and role_level >= 10
and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1656795600000)
GROUP BY 1 ORDER BY 1

免费钻石获得(√)
SELECT day_time,sum(recovery_count) from fairy_town_server.server_gem_recovery
where log_time >= 1656475200000 and log_time <= 1656795600000 
--and map_id = '41020001'
and server_id in (10001,10002,10003) and role_level >= 10
and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume where map_id = '41020001' and server_id in (10001,10002,10003))
and recovery_method in ('4','5','6','13','14','15','17','19','20','22','23','27','28','29','67','71','72','75','77','78','80','83','88','90','91','93',
                        '94','97','101','108','111','116','118','119','127','135','139')
and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1656795600000)
group by 1 order by 1




通关用户 (√) ****************************************(√)
SELECT count(DISTINCT a.role_id)
from
(SELECT role_id FROM fairy_town_server.server_task_completed
where server_id IN (10001,10002,10003) and log_time >= 1656475200000 and task_group_id = '310910') as a 


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
      and log_time >= 1656475200000
      AND task_group_id IN ('1007001','1007002','1007003','1007004','1007005','1007006','1007007','1007008',
                            '1007009','1007010','1007011','1007012','1007013','1007014','1007015','1007016',
                            '1007017','1007018','1007019','1007020','1007021')
      and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume 
          where map_id = '41020001' 
          and server_id in (10001,10002,10003) and log_time >= 1656475200000)
    group by 1
    ) a
left join
    (SELECT
        task_id as task_id,
        count(distinct role_id) as task_group_id_num
    FROM fairy_town_server.server_task_completed
    WHERE server_id IN (10001,10002,10003)
      and log_time >= 1656475200000
      AND task_group_id IN ('1007001','1007002','1007003','1007004','1007005','1007006','1007007','1007008',
                            '1007009','1007010','1007011','1007012','1007013','1007014','1007015','1007016',
                            '1007017','1007018','1007019','1007020','1007021')
      and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume 
          where map_id = '41020001' 
          and server_id in (10001,10002,10003) and log_time >= 1656475200000)
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
      and log_time >= 1656475200000
      AND task_id IN ('3109011','3109021','3109022','3109023','3109031','3109041','3109051',
                      '3109061','3109071','3109081','3109091','3109101','3109102','3109103')
      and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume 
          where map_id = '41020001'  and server_id in (10001,10002,10003) and log_time >= 1656475200000)
    group by 1
    ) a
left join
    (SELECT
        task_id as task_id,
        count(distinct role_id) as task_group_id_num
    FROM fairy_town_server.server_task_completed
    WHERE server_id IN (10001,10002,10003)
      and log_time >= 1656475200000
      AND task_id IN ('3109011','3109021','3109022','3109023','3109031','3109041','3109051',
                      '3109061','3109071','3109081','3109091','3109101','3109102','3109103')
      and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume 
          where map_id = '41020001'  and server_id in (10001,10002,10003) and log_time >= 1656475200000)
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
    case when building_id in ('4009034','4009035') then '树果帐篷'
    end as '装饰物'
from 
(SELECT 
    building_id,
    role_id
FROM 
    fairy_town_server.server_building_get
WHERE building_id in ('4009034','4009035') 
      and server_id in (10001,10002,10003)
      and log_time >= 1656475200000
) as aa
) as bb
group by 1




活动评价数据   ****************************************(√)
SELECT 
    role_id,
    scores
FROM fairy_town_server.server_event_rate
where role_id in (select distinct role_id from fairy_town_server.server_physical_consume 
                  where map_id = '41020001' 
                  and server_id in (10001,10002,10003) and day_time >= 20220629 and day_time <= 20220703)
      and activity_id = 25
group by 1,2




活动礼包购买行为 体力+炸弹 *************************************** (√) 
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
where game_product_id in ('com.managames.fairytown.iap_3.99ve','com.managames.fairytown.iap_9.99ve','com.managames.fairytown.iap_19.99ve',
                          'com.managames.fairytown.iap_4.99vb','com.managames.fairytown.iap_9.99vb','com.managames.fairytown.iap_19.99vb')
and server_id in (10001,10002,10003) and day_time >= 20220629 and day_time <= 20220703
union all
SELECT day_time,game_product_id,pay_price
FROM 
    fairy_town_tw.order_pay
where game_product_id in ('com.managames.fairytown.iap_3.99ve','com.managames.fairytown.iap_9.99ve','com.managames.fairytown.iap_19.99ve',
                          'com.managames.fairytown.iap_4.99vb','com.managames.fairytown.iap_9.99vb','com.managames.fairytown.iap_19.99vb')
and server_id in (10001,10002,10003) and day_time >= 20220629 and day_time <= 20220703
) as a
GROUP BY 1,2
ORDER BY 1,2



# 活动收入
—————————————————————————————— 参与 ——————————————————————————————(√) 
********************************************************************************

活跃人数
新用户
SELECT count(DISTINCT role_id) FROM fairy_town_server.server_activity_triggered WHERE server_id IN (10001,10002,10003) AND activity_id = 25
AND log_time >= 1656475200000 and log_time <= 1656795600000
AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time >= 1656475200000 and log_time <= 1656795600000) 
and role_id in (select distinct role_id from fairy_town_server.server_physical_consume 
                where map_id = '41020001'
                and consume_count>0 and server_id in (10001,10002,10003) and log_time >= 1656475200000)

老用户
SELECT count(DISTINCT role_id) FROM fairy_town_server.server_activity_triggered WHERE server_id IN (10001,10002,10003) AND activity_id = 25
AND log_time >= 1656475200000 and log_time <= 1656795600000
AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time < 1656475200000)
and role_id in (select distinct role_id from fairy_town_server.server_physical_consume 
                where map_id = '41020001'
                and consume_count>0 and server_id in (10001,10002,10003) and log_time >= 1656475200000)




当期充值人数
新用户
SELECT count(DISTINCT role_id)
FROM fairy_town.order_pay
WHERE server_id IN (10001,10002,10003)
  AND log_time >= 1656475200000 and log_time <= 1656795600000
  AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time >= 1656475200000 and log_time <= 1656795600000)
  and role_id in (SELECT DISTINCT role_id FROM fairy_town_server.server_activity_triggered WHERE server_id IN (10001,10002,10003) AND activity_id = 25 AND log_time >= 1656475200000)
  and role_id in (select distinct role_id from fairy_town_server.server_physical_consume 
                  where map_id = '41020001'
                  and consume_count>0 and server_id in (10001,10002,10003) and log_time >= 1656475200000)
  and product_name <> '战令'


老用户
SELECT count(DISTINCT role_id)
FROM fairy_town.order_pay
WHERE server_id IN (10001,10002,10003)
  AND log_time >= 1656475200000 and log_time <= 1656795600000
  AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time < 1656475200000)
  and role_id in (SELECT DISTINCT role_id FROM fairy_town_server.server_activity_triggered WHERE server_id IN (10001,10002,10003) AND activity_id = 25 AND log_time >= 1656475200000)
  and role_id in (select distinct role_id from fairy_town_server.server_physical_consume 
                  where map_id = '41020001' 
                  and consume_count>0 and server_id in (10001,10002,10003) and log_time >= 1656475200000)
  and product_name <> '战令'





当期充值金额
新用户
SELECT sum(pay_price)
    FROM fairy_town.order_pay
WHERE server_id IN (10001,10002,10003)
  AND log_time >= 1656475200000 and log_time <= 1656795600000
  AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time >= 1656475200000 and log_time <= 1656795600000)
  and role_id in (SELECT DISTINCT role_id FROM fairy_town_server.server_activity_triggered WHERE server_id IN (10001,10002,10003) AND activity_id = 25 AND log_time >= 1656475200000)
  and role_id in (select distinct role_id from fairy_town_server.server_physical_consume 
                  where map_id = '41020001' 
                  and consume_count>0 and server_id in (10001,10002,10003) and log_time >= 1656475200000)
  and product_name <> '战令'


老用户
SELECT sum(pay_price)
    FROM fairy_town.order_pay
WHERE server_id IN (10001,10002,10003)
  AND log_time >= 1656475200000 and log_time <= 1656795600000
  AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time < 1656475200000)
  and role_id in (SELECT DISTINCT role_id FROM fairy_town_server.server_activity_triggered WHERE server_id IN (10001,10002,10003) AND activity_id = 25 AND log_time >= 1656475200000)
  and role_id in (select distinct role_id from fairy_town_server.server_physical_consume 
                  where map_id = '41020001' 
                  and consume_count>0 and server_id in (10001,10002,10003) and log_time >= 1656475200000)
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
        day_time >= 20220625 and day_time <= 20220703
        and server_id IN (10001,10002,10003)
        and role_id in
        (SELECT
            distinct role_id
         FROM fairy_town_server.server_physical_consume 
         where map_id = '41020001' 
         and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1656475200000)
    group by 1,2

    union all

    select
        day_time,
        role_id,
        count(role_id) as cishu
    from
        fairy_town_tw.server_role_login
    where 
        day_time >= 20220625 and day_time <= 20220703
        and server_id IN (10001,10002,10003)
        and role_id in
        (SELECT
            distinct role_id
         FROM fairy_town_server_tw.server_physical_consume 
         where map_id = '41020001' 
         and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1656475200000)
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
        day_time >= 20220625 and day_time <= 20220703
        and server_id IN (10001,10002,10003)
        and role_id in
        (SELECT
            distinct role_id
         FROM fairy_town_server.server_physical_consume 
         where map_id = '41020001' 
         and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1656475200000
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
        day_time >= 20220625 and day_time <= 20220703
        and server_id IN (10001,10002,10003)
        and role_id in
        (SELECT
            distinct role_id
         FROM fairy_town_server_tw.server_physical_consume 
         where map_id = '41020001' 
         and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1656475200000
        )
    group by 1,2
) a
group by day_time
order by day_time




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
                where map_id = '41020001' 
                and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1656475200000)
union all
select day_time,physical,gold,gem,bomb
from fairy_town_server_tw.server_login_snap_shot 
where day_time >= ${start_time} and day_time <= ${end_time}
and server_id in (10001,10002,10003)
and role_id in (SELECT distinct role_id FROM fairy_town_server_tw.server_physical_consume 
                where map_id = '41020001' 
                and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1656475200000)
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
                where map_id = '41020001' 
                and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1656475200000)
union all
select day_time,role_id,phy_items
from fairy_town_server_tw.server_login_snap_shot 
where day_time >= ${start_time} and day_time <= ${end_time}
and server_id in (10001,10002,10003)
and role_id in (SELECT distinct role_id FROM fairy_town_server_tw.server_physical_consume 
                where map_id = '41020001' 
                and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1656475200000)
) as a
group by 1,2,3
order by 1





排行榜 1656475200000   1656795600000
SELECT c.role_id,change_sum as '积分数量',activity_group_id as '小组',physical_sum as '活动体力总消耗', 
recovery_count as '免费体力获得',(physical_sum - recovery_count) as '体力净消耗',country as '注册国家',paysum as '历史总付费',pay_2 as '当期付费'   
from

(SELECT role_id,sum(physical_consume) as physical_sum   -- 活动体力总消耗
from
(SELECT role_id,consume_count as physical_consume from fairy_town_server.server_physical_consume   -- 采集
where map_id = '41020001'
and server_id in (10001,10002,10003) and log_time >= 1656475200000

union all 

SELECT role_id,consume_physical_count as physical_consume from fairy_town_server.server_hunt       -- 打猎
where map_id = '41020001'
and server_id in (10001,10002,10003) and log_time >= 1656475200000
) a
group by 1
order by 1) as c

left join
(SELECT role_id,country, sum(change_count) as change_sum from fairy_town.server_prop 
where prop_id = '310808' and change_type = 'PRODUCE' and day_time >= 20220629 and day_time <= 20220703 group by 1,2) as a
on c.role_id = a.role_id

left join
(SELECT role_id,activity_group_id from fairy_town_server.server_activity_group WHERE activity_id = 25 GROUP BY 1,2) as b
on c.role_id = b.role_id

left join
(SELECT role_id,sum(recovery_count) as recovery_count  from fairy_town_server.server_physical_recovery
where log_time >= 1656475200000 and log_time <= 1656795600000
and server_id in (10001,10002,10003) and role_level >= 10  
and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume 
                where map_id = '41020001'
                and server_id in (10001,10002,10003) and log_time >= 1656475200000)
and recovery_method in ('4','5','6','13','14','15','17','19','20','22','23','27','28','29','67','71','72','75','77','78','80','83','88','90','91','93',
                        '94','97','101','108','111','116','118','119','127','135','139')

group by 1 order by 1) as d
on c.role_id = d.role_id
left join 
(select role_id,sum(pay_price) as paysum from fairy_town.order_pay where log_time <=1656795600000  group by 1) as f 
on c.role_id = f.role_id
left join 
(select role_id,sum(pay_price) as pay_2 from fairy_town.order_pay where day_time >= 20220629 and day_time <= 20220703 group by 1) as g 
on c.role_id = g.role_id

GROUP BY 1,2,3,4,5,6,7,8,9







SELECT c.role_id,change_sum as '积分数量',activity_group_id as '小组',physical_sum as '活动体力总消耗', 
recovery_count as '免费体力获得',(physical_sum - recovery_count) as '体力净消耗',country as '注册国家',paysum as '历史总付费',pay_2 as '当期付费'   
from

(SELECT role_id,sum(physical_consume) as physical_sum   -- 活动体力总消耗
from
(SELECT role_id,consume_count as physical_consume from fairy_town_server_tw.server_physical_consume   -- 采集
where map_id = '41020001'
and server_id in (10001,10002,10003) and log_time >= 1656475200000

union all 

SELECT role_id,consume_physical_count as physical_consume from fairy_town_server_tw.server_hunt       -- 打猎
where map_id = '41020001'
and server_id in (10001,10002,10003) and log_time >= 1656475200000
) a
group by 1
order by 1) as c

left join
(SELECT role_id,country, sum(change_count) as change_sum from fairy_town_tw.server_prop 
where prop_id = '310808' and change_type = 'PRODUCE' and day_time >= 20220629 and day_time <= 20220703 group by 1,2) as a
on c.role_id = a.role_id

left join
(SELECT role_id,activity_group_id from fairy_town_server_tw.server_activity_group WHERE activity_id = 25 GROUP BY 1,2) as b
on c.role_id = b.role_id

left join
(SELECT role_id,sum(recovery_count) as recovery_count  from fairy_town_server_tw.server_physical_recovery
where log_time >= 1656475200000 and log_time <= 1656795600000
and server_id in (10001,10002,10003) and role_level >= 10  
and role_id in (SELECT distinct role_id FROM fairy_town_server_tw.server_physical_consume 
                where map_id = '41020001'
                and server_id in (10001,10002,10003) and log_time >= 1656475200000)
and recovery_method in ('4','5','6','13','14','15','17','19','20','22','23','27','28','29','67','71','72','75','77','78','80','83','88','90','91','93',
                        '94','97','101','108','111','116','118','119','127','135','139')

group by 1 order by 1) as d
on c.role_id = d.role_id
left join 
(select role_id,sum(pay_price) as paysum from fairy_town_tw.order_pay where log_time <=1656795600000  group by 1) as f 
on c.role_id = f.role_id
left join 
(select role_id,sum(pay_price) as pay_2 from fairy_town_tw.order_pay where day_time >= 20220629 and day_time <= 20220703 group by 1) as g 
on c.role_id = g.role_id

GROUP BY 1,2,3,4,5,6,7,8,9

