-- 一、活动数据概览 2021.10.30 12：00 —— 2021.11.07 03：00
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
	where map_id = '31010001' and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1635566400000 and log_time <= 1636225200000
    ) a,
	(SELECT
        count(distinct role_id) as num
    FROM
        fairy_town_server.server_task_accept
    where task_id = '3101011' and server_id in (10001,10002,10003) and log_time >= 1635566400000 and log_time <= 1636225200000) b -- 接取活动任务的人数


# 进入地图人数
select
    count(distinct role_id)
from 
    fairy_town_server.server_map_enter
where map_id = '31010001' and server_id in (10001,10002,10003) and log_time >= 1635566400000 and log_time <= 1636225200000


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
    where map_id = '31010001' and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1635566400000 and log_time <= 1636225200000
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
             where map_id = '31010001' and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1635566400000 and log_time <= 1636225200000
             )   
         union all
             (
             SELECT
                 role_id,
                 date_time
             from 
                 fairy_town.server_role_login
             WHERE role_level >= 10 and server_id in (10001,10002,10003) and log_time >= 1635566400000 and log_time <= 1636225200000
             )
        ) c
    group by 1
    ) as b
where a.birth_dt = b.birth_dt
order by day_dt


-- # 2、活动参与深度 整体用户按天体力总消耗（采集消耗 + 训化）(√)
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
    where map_id = '31010001' and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1635566400000 and log_time <= 1636225200000
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
        and change_method = '56'
        and server_id in (10001,10002,10003) and log_time >= 1635566400000 and log_time <= 1636225200000
        and role_id in (SELECT DISTINCT role_id from fairy_town_server.server_physical_consume  where map_id = '31010001' and consume_count > 0 
                        and server_id in (10001,10002,10003) and log_time >= 1635566400000 and log_time <= 1636225200000)
    GROUP BY birth_dt
    ORDER BY birth_dt  
    )
    ) a
group by birth_dt
order by birth_dt


-- 当天总消耗
SELECT
    to_date(cast(date_time as timestamp)) as birth_dt,
    sum(change_count) as consume_count
FROM
    fairy_town.server_currency
where 
    server_id in (10001,10002,10003) 
    and log_time >= 1635566400000 
    and log_time <= 1636225200000
    and currency_id = '3' 
    and change_type = 'CONSUME' 
    and role_id in (select distinct role_id 
                    from fairy_town_server.server_physical_consume 
                    where map_id = '31010001' and consume_count > 0 
                    and server_id in (10001,10002,10003) 
                    and log_time >= 1635566400000 and log_time <= 1636225200000)
GROUP BY birth_dt
ORDER BY birth_dt


-- 整体用户体力消耗分布
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
        (SELECT
            role_id,
            sum(consume_count) as consume_count
        FROM
            fairy_town_server.server_physical_consume
        where map_id = '31010001' and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1635566400000 and log_time <= 1636225200000
        GROUP BY 1
        ) 
        union all
        (SELECT
            role_id
            ,sum(change_count) as consume_count
        FROM
            fairy_town.server_currency
        where currency_id = '3' 
            and change_type = 'CONSUME' 
            and change_method = '56'
            and server_id in (10001,10002,10003) and log_time >= 1635566400000 and log_time <= 1636225200000
            and role_id in (SELECT DISTINCT role_id from fairy_town_server.server_physical_consume  where map_id = '31010001' and consume_count > 0 
                        and server_id in (10001,10002,10003) and log_time >= 1635566400000 and log_time <= 1636225200000)
        GROUP BY 1
        )
        ) a
    group by 1
    ) b


