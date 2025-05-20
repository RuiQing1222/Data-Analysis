激活设备
select birth_dt,country,country2,channel_id,campaign,campaign_type,campaign_style,media_source,
     case when campaign_type is not null then 'Paid'
          else  'Organic'
     end as install_source,
     count(distinct a.device_id) as devices
from 
(select birth_dt,channel_id,device_id,country,country2
from
(select to_date(cast (date_time as timestamp)) as birth_dt,channel_id,device_id,
case when country ='US'  then '美国'
     when country ='DE'  then '德国'
     when country ='FR'  then '法国'
     when country in ('GB','AU','CA','NZ') then '英加澳洲' 
     when country in ('SE','DK','NO','FI') then '北欧四国'
     when country in ('IT','ES','RU','NL','BE','PL','AT','CH') then '其他国家' 
     when country ='TH'  then '泰国'
     when country ='BR'  then '巴西'
     when country ='SG'  then '新加坡'
     when country ='MY'  then '马来西亚'      
     when country ='IN'  then '印度'
     when country = 'JP' then '日本'
     when country = 'KR' then '韩国'
     else 'others'
end as country,
case when country in ('US','DE','FR','GB','AU','CA','NZ','SE','DK','NO','FI','IT','ES','RU','NL','BE','PL','AT','CH','TH','BR','SG','MY','IN','JP','KR') then country
     else 'others'
end as country2
from fairy_town.device_activate
where day_time>=20210916 and day_time< ${endDate} and country not in  ('CN','HK')
group by 1,2,3,4,5
union all
select to_date(cast (date_time as timestamp)) as birth_dt,channel_id,device_id,
case when country in ('TW','HK','MO')  then '港澳台'
     else 'others'
end as country,
case when country in ('TW','HK','MO') then country
     else 'others'
end as country2
from fairy_town_tw.device_activate
where day_time>=20220323 and day_time< ${endDate} and country not in  ('CN')
group by 1,2,3,4,5
) aa 
) a
left outer join 
(select customer_user_id,campaign,campaign_type,campaign_style,media_source
from
(select customer_user_id,campaign,
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
     when media_source = 'snapchat_int' then 'SnapChat'
     when media_source = 'Apple Search Ads' then 'ASA'
     when media_source = 'applovin_int'      then 'Applovin'
     when media_source = 'vungle_int' then 'vungle_int'
     else 'others'
end as media_source      
from fairy_town.af_push
where day_time>=20210916 and day_time< ${endDate} 
group by 1,2,3,4,5
union all
select customer_user_id,campaign,
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
     when media_source = 'snapchat_int' then 'SnapChat'
     when media_source = 'Apple Search Ads' then 'ASA'
     when media_source = 'applovin_int'      then 'Applovin'
     when media_source = 'vungle_int' then 'vungle_int'
     else 'others'
end as media_source      
from fairy_town_tw.af_push
where day_time>=20220323 and day_time< ${endDate} 
group by 1,2,3,4,5  
) cc
) c
on a.device_id=customer_user_id
group by 1,2,3,4,5,6,7,8,9






新增用户&新增付费用户&新增收入

select  birth_dt,a.channel_id as channel_id,country,country2,media_source,
case when campaign is not null then campaign
     when campaign is null then 'Organic'
end as campaign_type,
case when campaign_type is not null then campaign_type
     when campaign_type is null then 'Organic'
end as install_source,
case when campaign_type is not null then 'Paid'
     when campaign_type is null then 'Organic'
end as install_source2,
case when campaign_style is not null then campaign_style
     when campaign_style is null then 'Organic'
end as install_style ,
count(distinct a.user_id) as '新增用户',
count(distinct case when datediff(pay_dt,birth_dt) =0 then d.user_id  else null end) as '新增付费用户',
sum(case when datediff(pay_dt,birth_dt) =0 then pay_price else 0 end) as '新增付费收入'

