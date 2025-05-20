玩法系统数据分析  

玩法——3->战役

整体、付费-- 人数维度进入关卡人数、通关率、中途退出率，D1次数维度数据
select birth_dt,b.role_id,dungeon_id,scene_id,start_time,game_type,battle_result,battle_time,auto_battle,bottle_num,done_dt,标签,datediff(done_dt,birth_dt) + 1 as '天数'
from

(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
group by 1,2
)as a

left join
-- 关卡参与情况
(select dungeon_id,scene_id,role_id,start_time,game_type,battle_result,battle_time,auto_battle,bottle_num,done_dt, 
from
(select a.dungeon_id,a.scene_id,a.role_id,a.start_time,a.game_type,battle_result,battle_time,auto_battle,bottle_num,done_dt
from 
(select dungeon_id,scene_id,role_id,start_time,to_date(cast(date_time as timestamp)) as done_dt,game_type -- start_time也可用统计参与次数
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 3 -- 3->战役
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5,6
) as a
left join     
(select dungeon_id,scene_id,role_id,start_time,battle_result,
        case when battle_time/60000 is null then '无日志'
             when battle_time/60000 > 3  then '1超时'
             when battle_time/60000 > 2 and battle_time/60000 <= 3  then '2困难'
             when battle_time/60000 > 1 and battle_time/60000 <= 2  then '3较难'
             when battle_time/60000 > 0 and battle_time/60000 <= 1  then '4一般'
             else '无日志'
        end as battle_time,auto_battle,game_type,bottle_num --药瓶使用数
from myth_server.server_dungeon_end
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 3 -- 3->战役
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5,6,7,8,9
) b 
on a.dungeon_id=b.dungeon_id and a.scene_id = b.scene_id and a.role_id=b.role_id and a.start_time=b.start_time and a.game_type = b.game_type 
order by a.role_id,a.start_time asc 
) as e  
group by 1,2,3,4,5,6,7,8,9,10
) as b 
on a.role_id = b.role_id

left join -- 付费分档
(select role_id,case when 天数 = 1 and sum_pay = 0 then 'D1免费'
                     when 天数 = 1 and (sum_pay > 0 and sum_pay <= 6) then 'D1小R'
                     when 天数 = 1 and (sum_pay > 6 and sum_pay <= 36) then 'D1中R'
                     when 天数 = 1 and (sum_pay > 36 and sum_pay <= 268) then 'D1大R'
                     when 天数 = 2 and sum_pay = 0 then 'D2免费'
                     when 天数 = 2 and (sum_pay > 0 and sum_pay <= 36) then 'D2小R'
                     when 天数 = 2 and (sum_pay > 36 and sum_pay <= 108) then 'D2中R'
                     when 天数 = 2 and (sum_pay > 108 and sum_pay <= 566) then 'D2大R'
                     when 天数 = 3 and sum_pay = 0 then 'D3免费'
                     when 天数 = 3 and (sum_pay > 0 and sum_pay <= 66) then 'D3小R'
                     when 天数 = 3 and (sum_pay > 66 and sum_pay <= 274) then 'D3中R'
                     when 天数 = 3 and (sum_pay > 274 and sum_pay <= 852) then 'D3大R'
                     when 天数 = 4 and sum_pay = 0 then 'D4免费'
                     when 天数 = 4 and (sum_pay > 0 and sum_pay <= 78) then 'D4小R'
                     when 天数 = 4 and (sum_pay > 78 and sum_pay <= 500) then 'D4中R'
                     when 天数 = 4 and (sum_pay > 500 and sum_pay <= 882) then 'D4大R'
                     when 天数 = 5 and sum_pay = 0 then 'D5免费'
                     when 天数 = 5 and (sum_pay > 0 and sum_pay <= 78) then 'D5小R'
                     when 天数 = 5 and (sum_pay > 78 and sum_pay <= 628) then 'D5中R'
                     when 天数 = 5 and (sum_pay > 628 and sum_pay <= 912) then 'D5大R'
                     when 天数 = 6 and sum_pay = 0 then 'D6免费'
                     when 天数 = 6 and (sum_pay > 0 and sum_pay <= 78) then 'D6小R'
                     when 天数 = 6 and (sum_pay > 78 and sum_pay <= 628) then 'D6中R'
                     when 天数 = 6 and (sum_pay > 628 and sum_pay <= 942) then 'D6大R'
                     when 天数 = 7 and sum_pay = 0 then 'D7免费'
                     when 天数 = 7 and (sum_pay > 0 and sum_pay <= 78) then 'D7小R'
                     when 天数 = 7 and (sum_pay > 78 and sum_pay <= 628) then 'D7中R'
                     when 天数 = 7 and (sum_pay > 628 and sum_pay <= 972) then 'D7大R'
                     when 天数 = 14 and sum_pay = 0 then 'D14免费'
                     when 天数 = 14 and (sum_pay > 0 and sum_pay <= 78) then 'D14小R'
                     when 天数 = 14 and (sum_pay > 78 and sum_pay <= 628) then 'D14中R'
                     when 天数 = 14 and (sum_pay > 628 and sum_pay <= 1182) then 'D14大R'
                     when 天数 = 30 and sum_pay = 0 then 'D30免费'
                     when 天数 = 30 and (sum_pay > 0 and sum_pay <= 78) then 'D30小R'
                     when 天数 = 30 and (sum_pay > 78 and sum_pay <= 628) then 'D30中R'
                     when 天数 = 30 and (sum_pay > 628 and sum_pay <= 1662) then 'D30大R'
               else 'others'
               end as '标签'
from
(select birth_dt, a.role_id,datediff(pay_dt,birth_dt)+1 as '天数',sum_pay
from
(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
group by 1,2
)as a

left join
(select role_id,to_date(cast(date_time as timestamp)) as pay_dt,sum(pay_price) as sum_pay
from myth.order_pay
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and country not in ('CN','HK')
group by 1,2
) b
on a.role_id = b.role_id
where datediff(pay_dt,birth_dt) in (0,1,2,3,4,5,6)
) as c
on a.role_id = c.role_id
) c
on a.role_id = c.role_id and b.done_dt = c.pay_dt
where datediff(b.done_dt,a.birth_dt) <= 6
group by 1,2,3,4,5,6,7,8,9,10,11,12,13






