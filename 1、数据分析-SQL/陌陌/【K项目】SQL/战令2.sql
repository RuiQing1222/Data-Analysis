-- 第二期
-- 12.9  12：00 -  1.4 3：00 
战令数据

1639022400000   -   1641236400000

总渗透率

-- 分母  打开战令任务 或者 完成一个任务
-- 打开战令任务
SELECT 
    count(distinct role_id)
from 
    fairy_town_server.server_battle_pass_task_open
where
    server_id in (10001,10002,10003) 
    and day_time >= 20211209 and day_time <= 20220104

分平台
SELECT 
    channel_id,
    count(distinct role_id)
from 
    fairy_town_server.server_battle_pass_task_open
where
    server_id in (10001,10002,10003) 
    and day_time >= 20211209 and day_time <= 20220104
GROUP BY 1


-- 分子  买战令的人
select
    count(distinct role_id)
from 
    fairy_town.order_pay
where
    server_id in (10001,10002,10003) 
    and log_time >= 1639022400000 and log_time <= 1641236400000
    and product_name = '战令'

分平台
select
    channel_id,
    count(distinct role_id)
from 
    fairy_town.order_pay
where
    server_id in (10001,10002,10003) 
    and log_time >= 1639022400000 and log_time <= 1641236400000
    and product_name = '战令'
group by 1


-- 完成一个任务
select 
    count(distinct role_id)
from 
    fairy_town_server.server_battle_pass_task_completed
where
    server_id in (10001,10002,10003) 
    and day_time >= 20211209 and day_time <= 20220104

 分平台
 select 
    channel_id,
    count(distinct role_id)
from 
    fairy_town_server.server_battle_pass_task_completed
where
    server_id in (10001,10002,10003) 
    and day_time >= 20211209 and day_time <= 20220104
group by 1


# 商店9.9美金  230宝石  com.managames.fairytown.iap_9.99a

SELECT 
    channel_id,
    count(distinct role_id)
from 
    fairy_town_server.server_battle_pass_task_completed
where
    server_id in (10001,10002,10003) 
    and log_time >= 1639022400000 and log_time <= 1641236400000
    and role_id in (select distinct role_id from fairy_town.order_pay where game_product_id = 'com.managames.fairytown.iap_9.99a')
GROUP BY 1


-- 宝石月卡   com.managames.fairytown.iap_9.99e
SELECT 
    channel_id,
    count(distinct role_id)
from 
    fairy_town_server.server_battle_pass_task_completed
where
    server_id in (10001,10002,10003) 
    and log_time >= 1639022400000 and log_time <= 1641236400000
    and role_id in (select distinct role_id from fairy_town.order_pay where game_product_id = 'com.managames.fairytown.iap_9.99e')
GROUP BY 1




历史付费用户在战令期间活跃
select
    count(case when pay_sum >= 30 then role_id end) as '大R(>=$30)'
    ,count(case when pay_sum > 10 and pay_sum < 30 then role_id end) as '中R(>$10 & < $30)'
    ,count(case when pay_sum <= 10 then role_id end) as '小R(<=$10)'
from
(

select
    role_id
    ,sum(pay_price)  as pay_sum
from
    fairy_town.order_pay
where
    day_time <= 20220104
    and role_id in 
    (select role_id from (select distinct role_id from fairy_town.server_role_login where day_time >= 20211209 and day_time <= 20220104 and role_level >= 9
                    union all 
                    select distinct role_id from fairy_town.server_role_upgrade where day_time >= 20211209 and day_time <= 20220104 and role_level >= 9) w
    )
group by 1

) a



-- channel_id 平台 role_id 注册时间 是否活动期内 最后登录日期 是否流失 国家  历史总付费（4.20开始） 首次付费 购买日期  打开面板最早日期  打开面板时间戳 
-- 完成第一个任务的日期 做任务时间戳 做任务天数 完成任务数  登录天数

购买用户
select
    channel_id, 
    case when channel_id = 1000 then '安卓'
            when channel_id = 2000 then 'iOS' 
            end as '平台' ,a.role_id,birth_dt as '注册时间',
    case when birth_dt >= '2021-12-09' and birth_dt <= '2022-01-04' then '活动内'
         else '活动之前'
         end as '是否活动期内',
     最后登录日期,
    case when 最后登录日期 < '2021-12-30' then '流失'
         else '留存'
         end as '是否流失', 
     country,total_pay as '历史总付费',
     case when product_name='战令'   then '首次'
     when product_name <>'战令' then '非首次'
     end as '首次购买',
    --  bp_level as '战令等级',
     购买日期,购买时间戳,
     打开面板的最早日期,打开面板时间戳,
     做任务的最早日期,做任务最早时间戳,
     day_num as '做任务天数', tasks as '完成任务数', 登录天数
