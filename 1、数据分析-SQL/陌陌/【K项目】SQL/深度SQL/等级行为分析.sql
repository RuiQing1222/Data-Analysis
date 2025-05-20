select t1.role_level as '等级',
地图编号,
平均消耗体力数量,
等级账户数,
`等级转化率%`,
`总体等级转化率%`,
`等级停留时长(分钟)`,
等级停留天数,
`平均在线时长(分钟)`,
`累计在线时长(分钟)`,
平均登录次数,
完成猫头鹰订单数,
完成猫头鹰订单账户数,
账户平均完成猫头鹰订单数,
完成火车订单数,
完成火车订单账户数,
账户平均完成火车订单数,
完成码头订单数,
完成码头订单账户数,
账户平均完成码头订单数,
畜牧道具ID,
获得畜牧道具数量,
账户平均获得畜牧道具数量,
农业道具ID,
获得农业道具数量,
账户平均获得农业道具数量,
生产道具ID,
获得生产道具数量,
账户平均获得生产道具数量,
货币ID,
货币数量,
账户平均货币数量
from
(
select role_level, 
count(distinct user_id) as '等级账户数',
round(count(distinct user_id)/(first_value(count(distinct user_id)) over (order by role_level) )*100,2) as '总体等级转化率%',
round(avg(用户停留在该等级时长),2) as '等级停留时长(分钟)',
round(avg(用户停留在该等级天数),2) as '等级停留天数'
from 
(
select l1.user_id, l1.role_level, 
round((升级最小时间-该等级最小时间)/60000,2) as '用户停留在该等级时长',
round((升级最小时间-(first_value(该等级最小时间) over (partition by l1.user_id order by l1.user_id, l1.role_level) ))/60000/1440,2) as '用户停留在该等级天数'
from
(
select user_id, role_level, log_time as '该等级最小时间'
from fairy_town.server_role_create
where day_time between ${beginDate} and ${endDate} 
union all
SELECT user_id, role_level, min(log_time) as '该等级最小时间'
FROM fairy_town.server_role_upgrade
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by user_id, role_level
)l1
left join
(
SELECT user_id, role_level-1 as 'role_level', min(log_time) as '升级最小时间'
FROM fairy_town.server_role_upgrade
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by user_id, role_level-1
)l2
on l1.user_id =l2.user_id and l1.role_level=l2.role_level 
) tt
group by role_level
)t1
left join
(
select role_level as 'role_level', group_concat(cast(l1.map_id as string)) as '地图编号', group_concat(l1.consume_count) as '平均消耗体力数量'
from 
(
select role_level, round(cast(map_id as int)/10000,0) as 'map_id', 
cast(round(sum(consume_count)/count(distinct user_id),0)as string) as 'consume_count' 
from fairy_town_server.server_physical_consume
where day_time between ${beginDate} and ${endDate}
and server_id=${serverIds}
group by role_level, round(cast(map_id as int)/10000,0)
)l1
group by role_level
) t2
on t1.role_level=t2.role_level
left join
(
select l1.role_level, 
count(1) as '完成猫头鹰订单数',
count(distinct l1.user_id) as '完成猫头鹰订单账户数',
round(count(1)/count(distinct l1.user_id),2) as '账户平均完成猫头鹰订单数'
from
(
select role_level, order_type, user_id, order_id
from fairy_town_server.server_order_accepted
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
      and order_type = '1'
)l1
left join
(
select role_level, user_id, order_id
from fairy_town_server.server_order_owl
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
)l2
on l1.user_id=l2.user_id and l1.order_id = l2.order_id
group by l1.role_level
) t3
on t1.role_level=t3.role_level
left join
(
select * 
from 
(
(
select tt1.role_level as 'role_level',
完成火车订单数,
完成火车订单账户数,
账户平均完成火车订单数
from
(
select 8 as 'role_level',
sum(完成火车订单数) as '完成火车订单数'
from 
(
select *
from
(select l1.role_level as 'role_level', 
count(1) as '完成火车订单数',
count(distinct l1.user_id) as '完成火车订单账户数',
round(count(1)/count(distinct l1.user_id),2) as '账户平均完成火车订单数'
from
(
select role_level, order_type, user_id, order_id
from fairy_town_server.server_order_accepted
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
      and order_type = '2'
)l1
left join
(
select role_level, user_id, order_id
from fairy_town_server.server_order_train_complete
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
)l2
on l1.user_id=l2.user_id and l1.order_id = l2.order_id
group by l1.role_level
) ta
where role_level in (7,8)
) tb
) tt1
left join
(select 8 as 'role_level',
count(distinct l1.user_id) as '完成火车订单账户数',
round(count(1)/count(distinct l1.user_id),2) as '账户平均完成火车订单数'
from
(
select role_level, order_type, user_id, order_id
from fairy_town_server.server_order_accepted
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
      and order_type = '2' and role_level in (7,8)
)l1
left join
(
select role_level, user_id, order_id
from fairy_town_server.server_order_train_complete
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and role_level in (7,8)
)l2
on l1.user_id=l2.user_id and l1.order_id = l2.order_id
)tt2 on tt1.role_level= tt2.role_level
) 
union all
(
select *
from
(select l1.role_level as 'role_level', 
count(1) as '完成火车订单数',
count(distinct l1.user_id) as '完成火车订单账户数',
round(count(1)/count(distinct l1.user_id),2) as '账户平均完成火车订单数'
from
(
select role_level, order_type, user_id, order_id
from fairy_town_server.server_order_accepted
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
      and order_type = '2'
)l1
left join
(
select role_level, user_id, order_id
from fairy_town_server.server_order_train_complete
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
)l2
on l1.user_id=l2.user_id and l1.order_id = l2.order_id
group by l1.role_level
) ta
where role_level>8
)
) td
)t4
on t1.role_level=t4.role_level
left join
(
select l1.role_level, 
count(1) as '完成码头订单数',
count(distinct l1.user_id) as '完成码头订单账户数',
round(count(1)/count(distinct l1.user_id),2) as '账户平均完成码头订单数'
from
(
select role_level, order_type, user_id, order_id
from fairy_town_server.server_order_accepted
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
      and order_type = '3'
)l1
left join
(
select role_level, user_id, order_id
from fairy_town_server.server_order_wharf_complete
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
)l2
on l1.user_id=l2.user_id and l1.order_id = l2.order_id
group by l1.role_level
)t5
on t1.role_level=t5.role_level
left join
(
select role_level,
group_concat(prop_id) as '畜牧道具ID',
group_concat(cast (have as string)) as '获得畜牧道具数量',
group_concat(cast (round(have/等级账户数,0) as string)) as '账户平均获得畜牧道具数量'
from 
(
select b.role_level,等级账户数,prop_id,have
from
(
select * from
(
(SELECT role_level, count(distinct user_id) as '等级账户数'
FROM fairy_town.server_role_create 
where day_time between ${beginDate} and ${endDate}
group by role_level)
union all
(select role_level, count(distinct user_id) as '等级账户数'
from fairy_town.server_role_upgrade
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by role_level) 
)a
)b
left join
(
select l1.role_level, l1.prop_id, produce  as 'have', consume, produce-consume
from
(
select role_level, prop_id, sum(change_count) as 'consume'
from fairy_town.server_prop
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and change_type='CONSUME'
and prop_id in ('126001','126002','126003','126004','126005','126006','126007','126008','126009','126010',
'106001','106002','106003','106004','106005','107001','107002','107003','107004','107005','107006','107007'
,'127016','127017','127018')
group by role_level, prop_id
)l1
left join
(
select role_level, prop_id, sum(change_count) as 'produce'
from fairy_town.server_prop
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and change_type='PRODUCE'
and prop_id in ('126001','126002','126003','126004','126005','126006','126007','126008','126009','126010',
'106001','106002','106003','106004','106005','107001','107002','107003','107004','107005','107006','107007'
,'127016','127017','127018')
group by role_level, prop_id
)l2
on l1.prop_id=l2.prop_id and l1.role_level=l2.role_level
)c
on b.role_level = c.role_level
) l3
group by role_level
)t6
on t1.role_level=t6.role_level
left join
(
select role_level,
group_concat(prop_id) as '农业道具ID',
group_concat(cast (have as string)) as '获得农业道具数量',
group_concat(cast (round(have/等级账户数,0) as string)) as '账户平均获得农业道具数量'
from 
(
select b.role_level,等级账户数,prop_id,have
from
(
select * from
(
(SELECT role_level, count(distinct user_id) as '等级账户数'
FROM fairy_town.server_role_create 
where day_time between ${beginDate} and ${endDate}
group by role_level)
union all
(select role_level, count(distinct user_id) as '等级账户数'
from fairy_town.server_role_upgrade
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by role_level) 
)a
)b
left join
(
select l1.role_level, l1.prop_id, produce as 'have'
from
(
select role_level, prop_id, sum(change_count) as 'consume'
from fairy_town.server_prop
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and change_type='CONSUME'
and prop_id in ('101001','101002','101003','101004','101005','101006','102001','102002','102003','102004','102005','102006')
group by role_level, prop_id
)l1
left join
(
select role_level, prop_id, sum(change_count) as 'produce'
from fairy_town.server_prop
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and change_type='PRODUCE'
and prop_id in ('101001','101002','101003','101004','101005','101006','102001','102002','102003','102004','102005','102006')
group by role_level, prop_id
)l2
on l1.prop_id=l2.prop_id and l1.role_level=l2.role_level
)c
on b.role_level = c.role_level
) l3
group by role_level
)t7
on t1.role_level=t7.role_level
left join
(
select role_level,
group_concat(prop_id) as '生产道具ID',
group_concat(cast (have as string)) as '获得生产道具数量',
group_concat(cast (round(have/等级账户数,0) as string)) as '账户平均获得生产道具数量'
from 
(
select b.role_level,等级账户数,prop_id,have
from
(
select * from
(
(SELECT role_level, count(distinct user_id) as '等级账户数'
FROM fairy_town.server_role_create 
where day_time between ${beginDate} and ${endDate}
group by role_level)
union all
(select role_level, count(distinct user_id) as '等级账户数'
from fairy_town.server_role_upgrade
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by role_level) 
)a
)b
left join
(
select l1.role_level, l1.prop_id, produce as 'have'
from
(
select role_level, prop_id, sum(change_count) as 'consume'
from fairy_town.server_prop
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and change_type='CONSUME'
and prop_id in (
'108001',
'108002',
'108003',
'108004',
'108005',
'108006',
'109001',
'109002',
'109003',
'109004',
'110001',
'110002',
'110003',
'110004',
'110005',
'110006',
'111001',
'111002',
'111003',
'111004',
'112001',
'112002',
'112003',
'112004',
'112005',
'113001',
'113002',
'113003',
'113004',
'113005',
'113006',
'114001',
'114002',
'114003',
'114004',
'114005',
'115001',
'115002',
'115003',
'115004',
'116001',
'116002',
'116003',
'116004',
'116005',
'116006',
'116007',
'116008',
'117001',
'117002',
'117003',
'117004',
'117005',
'118001',
'118002',
'118003',
'118004',
'118005',
'118006',
'119001',
'119002',
'119003',
'119004',
'119005',
'120001',
'120002',
'120003',
'120004',
'120005',
'121001',
'121002',
'121003',
'121004',
'122001',
'122002',
'122003',
'122004',
'123001',
'123002',
'123003',
'123004',
'123005',
'124001',
'124002',
'124003',
'124004',
'124005',
'124006',
'125001',
'125002',
'125003',
'125004',
'125005')
group by role_level, prop_id
)l1
left join
(
select role_level, prop_id, sum(change_count) as 'produce'
from fairy_town.server_prop
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and change_type='PRODUCE'
and prop_id in (
'108001',
'108002',
'108003',
'108004',
'108005',
'108006',
'109001',
'109002',
'109003',
'109004',
'110001',
'110002',
'110003',
'110004',
'110005',
'110006',
'111001',
'111002',
'111003',
'111004',
'112001',
'112002',
'112003',
'112004',
'112005',
'113001',
'113002',
'113003',
'113004',
'113005',
'113006',
'114001',
'114002',
'114003',
'114004',
'114005',
'115001',
'115002',
'115003',
'115004',
'116001',
'116002',
'116003',
'116004',
'116005',
'116006',
'116007',
'116008',
'117001',
'117002',
'117003',
'117004',
'117005',
'118001',
'118002',
'118003',
'118004',
'118005',
'118006',
'119001',
'119002',
'119003',
'119004',
'119005',
'120001',
'120002',
'120003',
'120004',
'120005',
'121001',
'121002',
'121003',
'121004',
'122001',
'122002',
'122003',
'122004',
'123001',
'123002',
'123003',
'123004',
'123005',
'124001',
'124002',
'124003',
'124004',
'124005',
'124006',
'125001',
'125002',
'125003',
'125004',
'125005')
group by role_level, prop_id
)l2
on l1.prop_id=l2.prop_id and l1.role_level=l2.role_level
)c
on b.role_level = c.role_level
) l3
group by role_level
)t8
on t1.role_level=t8.role_level
left join
(
select role_level,
group_concat(currency_id) as '货币ID',
group_concat(cast (have as string)) as '货币数量',
group_concat(cast (round(have/等级账户数,0) as string)) as '账户平均货币数量'
from 
(
select b.role_level,等级账户数,currency_id,have
from
(
select * from
(
(SELECT role_level, count(distinct user_id) as '等级账户数'
FROM fairy_town.server_role_create 
where day_time between ${beginDate} and ${endDate}
group by role_level)
union all
(select role_level, count(distinct user_id) as '等级账户数'
from fairy_town.server_role_upgrade
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by role_level) 
)a
)b
left join
(
select l1.role_level, l1.currency_id, produce, consume, produce-consume as 'have'
from
(
select role_level, currency_id, sum(change_count) as 'consume'
from fairy_town.server_currency
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and change_type='CONSUME'
group by role_level, currency_id
)l1
left join
(
select role_level, currency_id, sum(change_count) as 'produce'
from fairy_town.server_currency
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and change_type='PRODUCE'
group by role_level, currency_id
)l2
on l1.currency_id=l2.currency_id and l1.role_level=l2.role_level
)c
on b.role_level = c.role_level
) l3
group by role_level
)t9
on t1.role_level=t9.role_level
left join
(
select role_level, 
round(count(user_id)/count(distinct user_id),2) as '平均登录次数'
from fairy_town.server_role_login
where 
day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by role_level
)t10
on t1.role_level=t10.role_level
left join
(
select ta1.role_level,ifnull(round(ta1.等级账户数/ta2.等级账户数*100,2),100) as '等级转化率%'
from
(
select 
(row_number() over (order by role_level)-1) as 'id',
role_level,
等级账户数,
round(等级账户数/(first_value(等级账户数) over (order by role_level) )*100,2) as '总体等级转化率%',
等级停留分钟,
等级停留天数
from
(
(
select role_level, 
count(distinct l1.user_id) as '等级账户数',
round(avg(l2.log_time-l1.log_time)/60000,2) as '等级停留分钟',
round(avg(l2.log_time-l1.log_time)/60000/1440,2) as '等级停留天数'
from
(
SELECT role_level, user_id, log_time
FROM fairy_town.server_role_create 
where day_time between ${beginDate} and ${endDate}
)l1
left join
(
select user_id, log_time
from fairy_town.server_role_upgrade
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and role_level=2
)l2
on l1.user_id = l2.user_id
group by role_level
)
union all
(
select role_level, 
count(distinct user_id) as '等级账户数',
round(avg(等级停留分钟),2) as '等级停留分钟',
round(avg(等级停留天数),2) as '等级停留天数'
from
(
select l1.user_id, l1.role_level, 
round((升级最小时间-该等级最小时间)/60000,2) as '等级停留分钟',
round((升级最小时间-该等级最小时间)/60000/1440,2) as '等级停留天数'
from
(
SELECT user_id, role_level, min(log_time) as '该等级最小时间'
FROM fairy_town.server_role_upgrade
where 
day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by user_id, role_level
)l1
left join
(
SELECT user_id, role_level-1 as 'role_level', min(log_time) as '升级最小时间'
FROM fairy_town.server_role_upgrade
where 
day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by user_id, role_level-1
)l2
on l1.user_id =l2.user_id and l1.role_level=l2.role_level
) l3
group by role_level
)
) l4
) ta1
left join
(
select 
row_number() over (order by role_level) as 'id',
role_level,
等级账户数,
round(等级账户数/(first_value(等级账户数) over (order by role_level) )*100,2) as '总体等级转化率%',
等级停留分钟,
等级停留天数
from
(
(
select role_level, 
count(distinct l1.user_id) as '等级账户数',
round(avg(l2.log_time-l1.log_time)/60000,2) as '等级停留分钟',
round(avg(l2.log_time-l1.log_time)/60000/1440,2) as '等级停留天数'
from
(
SELECT role_level, user_id, log_time
FROM fairy_town.server_role_create 
where day_time between ${beginDate} and ${endDate}
)l1
left join
(
select user_id, log_time
from fairy_town.server_role_upgrade
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and role_level=2
)l2
on l1.user_id = l2.user_id
group by role_level
)
union all
(
select role_level, 
count(distinct user_id) as '等级账户数',
round(avg(等级停留分钟),2) as '等级停留分钟',
round(avg(等级停留天数),2) as '等级停留天数'
from
(
select l1.user_id, l1.role_level, 
round((升级最小时间-该等级最小时间)/60000,2) as '等级停留分钟',
round((升级最小时间-该等级最小时间)/60000/1440,2) as '等级停留天数'
from
(
SELECT user_id, role_level, min(log_time) as '该等级最小时间'
FROM fairy_town.server_role_upgrade
where 
day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by user_id, role_level
)l1
left join
(
SELECT user_id, role_level-1 as 'role_level', min(log_time) as '升级最小时间'
FROM fairy_town.server_role_upgrade
where 
day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by user_id, role_level-1
)l2
on l1.user_id =l2.user_id and l1.role_level=l2.role_level
) l3
group by role_level
)
) l4
)ta2 on ta1.id=ta2.id
)t11 on t1.role_level=t11.role_level
left join
(
select t1.role_level, 
round(count(t1.user_id)/count(distinct t1.user_id),2) as '平均在线时长(分钟)',
round(sum(count(t1.user_id)/count(distinct t1.user_id)) over (order by t1.role_level),2) as '累计在线时长(分钟)'
from
(
SELECT role_level-1 as 'role_level', user_id, log_time
FROM fairy_town.server_role_upgrade 
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
)t1 left join 
(
select *
from
(
(SELECT role_level, user_id, log_time
FROM fairy_town.server_role_create 
where day_time between ${beginDate} and ${endDate} 
)union all
(SELECT role_level as 'role_level', user_id, log_time
FROM fairy_town.server_role_upgrade 
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
)
) list
)t2 
on t1.role_level= t2.role_level and t1.user_id=t2.user_id
left join
(
select l1.role_level, l1.user_id, l2.log_time
from 
(
SELECT role_level-1 as 'role_level', user_id, log_time
FROM fairy_town.server_role_upgrade 
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
)l1 left join
(
select user_id, log_time
FROM fairy_town.client_online
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
)l2
on l1.user_id= l2.user_id 
)t3
on t1.role_level=t3.role_level and t1.user_id = t3.user_id 
and t1.log_time > t3.log_time and t2.log_time <= t3.log_time
group by role_level
)t12 on t1.role_level=t12.role_level
order by t1.role_level
