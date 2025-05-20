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
	where map_id = '30010001' and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1633665600000 and log_time <= 1634324400000
    ) a,
	(SELECT
        count(distinct role_id) as num
    FROM
        fairy_town_server.server_task_accept
    where task_id = '3001011' and server_id in (10001,10002,10003) and log_time >= 1633665600000 and log_time <= 1634324400000) b -- 接取活动任务的人数

# 进入地图人数
select
    count(distinct role_id)
from 
    fairy_town_server.server_map_enter
where map_id = '30010001' and server_id in (10001,10002,10003) and log_time >= 1633665600000 and log_time <= 1634324400000


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
	where map_id = '30010001' and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1633665600000 and log_time <= 1634324400000
	GROUP BY birth_dt
	ORDER BY birth_dt) as a,

	(SELECT 
	    to_date(cast(date_time as timestamp)) as birth_dt,
	    count(distinct role_id) as num
	FROM 
	    fairy_town_server.server_physical_consume 
	where consume_count > 0 and role_level >= 10 and server_id in (10001,10002,10003) and log_time >= 1633665600000 and log_time <= 1634324400000
	GROUP BY birth_dt
	ORDER BY birth_dt) as b
where a.birth_dt = b.birth_dt
order by day_dt




-- # 2、活动参与深度 整体用户按天体力总消耗（采集消耗 + 转动消耗）(√)
SELECT
    birth_dt as birth_dt
    ,sum(consume_count) as consume_count_sum
FROM
    (
    (SELECT
        to_date(cast(date_time as timestamp)) as birth_dt,
        sum(consume_count) as consume_count
    FROM
        fairy_town_server.server_physical_consume
    where map_id = '30010001' and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1633665600000 and log_time <= 1634324400000
    GROUP BY birth_dt
    ORDER BY birth_dt
    ) 
    union all
    (SELECT
        to_date(cast(date_time as timestamp)) as birth_dt
        ,sum(change_count) as consume_count
    FROM
        fairy_town.server_currency
    where currency_id = '3' 
        and change_type = 'CONSUME' 
        and change_method = '82'
        and server_id in (10001,10002,10003) and log_time >= 1633665600000 and log_time <= 1634324400000
    GROUP BY birth_dt
    ORDER BY birth_dt  
    )
    ) a
group by birth_dt
order by birth_dt


-- 平均值  (√)
SELECT
    birth_dt,
    avg(consume_count_sum) as consume_count_avg
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
        where map_id = '30010001' and server_id in (10001,10002,10003) and log_time >= 1633665600000 and log_time <= 1634324400000
        ) 
        union all
        (SELECT
            role_id,
            to_date(cast(date_time as timestamp)) as birth_dt
            ,change_count as consume_count
        FROM
            fairy_town.server_currency
        where currency_id = '3' 
            and change_type = 'CONSUME' 
            and change_method = '82'
            and server_id in (10001,10002,10003) and log_time >= 1633665600000 and log_time <= 1634324400000
        )
    ) a
    group by role_id,birth_dt
    ) b
group by birth_dt
order by birth_dt




-- 中位数  (√)
SELECT
    birth_dt,
    appx_median(consume_count_sum) as consume_count_avg
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
        where map_id = '30010001' and server_id in (10001,10002,10003) and log_time >= 1633665600000 and log_time <= 1634324400000
        ) 
        union all
        (SELECT
            role_id,
            to_date(cast(date_time as timestamp)) as birth_dt
            ,change_count as consume_count
        FROM
            fairy_town.server_currency
        where currency_id = '3' 
            and change_type = 'CONSUME' 
            and change_method = '82'
            and server_id in (10001,10002,10003) and log_time >= 1633665600000 and log_time <= 1634324400000
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
    (SELECT
        role_id,
        consume_count as consume_count
    FROM
        fairy_town_server.server_physical_consume
    where map_id = '30010001' and server_id in (10001,10002,10003) and log_time >= 1633665600000 and log_time <= 1634324400000
    )
    union all
    (SELECT
        role_id,
        change_count as consume_count
    FROM
        fairy_town.server_currency
    where currency_id = '3' 
        and change_type = 'CONSUME' 
        and change_method = '82'
        and server_id in (10001,10002,10003) and log_time >= 1633665600000 and log_time <= 1634324400000
    )
) c
group by role_id
order by role_id