from 
(
select role_id,to_date(cast (date_time as timestamp)) as '购买日期',log_time as '购买时间戳'
from fairy_town.order_pay
where day_time>=20211209 and day_time<=${endDate} 
and server_id in (10001,10002,10003)
and product_name='战令'
) a 
left join 
(
select role_id ,channel_id,country,to_date(cast (date_time as timestamp)) as birth_dt
from fairy_town.server_role_create
where day_time>=20210420 and day_time<=${endDate} 
and server_id in (10001,10002,10003)
) b 
on a.role_id=b.role_id 
left join 
(select role_id,product_name from 
(
select role_id,product_name,row_number()over(partition by role_id order by log_time asc) as row_num1
from fairy_town.order_pay
where day_time>=20210420 and day_time<=${endDate} 
and server_id in (10001,10002,10003)
) c1 
where row_num1=1
) c 
on a.role_id=c.role_id 
left join 
(
select role_id,sum(pay_price) as total_pay
from fairy_town.order_pay
where  day_time>=20210420 and day_time<=${endDate} 
and log_time<=1641236400000
group by 1
) d 
on a.role_id=d.role_id 
left join 
(select role_id,做任务的最晚日期,做任务最晚时间戳 from 
(select role_id,to_date(cast (date_time as timestamp))  as '做任务的最晚日期',log_time as '做任务最晚时间戳' , row_number() over(partition by role_id order by log_time desc) as row_num2
from fairy_town_server.server_battle_pass_points 
where day_time>=20211209 and day_time<=${endDate} 
and server_id in (10001,10002,10003)
) e1
where row_num2=1
) e 
on a.role_id=e.role_id 
left join 
(select role_id,做任务的最早日期,做任务最早时间戳 from 
(select role_id,to_date(cast (date_time as timestamp))  as '做任务的最早日期',log_time as '做任务最早时间戳' , row_number() over(partition by role_id order by log_time asc) as row_num2
from fairy_town_server.server_battle_pass_points 
where day_time>=20211209 and day_time<=${endDate} 
and server_id in (10001,10002,10003)
) f1
where row_num2=1
) f 
on a.role_id=f.role_id 
left join 
(select role_id,count(distinct day_time) as day_num,count(distinct task_id) as tasks 
from fairy_town_server.server_battle_pass_task_completed 
where day_time>=20211209 and day_time<=${endDate} 
and server_id in (10001,10002,10003)
group by 1
) g
on a.role_id=g.role_id
left join 
(select role_id,打开面板的最早日期,打开面板时间戳  from 
(select role_id,to_date(cast (date_time as timestamp))  as '打开面板的最早日期',log_time as '打开面板时间戳' , row_number()over(partition by role_id order by log_time asc) as row_num3
from fairy_town_server.server_battle_pass_task_open 
where day_time>=20211209 and day_time<=${endDate} 
and server_id in (10001,10002,10003)
) h1
where row_num3=1
) h 
on a.role_id=h.role_id 
left join 
(select role_id,count(distinct day_time ) as '登录天数' 
from fairy_town.server_role_login
where day_time>=20211209 and day_time<=${endDate} 
and server_id in (10001,10002,10003)
group by 1
) i
on a.role_id=i.role_id 
left join 
(select role_id,max(to_date(cast (date_time as timestamp))) as '最后登录日期'
from fairy_town.server_role_login
where day_time>=20211209 and day_time<=${endDate} 
and server_id in (10001,10002,10003)
group by 1
) j
on a.role_id=j.role_id 






每日战令购买
SELECT day_time,
       sum(pay_price)
FROM fairy_town.order_pay
WHERE day_time>=20211209
  AND day_time<=20220104
  AND server_id IN (10001,10002,10003)
  AND product_name = '战令'
GROUP BY 1
ORDER BY 1




战令等级数据
-- 买战令的人
select distinct role_id from order_pay where server_id in (10001,10002,10003) and day_time >= 20211209 and day_time <= 20220104 and product_name = '战令'
-- 参与战令但是没买战令
select 
    distinct role_id
from 
    fairy_town_server.server_battle_pass_task_completed
