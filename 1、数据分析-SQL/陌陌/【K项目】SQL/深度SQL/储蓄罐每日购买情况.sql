select l1.day_time as '日期',
case when l1.commodity_id ='com.managames.fairytown.iap_2.99e' then '体力'
     when l1.commodity_id ='com.managames.fairytown.iap_2.99p' then '宝石'
end as '储蓄罐类型',     
case when l2.commodity_id is not null then 触发人数 else 0 end as 触发人数
,
case when l3.commodity_id is not null then 购买人数 else 0 end as 购买人数
from 
(select day_time,commodity_id from 
((select  day_time, commodity_id,count(distinct role_id) as '触发人数'
from fairy_town_server.server_piggy_bank_begin
where   day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by 1,2)  
union all
(select  day_time,game_product_id as commodity_id,count(role_id) as '购买人数'
from fairy_town.order_pay
where   day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and product_name in ('体力储蓄罐','宝石储蓄罐')
group by 1,2)) a  
group by 1,2) l1 
left join 
(select  day_time, commodity_id,count(distinct role_id) as '触发人数'
from fairy_town_server.server_piggy_bank_begin
where   day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by 1,2) l2 
on l1.day_time=l2.day_time and l1.commodity_id=l2.commodity_id
left join 
(select  day_time,game_product_id as commodity_id,count(role_id) as '购买人数'
from fairy_town.order_pay
where   day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and product_name in ('体力储蓄罐','宝石储蓄罐')
group by 1,2) l3
on l1.day_time=l3.day_time and l1.commodity_id=l3.commodity_id
order by 1,2