整体、付费 -- 复玩率
select birth_dt,datediff(done_dt,birth_dt)+1 as '天数',标签,count(distinct b.role_id) as '进入总人数',count(distinct case when 进入次数 > 1 then b.role_id else null) as '复玩人数'
from

(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
group by 1,2
)as a

left join
(select dungeon_id,scene_id,role_id,to_date(cast(date_time as timestamp)) as done_dt,count(distinct start_time) as '进入次数' -- start_time也可用统计参与次数
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 3 -- 3->战役
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4
) as b
on a.role_id = b.role_id

left join -- 付费分档
(select role_id,case when 天数 = 1 and sum_pay = 0 then 'D1免费'
                     when 天数 = 1 and (sum_pay > 0 and sum_pay <= 6) then 'D1小R'
                     when 天数 = 1 and (sum_pay > 6 and sum_pay <= 36) then 'D1中R'
                     when 天数 = 1 and (sum_pay > 36 and sum_pay <= 268) then 'D1大R'
                     when 天数 = 2 and sum_pay = 0 then 'D2免费'
                     when 天数 = 2 and (sum_pay > 0 and sum_pay <= 36) then 'D2小R'
                     when 天数 = 2 and (sum_pay > 36 and sum_pay <= 108) then 'D2中R'
                     when 天数 = 2 and (sum_pay > 108 and sum_pay <= 566) then 'D2大R'
                     when 天数 = 3 and sum_pay = 0 then 'D3免费'
                     when 天数 = 3 and (sum_pay > 0 and sum_pay <= 66) then 'D3小R'
                     when 天数 = 3 and (sum_pay > 66 and sum_pay <= 274) then 'D3中R'
                     when 天数 = 3 and (sum_pay > 274 and sum_pay <= 852) then 'D3大R'
                     when 天数 = 4 and sum_pay = 0 then 'D4免费'
                     when 天数 = 4 and (sum_pay > 0 and sum_pay <= 78) then 'D4小R'
                     when 天数 = 4 and (sum_pay > 78 and sum_pay <= 500) then 'D4中R'
                     when 天数 = 4 and (sum_pay > 500 and sum_pay <= 882) then 'D4大R'
                     when 天数 = 5 and sum_pay = 0 then 'D5免费'
                     when 天数 = 5 and (sum_pay > 0 and sum_pay <= 78) then 'D5小R'
                     when 天数 = 5 and (sum_pay > 78 and sum_pay <= 628) then 'D5中R'
                     when 天数 = 5 and (sum_pay > 628 and sum_pay <= 912) then 'D5大R'
                     when 天数 = 6 and sum_pay = 0 then 'D6免费'
                     when 天数 = 6 and (sum_pay > 0 and sum_pay <= 78) then 'D6小R'
                     when 天数 = 6 and (sum_pay > 78 and sum_pay <= 628) then 'D6中R'
                     when 天数 = 6 and (sum_pay > 628 and sum_pay <= 942) then 'D6大R'
                     when 天数 = 7 and sum_pay = 0 then 'D7免费'
                     when 天数 = 7 and (sum_pay > 0 and sum_pay <= 78) then 'D7小R'
                     when 天数 = 7 and (sum_pay > 78 and sum_pay <= 628) then 'D7中R'
                     when 天数 = 7 and (sum_pay > 628 and sum_pay <= 972) then 'D7大R'
                     when 天数 = 14 and sum_pay = 0 then 'D14免费'
                     when 天数 = 14 and (sum_pay > 0 and sum_pay <= 78) then 'D14小R'
                     when 天数 = 14 and (sum_pay > 78 and sum_pay <= 628) then 'D14中R'
                     when 天数 = 14 and (sum_pay > 628 and sum_pay <= 1182) then 'D14大R'
                     when 天数 = 30 and sum_pay = 0 then 'D30免费'
                     when 天数 = 30 and (sum_pay > 0 and sum_pay <= 78) then 'D30小R'
                     when 天数 = 30 and (sum_pay > 78 and sum_pay <= 628) then 'D30中R'
                     when 天数 = 30 and (sum_pay > 628 and sum_pay <= 1662) then 'D30大R'
               else 'others'
               end as '标签'
from
(select birth_dt, a.role_id,datediff(pay_dt,birth_dt)+1 as '天数',sum_pay
from
(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
group by 1,2
)as a

left join
(select role_id,to_date(cast(date_time as timestamp)) as pay_dt,sum(pay_price) as sum_pay
from myth.order_pay
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and country not in ('CN','HK')
group by 1,2
) b
on a.role_id = b.role_id
where datediff(pay_dt,birth_dt) in (0,1,2,3,4,5,6)
) as c
on a.role_id = c.role_id
) c
on a.role_id = c.role_id and b.done_dt = c.pay_dt
where datediff(b.done_dt,a.birth_dt) <= 6
group by 1,2,3