where
    server_id in (10001,10002,10003) 
    and day_time >= 20211209 and day_time <= 20220104
    and role_id not in (select distinct role_id from fairy_town.order_pay where server_id in (10001,10002,10003) and day_time >= 20211209 and day_time <= 20220104 and product_name = '战令')




几天达到满级 从点开任务开始到满级的时间 买/没买战令的
SELECT
    a.role_id,
    (a.min_log_time - b.min_log_time) / 1000 / 3600 / 24
from

(
SELECT
    min(log_time) as min_log_time,
    role_id
from
    fairy_town_server.server_battle_pass_points
where 
    server_id in (10001,10002,10003) 
    and day_time >= 20211209 and day_time <= 20220104
    and battle_pass_level = 25
    and role_id in (select distinct role_id from fairy_town.order_pay where server_id in (10001,10002,10003) and day_time >= 20211209 and day_time <= 20220104 and product_name = '战令')
group by 2
) a
left join
(
SELECT 
    min(log_time) as min_log_time,
    role_id
from 
    fairy_town_server.server_battle_pass_points
where
    server_id in (10001,10002,10003) 
    and day_time >= 20211209 and day_time <= 20220104
    and role_id in (select distinct role_id from fairy_town.order_pay where server_id in (10001,10002,10003) and day_time >= 20211209 and day_time <= 20220104 and product_name = '战令')
GROUP BY 2
) b
on a.role_id = b.role_id


没买战令的计算sql，买战令的在宽表里面计算

-- 任务天数分布
select
    count(distinct case when tian <=0 then role_id end) as '0'
    ,count(distinct case when tian >0 and tian <=7 then role_id end) as '1--7'
    ,count(distinct case when tian >7 and tian <=14 then role_id end) as '8--14'
    ,count(distinct case when tian >14 and tian <=19 then role_id end) as '15--19'
    ,count(distinct case when tian >19 and tian <=25 then role_id end) as '20--25'
    ,count(distinct case when tian >25 then role_id end) as '26'
from
(

SELECT
    r1.role_id as role_id,
    ((r2.log_time - r1.log_time) / 1000 /3600 / 24)  as tian
from
(SELECT
    role_id,
    log_time
from
(
SELECT
    role_id
    ,log_time
    ,row_number() over(partition by role_id order by log_time asc) as ranks_min
from 
    fairy_town_server.server_battle_pass_task_completed
where
    server_id in (10001,10002,10003) 
    and day_time >= 20211209 and day_time <= 20220104
    and role_id not in (select distinct role_id from fairy_town.order_pay where server_id in (10001,10002,10003) and day_time >= 20211209 and day_time <= 20220104 and product_name = '战令')
) as a
where ranks_min = 1) as r1
join
(SELECT
    role_id,
    log_time
from
(
SELECT
    role_id
    ,log_time
    ,row_number() over(partition by role_id order by log_time desc) as ranks_max
from 
    fairy_town_server.server_battle_pass_task_completed
where
    server_id in (10001,10002,10003) 
    and day_time >= 20211209 and day_time <= 20220104
    and role_id not in (select distinct role_id from fairy_town.order_pay where server_id in (10001,10002,10003) and day_time >= 20211209 and day_time <= 20220104 and product_name = '战令')
) as a
where ranks_max = 1) as r2
on r1.role_id = r2.role_id
) as b



-- 完成任务数占比
select
    count(case when task_num >=0 and task_num <=9 then role_id end) as '0--9'
    ,count(case when task_num >=10 and task_num <=19 then role_id end) as '10--19'
    ,count(case when task_num >=20 and task_num <=29 then role_id end) as '20--29'
    ,count(case when task_num >=30 and task_num <=39 then role_id end) as '30--39'
    ,count(case when task_num >=40 and task_num <=49 then role_id end) as '40--49'
    ,count(case when task_num >=50 and task_num <=59 then role_id end) as '50--59'
    ,count(case when task_num >=60 and task_num <=69 then role_id end) as '60--69'
    ,count(case when task_num >=70 and task_num <=79 then role_id end) as '70--79'
    ,count(case when task_num >=80 and task_num <=89 then role_id end) as '80--89'
    ,count(case when task_num >=90 then role_id end) as '90+'
from 
    (
    SELECT
        role_id
        ,count(task_id) as task_num
    from 
        fairy_town_server.server_battle_pass_task_completed 
    where
        server_id in (10001,10002,10003) 
        and day_time >= 20211209 and day_time <= 20220104
        and role_id not in (select distinct role_id from fairy_town.order_pay where server_id in (10001,10002,10003) and day_time >= 20211209 and day_time <= 20220104 and product_name = '战令')
    GROUP BY 1
    ) as a



