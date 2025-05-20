select round(cast(map_id as int)/10000,0) as '地图ID',
case round(cast(map_id as int)/10000,0)
when 1 then '梦想镇'
when 2 then '第一章1'
when 3 then '第一章2'
when 4 then '第一章3'
when 5 then '第一章支线'
when 6 then '第二章1'
when 7 then '第二章2'
when 8 then '第二章3'
when 9 then '第二章4'
when 10 then '第二章5'
when 11 then '第二章支线'
when 12 then '第三章1'
when 13 then '第三章2'
when 14 then '第三章3'
when 15 then '第三章4'
when 16 then '第三章5'
when 18 then '第四章1'
when 19 then '第四章2'
when 20 then '第四章3'
Else '暂不开启'
end as '地图名称',
round(sum(target_count)/count(distinct user_id),2) as '账户平均作用道具数量', 
round(sum(consume_count)/sum(target_count),2) as '账户平均单次体力消耗数量',
round(sum(consume_count)/count(distinct user_id),2) as '账户平均体力消耗数量',
count(distinct user_id) as '消耗体力账户数'
from fairy_town_server.server_physical_consume
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by round(cast(map_id as int)/10000,0)
order by 地图ID
