CPM = 花费 / 展示 * 1000
CPC = 花费 / 点击
CPI = 花费 / 安装
CPA = 花费 / 付费次数
CPP = 花费 / 付费人数
频次 = 展示 / 覆盖
CTR = 点击 / 展示
CVR = 安装 / 点击
IR = CTR * CVR
IPM = IR * 1000


设备回收
select birth_dt,channel_id,country,country2,campaign,af_ad, media_source,install_source,install_source2,install_style,
count(distinct a.device_id) as '新增用户数',
count(distinct case when datediff(pay_dt,birth_dt)  =0  then c.device_id else NULL end) as 'Day1付费人数',
count(distinct case when datediff(pay_dt,birth_dt) <=6  then c.device_id else NULL end) as 'Day7付费人数', 
count(distinct case when datediff(pay_dt,birth_dt) <=13  then c.device_id else NULL end) as 'Day14付费人数',   
count(distinct case when datediff(pay_dt,birth_dt) <=29 then c.device_id else NULL end) as 'Day30付费人数',
count(distinct case when datediff(pay_dt,birth_dt) <=59 then c.device_id else NULL end) as 'Day60付费人数',
count(case when datediff(pay_dt,birth_dt)  =0  then 1 else NULL end) as 'Day1付费次数',
count(case when datediff(pay_dt,birth_dt) <=6  then 1 else NULL end) as 'Day7付费次数', 
count(case when datediff(pay_dt,birth_dt) <=13  then 1 else NULL end) as 'Day14付费次数',   
count(case when datediff(pay_dt,birth_dt) <=29 then 1 else NULL end) as 'Day30付费次数',
count(case when datediff(pay_dt,birth_dt) <=59 then 1 else NULL end) as 'Day60付费次数',
sum(case when datediff(pay_dt,birth_dt)  =0  then pay_price else 0 end) as pay_day1,
sum(case when datediff(pay_dt,birth_dt) <=1  then pay_price else 0 end) as pay_day2,
sum(case when datediff(pay_dt,birth_dt) <=2  then pay_price else 0 end) as pay_day3, 
sum(case when datediff(pay_dt,birth_dt) <=3  then pay_price else 0 end) as pay_day4,
sum(case when datediff(pay_dt,birth_dt) <=4  then pay_price else 0 end) as pay_day5,
sum(case when datediff(pay_dt,birth_dt) <=5  then pay_price else 0 end) as pay_day6,
sum(case when datediff(pay_dt,birth_dt) <=6  then pay_price else 0 end) as pay_day7,
sum(case when datediff(pay_dt,birth_dt) <=7  then pay_price else 0 end) as pay_day8,
sum(case when datediff(pay_dt,birth_dt) <=8  then pay_price else 0 end) as pay_day9, 
sum(case when datediff(pay_dt,birth_dt) <=9  then pay_price else 0 end) as pay_day10,
sum(case when datediff(pay_dt,birth_dt) <=10 then pay_price else 0 end) as pay_day11,
sum(case when datediff(pay_dt,birth_dt) <=11 then pay_price else 0 end) as pay_day12,
sum(case when datediff(pay_dt,birth_dt) <=12 then pay_price else 0 end) as pay_day13,
sum(case when datediff(pay_dt,birth_dt) <=13 then pay_price else 0 end) as pay_day14,
sum(case when datediff(pay_dt,birth_dt) <=14 then pay_price else 0 end) as pay_day15, 
sum(case when datediff(pay_dt,birth_dt) <=15 then pay_price else 0 end) as pay_day16,
sum(case when datediff(pay_dt,birth_dt) <=16 then pay_price else 0 end) as pay_day17,
sum(case when datediff(pay_dt,birth_dt) <=17 then pay_price else 0 end) as pay_day18,
sum(case when datediff(pay_dt,birth_dt) <=18 then pay_price else 0 end) as pay_day19,
sum(case when datediff(pay_dt,birth_dt) <=19 then pay_price else 0 end) as pay_day20,
sum(case when datediff(pay_dt,birth_dt) <=20 then pay_price else 0 end) as pay_day21, 
sum(case when datediff(pay_dt,birth_dt) <=21 then pay_price else 0 end) as pay_day22,
sum(case when datediff(pay_dt,birth_dt) <=22 then pay_price else 0 end) as pay_day23,
sum(case when datediff(pay_dt,birth_dt) <=23 then pay_price else 0 end) as pay_day24,
sum(case when datediff(pay_dt,birth_dt) <=24 then pay_price else 0 end) as pay_day25,
sum(case when datediff(pay_dt,birth_dt) <=25 then pay_price else 0 end) as pay_day26,
sum(case when datediff(pay_dt,birth_dt) <=26 then pay_price else 0 end) as pay_day27, 
sum(case when datediff(pay_dt,birth_dt) <=27 then pay_price else 0 end) as pay_day28,
sum(case when datediff(pay_dt,birth_dt) <=28 then pay_price else 0 end) as pay_day29,
sum(case when datediff(pay_dt,birth_dt) <=29 then pay_price else 0 end) as pay_day30,
sum(case when datediff(pay_dt,birth_dt) <=30 then pay_price else 0 end) as pay_day31,
sum(case when datediff(pay_dt,birth_dt) <=31 then pay_price else 0 end) as pay_day32,
sum(case when datediff(pay_dt,birth_dt) <=32 then pay_price else 0 end) as pay_day33, 
sum(case when datediff(pay_dt,birth_dt) <=33 then pay_price else 0 end) as pay_day34,
sum(case when datediff(pay_dt,birth_dt) <=34 then pay_price else 0 end) as pay_day35,
sum(case when datediff(pay_dt,birth_dt) <=35 then pay_price else 0 end) as pay_day36,
sum(case when datediff(pay_dt,birth_dt) <=36 then pay_price else 0 end) as pay_day37,
sum(case when datediff(pay_dt,birth_dt) <=37 then pay_price else 0 end) as pay_day38,
sum(case when datediff(pay_dt,birth_dt) <=38 then pay_price else 0 end) as pay_day39, 
sum(case when datediff(pay_dt,birth_dt) <=39 then pay_price else 0 end) as pay_day40,
sum(case when datediff(pay_dt,birth_dt) <=40 then pay_price else 0 end) as pay_day41,
sum(case when datediff(pay_dt,birth_dt) <=41 then pay_price else 0 end) as pay_day42,
sum(case when datediff(pay_dt,birth_dt) <=42 then pay_price else 0 end) as pay_day43,
sum(case when datediff(pay_dt,birth_dt) <=43 then pay_price else 0 end) as pay_day44,
sum(case when datediff(pay_dt,birth_dt) <=44 then pay_price else 0 end) as pay_day45, 
sum(case when datediff(pay_dt,birth_dt) <=45 then pay_price else 0 end) as pay_day46,
sum(case when datediff(pay_dt,birth_dt) <=46 then pay_price else 0 end) as pay_day47,
sum(case when datediff(pay_dt,birth_dt) <=47 then pay_price else 0 end) as pay_day48,
sum(case when datediff(pay_dt,birth_dt) <=48 then pay_price else 0 end) as pay_day49,
sum(case when datediff(pay_dt,birth_dt) <=49 then pay_price else 0 end) as pay_day50,
sum(case when datediff(pay_dt,birth_dt) <=50 then pay_price else 0 end) as pay_day51, 
sum(case when datediff(pay_dt,birth_dt) <=51 then pay_price else 0 end) as pay_day52,
sum(case when datediff(pay_dt,birth_dt) <=52 then pay_price else 0 end) as pay_day53,
sum(case when datediff(pay_dt,birth_dt) <=53 then pay_price else 0 end) as pay_day54,
sum(case when datediff(pay_dt,birth_dt) <=54 then pay_price else 0 end) as pay_day55,
sum(case when datediff(pay_dt,birth_dt) <=55 then pay_price else 0 end) as pay_day56,
sum(case when datediff(pay_dt,birth_dt) <=56 then pay_price else 0 end) as pay_day57, 
sum(case when datediff(pay_dt,birth_dt) <=57 then pay_price else 0 end) as pay_day58,
sum(case when datediff(pay_dt,birth_dt) <=58 then pay_price else 0 end) as pay_day59,
sum(case when datediff(pay_dt,birth_dt) <=59 then pay_price else 0 end) as pay_day60

