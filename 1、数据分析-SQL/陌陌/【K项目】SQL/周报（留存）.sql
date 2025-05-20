-- ： 整体留存
select
	b.day_time_a as day_time,
	sum(case when by_day = 0 then 1 else 0 end) '新增',
    sum(case when by_day = 1 then 1 else 0 end) day_2,
    -- sum(case when by_day = 2 then 1 else 0 end) day_3,
    -- sum(case when by_day = 3 then 1 else 0 end) day_4,
    -- sum(case when by_day = 4 then 1 else 0 end) day_5,
    -- sum(case when by_day = 5 then 1 else 0 end) day_6,
    sum(case when by_day = 6 then 1 else 0 end) day_7
    -- sum(case when by_day = 14 then 1 else 0 end) day_14,
    -- sum(case when by_day = 30 then 1 else 0 end) day_30
from
(
	select 
		device_id_b as device_id,
		day_time_a,-- first_day
		day_time_b,
		datediff(day_time_b,day_time_a) as by_day -- 间隔
	from
		(select 
			b.device_id as device_id_b,
			a.day_times as day_time_a,
			b.day_times as day_time_b
		from
			 (
			 select 
				device_id,
				to_date(cast(date_time as timestamp)) as day_times 
			 from fairy_town.device_launch
			 where day_time >= ${start_time} and day_time <= ${endDate}
			 group by 
				device_id,
				day_times
			) b 
		right join 
			(select 
				device_id,
				to_date(cast(date_time as timestamp)) as day_times
			from 
				fairy_town.device_activate
			where day_time >= ${start_time} and day_time <= ${endDate}
			group by 
				device_id,
				day_times
			) a
			on a.device_id = b.device_id
		) as reu
	order by device_id_b,day_time_b		 
) as b

group by 1
order by 1

台湾留存
select
	b.day_time_a as day_time,
	sum(case when by_day = 0 then 1 else 0 end) '新增',
    sum(case when by_day = 1 then 1 else 0 end) day_2,
    -- sum(case when by_day = 2 then 1 else 0 end) day_3,
    -- sum(case when by_day = 3 then 1 else 0 end) day_4,
    -- sum(case when by_day = 4 then 1 else 0 end) day_5,
    -- sum(case when by_day = 5 then 1 else 0 end) day_6,
    sum(case when by_day = 6 then 1 else 0 end) day_7
    -- sum(case when by_day = 14 then 1 else 0 end) day_14,
    -- sum(case when by_day = 30 then 1 else 0 end) day_30
from
(
	select 
		device_id_b as device_id,
		day_time_a,-- first_day
		day_time_b,
		datediff(day_time_b,day_time_a) as by_day -- 间隔
	from
		(select 
			b.device_id as device_id_b,
			a.day_times as day_time_a,
			b.day_times as day_time_b
		from
			 (
			 select 
				device_id,
				to_date(cast(date_time as timestamp)) as day_times 
			 from fairy_town_tw.device_launch
			 where day_time >= ${start_time} and day_time <= ${endDate}
			 group by 
				device_id,
				day_times
			) b 
		right join 
			(select 
				device_id,
				to_date(cast(date_time as timestamp)) as day_times
			from 
				fairy_town_tw.device_activate
			where day_time >= ${start_time} and day_time <= ${endDate}
			group by 
				device_id,
				day_times
			) a
			on a.device_id = b.device_id
		) as reu
	order by device_id_b,day_time_b		 
) as b

group by 1
order by 1



-- ： 分国家留存
select
	b.country as country,
	b.day_time_a as day_time,
	sum(case when by_day = 0 then 1 else 0 end) '新增',
    sum(case when by_day = 1 then 1 else 0 end) day_2,
    -- sum(case when by_day = 2 then 1 else 0 end) day_3,
    -- sum(case when by_day = 3 then 1 else 0 end) day_4,
    -- sum(case when by_day = 4 then 1 else 0 end) day_5,
    -- sum(case when by_day = 5 then 1 else 0 end) day_6,
    sum(case when by_day = 6 then 1 else 0 end) day_7
    -- sum(case when by_day = 14 then 1 else 0 end) day_14,
    -- sum(case when by_day = 30 then 1 else 0 end) day_30
