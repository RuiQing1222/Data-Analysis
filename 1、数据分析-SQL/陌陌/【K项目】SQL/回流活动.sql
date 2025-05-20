每天回流人数

SELECT day_time, count(distinct role_id)
         FROM fairy_town_server.server_gold_recovery
         WHERE server_id IN (10001,10002,10003)
         AND day_time >= 20220126 and day_time <= 20220213
         and recovery_method = '116'
and role_id in (select distinct role_id from fairy_town.order_pay where day_time < 20220120)
GROUP BY 1 ORDER BY 1


回流等级分布
SELECT day_time, role_level, count(distinct role_id)
         FROM fairy_town_server.server_gold_recovery
         WHERE server_id IN (10001,10002,10003)
         AND day_time >= 20220126 and day_time <= 20220213
         and recovery_method = '116'
GROUP BY 1,2 ORDER BY 1,2




-- 任务完成率
-- SELECT
--     a.task_id as task_id,
--     a.task_group_id_num as '接取角色数',
--     b.task_group_id_num as '完成角色数',
--     b.task_group_id_num / a.task_group_id_num as '任务完成率'
-- FROM
--     (SELECT
--         task_id as task_id,
--         count(distinct role_id) as task_group_id_num
--     FROM fairy_town_server.server_recall_task_accept
--     WHERE server_id IN (10001,10002,10003)
--       and day_time >= 20220126 and day_time <= 20220213
--     group by 1
--     ) a
-- left join
--     (SELECT
--         task_id as task_id,
--         count(distinct role_id) as task_group_id_num
--     FROM fairy_town_server.server_recall_task_completed
--     WHERE server_id IN (10001,10002,10003)
--       and day_time >= 20220126 and day_time <= 20220213
--     group by 1
--     ) b
-- on a.task_id = b.task_id
-- order by  1



任务完成率 7天内的
SELECT
    a.task_id as task_id,
    a.task_group_id_num as '接取角色数',
    b.task_group_id_num as '完成角色数',
    b.task_group_id_num / a.task_group_id_num as '任务完成率'
FROM

--  任务接取
(select task_id,count(distinct role_id) as task_group_id_num
from
(select task_id,a.role_id as role_id,datediff(b.dates,a.dates) as by_day
from
    (SELECT role_id,to_date(cast(date_time as timestamp)) as dates
	FROM fairy_town_server.server_gold_recovery
	WHERE server_id IN (10001,10002,10003)
	AND day_time >= 20220126 and day_time <= 20220205
	and recovery_method = '116') as a
    left join 
    (SELECT
        role_id,to_date(cast(date_time as timestamp)) as dates,task_id
    FROM fairy_town_server.server_recall_task_accept
    WHERE server_id IN (10001,10002,10003)
      and day_time >= 20220126 and day_time <= 20220213
    ) b
    on a.role_id = b.role_id
) as aa
where by_day in (0,1,2,3,4,5,6)
group by 1 order by 1
) as a


left join

-- 任务完成
(select task_id,count(distinct role_id) as task_group_id_num
from
(select task_id,a.role_id as role_id,datediff(b.dates,a.dates) as by_day
from
    (SELECT role_id,to_date(cast(date_time as timestamp)) as dates
	FROM fairy_town_server.server_gold_recovery
	WHERE server_id IN (10001,10002,10003)
	AND day_time >= 20220126 and day_time <= 20220205
	and recovery_method = '116') as a
    left join 
    (SELECT
        role_id,to_date(cast(date_time as timestamp)) as dates,task_id
    FROM fairy_town_server.server_recall_task_completed
    WHERE server_id IN (10001,10002,10003)
      and day_time >= 20220126 and day_time <= 20220213
    ) b
    on a.role_id = b.role_id
) as aa
where by_day in (0,1,2,3,4,5,6)
group by 1 order by 1
) as b
on a.task_id = b.task_id

order by  1



礼包购买
回流礼包
SELECT 
    day_time,
    game_product_id,
    count(game_product_id) as `购买数量`,
    sum(pay_price) as `流水`
FROM 
    fairy_town.order_pay
where game_product_id in ('com.managames.fairytown.iap_0.99hg1','com.managames.fairytown.iap_4.99hg2','com.managames.fairytown.iap_9.99hg3',
					'com.managames.fairytown.iap_2.99hg4','com.managames.fairytown.iap_6.99hg5','com.managames.fairytown.iap_12.99hg6',
					'com.managames.fairytown.iap_39.99hg7','com.managames.fairytown.iap_69.99hg8','com.managames.fairytown.iap_99.99hg9')
