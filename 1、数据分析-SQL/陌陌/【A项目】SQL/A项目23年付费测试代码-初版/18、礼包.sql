每日特惠礼包
领取免费人数	购买礼包A	购买礼包B	购买礼包C	购买ABC
select 付费档位,count(distinct b.role_id) as '领取免费人数',
               count(distinct case when product_name = 'A' then c.role_id else null end) as '购买礼包A',
               count(distinct case when product_name = 'B' then c.role_id else null end) as '购买礼包B',
               count(distinct case when product_name = 'C' then c.role_id else null end) as '购买礼包C',
               count(distinct case when product_name = 'ABC' then c.role_id else null end) as '购买ABC'
from

(select role_id,
       case when sum_pay = 0 then '零氪'
            when sum_pay > 0 and sum_pay <= 78 then '小R'
            when sum_pay > 78 and sum_pay <= 628 then '中R'
            when sum_pay > 628 and sum_pay <= 972 then '大R'
            else '超R'
            end as '付费档位'
from
(select role_id,sum(pay_price) as sum_pay
from myth.order_pay
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and country not in ('CN','HK')
group by 1
) a1
group by 1,2
) as a

left join
(select role_id --每日特惠免费领取人数
from myth.server_currency
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
and change_method = 'PRODUCE'
and currency_id = 3 -- 每日特惠免费获得钻石
group by 1
) as b
on a.role_id = b.role_id

left join
(select role_id,product_name
from myth.order_pay
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and country not in ('CN','HK')
and product_name in ('A','B','C','ABC') --需要找策划要每日礼包名称
group by 1,2
) as c
on a.role_id = c.role_id
group by 1 order by 1



次日复购率	三日复购率
select product_name 
      ,round(count(distinct case when 是否2天内复购=1 then role_id else null end)/count(distinct role_id),2) as '2日内复购率'
      ,round(count(distinct case when 是否3天内复购=1 then role_id else null end)/count(distinct role_id),2) as '3日内复购率'
from 

(select a.role_id,a.product_name,
        case when (unix_timestamp(b.date_time)-unix_timestamp(a.date_time))/(24*60*60)<=2 then 1 else 0 end as '是否2天内复购',
        case when (unix_timestamp(b.date_time)-unix_timestamp(a.date_time))/(24*60*60)<=3 then 1 else 0 end as '是否3天内复购'
from
(select role_id,product_name,date_time
from
(select role_id,product_name,date_time,row_number()over(partition by role_id order by log_time asc) as num
from myth.order_pay
where day_time between ${beginDate} and ${endDate} 
and server_id in (20001,20002)
and channel_id=1000  --Android
and country not in ('CN','HK')
and product_name in ('A','B','C','ABC') --需要找策划要每日礼包名称
) as a1
where num = 1
group by 1,2,3
) as a   

left join
(select role_id,product_name,date_time 
from myth.order_pay
where day_time between ${beginDate} and ${endDate2} 
and server_id in (20001,20002)
and channel_id=1000  --Android
and country not in ('CN','HK')
and product_name in ('A','B','C','ABC') --需要找策划要每日礼包名称
group by 1,2,3
) as b 
on a.role_id = b.role_id and a.product_name = b.product_name and a.date_time <= b.date_time
group by 1,2,3,4
) as a
group by 1






新手礼包
购买礼包A	购买礼包B	购买礼包C	购买礼包D	购买礼包E	购买礼包F	购买ABCDEF
select 付费档位,count(distinct case when 是否购买A = 1 then c.role_id else null end) as '购买礼包A',
               count(distinct case when 是否购买B = 1 then c.role_id else null end) as '购买礼包B',
               count(distinct case when 是否购买C = 1 then c.role_id else null end) as '购买礼包C',
               count(distinct case when 是否购买D = 1 then c.role_id else null end) as '购买礼包D',
               count(distinct case when 是否购买E = 1 then c.role_id else null end) as '购买礼包E',
               count(distinct case when 是否购买F = 1 then c.role_id else null end) as '购买礼包F',
               count(distinct case when 是否购买A = 1 and 是否购买B = 1 and 是否购买C = 1 and 是否购买D = 1 and 是否购买E = 1 and 是否购买F = 1 then c.role_id else null end) as '购买礼包ABCDEF'
from

(select role_id,
       case when sum_pay = 0 then '零氪'
            when sum_pay > 0 and sum_pay <= 78 then '小R'
            when sum_pay > 78 and sum_pay <= 628 then '中R'
            when sum_pay > 628 and sum_pay <= 972 then '大R'
            else '超R'
            end as '付费档位'
from
(select role_id,sum(pay_price) as sum_pay
from myth.order_pay
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and country not in ('CN','HK')
group by 1
) a1
group by 1,2
) as a

left join
(select role_id,case when product_name = 'A' then 1 else 0 end as '是否购买A',
	            case when product_name = 'B' then 1 else 0 end as '是否购买B',
	            case when product_name = 'C' then 1 else 0 end as '是否购买C',
	            case when product_name = 'D' then 1 else 0 end as '是否购买D',
	            case when product_name = 'E' then 1 else 0 end as '是否购买E',
	            case when product_name = 'F' then 1 else 0 end as '是否购买F'
from myth.order_pay
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and country not in ('CN','HK')
and product_name in ('A','B','C','D','E','F') --需要找策划要礼包名称
group by 1,2,3,4,5,6,7
) as c
on a.role_id = c.role_id
group by 1 order by 1



次日复购率	三日复购率
select product_name 
      ,round(count(distinct case when 是否2天内复购=1 then role_id else null end)/count(distinct role_id),2) as '2日内复购率'
      ,round(count(distinct case when 是否3天内复购=1 then role_id else null end)/count(distinct role_id),2) as '3日内复购率'
from 

(select a.role_id,a.product_name,
        case when (unix_timestamp(b.date_time)-unix_timestamp(a.date_time))/(24*60*60)<=2 then 1 else 0 end as '是否2天内复购',
        case when (unix_timestamp(b.date_time)-unix_timestamp(a.date_time))/(24*60*60)<=3 then 1 else 0 end as '是否3天内复购'
from
(select role_id,product_name,date_time
from
(select role_id,product_name,date_time,row_number()over(partition by role_id order by log_time asc) as num
from myth.order_pay
where day_time between ${beginDate} and ${endDate} 
and server_id in (20001,20002)
and channel_id=1000  --Android
and country not in ('CN','HK')
and product_name in ('A','B','C','ABC') --需要找策划要每日礼包名称
) as a1
where num = 1
group by 1,2,3
) as a   

left join
(select role_id,product_name,date_time 
from myth.order_pay
where day_time between ${beginDate} and ${endDate2} 
and server_id in (20001,20002)
and channel_id=1000  --Android
and country not in ('CN','HK')
and product_name in ('A','B','C','D','E','F') --需要找策划要礼包名称
group by 1,2,3
) as b 
on a.role_id = b.role_id and a.product_name = b.product_name and a.date_time <= b.date_time
group by 1,2,3,4
) as a
group by 1