任务完成率
select a.task_id as '任务ID',
       a.get_num as '总接取人数',
       b.compleyed_num as '总完成人数',
       c.get_num as '购买战令_接取人数',
       d.compleyed_num as '购买战令_完成人数',
       e.get_num as '未购买战令_接取人数',
       f.compleyed_num as '未购买战令_完成人数'
from

-- 总体
(select cast(task_id as int) as task_id,count(role_id) as get_num -- 接取人数
from fairy_town_server.server_battle_pass_task_triggered
where server_id in (10001,10002,10003) and day_time >= 20211209 and day_time <= 20220104
group by 1
order by 1) as a
left join
(select cast(task_id as int) as task_id,count(role_id) as compleyed_num -- 完成人数
from fairy_town_server.server_battle_pass_task_completed
where server_id in (10001,10002,10003) and day_time >= 20211209 and day_time <= 20220104
group by 1
order by 1) as b
on a.task_id = b.task_id

-- 购买战令
left join
(select cast(task_id as int) as task_id,count(role_id) as get_num -- 接取人数
from fairy_town_server.server_battle_pass_task_triggered
where server_id in (10001,10002,10003) and day_time >= 20211209 and day_time <= 20220104
and role_id in (select distinct role_id from fairy_town.order_pay where server_id in (10001,10002,10003) and day_time >= 20211209 and day_time <= 20220104 and product_name = '战令')
group by 1
order by 1) as c
on a.task_id = c.task_id

left join
(select cast(task_id as int) as task_id,count(role_id) as compleyed_num -- 完成人数
from fairy_town_server.server_battle_pass_task_completed
where server_id in (10001,10002,10003) and day_time >= 20211209 and day_time <= 20220104
and role_id in (select distinct role_id from fairy_town.order_pay where server_id in (10001,10002,10003) and day_time >= 20211209 and day_time <= 20220104 and product_name = '战令')
group by 1
order by 1) as d
on a.task_id = d.task_id

-- 未购买战令
left join
(select cast(task_id as int) as task_id,count(role_id) as get_num -- 接取人数
from fairy_town_server.server_battle_pass_task_triggered
where server_id in (10001,10002,10003) and day_time >= 20211209 and day_time <= 20220104
and role_id in (select distinct role_id from fairy_town_server.server_battle_pass_task_triggered
                where
                    server_id in (10001,10002,10003) 
                    and day_time >= 20211209 and day_time <= 20220104
                    and role_id not in 
                    (select distinct role_id from fairy_town.order_pay where server_id in (10001,10002,10003) and day_time >= 20211209 and day_time <= 20220104 and product_name = '战令')
               )
group by 1
order by 1) as e
on a.task_id = e.task_id

left join
(select cast(task_id as int) as task_id,count(role_id) as compleyed_num -- 完成人数
from fairy_town_server.server_battle_pass_task_completed
where server_id in (10001,10002,10003) and day_time >= 20211209 and day_time <= 20220104
and role_id in (select distinct role_id from fairy_town_server.server_battle_pass_task_completed
                where
                    server_id in (10001,10002,10003) 
                    and day_time >= 20211209 and day_time <= 20220104
                    and role_id not in 
                    (select distinct role_id from fairy_town.order_pay where server_id in (10001,10002,10003) and day_time >= 20211209 and day_time <= 20220104 and product_name = '战令')
               )
group by 1
order by 1) as f
on a.task_id = f.task_id

order by 1













战令效果
-- 买战令的人
select distinct role_id from fairy_town.order_pay where server_id in (10001,10002,10003) and day_time >= 20211209 and day_time <= 20220104 and product_name = '战令'
-- 参与战令但是没买战令
select 
    distinct role_id
from 
    fairy_town_server.server_battle_pass_task_completed
where
    server_id in (10001,10002,10003) 
    day_time >= ${start_time} and day_time <= ${end_time}
    and role_id not in (select distinct role_id from fairy_town.order_pay where server_id in (10001,10002,10003) and day_time >= ${start_time} and day_time <= ${end_time} and product_name = '战令')




购买战令
活跃
-- 新
SELECT count(DISTINCT role_id) FROM fairy_town.server_role_login WHERE server_id IN (10001,10002,10003)
and day_time >= ${start_time} and day_time <= ${end_time}
AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE day_time >= ${start_time} and day_time <= ${end_time}) 
and role_id in (select distinct role_id from fairy_town.order_pay where server_id in (10001,10002,10003) and day_time >= ${start_time} and day_time <= ${end_time} and product_name = '战令')

