-- 一、活动数据概览
# 1、活动参与率 总参与率 (√)
SELECT
    a.act_num as '活动参与人数',
    b.num as '总参与人数',
	a.act_num / b.num as `总参与率`                          
FROM
	(SELECT
	    count(distinct role_id) as act_num
	FROM 
	    fairy_town_server.server_physical_consume 
	where map_id = '30010001' and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1639081800000 and log_time <= 1639681200000
    ) a,
	(SELECT
        count(distinct role_id) as num
    FROM
        fairy_town_server.server_task_accept
    where task_id = '3001011' and server_id in (10001,10002,10003) and log_time >= 1639081800000 and log_time <= 1639681200000) b -- 接取活动任务的人数

# 活动弹窗  id= 8  相当于接取任务人数
SELECT count(DISTINCT role_id)
FROM fairy_town_server.server_activity_triggered
WHERE server_id IN (10001,
                    10002,
                    10003)
  AND activity_id = 8
  AND log_time >= 1639081800000
  AND log_time <= 1639681200000



# 进入地图人数
select
    count(distinct role_id)
from 
    fairy_town_server.server_map_enter
where map_id = '30010001' and server_id in (10001,10002,10003) and log_time >= 1639081800000 and log_time <= 1639681200000



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
    where map_id = '30010001' and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1639081800000 and log_time <= 1639681200000
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
             where map_id = '30010001' and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1639081800000 and log_time <= 1639681200000
             )   
         union all
             (
             SELECT
                 role_id,
                 date_time
             from 
                 fairy_town.server_role_login
             WHERE role_level >= 10 and server_id in (10001,10002,10003) and log_time >= 1639081800000 and log_time <= 1639681200000
             )
        ) c
    group by 1
    ) as b
where a.birth_dt = b.birth_dt
order by day_dt


-- # 2、活动参与深度 整体用户按天体力总消耗（采集消耗 + 转动消耗 + 打猎 = 活动消耗 ）(√)
SELECT
    day_time
    ,sum(consume_count) as consume_count_sum
FROM
    (
    (SELECT
    day_time,
    sum(consume_count) as consume_count
    FROM
        fairy_town_server.server_physical_consume
    where map_id = '30010001' and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1639081800000
    GROUP BY 1
    ORDER BY 1
    ) 
    union all
    (SELECT day_time,sum(consume_count) as consume_count
     from fairy_town_server.server_stone_pillar_turn
     where map_id = '30010001' and log_time >= 1639081800000 and server_id in (10001,10002,10003)
     GROUP BY 1
     ORDER BY 1 
    )
    union all
    (SELECT day_time,sum(consume_physical_count) as consume_count
    FROM fairy_town_server.server_hunt 
    where server_id IN (10001,10002,10003)
    AND log_time >= 1639081800000
    and map_id = '30010001'
    GROUP BY 1
    ORDER BY 1    
    )
    ) a
group by 1
order by 1

-- 采集消耗
SELECT
    to_date(cast(date_time as timestamp)) as birth_dt,
    sum(consume_count) as consume_count
FROM
    fairy_town_server.server_physical_consume
where map_id = '30010001' and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1639081800000
GROUP BY birth_dt
ORDER BY birth_dt

-- 转动消耗
SELECT day_time,sum(consume_count) from fairy_town_server.server_stone_pillar_turn
where map_id = '30010001' and log_time >= 1639081800000 and server_id in (10001,10002,10003)
GROUP BY 1
ORDER BY 1

-- 打猎消耗
SELECT day_time,sum(consume_physical_count)
FROM fairy_town_server.server_hunt 
where server_id IN (10001,10002,10003)
AND log_time >= 1639081800000
and map_id = '30010001'
GROUP BY 1
ORDER BY 1


-- 当日总消耗
SELECT day_time,sum(ass)
from
(

(SELECT day_time, -- 采集
       sum(consume_count) as ass
FROM fairy_town_server.server_physical_consume
WHERE server_id IN (10001,10002,10003)
  AND log_time >= 1639081800000
  AND log_time <= 1639681200000
GROUP BY 1
ORDER BY 1)
union all
(SELECT day_time,sum(consume_count) as ass  -- 转动
from fairy_town_server.server_stone_pillar_turn
where log_time >= 1639081800000  AND log_time <= 1639681200000 and server_id in (10001,10002,10003)
GROUP BY 1
ORDER BY 1)
union all
(SELECT day_time,sum(consume_physical_count) as ass -- 打猎
FROM fairy_town_server.server_hunt 
where server_id IN (10001,10002,10003)
AND log_time >= 1639081800000 AND log_time <= 1639681200000
GROUP BY 1
ORDER BY 1)
union all
(SELECT day_time,sum(consume_currency_count) as ass  -- 市场
FROM fairy_town_server.server_market_buy 
where server_id IN (10001,10002,10003)
AND log_time >= 1639081800000 AND log_time <= 1639681200000
and consume_currency_id = '3'
GROUP BY 1
ORDER BY 1)

) s
group by 1
order by 1



