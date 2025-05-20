--------------------------------------------------------------------------------------------------------------------------------------------------------------------
命运殿堂
参与数据
-- 参与命运殿堂的玩家  消耗值大于0
select wish_mode,count(distinct role_id) as '参与人数',count(distinct log_time) as '参与次数'
from
(select role_id,log_time,wish_mode
from
(select role_id,log_time,wish_mode,consume_prop_num
from myth_server.server_wish_room
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) b1
where consume_prop_num > 0
group by 1,2,3
) as b
group by 1
order by 1

刷新数据
SELECT sys_type,count(distinct role_id) as '免费刷新人数'
FROM myth_server.server_click_believer
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and sys_type in (2,3,4) -- 免费刷新 2=命运殿堂白银 3=命运殿堂黄金 4=命运殿堂紫金
group by 1 order by 1




select wish_mode,count(distinct case when change_count >0 then b.role_id else NULL end) '钻石刷新人数&消耗钻石人数',
                 count(distinct case when change_count >0 then b.log_time else NULL end) '钻石刷新次数&消耗钻石次数'
from
(select role_id,log_time,wish_mode
from
(select role_id,log_time,wish_mode,consume_prop_num
from myth_server.server_wish_room
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) a1
where consume_prop_num > 0
group by 1,2,3
) as a

left join
(SELECT role_id,log_time,change_count 
FROM myth.server_currency
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and currency_id = '3'
AND change_type = 'CONSUME'
and change_method = '67' -- 刷新命运殿堂
group by 1,2,3
) as b
on a.role_id = b.role_id
group by 1 order by 1



天复玩率
select wish_mode,round(count(distinct case when play_not = 'yes' then role_id else NULL end) / count(distinct role_id),2) as '复玩率'
from

(select b.wish_mode,b.role_id,case when c.role_id is null then 'no'
                 else 'yes'
                 end as play_not
from
( -- 参与信徒心愿的玩家  消耗心愿值大于0
select wish_mode,role_id,done_dt
from
(select wish_mode,role_id,to_date(cast(date_time as timestamp)) as done_dt,consume_prop_num
from myth_server.server_wish_room
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) b1
where consume_prop_num > 0
group by 1,2,3
) b

left join
( -- 参与信徒心愿的玩家  消耗心愿值大于0
select wish_mode,role_id,done_dt
from
(select wish_mode,role_id,to_date(cast(date_time as timestamp)) as done_dt,consume_prop_num
from myth_server.server_wish_room
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) c1
where consume_prop_num > 0
group by 1,2,3
) c
on b.wish_mode = c.wish_mode and b.role_id = c.role_id and datediff(c.done_dt,b.done_dt) = 1
group by 1,2,3
) as b
group by 1 order by 1





信徒心愿
参与数据
select get_id,count(distinct b.role_id) as '参与人数',
              count(num) as '参与次数'
              round(count(num) / count(distinct b.role_id),2) as '人均参与次数'
from

(select role_id,get_id
from
(SELECT role_id,currency_id as get_id
FROM myth.server_currency
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
AND change_type = 'PRODUCE'
and change_method = '0' -- 信徒心愿获得 需要对表更改

union all

SELECT role_id,prop_id as get_id
FROM myth.server_prop
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
AND change_type = 'PRODUCE'
and change_method = '0' -- 信徒心愿获得 需要对表更改
) as a1
group by 1,2
) as a

left join 
( -- 参与信徒心愿的玩家  消耗心愿值大于0
select role_id,num
from
(select role_id,log_time as num,consume_believer
from myth_server.server_bless_believer
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) b1
where consume_believer > 0
group by 1,2
) b
on a.role_id = b.role_id
group by 1
order by 1


刷新数据
信徒心愿刷新数据
和钻石消耗
select get_id,count(distinct b.role_id) as '刷新人数',
              count(distinct log_time) as '刷新次数'
              round(count(distinct log_time) / count(distinct b.role_id),2) as '人均刷新次数',
              count(distinct case when change_count > 0 then b.role_id else NULL end) as '消耗钻石人数',
              count(distinct case when change_count > 0 then log_time else NULL end) as '消耗钻石次数'
from

(select role_id,get_id
from
(SELECT role_id,currency_id as get_id
FROM myth.server_currency
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
AND change_type = 'PRODUCE'
and change_method = '0' -- 信徒心愿获得 需要对表更改
union all
SELECT role_id,prop_id as get_id
FROM myth.server_prop
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
AND change_type = 'PRODUCE'
and change_method = '0' -- 信徒心愿获得 需要对表更改
) as a1
group by 1,2
) as a