-- 通关用户平均值(完成最后一个任务的用户  为通关用户) (√)
SELECT
    role_id
    ,sum(case c.consume_count when c.consume_count is null then 0 else c.consume_count end) consume_count1
FROM
(
    (SELECT
        role_id,
        consume_count as consume_count
    FROM
        fairy_town_server.server_physical_consume
    where map_id = '30010001' and server_id in (10001,10002,10003) and log_time >= 1633665600000 and log_time <= 1634324400000
          and role_id in (SELECT
                                role_id
                            FROM
                                fairy_town_server.server_task_completed
                            where server_id IN (10001,10002,10003)
                                  and log_time >= 1633665600000 and log_time <= 1634324400000
                                  and task_id = '3001471' -- 完成最后一个任务
                                  )
    )
    union all
    (SELECT
        role_id,
        change_count as consume_count
    FROM
        fairy_town.server_currency
    where currency_id = '3' 
        and change_type = 'CONSUME' 
        and change_method = '82'
        and server_id in (10001,10002,10003) and log_time >= 1633665600000 and log_time <= 1634324400000
        and role_id in (SELECT
                                role_id
                            FROM
                                fairy_town_server.server_task_completed
                            where server_id IN (10001,10002,10003)
                                  and log_time >= 1633665600000 and log_time <= 1634324400000
                                  and task_id = '3001471' -- 完成最后一个任务
                                  )
    )
) c
group by role_id
order by role_id

-- 通关用户 (√)
SELECT
    role_id
FROM
    fairy_town_server.server_task_completed
where server_id IN (10001,10002,10003)
      and log_time >= 1633665600000 and log_time <= 1634324400000
      and task_id = '3001471' -- 完成最后一个任务



# 3、任务通过率 记录完成的任务即可  (√)
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
      and log_time >= 1633665600000 and log_time <= 1634324400000
      AND task_group_id IN ('300101','300102','300103','300104','300105','300106','300107','300108','300109','300110','300111','300112','300113','300114',
        '300115','300116','300117','300118','300119','300120','300121','300122','300123','300124','300125','300126','300127','300128','300129','300130','300131','300132',
        '300133','300134','300135','300136','300137','300138','300139','300140','300141','300142','300143','300144','300145','300146','300147')
      and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume 
          where map_id = '30010001' and server_id in (10001,10002,10003) and log_time >= 1633665600000 and log_time <= 1634324400000)
    group by 1
    ) a
left join
    (SELECT
        task_group_id as task_group_id,
        count(distinct role_id) as task_group_id_num
    FROM fairy_town_server.server_task_completed
    WHERE server_id IN (10001,10002,10003)
      and log_time >= 1633665600000 and log_time <= 1634324400000
      AND task_group_id IN ('300101','300102','300103','300104','300105','300106','300107','300108','300109','300110','300111','300112','300113','300114',
        '300115','300116','300117','300118','300119','300120','300121','300122','300123','300124','300125','300126','300127','300128','300129','300130','300131','300132',
        '300133','300134','300135','300136','300137','300138','300139','300140','300141','300142','300143','300144','300145','300146','300147')
      and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume 
          where map_id = '30010001' and server_id in (10001,10002,10003) and log_time >= 1633665600000 and log_time <= 1634324400000)
    group by 1
    ) b
on a.task_group_id = b.task_group_id
order by 1

-- 任务   (√)
SELECT
    a.task_id as task_id,
    a.task_group_id_num as '接取角色数',
    b.task_group_id_num as '完成角色数'
    b.task_group_id_num / a.task_group_id_num as '任务完成率'
FROM
    (SELECT
        task_id as task_id,
        count(task_id) as task_group_id_num
    FROM fairy_town_server.server_task_accept
    WHERE server_id IN (10001,10002,10003)
      and log_time >= 1633665600000 and log_time <= 1634324400000
      AND task_group_id IN ('300101','300102','300103','300104','300105','300106','300107','300108','300109','300110','300111','300112','300113','300114',
        '300115','300116','300117','300118','300119','300120','300121','300122','300123','300124','300125','300126','300127','300128','300129','300130','300131','300132',
        '300133','300134','300135','300136','300137','300138','300139','300140','300141','300142','300143','300144','300145','300146','300147')
      and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume 
          where map_id = '30010001' and server_id in (10001,10002,10003) and log_time >= 1633665600000 and log_time <= 1634324400000)
    group by task_id
    ) a