role_id in (select distinct role_id from fairy_town.order_pay where server_id in (10001,10002,10003) and day_time <= 20211217)
-- # 活动参与深度 付费用户按天体力总消耗（采集消耗 + 转动消耗）(√)
-- 采集消耗
SELECT
    to_date(cast(date_time as timestamp)) as birth_dt,
    sum(consume_count) as consume_count
FROM
    fairy_town_server.server_physical_consume
where map_id = '30010001' and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1639081800000 
and role_id in (select distinct role_id from fairy_town.order_pay where server_id in (10001,10002,10003) and day_time <= 20211217)
GROUP BY birth_dt
ORDER BY birth_dt

-- 转动消耗
SELECT day_time,sum(consume_count) from fairy_town_server.server_stone_pillar_turn
where map_id = '30010001' and log_time >= 1639081800000
and role_id in (select distinct role_id from fairy_town.order_pay where server_id in (10001,10002,10003) and day_time <= 20211217)
GROUP BY 1
ORDER BY 1

-- 打猎消耗
SELECT day_time,sum(consume_physical_count)
FROM fairy_town_server.server_hunt 
where server_id IN (10001,10002,10003)
AND log_time >= 1639081800000
and map_id = '30010001'
and role_id in (select distinct role_id from fairy_town.order_pay where server_id in (10001,10002,10003) and day_time <= 20211217)
GROUP BY 1
ORDER BY 1


-- 当日总消耗
SELECT day_time,sum(ass)
from
(

(SELECT day_time,
       sum(consume_count) as ass
FROM fairy_town_server.server_physical_consume
WHERE server_id IN (10001,10002,10003)
  AND log_time >= 1639081800000
  AND log_time <= 1639681200000
  and role_id in (select distinct role_id from fairy_town.order_pay where server_id in (10001,10002,10003) and day_time <= 20211217)
GROUP BY 1
ORDER BY 1)
union all
(SELECT day_time,sum(consume_count) as ass
from fairy_town_server.server_stone_pillar_turn
where log_time >= 1639081800000  AND log_time <= 1639681200000 and server_id in (10001,10002,10003)
and role_id in (select distinct role_id from fairy_town.order_pay where server_id in (10001,10002,10003) and day_time <= 20211217)
GROUP BY 1
ORDER BY 1)
union all
(SELECT day_time,sum(consume_physical_count) as ass
FROM fairy_town_server.server_hunt 
where server_id IN (10001,10002,10003)
AND log_time >= 1639081800000 AND log_time <= 1639681200000
and role_id in (select distinct role_id from fairy_town.order_pay where server_id in (10001,10002,10003) and day_time <= 20211217)
GROUP BY 1
ORDER BY 1)
union all
(SELECT day_time,sum(consume_currency_count) as ass
FROM fairy_town_server.server_market_buy 
where server_id IN (10001,10002,10003)
AND log_time >= 1639081800000 AND log_time <= 1639681200000
and role_id in (select distinct role_id from fairy_town.order_pay where server_id in (10001,10002,10003) and day_time <= 20211217)
and consume_currency_id = '3'
GROUP BY 1
ORDER BY 1)

) s
group by 1
order by 1



