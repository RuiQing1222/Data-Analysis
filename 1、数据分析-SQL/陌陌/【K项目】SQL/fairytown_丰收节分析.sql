

时间 2022年1月20日12点至25日3点

参与率


日参与率
select day_time,count(distinct role_id)
from fairy_town.server_prop
where day_time>=20220120 and day_time<=20220125
and server_id in (10001,10002,10003)
and prop_id='340001'
and change_type='PRODUCE'
group by 1

select day_time,count(distinct role_id) from 
(select day_time,role_id,sum(nums)over(partition by role_id)  as total_nums
from 
(select day_time,role_id,sum(change_count) as nums
from fairy_town.server_prop
where day_time>=20220120 and day_time<=20220125
and server_id in (10001,10002,10003)
and prop_id='340001'
and change_type='PRODUCE'
group by 1,2) a 
) a 
where total_nums>=30
group by 1


10级以上活跃


select  day_time,count(distinct role_id) as activers
from 
(select day_time,role_id
from fairy_town.server_role_login
where day_time>=20220120 and day_time<=20220125
and log_time>=1642651200000  and  log_time<=1643050800000
and server_id in (10001,10002,10003)
and role_level>=10
union
select day_time,role_id
from fairy_town.server_prop
where day_time>=20220120 and day_time<=20220125
and server_id in (10001,10002,10003)
and prop_id='340001'
and change_type='PRODUCE'
group by 1
)  a 
group by 1

总参与率

select  count(distinct role_id)
from fairy_town.server_prop
where day_time>=20220120 and day_time<=20220125
and server_id in (10001,10002,10003)
and prop_id='340001'
and change_type='PRODUCE'


总活跃
select  count(distinct role_id) as activers
from 
(select role_id
from fairy_town.server_role_login
where day_time>=20220120 and day_time<=20220125
and log_time>=1642651200000  and  log_time<=1643050800000
and server_id in (10001,10002,10003)
and role_level>=10
union
select role_id
from fairy_town.server_prop
where day_time>=20220120 and day_time<=20220125
and server_id in (10001,10002,10003)
and prop_id='340001'
and change_type='PRODUCE'
group by 1
)  a 



积分区间
=IF(C2>=12000,5,IF(C2>=6000,4,IF(C2>=2000,3,IF(C2>=600,2,IF(C2>=20,1,0)))))


宽表

select a.role_id,day_time,nums,b.pay as '当期收入',otherpay,c.pay as '上期收入'
from 
(select role_id,sum(change_count) as nums 
from fairy_town.server_prop
where day_time>=20220120 and day_time<=20220125
and server_id in (10001,10002,10003)
and prop_id='340001'
and change_type='PRODUCE'
group by 1) a 
left join 
(select day_time,role_id
from fairy_town.server_role_create
where day_time>=20220120 and day_time<=20220125
and server_id in (10001,10002,10003)
group by 1,2
) e 
on a.role_id=e.role_id
left join 
(select role_id,
sum(pay_price) as pay,
sum(case when product_name<>'战令' then pay_price else 0 end ) as otherpay
from fairy_town.order_pay
where day_time>=20220120 and day_time<=20220125
and server_id in (10001,10002,10003)
and log_time>=1642651200000  and  log_time<=1643050800000
group by 1
) b 
on a.role_id=b.role_id
left join 
(select role_id,
sum(pay_price) as pay
from fairy_town.order_pay
where day_time>=20220113 and day_time<=20220118
and server_id in (10001,10002,10003)
and log_time>=1642046400000  and  log_time<=1642446000000
group by 1
) c 
on a.role_id=c.role_id
group by 1,2,3,4,5,6



新增对应周期内收入


select count(distinct role_id),sum(pay_price) as pay
from fairy_town.order_pay
where day_time>=20220113 and day_time<=20220118
and server_id in (10001,10002,10003)
and log_time>=1642046400000  and  log_time<=1642446000000
and role_id in (select day_time,role_id
from fairy_town.server_role_create
where day_time>=20220113 and day_time<=20220118
and server_id in (10001,10002,10003))





货币存量

select day_time,count(distinct role_id),
avg(gold) as avg_gold,appx_median(gold) as median_gold,
avg(gem) as gem ,appx_median(gem) as median_gem 
from fairy_town_server.server_login_snap_shot
where day_time>=20220113 and day_time<=20220125
and server_id in (10001,10002,10003)
and role_level>=10
--and role_id in (select role_id 
--from fairy_town.order_pay
--where day_time>=20210420 and day_time<=20220125
--and server_id in (10001,10002,10003))
group by 1 
 






实际领取人数

select recovery_count,count(distinct role_id)
from fairy_town_server.server_gem_recovery
where  day_time>=20220120 and day_time<=20220125
and server_id in (10001,10002,10003)
and recovery_count in (2,4,6,8,10)
and recovery_method='108'
group by 1