from
(select birth_dt,user_id,channel_id,device_id,country,country2
from 
(select to_date(cast (date_time as timestamp)) as birth_dt,user_id,channel_id,device_id,
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
     when country = 'JP' then '日本'
     when country = 'KR' then '韩国'
     else 'others'
end as country,
case when country in ('US','DE','FR','GB','AU','CA','NZ','SE','DK','NO','FI','IT','ES','RU','NL','BE','PL','AT','CH','TH','BR','SG','MY','IN','JP','KR') then country
     else 'others'
end as country2
from fairy_town.user_create
where day_time>=20210916 and day_time< ${endDate} and country not in  ('CN','HK')
group by 1,2,3,4,5,6
union all
select to_date(cast (date_time as timestamp)) as birth_dt,user_id,channel_id,device_id,
case when country in ('TW','HK','MO')  then '港澳台'
     else 'others'
end as country,
case when country in ('TW','HK','MO') then country
     else 'others'
end as country2
from fairy_town_tw.user_create
where day_time>=20220323 and day_time< ${endDate} and country not in  ('CN')
group by 1,2,3,4,5,6
) aa
) a  

left outer join 
(select customer_user_id,campaign,campaign_type,campaign_style,media_source
from
(select customer_user_id,campaign,
case when split_part(campaign,'-',4)='MAI'  then 'MAI'
     when split_part(campaign,'-',4)='AEO'  then 'AEO'
     when split_part(campaign,'-',4)='VO'   then 'VO'
     when split_part(campaign,'-',4)='Roas' then 'Roas'
     else 'Paid_Others'
end as campaign_type,
case when split_part(campaign,'-',3)='AAA'  then 'AAA'
     when split_part(campaign,'-',3)='NONE' then 'NONE'
     else 'Paid_Others'
end as campaign_style,
case when media_source in ('Facebook Ads','restricted') then 'FB'
     when media_source = 'googleadwords_int' then 'GG'
     when media_source = 'snapchat_int' then 'SnapChat'
     when media_source = 'Apple Search Ads' then 'ASA'
     when media_source = 'applovin_int'      then 'Applovin'
     when media_source = 'vungle_int' then 'vungle_int'
     else 'others'
end as media_source      
from fairy_town.af_push
where day_time>=20210916 and day_time< ${endDate}
group by 1,2,3,4,5
union all
select customer_user_id,campaign,
case when split_part(campaign,'-',4)='MAI'  then 'MAI'
     when split_part(campaign,'-',4)='AEO'  then 'AEO'
     when split_part(campaign,'-',4)='VO'   then 'VO'
     when split_part(campaign,'-',4)='Roas' then 'Roas'
     else 'Paid_Others'
end as campaign_type,
case when split_part(campaign,'-',3)='AAA'  then 'AAA'
     when split_part(campaign,'-',3)='NONE' then 'NONE'
     else 'Paid_Others'
end as campaign_style,
case when media_source in ('Facebook Ads','restricted') then 'FB'
     when media_source = 'googleadwords_int' then 'GG'
     when media_source = 'snapchat_int' then 'SnapChat'
     when media_source = 'Apple Search Ads' then 'ASA'
     when media_source = 'applovin_int'      then 'Applovin'
     when media_source = 'vungle_int' then 'vungle_int'
     else 'others'
end as media_source      
from fairy_town_tw.af_push
where day_time>=20220323 and day_time< ${endDate}
group by 1,2,3,4,5
) cc
) c
on a.device_id=customer_user_id

left outer join 
(select pay_dt,user_id,pay_price
from
(select to_date(cast (date_time as timestamp)) as pay_dt
,user_id,pay_price --设备ID
from fairy_town.order_pay
where day_time>=20210916 and day_time< ${endDate} and server_id in (10001,10002,10003)
union all
select to_date(cast (date_time as timestamp)) as pay_dt
,user_id,pay_price --设备ID
from fairy_town_tw.order_pay
where day_time>=20220323 and day_time< ${endDate} and server_id in (10001,10002,10003)
) dd
) d 
on a.user_id=d.user_id
group by 1,2,3,4,5,6,7,8,9




启动设备

select birth_dt,country,country2,channel_id,campaign,campaign_type,campaign_style,media_source,
case when campaign_type is not null then 'Paid'
     else 'Organic'