left join
    (SELECT
        task_id as task_id,
        count(task_id) as task_group_id_num
    FROM fairy_town_server.server_task_completed
    WHERE server_id IN (10001,10002,10003)
      and log_time >= 1633665600000 and log_time <= 1634324400000
      AND task_group_id IN ('300101','300102','300103','300104','300105','300106','300107','300108','300109','300110','300111','300112','300113','300114',
        '300115','300116','300117','300118','300119','300120','300121','300122','300123','300124','300125','300126','300127','300128','300129','300130','300131','300132',
        '300133','300134','300135','300136','300137','300138','300139','300140','300141','300142','300143','300144','300145','300146','300147')
      and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume 
          where map_id = '30010001' and server_id in (10001,10002,10003) and log_time >= 1633665600000 and log_time <= 1634324400000)
    group by task_id
    ) b
on a.task_id = b.task_id
order by a.task_id


# 活动礼包购买行为  (√)
SELECT 
    to_date(cast(date_time as timestamp)) as birth_dt,
    game_product_id,
    count(game_product_id) as `购买数量`,
    sum(pay_price) as `流水`
FROM 
    fairy_town.order_pay
where game_product_id in ('com.managames.fairytown.iap_4.99veg','com.managames.fairytown.iap_14.99veg','com.managames.fairytown.iap_29.99veg',
'com.managames.fairytown.iap_3.99ve','com.managames.fairytown.iap_9.99ve','com.managames.fairytown.iap_19.99ve')
and server_id in (10001,10002,10003) and day_time >= 20211008 and day_time <= 20211016
GROUP BY 1,2
ORDER BY 1,2


# 活动奖励领取情况   (√)
SELECT 
    item_ids,
    count(distinct role_id) as item_nums
FROM 
    fairy_town_server.server_enter_gift_box
WHERE item_ids in ('300130','300131','300132','300133','300134','300135','300136','300137','300138','300139','300140') 
      and server_id in (10001,10002,10003) 
      and role_level >= 10
      and log_time >= 1633665600000 and log_time <= 1634324400000 
GROUP BY item_ids
ORDER BY item_ids

# 花塔 （×）
SELECT 
     building_id,
     complete_stage,
     count(role_id)
FROM 
    fairy_town_server.server_building_complete
WHERE building_id in ('4003033','4003040')
      and server_id in (10001,10002,10003) 
      and map_id = '30010001' 
group by 1,2
order by 1,2



# 活动评价数据   (√)
SELECT 
    role_id,
    scores
FROM fairy_town_server.server_event_rate
where role_id in (select role_id from fairy_town_server.server_physical_consume 
                        where map_id = '30010001' and server_id in (10001,10002,10003))


# 活动收入（去除掉老用户的影响）
-- 4.20 - 9.28 注册的用户在活动期间登录付费
-- 9.29 - 10.7 注册的用户在活动期间登录付费
-- 10.8 - 10.16 注册的用户在活动期间登录付费
SELECT sum(pay_price)
    FROM fairy_town.order_pay
WHERE 
    server_id IN (10001,10002,10003)
    AND day_time >= 20211008
    AND day_time <= 20211016
    AND role_id IN(SELECT 
                        DISTINCT a.role_id
                   from
                        (SELECT role_id FROM fairy_town.role_create WHERE day_time >= 20210420 AND day_time <= 20210928) as a
                   join
                        (select role_id from fairy_town_server.server_physical_consume 
                        where map_id = '30010001' and server_id in (10001,10002,10003)) as b
                        on a.role_id = b.role_id)

 -- 付费用户数
 SELECT count(DISTINCT role_id)
FROM fairy_town.order_pay
WHERE server_id IN (10001,10002,10003)
  AND day_time >= 20211008
  AND day_time <= 20211016
  AND pay_price > 0
  AND role_id IN(SELECT 
                        DISTINCT a.role_id
                   from
                        (SELECT role_id FROM fairy_town.role_create WHERE day_time >= 20210420 AND day_time <= 20210928) as a
                   join
                        (select role_id from fairy_town_server.server_physical_consume 
                        where map_id = '30010001' and server_id in (10001,10002,10003)) as b
                        on a.role_id = b.role_id)

