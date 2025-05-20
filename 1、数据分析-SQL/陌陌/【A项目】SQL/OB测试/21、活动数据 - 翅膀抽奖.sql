

翅膀抽奖
开始 2023-8-11 18:00  结束 2023-8-18 18:00 1691748000000 - 1692352800000

select pay_or_not
       -- ,count(distinct g.role_id) as '任务接取人数'
       -- ,count(distinct h.role_id) as '任务完成人数'
       -- ,count(distinct i.role_id) as '完成任务领取道具人数'
       -- ,count(distinct i2.role_id) as '领取道具人数'
       -- ,sum(change_count) as '道具获取数量'
       -- ,count(distinct b.role_id) as '抽取人数'
       -- ,count(log_time) as '抽取次数'
       -- -- ,count(distinct c.role_id) as '可参与人数'
       -- -- ,count(distinct d.role_id) as '钻石消耗人数'
       -- -- ,round(sum(change_count) / count(distinct d.role_id),2) as '人均钻石消耗数'
       -- -- ,count(distinct e.role_id) as '礼包购买人数'
       -- -- ,round(sum(pay_price)/count(distinct e.role_id),2) as '礼包购买人均金额'
       -- ,count(distinct case when 是否购买礼包 = '否' then f.role_id else null end) as '未付费抽到大奖人数'
       -- ,round(sum(case when 是否购买礼包 = '否' then change_count else 0 end) / count(distinct case when 是否购买礼包 = '否' then f.role_id else null end),2) as '未付费抽到大奖人均钻石消耗'
       -- ,count(distinct case when 是否购买礼包 = '是' then f.role_id else null end) as '付费抽到大奖人数'
       -- ,round(sum(case when 是否购买礼包 = '是' then change_count else 0 end) / count(distinct case when 是否购买礼包 = '是' then f.role_id else null end),2) as '付费抽到大奖人均钻石消耗'
       -- ,round(sum(case when 是否购买礼包 = '是' then pay_price else 0 end) / count(distinct case when 是否购买礼包 = '是' then f.role_id else null end),2) as '付费抽到大奖人均付费金额'

from


-- 是否付费
(select birth_dt,a.role_id,case when b.role_id is null then '否' else '是' end as pay_or_not
from
(  --新增
select role_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
group by 1,2
)  a

left join
(
select role_id
from myth.order_pay
where log_time < 1692352800000 -- 活动结束前付费
and server_id in (${serverIds}) 
group by 1) b 
on a.role_id =b.role_id
group by 1,2,3
) a 


left join
-- 任务接取人数
(select role_id,log_time
from myth_server.server_accept_task
where day_time between ${activityBeginDate} and ${activityEndDate} 
and server_id in (${serverIds}) 
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and task_id in (150005,150006,150007,150008)
group by 1,2
) as g
on a.role_id = g.role_id
group by 1


-- left join
-- -- 任务完成人数
-- (select role_id,log_time
-- from myth_server.server_disclaim_reward
-- where day_time between ${activityBeginDate} and ${activityEndDate} 
-- and server_id in (${serverIds}) 
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and task_id in (150005,150006,150007,150008)
-- group by 1,2
-- ) h
-- on a.role_id = h.role_id
-- group by 1


-- left join
-- -- 完成任务领取道具人数
-- (select role_id,log_time
-- from myth_server.server_complete_task
-- where day_time between ${activityBeginDate} and ${activityEndDate} 
-- and server_id in (${serverIds}) 
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and task_id in (150005,150006,150007,150008)
-- group by 1,2
-- ) i
-- on a.role_id = i.role_id
-- group by 1


-- left join
-- -- 道具领取数量
-- (select role_id,log_time,change_count
-- from myth.server_prop
-- where day_time between ${activityBeginDate} and ${activityEndDate} 
-- and server_id in (${serverIds}) 
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and prop_id = '700848'
-- and change_type = 'PRODUCE'
-- group by 1,2,3
-- ) i2
-- on a.role_id = i2.role_id
-- group by 1


-- left join
-- -- 抽奖
-- (select role_id,log_time
-- from myth_server.server_lottery
-- where day_time between ${activityBeginDate} and ${activityEndDate} 
-- and server_id in (${serverIds})
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- group by 1,2
-- ) b
-- on a.role_id = b.role_id
-- group by 1
-- order by 1