-- 老
SELECT count(DISTINCT role_id) FROM fairy_town.server_role_login WHERE server_id IN (10001,10002,10003)
AND day_time >= ${start_time} and day_time <= ${end_time}
AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE day_time < ${start_time}) 
and role_id in (select distinct role_id from fairy_town.order_pay where server_id in (10001,10002,10003) and day_time >= ${start_time} and day_time <= ${end_time} and product_name = '战令')


充值人数
-- 新
SELECT count(DISTINCT role_id)
FROM fairy_town.order_pay
WHERE server_id IN (10001,10002,10003)
    and day_time >= ${start_time} and day_time <= ${end_time}
    AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE day_time >= ${start_time} and day_time <= ${end_time}) 
    and role_id in (select distinct role_id from fairy_town.order_pay where server_id in (10001,10002,10003) and day_time >= ${start_time} and day_time <= ${end_time} and product_name = '战令')


-- 老
SELECT count(DISTINCT role_id)
FROM fairy_town.order_pay
WHERE server_id IN (10001,10002,10003)
    AND day_time >= ${start_time} and day_time <= ${end_time}
    AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE day_time < ${start_time}) 
    and role_id in (select distinct role_id from fairy_town.order_pay where server_id in (10001,10002,10003) and day_time >= ${start_time} and day_time <= ${end_time} and product_name = '战令')


充值金额

-- 新
SELECT sum(pay_price)
    FROM fairy_town.order_pay
WHERE server_id IN (10001,10002,10003)
    and day_time >= ${start_time} and day_time <= ${end_time}
    AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE day_time >= ${start_time} and day_time <= ${end_time}) 
    and role_id in (select distinct role_id from fairy_town.order_pay where server_id in (10001,10002,10003) and day_time >= ${start_time} and day_time <= ${end_time} and product_name = '战令')

-- 老
SELECT sum(pay_price)
    FROM fairy_town.order_pay
WHERE server_id IN (10001,10002,10003)
AND day_time >= ${start_time} and day_time <= ${end_time}
AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE day_time < ${start_time}) 
and role_id in (select distinct role_id from fairy_town.order_pay where server_id in (10001,10002,10003) and day_time >= ${start_time} and day_time <= ${end_time} and product_name = '战令')




同时参与两期战令的用户
购买
select count(distinct a.role_id) from
(select distinct role_id from fairy_town.order_pay where server_id in (10001,10002,10003) and day_time >= 20211022 and day_time <= 20211117 and product_name = '战令') as a
join
(select distinct role_id from fairy_town.order_pay where server_id in (10001,10002,10003) and day_time >= 20211209 and day_time <= 20220104 and product_name = '战令') as b
on a.role_id = b.role_id

充值金额
SELECT sum(pay_price)
    FROM fairy_town.order_pay
WHERE server_id IN (10001,10002,10003)
    and day_time >= ${start_time} and day_time <= ${end_time}
    and role_id in (select distinct a.role_id from
                    (select distinct role_id from fairy_town.order_pay where server_id in (10001,10002,10003) and day_time >= 20211022 and day_time <= 20211117 and product_name = '战令') as a
                    join
                    (select distinct role_id from fairy_town.order_pay where server_id in (10001,10002,10003) and day_time >= 20211209 and day_time <= 20220104 and product_name = '战令') as b
                    on a.role_id = b.role_id)

没购买战令

select count(distinct a.role_id) from
(select 
    distinct role_id
from 
    fairy_town_server.server_battle_pass_task_completed
where
    server_id in (10001,10002,10003) 
    and day_time >= 20211022 and day_time <= 20211117
    and role_id not in (select distinct role_id from fairy_town.order_pay where server_id in (10001,10002,10003) and day_time >= 20211022 and day_time <= 20211117 and product_name = '战令')
) as a
join
(select 
    distinct role_id
from 
    fairy_town_server.server_battle_pass_task_completed
where
    server_id in (10001,10002,10003) 
    and day_time >= 20211209 and day_time <= 20220104
    and role_id not in (select distinct role_id from fairy_town.order_pay where server_id in (10001,10002,10003) and day_time >= 20211209 and day_time <= 20220104 and product_name = '战令')
) as b
on a.role_id = b.role_id