SELECT
    count(case when consume_count_sum >=0 and consume_count_sum <= 99 then role_id else null end) as '0-99'
    ,count(case when consume_count_sum >=100 and consume_count_sum <= 199 then role_id else null end) as '100-199'
    ,count(case when consume_count_sum >=200 and consume_count_sum <= 299 then role_id else null end) as '200-299'
    ,count(case when consume_count_sum >=300 and consume_count_sum <= 399 then role_id else null end) as '300-399'
    ,count(case when consume_count_sum >=400 and consume_count_sum <= 499 then role_id else null end) as '400-499'
    ,count(case when consume_count_sum >=500 and consume_count_sum <= 599 then role_id else null end) as '500-599'
    ,count(case when consume_count_sum >=600 and consume_count_sum <= 699 then role_id else null end) as '600-699'
    ,count(case when consume_count_sum >=700 and consume_count_sum <= 799 then role_id else null end) as '700-799'
    ,count(case when consume_count_sum >=800 and consume_count_sum <= 899 then role_id else null end) as '800-899'
    ,count(case when consume_count_sum >=900 and consume_count_sum <= 999 then role_id else null end) as '900-999'
    ,count(case when consume_count_sum >=1000 and consume_count_sum <= 1099 then role_id else null end) as '1000-1099'
    ,count(case when consume_count_sum >=1100 and consume_count_sum <= 1199 then role_id else null end) as '1100-1199'
    ,count(case when consume_count_sum >=1200 and consume_count_sum <= 1299 then role_id else null end) as '1200-1299'
    ,count(case when consume_count_sum >=1300 and consume_count_sum <= 1399 then role_id else null end) as '1300-1399'
    ,count(case when consume_count_sum >=1400 and consume_count_sum <= 1499 then role_id else null end) as '1400-1499'
    ,count(case when consume_count_sum >=1500 and consume_count_sum <= 1999 then role_id else null end) as '1500-1999'
    ,count(case when consume_count_sum >=2000 and consume_count_sum <= 2499 then role_id else null end) as '2000-2499'
    ,count(case when consume_count_sum >=2500 and consume_count_sum <= 2999 then role_id else null end) as '2500-2999'
    ,count(case when consume_count_sum >=3000 and consume_count_sum <= 3499 then role_id else null end) as '3000-3499'
    ,count(case when consume_count_sum >=3500 and consume_count_sum <= 3999 then role_id else null end) as '3500-3999'
    ,count(case when consume_count_sum >=4000 and consume_count_sum <= 4499 then role_id else null end) as '4000-4499'
    ,count(case when consume_count_sum >=4500 and consume_count_sum <= 4999 then role_id else null end) as '4500-4999'
    ,count(case when consume_count_sum >=5000 and consume_count_sum <= 5499 then role_id else null end) as '5000-5499'
    ,count(case when consume_count_sum >=5500 and consume_count_sum <= 5999 then role_id else null end) as '5500-5999'
    ,count(case when consume_count_sum >=6000 and consume_count_sum <= 6499 then role_id else null end) as '6000-6499'
    ,count(case when consume_count_sum >=6500 and consume_count_sum <= 6999 then role_id else null end) as '6500-6999'
    ,count(case when consume_count_sum >=7000 and consume_count_sum <= 7499 then role_id else null end) as '7000-7499'
    ,count(case when consume_count_sum >=7500 and consume_count_sum <= 7999 then role_id else null end) as '7500-7999'
    ,count(case when consume_count_sum >=8000 and consume_count_sum <= 8499 then role_id else null end) as '8000-8499'
    ,count(case when consume_count_sum >=8500 and consume_count_sum <= 8999 then role_id else null end) as '8500-8999'
    ,count(case when consume_count_sum >=9000 and consume_count_sum <= 9499 then role_id else null end) as '9000-9499'
    ,count(case when consume_count_sum >=9500 and consume_count_sum <= 9999 then role_id else null end) as '9500-9999'
    ,count(case when consume_count_sum >=10000 then role_id else null end) as '10000+'
from
    (SELECT
        role_id
        ,sum(consume_count) as consume_count_sum
    FROM
        (
        (SELECT   -- 采集
            role_id,
            sum(consume_count) as consume_count
        FROM
            fairy_town_server.server_physical_consume
        where map_id = '30010001' and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1639081800000
        GROUP BY 1
        ) 
        union all
        (
        SELECT  -- 转动
            role_id
            ,sum(consume_count) as consume_count
        from fairy_town_server.server_stone_pillar_turn
        where map_id = '30010001' and log_time >= 1639081800000 and server_id in (10001,10002,10003)
        GROUP BY 1
        )
        union all
        (SELECT   -- 打猎
            role_id
            ,sum(consume_physical_count) as consume_count
        FROM fairy_town_server.server_hunt 
        where server_id IN (10001,10002,10003)
        AND log_time >= 1639081800000
        and map_id = '30010001'
        GROUP BY 1
        )

        ) a
    group by 1
    ) b



-- 分天 整体用户平均值 中位数 (√)
SELECT
    birth_dt,
    avg(consume_count_sum) as consume_count_avg,
    appx_median(consume_count_sum) as consume_count_median
