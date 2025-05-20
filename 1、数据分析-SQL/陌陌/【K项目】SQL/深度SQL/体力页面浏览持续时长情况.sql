select role_level as '等级', 
count(distinct user_id) as '账户数',
round(avg(账户浏览体力面板时间)/60000,2) as '账户平均浏览时长(分钟)'
from
(
select role_level, user_id, avg(time_interval) as '账户浏览体力面板时间'
from
(
select role_level, user_id, open_time, min(close_time-open_time) as 'time_interval'
from
(
SELECT o.role_level, o.user_id, o.log_time as 'open_time', c.log_time as 'close_time'
FROM fairy_town_server.server_open_energy_panel o
left join fairy_town_server.server_close_energy_panel c
on c.user_id=o.user_id and c.role_level=o.role_level
where c.day_time between ${beginDate} and ${endDate} and c.server_id in (${serverIds})
and o.day_time between ${beginDate} and ${endDate} and o.server_id in (${serverIds})
group by o.role_level, o.user_id, o.log_time, c.log_time
)l1 
where close_time>open_time
group by role_level, user_id, open_time
)l2
group by role_level, user_id
)l3
group by role_level
order by role_level