end as install_source,
count(distinct a.device_id) as devices
from
(select birth_dt,channel_id,device_id,country,country2
from 
(select to_date(cast (date_time as timestamp)) as birth_dt,channel_id,device_id,
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
     when country = 'JP' then '日本'
     when country = 'KR' then '韩国'
     else 'others'
end as country,
case when country in ('US','DE','FR','GB','AU','CA','NZ','SE','DK','NO','FI','IT','ES','RU','NL','BE','PL','AT','CH','TH','BR','SG','MY','IN','JP','KR') then country
     else 'others'
end as country2
from fairy_town.device_launch
where day_time>=20210916 and day_time< ${endDate} and country not in  ('CN','HK')
group by 1,2,3,4,5
union all
select to_date(cast (date_time as timestamp)) as birth_dt,channel_id,device_id,
case when country in ('TW','HK','MO')  then '港澳台'
     else 'others'
end as country,
case when country in ('TW','HK','MO') then country
     else 'others'
end as country2
from fairy_town_tw.device_launch
where day_time>=20220323 and day_time< ${endDate} and country not in  ('CN')
group by 1,2,3,4,5
) aa
)a 
left outer join 
(select customer_user_id,campaign,campaign_type,campaign_style,media_source
from
(select customer_user_id,campaign,
case when split_part(campaign,'-',4)='MAI'  then 'MAI'
     when split_part(campaign,'-',4)='AEO'  then 'AEO'
     when split_part(campaign,'-',4)='VO'   then 'VO'
     when split_part(campaign,'-',4)='Roas' then 'Roas'
     else 'Paid_Others'
end as campaign_type,
case when split_part(campaign,'-',3)='AAA' then 'AAA'
     when split_part(campaign,'-',3)='NONE' then 'NONE'
     else 'Paid_Others'
end as campaign_style ,
case when media_source in ('Facebook Ads','restricted') then 'FB'
     when media_source = 'googleadwords_int' then 'GG'
     when media_source = 'snapchat_int' then 'SnapChat'
     when media_source = 'Apple Search Ads' then 'ASA'
     when media_source = 'applovin_int'      then 'Applovin'
     when media_source = 'vungle_int' then 'vungle_int'
     else 'others'
end as media_source      
from fairy_town.af_push
where day_time>=20210420 and day_time< ${endDate}
group by 1,2,3,4,5
union all
select customer_user_id,campaign,
case when split_part(campaign,'-',4)='MAI'  then 'MAI'
     when split_part(campaign,'-',4)='AEO'  then 'AEO'
     when split_part(campaign,'-',4)='VO'   then 'VO'
     when split_part(campaign,'-',4)='Roas' then 'Roas'
     else 'Paid_Others'
end as campaign_type,
case when split_part(campaign,'-',3)='AAA' then 'AAA'
     when split_part(campaign,'-',3)='NONE' then 'NONE'
     else 'Paid_Others'
end as campaign_style ,
case when media_source in ('Facebook Ads','restricted') then 'FB'
     when media_source = 'googleadwords_int' then 'GG'
     when media_source = 'snapchat_int' then 'SnapChat'
     when media_source = 'Apple Search Ads' then 'ASA'
     when media_source = 'applovin_int'      then 'Applovin'
     when media_source = 'vungle_int' then 'vungle_int'
     else 'others'
end as media_source      
from fairy_town_tw.af_push
where day_time>=20220323 and day_time< ${endDate}
group by 1,2,3,4,5
) cc
) c
on a.device_id=customer_user_id
group by 1,2,3,4,5,6,7,8,9






登录用户&登录付费用户&付费总收入

select  login_dt,channel_id,country,country2,media_source,install_source,install_source2,
count(distinct a.user_id) as '登录用户',
count(distinct case when datediff(login_dt,pay_dt)=0 then d.user_id else null end ) as '登录付费用户',
sum(case when datediff(login_dt,pay_dt)=0 then pay_price else 0 end  ) as '付费总收入'