from
    (SELECT
        birth_dt
        ,sum(case when consume_count > 0 then consume_count else NULL end) as consume_count_sum
    FROM
    (
        (SELECT
            role_id,
            to_date(cast(date_time as timestamp)) as birth_dt
            ,consume_count
        FROM
            fairy_town_server.server_physical_consume
        where map_id = '30010001' and server_id in (10001,10002,10003) and log_time >= 1639081800000
        ) 
        union all
        (
        SELECT  -- 转动
            role_id,
            to_date(cast(date_time as timestamp)) as birth_dt
            ,consume_count
        from fairy_town_server.server_stone_pillar_turn
        where map_id = '30010001' and server_id in (10001,10002,10003) and log_time >= 1639081800000
        )
        union all
        (SELECT   -- 打猎
            role_id,
            to_date(cast(date_time as timestamp)) as birth_dt
            ,consume_physical_count as consume_count
        FROM fairy_town_server.server_hunt 
        where server_id IN (10001,10002,10003)
        AND log_time >= 1639081800000
        and map_id = '30010001'
        )
    ) a
    group by role_id,birth_dt
    ) b
group by birth_dt
order by birth_dt



-- 分位数  (√)
SELECT
    role_id
    ,sum(case c.consume_count when c.consume_count is null then 0 else c.consume_count end) consume_count1
FROM
(
    (SELECT -- 采集
        role_id,
        consume_count as consume_count
    FROM
        fairy_town_server.server_physical_consume
    where map_id = '30010001' and server_id in (10001,10002,10003) and log_time >= 1639081800000
    )
    union all
    (
    SELECT  -- 转动
        role_id
        ,consume_count as consume_count
    from fairy_town_server.server_stone_pillar_turn
    where map_id = '30010001' and server_id in (10001,10002,10003) and log_time >= 1639081800000
    )
    union all
    (SELECT   -- 打猎
        role_id
        ,consume_physical_count as consume_count
    FROM fairy_town_server.server_hunt 
    where server_id IN (10001,10002,10003)
    AND log_time >= 1639081800000
    and map_id = '30010001'
    )
) c
group by 1




-- 通关用户平均值(完成最后一个任务的用户  为通关用户) (√)
SELECT
    role_id
    ,sum(case c.consume_count when c.consume_count is null then 0 else c.consume_count end) consume_count1
FROM
(
    (SELECT  -- 采集
        role_id,
        consume_count as consume_count
    FROM
        fairy_town_server.server_physical_consume
    where map_id = '30010001' and server_id in (10001,10002,10003) and log_time >= 1639081800000
          and role_id in (SELECT
                                role_id
                            FROM
                                fairy_town_server.server_task_completed
                            where server_id IN (10001,10002,10003)
                                  and log_time >= 1639081800000 and log_time <= 1639681200000
                                  and task_id = '3001471' -- 完成最后一个任务
                         )
    )
    union all
    (
    SELECT  -- 转动
        role_id
        ,consume_count as consume_count
    from fairy_town_server.server_stone_pillar_turn
    where map_id = '30010001' and server_id in (10001,10002,10003) and log_time >= 1639081800000
    and role_id in (SELECT
                                role_id
                            FROM
                                fairy_town_server.server_task_completed
                            where server_id IN (10001,10002,10003)
                                  and log_time >= 1639081800000 and log_time <= 1639681200000
                                  and task_id = '3001471' -- 完成最后一个任务
                    )
    )
    union all
    (SELECT   -- 打猎
        role_id
        ,consume_physical_count as consume_count
    FROM fairy_town_server.server_hunt 
    where server_id IN (10001,10002,10003)
    AND log_time >= 1639081800000
    and map_id = '30010001'
    and role_id in (SELECT
                                role_id
                            FROM
                                fairy_town_server.server_task_completed
                            where server_id IN (10001,10002,10003)
                                  and log_time >= 1639081800000 and log_time <= 1639681200000
                                  and task_id = '3001471' -- 完成最后一个任务
                    )
    )
) c
group by role_id
order by role_id



-- 通关用户 (√)
SELECT
    day_time,
    count(distinct role_id)
FROM
    fairy_town_server.server_task_completed
where server_id IN (10001,10002,10003)
      and log_time >= 1639081800000 and log_time <= 1639681200000
      and task_id = '3001471' -- 完成最后一个任务
group by 1
order by 1


-- 通关用户体力消耗  每天
-- 采集消耗
SELECT
    to_date(cast(date_time as timestamp)) as birth_dt,
    sum(consume_count) as consume_count
FROM
    fairy_town_server.server_physical_consume
where map_id = '30010001' and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1639081800000
and role_id in (SELECT
                    distinct role_id
                FROM
                    fairy_town_server.server_task_completed
                where server_id IN (10001,10002,10003)
                      and log_time >= 1639081800000 and log_time <= 1639681200000
                      and task_id = '3001471' )
GROUP BY 1
ORDER BY 1