-- left join
-- -- 可参与活动玩家
-- (SELECT role_id
-- from myth_server.server_accept_task
-- where day_time between ${activityBeginDate} and ${activityEndDate} 
-- and server_id in (${serverIds})
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and task_type = 12 -- 12 每日 13 活动
-- and task_id = 150001
-- GROUP BY 1  
-- ) c
-- on a.role_id = c.role_id
-- group by 1
-- order by 1


-- left join
-- -- 钻石消耗
-- (select role_id,change_count,log_time
-- from myth.server_currency
-- where day_time between ${activityBeginDate} and ${activityEndDate}  
-- and currency_id = '3'
-- and server_id in (${serverIds})
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and change_method = '154'
-- and change_type = 'CONSUME'
-- group by 1,2,3
-- ) d
-- on a.role_id = d.role_id
-- group by 1 order by 1


-- left join
-- -- 礼包购买
-- (select role_id,pay_price
-- from myth.order_pay
-- where day_time between ${activityBeginDate} and ${activityEndDate} 

-- and game_product_id in 
-- (
--  'com.managames.myththor.iap_1.99cblb2nd'
-- ,'com.managames.myththor.iap_9.99cblb2nd'
-- ,'com.managames.myththor.iap_29.99cblb2nd'
-- ,'com.managames.myththor.iap_99.99cblb2nd'
-- ,'com.managames.myththor.iap_0.99ltzyth'
-- ,'com.managames.myththor.iap_1.99ltzyth'
-- ,'com.managames.myththor.iap_2.99ltzyth'

-- )
-- ) e
-- on a.role_id = e.role_id
-- group by 1 order by 1


-- left join
-- -- 抽到大奖
-- (select f1.role_id,case when f2.role_id is null then '否' else '是' end as '是否购买礼包',change_count,pay_price
-- from

-- (select role_id
-- from myth_server.server_lottery
-- where day_time between ${activityBeginDate} and ${activityEndDate} 
-- and server_id in (${serverIds})
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')

-- and get_item_id = '700832'
-- group by 1
-- )f1
-- left join --是否买礼包
-- (select role_id,pay_price 
-- from myth.order_pay
-- where day_time between ${activityBeginDate} and ${activityEndDate} 

-- and game_product_id in 
-- (
--  'com.managames.myththor.iap_1.99cblb2nd'
-- ,'com.managames.myththor.iap_9.99cblb2nd'
-- ,'com.managames.myththor.iap_29.99cblb2nd'
-- ,'com.managames.myththor.iap_99.99cblb2nd'
-- ,'com.managames.myththor.iap_0.99ltzyth'
-- ,'com.managames.myththor.iap_1.99ltzyth'
-- ,'com.managames.myththor.iap_2.99ltzyth'
-- )
-- ) f2
-- on f1.role_id = f2.role_id

-- left join --钻石消耗
-- (select role_id,change_count,log_time
-- from myth.server_currency
-- where day_time between ${activityBeginDate} and ${activityEndDate}  
-- and currency_id = '3'
-- and server_id in (${serverIds})
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')

-- and change_method = '154'
-- and change_type = 'CONSUME'
-- group by 1,2,3
-- ) f3
-- on f1.role_id = f3.role_id
-- ) f 
-- on a.role_id = f.role_id  
-- group by 1 order by 1



-- 分任务后的抽取人数
-- select task_id,count(distinct b.role_id)
-- from
-- (select task_id,role_id,log_time
-- from myth_server.server_complete_task
-- where day_time between ${activityBeginDate} and ${activityEndDate} 
-- and server_id in (${serverIds}) 
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and task_id in (150005,150006,150007,150008)
-- group by 1,2,3
-- ) a
-- left join
-- (select role_id,log_time
-- from myth_server.server_lottery
-- where day_time between ${activityBeginDate} and ${activityEndDate} 
-- and server_id in (${serverIds})
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- group by 1,2
-- ) b
-- on a.role_id = b.role_id
-- group by 1 order by 1


-- 验证 -- 抽到大奖人数
-- select count(distinct role_id)
-- from myth.server_prop
-- where day_time between ${activityBeginDate} and ${activityEndDate} 
-- and server_id in (${serverIds}) 
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and prop_id = '700832'
-- and change_type = 'PRODUCE'





-- 战役层数停留
SELECT task_id,a.role_id,dungeon_id
from 
(SELECT day_time, task_id,role_id
from myth_server.server_accept_task
where server_id in (${serverIds})
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')

and task_type = 12 -- 12 每日 13 活动
and task_id in (150001,150002,150003,150004)
and day_time>=${beginDate} and day_time<=${endDate}
group by 1,2,3) a 
left join 
(
select role_id,case when max(dungeon_id) < 25 then '低于25' else '>+25' end as dungeon_id
from myth_server.server_dungeon_end 
where day_time=20230610 
and game_type= 3
and battle_result =1 
group by 1

) b 
on a.role_id=b.role_id 
GROUP BY 1,2,3