整体、付费 --人数维度 流失人数、流失率
流失：生命周期最高关卡，次日未登录
select birth_dt,b.role_id,最高关卡,是否流失,datediff(done_dt,birth_dt) + 1 as '天数',标签
from

(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
group by 1,2
)as a

left join
(select a.role_id,done_dt,最高关卡,
        case when b.role_id is null then '流失' 
             else '留存'
             end as '是否流失'
from
(select role_id,to_date(cast(date_time as timestamp)) as done_dt,max(dungeon_id) as '最高关卡'
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 3 -- 3->战役 
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2
) as a
left join
(select role_id,to_date(cast(date_time as timestamp)) as login_dt
from myth.server_role_login
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2
) as b 
on a.role_id = b.role_id
where datediff(login_dt,done_dt) = 1
group by 1,2,3,4
) as b
on a.role_id = b.role_id

left join -- 付费分档
(select role_id,case when 天数 = 1 and sum_pay = 0 then 'D1免费'
                     when 天数 = 1 and (sum_pay > 0 and sum_pay <= 6) then 'D1小R'
                     when 天数 = 1 and (sum_pay > 6 and sum_pay <= 36) then 'D1中R'
                     when 天数 = 1 and (sum_pay > 36 and sum_pay <= 268) then 'D1大R'
                     when 天数 = 2 and sum_pay = 0 then 'D2免费'
                     when 天数 = 2 and (sum_pay > 0 and sum_pay <= 36) then 'D2小R'
                     when 天数 = 2 and (sum_pay > 36 and sum_pay <= 108) then 'D2中R'
                     when 天数 = 2 and (sum_pay > 108 and sum_pay <= 566) then 'D2大R'
                     when 天数 = 3 and sum_pay = 0 then 'D3免费'
                     when 天数 = 3 and (sum_pay > 0 and sum_pay <= 66) then 'D3小R'
                     when 天数 = 3 and (sum_pay > 66 and sum_pay <= 274) then 'D3中R'
                     when 天数 = 3 and (sum_pay > 274 and sum_pay <= 852) then 'D3大R'
                     when 天数 = 4 and sum_pay = 0 then 'D4免费'
                     when 天数 = 4 and (sum_pay > 0 and sum_pay <= 78) then 'D4小R'
                     when 天数 = 4 and (sum_pay > 78 and sum_pay <= 500) then 'D4中R'
                     when 天数 = 4 and (sum_pay > 500 and sum_pay <= 882) then 'D4大R'
                     when 天数 = 5 and sum_pay = 0 then 'D5免费'
                     when 天数 = 5 and (sum_pay > 0 and sum_pay <= 78) then 'D5小R'
                     when 天数 = 5 and (sum_pay > 78 and sum_pay <= 628) then 'D5中R'
                     when 天数 = 5 and (sum_pay > 628 and sum_pay <= 912) then 'D5大R'
                     when 天数 = 6 and sum_pay = 0 then 'D6免费'
                     when 天数 = 6 and (sum_pay > 0 and sum_pay <= 78) then 'D6小R'
                     when 天数 = 6 and (sum_pay > 78 and sum_pay <= 628) then 'D6中R'
                     when 天数 = 6 and (sum_pay > 628 and sum_pay <= 942) then 'D6大R'
                     when 天数 = 7 and sum_pay = 0 then 'D7免费'
                     when 天数 = 7 and (sum_pay > 0 and sum_pay <= 78) then 'D7小R'
                     when 天数 = 7 and (sum_pay > 78 and sum_pay <= 628) then 'D7中R'
                     when 天数 = 7 and (sum_pay > 628 and sum_pay <= 972) then 'D7大R'
                     when 天数 = 14 and sum_pay = 0 then 'D14免费'
                     when 天数 = 14 and (sum_pay > 0 and sum_pay <= 78) then 'D14小R'
                     when 天数 = 14 and (sum_pay > 78 and sum_pay <= 628) then 'D14中R'
                     when 天数 = 14 and (sum_pay > 628 and sum_pay <= 1182) then 'D14大R'
                     when 天数 = 30 and sum_pay = 0 then 'D30免费'
                     when 天数 = 30 and (sum_pay > 0 and sum_pay <= 78) then 'D30小R'
                     when 天数 = 30 and (sum_pay > 78 and sum_pay <= 628) then 'D30中R'
                     when 天数 = 30 and (sum_pay > 628 and sum_pay <= 1662) then 'D30大R'
               else 'others'
               end as '标签'
from
(select birth_dt, a.role_id,datediff(pay_dt,birth_dt)+1 as '天数',sum_pay
from
(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
group by 1,2
)as a

left join
(select role_id,to_date(cast(date_time as timestamp)) as pay_dt,sum(pay_price) as sum_pay
from myth.order_pay
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and country not in ('CN','HK')
group by 1,2
) b
on a.role_id = b.role_id
where datediff(pay_dt,birth_dt) in (0,1,2,3,4,5,6)
) as c
on a.role_id = c.role_id
) c
on a.role_id = c.role_id and b.done_dt = c.pay_dt
where datediff(b.done_dt,a.birth_dt) <= 6
group by 1,2,3,4,5,6