-- 活跃用户数
SELECT count(DISTINCT role_id)
FROM fairy_town.role_login
WHERE server_id IN (10001,10002,10003)
  AND day_time >= 20211008
  AND day_time <= 20211016
  AND role_id IN(SELECT 
                        DISTINCT a.role_id
                   from
                        (SELECT role_id FROM fairy_town.role_create WHERE day_time >= 20210420 AND day_time <= 20210928) as a
                   join
                        (select role_id from fairy_town_server.server_physical_consume 
                        where map_id = '30010001' and server_id in (10001,10002,10003)) as b
                        on a.role_id = b.role_id)

-- 登录时常
select
    day_time,
    avg(num) as num_avg,
    sum(num) as num_sum
from
(
    SELECT
        role_id,
        day_time,
        count(ping) as num
    from 
        fairy_town.client_online
    where 
        day_time >= 20211008
        and day_time <= 20211016
        and server_id IN (10001,10002,10003)
        and role_id in
        (select role_id from fairy_town_server.server_physical_consume 
                            where map_id = '30010001' and server_id in (10001,10002,10003))
    group by role_id,day_time
) a
group by day_time
order by day_time


-- 登陆次数
select
    day_time,
    avg(cishu) cishu_avg,
    sum(cishu) cishu_sum
from
    (select
        day_time,
        role_id,
        count(role_id) as cishu
    from
        fairy_town.role_login
    where 
        day_time >= 20211008
        and day_time <= 20211016
        and server_id IN (10001,10002,10003)
        and role_id in
        (select role_id from fairy_town_server.server_physical_consume 
            where map_id = '30010001' and server_id in (10001,10002,10003))
    group by day_time,role_id
    ) a
group by day_time
order by day_time



-- 没用宽表
SELECT
    a.role_id
    ,b.`300130`
    ,b.`300131`
    ,b.`300132`
    ,b.`300133`
    ,b.`300134`
    ,b.`300135`
    ,b.`300136`
    ,b.`300137`
    ,b.`300138`
    ,b.`300139`
    ,b.`300140`
FROM
    (SELECT 
        distinct role_id
    FROM
        fairy_town_server.server_physical_consume
    WHERE
        consume_count > 0 -- 消耗体力
        and map_id = '30010001'
        and server_id in (10001,10002,10003) -- 正式服
        and log_time >= 1633665600000 and log_time <= 1634324400000 -- 时间周期
    ) a 
left join
    (SELECT
        role_id
        ,count( case item_ids when '300130' then 1 else 0 end ) `300130`
        ,count( case item_ids when '300131' then 1 else 0 end ) `300131`
        ,count( case item_ids when '300132' then 1 else 0 end ) `300132`
        ,count( case item_ids when '300133' then 1 else 0 end ) `300133`
        ,count( case item_ids when '300134' then 1 else 0 end ) `300134`
        ,count( case item_ids when '300135' then 1 else 0 end ) `300135`
        ,count( case item_ids when '300136' then 1 else 0 end ) `300136`
        ,count( case item_ids when '300137' then 1 else 0 end ) `300137`
        ,count( case item_ids when '300138' then 1 else 0 end ) `300138`
        ,count( case item_ids when '300139' then 1 else 0 end ) `300139`
        ,count( case item_ids when '300140' then 1 else 0 end ) `300140` --活动奖励领取情况
    FROM
        fairy_town_server.server_enter_gift_box
    WHERE
        item_ids in ('300130','300131','300132','300133','300134','300135','300136','300137','300138','300139','300140') -- 任务ID
        and server_id in (10001,10002,10003) -- 正式服
        and log_time >= 1633665600000 and log_time <= 1634324400000 -- 时间周期
    GROUP BY role_id
    ) b
on a.role_id = b.role_id
left join
    (SELECT
        role_id
        ,scores
    FROM
        fairy_town_server.server_event_rate
    WHERE
        activity_id = 1
        and server_id in (10001,10002,10003) -- 正式服
        and log_time >= 1633665600000 and log_time <= 1634324400000 -- 时间周期
    ) c