select role_level,count(distinct role_id) as uers
from 
(select role_id,role_level,row_number()over(partition by role_id order by log_time asc ) as row_num
from fairy_town.server_prop
where  day_time>=20220113 and day_time<=20220118
and server_id in (10001,10002,10003)
and role_id in (select role_id from 
fairy_town.server_role_create where  day_time>=20220113 and day_time<=20220118
and server_id in (10001,10002,10003))
and prop_id='127019'
and change_type='CONSUME'
) a 
where row_num=1
group by 1



首日使用瞬时化肥等级
(select role_id,role_level,row_number()over(partition by role_id order by log_time asc ) as row_num
from fairy_town.server_prop
where  day_time>=20220113 and day_time<=20220118
and server_id in (10001,10002,10003)
and role_id in (select role_id from 
fairy_town.server_role_create where  day_time>=20220113 and day_time<=20220118
and server_id in (10001,10002,10003))
and prop_id='127019'
and change_type='CONSUME'


新增用户的等级分布
select role_level,count(distinct role_id)
from 
(select role_id,max(role_level) as role_level
from fairy_town.server_role_upgrade
where  day_time>=20220113 and day_time<=20220118
and server_id in (10001,10002,10003)
and role_id in (select role_id from 
fairy_town.server_role_create where  day_time>=20220113 and day_time<=20220118
and server_id in (10001,10002,10003))
group by 1) a 
group by 1

 
select day_time,count(distinct t.role_id) as users,sum(nums) as nums 
from  
(select a.role_id from 
(select role_id
from fairy_town.server_role_login
where day_time>=20220113 and day_time<=20220118
and server_id in (10001,10002,10003)
and role_level>=10 
union 
select role_id
from fairy_town.server_role_upgrade
where day_time>=20220113 and day_time<=20220118
and server_id in (10001,10002,10003)
and role_level=10 
) a 
join 
(select role_id
from fairy_town.server_role_login
where day_time>=20220120 and day_time<=20220125
and server_id in (10001,10002,10003)
and role_level>=10 
union 
select role_id
from fairy_town.server_role_upgrade
where day_time>=20220120 and day_time<=20220125
and server_id in (10001,10002,10003)
and role_level=10 
) b 
on a.role_id=b.role_id
) t 
join 
(select day_time,role_id,sum(change_count) as nums 
from fairy_town.server_prop
where day_time>=20220113 and day_time<=20220125
and server_id in (10001,10002,10003)
and prop_id='127019'
and change_type='CONSUME'
group by 1,2) l 
on t.role_id=l.role_id
group by 1

钻石消耗
select day_time,count(distinct t.role_id) as users,sum(nums) as nums 
from  
(select a.role_id from 
(select role_id
from fairy_town.server_role_login
where day_time>=20220113 and day_time<=20220118
and server_id in (10001,10002,10003)
and role_level>=10 
union 
select role_id
from fairy_town.server_role_upgrade
where day_time>=20220113 and day_time<=20220118
and server_id in (10001,10002,10003)
and role_level=10 
) a 
join 
(select role_id
from fairy_town.server_role_login
where day_time>=20220120 and day_time<=20220125
and server_id in (10001,10002,10003)
and role_level>=10 
union 
select role_id
from fairy_town.server_role_upgrade
where day_time>=20220120 and day_time<=20220125
and server_id in (10001,10002,10003)
and role_level=10 
) b 
on a.role_id=b.role_id
) t 
join 
(select day_time,role_id,sum(consume_count) as nums 
from fairy_town_server.server_gem_consume
where day_time>=20220113 and day_time<=20220125
and server_id in (10001,10002,10003)
and consume_method='47'
group by 1,2) l 
on t.role_id=l.role_id
group by 1


留存

select channel_id,media_source,level_dt,role_level,datediff(login_dt,level_dt) as datediffs,count(distinct c.role_id)
from
(select channel_id,role_id,
	case when media_source is null then 'Organic'
         else media_source end as media_source,
         role_level,level_dt
 from 
(select channel_id,role_id,device_id,role_level,to_date(cast(date_time as timestamp)) as level_dt
from fairy_town.server_role_upgrade
where day_time>=20220105 and day_time<=20220125
and server_id in (10001,10002,10003)
and role_level in (10,11,12,13,14,15) 
group by 1,2,3,4,5
) a 
left outer join 
(select customer_user_id,  --设备ID
case when media_source in ('Facebook Ads','restricted') then 'FB'
     when media_source = 'googleadwords_int'            then 'GG'
     when media_source = 'applovin_int'                 then 'Applovin'
     when media_source = 'ironsource_int'               then 'IronSource'
     else  'others'
     end  as media_source                                        
from fairy_town.af_push
group by 1,2) b
on device_id=customer_user_id
) c 
left join 
(select role_id,to_date(cast(date_time as timestamp)) as login_dt
from fairy_town.server_role_login
where day_time>=20220105  and day_time<=20220126
and server_id in (10001,10002,10003)
group by 1,2
) d 
on c.role_id=d.role_id and login_dt>=level_dt
where datediff(login_dt,level_dt) <=1
group by 1,2,3,4,5