from
(select birth_dt,channel_id,device_id,country,country2,campaign,af_ad,
case when media_source  is not null then media_source
     when media_source  is null     then 'Organic'
end media_source,
case when campaign_type is not null then campaign_type
     when campaign_type is null then 'Organic'
end as install_source ,
case when campaign_type is not null then 'Paid'
     when campaign_type is null then 'Organic'
end as install_source2,
case when campaign_style is not null then campaign_style
     when campaign_style is null then 'Organic'
end as install_style
from
(select birth_dt,device_id,channel_id,country,country2
from 
(select to_date(cast (date_time as timestamp)) as birth_dt,device_id,channel_id,
case when country ='US' then '美国'
     when country ='DE' then '德国'
     when country ='FR' then '法国'
     when country ='GB' then '英国'
     when country ='CA' then '加拿大'
     when country ='AU' then '澳大利亚'
     when country ='NZ' then '新西兰'
     when country ='TH'  then '泰国'
     when country ='BR'  then '巴西'
     when country ='MY'  then '马来西亚'
     when country ='JP'  then '日本'
     when country ='KR'  then '韩国' 
     when country ='ID'  then '印尼'
     else 'others'
end as country,
case when country in ('US','DE','FR','GB','AU','CA','NZ','TH','BR','MY','JP','KR','ID') then country
     else 'others'
end as country2 
from fairy_town.device_activate
where  day_time>=20210916 and day_time<${endDate}
group by 1,2,3,4,5
union all
select to_date(cast (date_time as timestamp)) as birth_dt,device_id,channel_id,
case 
     when country in ('HK','TW','MO') then '港澳台' 
     else 'others'
end as country,
case when country  in ('HK','TW','MO') then country
     else 'others'
end as country2 
from fairy_town_tw.device_activate
where  day_time>=20220323 and day_time<${endDate}
group by 1,2,3,4,5
) aa
) a
left join 

(select customer_user_id,campaign_type,campaign_style,media_source,campaign,af_ad
from
(select customer_user_id,campaign, af_ad,
case when split_part(campaign,'-',4)='MAI'  then 'MAI'
     when split_part(campaign,'-',4)='AEO'  then 'AEO'
     when split_part(campaign,'-',4)='VO'   then 'VO'
     when split_part(campaign,'-',4)='Roas' then 'Roas'
     else 'Paid_Others'
end as campaign_type,
case when split_part(campaign,'-',3)='AAA'  then 'AAA'
     when split_part(campaign,'-',3)='NONE' then 'NONE'
     else 'Paid_Others'
end as campaign_style ,
case when media_source in ('Facebook Ads','restricted') then 'FB'
     when media_source = 'googleadwords_int' then 'GG'
     when media_source = 'applovin_int' then 'Applovin'
     when media_source = 'ironsource_int' then 'ironsource'
     when media_source = 'bytedanceglobal_int' then 'TikTok'
     else 'others'
end as media_source      
from fairy_town.af_push
where day_time>=20210916 and day_time<${endDate} 
group by 1,2,3,4,5,6
union all
select customer_user_id,campaign, af_ad,
case when split_part(campaign,'-',4)='MAI'  then 'MAI'
     when split_part(campaign,'-',4)='AEO'  then 'AEO'
     when split_part(campaign,'-',4)='VO'   then 'VO'
     when split_part(campaign,'-',4)='Roas' then 'Roas'
     else 'Paid_Others'
end as campaign_type,
case when split_part(campaign,'-',3)='AAA'  then 'AAA'
     when split_part(campaign,'-',3)='NONE' then 'NONE'
     else 'Paid_Others'
end as campaign_style ,
case when media_source in ('Facebook Ads','restricted') then 'FB'
     when media_source = 'googleadwords_int' then 'GG'
     when media_source = 'applovin_int' then 'Applovin'
     when media_source = 'ironsource_int' then 'ironsource'
     when media_source = 'bytedanceglobal_int' then 'TikTok'
     else 'others'
end as media_source      
from fairy_town_tw.af_push
where day_time>=20220323 and day_time<${endDate} 
group by 1,2,3,4,5,6
) bb
) b
on a.device_id=b.customer_user_id
) a 
left join 

