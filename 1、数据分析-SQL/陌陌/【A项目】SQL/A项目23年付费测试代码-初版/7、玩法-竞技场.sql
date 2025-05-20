玩法系统数据分析  

玩法——4->竞技场
PVP活跃天数 计算参与人数、次数，中途退出、通关、未通关、自动战斗、手动战斗等

select a.role_id,cycle_id,start_time,auto_battle,fighting_result,duration,积分
from
( -- 参与竞技场的玩家  若fighting_result为空则是无日志
select a1.role_id as role_id,fighting_result,auto_battle,a1.start_time as start_time,cycle_id,
       case when (end_time-a.start_time)/60000 is null then '无日志'
            when (end_time-a.start_time)/60000 > 3  then '1超时'
            when (end_time-a.start_time)/60000 > 2 and (end_time-a.start_time)/60000 <= 3  then '2困难'
            when (end_time-a.start_time)/60000 > 1 and (end_time-a.start_time)/60000 <= 2  then '3较难'
            when (end_time-a.start_time)/60000 > 0 and (end_time-a.start_time)/60000 <= 1  then '4一般'
            else '无日志'
       end as duration
from
(select role_id,start_time,cycle_id
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 4
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3
) a1
left join
(select role_id,start_time,fighting_result,auto_battle,cycle_id,log_time as end_time
from myth_server.server_arena
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')     
group by 1,2,3,4,5,6
) a2
on b1.role_id = b2.role_id and b1.start_time = b2.start_time and b1.cycle_id = b2.cycle_id
group by 1,2,3,4,5,6
) a

left join -- 积分分布
(select role_id,case when change_count >=0 and change_count <1000 then '[0,1000)'
                    when change_count >=0 and change_count <1000 then '[0,1000)'
                    when change_count >=0 and change_count <1000 then '[0,1000)'
                    when change_count >=0 and change_count <1000 then '[0,1000)'
                    when change_count >=0 and change_count <1000 then '[0,1000)' -- 积分分段也要等和策划对
                    end as '积分'
from
(SELECT role_id,sum(change_count) as change_count
FROM myth.server_prop
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
and prop_id = '3' -- 竞技场积分道具，要和策划要
AND change_type = 'PRODUCE'
and change_method = '51' --竞技场获取方式，要和策划确定是哪一个
group by 1
) as b1
group by 1,2
) as b
on a.role_id = b.role_id
group by 1,2,3,4,5,6,7



天复玩率
整体 -- 复玩率
select 积分,count(distinct a.role_id) as '进入总人数',count(distinct case when 是否复玩 = '是' then a.role_id else null) as '复玩人数'
from

(select cycle_id,role_id,case when a2.role_id is null then '否' else '是' end as '是否复玩'
from
(select role_id,cycle_id,to_date(cast(date_time as timestamp)) as done_dt
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 4 -- 4->竞技场
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3
) as a1
left join
(select role_id,cycle_id,to_date(cast(date_time as timestamp)) as done_dt
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 4 -- 4->竞技场
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3
) as a2
on a1.role_id = a2.role_id and datediff(a2.done_dt,a1.done_dt)=1
group by 1,2,3
) as a

left join -- 积分分布
(select role_id,case when change_count >=0 and change_count <1000 then '[0,1000)'
                    when change_count >=0 and change_count <1000 then '[0,1000)'
                    when change_count >=0 and change_count <1000 then '[0,1000)'
                    when change_count >=0 and change_count <1000 then '[0,1000)'
                    when change_count >=0 and change_count <1000 then '[0,1000)' -- 积分分段也要等和策划对
                    end as '积分'
from
(SELECT role_id,sum(change_count) as change_count
FROM myth.server_prop
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
and prop_id = '3' -- 竞技场积分道具，要和策划要
AND change_type = 'PRODUCE'
and change_method = '51' --竞技场获取方式，要和策划确定是哪一个
group by 1
) as b1
group by 1,2
) as b
on a.role_id = b.role_id
group by 1
order by 1



整体的钻石 消耗人数、次数
select 积分,count(distinct a.role_id) as '钻石消耗人数',sum(change_num) as '钻石消耗次数',sum(change_count) as '钻石消耗总数'
from
(SELECT role_id,count(log_time) as change_num,sum(change_count) as change_count
FROM myth.server_currency
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
and currency_id = '3'
AND change_type = 'CONSUME'
and change_method = '50'
group by 1,2
) as a

left join -- 积分分布
(select role_id,case when change_count >=0 and change_count <1000 then '[0,1000)'
                    when change_count >=0 and change_count <1000 then '[0,1000)'
                    when change_count >=0 and change_count <1000 then '[0,1000)'
                    when change_count >=0 and change_count <1000 then '[0,1000)'
                    when change_count >=0 and change_count <1000 then '[0,1000)' -- 积分分段也要等和策划对
                    end as '积分'
from
(SELECT role_id,sum(change_count) as change_count
FROM myth.server_prop
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
and prop_id = '3' -- 竞技场积分道具，要和策划要
AND change_type = 'PRODUCE'
and change_method = '51' --竞技场获取方式，要和策划确定是哪一个
group by 1
) as b1
group by 1,2
) as b
on a.role_id = b.role_id
group by 1
order by 1






位置选择
select def_role_pos,付费档位,sum(选择次数) as '总选择次数',round(count(case when fighting_result=1 then 1 else null end)/count(1)*100,0) as '胜率'
from

(
select role_id,cycle_id,def_role_pos,start_time,fighting_result
from
( -- 参与竞技场的玩家  若fighting_result为空则是无日志
select c1.role_id,c1.cycle_id,c1.start_time,def_role_pos,fighting_result
from
(select role_id,start_time,cycle_id
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 4
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3
) c1
left join
(select role_id,start_time,cycle_id,fighting_result,def_role_pos
from myth_server.server_arena
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')   
group by 1,2,3,4,5  
) c2
on c1.role_id = c2.role_id and c1.cycle_id = c2.cycle_id and c1.start_time = c2.start_time
group by 1,2,3,4,5
) c3
group by 1,2,3,4,5
) c

left join
(select role_id,
       -- 周期14天
       case when sum_pay = 0 then '零氪'
            when sum_pay > 0 and sum_pay <= 78 then '小R'
            when sum_pay > 78 and sum_pay <= 628 then '中R'
            when sum_pay > 628 and sum_pay <= 1182 then '大R'
            else 'others'
            end as '付费档位'
from
(select role_id,to_date(cast(date_time as timestamp)) as pay_dt,sum(pay_price) as sum_pay
from myth.order_pay
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and country not in ('CN','HK')
group by 1,2
) d1
group by 1,2
) d
on c.role_id = d.role_id
group by 1,2