from
(
	select 
		device_id_b as device_id,
		day_time_a,-- first_day
		day_time_b,
		datediff(day_time_b,day_time_a) as by_day, -- 间隔
		country
	from
		(select 
			b.device_id as device_id_b,
			a.day_times as day_time_a,
			b.day_times as day_time_b,
			a.country as country
		from
			 (
			 select 
				device_id,
				to_date(cast(date_time as timestamp)) as day_times 
			 from fairy_town.device_launch
			 where day_time >= ${start_time} and day_time <= ${endDate}
			 group by 
				device_id,
				day_times
			) b 
		right join 
			(select 
				device_id,
				to_date(cast(date_time as timestamp)) as day_times,
				case
					when country = 'US' then '美国'
					when country = 'DE' then '德国'
					when country = 'FR' then '法国'
					when country = 'GB' then '英国'
					when country = 'AU' then '澳大利亚'
					when country = 'CA' then '加拿大'
					when country = 'NZ' then '新西兰'
					when country = 'SE' then '瑞典'
					when country = 'DK' then '丹麦'
					when country = 'NO' then '挪威'
					when country = 'FI' then '芬兰'
					when country = 'IT' then '意大利'
					when country = 'ES' then '西班牙'
					when country = 'RU' then '俄罗斯'
					when country = 'NL' then '荷兰'
					when country = 'BE' then '比利时'
					when country = 'PL' then '波兰'
					when country = 'AT' then '奥地利'
					when country = 'CH' then '瑞士'
					when country = 'TH' then '泰国'
					when country = 'BR' then '巴西'
					when country = 'SG' then '新加坡'
					when country = 'MY' then '马来西亚'
					when country = 'JP' then '日本'
					when country = 'KR' then '韩国'
					when country = 'ID' then '印尼'
				end as country
			from 
				fairy_town.device_activate
			where day_time >= ${start_time} and day_time <= ${endDate}
			group by 1,2,3
			) a
			on a.device_id = b.device_id
		) as reu
	order by device_id_b,day_time_b		 
) as b

group by 1,2
order by 1,2






# 在线时长
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
        day_time >= ${start_time}
        and day_time <= ${end_time}
        and server_id IN (10001,10002,10003)
    group by device_id,day_time
) a
group by day_time
order by day_time



#  ROAS 周期每天收入
select birth_dt,
sum(case when datediff(pay_dt,birth_dt)  =0  then pay_price else 0 end) as pay_day1,
sum(case when datediff(pay_dt,birth_dt) <=1  then pay_price else 0 end) as pay_day2,
sum(case when datediff(pay_dt,birth_dt) <=2  then pay_price else 0 end) as pay_day3,
sum(case when datediff(pay_dt,birth_dt) <=3  then pay_price else 0 end) as pay_day4,
sum(case when datediff(pay_dt,birth_dt) <=4  then pay_price else 0 end) as pay_day5,
sum(case when datediff(pay_dt,birth_dt) <=5  then pay_price else 0 end) as pay_day6,
sum(case when datediff(pay_dt,birth_dt) <=6  then pay_price else 0 end) as pay_day7
from

(select to_date(cast (date_time as timestamp)) as birth_dt,device_id
from fairy_town.device_activate
where  day_time>=${startDate} and day_time<${endDate} and country not in  ('CN','HK')
group by 1,2) a 

left join 
(select to_date(cast (date_time as timestamp)) as pay_dt
,device_id,pay_price --设备ID
from fairy_town.order_pay
where day_time >= ${startDate} and day_time<${endDate} 
) c 
on a.device_id=c.device_id

group by 1





-- APPlovin分广告系列分国家安卓回收
select birth_dt,channel_id,country2,campaign,
sum(case when datediff(pay_dt,birth_dt)  =0  then pay_price else 0 end) as pay_day1,
sum(case when datediff(pay_dt,birth_dt) <=1  then pay_price else 0 end) as pay_day2,
sum(case when datediff(pay_dt,birth_dt) <=2  then pay_price else 0 end) as pay_day3, 
sum(case when datediff(pay_dt,birth_dt) <=3  then pay_price else 0 end) as pay_day4,
sum(case when datediff(pay_dt,birth_dt) <=4  then pay_price else 0 end) as pay_day5,
sum(case when datediff(pay_dt,birth_dt) <=5  then pay_price else 0 end) as pay_day6,
sum(case when datediff(pay_dt,birth_dt) <=6  then pay_price else 0 end) as pay_day7,   
sum(case when datediff(pay_dt,birth_dt) <=13 then pay_price else 0 end) as pay_day14,
sum(case when datediff(pay_dt,birth_dt) <=29 then pay_price else 0 end) as pay_day30,
sum(case when datediff(pay_dt,birth_dt) <=44 then pay_price else 0 end) as pay_day45,
sum(case when datediff(pay_dt,birth_dt) <=59 then pay_price else 0 end) as pay_day60,
sum(case when datediff(pay_dt,birth_dt) <=89 then pay_price else 0 end) as pay_day90
from