(select pay_dt,device_id,pay_price -- 付费
from
(select to_date(cast (date_time as timestamp)) as pay_dt
,device_id,pay_price --设备ID
from fairy_town.order_pay
where day_time >= 20210916 and day_time<${endDate} 
union all
select to_date(cast (date_time as timestamp)) as pay_dt
,device_id,pay_price --设备ID
from fairy_town_tw.order_pay
where day_time >= 20220323 and day_time<${endDate}
) cc
) c 
on a.device_id=c.device_id

group by 1,2,3,4,5,6,7,8,9,10








新增留存
select * from (
select birth_dt,a.channel_id,country,country2, media_source,campaign,af_ad,
case when campaign_type is not null then campaign_type
     when campaign_type is null then 'Organic'
end as install_source ,
case when campaign_type is not null then 'Paid'
     when campaign_type is null then 'Organic'
end as install_source2 ,
case when campaign_style is not null then campaign_style
     when campaign_style is null then 'Organic'
end as install_style ,
datediff(login_dt,birth_dt) as datediffs,
count(distinct a.device_id) as devices
from 
(select birth_dt,device_id,channel_id,country,country2
from
(select to_date(cast (date_time as timestamp)) as birth_dt,device_id,channel_id,
case when country ='US' then '美国'
     when country ='DE' then '德国'
     when country ='FR' then '法国'
     when country ='GB' then '英国'
     when country ='CA' then '加拿大'
     when country ='AU' then '澳大利亚'
     when country ='NZ' then '新西兰'
     when country ='TH'  then '泰国'
     when country ='BR'  then '巴西'
     when country ='MY'  then '马来西亚'
     when country ='JP'  then '日本'
     when country ='KR'  then '韩国' 
     when country ='ID'  then '印尼'
     else 'others'
end as country,
case when country in ('US','DE','FR','GB','AU','CA','NZ','TH','BR','MY','JP','KR','ID') then country
     else 'others'
end as country2 
from fairy_town.device_activate
where day_time>=20210916 and day_time< ${endDate}
group by 1,2,3,4,5
) aa
) a
left outer join
(select customer_user_id,campaign,af_ad,campaign_type,campaign_style,media_source
from 
(select customer_user_id,campaign,af_ad,
case when split_part(campaign,'-',4)='MAI'  then 'MAI'
     when split_part(campaign,'-',4)='AEO'  then 'AEO'
     when split_part(campaign,'-',4)='VO'   then 'VO'
     when split_part(campaign,'-',4)='Roas' then 'Roas'
     else 'Paid_Others'
end as campaign_type,
case when split_part(campaign,'-',3)='AAA'  then 'AAA'
     when split_part(campaign,'-',3)='NONE' then 'NONE'
     else 'Paid_Others'
end as campaign_style ,
case when media_source in ('Facebook Ads','restricted') then 'FB'
     when media_source = 'googleadwords_int' then 'GG'
     when media_source = 'applovin_int' then 'Applovin'
     when media_source = 'ironsource_int' then 'ironsource'
     when media_source = 'bytedanceglobal_int' then 'TikTok'
     else 'others'
     end  as media_source      
from fairy_town.af_push
where day_time>=20210420 and day_time< ${endDate} 
group by 1,2,3,4,5,6
) bb
) b
on device_id=customer_user_id
left join 
(select login_dt,device_id
from
(select to_date(cast (date_time as timestamp)) as login_dt
,device_id
from fairy_town.device_launch
where day_time>=20210916 and day_time<= ${endDate}  
group by 1,2
) cc
) c
on a.device_id=c.device_id and login_dt>=birth_dt
where datediff(login_dt,birth_dt) in (0,1,6,13,29,59)
group by 1,2,3,4,5,6,7,8,9,10,11
) as aaa