-- 活动参与深度 付费用户按天体力总消耗（采集消耗 + 训化）
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
    where map_id = '31010001' and server_id in (10001,10002,10003) and log_time >= 1635566400000 and log_time <= 1636225200000
    and role_id in (select distinct role_id from fairy_town.order_pay where day_time <= 20211107 and server_id in (10001,10002,10003))
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
        and change_method = '56'
        and server_id in (10001,10002,10003) and log_time >= 1635566400000 and log_time <= 1636225200000
        and role_id in (select distinct role_id from fairy_town.order_pay where day_time <= 20211107 and server_id in (10001,10002,10003))
        and role_id in (SELECT DISTINCT role_id from fairy_town_server.server_physical_consume  where map_id = '31010001' and server_id in (10001,10002,10003) 
            and log_time >= 1635566400000 and log_time <= 1636225200000)
    GROUP BY birth_dt
    ORDER BY birth_dt  
    )
    ) a
group by birth_dt
order by birth_dt


-- 当天总消耗 历史付费用户
SELECT
    to_date(cast(date_time as timestamp)) as birth_dt,
    sum(change_count) as consume_count
FROM
    fairy_town.server_currency
where 
    server_id in (10001,10002,10003) 
    and log_time >= 1635566400000 
    and log_time <= 1636225200000
    and currency_id = '3' 
    and change_type = 'CONSUME' 
    and role_id in (select distinct role_id 
                    from fairy_town_server.server_physical_consume 
                    where map_id = '31010001' and consume_count > 0 
                    and server_id in (10001,10002,10003) 
                    and log_time >= 1635566400000 and log_time <= 1636225200000)
    and role_id in (SELECT DISTINCT role_id from fairy_town.order_pay where server_id in (10001,10002,10003) and day_time <= 20211107)
GROUP BY birth_dt
ORDER BY birth_dt


-- 整体用户体力消耗 分布
-- 平均值  (√)   中位数  (√)
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
        where map_id = '31010001' and server_id in (10001,10002,10003) and log_time >= 1635566400000 and log_time <= 1636225200000
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
            and change_method = '56'
            and server_id in (10001,10002,10003) and log_time >= 1635566400000 and log_time <= 1636225200000
            and role_id in (SELECT DISTINCT role_id from fairy_town_server.server_physical_consume  where map_id = '31010001' and consume_count > 0 
                        and server_id in (10001,10002,10003) and log_time >= 1635566400000 and log_time <= 1636225200000)
        )
    ) a
    group by role_id,birth_dt
    ) b
group by birth_dt
order by birth_dt


-- 分位数  (√)
SELECT
    role_id
    ,sum(case when c.consume_count is null then 0 else c.consume_count end) consume_count1