充值人数
SELECT count(DISTINCT role_id)
FROM fairy_town.order_pay
WHERE server_id IN (10001,10002,10003)
    AND day_time >= ${start_time} and day_time <= ${end_time}
    and role_id in (
                    select distinct a.role_id from
                        (select 
                            distinct role_id
                        from 
                            fairy_town_server.server_battle_pass_task_completed
                        where
                            server_id in (10001,10002,10003) 
                            and day_time >= 20211022 and day_time <= 20211117
                            and role_id not in (select distinct role_id from fairy_town.order_pay where server_id in (10001,10002,10003) and day_time >= 20211022 and day_time <= 20211117 and product_name = '战令')
                        ) as a
                        join
                        (select 
                            distinct role_id
                        from 
                            fairy_town_server.server_battle_pass_task_completed
                        where
                            server_id in (10001,10002,10003) 
                            and day_time >= 20211209 and day_time <= 20220104
                            and role_id not in (select distinct role_id from fairy_town.order_pay where server_id in (10001,10002,10003) and day_time >= 20211209 and day_time <= 20220104 and product_name = '战令')
                        ) as b
                        on a.role_id = b.role_id
                    )

充值金额
SELECT sum(pay_price)
FROM fairy_town.order_pay
WHERE server_id IN (10001,10002,10003)
    AND day_time >= ${start_time} and day_time <= ${end_time}
    and role_id in (
                    select distinct a.role_id from
                        (select 
                            distinct role_id
                        from 
                            fairy_town_server.server_battle_pass_task_completed
                        where
                            server_id in (10001,10002,10003) 
                            and day_time >= 20211022 and day_time <= 20211117
                            and role_id not in (select distinct role_id from fairy_town.order_pay where server_id in (10001,10002,10003) and day_time >= 20211022 and day_time <= 20211117 and product_name = '战令')
                        ) as a
                        join
                        (select 
                            distinct role_id
                        from 
                            fairy_town_server.server_battle_pass_task_completed
                        where
                            server_id in (10001,10002,10003) 
                            and day_time >= 20211209 and day_time <= 20220104
                            and role_id not in (select distinct role_id from fairy_town.order_pay where server_id in (10001,10002,10003) and day_time >= 20211209 and day_time <= 20220104 and product_name = '战令')
                        ) as b
                        on a.role_id = b.role_id
                    )





上期购买战令的用户本期情况

select 
    count(distinct role_id)
from 
    fairy_town_server.server_battle_pass_task_completed
where
    server_id in (10001,10002,10003) 
    and day_time >= ${start_time} and day_time <= ${end_time}
    and role_id in (select distinct role_id from fairy_town.order_pay where server_id in (10001,10002,10003) and day_time >= 20211022 and day_time <= 20211117 and product_name = '战令')


select 
    count(distinct role_id)
from 
    fairy_town_server.server_battle_pass_task_completed
where
    server_id in (10001,10002,10003) 
    and day_time >= ${start_time} and day_time <= ${end_time}
and role_id in 
(
select 
    distinct role_id
from 
    fairy_town_server.server_battle_pass_task_completed
where
    server_id in (10001,10002,10003) 
    and day_time >= 20211022 and day_time <= 20211117
    and role_id not in (select distinct role_id from fairy_town.order_pay where server_id in (10001,10002,10003) and day_time >= 20211022 and day_time <= 20211117 and product_name = '战令')
)







美国  德国
select 
    country,
    count(distinct role_id)
from 
    fairy_town_server.server_battle_pass_task_completed
where
    server_id in (10001,10002,10003) 
    and day_time >= ${start_time} and day_time <= ${end_time}
    and country in ('US','DE')
    AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE day_time >= ${start_time} and day_time <= ${end_time}) 
    and role_id not in (select distinct role_id from fairy_town.order_pay where server_id in (10001,10002,10003) and day_time >= ${start_time} and day_time <= ${end_time} and product_name = '战令')
group by 1


select 
    country,
    count(distinct role_id)
from 
    fairy_town_server.server_battle_pass_task_completed
where
    server_id in (10001,10002,10003) 
    and day_time >= ${start_time} and day_time <= ${end_time}
    and country in ('US','DE')
    AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE day_time >= ${start_time} and day_time <= ${end_time}) 
    and role_id not in (select distinct role_id from fairy_town.order_pay where server_id in (10001,10002,10003) and day_time >= ${start_time} and day_time <= ${end_time} and product_name = '战令')
group by 1














战令效果

参与战令的用户
充值
select
    sum(pay_price)
from
    fairy_town.order_pay
