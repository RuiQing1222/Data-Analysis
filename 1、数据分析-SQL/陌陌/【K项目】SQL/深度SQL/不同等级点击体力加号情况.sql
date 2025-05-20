select t2.role_level as '等级', 
sum(购买次数) as '购买体力次数',
sum(点开体力加号次数) as '点开体力加号次数',
count(distinct t1.user_id) as '购买体力账户数',
count(distinct t2.user_id) as '点开体力加号账户数',
sum(体力数) as '加体力数',
round(sum(购买次数)/sum(点开体力加号次数)*100,2) as '加体力比例%'
from 
(
SELECT role_level, user_id, count(1) as '购买次数', sum(recovery_count) as '体力数'
FROM fairy_town_server.server_physical_recovery
where recovery_method='7'
and day_time between ${beginDate} and ${endDate}
and server_id in (${serverIds})
group by role_level, user_id
)t1 right join
(select role_level, user_id, count(1) as '点开体力加号次数'
from fairy_town_server.server_open_energy_panel
where day_time between ${beginDate} and ${endDate}
and server_id in (${serverIds})
group by role_level, user_id
)t2 on t1.role_level=t2.role_level and t1.user_id=t2.user_id
group by t2.role_level
order by t2.role_level