生命周期，D1-D7玩法细拆各个数据
存在失败日志的人数  失败
select a.role_id as role_id,birth_dt,game_type,dungeon_id,scene_id,datediff(done_dt,birth_dt)+1 as '天数',标签,失败人数,无日志人数
from

(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
group by 1,2
)as a


left join --存在失败记录的
(
select role_id,done_dt,game_type,dungeon_id,scene_id,
       count(distinct case when battle_result = 2 then role_id else null end) as '失败人数',
       count(distinct case when battle_result is NULL then role_id else null end) as '无日志人数'
from
(select role_id,done_dt,dungeon_id,scene_id,battle_result,game_type
from
(select a.role_id as role_id,done_dt,a.dungeon_id as dungeon_id,a.scene_id,battle_result,a.game_type as game_type
from
(select dungeon_id,scene_id,role_id,to_date(cast(date_time as timestamp)) as done_dt,start_time,game_type
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (20001,20002,20003)
and game_type =3 -- 3战役
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5,6
) a 
left join 
(select dungeon_id,scene_id,role_id,battle_result,log_time,start_time,game_type
from myth_server.server_dungeon_end
where day_time between ${beginDate} and ${endDate}   and server_id in (20001,20002,20003)
and game_type =3 -- 3战役
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5,6,7
) b 
on a.game_type = b.game_type and a.dungeon_id=b.dungeon_id and a.scene_id = b.scene_id and a.role_id=b.role_id and a.start_time = b.start_time
) as c
group by 1,2,3,4,5,6
) as b
group by 1,2,3,4,5
) as b
on a.role_id = b.role_id