and server_id in (10001,10002,10003) and day_time >= 20220126 and day_time <= 20220213
GROUP BY 1,2
ORDER BY 1,2


整体礼包
select product_name,count(distinct a.role_id) as '购买人数',sum(pay_price) as '购买金额'
from
(SELECT role_id
FROM fairy_town_server.server_gold_recovery
WHERE server_id IN (10001,10002,10003)
AND day_time >= 20220126 and day_time <= 20220213
and recovery_method = '116') as a
left join
(select role_id,product_name,pay_price
from fairy_town.order_pay
where server_id IN (10001,10002,10003)
AND day_time >= 20220126 and day_time <= 20220213) as b
on a.role_id = b.role_id
group by 1
order by 3 desc


LTV
回流活动
select
	a.dates_a as dates,
	-- channel_id,
	round(sum(if(datediff(dates_b,dates_a)=0, pay_price_2, 0)),2) as day1,
	round(sum(if(datediff(dates_b,dates_a)<=2, pay_price_2, 0)),2) as day3,
	round(sum(if(datediff(dates_b,dates_a)<=6, pay_price_2, 0)),2) as day7
from
	(
	select
		op1.role_id as role_id,
		op1.dates as dates_a,
		op2.dates as dates_b,
		op2.pay_price as pay_price_2,
		datediff(op2.dates,op1.dates) as p,
		channel_id
	from
		(select
			role_id,
			channel_id,
			to_date(cast(date_time as timestamp)) as dates
		 FROM fairy_town_server.server_gold_recovery
		where day_time >= 20220126 and day_time <= 20220213 and server_id IN (10001,10002,10003) and recovery_method = '116'
		-- and role_id in (select distinct role_id from fairy_town.order_pay where day_time < 20220120)
		) as op1 ,
		(select
			role_id,
			sum(pay_price) as pay_price,
			to_date(cast(date_time as timestamp)) as dates
		 from
			fairy_town.order_pay
		 where
		 	day_time >= 20220126 and day_time <= 20220213
		 group by role_id,dates
		 ) as op2 
	where op1.role_id = op2.role_id and op2.dates >= op1.dates
	) as a	
group by 1
order by 1


select day_time, count(distinct role_id) from fairy_town_server.server_gold_recovery
where day_time >= 20220126 and day_time <= 20220213 
and server_id in (10001,10002,10003) and recovery_method = '116'
and role_id in (select distinct role_id from fairy_town.order_pay where day_time < 20220120)
group by 1
order by 1 



角色新增
select
	a.dates_a as dates,
	channel_id,
	round(sum(if(datediff(dates_b,dates_a)=0, pay_price_2, 0)),2) as day1,
	round(sum(if(datediff(dates_b,dates_a)<=2, pay_price_2, 0)),2) as day3,
	round(sum(if(datediff(dates_b,dates_a)<=6, pay_price_2, 0)),2) as day7
from
	(
	select
		op1.role_id as role_id,
		op1.dates as dates_a,
		op2.dates as dates_b,
		op2.pay_price as pay_price_2,
		datediff(op2.dates,op1.dates) as p,
		channel_id
	from
		(select
			role_id,
			channel_id,
			to_date(cast(date_time as timestamp)) as dates
		 from
			fairy_town.server_role_create
		where day_time >= 20220126 and day_time <= 20220213 and country not in  ('CN','HK') 
		) as op1 ,
		(select
			role_id,
			sum(pay_price) as pay_price,
			to_date(cast(date_time as timestamp)) as dates
		 from
			fairy_town.order_pay
		 where
		 	day_time >= 20220126 and day_time <= 20220213
		 group by role_id,dates
		 ) as op2 
	where op1.role_id = op2.role_id and op2.dates >= op1.dates
	) as a	

group by 1,2
order by 2,1

select day_time,channel_id, count(distinct role_id) from fairy_town.server_role_create
where day_time >= 20220126 and day_time <= 20220213 
and server_id in (10001,10002,10003)
group by 1,2
order by 2,1 



