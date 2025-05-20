# 指标一：回收
select
	a.campaign as `广告系列名称`,
	a.country_code as country_code,
	a.media_source as media_source,
	a.birth_dt as `日期`,
	b.day1 as day1,
	b.day2 as day2,
	b.day3 as day3,
	b.day4 as day4,
	b.day5 as day5,
	b.day6 as day6,
	b.day7 as day7
from

(
	-- 1、af_push表和device_activate表 device_id 关联查询
	select 
	    a.campaign as campaign,
	    b.country as country_code,
	    a.media_source as media_source,
	    to_date(cast(b.date_time as timestamp)) as birth_dt,
	    b.device_id as device_id
	from 
		fairy_town.af_push as a, fairy_town.device_activate as b 
	where a.customer_user_id = b.device_id and a.day_time >= 20210929 and a.day_time <= ${endDate} and media_source = 'applovin_int'
) as a 

join

(
	select
		device_id,
		a.dates_a as dates,
		round(sum(if(datediff(dates_b,dates_a)=0, pay_price_2, 0)),2) as day1,
		round(sum(if(datediff(dates_b,dates_a)<=1, pay_price_2, 0)),2) as day2,
		round(sum(if(datediff(dates_b,dates_a)<=2, pay_price_2, 0)),2) as day3,
		round(sum(if(datediff(dates_b,dates_a)<=3, pay_price_2, 0)),2) as day4,
		round(sum(if(datediff(dates_b,dates_a)<=4, pay_price_2, 0)),2) as day5,
		round(sum(if(datediff(dates_b,dates_a)<=5, pay_price_2, 0)),2) as day6,
		round(sum(if(datediff(dates_b,dates_a)<=6, pay_price_2, 0)),2) as day7
	from
		(
		select
			op1.device_id as device_id,
			op1.dates as dates_a,
			op2.dates as dates_b,
			op2.pay_price as pay_price_2,
			datediff(op2.dates,op1.dates) as p
		from
			(select
				device_id,
				to_date(cast(date_time as timestamp)) as dates
			 from
				fairy_town.device_activate
			where day_time >= 20210929 and day_time <= ${endDate}
			) as op1,

			(select
				device_id,
				sum(pay_price) as pay_price,
				to_date(cast(date_time as timestamp)) as dates
			 from
				fairy_town.order_pay
			 where
			 	day_time >= 20210929 and day_time <= ${endDate}
			 group by device_id,dates
			 ) as op2 
		where op1.device_id = op2.device_id and op2.dates >= op1.dates
		) as a	
 
	group by
		a.device_id,a.dates_a
	order by
		a.device_id,a.dates_a
) as b
on a.device_id = b.device_id



#  指标二：留存
select
	a.campaign as campaign,
	b.day_time_a as day_time,
	a.country_code as country_code,
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
	-- 1、af_push表和device_activate表 device_id 关联查询
	select 
	    a.campaign as campaign,
	    b.country as country_code,
	    to_date(cast(b.date_time as timestamp)) as birth_dt,
	    b.device_id as device_id
	from 
		fairy_town.af_push as a, fairy_town.device_activate as b 
	where 
		a.customer_user_id = b.device_id 
		and a.day_time >= 20210929 
		and a.day_time <= ${endDate} 
		and media_source = 'applovin_int'
) as a 

join 

(
	select 
		device_id_b as device_id,
		day_time_a,-- first_day
		day_time_b,
		datediff(day_time_b,day_time_a) as by_day -- 间隔
	from
		(select 
			b.device_id as device_id_b,
			a.day_time as day_time_a,
			b.day_time as day_time_b
		from
			 (
			 select 
				device_id,
				to_date(cast(date_time as timestamp)) as day_time 
			 from fairy_town.device_launch
			 group by 
				device_id,
				day_time
			) b 
		left join 
			(select 
				device_id,
				to_date(cast(date_time as timestamp)) as day_time
			from 
				fairy_town.device_activate
			group by 
				device_id,
				day_time
			) a
			on a.device_id = b.device_id
		) as reu
	order by device_id_b,day_time_b		 
) as b
on a.device_id = b.device_id
group by a.campaign,a.country_code,b.day_time_a



# 指标三：付费深度（新增付费ARPU）= 新增付费 / 新增用户数
select
	a.campaign as campaign,
	a.country_code as country_code,
	a.birth_dt as birth_dt,
	count(a.device_id) as nuw_count,
	sum(b.pay_price) as new_pay_sum,
	sum(b.pay_price) / count(a.device_id) as new_ARPU
from
(
	-- 1、af_push表和device_activate表 device_id 关联查询
	select 
	    a.campaign as campaign,
	    b.country as country_code,
	    to_date(cast(b.date_time as timestamp)) as birth_dt,
	    b.device_id as device_id
	from 
		fairy_town.af_push as a, fairy_town.device_activate as b 
	where a.customer_user_id = b.device_id and a.day_time >= 20210929 and a.day_time <= ${endDate} and media_source = 'applovin_int'
) as a 

left join

(
-- 每天新增的付费
select
	device_id,
	to_date(cast(date_time as timestamp)) as birth_dt,
	pay_price
from
	order_pay
) as b
on a.device_id = b.device_id
group by a.campaign,a.country_code,a.birth_dt