-- 转动消耗
SELECT day_time,sum(consume_count) from fairy_town_server.server_stone_pillar_turn
where map_id = '30010001' and log_time >= 1639081800000
and role_id in (SELECT
                    distinct role_id
                FROM
                    fairy_town_server.server_task_completed
                where server_id IN (10001,10002,10003)
                      and log_time >= 1639081800000 and log_time <= 1639681200000
                      and task_id = '3001471' )
GROUP BY 1
ORDER BY 1

-- 打猎消耗
SELECT day_time,sum(consume_physical_count)
FROM fairy_town_server.server_hunt 
where server_id IN (10001,10002,10003)
AND log_time >= 1639081800000
and map_id = '30010001'
and role_id in (SELECT
                    distinct role_id
                FROM
                    fairy_town_server.server_task_completed
                where server_id IN (10001,10002,10003)
                      and log_time >= 1639081800000 and log_time <= 1639681200000
                      and task_id = '3001471')
GROUP BY 1
ORDER BY 1



-- 整体、通关用户炸弹使用
select a.role_id,b.bomb_num
from
(SELECT
distinct role_id
FROM
fairy_town_server.server_task_completed
where server_id IN (10001,10002,10003)
and log_time >= 1639081800000 and log_time <= 1639681200000
and task_id = '3001471') a
left join
(SELECT   -- 通关
    role_id,
    count(bomb_id) as bomb_num
FROM fairy_town_server.server_bomb_consume
WHERE map_id = '30010001'
  AND server_id IN (10001,10002,10003)
  AND log_time >= 1639081800000
  AND log_time <= 1639681200000
GROUP BY 1) b
on a.role_id = b.role_id


select a.role_id,b.bomb_num
from
(SELECT
  distinct role_id
FROM 
  fairy_town_server.server_physical_consume 
where map_id = '30010001' and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1639081800000 and log_time <= 1639681200000
) a
left join
(SELECT   -- 整体
    role_id,
    count(bomb_id) as bomb_num
FROM fairy_town_server.server_bomb_consume
WHERE map_id = '30010001'
  AND server_id IN (10001,10002,10003)
  AND log_time >= 1639081800000
  AND log_time <= 1639681200000
GROUP BY 1) b
on a.role_id = b.role_id




-- 任务   (√)
任务组
SELECT
    a.task_group_id as task_group_id,
    a.task_group_id_num as '接取角色数',
    b.task_group_id_num as '完成角色数',
    b.task_group_id_num / a.task_group_id_num as '任务组完成率'
FROM
    (SELECT
        task_group_id as task_group_id,
        count(distinct role_id) as task_group_id_num
    FROM fairy_town_server.server_task_accept
    WHERE server_id IN (10001,10002,10003)
      and log_time >= 1639081800000 and log_time <= 1639681200000
      AND task_group_id IN ('300101','300102','300103','300104','300105','300106','300107','300108','300109','300110','300111','300112','300113','300114',
        '300115','300116','300117','300118','300119','300120','300121','300122','300123','300124','300125','300126','300127','300128','300129','300130','300131','300132',
        '300133','300134','300135','300136','300137','300138','300139','300140','300141','300142','300143','300144','300145','300146','300147')
      and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume 
          where map_id = '30010001' and server_id in (10001,10002,10003) and log_time >= 1639081800000 and log_time <= 1639681200000)
    group by 1
    ) a
left join
    (SELECT
        task_group_id as task_group_id,
        count(distinct role_id) as task_group_id_num
    FROM fairy_town_server.server_task_completed
    WHERE server_id IN (10001,10002,10003)
      and log_time >= 1639081800000 and log_time <= 1639681200000
      AND task_group_id IN ('300101','300102','300103','300104','300105','300106','300107','300108','300109','300110','300111','300112','300113','300114',
        '300115','300116','300117','300118','300119','300120','300121','300122','300123','300124','300125','300126','300127','300128','300129','300130','300131','300132',
        '300133','300134','300135','300136','300137','300138','300139','300140','300141','300142','300143','300144','300145','300146','300147')
      and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume 
          where map_id = '30010001' and server_id in (10001,10002,10003) and log_time >= 1639081800000 and log_time <= 1639681200000)
    group by 1
    ) b
on a.task_group_id = b.task_group_id
order by 1




任务
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
      and log_time >= 1639081800000 and log_time <= 1639681200000
      AND task_group_id IN ('300101','300102','300103','300104','300105','300106','300107','300108','300109','300110','300111','300112','300113','300114',
        '300115','300116','300117','300118','300119','300120','300121','300122','300123','300124','300125','300126','300127','300128','300129','300130','300131','300132',
        '300133','300134','300135','300136','300137','300138','300139','300140','300141','300142','300143','300144','300145','300146','300147')
      and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume 
          where map_id = '30010001' and server_id in (10001,10002,10003) and log_time >= 1639081800000 and log_time <= 1639681200000)
    group by 1
    ) a
