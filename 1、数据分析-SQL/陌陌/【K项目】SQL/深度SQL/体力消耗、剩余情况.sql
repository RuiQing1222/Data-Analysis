体力消耗情况
select target_id as '体力消耗原因ID', 
round(sum(target_count)/count(distinct user_id),2) as '账户平均体力消耗次数', 
round(sum(consume_count)/count(distinct user_id),2) as '账户平均体力消耗数量',
count(distinct user_id) as '账户数'
from fairy_town_server.server_physical_consume
where day_time between ${beginDate} and ${endDate}
      and server_id in (${serverIds})
group by target_id
order by cast(target_id as int)










体力剩余情况
select 
day_time  as '日期',
sum(rest) as '该天总共剩余体力',
round(sum(consume)/count(distinct user_id),2)  as '账户每天平均消耗体力',
round(sum(recovery)/count(distinct user_id),2) as '账户每天平均恢复体力',
round(sum(rest)/count(distinct user_id),2)     as '账户每天平均剩余体力',
count(distinct user_id)                        as '消耗体力账户数'
from
(select 
l1.day_time as 'day_time', l1.user_id as 'user_id',
recovery,consume,rest
from
(select day_time, user_id, sum(consume) as consume
from
(
select day_time, user_id, consume_count as 'consume'
from fairy_town_server.server_physical_consume 
where day_time between ${beginDate} and ${endDate}
and server_id in (${serverIds})
union all
select day_time, user_id, consume_physical_count as 'consume'
from fairy_town_server.server_hunt 
where day_time between ${beginDate} and ${endDate}
and server_id in (${serverIds})  
union all 
select day_time, user_id, consume_currency_count as 'consume'
from fairy_town_server.server_market_buy
where day_time between ${beginDate} and ${endDate}
and server_id in (${serverIds})  
and consume_currency_id='3'
union all 
select day_time, user_id, consume_count as 'consume'
from fairy_town_server.server_stone_pillar_turn
where day_time between ${beginDate} and ${endDate}
and server_id in (${serverIds})  
) a
group by 1,2
)l1
left join
(
select day_time, user_id, sum(recovery_count) as 'recovery'
from fairy_town_server.server_physical_recovery 
where day_time between ${beginDate} and ${endDate}
and server_id in (${serverIds})
group by day_time, user_id
)l2
on l1.day_time = l2.day_time and l1.user_id = l2.user_id
left join
(
select day_time, user_id, physical as 'rest'
from fairy_town_server.server_login_snap_shot
where day_time between ${beginDate} and ${endDate}
and server_id in (${serverIds})
)l3
on l1.day_time = l3.day_time and l1.user_id = l3.user_id
group by 1,2,3,4,5
) list
group by day_time
order by 日期