FROM
(
    (SELECT
        role_id,
        consume_count as consume_count
    FROM
        fairy_town_server.server_physical_consume
    where map_id = '31010001' and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1635566400000 and log_time <= 1636225200000
    )
    union all
    (SELECT
        role_id,
        change_count as consume_count
    FROM
        fairy_town.server_currency
    where currency_id = '3' 
        and change_type = 'CONSUME' 
        and change_method = '56'
        and server_id in (10001,10002,10003) and log_time >= 1635566400000 and log_time <= 1636225200000
        and role_id in ((SELECT role_id FROM fairy_town_server.server_physical_consume where map_id = '31010001' and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1635566400000 and log_time <= 1636225200000
    ))
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
    where map_id = '31010001' and server_id in (10001,10002,10003) and log_time >= 1635566400000 and log_time <= 1636225200000
          and role_id in (SELECT
                                role_id
                            FROM
                                fairy_town_server.server_task_completed
                            where server_id IN (10001,10002,10003)
                                  and log_time >= 1635566400000 and log_time <= 1636225200000
                                  and task_id = '3101571' -- 完成最后一个任务
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
        and change_method = '56'
        and server_id in (10001,10002,10003) and log_time >= 1635566400000 and log_time <= 1636225200000
        and role_id in (SELECT
                                role_id
                            FROM
                                fairy_town_server.server_task_completed
                            where server_id IN (10001,10002,10003)
                                  and log_time >= 1635566400000 and log_time <= 1636225200000
                                  and task_id = '3101571' -- 完成最后一个任务
                        )
    )
) c
group by role_id
order by role_id


-- 通关用户 (√)
SELECT
    day_time,
    count(role_id)
FROM
    fairy_town_server.server_task_completed
where server_id IN (10001,10002,10003)
    and log_time >= 1635566400000 and log_time <= 1636225200000
    and task_id = '3101571' -- 完成最后一个任务
group by 1


# 3、任务通过率 记录完成的任务即可  (√)
SELECT
    a.task_group_id as task_group_id,
    a.task_group_id_num as task_group_id_num,
    b.task_group_id_num / a.task_group_id_num as '任务组完成率'
FROM
    (SELECT
        task_group_id as task_group_id,
        count(distinct role_id) as task_group_id_num
    FROM fairy_town_server.server_task_accept
    WHERE server_id IN (10001,10002,10003)
      and log_time >= 1635566400000 and log_time <= 1636225200000
      AND task_group_id IN ('310100','310101','310102','310103','310104','310105','310106','310107','310108','310109','310110','310111','310112','310113','310114',
                            '310115','310116','310117','310118','310119','310120','310121','310122','310123','310124','310125','310126','310127','310128','310129',
                            '310130','310131','310132','310133','310134','310135','310136','310137','310141','310142','310143','310144','310145','310146','310147',
                            '310148','310149','310150','310151','310152','310153','310154','310155','310156','310157','310158','310159','310160','310161','310162',
                            '310163','310164','310165','310166','310167','310168','310169','310170','310171','310172','310173')
      and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume 
          where map_id = '31010001' and server_id in (10001,10002,10003) and log_time >= 1635566400000 and log_time <= 1636225200000)
    group by task_group_id
    ) a
left join
    (SELECT
        task_group_id as task_group_id,
        count(distinct role_id) as task_group_id_num
    FROM fairy_town_server.server_task_completed
    WHERE server_id IN (10001,10002,10003)
      and log_time >= 1635566400000 and log_time <= 1636225200000
      AND task_group_id IN ('310100','310101','310102','310103','310104','310105','310106','310107','310108','310109','310110','310111','310112','310113','310114',
                            '310115','310116','310117','310118','310119','310120','310121','310122','310123','310124','310125','310126','310127','310128','310129',
                            '310130','310131','310132','310133','310134','310135','310136','310137','310141','310142','310143','310144','310145','310146','310147',
                            '310148','310149','310150','310151','310152','310153','310154','310155','310156','310157','310158','310159','310160','310161','310162',
                            '310163','310164','310165','310166','310167','310168','310169','310170','310171','310172','310173')
      and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume 
          where map_id = '31010001' and server_id in (10001,10002,10003) and log_time >= 1635566400000 and log_time <= 1636225200000)
    group by task_group_id
    ) b
on a.task_group_id = b.task_group_id
order by a.task_group_id

-- 任务   (√)

SELECT
    a.task_id as task_id,
    a.task_group_id_num as task_group_id_num,
    b.task_group_id_num / a.task_group_id_num as '任务完成率'
FROM
    (SELECT
        task_id as task_id,
        count(distinct role_id) as task_group_id_num
    FROM fairy_town_server.server_task_accept
    WHERE server_id IN (10001,10002,10003)
      and log_time >= 1635566400000 and log_time <= 1636225200000
      AND task_group_id IN ('310100','310101','310102','310103','310104','310105','310106','310107','310108','310109','310110','310111','310112','310113','310114',
                            '310115','310116','310117','310118','310119','310120','310121','310122','310123','310124','310125','310126','310127','310128','310129',
                            '310130','310131','310132','310133','310134','310135','310136','310137','310141','310142','310143','310144','310145','310146','310147',
                            '310148','310149','310150','310151','310152','310153','310154','310155','310156','310157','310158','310159','310160','310161','310162',
                            '310163','310164','310165','310166','310167','310168','310169','310170','310171','310172','310173')
      and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume 
          where map_id = '31010001' and server_id in (10001,10002,10003) and log_time >= 1635566400000 and log_time <= 1636225200000)
    group by task_id
    ) a