回流留存
select
    b.day_time_a as day_time,
    sum(case when by_day = 0 then 1 else 0 end) '新增',
    sum(case when by_day = 1 then 1 else 0 end) day_2,
    sum(case when by_day = 2 then 1 else 0 end) day_3,
    sum(case when by_day = 3 then 1 else 0 end) day_4,
    sum(case when by_day = 4 then 1 else 0 end) day_5,
    sum(case when by_day = 5 then 1 else 0 end) day_6,
    sum(case when by_day = 6 then 1 else 0 end) day_7
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
             AND day_time >= 20220126 and day_time <= 20220213
             group by 1,2
            ) b 
        right join 
            (SELECT role_id,
                    to_date(cast(date_time as timestamp)) as day_times
             FROM fairy_town_server.server_gold_recovery
             WHERE server_id IN (10001,10002,10003)
             AND day_time >= 20220126 and day_time <= 20220213
             and recovery_method = '116'
             group by 1,2
            ) a
            on a.role_id = b.role_id
        ) as reu
    order by 1,3      
) as b

group by 1
order by 1


新增角色留存
select
    b.day_time_a as day_time,
    sum(case when by_day = 0 then 1 else 0 end) '新增',
    sum(case when by_day = 1 then 1 else 0 end) day_2,
    sum(case when by_day = 2 then 1 else 0 end) day_3,
    sum(case when by_day = 3 then 1 else 0 end) day_4,
    sum(case when by_day = 4 then 1 else 0 end) day_5,
    sum(case when by_day = 5 then 1 else 0 end) day_6,
    sum(case when by_day = 6 then 1 else 0 end) day_7
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
             AND day_time >= 20220126 and day_time <= 20220213
             group by 1,2
            ) b 
        right join 
            (SELECT role_id,
                    to_date(cast(date_time as timestamp)) as day_times
             FROM fairy_town.server_role_create
             WHERE server_id IN (10001,10002,10003)
             AND day_time >= 20220126 and day_time <= 20220213
             group by 1,2
            ) a
            on a.role_id = b.role_id
        ) as reu
    order by 1,3      
) as b

group by 1
order by 1


************************************************************************

免费领取方式   '4','5','6','13','14','15','17','19','20','22','23','27','28','29','67','71','72','75','77','78','80','83',
		    '88','90','91','93','94','97','101','108','111','116','117','118','119'

回流获取
select day_time,sum(recovery_count)
from
(
select a.dates as day_time, a.role_id as role_id,recovery_count,datediff(b.dates,a.dates) as by_day
from
(SELECT role_id,to_date(cast(date_time as timestamp)) as dates
FROM fairy_town_server.server_gold_recovery
WHERE server_id IN (10001,10002,10003)
AND day_time >= 20220203 and day_time <= 20220209
and recovery_method = '116') as a

left join

(select  role_id,to_date(cast(date_time as timestamp)) as dates,recovery_count
from fairy_town_server.server_gem_recovery
where server_id IN (10001,10002,10003)
and recovery_method in ('116','117','118','119') ) as b
on a.role_id = b.role_id
) as aa where by_day <= 7
group by 1 order by 1




免费行为获取

select day_time,sum(recovery_count)
from
(
select a.dates as day_time, a.role_id as role_id, recovery_count,datediff(b.dates,a.dates) as by_day
from

(SELECT role_id,to_date(cast(date_time as timestamp)) as dates
FROM fairy_town_server.server_gold_recovery
WHERE server_id IN (10001,10002,10003)
AND day_time >= 20220203 and day_time <= 20220209
and recovery_method = '116' GROUP BY 1,2) as a

left join

(select role_id,to_date(cast(date_time as timestamp)) as dates, recovery_count
from fairy_town_server.server_gold_recovery
where server_id IN (10001,10002,10003)
and recovery_method in ('4','5','6','13','14','15','17','19','20','22','23','27','28','29','67','71','72','75','77','78','80','83',
		               '88','90','91','93','94','97','101','108','111','116','117','118','119') group by 1,2,3) as b

on a.role_id = b.role_id
group by 1,2,3,4

) as aa where by_day <= 6

group by 1 
order by 1





select a.day_time,sum(recovery_count)
from

(
select day_time,role_id
from
(
select a.dates as day_time, a.role_id as role_id,datediff(b.dates,a.dates) as by_day
from

(SELECT role_id,to_date(cast(date_time as timestamp)) as dates
FROM fairy_town_server.server_gold_recovery
WHERE server_id IN (10001,10002,10003)
AND day_time >= 20220203 and day_time <= 20220209
and recovery_method = '116' GROUP BY 1,2) as a

left join

(select role_id,to_date(cast(date_time as timestamp)) as dates
from fairy_town_server.server_gold_recovery
where server_id IN (10001,10002,10003)
and recovery_method in ('4','5','6','13','14','15','17','19','20','22','23','27','28','29','67','71','72','75','77','78','80','83',
		               '88','90','91','93','94','97','101','108','111','116','117','118','119') group by 1,2,3) as b

on a.role_id = b.role_id
group by 1,2,3,4

) as aa 
where by_day <= 6
) as a

