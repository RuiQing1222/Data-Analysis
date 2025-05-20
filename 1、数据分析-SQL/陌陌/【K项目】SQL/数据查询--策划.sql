这样看
用户数据：
1.通关用户的日均体力净消耗，和未通关主线用户的日均体力净消耗对比。
2.通关用户日均在线人数和账户总人数对比，未通关用户日均在线人数和账户总人数对比

这两样分别对比两个时间范围，查看的时间以日为计：
活动期
1.4月22日-5月3日 复活节
2.5月13日-5月24日 皇后迷宫v3
3.5月13日-5月18日 镇长大赛
4.5月28日-6月1日 周常1
5.6月20日 -6月29日 垂钓海滩
非活动期
1.5月4日-5月12日
2.5月25日-5月27日
3.6月2日-6月19日



select a.role_id as '角色ID',a.day_time as '日期',体力总消耗,免费体力获得,case when c.role_id is not null then '通关' else '未通关' end as '是否通关'
from

(-- 体力总消耗
SELECT role_id,day_time,sum(physical_consume) as '体力总消耗'
from
(SELECT role_id,day_time,consume_count as physical_consume from fairy_town_server.server_physical_consume   -- 采集
where server_id in (10001,10002,10003) and day_time >= ${start_time} and day_time <= ${end_time}

union all 

SELECT role_id,day_time,consume_physical_count as physical_consume from fairy_town_server.server_hunt       -- 打猎
where server_id in (10001,10002,10003) and day_time >= ${start_time} and day_time <= ${end_time}

union all

SELECT role_id,day_time,consume_count as physical_consume from fairy_town_server.server_stone_pillar_turn       -- 旋转石柱
where server_id in (10001,10002,10003) and day_time >= ${start_time} and day_time <= ${end_time}

union all

SELECT role_id,day_time,consume_currency_count as physical_consume from fairy_town_server.server_market_buy      -- 市场购买
where server_id in (10001,10002,10003) and day_time >= ${start_time} and day_time <= ${end_time}
and consume_currency_id = '3'
) a
group by 1,2
) as a

left join

(-- 免费体力获得
SELECT role_id,day_time,sum(recovery_count) as '免费体力获得' from fairy_town_server.server_physical_recovery
where day_time >= ${start_time} and day_time <= ${end_time}
and server_id in (10001,10002,10003) 
and recovery_method in ('4','5','6','13','14','15','17','19','20','22','23','27','28','29','67','71','72','75','77','78','80','83','88','90','91','93',
                        '94','97','101','108','111','116','118','119','127','135','139')
group by 1,2
) as b 
on a.role_id = b.role_id and a.day_time = b.day_time

left join

(select role_id
from fairy_town_server.server_task_completed
where day_time >= 20210916 and day_time < ${start_time}
and task_group_id ='205126'
and server_id in (10001,10002,10003) 
) as c 
on a.role_id = c.role_id
group by 1,2,3,4,5
order by 2



在线每日
select a.role_id as '角色ID',a.day_time as '日期',case when c.role_id is not null then '通关' else '未通关' end as '是否通关'
from

(SELECT role_id,day_time from fairy_town.server_role_login
where server_id in (10001,10002,10003)
and day_time >= ${start_time} and day_time <= ${end_time}
group by 1,2) as a

left join

(select role_id
from fairy_town_server.server_task_completed
where day_time >= 20210916 and day_time < ${start_time}
and task_group_id ='205126'
and server_id in (10001,10002,10003) 
) as c

on a.role_id = c.role_id
group by 1,2,3





总人数
select a.day_time as '日期',case when c.role_id is not null then '通关' else '未通关' end as '是否通关',count(distinct a.role_id)
from

(SELECT role_id,day_time from fairy_town.server_role_create
where server_id in (10001,10002,10003)
and day_time >= 20210420 and day_time <= 20220629
group by 1,2) as a

left join

(select role_id
from fairy_town_server.server_task_completed
where day_time >= 20210916 and day_time <= 20220629
and task_group_id ='205126'
and server_id in (10001,10002,10003) 
) as c

on a.role_id = c.role_id
group by 1,2
order by 1



21.9.16 至 22.5月25日的通关用户往前14天 往后14天的付费人均额度的差异
select role_id
from fairy_town_server.server_task_completed
where day_time >= 20210916 and day_time <= 20220525
and task_group_id ='205126'
and server_id in (10001,10002,10003) 




