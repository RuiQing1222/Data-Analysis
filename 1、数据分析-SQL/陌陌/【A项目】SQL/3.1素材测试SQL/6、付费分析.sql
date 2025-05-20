D30内付费用户购买类型分类


select a.role_id,birth_dt,country,
sum(case when datediff(pay_dt,birth_dt)<=29 then pay_price else 0 end) as pay_30,
group_concat(distinct case when row_num=1 then game_product_id else null end) as '首次付费道具',
group_concat(distinct case when row_num=2 then game_product_id else null end) as '二次付费道具',
group_concat(distinct case when row_num=3 then game_product_id else null end) as '三次付费道具',
group_concat(distinct case when row_num=4 then game_product_id else null end) as '四次付费道具',
group_concat(distinct case when row_num=5 then game_product_id else null end) as '五次付费道具'
from 
(  --新增
select role_id,birth_dt,country
from
(select role_id,device_id,to_date(date_time) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(date_time) as device_birth_dt, 
     case when country in ('PH','MY') then 'PH+MY'
     when country in ('GB','IE','CA')  then 'GB+CA'
     end as country
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
) as a

left join

(
select role_id,to_date(date_time) as pay_dt,pay_price,game_product_id,row_number()over(partition by role_id order by log_time asc) as row_num
from myth.order_pay
where  day_time>=${beginDate} and day_time<=${EndDate}
and country not in ('CN','HK')
) b 
on a.role_id = b.role_id
where datediff(pay_dt,birth_dt)<=29 
and row_num in (1,2,3,4,5)
group by 1,2,3



select a.role_id,birth_dt,country,
sum( case when datediff(pay_dt,birth_dt)=0 then pay else 0 end) as '首日付费金额',
sum( case when datediff(pay_dt,birth_dt)=1 then pay else 0 end) as '二日付费金额',
sum( case when datediff(pay_dt,birth_dt)=2 then pay else 0 end) as '三日付费金额',
sum( case when datediff(pay_dt,birth_dt)=3 then pay else 0 end) as '四日付费金额',
sum( case when datediff(pay_dt,birth_dt)=4 then pay else 0 end) as '五日付费金额',
sum( case when datediff(pay_dt,birth_dt)=5 then pay else 0 end) as '六日付费金额',
sum( case when datediff(pay_dt,birth_dt)=6 then pay else 0 end) as '七日付费金额',
sum( case when datediff(pay_dt,birth_dt)>=7  and datediff(pay_dt,birth_dt)<=13 then pay else 0 end) as '八至十四日付费金额',
sum( case when datediff(pay_dt,birth_dt)>=14 and datediff(pay_dt,birth_dt)<=29 then pay else 0 end) as '十五日至三十付费金额'
from 
(  --新增
select role_id,birth_dt,country
from
(select role_id,device_id,to_date(date_time) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(date_time) as device_birth_dt, 
     case when country in ('PH','MY') then 'PH+MY'
     when country in ('GB','IE','CA')  then 'GB+CA'
     end as country
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
) as a

left join

(
select role_id,to_date(date_time) as pay_dt,sum(pay_price) pay 
from myth.order_pay
where  day_time>=${beginDate} and day_time<=${EndDate}
and country not in ('CN','HK')
group by 1,2 ) b 
on a.role_id =b.role_id
where b.role_id is not null 
group by 1,2,3



副本人数
select a.role_id,birth_dt,country,
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
(  --新增
select role_id,birth_dt,country
from
(select role_id,device_id,to_date(date_time) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(date_time) as device_birth_dt, 
     case when country in ('PH','MY') then 'PH+MY'
     when country in ('GB','IE','CA')  then 'GB+CA'
     end as country
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
) as a

left join

-- (
-- select role_id,to_date(date_time) as pay_dt,game_product_id,sum(pay_price) as pay 
-- from myth.order_pay
-- where  day_time>=${beginDate} and day_time<=${EndDate}
-- and country not in ('CN','HK')
-- group by 1,2,3 ) b 
-- on a.role_id =b.role_id

-- (select role_id,to_date(date_time) as done_dt
-- from myth_server.server_enter_dungeon
-- where day_time>=${beginDate} and day_time<=${payDate}
-- and channel_id=1000  --Android
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- group by 1,2) c 
-- on a.role_id=c.role_id


(select role_id,to_date(date_time) as done_dt
from myth.client_online
where day_time>=${beginDate} and day_time<=${payDate}
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2) c 
on a.role_id=c.role_id

where datediff(done_dt,birth_dt)<=29 
group by 1,2,3


货币存量
select a.role_id,birth_dt,country,
--game_product_id,sum(pay) as pay 
sum( case when datediff(done_dt,birth_dt) =0  and change_type='PRODUCE' then change_count else 0 end) as '首日钻石获得',
sum( case when datediff(done_dt,birth_dt) =0  and change_type='CONSUME' then change_count else 0 end) as '首日钻石消耗',
sum( case when datediff(done_dt,birth_dt)<=1  and change_type='PRODUCE' then change_count else 0 end) as '二日钻石获得',
sum( case when datediff(done_dt,birth_dt)<=1  and change_type='CONSUME' then change_count else 0 end) as '二日钻石消耗',
sum( case when datediff(done_dt,birth_dt)<=2  and change_type='PRODUCE' then change_count else 0 end) as '三日钻石获得',
sum( case when datediff(done_dt,birth_dt)<=2  and change_type='CONSUME' then change_count else 0 end) as '三日钻石消耗',
sum( case when datediff(done_dt,birth_dt)<=3  and change_type='PRODUCE' then change_count else 0 end) as '四日钻石获得',
sum( case when datediff(done_dt,birth_dt)<=3  and change_type='CONSUME' then change_count else 0 end) as '四日钻石消耗',
sum( case when datediff(done_dt,birth_dt)<=4  and change_type='PRODUCE' then change_count else 0 end) as '五日钻石获得',
sum( case when datediff(done_dt,birth_dt)<=4  and change_type='CONSUME' then change_count else 0 end) as '五日钻石消耗'
from 
(  --新增
select role_id,birth_dt,country
from
(select role_id,device_id,to_date(date_time) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(date_time) as device_birth_dt, 
     case when country in ('PH','MY') then 'PH+MY'
     when country in ('GB','IE','CA')  then 'GB+CA'
     end as country
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
) as a

left join

-- (
-- select role_id,to_date(date_time) as pay_dt,game_product_id,sum(pay_price) as pay 
-- from myth.order_pay
-- where  day_time>=${beginDate} and day_time<=${EndDate}
-- and country not in ('CN','HK')
-- group by 1,2,3 ) b 
-- on a.role_id =b.role_id

(select role_id,to_date(date_time) as done_dt,change_type,sum(change_count) as change_count
from myth.server_currency
where day_time>=${beginDate} and day_time<=${payDate}
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and currency_id = '3'
group by 1,2,3) c 
on a.role_id=c.role_id

where datediff(done_dt,birth_dt)<=29 
group by 1,2,3




select a.role_id,change_method,
--currency_id,
prop_id,
sum(case when datediff(pay_dt,birth_dt)<=29 then change_count else 0 end ) as counts 
from 
(  --新增
select role_id,birth_dt,country
from
(select role_id,device_id,to_date(date_time) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(date_time) as device_birth_dt, 
     case when country in ('PH','MY') then 'PH+MY'
     when country in ('GB','IE','CA')  then 'GB+CA'
     end as country
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
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
     end as change_method,
     sum(change_count) as change_count
from  myth.server_prop
where day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and change_type='PRODUCE'
and change_method in ('119','123','118','85')
group by 1,2,3,4

) b 
on a.role_id=b.role_id
where datediff(pay_dt,birth_dt)<=29
group by 1,2,3




D30 前五次付费的战役关卡分布

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
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(date_time) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
group by 1,2
)  a
left join
(select pay_dt,pay_time,role_id,row_num1
from 
(select to_date(date_time) as pay_dt,log_time as pay_time,role_id,row_number()over(partition by role_id order by log_time  asc ) as row_num1
from myth.order_pay
where day_time>= ${beginDate}  and day_time<=${endDate}
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and country not in ('CN','HK')
) b1 
where row_num1 <= 5 
) b
on a.role_id = b.role_id 
where datediff(pay_dt,birth_dt)<=${lifeTime}
) a 
left join 
(select log_time as dungeon_time,dungeon_id,role_id 
from myth_server.server_dungeon_end
where day_time>= ${beginDate}  and day_time<=${endDate}
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
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




 D30分VIP

select vip,
--birth_dt,
change_method,sum(currency_count) as counts,count(distinct a.role_id) as users,sum(nums) as nums 
from 
(select birth_dt,role_id,
case when total_pay>0     and total_pay<=13    then 1
     when total_pay>13    and total_pay<=105   then 2 
     when total_pay>105   and total_pay<=277   then 3
     when total_pay>277                        then 4 
     else 0 
     end as vip    
from 
(select birth_dt,a.role_id
,sum(case when datediff(vip_dt,birth_dt)<=${lifeTime}  then pay else 0 end ) as 'total_pay'
from
(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(date_time) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(date_time) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
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
end as currency_id,change_method,to_date(date_time) as currency_dt,count(1) as nums,sum(change_count) as currency_count
from myth.server_currency
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id=1000  --Android
and server_id in (${serverIds}) 
and version_name ='1.4.0'
and country not in ('CN','HK')
and currency_id ='3' --in ('8','3')
and change_type='CONSUME'
group by 1,2,3,4
) d 
on a.role_id=d.role_id
where datediff(currency_dt,birth_dt)<=${lifeTime}
group by 1,2