left join
    (SELECT
        task_id as task_id,
        count(distinct role_id) as task_group_id_num
    FROM fairy_town_server.server_task_completed
    WHERE server_id IN (10001,10002,10003)
      and log_time >= 1635566400000 and log_time <= 1636225200000
      AND task_group_id IN ('310100','310101','310102','310103','310104','310105','310106','310107','310108','310109','310110','310111','310112','310113','310114',
                            '310115','310116','310117','310118','310119','310120','310121','310122','310123','310124','310125','310126','310127','310128','310129',
                            '310130','310131','310132','310133','310134','310135','310136','310137','310141','310142','310143','310144','310145','310146','310147',
                            '310148','310149','310150','310151','310152','310153','310154','310155','310156','310157','310158','310159','310160','310161','310162',
                            '310163','310164','310165','310166','310167','310168','310169','310170','310171','310172','310173')
      and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume 
          where map_id = '31010001' and server_id in (10001,10002,10003) and log_time >= 1635566400000 and log_time <= 1636225200000)
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
where game_product_id in ('com.managames.fairytown.iap_4.99p','com.managames.fairytown.iap_9.99p','com.managames.fairytown.iap_14.99p',
                          'com.managames.fairytown.iap_9.99t','com.managames.fairytown.iap_19.99t','com.managames.fairytown.iap_39.99t')
and server_id in (10001,10002,10003) and day_time >= 20211030 and day_time <= 20211107
GROUP BY 1,2
ORDER BY 1,2




# 活动奖励领取情况   (√)
SELECT 
    item_ids,
    count(distinct role_id) as '人数'
FROM 
    fairy_town_server.server_enter_gift_box
WHERE item_ids in ('130006','130007','130008','130009','130010','130011','130012','130013','130014','130015','130016','130017','130018','130019','130020','130021','130022','130023')
      and server_id in (10001,10002,10003) 
GROUP BY item_ids
ORDER BY item_ids

# 礼物堆 (×)
SELECT 
     building_id,
     complete_stage,
     count(role_id)
FROM 
    fairy_town_server.server_building_complete
WHERE building_id in ('4003033','4003040')
      and server_id in (10001,10002,10003) 
      and map_id = '31010001' 
group by 1,2
order by 1,2



# 活动评价数据   (√)
SELECT 
    role_id,
    scores
FROM fairy_town_server.server_event_rate
where role_id in (select DISTINCT role_id from fairy_town_server.server_physical_consume 
                        where map_id = '31010001' and server_id in (10001,10002,10003))
    and activity_id = 3




-- 登录时常
select
    day_time,
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
        day_time >= 20211030
        and day_time <= 20211107
        and server_id IN (10001,10002,10003)
        and role_id in
        (select role_id from fairy_town_server.server_physical_consume 
                            where map_id = '31010001' and server_id in (10001,10002,10003))
    group by role_id,day_time
) a
group by day_time
order by day_time


-- 登陆次数
select
    day_time,
    avg(cishu) cishu_avg,
    appx_median(cishu) cishu_median
from
    (select
        day_time,
        role_id,
        count(role_id) as cishu
    from
        fairy_town.role_login
    where 
        day_time >= 20211030
        and day_time <= 20211107
        and server_id IN (10001,10002,10003)
        and role_id in
        (select role_id from fairy_town_server.server_physical_consume 
            where map_id = '31010001' and server_id in (10001,10002,10003))
    group by day_time,role_id
    ) a
group by day_time
order by day_time