变现分析



SELECT day_time,ad_position,count(1) as '点击数' from fairy_town_server_tw.server_ad_btn_click
where server_id in (10001,10002,10003)
and day_time >= 20211209 and day_time <= 20220731
GROUP BY 1,2


SELECT day_time,ad_position,count(1) as '领奖数' from fairy_town_server_tw.server_ad_rewards
where server_id in (10001,10002,10003)
and day_time >= 20211209 and day_time <= 20220731
GROUP BY 1,2





select day_time,sum(count_role)
from 
(select day_time,count(distinct role_id) as count_role from fairy_town.server_role_login
where server_id in (10001,10002,10003)
and log_time >= 1639022400000 and day_time <= 20220731
and role_level >= 2
group by 1
order by 1
union  all
select day_time,count(distinct role_id) as count_role from fairy_town.server_role_upgrade
where server_id in (10001,10002,10003)
and log_time >= 1639022400000 and day_time <= 20220731
and role_level = 2
group by 1
order by 1
union all
select day_time,count(distinct role_id) as count_role from fairy_town_tw.server_role_login
where server_id in (10001,10002,10003)
and log_time >= 1639022400000 and day_time <= 20220731
and role_level >= 2
group by 1
order by 1
union  all
select day_time,count(distinct role_id) as count_role from fairy_town_tw.server_role_upgrade
where server_id in (10001,10002,10003)
and log_time >= 1639022400000 and day_time <= 20220731
and role_level = 2
group by 1
order by 1

)
as a
group by 1 order by 1