left join 

(select role_id,to_date(cast(date_time as timestamp)) as dates,recovery_count
from fairy_town_server.server_gold_recovery
where server_id IN (10001,10002,10003)
and recovery_method in ('4','5','6','13','14','15','17','19','20','22','23','27','28','29','67','71','72','75','77','78','80','83',
		               '88','90','91','93','94','97','101','108','111','116','117','118','119') group by 1,2,3) as b
on a.role_id = b.role_id and a.day_time = b.dates
group by 1 order by 1






select sum(recovery_count)
from fairy_town_server.server_gold_recovery
where recovery_method in ('4','5','6','13','14','15','17','19','20','22','23','27','28','29','67','71','72','75','77','78','80','83',
		               '88','90','91','93','94','97','101','108','111','116','117','118','119')
and role_id in (SELECT distinct role_id
			FROM fairy_town_server.server_gold_recovery
			WHERE server_id IN (10001,10002,10003)
			AND day_time = 20220203
			and recovery_method = '116')
and day_time >= 20220203 and day_time <= 20220209





-- --消耗
select day_time,sum(consume_count)
from
(
select a.dates as day_time, a.role_id as role_id,consume_count,datediff(b.dates,a.dates) as by_day
from
(SELECT role_id,to_date(cast(date_time as timestamp)) as dates
FROM fairy_town_server.server_gold_recovery
WHERE server_id IN (10001,10002,10003)
AND day_time >= 20220203 and day_time <= 20220209
and recovery_method = '116') as a

left join

(select  role_id,to_date(cast(date_time as timestamp)) as dates,consume_count
from fairy_town_server.server_gem_consume
where server_id IN (10001,10002,10003)
) as b
on a.role_id = b.role_id
) as aa where by_day <= 7
group by 1 order by 1



没回流活动


select day_time,sum(recovery_count)
from
(
select a.dates as day_time, a.role_id as role_id,recovery_count,datediff(b.dates,a.dates) as by_day
from
(select role_id,dates
from
(select dates,role_id,dgsc
from
(
SELECT dates, role_id, date_scdl, -- 上次登录时间 
DATEDIFF( dates, date_scdl ) AS dgsc -- 未登录时长 = 本次登录时间-上次登录时间 
FROM (SELECT dates, role_id, LAG ( dates,1) OVER ( PARTITION BY role_id ORDER BY dates ) as date_scdl FROM 
	(select to_date(cast(date_time as timestamp)) as dates, role_id from fairy_town.server_role_login where day_time >= 20210420 and day_time <= 20220107
	 and server_id IN (10001,10002,10003)) as aa
	) a
) as b 
where dgsc >= 15 and dates >= '2022-01-01' and dates <= '2022-01-07'
group by 1,2,3
order by 1
) as c) as a

left join

(select  role_id,to_date(cast(date_time as timestamp)) as dates,recovery_count
from fairy_town_server.server_gem_recovery
where server_id IN (10001,10002,10003)
and recovery_method in ('4','5','6','13','14','15','17','19','20','22','23','27','28','29','67','71','72','75','77','78','80','83',
		               '88','90','91','93','94','97','101','108','111','116','117','118','119') ) as b
on a.role_id = b.role_id
) as aa where by_day <= 7
group by 1 order by 1



-- 消耗

select day_time,sum(consume_count)
from
(
select a.dates as day_time, a.role_id as role_id,consume_count,datediff(b.dates,a.dates) as by_day
from
(select role_id,dates
from
(select dates,role_id,dgsc
from
(
SELECT dates, role_id, date_scdl, -- 上次登录时间 
DATEDIFF( dates, date_scdl ) AS dgsc -- 未登录时长 = 本次登录时间-上次登录时间 
FROM (SELECT dates, role_id, LAG ( dates,1) OVER ( PARTITION BY role_id ORDER BY dates ) as date_scdl FROM 
	(select to_date(cast(date_time as timestamp)) as dates, role_id from fairy_town.server_role_login where day_time >= 20210420 and day_time <= 20220107
	 and server_id IN (10001,10002,10003)) as aa
	) a
) as b 
where dgsc >= 15 and dates >= '2022-01-01' and dates <= '2022-01-07'
group by 1,2,3
order by 1
) as c) as a

left join

(select  role_id,to_date(cast(date_time as timestamp)) as dates,consume_count
from fairy_town_server.server_gem_consume
where server_id IN (10001,10002,10003)
 ) as b
on a.role_id = b.role_id
) as aa where by_day <= 7
group by 1 order by 1