# 活动收入（去除掉老用户的影响）
-- 10.30 - 11.07 万圣节注册用户
select distinct role_id from fairy_town.server_role_create where day_time >= 20211030 and day_time <= 20211107
-- 10.22 - 10.29 战令注册用户
select distinct role_id from fairy_town.server_role_create where day_time >= 20211022 and day_time <= 20211029
-- 10.17 - 10.21 空白期注册用户
select distinct role_id from fairy_town.server_role_create where day_time >= 20211017 and day_time <= 20211021
-- 10.08 - 10.16 飞鱼岛注册用户
select distinct role_id from fairy_town.server_role_create where day_time >= 20211008 and day_time <= 20211016
-- 10.16之前注册用户
select distinct role_id from fairy_town.server_role_create where day_time <= 20211016
-- 参加活动的用户
select distinct role_id from fairy_town_server.server_physical_consume where map_id = '31010001' and server_id in (10001,10002,10003) and consume_count > 0
-- 参加过两个活动的用户
select a.role_id from
(select distinct role_id from fairy_town_server.server_physical_consume where map_id = '31010001' and consume_count>0 and server_id in (10001,10002,10003) and consume_count > 0) a
join
(select distinct role_id from fairy_town_server.server_physical_consume where map_id = '30010001' and consume_count>0 and server_id in (10001,10002,10003) and consume_count > 0) b
on a.role_id = b.role_id



-- 充值
select
    sum(pay_price)
from
    fairy_town.order_pay
where
    server_id IN (10001,10002,10003)
    and role_id in (select distinct role_id from fairy_town_server.server_physical_consume where map_id = '31010001' and server_id in (10001,10002,10003) and consume_count > 0)
    and role_id in (select distinct role_id from fairy_town.server_role_create where day_time <= 20211007)
    -- and role_id in (select distinct role_id from fairy_town.server_role_create where day_time >= 20211008 and day_time <= 20211016)
    -- and role_id in (select distinct role_id from fairy_town.server_role_create where day_time >= 20211017 and day_time <= 20211021)
    -- and role_id in (select distinct role_id from fairy_town.server_role_create where day_time >= 20211022 and day_time <= 20211029)
    -- and role_id in (select distinct role_id from fairy_town.server_role_create where day_time >= 20211030 and day_time <= 20211107)
    and log_time >= 1633665600000 -- 飞鱼岛 
    and log_time <= 1634324400000 
    and log_time >= 1635566400000 -- 万圣节
    and log_time <= 1636225200000


-- 活跃用户数
SELECT 
    count(DISTINCT role_id)
FROM 
    fairy_town.server_role_login
WHERE 
    server_id IN (10001,10002,10003)
    and role_id in (select distinct role_id from fairy_town_server.server_physical_consume where map_id = '31010001' and server_id in (10001,10002,10003) and consume_count > 0)
    and role_id in (select distinct role_id from fairy_town.server_role_create where day_time <= 20211007)
    -- and role_id in (select distinct role_id from fairy_town.server_role_create where day_time >= 20211008 and day_time <= 20211016)
    -- and role_id in (select distinct role_id from fairy_town.server_role_create where day_time >= 20211017 and day_time <= 20211021)
    -- and role_id in (select distinct role_id from fairy_town.server_role_create where day_time >= 20211022 and day_time <= 20211029)
    -- and role_id in (select distinct role_id from fairy_town.server_role_create where day_time >= 20211030 and day_time <= 20211107)
    and day_time >= ${start_time}
    and day_time <= ${end_time}



 -- 付费用户数
SELECT 
    count(DISTINCT role_id)
FROM 
    fairy_town.order_pay