老王新加的数据需求
-- 活动期间的付费总额,总人数
select 
       -- sum(pay_price)
       count(distinct b.role_id)
from
(  --新增
select role_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
group by 1,2
)  a

left join
(
select role_id,pay_price,log_time
from myth.order_pay
where log_time>=1691748000000 and log_time <= 1692352800000 -- 活动期间付费
and server_id in (${serverIds}) 
group by 1,2,3) b 
on a.role_id =b.role_id


翅膀礼包破冰人数

-- 礼包购买
select count(distinct role_id)
from
(select role_id,game_product_id
from
(select role_id,game_product_id,row_number() over(partition by role_id order by log_time asc) as num
from myth.order_pay
where day_time >= ${beginDate}
and log_time < 1692352800000
and server_id in (${serverIds}) 
) a 
where num = 1
and game_product_id in 
(
 'com.managames.myththor.iap_1.99cblb2nd'
,'com.managames.myththor.iap_9.99cblb2nd'
,'com.managames.myththor.iap_29.99cblb2nd'
,'com.managames.myththor.iap_99.99cblb2nd'
,'com.managames.myththor.iap_0.99ltzyth'
,'com.managames.myththor.iap_1.99ltzyth'
,'com.managames.myththor.iap_2.99ltzyth'
)
) b 


购买礼包玩家活动期间总付费
select sum(pay_price)
from myth.order_pay
where log_time>=1691748000000 and log_time <= 1692352800000
and server_id in (${serverIds}) 
and role_id in 
(select role_id
from myth.order_pay
where day_time between ${activityBeginDate} and ${activityEndDate} 
and server_id in (${serverIds}) 
and game_product_id in 
(
 'com.managames.myththor.iap_1.99cblb2nd'
,'com.managames.myththor.iap_9.99cblb2nd'
,'com.managames.myththor.iap_29.99cblb2nd'
,'com.managames.myththor.iap_99.99cblb2nd'
,'com.managames.myththor.iap_0.99ltzyth'
,'com.managames.myththor.iap_1.99ltzyth'
,'com.managames.myththor.iap_2.99ltzyth'
)
group by 1
) 


验证 14人买礼包没抽奖
select a.role_id as '买礼包',b.role_id as '抽奖'
from
(select role_id
from myth.order_pay
where day_time between ${activityBeginDate} and ${activityEndDate} 
and server_id in (${serverIds}) 
and game_product_id in 
(
 'com.managames.myththor.iap_1.99cblb2nd'
,'com.managames.myththor.iap_9.99cblb2nd'
,'com.managames.myththor.iap_29.99cblb2nd'
,'com.managames.myththor.iap_99.99cblb2nd'
,'com.managames.myththor.iap_0.99ltzyth'
,'com.managames.myththor.iap_1.99ltzyth'
,'com.managames.myththor.iap_2.99ltzyth'
)
group by 1)

left join
(select role_id
from myth_server.server_lottery
where day_time between ${activityBeginDate} and ${activityEndDate} 
and server_id in (${serverIds})
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
group by 1
) b
on a.role_id = b.role_id
group by 1,2




奖励获取
select prop_id,count(distinct role_id),count(distinct log_time)
from myth.server_prop
where day_time between ${activityBeginDate} and ${activityEndDate} 
and server_id in (${serverIds}) 
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and prop_id in ('100530','100564','100531','100552','100049') 
and change_type = 'PRODUCE'
and change_method = '154'
and role_id in 
(select role_id
from myth.order_pay
where day_time between ${activityBeginDate} and ${activityEndDate} 
and server_id in (${serverIds}) 
and game_product_id in 
(
 'com.managames.myththor.iap_1.99cblb2nd'
,'com.managames.myththor.iap_9.99cblb2nd'
,'com.managames.myththor.iap_29.99cblb2nd'
,'com.managames.myththor.iap_99.99cblb2nd'
,'com.managames.myththor.iap_0.99ltzyth'
,'com.managames.myththor.iap_1.99ltzyth'
,'com.managames.myththor.iap_2.99ltzyth'
)
group by 1)
group by 1 order by 1





翅膀获得层数分布
select 
-- b.role_id,pay_or_not,turn_id,vip_level
b.role_id,turn_id,vip_level
from

