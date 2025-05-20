20001,20002,20003,20004,20005,20006,20007,20008,20009,20010,20011,20012,20013,20014,20015,20016,20017,20018,20019,20020,20021,20022,20023,20024,20025,20026


活动一：幸运666

开始 2023-6-9 10:00  结束 2023-6-16 10:00 1686276000000 - 1686880800000

select vip 
       -- ,count(distinct b.role_id) -- 任务接取
       -- ,count(distinct c.role_id) -- 任务完成
       -- ,count(distinct d.role_id) -- 道具获取人数
       -- ,sum(change_count) -- 道具获取数量
       ,count(distinct d.role_id) -- 道具消耗人数
       ,count(log_time) -- 道具消耗次数


from
-- 付费档位
(select birth_dt,role_id,
case when total_pay<=8                    then 1
     when total_pay>8  and total_pay<=70  then 2
     when total_pay>70                    then 3 
     else 0 
     end as vip --D7
from 
(select birth_dt,a.role_id
,sum(case when datediff(vip_dt,birth_dt)<=${lifeTime}-1  then pay else 0 end ) as 'total_pay'
from

(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id --and a1.birth_dt = a2.device_birth_dt
group by 1,2
)  a

left join
(
select role_id,to_date(cast(date_time as timestamp)) as vip_dt,sum(pay_price) pay 
from myth.order_pay
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
group by 1,2 ) b 
on a.role_id =b.role_id
group by 1,2
) a1 
) a 

-- left join
-- 任务接取
-- (select role_id
-- from myth_server.server_accept_task
-- where day_time between ${activityBeginDate} and ${activityEndDate} 
-- and server_id in (${serverIds})
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK') 
-- and task_type = 16 --老虎机
-- group by 1
-- ) b
-- on a.role_id = b.role_id
-- group by 1 order by 1


-- left join
-- 任务完成
-- (select role_id
-- from myth_server.server_complete_task
-- where day_time between ${activityBeginDate} and ${activityEndDate} 
-- and server_id in (${serverIds})
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK') 
-- and task_type = 16 --老虎机
-- group by 1
-- ) c
-- on a.role_id = c.role_id
-- group by 1 order by 1


left join
-- 道具获取 消耗
(select role_id,change_count,log_time
from myth.server_prop
where day_time between ${activityBeginDate} and ${activityEndDate}  
and server_id in (${serverIds})
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
and change_method = '163' --163 5
and change_type = 'CONSUME' --PRODUCE
and prop_id = '700833'
group by 1,2,3
) d
on a.role_id = d.role_id
group by 1 order by 1






任务完成
select day_time,task_id,count(distinct role_id)
from myth_server.server_activity_task_completed
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK') 
and activity_id = 2 --老虎机
group by 1,2
order by 1,2

参与
select count(distinct role_id)
from myth_server.server_activity_task_completed
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK') 
and activity_id = 2 --老虎机








活动二：翅膀抽奖
开始 2023-8-11 10:00  结束 2023-8-17 10:00 1691719200000 - 1692237600000

select vip
       ,count(distinct g.role_id) as '任务接取人数'
       ,count(distinct h.role_id) as '任务完成人数'
       ,count(distinct i.role_id) as '道具领取人数'
       ,sum(change_count) as '道具获取数量'
       -- ,count(distinct b.role_id) as '抽取人数'
       -- ,count(log_time) as '抽取次数'
       -- ,count(distinct c.role_id) as '可参与人数'
       -- ,count(distinct d.role_id) as '钻石消耗人数'
       -- ,round(sum(change_count) / count(distinct d.role_id),2) as '人均钻石消耗数'
       -- ,count(distinct e.role_id) as '礼包购买人数'
       -- ,round(sum(pay_price)/count(distinct e.role_id),2) as '礼包购买人均金额'
       ,count(distinct case when 是否购买礼包 = '否' then f.role_id else null end) as '未付费抽到大奖人数'
       ,round(sum(case when 是否购买礼包 = '否' then change_count else 0 end) / count(distinct case when 是否购买礼包 = '否' then f.role_id else null end),2) as '未付费抽到大奖人均钻石消耗'
       ,count(distinct case when 是否购买礼包 = '是' then f.role_id else null end) as '付费抽到大奖人数'
       ,round(sum(case when 是否购买礼包 = '是' then change_count else 0 end) / count(distinct case when 是否购买礼包 = '是' then f.role_id else null end),2) as '付费抽到大奖人均钻石消耗'
       ,round(sum(case when 是否购买礼包 = '是' then pay_price else 0 end) / count(distinct case when 是否购买礼包 = '是' then f.role_id else null end),2) as '付费抽到大奖人均付费金额'

