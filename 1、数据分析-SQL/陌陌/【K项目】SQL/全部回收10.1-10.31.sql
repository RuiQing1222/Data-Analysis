	select
		a.dates_a as dates,
		a.channel_id as channel_id,
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
		round(sum(if(datediff(dates_b,dates_a)<=29, pay_price_2, 0)),2)  as day30
	from
		(
		select
			op1.device_id as device_id,
			op1.dates as dates_a,
			op1.channel_id as channel_id,
			op2.dates as dates_b,
			op2.pay_price as pay_price_2,
			datediff(op2.dates,op1.dates) as p
		from
			(select
				device_id,
				country,
				channel_id,
				to_date(cast(date_time as timestamp)) as dates
			 from
				fairy_town.device_activate
			where 
				day_time >= 20211001 
				and day_time <= 20211028
				-- and country in ('US','DE','FR','GB','AU','CA','NZ','SE','DK','NO','FI','IT','ES','RU','NL','BE','PL','AT','CH') 
				and channel_id in (1000,2000)
			) as op1 ,

			(select
				device_id,
				sum(pay_price) as pay_price,
				to_date(cast(date_time as timestamp)) as dates
			 from
				fairy_town.order_pay
			 where
			 	day_time >= 20211001 and day_time <= 20211028
			 group by device_id,dates
			 ) as op2 
		where op1.device_id = op2.device_id and op2.dates >= op1.dates
		) as a	
 
	group by 1,2
	order by 1