**************************************************************************************************************************











在线时长、登录次数
回流
登陆次数
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
        day_time >= 20220126
        and day_time <= 20220213
        and server_id IN (10001,10002,10003)
        and role_id in
        (SELECT distinct role_id FROM fairy_town_server.server_gold_recovery
		WHERE server_id IN (10001,10002,10003)
		AND day_time >= 20220126 and day_time <= 20220213
		and recovery_method = '116'
        )
    group by 1,2
    ) a
group by day_time
order by day_time


-- 在线时长
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
        day_time >= 20220126
        and day_time <= 20220213
        and server_id IN (10001,10002,10003)
        and role_id in
        (SELECT distinct role_id FROM fairy_town_server.server_gold_recovery
		WHERE server_id IN (10001,10002,10003)
		AND day_time >= 20220126 and day_time <= 20220213
		and recovery_method = '116'
        )
    group by 1,2
) a
group by day_time
order by day_time



角色新增
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
        day_time >= 20220126
        and day_time <= 20220213
        and server_id IN (10001,10002,10003)
        and role_id in
        (SELECT distinct role_id FROM fairy_town.server_role_create
		WHERE server_id IN (10001,10002,10003)
		AND day_time >= 20220126 and day_time <= 20220213
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
        day_time >= 20220126
        and day_time <= 20220213
        and server_id IN (10001,10002,10003)
        and role_id in
        (SELECT distinct role_id FROM fairy_town.server_role_create
		WHERE server_id IN (10001,10002,10003)
		AND day_time >= 20220126 and day_time <= 20220213
        )
    group by 1,2
) a
group by day_time
order by day_time




连续15天未登录 等级大于等于4级 
select dates,count(distinct role_id)
from
(select dates,role_id,dgsc
from
(
SELECT dates, role_id, date_scdl, -- 上次登录时间 
DATEDIFF( dates, date_scdl ) AS dgsc -- 未登录时长 = 本次登录时间-上次登录时间 
FROM (SELECT dates, role_id, LAG ( dates,1) OVER ( PARTITION BY role_id ORDER BY dates ) as date_scdl FROM 
	(select to_date(cast(date_time as timestamp)) as dates, role_id from fairy_town.server_role_login where day_time >= 20210420 and day_time <= 20220119
	 and server_id IN (10001,10002,10003)) as aa
	) a
) as b 
where dgsc >= 15 and dates >= '2022-01-01' and dates <= '2022-01-19'
group by 1,2,3
order by 1
) as c
group by 1 order by 1





没有回流活动期间留存
select
    b.day_time_a as day_time,
    sum(case when by_day = 0 then 1 else 0 end) '新增',
    sum(case when by_day = 1 then 1 else 0 end) day_2,
    sum(case when by_day = 2 then 1 else 0 end) day_3,
    sum(case when by_day = 3 then 1 else 0 end) day_4,
    sum(case when by_day = 4 then 1 else 0 end) day_5,
    sum(case when by_day = 5 then 1 else 0 end) day_6,
    sum(case when by_day = 6 then 1 else 0 end) day_7
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
            a.dates as day_time_a,
            b.day_times as day_time_b
        from
            (
             SELECT role_id,
                    to_date(cast(date_time as timestamp)) as day_times
             FROM fairy_town.server_role_login
             WHERE server_id IN (10001,10002,10003)
             AND day_time >= 20220101 and day_time <= 20220119
             group by 1,2
            ) b 
        right join 
            (select role_id,dates
			from
			(select dates,role_id,dgsc
			from
			(
			SELECT dates, role_id, date_scdl, -- 上次登录时间 
			DATEDIFF( dates, date_scdl ) AS dgsc -- 未登录时长 = 本次登录时间-上次登录时间 
			FROM (SELECT dates, role_id, LAG ( dates,1) OVER ( PARTITION BY role_id ORDER BY dates ) as date_scdl FROM 
				(select to_date(cast(date_time as timestamp)) as dates, role_id from fairy_town.server_role_login where day_time >= 20210420 and day_time <= 20220119
				 and server_id IN (10001,10002,10003)) as aa
				) a
			) as b 
			where dgsc >= 15 and dates >= '2022-01-01' and dates <= '2022-01-19'
			group by 1,2,3
			order by 1
			) as c
			group by 1,2 order by 2
            ) a
            on a.role_id = b.role_id
        ) as reu
    order by 1,3      
) as b