from 
(select login_dt,a.user_id,channel_id,device_id,country,country2,
case when media_source  is not null then  media_source
     when media_source  is null then 'Organic'
end media_source,
case when campaign_type is not null then campaign_type
     when campaign_type is null then 'Organic'
end as install_source,
case when campaign_type is not null then 'Paid'
     when campaign_type is null then 'Organic'
end as install_source2
from
(select login_dt,user_id,channel_id,device_id,country,country2
from 
(select to_date(cast (date_time as timestamp)) as login_dt,user_id,channel_id,device_id,
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
     when country = 'JP' then '日本'
     when country = 'KR' then '韩国'
     else 'others'
     end as country,
case when country in ('US','DE','FR','GB','AU','CA','NZ','SE','DK','NO','FI','IT','ES','RU','NL','BE','PL','AT','CH','TH','BR','SG','MY','IN','JP','KR') then country
     else 'others'
end as country2
from fairy_town.user_login
where day_time>=20210916 and day_time< ${endDate} and country not in  ('CN','HK')
group by 1,2,3,4,5,6
union all
select to_date(cast (date_time as timestamp)) as login_dt,user_id,channel_id,device_id,
case when country in ('TW','HK','MO')  then '港澳台'
     else 'others'
     end as country,
case when country in ('TW','HK','MO') then country
     else 'others'
end as country2
from fairy_town_tw.user_login
where day_time>=20220323 and day_time< ${endDate} and country not in  ('CN')
group by 1,2,3,4,5,6
) aa
) a 
left outer join
(select customer_user_id,campaign_type,media_source
from 
(select customer_user_id,
case when split_part(campaign,'-',4)='MAI'  then 'MAI'
     when split_part(campaign,'-',4)='AEO'  then 'AEO'
     when split_part(campaign,'-',4)='VO'   then 'VO'
     when split_part(campaign,'-',4)='Roas' then 'Roas'
     else 'Paid_Others'
end as campaign_type,
case when media_source in ('Facebook Ads','restricted') then 'FB'
     when media_source = 'googleadwords_int' then 'GG'
     when media_source = 'unityads_int'      then 'Unity'
     when media_source = 'snapchat_int'      then 'SnapChat'
     when media_source = 'applovin_int'      then 'Applovin'
     when media_source = 'Apple Search Ads'  then 'ASA'
     when media_source in('KOL','KOL_TheFamilyProject') then 'KOL'
     when media_source = 'Twitter'           then 'Twitter'
     when media_source = 'vungle_int' then 'vungle_int'
     else 'others'
end as media_source      
from fairy_town.af_push
where day_time>=20210420 and day_time< ${endDate}
group by 1,2,3
union all
select customer_user_id,
case when split_part(campaign,'-',4)='MAI'  then 'MAI'
     when split_part(campaign,'-',4)='AEO'  then 'AEO'
     when split_part(campaign,'-',4)='VO'   then 'VO'
     when split_part(campaign,'-',4)='Roas' then 'Roas'
     else 'Paid_Others'
end as campaign_type,
case when media_source in ('Facebook Ads','restricted') then 'FB'
     when media_source = 'googleadwords_int' then 'GG'
     when media_source = 'unityads_int'      then 'Unity'
     when media_source = 'snapchat_int'      then 'SnapChat'
     when media_source = 'applovin_int'      then 'Applovin'
     when media_source = 'Apple Search Ads'  then 'ASA'
     when media_source in('KOL','KOL_TheFamilyProject') then 'KOL'
     when media_source = 'Twitter'           then 'Twitter'
     when media_source = 'vungle_int' then 'vungle_int'
     else 'others'
end as media_source      
from fairy_town_tw.af_push
where day_time>=20220323 and day_time< ${endDate}
group by 1,2,3 
) cc
) c
on a.device_id=customer_user_id
) a 
left join
(select pay_dt,user_id,pay_price
from 
(select to_date(cast (date_time as timestamp)) as pay_dt
,user_id,pay_price --设备ID
from fairy_town.order_pay
where day_time>=20210916 and day_time< ${endDate} and server_id in (10001,10002,10003)
union all
select to_date(cast (date_time as timestamp)) as pay_dt
,user_id,pay_price --设备ID
from fairy_town_tw.order_pay
where day_time>=20220323 and day_time< ${endDate} and server_id in (10001,10002,10003)  
) dd
)d  
on a.user_id=d.user_id
group by 1,2,3,4,5,6,7 








设备回收