(select birth_dt,channel_id,device_id,country,country2,campaign
from 
(select to_date(cast (date_time as timestamp)) as birth_dt,device_id,channel_id,
case when country ='US' then '美国'
     when country ='DE' then '德国'
     when country ='FR' then '法国'
     when country in ('GB','AU','CA','NZ') then '英加澳洲' 
     when country in ('SE','DK','NO','FI') then '北欧四国'
     when country in ('IT','ES','RU','NL','BE','PL','AT','CH') then '其他国家' 
     when country ='TH'  then '泰国'
     when country ='BR'  then '巴西'
     when country ='SG'  then '新加坡'
     when country ='MY'  then '马来西亚'       
     when country ='IN'  then '印度'
     else 'others'
end as country,
case when country  in ('US','DE','FR','GB','AU','CA','NZ','SE','DK','NO','FI','IT','ES','RU','NL','BE','PL','AT','CH','TH','BR','SG','MY','IN') then country
     else 'others'
end as country2 
from fairy_town.device_activate
where  day_time>=${startDate} and day_time<${endDate} and country not in  ('CN','HK') and channel_id = 1000
group by 1,2,3,4,5) a 

left join 
(select customer_user_id,campaign   
from fairy_town.af_push
where day_time>=${startDate}  and day_time<${endDate} and media_source = 'applovin_int'
group by 1,2) b
on a.device_id=b.customer_user_id
) a 

left join 
(select to_date(cast (date_time as timestamp)) as pay_dt
,device_id,pay_price --设备ID
from fairy_town.order_pay
where day_time >= ${startDate} and day_time<${endDate} 
) c 
on a.device_id=c.device_id
group by 1,2,3,4




-- APPlovin分广告系列分国家安卓留存
select birth_dt,a.channel_id,country2,media_source,
case when campaign_type is not null then campaign_type
     when campaign_type is null then 'Organic'
end as install_source ,
case when campaign_type is not null then 'Paid'
     when campaign_type is null then 'Organic'
end as install_source2 ,
datediff(login_dt,birth_dt) as datediffs,
count(distinct a.device_id) as devices
from 

(select to_date(cast (date_time as timestamp)) as birth_dt,device_id,channel_id,
case when country  in ('US','DE','FR','GB','AU','CA','NZ','SE','DK','NO','FI','IT','ES','RU','NL','BE','PL','AT','CH','TH','BR','SG','MY','IN')    then country
     else 'others'
	 end as country2
from fairy_town.device_activate
where day_time>=20210930 and day_time< ${endDate} and channel_id = 1000
and country not in  ('CN','HK')
group by 1,2,3,4) a 
left join 

(select customer_user_id,campaign,
case when split_part(campaign,'-',4)='MAI'  then 'MAI'
     when split_part(campaign,'-',4)='AEO'  then 'AEO'
     when split_part(campaign,'-',4)='VO'   then 'VO'
     when split_part(campaign,'-',4)='Roas' then 'Roas'
     else 'Paid_Others'
end as campaign_type,
case when media_source in ('Facebook Ads','restricted') then 'FB'
     when media_source = 'googleadwords_int' then 'GG'
     when media_source = 'snapchat_int'      then 'SnapChat'
     when media_source = 'Apple Search Ads'  then 'ASA'
     when media_source = 'applovin_int'      then 'applovin'
     else  'others'
     end  as media_source      
from fairy_town.af_push
where day_time>=20210420 and day_time< ${endDate} and media_source = 'applovin_int'
group by 1,2,3,4) b 
on device_id=customer_user_id
left join 

(select to_date(cast (date_time as timestamp)) as login_dt
,device_id
from fairy_town.device_launch
where day_time>=20210930 and day_time<= ${endDate}  
group by 1,2) c 
on a.device_id=c.device_id and login_dt>=birth_dt