on a.role_id = c.role_id




-- boss需求
-- 活跃增长：1、留存分析 活跃的变化取决于  1） 新用户流失高  2）老用户流失高  3）没有流失，登录频次下降     看绝对值
-- 付费增长：付费增长分为ARPU增长  付费率增长 1）付费用户 大R 中R 小R  看付费天梯是否上下移动  整体付费率下降问题  2）付费率
-- 活动影响：活动期间付费拉升，用户活动之后流失了---说明活动做得不好；活动之后付费自然下降说明提前透支一部分收入，或停止付费可能需要停下系统开发，去多开发新地图和新关卡，大R用户消耗较快
-- 一、活跃增长
    1、9.16 - 至今  看活跃的变化  

-- 登陆次数
select
    day_time,
    avg(cishu) cishu_avg,
    sum(cishu) cishu_sum
from
    (select
        day_time,
        device_id,
        count(device_id) as cishu
    from
        fairy_town.device_launch
    where 
        day_time >= 20211011
        and day_time <= 20211018
        and server_id IN (10001,10002,10003)
        and device_id in
        (select device_id from fairy_town.device_activate 
            where day_time >= 20210916 and day_time <= 20211010)
    group by day_time,device_id
    ) a
group by day_time
order by day_time


-- 在线时长
select
    day_time,
    avg(num) as num_avg,
    sum(num) as num_sum
from
(
    SELECT
        device_id,
        day_time,
        count(ping) as num
    from 
        fairy_town.client_online
    where 
        day_time >= 20211011
        and day_time <= 20211018
        and server_id IN (10001,10002,10003)
        and device_id in
        (select device_id from fairy_town.device_activate where day_time >= 20210916 and day_time <= 20211010)
    group by device_id,day_time
) a
group by day_time
order by day_time

-- 新用户付费
SELECT
    day_time
    ,case
        when pay_price > 0 then 1
        else 0
    end as payer
    ,pay_price
FROM 
    fairy_town.order_pay
WHERE 
    server_id IN (10001,10002,10003)
    AND day_time >= 20211011
    AND day_time <= 20211018
    AND device_id IN (select distinct device_id from fairy_town.device_activate where day_time >= 20211011 and day_time <= 20211018)
order by day_time


-- 老用户付费






# 策划活动复盘后需求
-- 付费用户定义 活动期间付费用户

-- 1、活动期间与活动前一周，飞鱼岛参与者的每日免费体力获取总量分布情况,免费用户与付费用户分别统计。
-- 2、活动期间与活动前一周，飞鱼岛参与者的各体力获取途径获取体力占比,免费用户与付费用户分别统计。
-- 3、活动期间与活动前一周，新增用户的10级~15级留存是提高了还是降低了
-- 4、飞鱼岛挖矿任务的完成情况数据



-- 1、活动期间与活动前一周，飞鱼岛参与者的每日免费体力获取总量分布情况,免费用户与付费用户分别统计。

# 免费用户（在这期间没付费的用户）role_id 不在这里边的
select distinct role_id from fairy_town.order_pay where day_time >= ${startDate} and day_time <= ${endDate}
# 付费用户（在这期间付费的用户） 
select distinct role_id from fairy_town.order_pay where pay_price > 0 and day_time >= ${startDate} and day_time <= ${endDate}
# 飞鱼岛参与用户
select distinct role_id from fairy_town_server.server_physical_consume where map_id = '30010001' and day_time >= 20211008 and day_time <= 20211016 and server_id in (10001,10002,10003)
-- 去掉新用户
select distinct role_id from fairy_town.role_create where day_time >= 20211008 and day_time <= 20211016 and server_id in (10001,10002,10003)


-- 10.8-10.16 免费用户每日获取免费体力
select  -- 分位数
    role_id
    ,sum(recovery_count) as '免费体力恢复'
from
    fairy_town_server.server_physical_recovery