select birth_dt,channel_id,country,country2,media_source,install_source,install_source2,
count(distinct a.device_id) as devices,
sum(pay_price) as pay_total,
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
sum(case when datediff(pay_dt,birth_dt) <=89 then pay_price else 0 end) as pay_day90,
sum(case when datediff(pay_dt,birth_dt) <=119 then pay_price else 0 end) as pay_day120
from
(select birth_dt,channel_id,device_id,country,country2,
case when media_source  is not null then media_source
     when media_source  is null     then 'Organic'
end media_source,
case when campaign_type is not null then campaign_type
     when campaign_type is null then 'Organic'
end as install_source ,
case when campaign_type is not null then 'Paid'
     when campaign_type is null then 'Organic'
end as install_source2
from
(select birth_dt,device_id,channel_id,country,country2
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
     when country = 'JP' then '日本'
     when country = 'KR' then '韩国'
     else 'others'
end as country,
case when country  in ('US','DE','FR','GB','AU','CA','NZ','SE','DK','NO','FI','IT','ES','RU','NL','BE','PL','AT','CH','TH','BR','SG','MY','IN','JP','KR') then country
     else 'others'
end as country2 
from fairy_town.device_activate
where  day_time>=20210916 and day_time<${endDate} and country not in  ('CN','HK')
group by 1,2,3,4,5
union all
select to_date(cast (date_time as timestamp)) as birth_dt,device_id,channel_id,
case when country in ('TW','HK','MO')  then '港澳台'
     else 'others'
end as country,
case when country  in ('TW','HK','MO') then country
     else 'others'
end as country2 
from fairy_town_tw.device_activate
where  day_time>=20220323 and day_time<${endDate} and country not in  ('CN')
group by 1,2,3,4,5
) aa
) a  
left outer join
(select customer_user_id,campaign_type,media_source
from 
(select customer_user_id,
case when split_part(campaign,'-',4)='MAI'  then 'MAI'
     when split_part(campaign,'-',4)='AEO'  then 'AEO'
     when split_part(campaign,'-',4)='VO'   then 'VO'
     when split_part(campaign,'-',4)='Roas' then 'Roas'
     else 'Paid_Others'
end as campaign_type,
case when media_source in ('Facebook Ads','restricted') then 'FB'
     when media_source = 'googleadwords_int' then 'GG'
     when media_source = 'unityads_int'      then 'Unity'
     when media_source = 'snapchat_int'      then 'SnapChat'
     when media_source = 'applovin_int'      then 'Applovin'
     when media_source = 'Apple Search Ads'  then 'ASA'
     when media_source in('KOL','KOL_TheFamilyProject') then 'KOL'
     when media_source = 'Twitter'           then 'Twitter'
     when media_source = 'vungle_int' then 'vungle_int'
     when media_source = 'chartboosts2s_int' then 'chartboosts'
     when media_source = 'ironsource_int' then 'ironsource'
     else 'others'
end as media_source      
from fairy_town.af_push
where day_time>=20210916  and day_time<${endDate}
group by 1,2,3
union all
select customer_user_id,
case when split_part(campaign,'-',4)='MAI'  then 'MAI'
     when split_part(campaign,'-',4)='AEO'  then 'AEO'
     when split_part(campaign,'-',4)='VO'   then 'VO'
     when split_part(campaign,'-',4)='Roas' then 'Roas'
     else 'Paid_Others'
end as campaign_type,
case when media_source in ('Facebook Ads','restricted') then 'FB'
     when media_source = 'googleadwords_int' then 'GG'
     when media_source = 'unityads_int'      then 'Unity'
     when media_source = 'snapchat_int'      then 'SnapChat'
     when media_source = 'applovin_int'      then 'Applovin'
     when media_source = 'Apple Search Ads'  then 'ASA'
     when media_source in('KOL','KOL_TheFamilyProject') then 'KOL'
     when media_source = 'Twitter'           then 'Twitter'
     when media_source = 'vungle_int' then 'vungle_int'
     when media_source = 'chartboosts2s_int' then 'chartboosts'
     when media_source = 'ironsource_int' then 'ironsource'
     else 'others'
end as media_source      
from fairy_town_tw.af_push
where day_time>=20220323  and day_time<${endDate}
group by 1,2,3
) bb
) b
on a.device_id=b.customer_user_id
) a 
left outer join
(select pay_dt,device_id,pay_price
from 
(select to_date(cast (date_time as timestamp)) as pay_dt
,device_id,pay_price --设备ID
from fairy_town.order_pay
where day_time >= 20210916 and day_time<${endDate} and server_id in (10001,10002,10003)
union all
select to_date(cast (date_time as timestamp)) as pay_dt
,device_id,pay_price --设备ID
from fairy_town_tw.order_pay
where day_time >= 20220323 and day_time<${endDate} and server_id in (10001,10002,10003)
) cc
) c 
on a.device_id=c.device_id
group by 1,2,3,4,5,6,7 







