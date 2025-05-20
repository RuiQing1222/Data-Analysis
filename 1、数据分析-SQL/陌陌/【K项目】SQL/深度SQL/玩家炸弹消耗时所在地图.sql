select l1.map_id as '玩家炸弹消耗时所在地图',
case l1.map_id 
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
bomb_id as '炸弹ID',
case bomb_id
when '1' then '普通炸弹'
when '2' then '定点炸弹'
when '3' then '免费炸弹'
end as '炸弹名称',
该地图账户数,
使用炸弹账户数,
round(使用炸弹账户数/该地图账户数*100,2) as '使用炸弹账户比例%',
总共使用炸弹数,
账户平均使用炸弹次数
from (
select round(cast(map_id as int)/10000,0) as 'map_id', 
bomb_id,
count(distinct user_id) as '使用炸弹账户数',
count(1) as '总共使用炸弹数',
round(count(1)/count(distinct user_id),2) as '账户平均使用炸弹次数'
from fairy_town_server.server_bomb_consume
where 
day_time between ${beginDate} and ${endDate}
      and server_id in (${serverIds})
group by round(cast(map_id as int)/10000,0), bomb_id
) l1
left join 
(
select round(cast(map_id as int)/10000,0) as 'map_id',
count(distinct user_id) as '该地图账户数'
from fairy_town_server.server_map_enter
where day_time between ${beginDate} and ${endDate}
      and server_id in (${serverIds})
group by round(cast(map_id as int)/10000,0)
) l2
on l1.map_id = l2.map_id
order by 玩家炸弹消耗时所在地图
