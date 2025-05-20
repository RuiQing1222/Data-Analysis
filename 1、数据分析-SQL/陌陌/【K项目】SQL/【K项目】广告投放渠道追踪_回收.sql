select
	a.platform as platform,
	a.campaign as `广告系列名称`,
	a.af_ad as `广告名称`,
	a.af_adset_id as `广告组id`,
	a.country_code as country_code,
	a.media_source as media_source,
	a.channel_id as `平台`,
	a.birth_dt as `日期`,
	b.day1 as day1,
	b.day2 as day2,
	b.day3 as day3,
	b.day4 as day4,
	b.day5 as day5,
	b.day6 as day6,
	b.day7 as day7,
	b.day8 as day8,
	b.day9 as day9,
	b.day10 as day10,
	b.day11 as day11,
	b.day12 as day12,
	b.day13 as day13,
	b.day14 as day14,
	b.day15 as day15,
	b.day30 as day30,
	b.day45 as day45
from
	(
	-- 1、af_push表和device_activate表 device_id 关联查询
	select 
		a.platform as platform,
	    a.campaign as campaign,
	    a.af_ad as af_ad,
	    a.af_adset_id as af_adset_id,
	    b.country as country_code,
	    case 
	    	when media_source in ('Facebook Ads','restricted') then 'FB'
     		when media_source = 'googleadwords_int' then 'GG'
     		when media_source = 'applovin_int'      then 'applovin'
     		else  'others'
     	end  as media_source,
	    --a.media_source as media_source,
	    -- if(a.campaign is NULL, "Paid_Others",split_part(a.campaign,"-",4)) as campaign_type, -- 切分字符串
	    case 
	    	when b.channel_id = 1000 then 'AND'
     		when b.channel_id = 2000 then 'iOS'
     		else  'others'
     	end  as channel_id,
	    to_date(cast(b.date_time as timestamp)) as birth_dt,
	    b.device_id as device_id
	from 
		fairy_town.af_push as a, fairy_town.device_activate as b 
	where a.customer_user_id = b.device_id and a.day_time >= 20210916 and a.day_time <= ${endDate}
	) as a 

join
	-- 2、按照device_id,时间计算每天收入 order_pay自关联
	
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
		round(sum(if(datediff(dates_b,dates_a)<=6, pay_price_2, 0)),2) as day7,
		round(sum(if(datediff(dates_b,dates_a)<=7, pay_price_2, 0)),2) as day8,
		round(sum(if(datediff(dates_b,dates_a)<=8, pay_price_2, 0)),2) as day9,
		round(sum(if(datediff(dates_b,dates_a)<=9, pay_price_2, 0)),2) as day10,
		round(sum(if(datediff(dates_b,dates_a)<=10, pay_price_2, 0)),2)  as day11,
		round(sum(if(datediff(dates_b,dates_a)<=11, pay_price_2, 0)),2)  as day12,
		round(sum(if(datediff(dates_b,dates_a)<=12, pay_price_2, 0)),2)  as day13,
		round(sum(if(datediff(dates_b,dates_a)<=13, pay_price_2, 0)),2)  as day14,
		round(sum(if(datediff(dates_b,dates_a)<=14, pay_price_2, 0)),2)  as day15,
		round(sum(if(datediff(dates_b,dates_a)<=29, pay_price_2, 0)),2)  as day30,
		round(sum(if(datediff(dates_b,dates_a)<=44, pay_price_2, 0)),2)  as day45
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
			where day_time >= 20210916 and day_time <= ${endDate} and country not in  ('CN','HK') 
			) as op1 ,

			(select
				device_id,
				sum(pay_price) as pay_price,
				to_date(cast(date_time as timestamp)) as dates
			 from
				fairy_town.order_pay
			 where
			 	day_time >= 20210916 and day_time <= ${endDate}
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