新增留存

select birth_dt,a.channel_id as channel_id,
-- country,country2,
media_source,
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
(select birth_dt,device_id,channel_id
from
(select to_date(cast (date_time as timestamp)) as birth_dt,device_id,channel_id
-- case when country ='US' then '美国'
--      when country ='DE' then '德国'
--      when country ='FR' then '法国'
--      when country in ('GB','AU','CA','NZ') then '英加澳洲' 
--      when country in ('SE','DK','NO','FI') then '北欧四国'
--      when country in ('IT','ES','RU','NL','BE','PL','AT','CH') then '其他国家' 
--      when country ='TH'  then '泰国'
--      when country ='BR'  then '巴西'
--      when country ='SG'  then '新加坡'
--      when country ='MY'  then '马来西亚'       
--      when country ='IN'  then '印度'
--      else 'others'
-- end as country,
-- case when country  in ('US','DE','FR','GB','AU','CA','NZ','SE','DK','NO','FI','IT','ES','RU','NL','BE','PL','AT','CH','TH','BR','SG','MY','IN')    then country
--      else 'others'
-- end as country2
from fairy_town.device_activate
where day_time>=20210916 and day_time< ${endDate}  
and country not in  ('CN','HK')
group by 1,2,3
union all
select to_date(cast (date_time as timestamp)) as birth_dt,device_id,channel_id
-- case when country in ('TW','HK','MO')  then '港澳台'
--      else 'others'
-- end as country,
-- case when country  in ('TW','HK','MO') then country
--      else 'others'
-- end as country2
from fairy_town_tw.device_activate
where day_time>=20220323 and day_time< ${endDate}  
and country not in  ('CN','HK')
group by 1,2,3
) aa 
) a
left outer join
(select customer_user_id,campaign,campaign_type,campaign_style,media_source
from 
(select customer_user_id,campaign,
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
     when media_source = 'snapchat_int'      then 'SnapChat'
     when media_source = 'Apple Search Ads'  then 'ASA'
     when media_source = 'applovin_int'      then 'applovin'
     when media_source = 'vungle_int' then 'vungle_int'
     when media_source = 'chartboosts2s_int' then 'chartboosts'
     when media_source = 'ironsource_int' then 'ironsource'
     else  'others'
     end  as media_source      
from fairy_town.af_push
where day_time>=20210420 and day_time< ${endDate}
group by 1,2,3,4,5
union all
select customer_user_id,campaign,
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
     when media_source = 'snapchat_int'      then 'SnapChat'
     when media_source = 'Apple Search Ads'  then 'ASA'
     when media_source = 'applovin_int'      then 'applovin'
     when media_source = 'vungle_int' then 'vungle_int'
     when media_source = 'chartboosts2s_int' then 'chartboosts'
     when media_source = 'ironsource_int' then 'ironsource'
     else  'others'
     end  as media_source      
from fairy_town_tw.af_push
where day_time>=20220323 and day_time< ${endDate}
group by 1,2,3,4,5
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
union all
select to_date(cast (date_time as timestamp)) as login_dt
,device_id
from fairy_town_tw.device_launch
where day_time>=20220323 and day_time<= ${endDate}  
group by 1,2 
) cc
) c 
on a.device_id=c.device_id and login_dt>=birth_dt
where datediff(login_dt,birth_dt) in (0,1,2,3,4,5,6,13,29,44,59,89,119)
group by 1,2,3,4,5,6,7


1月新增付费在2月付费的跌幅    和     2月新增付费在3月付费的跌幅不同