-- 9.16号至今 安卓自然量 分国家的 分周的  新增激活数量、 新增付费率、 新增平均付费用户的付费金额

-- 新增付费率 = 新增付费人数 / 新增用户数
-- 平均付费用户的付费金额 = 付费总金额 / 付费用户数
-- 捷克CZ 葡萄牙PT 爱尔兰IE 斯洛伐克SK 匈牙利HU 波罗的海三国(爱沙尼亚EE、拉脱维亚LV、立陶宛LT)

select
	e.country_code as country_code
	,e.birth_week as birth_week  -- 周一的日期
	,count(e.device_id) as `新增激活数量`
	,sum(e.payer) / count(e.device_id) as `新增付费率`
	,sum(e.pay_price) / sum(e.payer) as `新增平均付费用户的付费金额`
from
	(
	select
		c.country_code as country_code
		,to_date(date_trunc('week',c.date_time)) as birth_week  -- 周一的日期
		,case
		    when d.pay_price > 0 then 1
		 else 0
		 end as payer
		,d.pay_price as pay_price
		,c.device_id as device_id
	from
		(select
			case
				when b.country = 'CZ' then '捷克'
				when b.country = 'PT' then '葡萄牙'
				when b.country = 'IE' then '爱尔兰'
				when b.country = 'SK' then '斯洛伐克'
				when b.country = 'HU' then '匈牙利'
				when b.country = 'EE' then '波罗的海三国'
				when b.country = 'LV' then '波罗的海三国'
				when b.country = 'LT' then '波罗的海三国'
			else ''
			end as country_code
		    ,a.date_time as date_time
		    ,b.device_id as device_id
		from 
			fairy_town.af_push as a
		right join 
			fairy_town.device_activate as b 
		on 
			a.customer_user_id = b.device_id 
		where
			b.channel_id = 1000
			and b.country in ('CZ','PT','IE','SK','HU','EE','LV','LT')
			and a.day_time >= 20210916 
			and a.day_time <= ${endDate}
		) c
		left join
		(select
			device_id
			,pay_price
		from
			fairy_town.order_pay
		where
			day_time >= 20210916 
			and day_time <= ${endDate}
		) d
		on c.device_id = d.device_id
	) e
group by country_code,birth_week
order by birth_week