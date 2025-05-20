-- 开服至今的数据   4.20 - 至今
-- 1.看7天内活跃的    11.2-11.8
-- 2.分付费的和免费的用户 
-- 3.按数量分布，间距你定，细点比较好    钻石的存量

# 开服至今付费/免费用户  在里面付费   不在就免费
select distinct role_id from fairy_town.order_pay where day_time >= 20210420 and day_time <= 20211108


-- 1.看7天内活跃的付费用户钻石的存量
select
    count(case when gem =0 then role_id else null end)
    ,count(case when gem >0 and gem <3 then role_id else null end)
    ,count(case when gem >=3 and gem <7 then role_id else null end)
    ,count(case when gem >=7 and gem <10 then role_id else null end)
    ,count(case when gem >=10 and gem <15 then role_id else null end)
    ,count(case when gem >=15 and gem <20 then role_id else null end)
    -- ,count(case when gem >=10 and gem <20 then role_id else null end)
    ,count(case when gem >=20 and gem <40 then role_id else null end)
    ,count(case when gem >=40 and gem <100 then role_id else null end)
    ,count(case when gem >=100 then role_id else null end)
from
    (select
    	role_id,
    	day_time,
    	gem,
    	row_number() over(partition by role_id order by day_time desc) as ranks
    from 
    	fairy_town_server.server_login_snap_shot
    where
    	day_time >= 20211102 
    	and day_time <= 20211108 
    	and role_id in (select distinct role_id from fairy_town.order_pay where day_time >= 20210420 and day_time <= 20211108)
    ) a
where ranks =1 


-- 2.看7天内活跃的免费用户钻石的存量
select
    count(case when gem =0 then role_id else null end)
    ,count(case when gem >0 and gem <3 then role_id else null end)
    ,count(case when gem >=3 and gem <7 then role_id else null end)
    ,count(case when gem >=7 and gem <10 then role_id else null end)
    ,count(case when gem >=10 and gem <15 then role_id else null end)
    ,count(case when gem >=15 and gem <20 then role_id else null end)
    -- ,count(case when gem >=10 and gem <20 then role_id else null end)
    ,count(case when gem >=20 and gem <40 then role_id else null end)
    ,count(case when gem >=40 and gem <100 then role_id else null end)
    ,count(case when gem >=100 then role_id else null end)
from
    (select
    	role_id,
    	day_time,
    	gem,
    	row_number() over(partition by role_id order by day_time desc) as ranks
    from 
    	fairy_town_server.server_login_snap_shot
    where
    	day_time >= 20211102 
    	and day_time <= 20211108 
    	and role_id not in (select distinct role_id from fairy_town.order_pay where day_time >= 20210420 and day_time <= 20211108)
    ) a
where ranks =1 




还想拉下用户金币的存量情况
开服至今的数据
1.看7天内活跃的
2.分付费的和免费的用户
3.限15级以上的用户
3.按数量分布，间距你定，细点比较好

-- 1.看7天内活跃的付费用户金币的存量
select
    count(case when gold =0 then role_id else null end) '0'
    ,count(case when gold >0 and gold <2500 then role_id else null end) '1-2499'
    ,count(case when gold >=2500 and gold <5000 then role_id else null end) '2500-4999'
    ,count(case when gold >=5000 and gold <7500 then role_id else null end) '5000-7499'
    ,count(case when gold >=7500 and gold <10000 then role_id else null end) '7500-9999'
    ,count(case when gold >=10000 and gold <12500 then role_id else null end) '10000-12499'
    ,count(case when gold >=12500 and gold <15000 then role_id else null end) '12500-14999'
    ,count(case when gold >=15000 and gold <20000 then role_id else null end) '15000-19999'
    ,count(case when gold >=20000 and gold <30000 then role_id else null end) '20000-29999'
    ,count(case when gold >=30000 and gold <50000 then role_id else null end) '30000-49999'
    ,count(case when gold >=50000 then role_id else null end) '50000+'
from
    (select
        role_id,
        day_time,
        gold,
        row_number() over(partition by role_id order by day_time desc) as ranks
    from 
        fairy_town_server.server_login_snap_shot
    where
        day_time >= 20211103 
        and day_time <= 20211109 
        and role_id in (select distinct role_id from fairy_town.order_pay where day_time >= 20210420 and day_time <= 20211109)
        and role_level >= 15
    ) a
where ranks =1


活跃用户
select distinct role_id from fairy_town.server_role_login where day_time >= 20211105 and day_time <= 20211111

付费用户
select distinct role_id from fairy_town.order_pay where day_time >= 20210420 and day_time <= 20211111