WHERE 
    server_id IN (10001,10002,10003)
    and role_id in (select distinct role_id from fairy_town_server.server_physical_consume where map_id = '31010001' and server_id in (10001,10002,10003) and consume_count > 0)
    and role_id in (select distinct role_id from fairy_town.server_role_create where day_time <= 20211007)
    -- and role_id in (select distinct role_id from fairy_town.server_role_create where day_time >= 20211008 and day_time <= 20211016)
    -- and role_id in (select distinct role_id from fairy_town.server_role_create where day_time >= 20211017 and day_time <= 20211021)
    -- and role_id in (select distinct role_id from fairy_town.server_role_create where day_time >= 20211022 and day_time <= 20211029)
    -- and role_id in (select distinct role_id from fairy_town.server_role_create where day_time >= 20211030 and day_time <= 20211107)
    and day_time >= ${start_time}
    and day_time <= ${end_time}







(select distinct role_id from fairy_town.server_role_create where day_time <= 20211007)

(select distinct role_id from fairy_town.server_role_create where day_time >= 20211008 and day_time <= 20211016)

select
    sum(pay_price)
from
    fairy_town.order_pay
where
    server_id IN (10001,10002,10003)
    and role_id in (select a.role_id from
                    (select distinct role_id from fairy_town_server.server_physical_consume where map_id = '31010001' and server_id in (10001,10002,10003) and consume_count > 0) a
                    join
                    (select distinct role_id from fairy_town_server.server_physical_consume where map_id = '30010001' and server_id in (10001,10002,10003) and consume_count > 0) b
                    on a.role_id = b.role_id)
    and role_id in (select distinct role_id from fairy_town.server_role_create where day_time <= 20211007)
    and log_time >= 1633665600000 -- 飞鱼岛 
    and log_time <= 1634324400000 
    and log_time >= 1635566400000 -- 万圣节
    and log_time <= 1636225200000




SELECT 
    count(DISTINCT role_id)
FROM 
    fairy_town.order_pay
WHERE 
    server_id IN (10001,10002,10003)
    and role_id in (select a.role_id from
                    (select distinct role_id from fairy_town_server.server_physical_consume where map_id = '31010001' and server_id in (10001,10002,10003) and consume_count > 0) a
                    join
                    (select distinct role_id from fairy_town_server.server_physical_consume where map_id = '30010001' and server_id in (10001,10002,10003) and consume_count > 0) b
                    on a.role_id = b.role_id)
    and role_id in (select distinct role_id from fairy_town.server_role_create where day_time <= 20211007)
    and day_time >= ${start_time}
    and day_time <= ${end_time}


SELECT 
    count(DISTINCT role_id)
FROM 
    fairy_town.server_role_login
WHERE 
    server_id IN (10001,10002,10003)
    and role_id in (select a.role_id from
                    (select distinct role_id from fairy_town_server.server_physical_consume where map_id = '31010001' and server_id in (10001,10002,10003) and consume_count > 0) a
                    join
                    (select distinct role_id from fairy_town_server.server_physical_consume where map_id = '30010001' and server_id in (10001,10002,10003) and consume_count > 0) b
                    on a.role_id = b.role_id)
    and role_id in (select distinct role_id from fairy_town.server_role_create where day_time <= 20211007)
    and day_time >= ${start_time}
    and day_time <= ${end_time}





SELECT
    day_time,
    change_method,
    sum(change_count)
from fairy_town.server_currency
WHERE 
    role_id in (select distinct role_id from fairy_town.server_role_create where day_time <= 20211007)
    and role_id in ((select distinct role_id from fairy_town.order_pay where day_time >= 20211008 and day_time <= 20211016))
    and role_id in (select a.role_id from
                    (select distinct role_id from fairy_town_server.server_physical_consume where map_id = '31010001' and server_id in (10001,10002,10003) and consume_count > 0) a
                    join
                    (select distinct role_id from fairy_town_server.server_physical_consume where map_id = '30010001' and server_id in (10001,10002,10003) and consume_count > 0) b
                    on a.role_id = b.role_id)
    and server_id in (10001,10002,10003)
    and currency_id = '3'
    and day_time >= 20211001
    and day_time <= 20211008
    and change_type = 'PRODUCE'
GROUP BY 1,2
ORDER BY 1