-- -- 是否付费
-- (select a.role_id,case when b.role_id is null then '否' else '是' end as pay_or_not
-- from
-- (  --新增
-- select role_id,to_date(cast(date_time as timestamp)) as birth_dt
-- from myth.server_role_create 
-- where day_time>=${beginDate} and day_time<=${birthEndDate} 
-- and server_id in (${serverIds}) 
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- group by 1,2
-- )  a

-- left join
-- (
-- select role_id
-- from myth.order_pay
-- where log_time < 1692352800000 -- 活动结束前付费
-- and server_id in (${serverIds}) 
-- group by 1
-- ) b 
-- on a.role_id =b.role_id
-- group by 1,2
-- ) a 

(select role_id
from myth.order_pay
where day_time between ${activityBeginDate} and ${activityEndDate} 
and server_id in (${serverIds}) 
and game_product_id in 
(
 'com.managames.myththor.iap_1.99cblb2nd'
,'com.managames.myththor.iap_9.99cblb2nd'
,'com.managames.myththor.iap_29.99cblb2nd'
,'com.managames.myththor.iap_99.99cblb2nd'
,'com.managames.myththor.iap_0.99ltzyth'
,'com.managames.myththor.iap_1.99ltzyth'
,'com.managames.myththor.iap_2.99ltzyth'
)) a


left join
-- 翅膀获得
(select role_id,turn_id,vip_level
from myth_server.server_lottery
where day_time between ${activityBeginDate} and ${activityEndDate} 
and server_id in (${serverIds})
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and get_item_id = '700832'
group by 1,2,3
) b
on a.role_id = b.role_id
group by 1,2,3






层数停留
select 
-- b.role_id,pay_or_not,turn_id_max,vip_max
a.role_id,turn_id_max,vip_max
from

-- -- 是否付费
-- (select a.role_id,case when b.role_id is null then '否' else '是' end as pay_or_not
-- from
-- (  --新增
-- select role_id,to_date(cast(date_time as timestamp)) as birth_dt
-- from myth.server_role_create 
-- where day_time>=${beginDate} and day_time<=${birthEndDate} 
-- and server_id in (${serverIds}) 
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- group by 1,2
-- )  a

-- left join
-- (
-- select role_id
-- from myth.order_pay
-- where log_time < 1692352800000 -- 活动结束前付费
-- and server_id in (${serverIds}) 
-- group by 1
-- ) b 
-- on a.role_id =b.role_id
-- group by 1,2
-- ) a 
(select role_id
from myth.order_pay
where day_time between ${activityBeginDate} and ${activityEndDate} 
and server_id in (${serverIds}) 
and game_product_id in 
(
 'com.managames.myththor.iap_1.99cblb2nd'
,'com.managames.myththor.iap_9.99cblb2nd'
,'com.managames.myththor.iap_29.99cblb2nd'
,'com.managames.myththor.iap_99.99cblb2nd'
,'com.managames.myththor.iap_0.99ltzyth'
,'com.managames.myththor.iap_1.99ltzyth'
,'com.managames.myththor.iap_2.99ltzyth'
)) a


left join
-- 抽奖最后一层
(select b1.role_id,turn_id_max,vip_max
from
(select role_id,turn_id,max(vip_level) as vip_max
from myth_server.server_lottery
where day_time between ${activityBeginDate} and ${activityEndDate} 
and server_id in (${serverIds})
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
group by 1,2
) b1
left join
(select role_id,max(turn_id) as turn_id_max
from myth_server.server_lottery
where day_time between ${activityBeginDate} and ${activityEndDate} 
and server_id in (${serverIds})
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
group by 1
) b2
on b1.role_id = b2.role_id and b1.turn_id = b2.turn_id_max
group by 1,2,3
) b

on a.role_id = b.role_id
group by 1,2,3


礼包购买情况
select game_product_id,count(distinct role_id)
from myth.order_pay
where day_time between ${activityBeginDate} and ${activityEndDate} 
and server_id in (${serverIds}) 
and game_product_id in 
(
 'com.managames.myththor.iap_1.99cblb2nd'
,'com.managames.myththor.iap_9.99cblb2nd'
,'com.managames.myththor.iap_29.99cblb2nd'
,'com.managames.myththor.iap_99.99cblb2nd'
,'com.managames.myththor.iap_0.99ltzyth'
,'com.managames.myththor.iap_1.99ltzyth'
,'com.managames.myththor.iap_2.99ltzyth'
)
group by 1 order by 1