group by 1
order by 1


LTV没回流活动
select
	a.dates_a as dates,
	-- channel_id,
	round(sum(if(datediff(dates_b,dates_a)=0, pay_price_2, 0)),2) as day1,
	round(sum(if(datediff(dates_b,dates_a)<=2, pay_price_2, 0)),2) as day3,
	round(sum(if(datediff(dates_b,dates_a)<=6, pay_price_2, 0)),2) as day7
from
	(
	select
		op1.role_id as role_id,
		op1.dates as dates_a,
		op2.dates as dates_b,
		op2.pay_price as pay_price_2,
		datediff(op2.dates,op1.dates) as p,
		channel_id
	from
		(
			select role_id,channel_id, dates
			from
			(select dates,role_id,dgsc,channel_id
			from
			(
			SELECT dates, role_id,channel_id, date_scdl, -- 上次登录时间 
			DATEDIFF( dates, date_scdl ) AS dgsc -- 未登录时长 = 本次登录时间-上次登录时间 
			FROM (SELECT dates, role_id,channel_id, LAG ( dates,1) OVER ( PARTITION BY role_id ORDER BY dates ) as date_scdl FROM 
				(select to_date(cast(date_time as timestamp)) as dates,channel_id, role_id from fairy_town.server_role_login where day_time >= 20210420 and day_time <= 20220119
				 and server_id IN (10001,10002,10003)) as aa
				) a
			) as b 
			where dgsc >= 15 and dates >= '2022-01-01' and dates <= '2022-01-19'
			) as c

		) as op1 ,
		(select
			role_id,
			sum(pay_price) as pay_price,
			to_date(cast(date_time as timestamp)) as dates
		 from
			fairy_town.order_pay
		 where
		 	day_time >= 20220101 and day_time <= 20220119
		 group by role_id,dates
		 ) as op2 
	where op1.role_id = op2.role_id and op2.dates >= op1.dates
	) as a	
group by 1
order by 1



select day_time, count(distinct role_id) from fairy_town_server.server_gold_recovery
where day_time >= 20220126 and day_time <= 20220213 
and server_id in (10001,10002,10003) and recovery_method = '116'
and role_id in (select distinct role_id from fairy_town.order_pay where day_time < 20220120)
group by 1
order by 1 





















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
        day_time >= 20220101
        and day_time <= 20220119
        and server_id IN (10001,10002,10003)
        and role_id in
        (select distinct role_id
				from

				(select dates,role_id,dgsc
				from
				(
				SELECT dates, role_id, date_scdl, -- 上次登录时间 
				DATEDIFF( dates, date_scdl ) AS dgsc -- 未登录时长 = 本次登录时间-上次登录时间 
				FROM (SELECT dates, role_id, LAG ( dates,1) OVER ( PARTITION BY role_id ORDER BY dates ) as date_scdl FROM 
					(select to_date(cast(date_time as timestamp)) as dates, role_id from fairy_town.server_role_login where day_time >= 20210420 and day_time <= 20220119
					 and server_id IN (10001,10002,10003)) as aa
					) a
				) as b 
				where dgsc >= 15 and dates >= '2022-01-01' and dates <= '2022-01-19'
				group by 1,2,3
				order by 1
				) as c
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
        day_time >= 20220101
        and day_time <= 20220119
        and server_id IN (10001,10002,10003)
        and role_id in
        (select distinct role_id
				from

				(select dates,role_id,dgsc
				from
				(
				SELECT dates, role_id, date_scdl, -- 上次登录时间 
				DATEDIFF( dates, date_scdl ) AS dgsc -- 未登录时长 = 本次登录时间-上次登录时间 
				FROM (SELECT dates, role_id, LAG ( dates,1) OVER ( PARTITION BY role_id ORDER BY dates ) as date_scdl FROM 
					(select to_date(cast(date_time as timestamp)) as dates, role_id from fairy_town.server_role_login where day_time >= 20210420 and day_time <= 20220119
					 and server_id IN (10001,10002,10003)) as aa
					) a
				) as b 
				where dgsc >= 15 and dates >= '2022-01-01' and dates <= '2022-01-19'
				group by 1,2,3
				order by 1
				) as c
        )
    group by 1,2
) a
group by day_time
order by day_time