left join -- 付费分档
(select role_id,case when 天数 = 1 and sum_pay = 0 then 'D1免费'
                     when 天数 = 1 and (sum_pay > 0 and sum_pay <= 6) then 'D1小R'
                     when 天数 = 1 and (sum_pay > 6 and sum_pay <= 36) then 'D1中R'
                     when 天数 = 1 and (sum_pay > 36 and sum_pay <= 268) then 'D1大R'
                     when 天数 = 2 and sum_pay = 0 then 'D2免费'
                     when 天数 = 2 and (sum_pay > 0 and sum_pay <= 36) then 'D2小R'
                     when 天数 = 2 and (sum_pay > 36 and sum_pay <= 108) then 'D2中R'
                     when 天数 = 2 and (sum_pay > 108 and sum_pay <= 566) then 'D2大R'
                     when 天数 = 3 and sum_pay = 0 then 'D3免费'
                     when 天数 = 3 and (sum_pay > 0 and sum_pay <= 66) then 'D3小R'
                     when 天数 = 3 and (sum_pay > 66 and sum_pay <= 274) then 'D3中R'
                     when 天数 = 3 and (sum_pay > 274 and sum_pay <= 852) then 'D3大R'
                     when 天数 = 4 and sum_pay = 0 then 'D4免费'
                     when 天数 = 4 and (sum_pay > 0 and sum_pay <= 78) then 'D4小R'
                     when 天数 = 4 and (sum_pay > 78 and sum_pay <= 500) then 'D4中R'
                     when 天数 = 4 and (sum_pay > 500 and sum_pay <= 882) then 'D4大R'
                     when 天数 = 5 and sum_pay = 0 then 'D5免费'
                     when 天数 = 5 and (sum_pay > 0 and sum_pay <= 78) then 'D5小R'
                     when 天数 = 5 and (sum_pay > 78 and sum_pay <= 628) then 'D5中R'
                     when 天数 = 5 and (sum_pay > 628 and sum_pay <= 912) then 'D5大R'
                     when 天数 = 6 and sum_pay = 0 then 'D6免费'
                     when 天数 = 6 and (sum_pay > 0 and sum_pay <= 78) then 'D6小R'
                     when 天数 = 6 and (sum_pay > 78 and sum_pay <= 628) then 'D6中R'
                     when 天数 = 6 and (sum_pay > 628 and sum_pay <= 942) then 'D6大R'
                     when 天数 = 7 and sum_pay = 0 then 'D7免费'
                     when 天数 = 7 and (sum_pay > 0 and sum_pay <= 78) then 'D7小R'
                     when 天数 = 7 and (sum_pay > 78 and sum_pay <= 628) then 'D7中R'
                     when 天数 = 7 and (sum_pay > 628 and sum_pay <= 972) then 'D7大R'
                     when 天数 = 14 and sum_pay = 0 then 'D14免费'
                     when 天数 = 14 and (sum_pay > 0 and sum_pay <= 78) then 'D14小R'
                     when 天数 = 14 and (sum_pay > 78 and sum_pay <= 628) then 'D14中R'
                     when 天数 = 14 and (sum_pay > 628 and sum_pay <= 1182) then 'D14大R'
                     when 天数 = 30 and sum_pay = 0 then 'D30免费'
                     when 天数 = 30 and (sum_pay > 0 and sum_pay <= 78) then 'D30小R'
                     when 天数 = 30 and (sum_pay > 78 and sum_pay <= 628) then 'D30中R'
                     when 天数 = 30 and (sum_pay > 628 and sum_pay <= 1662) then 'D30大R'
               else 'others'
               end as '标签'
from
(select birth_dt, a.role_id,datediff(pay_dt,birth_dt)+1 as '天数',sum_pay
from
(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
group by 1,2
)as a

left join
(select role_id,to_date(cast(date_time as timestamp)) as pay_dt,sum(pay_price) as sum_pay
from myth.order_pay
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and country not in ('CN','HK')
group by 1,2
) b
on a.role_id = b.role_id
where datediff(pay_dt,birth_dt) in (0,1,2,3,4,5,6)
) as c
on a.role_id = c.role_id
) c
on a.role_id = c.role_id and b.done_dt = c.pay_dt
where datediff(b.done_dt,a.birth_dt) <= 6
group by 1,2,3,4,5,6,7,8,9




复玩人数、复玩次数
select birth_dt,datediff(done_dt,birth_dt)+1 as '天数',标签,game_type,dungeon_id,scene_id,count(distinct f.role_id) as '复玩人数',sum(进入次数) as '复玩次数'
from

(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
group by 1,2
)as a

