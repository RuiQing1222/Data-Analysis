select map_id as '地图ID',bomb_id as '炸弹ID',
case bomb_id
when '1' then '普通'
when '2' then '定点'
when '3' then '免费'
end as '炸弹类型',
case map_id
when '10001' then '梦想镇'
when '20001' then '睡美人1'
when '30001' then '睡美人2'
when '30002' then '睡美人2'
when '40001' then '睡美人3'
when '50001' then '睡美人支线'
when '50002' then '睡美人支线'
when '60001' then '美人鱼1'
when '70001' then '美人鱼2'
when '80001' then '美人鱼3'
when '90001' then '美人鱼4'
when '100001' then '美人鱼5'
when '110001' then '美人鱼支线'
when '120001' then '第三章1'
when '130001' then '第三章2'
when '140001' then '第三章3'
when '150001' then '第三章4'
when '160001' then '第三章4'
when '180001' then '第四章1'
when '190001' then '第四章2'
when '200001' then '第四章3'
when '210001' then '第四章4'
when '220001' then '第四章5'
when '30010001' then '飞鱼岛的宝藏'
when '30020001' then '雪人的故事'
when '31010001' then '怪物派对'
when '31020001' then '企鹅镇'
when '40010001' then '皇后迷宫-雪地1'
when '40020001' then '皇后迷宫-秋季草地1'
when '40030001' then '皇后迷宫-沙滩1'
when '40040001' then '皇后迷宫-森林1'
when '40050001' then '皇后迷宫-阴暗1'
when '40060001' then '皇后迷宫-森林2'
when '40070001' then '皇后迷宫-阴暗2'
when '40080001' then '皇后迷宫-雪地2'
when '40090001' then '皇后迷宫-沙滩1-固定'
when '40100001' then '皇后迷宫-森林2-固定'
when '40110001' then '皇后迷宫-阴暗2-固定'
when '40120001' then '皇后迷宫-雪地2-固定'
Else '暂不开启'
end as '地图名称',
count(bomb_id) as '炸弹消耗数量'
from
fairy_town_server.server_bomb_consume
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by 1
order by 1