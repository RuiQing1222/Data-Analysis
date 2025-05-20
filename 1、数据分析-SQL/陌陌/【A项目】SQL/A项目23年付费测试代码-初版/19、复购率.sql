复购率
首次购买道具  购买人数  7日内复购率  7日付费用户LTV

select product_name 
      ,count(distinct role_id) as '首次购买人数'
      ,round(count(distinct case when 是否7天内复购=1 then role_id else null end)/count(distinct role_id),2) as '7日内复购率'
      ,round(sum(case when 天数 <= 7 then pay_price else 0 end) / count(distinct case when 天数 <= 7 then role_id else null end),2) as '7日付费用户LTV'
from 

(select a.role_id,a.product_name,pay_price,
        unix_timestamp(b.date_time)-unix_timestamp(a.date_time) / (24*60*60) as '天数',
        case when (unix_timestamp(b.date_time)-unix_timestamp(a.date_time))/(24*60*60)<=7 then 1 else 0 end as '是否7天内复购'
from
(select role_id,product_name,date_time
from
(select role_id,product_name,date_time,row_number()over(partition by role_id order by log_time asc) as num
from myth.order_pay
where day_time between ${beginDate} and ${endDate} 
and server_id in (20001,20002)
and channel_id=1000  --Android
and country not in ('CN','HK')
) as a1
where num = 1
group by 1,2,3
) as a   

left join
(select role_id,product_name,date_time,pay_price 
from myth.order_pay
where day_time between ${beginDate} and ${endDate2} 
and server_id in (20001,20002)
and channel_id=1000  --Android
and country not in ('CN','HK')
group by 1,2,3,4
) as b 
on a.role_id = b.role_id and a.product_name = b.product_name and a.date_time <= b.date_time
group by 1,2,3,4,5
) as a
group by 1