from


-- 付费档位
(select birth_dt,role_id,
case when total_pay<=8                    then 1
     when total_pay>8  and total_pay<=70  then 2
     when total_pay>70                    then 3 
     else 0 
     end as vip --D7
from 
(select birth_dt,a.role_id
,sum(case when datediff(vip_dt,birth_dt)<=${lifeTime}-1  then pay else 0 end ) as 'total_pay'
from

(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id --and a1.birth_dt = a2.device_birth_dt
group by 1,2
)  a

left join
(
select role_id,to_date(cast(date_time as timestamp)) as vip_dt,sum(pay_price) pay 
from myth.order_pay
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
group by 1,2 ) b 
on a.role_id =b.role_id
group by 1,2
) a1 
) a 


-- left join
-- -- 任务接取人数
-- (select role_id,log_time
-- from myth_server.server_accept_task
-- where day_time between ${activityBeginDate} and ${activityEndDate} 
-- and server_id in (${serverIds}) 
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
-- and task_id in (150005,150006,150007,150008)
-- group 1,2
-- ) as g
-- on a.role_id = g.role_id


-- left join
-- -- 任务完成人数
-- (select role_id,log_time
-- from myth_server.server_disclaim_reward
-- where day_time between ${activityBeginDate} and ${activityEndDate} 
-- and server_id in (${serverIds}) 
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
-- and task_id in (150005,150006,150007,150008)
-- group 1,2
-- ) as h
-- on a.role_id = h.role_id


-- left join
-- -- 道具领取人数、数量
-- (select i1.role_id,change_count
-- from
-- (select role_id,log_time
-- from myth_server.server_complete_task
-- where day_time between ${activityBeginDate} and ${activityEndDate} 
-- and server_id in (${serverIds}) 
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
-- and task_id in (150005,150006,150007,150008)
-- group 1,2
-- ) as i1
-- left join
-- (select role_id,log_time,change_count
-- from myth.server_prop
-- where day_time between ${activityBeginDate} and ${activityEndDate} 
-- and server_id in (${serverIds}) 
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
-- and prop_id = '700809'
-- and change_type = 'PRODUCE'
-- group by 1,2,3
-- ) i2
-- on i1.role_id = i2.role_id
-- ) i
-- on a.role_id = i.role_id


left join
-- 抽奖
(select role_id,log_time
from myth_server.server_lottery
where day_time between ${activityBeginDate} and ${activityEndDate} 
and server_id in (${serverIds})
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
group by 1,2
) b
on a.role_id = b.role_id
group by 1
order by 1


-- left join
-- -- 可参与活动玩家
-- (SELECT role_id
-- from myth_server.server_accept_task
-- where day_time between ${activityBeginDate} and ${activityEndDate} 
-- and server_id in (${serverIds})
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
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
-- and country not in ('CN','HK')
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
-- and country not in ('CN','HK')
-- and game_product_id in 
-- (
--  'com.managames.myththor.iap_0.99yszsjhlb'
-- ,'com.managames.myththor.iap_4.99yszsjhlb'
-- ,'com.managames.myththor.iap_9.99yszsjhlb'
-- ,'com.managames.myththor.iap_19.99yszsjhlb'
-- ,'com.managames.myththor.iap_49.99yszsjhlb'
-- ,'com.managames.myththor.iap_99.99yszsjhlb'

-- )
-- ) e
-- on a.role_id = e.role_id
-- group by 1 order by 1


left join
-- 抽到大奖
(select f1.role_id,case when f2.role_id is null then '否' else '是' end as '是否购买礼包',change_count,pay_price
from

(select role_id
from myth_server.server_lottery
where day_time between ${activityBeginDate} and ${activityEndDate} 
and server_id in (${serverIds})
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
and get_item_id = '700832'
group by 1
)f1
left join --是否买礼包
(select role_id,pay_price 
from myth.order_pay
where day_time between ${activityBeginDate} and ${activityEndDate} 
and country not in ('CN','HK')
and game_product_id in 
(
 'com.managames.myththor.iap_0.99yszsjhlb'
,'com.managames.myththor.iap_4.99yszsjhlb'
,'com.managames.myththor.iap_9.99yszsjhlb'
,'com.managames.myththor.iap_19.99yszsjhlb'
,'com.managames.myththor.iap_49.99yszsjhlb'
,'com.managames.myththor.iap_99.99yszsjhlb'
)
) f2
on f1.role_id = f2.role_id

left join --钻石消耗
(select role_id,change_count,log_time
from myth.server_currency
where day_time between ${activityBeginDate} and ${activityEndDate}  
and currency_id = '3'
and server_id in (${serverIds})
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
and change_method = '154'
and change_type = 'CONSUME'
group by 1,2,3
) f3
on f1.role_id = f3.role_id
) f 
on a.role_id = f.role_id  
group by 1 order by 1