where
    role_id in (
                select distinct role_id from fairy_town_server.server_physical_consume 
                where map_id = '30010001' and server_id in (10001,10002,10003)
                and role_id not in (select distinct role_id from fairy_town.order_pay where day_time >= ${startDate} and day_time <= ${endDate})
               )
    and role_id not in (select distinct role_id from fairy_town.role_create where day_time >= 20211008 and day_time <= 20211016 and server_id in (10001,10002,10003))
    and day_time >= 20211008
    and day_time <= 20211016
    and recovery_method in ('14','15','17','19','22','23','27','28','29','4','5','6','67','71','75','77','78','80','83')
group by 1


select
    day_time
    ,avg(recovery_count_num) as recovery_count_avg
    ,appx_median(recovery_count_num) as recovery_count_median
from
    (
    select  -- 分天
        role_id
        ,day_time
        ,sum(recovery_count) as recovery_count_num
    from
        fairy_town_server.server_physical_recovery
    where
        role_id in (
                    select distinct role_id from fairy_town_server.server_physical_consume 
                    where map_id = '30010001' and day_time >= 20211008 and day_time <= 20211016 and server_id in (10001,10002,10003)
                    and role_id not in (select distinct role_id from fairy_town.order_pay where day_time >= ${startDate} and day_time <= ${endDate})
                   )
        and role_id not in (select distinct role_id from fairy_town.role_create where day_time >= 20211008 and day_time <= 20211016 and server_id in (10001,10002,10003))
        and day_time >= 20211008
        and day_time <= 20211016
        and recovery_method in ('14','15','17','19','22','23','27','28','29','4','5','6','67','71','75','77','78','80','83')
    group by 1,2
    order by 2
    ) a
group by 1
order by 1

-- 10.8-10.16 付费用户每日获取免费体力

select  -- 分位数
    role_id
    ,sum(recovery_count) as '免费体力恢复'
from
    fairy_town_server.server_physical_recovery
where
    role_id in (
                select distinct role_id from fairy_town_server.server_physical_consume 
                where map_id = '30010001' and server_id in (10001,10002,10003)
                and role_id in (select distinct role_id from fairy_town.order_pay where day_time >= ${startDate} and day_time <= ${endDate})
               )
    and role_id not in (select distinct role_id from fairy_town.role_create where day_time >= 20211008 and day_time <= 20211016 and server_id in (10001,10002,10003))
    and day_time >= 20211008
    and day_time <= 20211016
    and recovery_method in ('14','15','17','19','22','23','27','28','29','4','5','6','67','71','75','77','78','80','83')
group by 1


select
    day_time
    ,avg(recovery_count_num) as recovery_count_avg
    ,appx_median(recovery_count_num) as recovery_count_median
from
    (
    select  -- 分天
        role_id
        ,day_time
        ,sum(recovery_count) as recovery_count_num
    from
        fairy_town_server.server_physical_recovery
    where
        role_id in (
                    select distinct role_id from fairy_town_server.server_physical_consume 
                where map_id = '30010001' and day_time >= 20211008 and day_time <= 20211016 and server_id in (10001,10002,10003)
                and role_id in (select distinct role_id from fairy_town.order_pay where pay_price > 0 and day_time >= ${startDate} and day_time <= ${endDate})
                   )
        and role_id not in (select distinct role_id from fairy_town.role_create where day_time >= 20211008 and day_time <= 20211016 and server_id in (10001,10002,10003))
        and day_time >= 20211008
        and day_time <= 20211016
        and recovery_method in ('14','15','17','19','22','23','27','28','29','4','5','6','67','71','75','77','78','80','83')
    group by 1,2
    order by 2
    ) a
group by 1
order by 1

-- 9.29-10.7 付费用户每日获取免费体力  不是参与活动的用户了  改一下时间就好
-- 9.29-10.7 免费用户每日获取免费体力  
select  -- 分位数
    role_id
    ,sum(recovery_count) as '免费体力恢复'
from
    fairy_town_server.server_physical_recovery
where
    role_id in (
                select distinct role_id from fairy_town_server.server_physical_consume 
                where map_id = '30010001' and server_id in (10001,10002,10003)
                and role_id not in (select distinct role_id from fairy_town.order_pay where day_time >= ${startDate} and day_time <= ${endDate})
               )
    and role_id not in (select distinct role_id from fairy_town.role_create where day_time >= 20211008 and day_time <= 20211016 and server_id in (10001,10002,10003))
    and day_time >= 20210929
    and day_time <= 20211007
    and recovery_method in ('14','15','17','19','22','23','27','28','29','4','5','6','67','71','75','77','78','80','83')