点击
SELECT *
from
(SELECT day_time,ad_position,count(DISTINCT role_id) from fairy_town_server.server_ad_btn_click
where server_id in (10001,10002,10003)
and day_time >= 20211209 and day_time <= 20220731
GROUP BY 1,2
ORDER BY 1
UNION all
SELECT day_time,ad_position,count(DISTINCT role_id) from fairy_town_server_tw.server_ad_btn_click
where server_id in (10001,10002,10003)
and day_time >= 20211209 and day_time <= 20220731
GROUP BY 1,2
ORDER BY 1
) as a





点击的用户
select click_dt,datediff(login_dt,click_dt) as diffs,pay_zone,count(distinct a.role_id)
from 
(select click_dt,a.role_id,
case when pay is  null then 0
     when pay>0   and pay<=10  then 10
     when pay>10  and pay<=20  then 20
     when pay>20  and pay<=100 then 100
     when pay>100              then 1000
     end as pay_zone
    from  
(select to_date(cast(date_time as timestamp)) as click_dt,role_id
from fairy_town_server.server_ad_btn_click
where day_time >= ${start_time} and day_time <= ${endDate} 
and server_id in (10001,10002,10003)
) a 
left join 
(select role_id,sum(pay_price) as pay
from fairy_town.order_pay
where day_time>=20210420 and day_time<=${endDate} 
group by 1) b 
on a.role_id=b.role_id
) a 
left join 
(select to_date(cast(date_time as timestamp)) as login_dt,role_id
from fairy_town.server_role_login
where day_time >= ${start_time} and day_time <= ${endDate} 
and server_id in (10001,10002,10003)
) c 
on a.role_id=c.role_id and login_dt>=click_dt
group by 1,2,3



2022年3月23 开台湾
select click_dt,datediff(login_dt,click_dt) as diffs,pay_zone,count(distinct a.role_id)
from 
(select click_dt,a.role_id,
case when pay is  null then 0
     when pay>0   and pay<=10  then 10
     when pay>10  and pay<=20  then 20
     when pay>20  and pay<=100 then 100
     when pay>100              then 1000
     end as pay_zone
    from  
(select to_date(cast(date_time as timestamp)) as click_dt,role_id
from fairy_town_server_tw.server_ad_btn_click
where day_time >= ${start_time} and day_time <= ${endDate} 
and server_id in (10001,10002,10003)
) a 
left join 
(select role_id,sum(pay_price) as pay
from fairy_town_tw.order_pay
where day_time>=20210420 and day_time<=${endDate} 
group by 1) b 
on a.role_id=b.role_id
) a 
left join 
(select to_date(cast(date_time as timestamp)) as login_dt,role_id
from fairy_town_tw.server_role_login
where day_time >= ${start_time} and day_time <= ${endDate} 
and server_id in (10001,10002,10003)
) c 
on a.role_id=c.role_id and login_dt>=click_dt
group by 1,2,3