left join
(select role_id,log_time,change_count
from
(SELECT role_id,log_time,change_count 
FROM myth.server_currency
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and currency_id = '3'
AND change_type = 'CONSUME'
and change_method = '40' -- 刷新信徒心愿
group by 1,2,3
union all
SELECT role_id,log_time, 0 as change_count 
FROM myth_server.server_click_believer
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and sys_type = 1 -- 免费刷新信徒心愿
group by 1,2,3
) as b1
group by 1,2,3
) as b
on a.role_id = b.role_id
group by 1
order by 1


天复玩率
select get_id,round(count(distinct case when play_not = 'yes' then b.role_id else NULL end) / count(distinct b.role_id),2) as '复玩率'
from
(select role_id,get_id
from
(SELECT role_id,currency_id as get_id
FROM myth.server_currency
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
AND change_type = 'PRODUCE'
and change_method = '0' -- 信徒心愿获得 需要对表更改
union all
SELECT role_id,prop_id as get_id
FROM myth.server_prop
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
AND change_type = 'PRODUCE'
and change_method = '0' -- 信徒心愿获得 需要对表更改
) as a1
group by 1,2
) as a

left join
(select b.role_id,case when c.role_id is null then 'no'
                 else 'yes'
                 end as play_not
from
( -- 参与信徒心愿的玩家  消耗心愿值大于0
select role_id,done_dt
from
(select role_id,to_date(cast(date_time as timestamp)) as done_dt,consume_believer
from myth_server.server_bless_believer
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) b1
where consume_believer > 0
group by 1,2,3
) b

left join
( -- 参与信徒心愿的玩家  消耗心愿值大于0
select role_id,done_dt
from
(select role_id,to_date(cast(date_time as timestamp)) as done_dt,consume_believer
from myth_server.server_bless_believer
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) c1
where consume_believer > 0
group by 1,2,3
) c
on b.role_id = c.role_id and datediff(c.done_dt,b.done_dt) = 1
group by 1,2
) as b
on a.role_id = b.role_id
group by 1





春之庭院
参与情况，参与人数、参与次数

select 付费档位,count(distinct a.role_id) as '参与人数',count(num) as '参与次数',round(count(num)/count(distinct a.role_id),2) as '人均参与次数'
from

( -- 参与春之庭院的玩家  有领取挂机奖励的日志
select role_id,log_time as num
from myth_server.server_claim_hang_reward
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) a

left join -- 付费分档
(select role_id,
       case when sum_pay > 0 and sum_pay <= 78 then '1小R'
            when sum_pay > 78 and sum_pay <= 628 then '2中R'
            when sum_pay > 628 and sum_pay <= 972 then '3大R'
            when sum_pay > 972 then '4超R'
            else '免费'
            end as '付费档位'
from
(select role_id,to_date(cast(date_time as timestamp)) as pay_dt,sum(pay_price) as sum_pay
from myth.order_pay
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and country not in ('CN','HK')
group by 1,2
) c1
group by 1,2
) c
on a.role_id = c.role_id
group by 1


挂机加速数据
select 付费档位,count(distinct a.role_id) as '加速人数',count(num) as '加速次数',round(count(num)/count(distinct a.role_id),2) as '人均加速次数'
               count(distinct case when consume_currency_num > 0 then a.role_id else NULL end) as '消耗钻石加速人数',
               count(case when consume_currency_num > 0 then num else 0 end) as '消耗钻石加速次数',
               round(count(case when consume_currency_num > 0 then num else 0 end)/count(distinct case when consume_currency_num > 0 then a.role_id else NULL end),2) as '消耗钻石人均加速次数'
from

( 
select role_id,log_time as num,consume_currency_num
from myth_server.server_quicken_hang
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3
) a

left join -- 付费分档
(select role_id,
       case when sum_pay > 0 and sum_pay <= 78 then '1小R'
            when sum_pay > 78 and sum_pay <= 628 then '2中R'
            when sum_pay > 628 and sum_pay <= 972 then '3大R'
            when sum_pay > 972 then '4超R'
            else '免费'
            end as '付费档位'
from
(select role_id,to_date(cast(date_time as timestamp)) as pay_dt,sum(pay_price) as sum_pay
from myth.order_pay
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and country not in ('CN','HK')
group by 1,2
) c1
group by 1,2
) c
on a.role_id = c.role_id
group by 1
order by 1





主城答题

select npc_id,答题人数,活跃人数,
       round(答题人数 / 活跃人数*100,2) as '答题占比%'
from
-- 这个周期内参与答题人数
(select npc_id,count(distinct role_id) as '答题人数'
from myth_server.server_questions
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1
) a 
left join
-- 有至少两个自然日登录的玩家
(select count(distinct role_id) as '活跃人数'
from
(select role_id,count(distinct day_time) as num  
from myth.client_online
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1
) as b1 
where num >= 2
) b
on 1 = 1
order by npc_id asc


