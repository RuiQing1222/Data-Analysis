D7内付费用户购买类型分类

=if(D2<=8,"档位1",if(D2<=70,"档位2","档位3"))
=IFERROR(LEFT(A2,MATCH(TRUE,ISNUMBER(--MID(A2,ROW($1:$999),1)),0)-1),A2)
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
前五次道具购买     
select a.role_id,birth_dt,country,
sum(case when datediff(pay_dt,birth_dt)<${lifeTime} then pay_price else 0 end) as pay_${lifeTime},
group_concat(distinct case when row_num=1 and datediff(pay_dt,birth_dt)< ${lifeTime} then game_product_id else null end) as '首次付费道具',
group_concat(distinct case when row_num=1 and datediff(pay_dt,birth_dt)< ${lifeTime} then product_name    else null end) as '首次付费道具名称',
group_concat(distinct case when row_num=2 and datediff(pay_dt,birth_dt)< ${lifeTime} then game_product_id else null end) as '二次付费道具',
group_concat(distinct case when row_num=2 and datediff(pay_dt,birth_dt)< ${lifeTime} then product_name    else null end) as '二次付费道具名称',
group_concat(distinct case when row_num=3 and datediff(pay_dt,birth_dt)< ${lifeTime} then game_product_id else null end) as '三次付费道具',
group_concat(distinct case when row_num=3 and datediff(pay_dt,birth_dt)< ${lifeTime} then product_name    else null end) as '三次付费道具名称',
group_concat(distinct case when row_num=4 and datediff(pay_dt,birth_dt)< ${lifeTime} then game_product_id else null end) as '四次付费道具',
group_concat(distinct case when row_num=4 and datediff(pay_dt,birth_dt)< ${lifeTime} then product_name    else null end) as '四次付费道具名称',
group_concat(distinct case when row_num=5 and datediff(pay_dt,birth_dt)< ${lifeTime} then game_product_id else null end) as '五次付费道具',
group_concat(distinct case when row_num=5 and datediff(pay_dt,birth_dt)< ${lifeTime} then product_name    else null end) as '五次付费道具名称'
from 
(  --新增
select role_id,birth_dt,country
from
(select role_id,device_id,to_date(date_time) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name = '1.5.0'
and country not in ('CN','HK')   
) as a1
right join
(select device_id,to_date(date_time) as device_birth_dt,country
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name = '1.5.0'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id --and a1.birth_dt = a2.device_birth_dt
) as a

left join
(
select role_id,to_date(date_time) as pay_dt,pay_price,game_product_id,product_name,row_number()over(partition by role_id order by log_time asc) as row_num
from myth.order_pay
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
) b 
on a.role_id = b.role_id
where datediff(pay_dt,birth_dt)< ${lifeTime}
group by 1,2,3





D7 前五次付费的战役关卡分布

select row_num1,dungeon_id,role_id from 
(select pay_dt,row_num1,duration,dungeon_id,role_id,row_number()over(partition by role_id,row_num1 order by duration asc ) as row_num2
from 
(select pay_dt,row_num1,pay_time-dungeon_time as duration,dungeon_id,a.role_id
from 
(select a.role_id,pay_dt,pay_time,row_num1
     from 
(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(date_time) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id in (1000,2000)
and version_name = '1.5.0'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(date_time) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id in (1000,2000)
and version_name = '1.5.0'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id --and a1.birth_dt = a2.device_birth_dt
group by 1,2
)  a
left join
(select pay_dt,pay_time,role_id,row_num1
from 
(select to_date(date_time) as pay_dt,log_time as pay_time,role_id,row_number()over(partition by role_id order by log_time  asc ) as row_num1
from myth.order_pay
where day_time>= ${beginDate}  and day_time<=${endDate}
and server_id in (${serverIds}) 
and channel_id in (1000,2000)
and country not in ('CN','HK')
) b1 
where row_num1 <= 5 
) b
on a.role_id = b.role_id 
where datediff(pay_dt,birth_dt)< ${lifeTime}
) a 
left join 
(select log_time as dungeon_time,dungeon_id,role_id 
from myth_server.server_dungeon_end
where day_time>= ${beginDate}  and day_time<=${endDate}
and server_id in (${serverIds}) 
and channel_id in (1000,2000)
and version_name = '1.5.0'
and country not in ('CN','HK')
and game_type= 3 
and battle_result = 1
) b 
on a.role_id = b.role_id
where dungeon_time<pay_time
) a 
) t 
where row_num2 = 1 
 group by 1,2,3


D7 前五次付费的等级分布

select row_num1,role_level,role_id from 
(select pay_dt,row_num1,duration,dungeon_id,role_id,role_level,row_number()over(partition by role_id,row_num1 order by duration asc ) as row_num2
from 
(select pay_dt,row_num1,pay_time-dungeon_time as duration,dungeon_id,a.role_id,role_level
from 
(select a.role_id,pay_dt,pay_time,row_num1
     from 
(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(date_time) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id in (1000,2000)
and version_name = '1.5.0'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(date_time) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id in (1000,2000)
and version_name = '1.5.0'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id --and a1.birth_dt = a2.device_birth_dt
group by 1,2
)  a
left join
(select pay_dt,pay_time,role_id,row_num1
from 
(select to_date(date_time) as pay_dt,log_time as pay_time,role_id,row_number()over(partition by role_id order by log_time  asc ) as row_num1
from myth.order_pay
where day_time>= ${beginDate}  and day_time<=${endDate}
and server_id in (${serverIds}) 
and channel_id in (1000,2000)
and country not in ('CN','HK')
) b1 
where row_num1 <= 5 
) b
on a.role_id = b.role_id 
where datediff(pay_dt,birth_dt)< ${lifeTime}
) a 
left join 
(select log_time as dungeon_time,dungeon_id,role_id,role_level
from myth_server.server_dungeon_end
where day_time>= ${beginDate}  and day_time<=${endDate}
and server_id in (${serverIds}) 
and channel_id in (1000,2000)
and version_name = '1.5.0'
and country not in ('CN','HK')
and game_type= 3 
and battle_result = 1
) b 
on a.role_id = b.role_id
where dungeon_time<pay_time
) a 
) t 
where row_num2 = 1 
 group by 1,2,3





七日内所有物品


select datediff(pay_dt,birth_dt),a.role_id,game_product_id,product_name
,sum(nums) as nums
,sum(pay) as pay
from 
-- (select birth_dt,role_id,
-- case when total_pay>0  and total_pay<=8   then 1
--      when total_pay>8  and total_pay<=70  then 2
--      when total_pay>70                    then 3 
--      else 0 
--      end as vip --D7 
-- from 
-- (select birth_dt,a.role_id
-- ,sum(case when datediff(vip_dt,birth_dt)< ${lifeTime}  then pay else 0 end ) as 'total_pay'
-- from

(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(date_time) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id in (1000,2000)
and version_name  ='1.4.7'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(date_time) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id in (1000,2000)
and version_name  ='1.4.7'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id   --and a1.birth_dt = a2.device_birth_dt
group by 1,2
)  a
-- left join
-- (
-- select role_id,to_date(date_time) as vip_dt,sum(pay_price) pay 
-- from myth.order_pay
-- where  day_time>=${beginDate} and day_time<=${endDate}
-- and country not in ('CN','HK')
-- group by 1,2 ) b 
-- on a.role_id =b.role_id
-- where b.role_id  is not null 
-- group by 1,2
-- ) a1 
-- ) a 

left join

(
select role_id,to_date(date_time) as pay_dt,game_product_id,product_name,count(1) as nums,sum(pay_price) pay 
from myth.order_pay
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
group by 1,2,3,4 ) c 
on a.role_id = c.role_id 
where c.role_id is not null 
-- and vip>0
and datediff(pay_dt,birth_dt)< ${lifeTime}
group by 1,2,3,4



观察每日情况


在线/副本/付费人数/历史付费人数

select vip,
count(distinct 首日副本人数) as 首日,
count(distinct 二日副本人数) as 二日,
count(distinct 三日副本人数) as 三日,
count(distinct 四日副本人数) as 四日,
count(distinct 五日副本人数) as 五日,
count(distinct 六日副本人数) as 六日,
count(distinct 七日副本人数) as 七日,
count(distinct 八至十四日副本人数) as 八至十四日,
count(distinct 十五至三十日副本人数) as 十五至三十日
from 
(select a.role_id,birth_dt,vip,
--game_product_id,sum(pay) as pay 
group_concat(distinct case when datediff(done_dt,birth_dt)=0  then a.role_id else null end) as '首日副本人数',
group_concat(distinct case when datediff(done_dt,birth_dt)=1  then a.role_id else null end) as '二日副本人数',
group_concat(distinct case when datediff(done_dt,birth_dt)=2  then a.role_id else null end) as '三日副本人数',
group_concat(distinct case when datediff(done_dt,birth_dt)=3  then a.role_id else null end) as '四日副本人数',
group_concat(distinct case when datediff(done_dt,birth_dt)=4  then a.role_id else null end) as '五日副本人数',
group_concat(distinct case when datediff(done_dt,birth_dt)=5  then a.role_id else null end) as '六日副本人数',
group_concat(distinct case when datediff(done_dt,birth_dt)=6  then a.role_id else null end) as '七日副本人数',
group_concat(distinct case when datediff(done_dt,birth_dt)>=7 and datediff(done_dt,birth_dt)<=13   then a.role_id else null end) as '八至十四日副本人数',
group_concat(distinct case when datediff(done_dt,birth_dt)>=14 and datediff(done_dt,birth_dt)<=29  then a.role_id else null end) as '十五至三十日副本人数'
from 
(select birth_dt,role_id,
case when total_pay>0  and total_pay<=8   then 1
     when total_pay>8  and total_pay<=10  then 2
     when total_pay>10                    then 3 
     else 0 
     end as vip --D3
from 
(select birth_dt,a.role_id
,sum(case when datediff(vip_dt,birth_dt)< ${lifeTime}  then pay else 0 end ) as 'total_pay'
from

(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(date_time) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id in (1000,2000)
and version_name = '1.5.0'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(date_time) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id in (1000,2000)
and version_name = '1.5.0'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id   --and a1.birth_dt = a2.device_birth_dt
group by 1,2
)  a
left join
(
select role_id,to_date(date_time) as vip_dt,sum(pay_price) pay 
from myth.order_pay
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
group by 1,2 ) b 
on a.role_id =b.role_id
where b.role_id  is not null 
group by 1,2
) a1 
) a 

left join

--付费人数
-- (
-- select role_id,to_date(date_time) as done_dt,game_product_id,sum(pay_price) as pay 
-- from myth.order_pay
-- where  day_time>=${beginDate} and day_time<=${endDate}
-- and country not in ('CN','HK')
-- group by 1,2,3 ) c 

--副本人数
-- (select role_id,to_date(date_time) as done_dt
-- from myth_server.server_enter_dungeon
-- where day_time>=${beginDate} and day_time<=${endDate}
-- and channel_id in (1000,2000)
-- and version_name = '1.5.0'
-- and country not in ('CN','HK')
-- group by 1,2) c 

--活跃人数
-- (select role_id,to_date(date_time) as done_dt
-- from myth.client_online
-- where day_time>=${beginDate} and day_time<=${endDate}
-- and channel_id in (1000,2000)
-- and version_name = '1.5.0'
-- and country not in ('CN','HK')
-- group by 1,2) c 

--历史付费人数
-- (select done_dt,a.role_id from 
-- (select role_id,min(to_date(date_time)) as min_pay_dt
-- from myth.order_pay
-- where  day_time>=${beginDate} and day_time<=${endDate}
-- and country not in ('CN','HK')
-- group by 1 )  a 
-- left join 
-- (select role_id,to_date(date_time) as done_dt
-- from myth.client_online
-- where day_time>=${beginDate} and day_time<=${endDate}
-- and channel_id in (1000,2000)
-- and version_name = '1.5.0'
-- and country not in ('CN','HK')
-- group by 1,2) c 
-- on a.role_id = c.role_id
-- where c.done_dt>=min_pay_dt
-- ) c   

on a.role_id=c.role_id
where datediff(done_dt,birth_dt)<${lifeTime} 
group by 1,2,3) t
where vip>0
group by 1


每日付费总金额

select vip,
sum( case when datediff(pay_dt,birth_dt)=0 then pay else 0 end) as '首日付费金额',
sum( case when datediff(pay_dt,birth_dt)=1 then pay else 0 end) as '二日付费金额',
sum( case when datediff(pay_dt,birth_dt)=2 then pay else 0 end) as '三日付费金额',
sum( case when datediff(pay_dt,birth_dt)=3 then pay else 0 end) as '四日付费金额',
sum( case when datediff(pay_dt,birth_dt)=4 then pay else 0 end) as '五日付费金额',
sum( case when datediff(pay_dt,birth_dt)=5 then pay else 0 end) as '六日付费金额',
sum( case when datediff(pay_dt,birth_dt)=6 then pay else 0 end) as '七日付费金额',
-- sum( case when datediff(pay_dt,birth_dt)>=7  and datediff(pay_dt,birth_dt)<=13 then pay else 0 end) as '八至十四日付费金额',
-- sum( case when datediff(pay_dt,birth_dt)>=14 and datediff(pay_dt,birth_dt)<=29 then pay else 0 end) as '十五日至三十付费金额'
from 
(select birth_dt,role_id,
case when total_pay>0  and total_pay<=8   then 1
     when total_pay>8  and total_pay<=10  then 2
     when total_pay>10                    then 3 
     else 0 
     end as vip --D3
from 
(select birth_dt,a.role_id
,sum(case when datediff(vip_dt,birth_dt)< ${lifeTime}  then pay else 0 end ) as 'total_pay'
from

(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(date_time) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id in (1000,2000)
and version_name = '1.5.0'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(date_time) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id in (1000,2000)
and version_name = '1.5.0'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id   --and a1.birth_dt = a2.device_birth_dt
group by 1,2
)  a
left join
(
select role_id,to_date(date_time) as vip_dt,sum(pay_price) pay 
from myth.order_pay
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
group by 1,2 ) b 
on a.role_id =b.role_id
where b.role_id  is not null 
group by 1,2
) a1 
) a 

left join

(
select role_id,to_date(date_time) as pay_dt,sum(pay_price) pay 
from myth.order_pay
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
group by 1,2 ) c 
on a.role_id = c.role_id 
where c.role_id is not null 
and vip>0
group by 1







-- 货币存量
-- select a.role_id,birth_dt,country,
-- --game_product_id,sum(pay) as pay 
-- sum( case when datediff(done_dt,birth_dt) =0  and change_type='PRODUCE' then change_count else 0 end) as '首日钻石获得',
-- sum( case when datediff(done_dt,birth_dt) =0  and change_type='CONSUME' then change_count else 0 end) as '首日钻石消耗',
-- sum( case when datediff(done_dt,birth_dt)<=1  and change_type='PRODUCE' then change_count else 0 end) as '二日钻石获得',
-- sum( case when datediff(done_dt,birth_dt)<=1  and change_type='CONSUME' then change_count else 0 end) as '二日钻石消耗',
-- sum( case when datediff(done_dt,birth_dt)<=2  and change_type='PRODUCE' then change_count else 0 end) as '三日钻石获得',
-- sum( case when datediff(done_dt,birth_dt)<=2  and change_type='CONSUME' then change_count else 0 end) as '三日钻石消耗',
-- sum( case when datediff(done_dt,birth_dt)<=3  and change_type='PRODUCE' then change_count else 0 end) as '四日钻石获得',
-- sum( case when datediff(done_dt,birth_dt)<=3  and change_type='CONSUME' then change_count else 0 end) as '四日钻石消耗',
-- sum( case when datediff(done_dt,birth_dt)<=4  and change_type='PRODUCE' then change_count else 0 end) as '五日钻石获得',
-- sum( case when datediff(done_dt,birth_dt)<=4  and change_type='CONSUME' then change_count else 0 end) as '五日钻石消耗'
-- from 
-- (  --新增
-- select role_id,birth_dt,country
-- from
-- (select role_id,device_id,to_date(date_time) as birth_dt
-- from myth.server_role_create 
-- where day_time>=${beginDate} and day_time<=${birthEndDate} 
-- and server_id in (${serverIds}) 
-- and version_name = '1.4.3'
-- and country not in ('CN','HK')
-- ) as a1
-- right join
-- (select device_id,to_date(date_time) as device_birth_dt, 
--      case when country in ('PH','MY') then 'PH+MY'
--      when country in ('GB','IE','CA')  then 'GB+CA'
--      end as country
-- from myth.device_activate
-- where day_time>=${beginDate} and day_time<=${birthEndDate}
-- and version_name = '1.4.3'
-- and country not in ('CN','HK')
-- ) as a2 
-- on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
-- ) as a

-- left join

-- -- (
-- -- select role_id,to_date(date_time) as pay_dt,game_product_id,sum(pay_price) as pay 
-- -- from myth.order_pay
-- -- where  day_time>=${beginDate} and day_time<=${EndDate}
-- -- and country not in ('CN','HK')
-- -- group by 1,2,3 ) b 
-- -- on a.role_id =b.role_id

-- (select role_id,to_date(date_time) as done_dt,change_type,sum(change_count) as change_count
-- from myth.server_currency
-- where day_time>=${beginDate} and day_time<=${payDate}
-- and channel_id in (1000,2000)
-- and version_name = '1.4.3'
-- and country not in ('CN','HK')
-- and currency_id = '3'
-- group by 1,2,3) c 
-- on a.role_id=c.role_id

-- where datediff(done_dt,birth_dt)< ${lifeTime}
-- group by 1,2,3



产物计算用
购买礼包的产物追求情况


select vip,count(distinct a.role_id)
from 
(select birth_dt,role_id,
case when total_pay>0  and total_pay<=8   then 1
     when total_pay>8  and total_pay<=70  then 2
     when total_pay>70                    then 3 
     else 0 
     end as vip --D7 
from 
(select birth_dt,a.role_id
,sum(case when datediff(vip_dt,birth_dt)< ${lifeTime}  then pay else 0 end ) as 'total_pay'
from

(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(date_time) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id in (1000,2000)
and version_name = '1.4.3'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(date_time) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id in (1000,2000)
and version_name = '1.4.3'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id   --and a1.birth_dt = a2.device_birth_dt
group by 1,2
)  a
left join
(
select role_id,to_date(date_time) as vip_dt,sum(pay_price) pay 
from myth.order_pay
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
group by 1,2 ) b 
on a.role_id =b.role_id
where b.role_id  is not null 
group by 1,2
) a1 
) a 
left join 
(
select role_id,game_product_id,to_date(date_time) as done_dt
from myth.order_pay
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and game_product_id in (
'com.managames.myththor.iap_4.99kf',
'com.managames.myththor.iap_4.99kpsj_15',
'com.managames.myththor.iap_4.99y',
'com.managames.myththor.iap_19.99kf'

)  --对应产物的礼包
group by 1,2,3 
)  c 
on a.role_id = c.role_id 
where datediff(done_dt,birth_dt)< ${lifeTime} 
group by 1
order by 1 asc 



select a.role_id,change_method,
--currency_id,
prop_id,
sum(case when datediff(pay_dt,birth_dt)<${lifeTime} then change_count else 0 end ) as counts 
from 
(  --新增
select role_id,birth_dt,country
from
(select role_id,device_id,to_date(date_time) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name = '1.4.3'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(date_time) as device_birth_dt, 
     case when country in ('PH','MY') then 'PH+MY'
     when country in ('GB','IE','CA')  then 'GB+CA'
     end as country
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name = '1.4.3'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id --and a1.birth_dt = a2.device_birth_dt
) as a

left join
-- (
-- select role_id,to_date(date_time) as pay_dt,currency_id,
-- case when change_method = '119' then '月卡'
--      when change_method = '123' then '悬赏令'
--      when change_method in ('118','85')  then '基金'
--      end as change_method,
--      sum(change_count) as change_count
-- from  myth.server_currency
-- where day_time>=${beginDate} and day_time<=${endDate}
-- and country not in ('CN','HK')
-- and change_type='PRODUCE'
-- and change_method in ('119','123','118','85')
-- group by 1,2,3,4

-- ) b 
(
select role_id,to_date(date_time) as pay_dt,prop_id,
case when change_method = '119' then '月卡'
     when change_method = '123' then '悬赏令'
     when change_method in ('118','85')  then '基金'
     when change_method ='143'           then '补给礼包'
     end as change_method,
     sum(change_count) as change_count
from  myth.server_prop
where day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and change_type='PRODUCE'
and change_method in ('119','123','118','85','143')
group by 1,2,3,4

) b 
on a.role_id=b.role_id
where datediff(pay_dt,birth_dt)< ${lifeTime}
group by 1,2,3







 D7分VIP

select vip,
--birth_dt,
change_method,
min(min_count) as  '最低单价',
sum(currency_count) as '总消耗',
count(distinct a.role_id) as '消耗人数',
sum(nums) as '消耗次数'
from 
(select birth_dt,role_id,
case when total_pay>0    and total_pay<=8    then 1
     when total_pay>8     and total_pay<=10   then 2 
     when total_pay>70                        then 3
     end as vip   --D3 
from 
(select birth_dt,a.role_id
,sum(case when datediff(vip_dt,birth_dt)<${lifeTime}  then pay else 0 end ) as 'total_pay'
from
(  --新增
select role_id,birth_dt 
from
(select role_id,device_id,to_date(date_time) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id in (1000,2000)
and version_name = '1.5.0'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(date_time) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id in (1000,2000)
and version_name = '1.5.0'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id  --and a1.birth_dt = a2.device_birth_dt
group by 1,2
)  a
left join
(
select role_id,to_date(date_time) as vip_dt,sum(pay_price) pay 
from myth.order_pay
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
group by 1,2 ) b 
on a.role_id =b.role_id
group by 1,2
) a1 
) a 
left join 
(
select role_id,
--role_level as currency_level,
case currency_id
when '3' then '钻石'
when '8' then  '金币'
else '未知'
end as currency_id,change_method,to_date(date_time) as currency_dt,min(change_count) as min_count,count(1) as nums,sum(change_count) as currency_count
from myth.server_currency
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id in (1000,2000)
and server_id in (${serverIds}) 
and version_name ='1.4.7'
and country not in ('CN','HK')
and currency_id ='3' 
-- and currency_id ='8'
and change_type='CONSUME'
group by 1,2,3,4
) d 
on a.role_id=d.role_id
where datediff(currency_dt,birth_dt)<${lifeTime}
and vip>0
group by 1,2



后期付费

select vip,datediff(pay_dt,birth_dt)+1 as '天数',game_product_id,product_name,count(1) as item_nums
from 
(select birth_dt,role_id,
case when total_pay>0  and total_pay<=8   then 1
     when total_pay>8  and total_pay<=83  then 2
     when total_pay>83                    then 3 
     else 0 
     end as vip --D14
from 
(select birth_dt,a.role_id
,sum(case when datediff(vip_dt,birth_dt)< ${lifeTime}  then pay else 0 end ) as 'total_pay'
from

(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(date_time) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id in (1000,2000)
and version_name = '1.4.3'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(date_time) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id in (1000,2000)
and version_name = '1.4.3'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id   --and a1.birth_dt = a2.device_birth_dt
group by 1,2
)  a
left join
(
select role_id,to_date(date_time) as vip_dt,sum(pay_price) pay 
from myth.order_pay
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
group by 1,2 ) b 
on a.role_id =b.role_id
where b.role_id  is not null 
group by 1,2
) a1 
) a 

left join

(
select role_id,to_date(date_time) as pay_dt,game_product_id  ,product_name
from myth.order_pay
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
) c 
on a.role_id = c.role_id 
where c.role_id is not null 
and vip>1
group by 1,2,3,4



付费为起点+当期新增

select pay_dt,datediff(login_dt,pay_dt)+1 as '天数',count(distinct a.role_id)
from 
(select a.role_id,pay_dt
from 
(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(date_time) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id in (1000,2000)
and version_name = '1.5.0'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(date_time) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id in (1000,2000)
and version_name = '1.5.0'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id   --and a1.birth_dt = a2.device_birth_dt
group by 1,2
)  a
left join
(
select role_id,min(to_date(date_time)) as pay_dt
from myth.order_pay
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id in (1000,2000)
and country not in ('CN','HK')
group by 1 
) b  
on a.role_id = b.role_id 
where b.role_id is not null 
and datediff(pay_dt,birth_dt)<6
) a 
left join 
(
select role_id,to_date(date_time) as login_dt
from myth.server_role_login
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id in (1000,2000)
and version_name = '1.5.0'
and country not in ('CN','HK')
group by 1,2 
) c 
on a.role_id = c.role_id 
where login_dt>=pay_dt
group by 1,2 


























 -- 连续付费

-- select distinct  t1.role_id, to_date(date_time) as currency_dt,game_product_id,count(1) as nums
-- from myth.order_pay t1

-- join myth.order_pay t2 
 
-- on t1.role_id = t2.role_id and to_date(t1.date_time) = date_add(to_date(t2.date_time),1)
-- join myth.order_pay t3 

-- on t1.role_id = t3.role_id and to_date(t1.date_time) = date_add(to_date(t3.date_time),2)
-- where  t1.day_time>=${beginDate} and t1.day_time<=${endDate}
-- and   t2.day_time>=${beginDate} and t2.day_time<=${endDate}
-- and   t3.day_time>=${beginDate} and t3.day_time<=${endDate}
-- group by 1,2,3