免费获取金币 分天 分区间
select
    day_time
    ,count(distinct case when change_count =0 then role_id else null end) '0'
    ,count(distinct case when change_count >0 and change_count <100 then role_id else null end) '1-99'
    ,count(distinct case when change_count >=100 and change_count <200 then role_id else null end) '100-199'
    ,count(distinct case when change_count >=200 and change_count <300 then role_id else null end) '200-299'
    ,count(distinct case when change_count >=300 and change_count <400 then role_id else null end) '300-399'
    ,count(distinct case when change_count >=400 and change_count <500 then role_id else null end) '400-499'
    ,count(distinct case when change_count >=500 and change_count <600 then role_id else null end) '500-599'
    ,count(distinct case when change_count >=600 and change_count <700 then role_id else null end) '600-699'
    ,count(distinct case when change_count >=700 and change_count <800 then role_id else null end) '700-799'
    ,count(distinct case when change_count >=800 and change_count <900 then role_id else null end) '800-899'
    ,count(distinct case when change_count >=900 and change_count <1000 then role_id else null end) '900-999'
    ,count(distinct case when change_count >=1000 and change_count <2000 then role_id else null end) '1000-1999'
    ,count(distinct case when change_count >=2000 and change_count <3000 then role_id else null end) '2000-2999'
    ,count(distinct case when change_count >=3000 and change_count <4000 then role_id else null end) '3000-3999'
    ,count(distinct case when change_count >=4000 and change_count <5000 then role_id else null end) '4000-4999'
    ,count(distinct case when change_count >=5000 and change_count <10000 then role_id else null end) '5000-9999'
    ,count(distinct case when change_count >=10000 and change_count <20000 then role_id else null end) '10000-19999'
    ,count(distinct case when change_count >=20000 and change_count <30000 then role_id else null end) '20000-29999'
    ,count(distinct case when change_count >=30000 and change_count <40000 then role_id else null end) '30000-49999'
    ,count(distinct case when change_count >=40000 and change_count <50000 then role_id else null end) '40000-49999'
    ,count(distinct case when change_count >=50000 and change_count <60000 then role_id else null end) '50000-59999'
    ,count(distinct case when change_count >=60000 and change_count <70000 then role_id else null end) '60000-69999'
    ,count(distinct case when change_count >=70000 and change_count <80000 then role_id else null end) '70000-79999'
    ,count(distinct case when change_count >=80000 and change_count <90000 then role_id else null end) '80000-89999'
    ,count(distinct case when change_count >=90000 and change_count <100000 then role_id else null end) '90000-99999'
    ,count(distinct case when change_count >=100000 then role_id else null end) '100000+'
from
    (
    select
        role_id,
        day_time,
        sum(change_count) as change_count
    from 
        fairy_town.server_currency
    where
        day_time >= 20210916
        and day_time <= 20211111
        and role_id in (select distinct role_id from fairy_town.order_pay where day_time >= 20210420 and day_time <= 20211111)
        and role_id in (select distinct role_id from fairy_town.server_role_login where day_time >= 20211105 and day_time <= 20211111)
        and server_id in (10001,10002,10003)
        and currency_id = '1'
        and change_type = 'PRODUCE'
        and change_method not in ('26', '89')
        and role_level >= 15
    group by 1,2
    ) a
group by 1 
order by 1;






SELECT
    day_time,
    count(DISTINCT role_id)
from fairy_town.server_currency
WHERE role_id in (select distinct role_id from fairy_town.order_pay where day_time >= 20210420 and day_time <= 20211111)
and role_id in (select distinct role_id from fairy_town.server_role_login where day_time >= 20211105 and day_time <= 20211111 )
and server_id in (10001,10002,10003)
and currency_id = '1'
and day_time >= 20210916
and day_time <= 20211111
and change_type = 'PRODUCE'
and change_method not in ('26', '89')
and role_level >= 15

GROUP BY 1
ORDER BY 1



体力道具存量
select day_time,aa.role_id as role_id,bb.prop_id as prop_id,bb.counts as counts
from
(select day_time,role_id from fairy_town.server_role_login 
where server_id in (10001,10002,10003)
and day_time = ${end_time}
group by 1,2) as aa

left join

(
select a.role_id as role_id,a.prop_id as prop_id,(a.sum_count - b.sum_count) as counts
from    
(-- 获取
select role_id,prop_id,sum(change_count) as sum_count from fairy_town.server_prop
where server_id in (10001,10002,10003)
and day_time >= 20210420 and day_time <= ${end_time}
and change_type = "PRODUCE"
and prop_id in ('103004','143010','102001','107006','103017')
group by 1,2
) as a
left join
(
-- 消耗
select role_id,prop_id,sum(change_count) as sum_count from fairy_town.server_prop
where server_id in (10001,10002,10003)
and day_time >= 20210420 and day_time <= ${end_time}
and change_type = "CONSUME"
and prop_id in ('103004','143010','102001','107006','103017')
group by 1,2
) as b
on a.role_id = b.role_id and a.prop_id = b.prop_id
) as bb
on aa.role_id = bb.role_id
group by 1,2,3,4
order by 1





select role_id,prop_id,sum(change_count) as sum_count from fairy_town.server_prop
where server_id in (10001,10002,10003)
and day_time >= 20210420 and day_time <= ${end_time}
and change_type = "PRODUCE"
and prop_id = '102001'
and role_id = '1000100000000027980'
group by 1,2

select role_id,prop_id,sum(change_count) as sum_count from fairy_town.server_prop
where server_id in (10001,10002,10003)
and day_time >= 20210420 and day_time <= ${end_time}
and change_type = "CONSUME"
and prop_id = '102001'
and role_id = '1000100000000027980'
group by 1,2