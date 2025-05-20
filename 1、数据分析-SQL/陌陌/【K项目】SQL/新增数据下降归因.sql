SELECT 
	count(*) as liang,
	channel_id as channel_id,
	country as country,
	flag as flag	
from	
	(SELECT 
		a.device_id as device_id,
		a.channel_id as channel_id,
		a.os_version as os_version,
		a.flag as flag,
		case 
	    	when a.country = 'US' then '美国'
     		when a.country = 'DE' then '德国'
     		when a.country = 'FR' then '法国'
     		when a.country in ('GB','AU','CA','NZ') then '英加澳洲'
     		when a.country in ('SE','DK','NO','FI') then '北欧四国'
     		when a.country in ('IT','ES','RU','NL','BE','PL','AT','CH') then '其他国家'
     		else  'others'
     	end  as country,
		a.birth_dt as birth_dt,
		b.media_source as media_source
	from
		(
		SELECT 
		    device_id,   -- 设备id
		    case 
	    		when channel_id = 1000 then 'AND'
     			when channel_id = 2000 then 'iOS'
     			else  'others'
     		end  as channel_id,  -- 渠道id Android IOS
		    os_version,  -- 系统版本
		    country,     -- 国家
		    case
		    	when date_time >= '2021-09-17 02:00:00' and date_time <= '2021-09-17 04:00:00' then 1
		    	when date_time >= '2021-09-17 23:00:00' and date_time <= '2021-09-18 01:00:00' then 2
		    	when date_time >= '2021-09-18 23:00:00' and date_time <= '2021-09-19 01:00:00' then 3
		    	when date_time >= '2021-09-20 00:00:00' and date_time <= '2021-09-20 02:00:00' then 4
		    	when date_time >= '2021-09-21 02:00:00' and date_time <= '2021-09-21 04:00:00' then 5
		    	when date_time >= '2021-09-22 01:00:00' and date_time <= '2021-09-22 03:00:00' then 6
		    	when date_time >= '2021-09-23 01:00:00' and date_time <= '2021-09-23 03:00:00' then 7
		    	else 0
		    end as flag,
		    to_date(cast(date_time as timestamp)) as birth_dt -- 日期
		FROM 
		    fairy_town.device_activate
		where day_time > 20210916 and day_time <= ${endDate} and country not in  ('CN','HK') 
		ORDER BY birth_dt
		) as a
		left join
		(
		SELECT 
			customer_user_id,
			media_source
		from
			fairy_town.af_push
		where day_time > 20210916 and day_time <= ${endDate}
		) as b
		on a.device_id = b.customer_user_id
	) as op	
where media_source is null
group by channel_id,country,flag