left join
(
select role_id,done_dt,game_type,dungeon_id,scene_id,进入次数 -- 对应着复玩人数、次数
from
(select d.role_id,c.done_dt,c.dungeon_id,c.scene_id,c.game_type,进入次数
from
(select a.role_id,a.done_dt,a.dungeon_id,a.game_type -- 有失败的玩家
from
(select dungeon_id,scene_id,role_id,to_date(cast(date_time as timestamp)) as done_dt,start_time,game_type
from myth_server.server_enter_dungeon
where day_time>=${beginDate} and day_time<=${end2Date} and server_id in (20001,20002)
and game_type =3 -- 3战役
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5,6) a 
left join 
(select dungeon_id,scene_id,role_id,battle_result,log_time,start_time,game_type
from myth_server.server_dungeon_end
where day_time>=${beginDate} and day_time<=${end2Date}   and server_id in (20001,20002)
and game_type =3 -- 3战役
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5,6,7) b 
on a.game_type = b.game_type and a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time = b.start_time
where battle_result =2 -- =2是有失败记录的/is null是无日志记录的
group by 1,2,3,4 
) c 
left join 
(select a.role_id as role_id,done_dt,a.game_type as game_type,a.dungeon_id as dungeon_id,a.scene_id as scene_id,count(a.start_time) as '进入次数'
from
(select dungeon_id,scene_id,role_id,to_date(cast(date_time as timestamp)) as done_dt,start_time,game_type
from myth_server.server_enter_dungeon
where day_time>=${beginDate} and day_time<=${end2Date} and server_id in (20001,20002)
and game_type =3 -- 3战役
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5,6) a 
left join 
(select dungeon_id,scene_id,role_id,battle_result,log_time,start_time,game_type
from myth_server.server_dungeon_end
where day_time>=${beginDate} and day_time<=${end2Date}   and server_id in (20001,20002)
and game_type =3 -- 3战役
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5,6,7) b 
on a.game_type = b.game_type and a.dungeon_id=b.dungeon_id and a.scene_id = b.scene_id and a.role_id=b.role_id and a.start_time = b.start_time
group by 1,2,3,4
) as d 
on c.game_type = d.game_type and c.dungeon_id=d.dungeon_id and a.scene_id = d.scene_id and c.role_id=d.role_id and c.done_dt=d.done_dt
group by 1,2,3,4,5,6
) as  e 
group by 1,2,3,4,5,6
) as f 
on a.role_id = f.role_id 

left join -- 付费分档
(select role_id,case when 天数 = 1 and sum_pay = 0 then 'D1免费'
                     when 天数 = 1 and (sum_pay > 0 and sum_pay <= 6) then 'D1小R'
                     when 天数 = 1 and (sum_pay > 6 and sum_pay <= 36) then 'D1中R'
                     when 天数 = 1 and (sum_pay > 36 and sum_pay <= 268) then 'D1大R'
                     when 天数 = 2 and sum_pay = 0 then 'D2免费'
                     when 天数 = 2 and (sum_pay > 0 and sum_pay <= 36) then 'D2小R'
                     when 天数 = 2 and (sum_pay > 36 and sum_pay <= 108) then 'D2中R'
                     when 天数 = 2 and (sum_pay > 108 and sum_pay <= 566) then 'D2大R'
                     when 天数 = 3 and sum_pay = 0 then 'D3免费'
                     when 天数 = 3 and (sum_pay > 0 and sum_pay <= 66) then 'D3小R'
                     when 天数 = 3 and (sum_pay > 66 and sum_pay <= 274) then 'D3中R'
                     when 天数 = 3 and (sum_pay > 274 and sum_pay <= 852) then 'D3大R'
                     when 天数 = 4 and sum_pay = 0 then 'D4免费'
                     when 天数 = 4 and (sum_pay > 0 and sum_pay <= 78) then 'D4小R'
                     when 天数 = 4 and (sum_pay > 78 and sum_pay <= 500) then 'D4中R'
                     when 天数 = 4 and (sum_pay > 500 and sum_pay <= 882) then 'D4大R'
                     when 天数 = 5 and sum_pay = 0 then 'D5免费'
                     when 天数 = 5 and (sum_pay > 0 and sum_pay <= 78) then 'D5小R'
                     when 天数 = 5 and (sum_pay > 78 and sum_pay <= 628) then 'D5中R'
                     when 天数 = 5 and (sum_pay > 628 and sum_pay <= 912) then 'D5大R'
                     when 天数 = 6 and sum_pay = 0 then 'D6免费'
                     when 天数 = 6 and (sum_pay > 0 and sum_pay <= 78) then 'D6小R'
                     when 天数 = 6 and (sum_pay > 78 and sum_pay <= 628) then 'D6中R'
                     when 天数 = 6 and (sum_pay > 628 and sum_pay <= 942) then 'D6大R'
                     when 天数 = 7 and sum_pay = 0 then 'D7免费'
                     when 天数 = 7 and (sum_pay > 0 and sum_pay <= 78) then 'D7小R'
                     when 天数 = 7 and (sum_pay > 78 and sum_pay <= 628) then 'D7中R'
                     when 天数 = 7 and (sum_pay > 628 and sum_pay <= 972) then 'D7大R'
                     when 天数 = 14 and sum_pay = 0 then 'D14免费'
                     when 天数 = 14 and (sum_pay > 0 and sum_pay <= 78) then 'D14小R'
                     when 天数 = 14 and (sum_pay > 78 and sum_pay <= 628) then 'D14中R'
                     when 天数 = 14 and (sum_pay > 628 and sum_pay <= 1182) then 'D14大R'
                     when 天数 = 30 and sum_pay = 0 then 'D30免费'
                     when 天数 = 30 and (sum_pay > 0 and sum_pay <= 78) then 'D30小R'
                     when 天数 = 30 and (sum_pay > 78 and sum_pay <= 628) then 'D30中R'
                     when 天数 = 30 and (sum_pay > 628 and sum_pay <= 1662) then 'D30大R'
               else 'others'
               end as '标签'
from
(select birth_dt, a.role_id,datediff(pay_dt,birth_dt)+1 as '天数',sum_pay
from
(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
group by 1,2
)as a

left join
(select role_id,to_date(cast(date_time as timestamp)) as pay_dt,sum(pay_price) as sum_pay
from myth.order_pay
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and country not in ('CN','HK')
group by 1,2
) b
on a.role_id = b.role_id
where datediff(pay_dt,birth_dt) in (0,1,2,3,4,5,6)
) as c
on a.role_id = c.role_id
) c
on a.role_id = c.role_id and b.done_dt = c.pay_dt
where datediff(b.done_dt,a.birth_dt) <= 6
group by 1,2,3,4,5,6






