--------------------------------------------------------------------------------------------------------------------------------------------------------------------
命运殿堂
select a.类型,参与人数,人均参与次数,免费刷新人数,钻石刷新人数,钻石刷新次数,天复玩率
from
(select case when wish_mode = 1 then '3紫金' -- 参与人数
            when wish_mode = 2 then '1白银'
            when wish_mode = 3 then '2黄金'
       end as '类型'
            ,count(distinct role_id) as '参与人数'
            ,sum(num) as '参与次数'
            ,round(sum(num)/count(distinct role_id),2) as '人均参与次数'
from
(select role_id,wish_mode,count(distinct log_time) as num
from myth_server.server_wish_room
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and consume_prop_num > 0
group by 1,2
) b
group by 1
order by 1
) as a

left join -- 免费刷新
(SELECT case when sys_type = 2 then '1白银'
            when sys_type = 3 then '2黄金'
            when sys_type = 4 then '3紫金'
       end as '类型',count(distinct role_id) as '免费刷新人数'
FROM myth_server.server_click_believer
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and sys_type in (2,3,4) -- 免费刷新 2=命运殿堂白银 3=命运殿堂黄金 4=命运殿堂紫金
group by 1 
order by 1
) as b  
on a.类型 = b.类型

left join -- 钻石刷新
(select case when wish_mode = 1 then '3紫金'
            when wish_mode = 2 then '1白银'
            when wish_mode = 3 then '2黄金'
       end as '类型'
       ,count(distinct case when change_count >0 then b.role_id else NULL end) '钻石刷新人数'
       ,sum(case when change_count >0 then b.num else 0 end) '钻石刷新次数'
from

(select role_id,wish_mode
from myth_server.server_wish_room
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and consume_prop_num > 0
group by 1,2
) a

left join
(SELECT role_id,change_count,count(distinct log_time) as num 
FROM myth.server_currency
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and currency_id = '3'
AND change_type = 'CONSUME'
and change_method = '67' -- 刷新命运殿堂
group by 1,2
) as b
on a.role_id = b.role_id
group by 1 order by 1) as c
on a.类型 = c.类型

left join
(select case when wish_mode = 1 then '3紫金'
            when wish_mode = 2 then '1白银'
            when wish_mode = 3 then '2黄金'
       end as '类型'
       ,round((count(distinct case when play_not = 'yes' then role_id else NULL end) / count(distinct role_id))*100,2) as '天复玩率'
from

(select b.wish_mode,b.role_id,case when c.role_id is null then 'no'
                 else 'yes'
                 end as play_not
from

(select wish_mode,role_id,to_date(cast(date_time as timestamp)) as done_dt
from myth_server.server_wish_room
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and consume_prop_num > 0
) b

left join
(select wish_mode,role_id,to_date(cast(date_time as timestamp)) as done_dt
from myth_server.server_wish_room
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and consume_prop_num > 0
) c
on b.wish_mode = c.wish_mode and b.role_id = c.role_id and datediff(c.done_dt,b.done_dt) = 1
group by 1,2,3
) as b
group by 1 order by 1
) as d 
on a.类型 = d.类型
group by 1,2,3,4,5,6,7
order by 1





信徒心愿
-- 心愿任务   参与人数 人均参与次数  免费刷新人数 钻石刷新人数  钻石刷新次数  天复玩率 消耗钻石人数  钻石消耗次数

select believer_id_list as '心愿任务'
       ,count(distinct a.role_id) as '参与人数'
       ,round(sum(num)/count(distinct a.role_id),2) as '人均参与次数'
       ,count(distinct b.role_id) as '免费刷新人数'
       ,count(distinct c.role_id) as '钻石刷新人数'
       ,sum(钻石刷新次数) as '钻石刷新次数'
       ,count(distinct d.role_id) as '消耗钻石人数'
       ,sum(钻石消耗次数) as '钻石消耗次数'
       ,sum(钻石消耗数量) as '钻石消耗数量'
       ,round((count(distinct case when play_not = 'yes' then f.role_id else NULL end) / count(distinct f.role_id))*100,2) as '复玩率'
from

-- 参与信徒心愿的玩家  消耗心愿值大于0
(select role_id,believer_id_list,count(distinct log_time) as num
from myth_server.server_bless_believer
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and consume_believer > 0
group by 1,2
) a

left join
-- 免费刷新人数
(select role_id 
from myth_server.server_click_believer
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and sys_type = 1 -- 免费刷新信徒心愿
group by 1
) b 
on a.role_id = b.role_id

left join
-- 钻石刷新
(select role_id,count(distinct log_time) as '钻石刷新次数'
from myth.server_currency
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and currency_id = '3'
AND change_type = 'CONSUME'
and change_method = '40' -- 刷新信徒心愿
group by 1
) c 
on a.role_id = c.role_id

left join
-- 钻石消耗
(select role_id,count(distinct log_time) as '钻石消耗次数',sum(change_count) as '钻石消耗数量'
from myth.server_currency
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and currency_id = '3'
AND change_type = 'CONSUME'
and change_method in ('38','40') -- 加速信徒心愿完成 刷新信徒心愿
group by 1
) d 
on a.role_id = d.role_id

left join
-- 天复玩率
(select f1.role_id,case when f2.role_id is null then 'no'
                 else 'yes'
                 end as play_not
from
(select role_id,to_date(cast(date_time as timestamp)) as done_dt
from myth_server.server_bless_believer
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and consume_believer > 0
) f1
left join
(select role_id,to_date(cast(date_time as timestamp)) as done_dt
from myth_server.server_bless_believer
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and consume_believer > 0
) f2
on f1.role_id = f2.role_id and datediff(f2.done_dt,f1.done_dt) = 1
group by 1,2
) as f
on a.role_id = f.role_id
group by 1
order by 1


主城答题

参与答题人数
select npc_id,count(distinct role_id)
from myth_server.server_questions
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1
order by 1

至少两个自然日在线人数
select count(distinct role_id)
from
(select role_id,count(distinct day_time) as num  
from myth.client_online
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1
) as a 
where num >= 2





时间庭院
整体
-- 日期   参与人数 人均参与次数    整体加速人数    整体人均加速次数  消耗钻石加速人数  消耗钻石人均加速

select a.day_time as '日期'
       ,count(distinct a.role_id) as '参与人数'
       ,round(sum(num)/count(distinct a.role_id),2) as '人均参与次数'
       ,count(distinct b.role_id) as '整体加速人数'
       ,round(count(log_time)/count(distinct b.role_id),2) as '整体人均加速次数'
       ,count(distinct case when consume_currency_num > 0 then b.role_id else NULL end) as '消耗钻石加速人数'
       ,round(count(case when consume_currency_num > 0 then log_time else NULL end)/count(distinct case when consume_currency_num > 0 then b.role_id else NULL end),2) as '消耗钻石人均加速次数'
from
( -- 参与春之庭院的玩家  有领取挂机奖励的日志
select role_id,day_time,count(distinct log_time) as num
from myth_server.server_claim_hang_reward
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2
) a

left join
-- 加速、钻石消耗
( 
select role_id,day_time,log_time,consume_currency_num
from myth_server.server_quicken_hang
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and consume_currency_id = 3
group by 1,2,3,4
) b
on a.role_id = b.role_id and a.day_time = b.day_time
group by 1
order by 1