left join
    (SELECT
        task_id as task_id,
        count(distinct role_id) as task_group_id_num
    FROM fairy_town_server.server_task_completed
    WHERE server_id IN (10001,10002,10003)
      and log_time >= 1639081800000 and log_time <= 1639681200000
      AND task_group_id IN ('300101','300102','300103','300104','300105','300106','300107','300108','300109','300110','300111','300112','300113','300114',
        '300115','300116','300117','300118','300119','300120','300121','300122','300123','300124','300125','300126','300127','300128','300129','300130','300131','300132',
        '300133','300134','300135','300136','300137','300138','300139','300140','300141','300142','300143','300144','300145','300146','300147')
      and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume 
          where map_id = '30010001' and server_id in (10001,10002,10003) and log_time >= 1639081800000 and log_time <= 1639681200000)
    group by 1
    ) b
on a.task_id = b.task_id
order by  1




# 活动奖励领取情况   (√)
SELECT 
    building_id,
    count(distinct role_id) as num
FROM 
    fairy_town_server.server_building_get
WHERE building_id in ('4002173','4002174','4002177','4002179') 
      and server_id in (10001,10002,10003)
      and log_time >= 1639081800000 and log_time <= 1639681200000
GROUP BY 1
order by 1



# 水果塔 （√）
select nums,count(distinct role_id) from
(select role_id,count(1) as nums
from fairy_town_server.server_building_complete
where log_time >= 1639081800000 and log_time <= 1639681200000
and server_id in (10001,10002,10003)
and building_id ='4002156'
group by 1) a 
group by 1



# 活动评价数据   (√)
SELECT 
    DISTINCT role_id,
    scores
FROM fairy_town_server.server_event_rate
where role_id in (select distinct role_id from fairy_town_server.server_physical_consume 
                  where map_id = '30010001' and server_id in (10001,10002,10003) and log_time >= 1639081800000 and log_time <= 1639681200000)
      and activity_id = 8


# 活动礼包购买行为  (√)
SELECT 
    day_time,
    game_product_id,
    count(game_product_id) as `购买数量`,
    sum(pay_price) as `流水`
FROM 
    fairy_town.order_pay
where game_product_id in ('com.managames.fairytown.iap_4.99veg','com.managames.fairytown.iap_14.99veg','com.managames.fairytown.iap_29.99veg',
'com.managames.fairytown.iap_3.99ve','com.managames.fairytown.iap_9.99ve','com.managames.fairytown.iap_19.99ve')
and server_id in (10001,10002,10003) and day_time >= 20211209 and day_time <= 20211217
GROUP BY 1,2
ORDER BY 1,2


-- 挖矿
SELECT 
    day_time
    ,role_id
    ,resource_id
FROM 
    fairy_town_server.server_map_resource_mission_complete
WHERE 
    map_id = '30010001' 
    and server_id in (10001,10002,10003)
    and log_time >= 1639081800000 and log_time <= 1639681200000






# 活动收入
—————————————————————————————— 没参与  12.9 开始 ——————————————————————————————



SELECT count(DISTINCT role_id) FROM fairy_town_server.server_activity_triggered WHERE server_id IN (10001,10002,10003) AND activity_id in (7,8)
AND log_time >= 1639022400000 AND log_time <= 1639681200000
AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time >= 1639022400000 and log_time <= 1639681200000) 
and role_id in (select distinct role_id from fairy_town_server.server_physical_consume where map_id = '30010001' and consume_count>0 
                  and server_id in (10001,10002,10003) and log_time >= 1639022400000 and log_time <= 1639681200000)

-- 老
SELECT count(DISTINCT role_id) FROM fairy_town_server.server_activity_triggered WHERE server_id IN (10001,10002,10003) AND activity_id in (7,8)
AND log_time >= 1639022400000 AND log_time <= 1639681200000
AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time < 1639022400000)
and role_id in (select distinct role_id from fairy_town_server.server_physical_consume where map_id = '30010001' and consume_count>0 
                  and server_id in (10001,10002,10003) and log_time >= 1639022400000 and log_time <= 1639681200000)