where datediff(login_dt,birth_dt) in (0,1,2,3,4,5,6,13,29,44,59,89)
group by 1,2,3,4,5,6,7




















有效新增：7天内登录两天或以上的新增用户/7天内新增用户
一阶登录比：7天内登录三天或以上的新增用户/7天内登录两天或以上的新增用户
二阶登录比：7天内登录三天或以上的新增用户在8-14天有登录行为/7天内登录三天或以上的新增用户

有效新增
select day_time,count(distinct role_id) from fairy_town.server_role_create
where day_time >= ${d1} and day_time <= ${d2}
and server_id IN (10001,10002,10003)
group by 1 order by 1


7天内登录两天或以上的新增用户
select day_times,count(distinct role_id)
from
(select day_times,role_id
from
(select day_times,role_id,count(distinct cast(by_day as string)) as num
from
(select role_id,day_times,by_day	   
from
(select b.role_id as role_id,a.day_times as day_times,datediff(b.day_times,a.day_times) as by_day
from

(select role_id,to_date(cast(date_time as timestamp)) as day_times from fairy_town.server_role_create
where day_time >= ${d1} and day_time <= ${d2} and server_id IN (10001,10002,10003)) as a
left join
(select role_id,to_date(cast(date_time as timestamp)) as day_times from fairy_town.server_role_login
where day_time >= ${d1} and day_time <= ${d2}
and server_id IN (10001,10002,10003) ) as b 
on a.role_id = b.role_id

) as c where by_day < 7 
) as d group by 1,2
) as e where num >= 2 group by 1,2
) as f 
group by 1
order by 1




7天内登录三天或以上的新增用户
select day_times,count(distinct role_id)
from
(select day_times,role_id
from
(select day_times,role_id,count(distinct cast(by_day as string)) as num
from
(select role_id,day_times,by_day	   
from
(select b.role_id as role_id,a.day_times as day_times,datediff(b.day_times,a.day_times) as by_day
from

(select role_id,to_date(cast(date_time as timestamp)) as day_times from fairy_town.server_role_create
where day_time >= ${d1} and day_time <= ${d2} and server_id IN (10001,10002,10003)) as a
left join
(select role_id,to_date(cast(date_time as timestamp)) as day_times from fairy_town.server_role_login
where day_time >= ${d1} and day_time <= ${d2}
and server_id IN (10001,10002,10003) ) as b 
on a.role_id = b.role_id

) as c where by_day < 7 
) as d group by 1,2
) as e where num >= 3 group by 1,2
) as f 
group by 1
order by 1




7天内登录三天或以上的新增用户在8-14天有登录行为
select a.day_times,count(distinct a.role_id)
from
(select day_times,role_id
from
(select day_times,role_id
from
(select day_times,role_id,count(distinct by_day) as num
from
(select role_id,day_times,by_day	   
from
(select b.role_id as role_id,a.day_times as day_times,datediff(b.day_times,a.day_times) as by_day
from

(select role_id,to_date(cast(date_time as timestamp)) as day_times from fairy_town.server_role_create
where day_time >= ${d1} and day_time <= ${d2} and server_id IN (10001,10002,10003)) as a
left join
(select role_id,to_date(cast(date_time as timestamp)) as day_times from fairy_town.server_role_login
where day_time >= ${d1} and day_time <= ${d2}
and server_id IN (10001,10002,10003) ) as b 
on a.role_id = b.role_id

) as c where by_day < 7 
) as d group by 1,2
) as e where num >= 3 group by 1,2
) as f 
) as a

join

(select role_id,day_times	   
from
(select b.role_id as role_id,a.day_times as day_times,datediff(b.day_times,a.day_times) as by_day
from
(select role_id,to_date(cast(date_time as timestamp)) as day_times from fairy_town.server_role_create
where day_time >= ${d1} and day_time <= ${d2} and server_id IN (10001,10002,10003)) as a
left join
(select role_id,to_date(cast(date_time as timestamp)) as day_times from fairy_town.server_role_login
where day_time >= ${d1} and day_time <= ${d2}
and server_id IN (10001,10002,10003) ) as b 
on a.role_id = b.role_id
) as c where by_day >= 7 and by_day < 14 
) as b
on a.role_id = b.role_id and a.day_times = b.day_times

group by 1 
order by 1

