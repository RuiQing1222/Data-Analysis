select t1.day_time as '日期',
count(distinct t1.user_id) as '点击体力加号账户数',
count(distinct t2.user_id) as '购买体力账户数',
round(count(distinct t2.user_id)/count(distinct t1.user_id)*100,2) as '点击体力加号并购买体力用户比例%',
count(distinct t1.user_id)-count(distinct t2.user_id) as '点击体力加号没购买体力用户数',
round(sum(账户点击体力加号次数)/count(distinct t1.user_id),2) as '账户平均点击体力加号次数',
round(sum(购买体力次数)/count(distinct t2.user_id),2) as '账户平均购买体力次数',
round(sum(购买体力次数)/sum(账户点击体力加号次数)*100,2) as '购买体力次数与点击体力加号次数比例%',
round(sum(体力数)/count(distinct t2.user_id),2) as '账户平均购买体力数'
from
(
SELECT day_time, user_id, count(1) as '账户点击体力加号次数'
FROM fairy_town_server.server_open_energy_panel 
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by day_time, user_id
)t1 left join
(
SELECT day_time, user_id, count(1) as '购买体力次数', sum(recovery_count) as '体力数'
FROM fairy_town_server.server_physical_recovery
where recovery_method='7'
and day_time between ${beginDate} and ${endDate}
and server_id in (${serverIds})
group by day_time, user_id
)t2 on t1.day_time=t2.day_time and t1.user_id=t2.user_id
group by t1.day_time
order by 日期