where 
    server_id IN (10001,10002,10003)
    and role_id in 
    (select 
    distinct role_id
from 
    fairy_town_server.server_battle_pass_task_completed
where
    server_id in (10001,10002,10003) 
    and day_time >= 20211209 and day_time <= 20211026
    and role_id in (select role_id from fairy_town.server_role_login  where day_time>=20211017 and day_time<=20211021)
    and role_id in (select role_id from fairy_town.server_role_login  where day_time>=20211209 and day_time<=20211026))
    and day_time >= ${start_time}
    and day_time <= ${end_time}


活跃
select 
    count(distinct role_id)
from 
    fairy_town_server.server_battle_pass_task_completed
where
    server_id in (10001,10002,10003) 
    and day_time >= 20211209 and day_time <= 20211026
    and role_id in (select role_id from fairy_town.server_role_login  where day_time>=20211017 and day_time<=20211021)
    and role_id in (select role_id from fairy_town.server_role_login  where day_time>=20211209 and day_time<=20211026)


付费用户数
SELECT 
    count(DISTINCT role_id)
FROM 
    fairy_town.order_pay
WHERE 
    server_id IN (10001,10002,10003)
    and role_id in 
    (select distinct role_id from fairy_town_server.server_battle_pass_task_completed
    where
        server_id in (10001,10002,10003) 
        and day_time >= 20211209 and day_time <= 20211026
        and role_id in (select role_id from fairy_town.server_role_login  where day_time>=20211017 and day_time<=20211021)
        and role_id in (select role_id from fairy_town.server_role_login  where day_time>=20211209 and day_time<=20211026)
    )
    and day_time >= ${start_time}
    and day_time <= ${end_time}



购买战令的用户

充值
select
    sum(pay_price)
from
    fairy_town.order_pay
where 
    server_id IN (10001,10002,10003)
    and role_id in 
    (select distinct role_id
        from fairy_town.order_pay 
        where day_time>=20211209 and day_time<=20211026
        and product_name='战令'
        and role_id  in (select role_id from fairy_town.server_role_login  where day_time>=20211017 and day_time<=20211021)
        and role_id  in (select role_id from fairy_town.server_role_login  where day_time>=20211209 and day_time<=20211026)
        and role_id in (select distinct role_id from fairy_town_server.server_battle_pass_task_completed where server_id in (10001,10002,10003) and day_time >= 20211209 and day_time <= 20211026)
    )
    and day_time >= ${start_time}
    and day_time <= ${end_time}


活跃
select count(distinct role_id)
from fairy_town.order_pay 
where day_time>=20211209 and day_time<=20211026
and product_name='战令'
and role_id  in (select role_id from fairy_town.server_role_login  where day_time>=20211017 and day_time<=20211021)
and role_id  in (select role_id from fairy_town.server_role_login  where day_time>=20211209 and day_time<=20211026)
and role_id in (select distinct role_id from fairy_town_server.server_battle_pass_task_completed where server_id in (10001,10002,10003) and day_time >= 20211209 and day_time <= 20211026)


付费用户数
SELECT 
    count(DISTINCT role_id)
FROM 
    fairy_town.order_pay
WHERE 
    server_id IN (10001,10002,10003)
    and role_id in 
    (select distinct role_id
        from fairy_town.order_pay 
        where day_time>=20211209 and day_time<=20211026
        and product_name='战令'
        and role_id  in (select role_id from fairy_town.server_role_login  where day_time>=20211017 and day_time<=20211021)
        and role_id  in (select role_id from fairy_town.server_role_login  where day_time>=20211209 and day_time<=20211026)
        and role_id in (select distinct role_id from fairy_town_server.server_battle_pass_task_completed where server_id in (10001,10002,10003) and day_time >= 20211209 and day_time <= 20211026)
    )
    and day_time >= ${start_time}
    and day_time <= ${end_time}



未购买战令的用户

充值
select
    sum(pay_price)
from
    fairy_town.order_pay
where 
    server_id IN (10001,10002,10003)
    and role_id in 
    (select distinct role_id from fairy_town_server.server_battle_pass_task_completed
    where
        server_id in (10001,10002,10003) 
        and day_time >= 20211209 and day_time <= 20211026
        and role_id not in (select distinct role_id from fairy_town.order_pay where product_name = '战令' and day_time >= 20211209 and day_time <= 20211026)
        and role_id in (select role_id from fairy_town.server_role_login  where day_time>=20211017 and day_time<=20211021)
        and role_id in (select role_id from fairy_town.server_role_login  where day_time>=20211209 and day_time<=20211026)
    )
    and day_time >= ${start_time}
    and day_time <= ${end_time}