SELECT count(DISTINCT role_id)
FROM fairy_town.order_pay
WHERE server_id IN (10001,10002,10003)
  AND log_time >= 1639022400000 and log_time <= 1639681200000
  AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time >= 1639022400000 and log_time <= 1639681200000)
  and role_id in (SELECT DISTINCT role_id FROM fairy_town_server.server_activity_triggered WHERE server_id IN (10001,10002,10003) AND activity_id in (7,8)
                AND log_time >= 1639022400000 AND log_time <= 1639681200000)
  and role_id in (select distinct role_id from fairy_town_server.server_physical_consume where map_id = '30010001' and consume_count>0 
                  and server_id in (10001,10002,10003) and log_time >= 1639022400000 and log_time <= 1639681200000)
老
SELECT count(DISTINCT role_id)
FROM fairy_town.order_pay
WHERE server_id IN (10001,10002,10003)
  AND log_time >= 1639022400000 and log_time <= 1639681200000
  AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time < 1639022400000)
  and role_id in (SELECT DISTINCT role_id FROM fairy_town_server.server_activity_triggered WHERE server_id IN (10001,10002,10003) AND activity_id in (7,8)
                AND log_time >= 1639022400000 AND log_time <= 1639681200000)
  and role_id in (select distinct role_id from fairy_town_server.server_physical_consume where map_id = '30010001' and consume_count>0 
                  and server_id in (10001,10002,10003) and log_time >= 1639022400000 and log_time <= 1639681200000)


新
SELECT sum(pay_price)
    FROM fairy_town.order_pay
WHERE server_id IN (10001,10002,10003)
  AND log_time >= 1639022400000 and log_time <= 1639681200000
  AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time >= 1639022400000 and log_time <= 1639681200000)
  and role_id in (SELECT DISTINCT role_id FROM fairy_town_server.server_activity_triggered WHERE server_id IN (10001,10002,10003) AND activity_id in (7,8)
                AND log_time >= 1639022400000 AND log_time <= 1639681200000)
  and role_id in (select distinct role_id from fairy_town_server.server_physical_consume where map_id = '30010001' and consume_count>0 
                  and server_id in (10001,10002,10003) and log_time >= 1639022400000 and log_time <= 1639681200000)

老
SELECT sum(pay_price)
    FROM fairy_town.order_pay
WHERE server_id IN (10001,10002,10003)
  AND log_time >= 1639022400000 and log_time <= 1639681200000
  AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time < 1639022400000)
  and role_id in (SELECT DISTINCT role_id FROM fairy_town_server.server_activity_triggered WHERE server_id IN (10001,10002,10003) AND activity_id in (7,8)
                AND log_time >= 1639022400000 AND log_time <= 1639681200000)
  and role_id in (select distinct role_id from fairy_town_server.server_physical_consume where map_id = '30010001' and consume_count>0 
                  and server_id in (10001,10002,10003) and log_time >= 1639022400000 and log_time <= 1639681200000)




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
        fairy_town.server_role_login
    where 
        -- day_time >= ${start_time}
        -- and day_time <= ${end_time}
        log_time >= 1639081800000 and log_time <= 1639681200000
        and server_id IN (10001,10002,10003)
        and role_id in
        (SELECT
            distinct role_id
         FROM fairy_town_server.server_physical_consume 
         where map_id = '30010001' and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1639081800000 and log_time <= 1639681200000
        )
    group by 1,2
    ) a
group by day_time
order by day_time


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
        fairy_town.client_online
    where 
        -- day_time >= ${start_time}
        -- and day_time <= ${end_time}
        log_time >= 1639081800000 and log_time <= 1639681200000
        and server_id IN (10001,10002,10003)
        and role_id in
        (SELECT
            distinct role_id
         FROM fairy_town_server.server_physical_consume 
         where map_id = '30010001' and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1639081800000 and log_time <= 1639681200000
        )
    group by 1,2
) a
group by day_time
order by day_time







*******************运营需求*************************


次日留存
select
    b.day_time_a as day_time,
    sum(case when by_day = 0 then 1 else 0 end) '新增',
    sum(case when by_day = 1 then 1 else 0 end) day_2
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
             SELECT role_id,
                    to_date(cast(date_time as timestamp)) as day_times
             FROM fairy_town.server_role_login
             WHERE server_id IN (10001,10002,10003)
             AND day_time >= 20211008 and day_time <= 20211017
             group by 1,2
            ) b 
        right join 
            (SELECT role_id,
                    to_date(cast(date_time as timestamp)) as day_times
             FROM fairy_town.server_role_login
             WHERE server_id IN (10001,10002,10003)
             AND log_time >= 1633665600000 and log_time <= 1634324400000
             and role_id in (select distinct role_id from fairy_town_server.server_physical_consume where map_id = '30010001' 
                            and consume_count>0 and server_id in (10001,10002,10003) and log_time >= 1633665600000 and log_time <= 1634324400000)
             group by 1,2
            ) a
            on a.role_id = b.role_id
        ) as reu
    order by 1,3      
) as b