未点击的用户 但是等级>=4
select click_dt,datediff(login_dt,click_dt) as diffs,pay_zone,count(distinct a.role_id)
from 
(select click_dt,a.role_id,
case when pay is  null then 0
     when pay>0   and pay<=10  then 10
     when pay>10  and pay<=20  then 20
     when pay>20  and pay<=100 then 100
     when pay>100              then 1000
     end as pay_zone
    from  
(select click_dt,role_id
from 
(select to_date(cast(date_time as timestamp)) as click_dt,role_id
from fairy_town.server_role_upgrade
where day_time >= ${start_time} and day_time <= ${endDate} 
and log_time>=1639027280437 
and server_id in (10001,10002,10003)
and role_level>=4
and role_id not in (select role_id
from fairy_town_server.server_ad_btn_click
where day_time >= ${start_time} and day_time <= ${endDate}
and server_id in (10001,10002,10003))
union all 
select to_date(cast(date_time as timestamp)) as click_dt, role_id
from fairy_town.server_role_login
where day_time >= ${start_time} and day_time <= ${endDate}
and log_time>=1639027280437 
and server_id in (10001,10002,10003)
and role_level>=4
and role_id not in (select role_id
from fairy_town_server.server_ad_btn_click
where day_time >= ${start_time} and day_time <= ${endDate}
and server_id in (10001,10002,10003))
) a1 
group by 1,2
) a 
left join 
(select role_id,sum(pay_price) as pay
from fairy_town.order_pay
where day_time>=20210420 and day_time<=${endDate} 
group by 1) b 
on a.role_id=b.role_id
) a 
left join 
(select to_date(cast(date_time as timestamp)) as login_dt,role_id
from fairy_town.server_role_login
where day_time >= ${start_time} and day_time <= ${endDate}
and server_id in (10001,10002,10003)
) c 
on a.role_id=c.role_id and login_dt>=click_dt
group by 1,2,3




台湾
select click_dt,datediff(login_dt,click_dt) as diffs,pay_zone,count(distinct a.role_id)
from 
(select click_dt,a.role_id,
case when pay is  null then 0
     when pay>0   and pay<=10  then 10
     when pay>10  and pay<=20  then 20
     when pay>20  and pay<=100 then 100
     when pay>100              then 1000
     end as pay_zone
    from  
(select click_dt,role_id
from 
(select to_date(cast(date_time as timestamp)) as click_dt,role_id
from fairy_town_tw.server_role_upgrade
where day_time >= ${start_time} and day_time <= ${endDate} 
and log_time>=1639027280437 
and server_id in (10001,10002,10003)
and role_level>=4
and role_id not in (select role_id
from fairy_town_server_tw.server_ad_btn_click
where day_time >= ${start_time} and day_time <= ${endDate}
and server_id in (10001,10002,10003))
union all 
select to_date(cast(date_time as timestamp)) as click_dt, role_id
from fairy_town_tw.server_role_login
where day_time >= ${start_time} and day_time <= ${endDate}
and log_time>=1639027280437 
and server_id in (10001,10002,10003)
and role_level>=4
and role_id not in (select role_id
from fairy_town_server_tw.server_ad_btn_click
where day_time >= ${start_time} and day_time <= ${endDate}
and server_id in (10001,10002,10003))
) a1 
group by 1,2
) a 
left join 
(select role_id,sum(pay_price) as pay
from fairy_town_tw.order_pay
where day_time>=20210420 and day_time<=${endDate} 
group by 1) b 
on a.role_id=b.role_id
) a 
left join 
(select to_date(cast(date_time as timestamp)) as login_dt,role_id
from fairy_town_tw.server_role_login
where day_time >= ${start_time} and day_time <= ${endDate}
and server_id in (10001,10002,10003)
) c 
on a.role_id=c.role_id and login_dt>=click_dt
group by 1,2,3