活跃
select 
    count(distinct role_id)
from 
    fairy_town_server.server_battle_pass_task_completed
    where
        server_id in (10001,10002,10003) 
        and day_time >= 20211209 and day_time <= 20211026
        and role_id not in (select distinct role_id from fairy_town.order_pay where product_name = '战令' and day_time >= 20211209 and day_time <= 20211026)
        and role_id in (select role_id from fairy_town.server_role_login  where day_time>=20211017 and day_time<=20211021)
        and role_id in (select role_id from fairy_town.server_role_login  where day_time>=20211209 and day_time<=20211026)


付费用户数
SELECT 
    count(DISTINCT role_id)
FROM 
    fairy_town.order_pay
WHERE 
    server_id IN (10001,10002,10003)
    and role_id in 
    (select distinct role_id from fairy_town_server.server_battle_pass_task_completed
    where
        server_id in (10001,10002,10003) 
        and day_time >= 20211209 and day_time <= 20211026
        and role_id not in (select distinct role_id from fairy_town.order_pay where product_name = '战令' and day_time >= 20211209 and day_time <= 20211026)
        and role_id in (select role_id from fairy_town.server_role_login  where day_time>=20211017 and day_time<=20211021)
        and role_id in (select role_id from fairy_town.server_role_login  where day_time>=20211209 and day_time<=20211026)
    )
    and day_time >= ${start_time}
    and day_time <= ${end_time}




购买战令用户登录时长，登陆次数

select distinct role_id
from fairy_town.order_pay 
where day_time>=20211209 and day_time<=20211026
and product_name='战令'
and role_id  in (select role_id from fairy_town.server_role_login  where day_time>=20211017 and day_time<=20211021)
and role_id  in (select role_id from fairy_town.server_role_login  where day_time>=20211209 and day_time<=20211026)
and role_id in (select distinct role_id from fairy_town_server.server_battle_pass_task_completed where server_id in (10001,10002,10003) and day_time >= 20211209 and day_time <= 20211026)

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
        day_time >= ${start_time}
        and day_time <= ${end_time}
        and server_id IN (10001,10002,10003)
        and role_id in
        (select distinct role_id
        from fairy_town.order_pay 
        where day_time>=20211209 and day_time<=20220104
        and product_name='战令'
        )
    group by 1,2
) a
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
        day_time >= ${start_time}
        and day_time <= ${end_time}
        and server_id IN (10001,10002,10003)
        and role_id in
        (select distinct role_id
        from fairy_town.order_pay 
        where day_time>=20211209 and day_time<=20220104
        and product_name='战令'
        )
    group by 1,2
    ) a
group by 1
order by 1



未购买战令用户登录时长、登录次数
select 
    distinct role_id
from 
    fairy_town_server.server_battle_pass_task_completed
    where
        server_id in (10001,10002,10003) 
        and day_time >= 20211209 and day_time <= 20211026
        and role_id not in (select distinct role_id from fairy_town.order_pay where product_name = '战令' and day_time >= 20211209 and day_time <= 20211026)
        and role_id in (select role_id from fairy_town.server_role_login  where day_time>=20211017 and day_time<=20211021)
        and role_id in (select role_id from fairy_town.server_role_login  where day_time>=20211209 and day_time<=20211026)



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
        day_time >= ${start_time}
        and day_time <= ${end_time}
        and server_id IN (10001,10002,10003)
        and role_id in
        (select 
            distinct role_id
        from 
            fairy_town_server.server_battle_pass_task_completed
            where
                server_id in (10001,10002,10003) 
                and day_time >= 20211209 and day_time <= 20220104
                and role_id not in (select distinct role_id from fairy_town.order_pay where product_name = '战令' and day_time >= 20211209 and day_time <= 20220104)
        )
    group by 1,2
) a
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
        day_time >= ${start_time}
        and day_time <= ${end_time}
        and server_id IN (10001,10002,10003)
        and role_id in
        (select 
            distinct role_id
        from 
            fairy_town_server.server_battle_pass_task_completed
            where
                server_id in (10001,10002,10003) 
                and day_time >= 20211209 and day_time <= 20220104
                and role_id not in (select distinct role_id from fairy_town.order_pay where product_name = '战令' and day_time >= 20211209 and day_time <= 20220104)
        )
    group by 1,2
    ) a
group by 1
order by 1




