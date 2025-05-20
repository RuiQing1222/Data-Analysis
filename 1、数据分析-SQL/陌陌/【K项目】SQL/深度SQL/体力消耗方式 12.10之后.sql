SELECT a.day_time as '日期', 采集消耗,转动消耗,打猎消耗,市场消耗
from

(SELECT day_time,sum(consume_count) as '采集消耗'
FROM fairy_town_server.server_physical_consume
WHERE server_id IN (10001,10002,10003) and day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
GROUP BY 1
ORDER BY 1) as a
left join
(SELECT day_time,sum(consume_count) as '转动消耗'
from fairy_town_server.server_stone_pillar_turn
where server_id IN (10001,10002,10003) and day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
GROUP BY 1
ORDER BY 1) as b
on a.day_time = b.day_time

left join
(SELECT day_time,sum(consume_physical_count) as '打猎消耗'
FROM fairy_town_server.server_hunt 
where server_id IN (10001,10002,10003) and day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
GROUP BY 1
ORDER BY 1) as c
on a.day_time = c.day_time

left join
(SELECT day_time,sum(consume_currency_count) as '市场消耗'
FROM fairy_town_server.server_market_buy 
where server_id IN (10001,10002,10003) and day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and consume_currency_id = '3'
GROUP BY 1
ORDER BY 1) as d
on a.day_time = d.day_time

group by 1
order by 1
