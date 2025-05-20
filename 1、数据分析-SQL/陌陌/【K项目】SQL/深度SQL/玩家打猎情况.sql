select case round(cast(map_id as int)/10000,0)
when 1 then  '家园'
when 2 then  '第一章1'
when 3 then  '第一章2'
when 4 then  '第一章3'
when 5 then  '野餐聚会'
when 6 then  '第二章1'
when 7 then  '第二章2'
when 8 then  '第二章3'
when 9 then  '第二章4'
when 10 then '第二章5'
when 11 then '成人礼'
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
role_level as '等级', 
count(distinct user_id) as '打猎账户数',
round(count(1)/count(distinct user_id),2) as '账户平均打猎次数',
round(sum(cast(consume_physical_count as double))/count(distinct user_id),2) as '账户平均打猎消耗体力数量',
round(avg(cast(consume_physical_count as double)),2) as '打猎平均消耗体力点数'
from fairy_town_server.server_hunt
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by 1,2
order by role_level;