失败后通关人数 去重日志条数 = 2 -- 2代表有失败记录最后通关的  1代表无日志记录最后通关的

select role_id,birth_dt,game_type,dungeon_id,scene_id,天数,标签
from

(select a.role_id as role_id,birth_dt,game_type,dungeon_id,scene_id,num,datediff(done_dt,birth_dt)+1 as '天数',标签
from

(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
group by 1,2
)as a


left join
(select c.role_id,c.done_dt,c.dungeon_id,c.scene_id,c.game_type,count(distinct battle_result) as num -- 去重日志条数
from
(select a.role_id,a.done_dt,a.dungeon_id,a.game_type -- 有失败/无日志的玩家
from
(select dungeon_id,scene_id,role_id,to_date(cast(date_time as timestamp)) as done_dt,start_time,game_type
from myth_server.server_enter_dungeon
where day_time>=${beginDate} and day_time<=${end2Date} and server_id in (20001,20002)
and game_type =3 -- 3战役
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5,6) a 
left join 
(select dungeon_id,scene_id,role_id,battle_result,log_time,start_time,game_type
from myth_server.server_dungeon_end
where day_time>=${beginDate} and day_time<=${end2Date} and server_id in (20001,20002)
and game_type =3 -- 3战役
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5,6,7) b 
on a.game_type = b.game_type and a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time = b.start_time
where battle_result =2 -- =2是有失败记录的/is null是无日志记录的
group by 1,2,3,4 
) c 
left join 
(select a.role_id as role_id,done_dt,a.game_type as game_type,a.dungeon_id as dungeon_id,a.scene_id as scene_id,battle_result
from
(select dungeon_id,scene_id,role_id,to_date(cast(date_time as timestamp)) as done_dt,start_time,game_type
from myth_server.server_enter_dungeon
where day_time>=${beginDate} and day_time<=${end2Date} and server_id in (20001,20002)
and game_type =3 -- 3战役
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5,6) a 
left join 
(select dungeon_id,scene_id,role_id,battle_result,log_time,start_time,game_type
from myth_server.server_dungeon_end
where day_time>=${beginDate} and day_time<=${end2Date}   and server_id in (20001,20002)
and game_type =3 -- 3战役
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3,4,5,6,7) b 
on a.game_type = b.game_type and a.dungeon_id=b.dungeon_id and a.scene_id = b.scene_id and a.role_id=b.role_id and a.start_time = b.start_time
where battle_result = 1 -- 有成功日志的
group by 1,2,3,4,5,6
) as d 
on c.game_type = d.game_type and c.dungeon_id=d.dungeon_id and a.scene_id = d.scene_id and c.role_id=d.role_id and c.done_dt=d.done_dt
group by 1,2,3,4,5
) as f 
on a.role_id = f.role_id 

left join -- 付费分档
(select role_id,case when 天数 = 1 and sum_pay = 0 then 'D1免费'
                     when 天数 = 1 and (sum_pay > 0 and sum_pay <= 6) then 'D1小R'
                     when 天数 = 1 and (sum_pay > 6 and sum_pay <= 36) then 'D1中R'
                     when 天数 = 1 and (sum_pay > 36 and sum_pay <= 268) then 'D1大R'
                     when 天数 = 2 and sum_pay = 0 then 'D2免费'
                     when 天数 = 2 and (sum_pay > 0 and sum_pay <= 36) then 'D2小R'
                     when 天数 = 2 and (sum_pay > 36 and sum_pay <= 108) then 'D2中R'
                     when 天数 = 2 and (sum_pay > 108 and sum_pay <= 566) then 'D2大R'
                     when 天数 = 3 and sum_pay = 0 then 'D3免费'
                     when 天数 = 3 and (sum_pay > 0 and sum_pay <= 66) then 'D3小R'
                     when 天数 = 3 and (sum_pay > 66 and sum_pay <= 274) then 'D3中R'
                     when 天数 = 3 and (sum_pay > 274 and sum_pay <= 852) then 'D3大R'
                     when 天数 = 4 and sum_pay = 0 then 'D4免费'
                     when 天数 = 4 and (sum_pay > 0 and sum_pay <= 78) then 'D4小R'
                     when 天数 = 4 and (sum_pay > 78 and sum_pay <= 500) then 'D4中R'
                     when 天数 = 4 and (sum_pay > 500 and sum_pay <= 882) then 'D4大R'
                     when 天数 = 5 and sum_pay = 0 then 'D5免费'
                     when 天数 = 5 and (sum_pay > 0 and sum_pay <= 78) then 'D5小R'
                     when 天数 = 5 and (sum_pay > 78 and sum_pay <= 628) then 'D5中R'
                     when 天数 = 5 and (sum_pay > 628 and sum_pay <= 912) then 'D5大R'
                     when 天数 = 6 and sum_pay = 0 then 'D6免费'
                     when 天数 = 6 and (sum_pay > 0 and sum_pay <= 78) then 'D6小R'
                     when 天数 = 6 and (sum_pay > 78 and sum_pay <= 628) then 'D6中R'
                     when 天数 = 6 and (sum_pay > 628 and sum_pay <= 942) then 'D6大R'
                     when 天数 = 7 and sum_pay = 0 then 'D7免费'
                     when 天数 = 7 and (sum_pay > 0 and sum_pay <= 78) then 'D7小R'
                     when 天数 = 7 and (sum_pay > 78 and sum_pay <= 628) then 'D7中R'
                     when 天数 = 7 and (sum_pay > 628 and sum_pay <= 972) then 'D7大R'
                     when 天数 = 14 and sum_pay = 0 then 'D14免费'
                     when 天数 = 14 and (sum_pay > 0 and sum_pay <= 78) then 'D14小R'
                     when 天数 = 14 and (sum_pay > 78 and sum_pay <= 628) then 'D14中R'
                     when 天数 = 14 and (sum_pay > 628 and sum_pay <= 1182) then 'D14大R'
                     when 天数 = 30 and sum_pay = 0 then 'D30免费'
                     when 天数 = 30 and (sum_pay > 0 and sum_pay <= 78) then 'D30小R'
                     when 天数 = 30 and (sum_pay > 78 and sum_pay <= 628) then 'D30中R'
                     when 天数 = 30 and (sum_pay > 628 and sum_pay <= 1662) then 'D30大R'
               else 'others'
               end as '标签'
from
(select birth_dt, a.role_id,datediff(pay_dt,birth_dt)+1 as '天数',sum_pay
from
(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
group by 1,2
)as a

left join
(select role_id,to_date(cast(date_time as timestamp)) as pay_dt,sum(pay_price) as sum_pay
from myth.order_pay
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and country not in ('CN','HK')
group by 1,2
) b
on a.role_id = b.role_id
where datediff(pay_dt,birth_dt) in (0,1,2,3,4,5,6)
) as c
on a.role_id = c.role_id
) c
on a.role_id = c.role_id and b.done_dt = c.pay_dt
where datediff(f.done_dt,a.birth_dt) <= 6

) as new
and num = 2 -- 2代表有失败记录最后通关的  1代表无日志记录最后通关的
group by 1,2,3,4,5,6,7
