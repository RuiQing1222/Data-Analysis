--------------------------------------------------------------------------------------------------------------------------------------------------------------------
宝石矿坑
玩法——14->宝石矿坑

宝石矿坑挖矿(旷工ID)
-- 挖矿方式(矿工ID)    挖矿人数   挖矿次数   人均挖矿次数 消耗金币人数 消耗金币次数 消耗钻石人数 消耗钻石次数
-- 1                                                
-- 2                                                
-- 3                                                
-- 4                                                
-- 5       
select mine_id as '挖矿方式(矿工ID)'
       ,count(distinct b.role_id) as '挖矿人数'
       ,count(log_time) as '挖矿次数'
       ,round(count(log_time)/count(distinct b.role_id),2) as '人均挖矿次数'
       ,count(distinct case when consume_currency_id=8 then b.role_id else null end) as '消耗金币人数'
       ,count(distinct case when consume_currency_id=8 then log_time else null end) as '消耗金币次数'
       ,count(distinct case when consume_currency_id=3 then b.role_id else null end) as '消耗钻石人数'
       ,count(distinct case when consume_currency_id=3 then log_time else null end) as '消耗钻石次数'
from

(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
group by 1,2
)as a

left join 
-- 挖矿数据
(select role_id,to_date(cast(date_time as timestamp)) as done_dt,log_time,mine_id,consume_currency_id,consume_currency_num
from myth_server.server_gem_mine_start
where  day_time between ${beginDate} and ${lifeCycleEndDate} and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and consume_currency_id in (3,8) --钻石、金币
group by 1,2,3,4,5,6
) b
on a.role_id = b.role_id
where datediff(b.done_dt,a.birth_dt) = ${lifeCycle}
group by 1
order by 1




宝石矿坑副本 生命周期
-- 层数   进入关卡人数 通关率 中途退出率
-- 1                           
-- 2                           
-- 3                           
-- 4                           
-- 5                           
-- 6                           
-- 7                           
select dungeon_id as '层数'
       ,count(distinct b.role_id) as '进入关卡人数'
       ,round((count(distinct case when battle_result = 1 then b.role_id else null end)/count(distinct b.role_id))*100,2) as '通关率'
       ,round((count(case when 是否退出 = 'yes' then start_time else null end)/count(start_time))*100,2) as '中途退出率'
from
(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
group by 1,2
)as a

left join
-- 进入关卡人数 通关率 中途退出率
(select a.dungeon_id,a.role_id,a.start_time,done_dt,battle_result,case when battle_result is null then 'yes' else 'no' end as '是否退出'
from 
(select dungeon_id,role_id,start_time,to_date(cast(date_time as timestamp)) as done_dt -- start_time也可用统计参与次数
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${lifeCycleEndDate} and server_id in (${serverIds})
and game_type = 14 -- 14->宝石矿坑
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3,4
) as a
left join     
(select dungeon_id,role_id,start_time,battle_result
from myth_server.server_dungeon_end
where day_time between ${beginDate} and ${lifeCycleEndDate} and server_id in (${serverIds})
and game_type = 14 -- 14->宝石矿坑
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3,4
) b 
on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time=b.start_time 
group by 1,2,3,4,5,6
order by a.role_id,a.start_time asc 
) as b 
on a.role_id = b.role_id
where datediff(b.done_dt,a.birth_dt) = ${lifeCycle}
group by 1
order by 1