group by 1
order by 1






充值

频次
SELECT 
    count(case when num =1 then role_id else null end) as '1次',
    count(case when num =2 or num = 3 then role_id else null end) as '2-3次',
    count(case when num =4 or num = 5 then role_id else null end) as '4-5次',
    count(case when num > 5 then role_id else null end) as '5次以上'
from
(
SELECT role_id,count(1) as num
FROM fairy_town.order_pay
WHERE server_id IN (10001,10002,10003)
  AND log_time >= 1639022400000 and log_time <= 1639681200000
  and product_name <> '战令'
  and role_id in (select distinct role_id from fairy_town_server.server_physical_consume where map_id = '30010001' and consume_count>0 
                  and server_id in (10001,10002,10003) and log_time >= 1639022400000 and log_time <= 1639681200000)
GROUP BY 1
) a


非活动期 10级以上购买频次  11.30 12：00 - 12.8 3：00 
SELECT 
    count(distinct case when num =1 then role_id else null end) as '1次',
    count(distinct case when num =2 or num = 3 then role_id else null end) as '2-3次',
    count(distinct case when num =4 or num = 5 then role_id else null end) as '4-5次',
    count(distinct case when num > 5 then role_id else null end) as '5次以上'
from
(
SELECT a.role_id, num
from
    (select 
    role_id,
    log_time
    from fairy_town.server_role_upgrade
    where log_time >= 1638244800000 and log_time <= 1638903600000
    and role_level >= 10
    union all 
    select 
    role_id,
    log_time
    from fairy_town.server_role_login
    where log_time >= 1638244800000 and log_time <= 1638903600000
    and role_level >= 10
    ) a, 
    (SELECT
        role_id,count(1) as num
    from fairy_town.order_pay
    where log_time >= 1638244800000 and log_time <= 1638903600000
    group by 1 ) b
    where a.role_id = b.role_id
) c




档位  12.9-12.17
select
    count(case when pay_sum >= 30 then role_id end) as '大R(>=$30)'
    ,count(case when pay_sum > 10 and pay_sum < 30 then role_id end) as '中R(>$10 & < $30)'
    ,count(case when pay_sum <= 10 then role_id end) as '小R(<=$10)'
from
(
SELECT role_id,sum(pay_price) as pay_sum
FROM fairy_town.order_pay
WHERE server_id IN (10001,10002,10003)
  AND log_time >= 1639022400000 and log_time <= 1639681200000
  and product_name <> '战令'
  and role_id in (select distinct role_id from fairy_town_server.server_physical_consume where map_id = '30010001' and consume_count>0 
                  and server_id in (10001,10002,10003) and log_time >= 1639022400000 and log_time <= 1639681200000)
GROUP BY 1
) a


SELECT 
    count(distinct case when num >=30 then role_id else null end) as '大R(>=$30)',
    count(distinct case when num > 10 and num < 30 then role_id else null end) as '中R(>$10 & < $30)',
    count(distinct case when num <= 10 then role_id else null end) as '小R(<=$10)'
from
(
SELECT a.role_id, num
from
    (select 
    role_id,
    log_time
    from fairy_town.server_role_upgrade
    where log_time >= 1638244800000 and log_time <= 1638903600000
    and role_level >= 10
    union all 
    select 
    role_id,
    log_time
    from fairy_town.server_role_login
    where log_time >= 1638244800000 and log_time <= 1638903600000
    and role_level >= 10
    ) a, 
    (SELECT
        role_id,sum(pay_price) as num
    from fairy_town.order_pay
    where log_time >= 1638244800000 and log_time <= 1638903600000
    group by 1 ) b
    where a.role_id = b.role_id
) c



历史付费用户及总收入划分大中小R  做帕累托图看
SELECT role_id, sum(pay_price)
from fairy_town.order_pay
where day_time <= 20211217
group by 1


充值路径
SELECT game_product_id,product_name,count(distinct role_id)
FROM fairy_town.order_pay
WHERE server_id IN (10001,10002,10003)
  AND log_time >= 1639081800000 and log_time <= 1639681200000
  and role_id in (select distinct role_id from fairy_town_server.server_physical_consume where map_id = '30010001' and consume_count>0 
                  and server_id in (10001,10002,10003) and log_time >= 1639081800000 and log_time <= 1639681200000)
GROUP BY 1,2


充能宝石展示
SELECT  count(DISTINCT role_id) from fairy_town_server.server_package_page_view where package_id in (228,229) and day_time >= 20211209