group by 1

select
    day_time
    ,avg(recovery_count_num) as recovery_count_avg
    ,appx_median(recovery_count_num) as recovery_count_median
from
    (
    select  -- 分天
        role_id
        ,day_time
        ,sum(recovery_count) as recovery_count_num
    from
        fairy_town_server.server_physical_recovery
    where
        role_id in (
                    select distinct role_id from fairy_town_server.server_physical_consume 
                    where map_id = '30010001' and server_id in (10001,10002,10003)
                    and role_id not in (select distinct role_id from fairy_town.order_pay where day_time >= ${startDate} and day_time <= ${endDate})
                   )
        and role_id not in (select distinct role_id from fairy_town.role_create where day_time >= 20211008 and day_time <= 20211016 and server_id in (10001,10002,10003))
        and day_time >= 20210929
        and day_time <= 20211007
        and recovery_method in ('14','15','17','19','22','23','27','28','29','4','5','6','67','71','75','77','78','80','83')
    group by 1,2
    order by 2
    ) a
group by 1
order by 1



-- 2、活动期间与活动前一周，飞鱼岛参与者的各体力获取途径获取体力占比,免费用户与付费用户分别统计。

-- 10.8-10.16 飞鱼岛参与者 免费用户
select 
    day_time,
    recovery_method as '体力恢复方式ID', 
    case recovery_method
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
        when '95' then '限时建'
    end as '体力恢复方式',
    sum(recovery_count) as '各个方式恢复体力人数'
from 
    fairy_town_server.server_physical_recovery
where 
    day_time >= 20211008 
    and day_time <= 20211016
    and server_id in (10001,10002,10003)
    and role_id in (
                    select distinct role_id from fairy_town_server.server_physical_consume 
                    where map_id = '30010001' and server_id in (10001,10002,10003)
                    and role_id not in (select distinct role_id from fairy_town.order_pay where day_time >= ${startDate} and day_time <= ${endDate})
                    and role_id not in (select distinct role_id from fairy_town.role_create where day_time >= 20211008 and day_time <= 20211016 and server_id in (10001,10002,10003))
                    )
group by 1,2
order by 1



-- 3、活动期间与活动前一周，新增用户的10级~15级留存是提高了还是降低了

-- 10.8-10.16 活动期间新增用户10-15级 留存
select
    day_time_a as day_time,
    sum(case when by_day = 0 then 1 else 0 end) day_0,
    sum(case when by_day = 1 then 1 else 0 end) day_1,
    sum(case when by_day = 2 then 1 else 0 end) day_2,
    sum(case when by_day = 3 then 1 else 0 end) day_3,
    sum(case when by_day = 4 then 1 else 0 end) day_4,
    sum(case when by_day = 5 then 1 else 0 end) day_5,
    sum(case when by_day = 6 then 1 else 0 end) day_6,
    sum(case when by_day = 7 then 1 else 0 end) day_7
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
            a.d_time as day_time_a,
            b.d_time as day_time_b
        from
             (
             select 
                role_id,
                to_date(cast(date_time as timestamp)) as d_time
             from fairy_town.server_role_upgrade
             where
                day_time >= 20211008 and day_time <= 20211016 and role_level >= 10 and role_level <= 15
             group by 1,2
            ) b 
        left join 
            (select 
                role_id,
                to_date(cast(date_time as timestamp)) as d_time
            from 
                fairy_town.role_login
            where
                day_time >= 20211008 and day_time <= 20211016
            group by  1,2
            ) a
            on a.role_id = b.role_id
        ) as reu
    order by role_id_b,day_time_b 
    ) a
group by 1
order by 1



-- 9.29-10.7 活动前一周新增用户10-15级 留存
select distinct role_id from fairy_town.role_create where day_time >= 20210929 and day_time <= 20211007 and role_level >= 10 and role_level <= 15






-- 4、飞鱼岛挖矿任务的完成情况数据

SELECT 
    day_time
    ,role_id
    ,resource_id
FROM 
    fairy_town_server.server_map_resource_mission_complete
WHERE 
    map_id = '30010001' 
    and server_id in (10001,10002,10003)