层数分布
select pay_or_not,turn_id,count(distinct b.role_id)
from
-- 是否付费
(select birth_dt,a.role_id,case when b.role_id is null then '否' else '是' end as pay_or_not
from

(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id --and a1.birth_dt = a2.device_birth_dt
group by 1,2
)  a

left join
(
select role_id
from myth.order_pay
where log_time < 1686880800000 -- 活动结束前付费
and country not in ('CN','HK')
group by 1) b 
on a.role_id =b.role_id
group by 1,2,3
) a 


left join
-- 抽奖
(select role_id,turn_id
from myth_server.server_lottery
where day_time between ${activityBeginDate} and ${activityEndDate} 
and server_id in (${serverIds})
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
group by 1,2
) b
on a.role_id = b.role_id
group by 1,2
order by 1,2


-- 战役层数停留
SELECT task_id,a.role_id,dungeon_id
from 
(SELECT day_time, task_id,role_id
from myth_server.server_accept_task
where server_id in (${serverIds})
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
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







活动三：兑换活动

任务
SELECT task_id,count(DISTINCT role_id)
from myth_server.server_accept_task
where day_time between ${activityBeginDate} and ${activityEndDate} 
and server_id in (${serverIds})
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
and task_type = 13 -- 12 每日 13 活动
GROUP BY 1         
ORDER BY 1

SELECT task_id,count(DISTINCT role_id)
from myth_server.server_complete_task
where day_time between ${activityBeginDate} and ${activityEndDate} 
and server_id in (${serverIds})
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
and task_type = 13 -- 12 每日 13 活动
GROUP BY 1         
ORDER BY 1


道具获取
select prop_id,count(distinct role_id),count(log_time)
from myth.server_prop
where day_time between ${activityBeginDate} and ${activityEndDate}  
and server_id in (${serverIds})
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
and change_method = '150'
and change_type = 'PRODUCE'
and prop_id in 
(
'100796','100557','100788','100790','100792','100794','700805','500101',
'100502','100531','100564','100530','100335','100122','100524','100523',
'100083','100062','100517','100518','100525','100532','100559','100558','100015'
)
group by 1 order by 1



礼包购买
select game_product_id,count(distinct role_id),count(distinct log_time),sum(pay_price)
from myth.order_pay
where day_time between ${activityBeginDate} and ${activityEndDate} 
and country not in ('CN','HK')
and game_product_id in 
(
'com.managames.myththor.iap_0.99flyyxlb'
,'com.managames.myththor.iap_4.99flyyxlb'
,'com.managames.myththor.iap_9.99flyyxlb'
,'com.managames.myththor.iap_19.99flyyxlb'
,'com.managames.myththor.iap_49.99flyyxlb'
,'com.managames.myththor.iap_99.99flyyxlb1'
,'com.managames.myththor.iap_99.99flyyxlb2'
,'com.managames.myththor.iap_99.99flyyxlb3'
)
group by 1



付费档位
select vip
       ,count(distinct e.role_id) as '礼包购买人数'
       ,round(sum(pay_price)/count(distinct e.role_id),2) as '礼包购买人均金额'
from
-- 付费档位
(select birth_dt,role_id,
case when total_pay<=8                    then 1
     when total_pay>8  and total_pay<=71  then 2
     when total_pay>71                    then 3 
     else 0 
     end as vip --D7
from 
(select birth_dt,a.role_id
,sum(case when datediff(vip_dt,birth_dt)<=${lifeTime}-1  then pay else 0 end ) as 'total_pay'
from

(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id --and a1.birth_dt = a2.device_birth_dt
group by 1,2
)  a

left join
(
select role_id,to_date(cast(date_time as timestamp)) as vip_dt,sum(pay_price) pay 
from myth.order_pay
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
group by 1,2 ) b 
on a.role_id =b.role_id
group by 1,2
) a1 
) a 

left join
-- 礼包购买
(select role_id,pay_price
from myth.order_pay
where day_time between ${activityBeginDate} and ${activityEndDate} 
and country not in ('CN','HK')
and game_product_id in 
(
'com.managames.myththor.iap_0.99flyyxlb'
,'com.managames.myththor.iap_4.99flyyxlb'
,'com.managames.myththor.iap_9.99flyyxlb'
,'com.managames.myththor.iap_19.99flyyxlb'
,'com.managames.myththor.iap_49.99flyyxlb'
,'com.managames.myththor.iap_99.99flyyxlb1'
,'com.managames.myththor.iap_99.99flyyxlb2'
,'com.managames.myththor.iap_99.99flyyxlb3'
)
) e
on a.role_id = e.role_id
group by 1 order by 1




活动三：拼图活动

任务完成
select day_time,task_id,count(distinct role_id)
from myth_server.server_activity_task_completed
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK') 
and activity_id = 1 --拼图
group by 1,2
order by 1,2





周期UP活动
6.3-6.4地精
select day_time,
       round(count(start_time) / count(distinct role_id),2)
from
(select dungeon_id,role_id,start_time,day_time -- start_time也可用统计参与次数
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 7 -- 7->地精宝库
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
-- and role_level >= 24
group by 1,2,3,4
union all
select dungeon_id,role_id,log_time as start_time,day_time -- log_time也可用统计参与次数
from myth_server.server_dungeon_blitz
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 7 -- 7->地精宝库
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
group by 1,2,3,4
) a
group by 1 order by 1




分天参与率
select a.day_time, count(distinct b.role_id)
from
(select role_id,day_time
from myth.server_role_login -- 活跃
where day_time>=${beginDate} and day_time<=${endDate}
and server_id in (${serverIds})
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
and device_id in (select distinct device_id from myth.device_activate where day_time>=${beginDate} and day_time<=${birthEndDate})
) as a 

left join --  关联此表 可参与人数
(select role_id,day_time
from myth_server.server_dungeon_end
where day_time>=${beginDate} and day_time<=${endDate}
and server_id in (${serverIds})
and game_type =3 
and battle_result = 1
and dungeon_id = 10  --地精宝库完成2-3（10）
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) b
on a.role_id = b.role_id and b.day_time <=a.day_time
group by 1 order by 1



当天参与
-- 地精宝库要合并 正常进入关卡的  和 直接扫荡的玩家
select day_time, count(distinct role_id)
from
(select day_time, role_id
from myth_server.server_enter_dungeon
where day_time>=${beginDate} and day_time<=${endDate}
and server_id in (${serverIds})
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
and game_type = 7
and device_id in (select distinct device_id from myth.device_activate where day_time>=${beginDate} and day_time<=${birthEndDate} and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK'))
union all
select day_time, role_id
from myth_server.server_dungeon_blitz
where day_time>=${beginDate} and day_time<=${endDate}
and server_id in (${serverIds})
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
and game_type = 7
and device_id in (select distinct device_id from myth.device_activate where day_time>=${beginDate} and day_time<=${birthEndDate} and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK'))
) as b
group by 1 order by 1







时间庭院
select a.day_time as '日期'
       ,count(distinct a.role_id) as '参与人数'
       ,round(sum(num)/count(distinct a.role_id),2) as '人均参与次数'
from
( -- 参与春之庭院的玩家  有领取挂机奖励的日志
select role_id,day_time,count(distinct log_time) as num
from myth_server.server_quicken_hang
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
group by 1,2
) a
group by 1 order by 1




分天参与率
select a.day_time, count(distinct b.role_id)
from
(select role_id,day_time
from myth.server_role_login -- 活跃
where day_time>=${beginDate} and day_time<=${endDate}
and server_id in (${serverIds})
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
and device_id in (select distinct device_id from myth.device_activate where day_time>=${beginDate} and day_time<=${birthEndDate})
) as a 

left join --  关联此表 可参与人数
(select role_id,day_time
from myth_server.server_dungeon_end
where day_time>=${beginDate} and day_time<=${endDate}
and server_id in (${serverIds})
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
and game_type =3 
and battle_result = 1
and dungeon_id = 19 --快速挂机 
) b
on a.role_id = b.role_id and b.day_time<=a.day_time
group by 1
order by 1


当天参与
select day_time, count(distinct role_id)
from myth_server.server_quicken_hang
where day_time>=${beginDate} and day_time<=${endDate}
and server_id in (${serverIds})
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
and device_id in (select distinct device_id from myth.device_activate where day_time >= ${beginDate} and day_time <= ${birthEndDate} and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK'))
group by 1 order by 1







信徒心愿
select day_time
       ,round(sum(num)/count(distinct a.role_id),2) as '人均参与次数'
from

-- 参与信徒心愿的玩家  消耗心愿值大于0
(select role_id,day_time,believer_id_list,count(distinct log_time) as num
from myth_server.server_bless_believer
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
and consume_believer > 0
group by 1,2,3
) a
group by 1
order by 1





信徒心愿日参与率

select a.day_time, count(distinct b.role_id)
from
(select role_id,day_time
from myth.server_role_login -- 活跃
where day_time>=${beginDate} and day_time<=${endDate}
and server_id in (${serverIds}) 
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
and device_id in (select distinct device_id from myth.device_activate where day_time>=${beginDate} and day_time<=${birthEndDate})
) as a 

left join --  关联此表 可参与人数
(select role_id,day_time
from myth_server.server_dungeon_end
where day_time>=${beginDate} and day_time<=${endDate}
and server_id in (${serverIds}) 
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
and game_type =3 
and battle_result = 1
and dungeon_id = 23
) b
on a.role_id = b.role_id and b.day_time<=a.day_time
group by 1 order by 1


分天参与
select day_time, count(distinct role_id)
from
(select role_id,consume_believer,day_time
from myth_server.server_bless_believer
where day_time>=${beginDate} and day_time<=${endDate}
and server_id in (${serverIds}) 
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
and device_id in (select distinct device_id from myth.device_activate where day_time>=${beginDate} and day_time<=${birthEndDate} and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK'))
) b1
where consume_believer > 0
group by 1 order by 1




















付费用户前50的购买商店物品的list  
6月3日至6月24日18点前的所有新增  的付费用户前50

select role_id,game_product_id,product_name,count(distinct log_time) as '购买数量'
from myth.order_pay
where day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and role_id in 
('2201200000000003679',
'2201200000000002884',
'2201400000000000786',
'2201300000000002021',
'2201400000000000670',
'2201100000000002687',
'2201400000000006801',
'2201300000000003110',
'2201100000000005095',
'2201200000000000508',
'2201400000000004320',
'2201200000000000064',
'2201400000000000317',
'2200200000000000103',
'2200900000000001244',
'2201200000000002039',
'2201300000000002601',
'2201200000000003669',
'2201100000000002651',
'2201400000000000118',
'2201100000000000429',
'2201100000000000849')
group by 1,2,3






购买商铺的物品
select role_id,get_prop_id,cost_currency_id,sum(cast(get_prop_num as int)) as '购买数量',sum(cost_currency_num) as '消耗货币数量'
from myth_server.server_mall_buy
where day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and mall_type = 1 -- 商铺

and role_id in 
('2201200000000003679',
'2201200000000002884',
'2201400000000000786',
'2201300000000002021',
'2201400000000000670',
'2201100000000002687',
'2201400000000006801',
'2201300000000003110',
'2201100000000005095',
'2201200000000000508',
'2201400000000004320',
'2201200000000000064',
'2201400000000000317',
'2200200000000000103',
'2200900000000001244',
'2201200000000002039',
'2201300000000002601',
'2201200000000003669',
'2201100000000002651',
'2201400000000000118',
'2201100000000000429',
'2201100000000000849')
group by 1,2,3




select role_id,get_prop_id,sum(cast(get_prop_num as int)) as '购买数量'
from myth_server.server_mall_buy
where day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and mall_type = 1 -- 商铺

and role_id in 
('2201200000000003679',
'2201200000000002884',
'2201400000000000786',
'2201300000000002021',
'2201400000000000670',
'2201100000000002687',
'2201400000000006801',
'2201300000000003110',
'2201100000000005095',
'2201200000000000508',
'2201400000000004320',
'2201200000000000064',
'2201400000000000317',
'2200200000000000103',
'2200900000000001244',
'2201200000000002039',
'2201300000000002601',
'2201200000000003669',
'2201100000000002651',
'2201400000000000118',
'2201100000000000429',
'2201100000000000849')
group by 1,2

'100517','100558','100522','100559','100532','100503','100530',
'100564','100020','100019','100216','100061','100504','100552',
'100083','100017','100025','100035'






购买神秘商人的物品
select role_id,get_prop_id,sum(cast(get_prop_num as int)) as '购买数量'
from myth_server.server_mall_buy
where day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and mall_type = 13

and role_id in 
('2201200000000003679',
'2201200000000002884',
'2201400000000000786',
'2201300000000002021',
'2201400000000000670',
'2201100000000002687',
'2201400000000006801',
'2201300000000003110',
'2201100000000005095',
'2201200000000000508',
'2201400000000004320',
'2201200000000000064',
'2201400000000000317',
'2200200000000000103',
'2200900000000001244',
'2201200000000002039',
'2201300000000002601',
'2201200000000003669',
'2201100000000002651',
'2201400000000000118',
'2201100000000000429',
'2201100000000000849')
group by 1,2





以上道具存量数据


select role_id,sum(diamond) as '钻石存量',sum(gold) as '金币存量',sum(divine_crystal) as '神力结晶存量',sum(mine_dust) as '宝石粉尘存量',sum(hell_ghost) as '地狱幽魂存量'
              ,sum(guild_coin) as '公会币存量',sum(guild_war_coin) as '公会战代币存量'
from
(select role_id,diamond,gold,divine_crystal,mine_dust,hell_ghost,guild_coin,guild_war_coin,row_number() over(partition by role_id order by log_time desc) as num
from myth_server.server_login_snapshot
where day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')

and role_id in 
('2201200000000003679',
'2201200000000002884',
'2201400000000000786',
'2201300000000002021',
'2201400000000000670',
'2201100000000002687',
'2201400000000006801',
'2201300000000003110',
'2201100000000005095',
'2201200000000000508',
'2201400000000004320',
'2201200000000000064',
'2201400000000000317',
'2200200000000000103',
'2200900000000001244',
'2201200000000002039',
'2201300000000002601',
'2201200000000003669',
'2201100000000002651',
'2201400000000000118',
'2201100000000000429',
'2201100000000000849')
) as a 
where num = 1
group by 1



货币



select role_id,currency_id
       ,sum(case when change_type = 'PRODUCE' then change_count else 0 end) as '获取'
       ,sum(case when change_type = 'CONSUME' then change_count else 0 end) as '消耗'

from myth.server_currency
where day_time >= ${start_time} and day_time <= ${end_time}
and server_id in (${serverIds}) 
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
and currency_id in ('3','8','9','14','18','11','12','16','17','22','13','23')
and role_id in 
('2201200000000003679',
'2201200000000002884',
'2201400000000000786',
'2201300000000002021',
'2201400000000000670',
'2201100000000002687',
'2201300000000003110',
'2201100000000005095',
'2201200000000000508',
'2201400000000004320',
'2201200000000000064',
'2201400000000000317',
'2201200000000002039',
'2201300000000002601',
'2201200000000003669',
'2201100000000002651',
'2201400000000000118',
'2201100000000000429',
'2201100000000000849')
group by 1,2
order by 1,2





道具
select role_id,prop_id
       ,sum(case when change_type = 'PRODUCE' then change_count else 0 end) as '获取'
       ,sum(case when change_type = 'CONSUME' then change_count else 0 end) as '消耗'

from myth.server_prop
where day_time >= ${start_time} and day_time <= ${end_time}
and server_id in (${serverIds}) 
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
and prop_id in (
'100517','100003','100004','100518','100006','100525','100558','100559','100521','100522',
'100523','100526','100527','100528','100785','100786','100787','100561','100562','100563',
'100524','100532','100535','100530','100564','100531','100519','100015','100016','100017',
'100018','100019','100020','100021','100022','100023','100024','100025','100031','100032',
'100033','100034','100035','100121','100122','100334','100335')
and role_id in 
('2201200000000003679',
'2201200000000002884',
'2201400000000000786',
'2201300000000002021',
'2201400000000000670',
'2201100000000002687',
'2201400000000006801',
'2201300000000003110',
'2201100000000005095',
'2201200000000000508',
'2201400000000004320',
'2201200000000000064',
'2201400000000000317',
'2200200000000000103',
'2200900000000001244',
'2201200000000002039',
'2201300000000002601',
'2201200000000003669',
'2201100000000002651',
'2201400000000000118',
'2201100000000000429',
'2201100000000000849')
group by 1,2
order by 1,2






快速通关


select game_type,dungeon_id,count(distinct b.role_id)
from
(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id --and a1.birth_dt = a2.device_birth_dt
group by 1,2
)  a

left join
(select role_id,game_type,dungeon_id
from myth_server.server_fast_pass
where day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
group by 1,2,3
) b 
on a.role_id = b.role_id
group by 1,2
order by 1,2

