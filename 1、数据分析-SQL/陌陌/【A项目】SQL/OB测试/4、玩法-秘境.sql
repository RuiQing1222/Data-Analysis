玩法系统数据分析  

玩法系统数据分析  

玩法——2->秘境

整体、付费、免费
-- 人数维度进入关卡人数、通关率

D10

-- 付费档位的平均战力
select dungeon_id,vip,appx_median(battle_points)
from 
(select dungeon_id,vip,battle_points,a.role_id
from

(select birth_dt,role_id,
case when total_pay<=8                    then 1
     when total_pay>8  and total_pay<=70  then 2
     when total_pay>70                    then 3 
     else 0 
     end as vip --D7 
from 
(select birth_dt,a.role_id
,sum(case when datediff(vip_dt,birth_dt)< ${lifeTime}  then pay else 0 end ) as 'total_pay'
from

(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(hours_add(date_time,-18)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(hours_add(date_time,-18)) as device_birth_dt
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
select role_id,to_date(hours_add(date_time,-18)) as vip_dt,sum(pay_price) pay 
from myth.order_pay
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
group by 1,2 ) b 
on a.role_id =b.role_id
group by 1,2
) a1 
) a 

left join
(select dungeon_id,role_id,battle_points,to_date(hours_add(date_time,-18)) as done_dt
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 2 
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
group by 1,2,3,4
) as b
on a.role_id = b.role_id 
where datediff(done_dt,birth_dt)< ${lifeTime}
) a 
group by 1,2




-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

生命周期的秘境参与人数 扫荡参与人数  扫荡次数  

D1-D4

select  vip,
count(distinct a.role_id) as users
,sum(battle_num) as battle_num
-- ,sum(blitz_num) as blitz_num
-- ,sum(fights) as fights
--,sum(consume_times) as consume_times
from 
(select birth_dt,role_id,
-- case when total_pay<=1                   then 1
--      when total_pay>1  and total_pay<=2  then 2
--      when total_pay>2                    then 3 
--      else 0 
--      end as vip --D1  
-- case when total_pay<=3                   then 1
--      when total_pay>3  and total_pay<=5  then 2
--      when total_pay>5                    then 3 
--      else 0 
--      end as vip --D2
case when total_pay<=8                    then 1
     when total_pay>8  and total_pay<=10  then 2
     when total_pay>10                    then 3 
     else 0 
     end as vip --D3
-- case when total_pay<=13                   then 1
--      when total_pay>13  and total_pay<=20 then 2
--      when total_pay>20                    then 3 
--      else 0 
--      end as vip --D4
from 
(select birth_dt,a.role_id
,sum(case when datediff(vip_dt,birth_dt)< ${lifeTime}  then pay else 0 end ) as 'total_pay'
from
(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(hours_add(date_time,-18)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(hours_add(date_time,-18)) as device_birth_dt
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
select role_id,to_date(hours_add(date_time,-18)) as vip_dt,sum(pay_price) pay 
from myth.order_pay
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
group by 1,2 ) b 
on a.role_id =b.role_id
group by 1,2
) a1 
) a 
left join 
(
select to_date(hours_add(date_time,-18)) as dungeon_dt,role_id,count(1) as battle_num
from myth_server.server_dungeon_end
where  day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
and game_type =2
and battle_result =1
group by 1,2 ) b 
on a.role_id=b.role_id 
-- left join 
-- (select to_date(hours_add(date_time,-18)) as dungeon_dt,role_id,count(1) as blitz_num
-- from myth_server.server_dungeon_blitz
-- where  day_time between ${beginDate} and ${endDate} 
-- and server_id in (${serverIds})
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
-- and game_type =2
-- group by 1,2 ) c 
-- on a.role_id = c.role_id 
-- left join 
-- (select role_id,to_date(hours_add(date_time,-18)) as dungeon_dt,sum(change_count) as fights
-- from myth.server_prop
-- where day_time>=${beginDate} and day_time<=${endDate}
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
-- and change_type = 'CONSUME'
-- and prop_id = '100535'
-- group by 1,2
-- ) d
-- on a.role_id =d.role_id 
left join 
(select role_id,to_date(hours_add(date_time,-18)) as dungeon_dt,count(change_count) as consume_times
from myth.server_currency
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
and change_method ='142'
and change_type = 'CONSUME'
and currency_id = '3'
group by 1,2
) e
on a.role_id =e.role_id 
where 
datediff(b.dungeon_dt,birth_dt)< ${lifeTime}
-- datediff(c.dungeon_dt,birth_dt)< ${lifeTime}
-- datediff(d.dungeon_dt,birth_dt)< ${lifeTime}
-- datediff(e.dungeon_dt,birth_dt)< ${lifeTime}
group by 1
order by 1













-- 生命周期D1-D7整体数据
select dungeon_id,

-- -- 战力压制 按照颜色 只算俩数据
-- count(distinct case when suppression = '绿色' then start_time else null end) as '绿色进入关卡次数',
-- count(distinct case when battle_result=1 and suppression = '绿色' then b.role_id else null end ) / count(distinct case when suppression = '绿色' then start_time else null end) as '绿色通关率',
-- count(distinct case when suppression = '白色' then start_time else null end) as '白色进入关卡次数',
-- count(distinct case when battle_result=1 and suppression = '白色' then b.role_id else null end ) / count(distinct case when suppression = '白色' then start_time else null end) as '白色通关率',
-- count(distinct case when suppression = '黄色' then start_time else null end) as '黄色进入关卡次数',
-- count(distinct case when battle_result=1 and suppression = '黄色' then b.role_id else null end ) / count(distinct case when suppression = '黄色' then start_time else null end) as '黄色通关率',
-- count(distinct case when suppression = '橙色' then start_time else null end) as '橙色进入关卡次数',
-- count(distinct case when battle_result=1 and suppression = '橙色' then b.role_id else null end ) / count(distinct case when suppression = '橙色' then start_time else null end) as '橙色通关率',
-- count(distinct case when suppression = '红色' then start_time else null end) as '红色进入关卡次数',
-- count(distinct case when battle_result=1 and suppression = '红色' then b.role_id else null end ) / count(distinct case when suppression = '红色' then start_time else null end) as '红色通关率',
-- --整体
-- count(distinct a.role_id) as '进入关卡人数',
-- count(distinct case when battle_result=1 then b.role_id else null end ) as '通关人数',
-- count(distinct case when battle_result=1 then b.role_id else null end ) / count(distinct a.role_id) as '通关率',
-- count(distinct case when battle_result=2 then b.role_id else null end ) as '失败人数',
-- count(distinct case when battle_result=2 then b.role_id else null end ) / count(distinct a.role_id) as '失败率',
-- count(distinct case when battle_result is null then b.role_id else null end ) as '无日志人数',
-- count(distinct case when battle_result is null then b.role_id else null end ) / count(distinct a.role_id) as '无日志率',
-- count(distinct case when battle_result is null or battle_result =2 then a.role_id  else null end ) as '无日志&失败人数'

-- 复玩人数
-- count(distinct e.role_id)

-- 复玩通关人数 
 count(distinct f.role_id)

-- 最高关卡停留且无通关记录的人数且未去其他玩法
-- num,
-- count(distinct g.role_id)

-- 最高关卡停留且无通关记录的人数且未去其他玩法,2天登录过的玩家
-- count(distinct case when datediff(login_dt,enter_dt) <= 1 then a.role_id else null end) as '2日内登录角色数' 


-- 时长 通关-死亡-主动退出remain_hp 是否为0
-- count(distinct case when battle_result = 2 and remain_hp = 0 then a.role_id else null end) as '死亡人数',
-- count(distinct case when battle_result = 2 and battle_time = '1超时' then a.role_id else null end) as '超时人数',
-- count(distinct case when battle_result = 2 and remain_hp <> 0 and battle_time <> '1超时' then a.role_id else null end) as '主动退出人数',
-- count(case when battle_result = 1 and battle_time = '1超时' then start_time else null end) as '通关1超时次数',
-- count(case when battle_result = 1 and battle_time = '2困难' then start_time else null end) as '通关2困难次数',
-- count(case when battle_result = 1 and battle_time = '3较难' then start_time else null end) as '通关3较难次数',
-- count(case when battle_result = 1 and battle_time = '4一般' then start_time else null end) as '通关4一般次数',
-- count(case when battle_result = 1 then start_time else null end) as '通关汇总次数',
-- count(case when battle_result = 2 and battle_time = '1超时' and remain_hp = 0 then start_time else null end) as '死亡1超时次数',
-- count(case when battle_result = 2 and battle_time = '2困难' and remain_hp = 0 then start_time else null end) as '死亡2困难次数',
-- count(case when battle_result = 2 and battle_time = '3较难' and remain_hp = 0 then start_time else null end) as '死亡3较难次数',
-- count(case when battle_result = 2 and battle_time = '4一般' and remain_hp = 0 then start_time else null end) as '死亡4一般次数',
-- count(case when battle_result = 2 and remain_hp = 0  then start_time else null end) as '死亡汇总次数',
-- count(case when battle_result = 2 and remain_hp <> 0 and battle_time = '1超时'  then start_time else null end) as '超时未通关次数',
-- count(case when battle_result = 2 and battle_time = '2困难' and remain_hp <> 0  then start_time else null end) as '主动退出2困难次数',
-- count(case when battle_result = 2 and battle_time = '3较难' and remain_hp <> 0  then start_time else null end) as '主动退出3较难次数',
-- count(case when battle_result = 2 and battle_time = '4一般' and remain_hp <> 0  then start_time else null end) as '主动退出4一般次数',
-- count(case when battle_result = 2 and remain_hp <> 0 and battle_time <> '1超时' then start_time else null end) as '主动退出汇总次数',
-- count(case when auto_battle is null then b.role_id else null end) as '无日志次数',
-- count(distinct start_time) as '总次数'

from

-- 最高关卡停留且无通关记录的人数且未去其他玩法,3天登录过的玩家
-- (select a.role_id,enter_dt,dungeon_id,num
--  from

(  --新增
select role_id,birth_dt,country
from
(select role_id,device_id,to_date(hours_add(date_time,-18)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(hours_add(date_time,-18)) as device_birth_dt, 
     case when country in ('PH','MY') then 'PH+MY'
     when country in ('GB','IE','CA')  then 'GB+CA'
     end as country
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id --and a1.birth_dt = a2.device_birth_dt
) as a


--  -- 进入关卡人数、通关率
-- left join
--  -- 关卡参与情况
-- (select a.dungeon_id,a.role_id,a.start_time,battle_result,battle_time,auto_battle,done_dt,suppression
-- from 
-- (select dungeon_id,role_id,start_time,to_date(hours_add(date_time,-18)) as done_dt
-- from myth_server.server_enter_dungeon
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and game_type = 2
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
-- group by 1,2,3,4
-- ) as a
-- left join     
-- (select dungeon_id,role_id,start_time,battle_result,battle_time,auto_battle,
--         case when suppression = 2 then '绿色'
--              when suppression >= 3 and suppression <= 13 then '白色'
--              when suppression >= 14 and suppression <= 23 then '黄色'
--              when suppression >= 24 and suppression <= 53 then '橙色'
--              when suppression >= 54 and suppression <= 83 then '红色'
--         end as suppression
-- from myth_server.server_dungeon_end
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and game_type = 2 
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
-- group by 1,2,3,4,5,6,7
-- ) c 
-- on a.dungeon_id=c.dungeon_id and a.role_id=c.role_id and a.start_time=c.start_time 
-- ) as b 
-- on a.role_id = b.role_id and datediff(done_dt,birth_dt) <=${lifeTime}-1
-- where b.role_id is not null 
-- group by 1 order by 1


-- left join
-- -- 重复进入（复玩）人数
-- (select role_id,dungeon_id,done_dt
-- from
-- (select dungeon_id,role_id,to_date(hours_add(date_time,-18)) as done_dt,count(distinct start_time) as '进入次数'
-- from myth_server.server_enter_dungeon
-- where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
-- and game_type = 2 
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
-- group by 1,2,3
-- ) c1
-- where 进入次数 > 1
-- group by 1,2,3 
-- ) as e
-- on a.role_id = e.role_id
-- where datediff(done_dt,birth_dt) <${lifeTime}
-- group by 1 order by 1




-- -- 重复进入（复玩）最终通关人数
-- left join
-- (select d.role_id,d.dungeon_id,d.done_dt
-- from
-- (select role_id,dungeon_id,done_dt
-- from
-- (select dungeon_id,role_id,to_date(hours_add(date_time,-18)) as done_dt,count(distinct start_time) as '进入次数'
-- from myth_server.server_enter_dungeon
-- where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
-- and game_type = 2 
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
-- group by 1,2,3
-- ) c1
-- where 进入次数 > 1
-- group by 1,2,3 
-- ) as c
-- left join 
-- (select a.role_id as role_id,done_dt,a.dungeon_id as dungeon_id,battle_result
-- from
-- (select dungeon_id,role_id,to_date(hours_add(date_time,-18)) as done_dt,start_time
-- from myth_server.server_enter_dungeon
-- where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
-- and game_type = 2 
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
-- group by 1,2,3,4) a 
-- left join 
-- (select dungeon_id,role_id,battle_result,log_time,start_time
-- from myth_server.server_dungeon_end
-- where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
-- and game_type = 2 
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
-- group by 1,2,3,4,5) b 
-- on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time = b.start_time
-- where battle_result = 1 -- 有成功日志的
-- group by 1,2,3,4
-- ) as d 
-- on c.dungeon_id=d.dungeon_id and c.role_id=d.role_id and c.done_dt=d.done_dt
-- group by 1,2,3
-- ) as f 
-- on a.role_id = f.role_id 
-- where datediff(f.done_dt,a.birth_dt) <${lifeTime}
-- group by 1
-- order by 1



-- -- 最高关卡停留且无通关记录的人数且未去其他玩法
-- left join 
-- (select role_id,dungeon_id,enter_dt,sum(标签) as num--,sum(是否死亡) as die_or_not
-- from
-- (select c.role_id,c.enter_dt,dungeon_id,玩法类型,标签--,是否死亡
-- from

-- (select c3.role_id,enter_dt,c2.dungeon_id,end_time,标签--,是否死亡 -- 最高关卡且无通关记录的玩家
-- from
-- (select role_id,enter_dt,dungeon_id,start_time
-- from
-- (select to_date(hours_add(date_time,-18)) as enter_dt,role_id,start_time,dungeon_id,row_number() over(partition by role_id order by log_time desc) as num
-- from myth_server.server_enter_dungeon
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and game_type = 2 
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
-- ) c1 
-- where num = 1
-- ) c2

-- left join
-- (
-- select dungeon_id,role_id,start_time,end_time,标签--,是否死亡
-- from
-- (
-- select a.role_id,a.start_time,a.dungeon_id,end_time,1 as '标签',是否死亡
-- from
-- (select dungeon_id,role_id,to_date(hours_add(date_time,-18)) as done_dt,start_time
-- from myth_server.server_enter_dungeon
-- where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
-- and game_type = 2
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
-- group by 1,2,3,4) a 
-- left join 
-- (select dungeon_id,role_id,battle_result,log_time as end_time,start_time,
--         case when cast(split_part(remain_hp,',',1) as int) = 0 then 1 -- 死亡
--              else 2 --主动退出
--              end as '是否死亡'
-- from myth_server.server_dungeon_end
-- where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
-- and game_type = 2
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
-- group by 1,2,3,4,5,6) b 
-- on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time = b.start_time
-- where battle_result = 2 -- 有失败日志的

-- union all

-- select a.role_id,a.start_time,a.dungeon_id,end_time,2 as '标签',0 as '是否死亡'
-- from
-- (select dungeon_id,role_id,to_date(hours_add(date_time,-18)) as done_dt,start_time
-- from myth_server.server_enter_dungeon
-- where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
-- and game_type = 2
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
-- group by 1,2,3,4) a 
-- left join 
-- (select dungeon_id,role_id,battle_result,log_time as end_time,start_time
-- from myth_server.server_dungeon_end
-- where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
-- and game_type = 2
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
-- group by 1,2,3,4,5) b 
-- on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time = b.start_time
-- where battle_result is null -- 无日志的
-- ) c4
-- group by 1,2,3,4,5
-- ) c3 
-- on c2.role_id = c3.role_id and c2.dungeon_id=c3.dungeon_id and c2.start_time = c3.start_time
-- group by 1,2,3,4,5
-- ) as c

-- left join
-- (
-- select role_id,to_date(hours_add(date_time,-18)) as enter_dt,start_time,
-- case game_type 
--            when 3 then '战役'
--            when 4 then '竞技场'
--            when 6 then '远古战场'
--            when 7 then '地精宝库'
--            when 8 then '诸神试炼'
--            when 9 then '诸神试炼'
--            when 10 then '诸神试炼'
--            when 11 then '诸神试炼'
--            when 12 then '诸神试炼'
--            when 13 then '诸神试炼'
--            when 14 then '宝石矿坑'
--            when 16 then '公会领主'
--            when 17 then '无尽深渊'
--            when 18 then '公会远征'
--            when 19 then '次元危机'
--            when 20 then '专属副本'
--            when 21 then '公会争霸'
--            when 22 then '地狱竞技场'
--            else 'others'
--            end as '玩法类型'
-- from myth_server.server_enter_dungeon
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and game_type in (3,4,6,7,8,9,10,11,12,13,14,16,17,18,19,20,21,22)
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
-- ) as d
-- on c.role_id = d.role_id and c.enter_dt = d.enter_dt and d.start_time > c.end_time
-- group by 1,2,3,4,5
-- ) as e  
-- where 玩法类型 is null
-- group by 1,2,3
-- ) f
-- on a.role_id = f.role_id and datediff(enter_dt,birth_dt)+1 <= ${life_time}
-- ) as g
-- group by 1,2
-- order by 1,2




-- -- 最高关卡停留且无通关记录的人数且未去其他玩法,7天登录过的玩家
-- left join 
-- (select role_id,dungeon_id,enter_dt,sum(标签) as num
-- from
-- (select c.role_id,c.enter_dt,dungeon_id,玩法类型,标签
-- from

-- (select c3.role_id,enter_dt,c2.dungeon_id,end_time,标签 -- 最高关卡且无通关记录的玩家
-- from
-- (select role_id,enter_dt,dungeon_id,start_time
-- from
-- (select to_date(hours_add(date_time,-18)) as enter_dt,role_id,start_time,dungeon_id,row_number() over(partition by role_id order by log_time desc) as num
-- from myth_server.server_enter_dungeon
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and game_type = 2 
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
-- ) c1 
-- where num = 1
-- ) c2

-- left join
-- (
-- select dungeon_id,role_id,start_time,end_time,标签
-- from
-- (
-- select a.role_id,a.start_time,a.dungeon_id,end_time,1 as '标签'
-- from
-- (select dungeon_id,role_id,to_date(hours_add(date_time,-18)) as done_dt,start_time
-- from myth_server.server_enter_dungeon
-- where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
-- and game_type = 2
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
-- group by 1,2,3,4) a 
-- left join 
-- (select dungeon_id,role_id,battle_result,log_time as end_time,start_time
-- from myth_server.server_dungeon_end
-- where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
-- and game_type = 2
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
-- group by 1,2,3,4,5) b 
-- on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time = b.start_time
-- where battle_result = 2 -- 有失败日志的

-- union all

-- select a.role_id,a.start_time,a.dungeon_id,end_time,2 as '标签'
-- from
-- (select dungeon_id,role_id,to_date(hours_add(date_time,-18)) as done_dt,start_time
-- from myth_server.server_enter_dungeon
-- where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
-- and game_type = 2
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
-- group by 1,2,3,4) a 
-- left join 
-- (select dungeon_id,role_id,battle_result,log_time as end_time,start_time
-- from myth_server.server_dungeon_end
-- where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
-- and game_type = 2
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
-- group by 1,2,3,4,5) b 
-- on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time = b.start_time
-- where battle_result is null -- 无日志的
-- ) c4
-- group by 1,2,3,4,5
-- ) c3 
-- on c2.role_id = c3.role_id and c2.dungeon_id=c3.dungeon_id and c2.start_time = c3.start_time
-- group by 1,2,3,4,5
-- ) as c

-- left join
-- (
-- select role_id,to_date(hours_add(date_time,-18)) as enter_dt,start_time,
-- case game_type 
--            when 3 then '战役'
--            when 4 then '竞技场'
--            when 6 then '远古战场'
--            when 7 then '地精宝库'
--            when 8 then '诸神试炼'
--            when 9 then '诸神试炼'
--            when 10 then '诸神试炼'
--            when 11 then '诸神试炼'
--            when 12 then '诸神试炼'
--            when 13 then '诸神试炼'
--            when 14 then '宝石矿坑'
--            when 16 then '公会领主'
--            when 17 then '无尽深渊'
--            when 18 then '公会远征'
--            when 19 then '次元危机'
--            when 20 then '专属副本'
--            when 21 then '公会争霸'
--            when 22 then '地狱竞技场'
--            else 'others'
--            end as '玩法类型'
-- from myth_server.server_enter_dungeon
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and game_type in (3,4,6,7,8,9,10,11,12,13,14,16,17,18,19,20,21,22)
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
-- ) as d
-- on c.role_id = d.role_id and c.enter_dt = d.enter_dt and d.start_time > c.end_time
-- group by 1,2,3,4,5
-- ) as e  
-- where 玩法类型 is null
-- group by 1,2,3
-- ) f
-- on a.role_id = f.role_id and datediff(enter_dt,birth_dt)+1 <= ${life_time}
-- group by 1,2,3,4
-- ) a

-- left join 
-- (
-- select role_id,to_date(hours_add(date_time,-18)) as login_dt
-- from myth.server_role_login
-- where day_time>=${beginDate} and day_time<=${doneDate} 
-- and server_id in (${serverIds}) 
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
-- ) d
-- on a.role_id = d.role_id and login_dt>enter_dt
-- group by 1,2
-- order by 1



left join 
-- 时长 通关-死亡-主动退出remain_hp 是否为0
(select dungeon_id,role_id,start_time,battle_result,battle_time,auto_battle,done_dt,cast(split_part(remain_hp,',',1) as int) as remain_hp
from
(select a.dungeon_id,a.role_id,a.start_time,battle_result,battle_time,auto_battle,done_dt,remain_hp
from 
(select dungeon_id,role_id,start_time,to_date(hours_add(date_time,-18)) as done_dt
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 2 
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
group by 1,2,3,4
) as a
left join     
(select dungeon_id,role_id,start_time,battle_result,
        case when battle_time is null then '无日志'
             when battle_time/60 >=2  then '1超时'
             when battle_time/60 >=1   and battle_time/60 < 2     then '2困难'
             when battle_time/60 >=0.5 and battle_time/60 < 1   then '3较难'
             when battle_time/60 >=0   and battle_time/60 < 0.5  then '4一般'
             else '无日志'
        end as battle_time,auto_battle,remain_hp
from myth_server.server_dungeon_end
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 2
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
group by 1,2,3,4,5,6,7
) b 
on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time=b.start_time
order by a.role_id,a.start_time asc 
) as e  
group by 1,2,3,4,5,6,7,8
) as b 
on a.role_id = b.role_id

where datediff(done_dt,birth_dt) < ${lifeTime}
group by 1
order by 1






当日停留用户的次日通关率
select birth_dt,country,max_dungeon,
count(distinct case when battle_result=1  then a.role_id else null end )as '通关玩家',
count(distinct a.role_id) as '停留玩家'
from 
(select birth_dt,country,a.role_id,done_dt,max_dungeon
from 
(  --新增
select role_id,birth_dt,country
from
(select role_id,device_id,to_date(hours_add(date_time,-18)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(hours_add(date_time,-18)) as device_birth_dt, 
     case when country in ('PH','MY') then 'PH+MY'
     when country in ('GB','IE','CA')  then 'GB+CA'
     end as country
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id --and a1.birth_dt = a2.device_birth_dt
) as a
left join 
(
select role_id,to_date(hours_add(date_time,-18)) as done_dt,max(dungeon_id) as max_dungeon
from myth_server.server_dungeon_end
where day_time>=${beginDate} and day_time<=${endDate}
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
and game_type =2 
and battle_result =1 
group by 1,2
) b 
on a.role_id = b.role_id 
where datediff(done_dt,birth_dt) < ${lifeTime}
) a 
left join 
(select c.role_id,c.end_dt,c.dungeon_id,battle_result
from 
(
select role_id,to_date(hours_add(date_time,-18)) as end_dt,dungeon_id,start_time 
from myth_server.server_enter_dungeon
where day_time>=${beginDate} and day_time<=${end2Date}
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
and game_type =2 
) c 
left join 
(
select role_id,to_date(hours_add(date_time,-18)) as end_dt,battle_result,dungeon_id,start_time
from myth_server.server_dungeon_end
where day_time>=${beginDate} and day_time<=${end2Date}
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
and game_type =2 
) d 
on c.role_id = d.role_id and c.end_dt=d.end_dt and c.dungeon_id=d.dungeon_id and c.start_time = d.start_time
) e  
on a.role_id= e.role_id and a.max_dungeon=e.dungeon_id-1
where datediff(end_dt,done_dt)=1
group by 1,2,3









秘境分职业
select dungeon_id,case role_type 
             when   '1' then '3雷'
             when   '2' then '1瓦'
             when   '3' then '2齐'
             when   '4' then '4乌'
             when   '5' then '5芙'
        end as role_type,

-- -- 战力压制 按照颜色 只算俩数据
-- count(distinct case when suppression = '绿色' then start_time else null end) as '绿色进入关卡次数',
-- count(distinct case when battle_result=1 and suppression = '绿色' then b.role_id else null end ) / count(distinct case when suppression = '绿色' then start_time else null end) as '绿色通关率',
-- count(distinct case when suppression = '白色' then start_time else null end) as '白色进入关卡次数',
-- count(distinct case when battle_result=1 and suppression = '白色' then b.role_id else null end ) / count(distinct case when suppression = '白色' then start_time else null end) as '白色通关率',
-- count(distinct case when suppression = '黄色' then start_time else null end) as '黄色进入关卡次数',
-- count(distinct case when battle_result=1 and suppression = '黄色' then b.role_id else null end ) / count(distinct case when suppression = '黄色' then start_time else null end) as '黄色通关率',
-- count(distinct case when suppression = '橙色' then start_time else null end) as '橙色进入关卡次数',
-- count(distinct case when battle_result=1 and suppression = '橙色' then b.role_id else null end ) / count(distinct case when suppression = '橙色' then start_time else null end) as '橙色通关率',
-- count(distinct case when suppression = '红色' then start_time else null end) as '红色进入关卡次数',
-- count(distinct case when battle_result=1 and suppression = '红色' then b.role_id else null end ) / count(distinct case when suppression = '红色' then start_time else null end) as '红色通关率',
-- -- 整体
-- count(distinct a.role_id) as '进入关卡人数',
-- count(distinct case when battle_result=1 then b.role_id else null end ) as '通关人数',
-- count(distinct case when battle_result=1 then b.role_id else null end ) / count(distinct a.role_id) as '通关率',
-- count(distinct case when battle_result=2 then b.role_id else null end ) as '失败人数',
-- count(distinct case when battle_result=2 then b.role_id else null end ) / count(distinct a.role_id) as '失败率',
-- count(distinct case when battle_result is null then b.role_id else null end ) as '无日志人数',
-- count(distinct case when battle_result is null then b.role_id else null end ) / count(distinct a.role_id) as '无日志率'


-- 最高关卡停留且无通关记录的人数且未去其他玩法
num,--die_or_not,
count(distinct g.role_id)

-- 最高关卡停留且无通关记录的人数且未去其他玩法,2天登录过的玩家
-- count(distinct case when datediff(login_dt,enter_dt) <= 1 then a.role_id else null end) as '2日内登录角色数' 


from

-- 最高关卡停留且无通关记录的人数且未去其他玩法,7天登录过的玩家
(select a.role_id,role_type,enter_dt,dungeon_id,num--,die_or_not
 from


(  --新增
select role_id,birth_dt,country
from
(select role_id,device_id,to_date(hours_add(date_time,-18)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(hours_add(date_time,-18)) as device_birth_dt, 
     case when country in ('PH','MY') then 'PH+MY'
     when country in ('GB','IE','CA')  then 'GB+CA'
     end as country
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id --and a1.birth_dt = a2.device_birth_dt
) as a


--  -- 进入关卡人数、通关率
-- left join
--  -- 关卡参与情况
-- (select a.dungeon_id,a.role_id,a.start_time,role_type,battle_result,battle_time,auto_battle,done_dt,suppression
-- from 
-- (select dungeon_id,role_id,role_type,start_time,to_date(hours_add(date_time,-18)) as done_dt
-- from myth_server.server_enter_dungeon
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and game_type = 2
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
-- group by 1,2,3,4,5
-- ) as a
-- left join     
-- (select dungeon_id,role_id,start_time,battle_result,battle_time,auto_battle,
--         case when suppression = 2 then '绿色'
--              when suppression >= 3 and suppression <= 13 then '白色'
--              when suppression >= 14 and suppression <= 23 then '黄色'
--              when suppression >= 24 and suppression <= 53 then '橙色'
--              when suppression >= 54 and suppression <= 83 then '红色'
--         end as suppression
-- from myth_server.server_dungeon_end
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and game_type = 2
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
-- group by 1,2,3,4,5,6,7
-- ) c 
-- on a.dungeon_id=c.dungeon_id and a.role_id=c.role_id and a.start_time=c.start_time 
-- ) as b 
-- on a.role_id = b.role_id and datediff(done_dt,birth_dt)+ 1 <= ${left_time}
-- where b.role_id is not null 
-- group by 1,2 order by 1,2




-- 最高关卡停留且无通关记录的人数且未去其他玩法
left join 
(select role_id,role_type,dungeon_id,enter_dt,sum(标签) as num--,sum(是否死亡) as die_or_not
from
(select c.role_id,role_type,c.enter_dt,dungeon_id,玩法类型,标签--,是否死亡
from

(select c3.role_id,role_type,enter_dt,c2.dungeon_id,end_time,标签--,是否死亡 -- 最高关卡且无通关记录的玩家
from
(select role_id,role_type,enter_dt,dungeon_id,start_time
from
(select to_date(hours_add(date_time,-18)) as enter_dt,role_id,role_type,start_time,dungeon_id,row_number() over(partition by role_id order by log_time desc) as num
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 2 
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) c1 
where num = 1
) c2

left join
(
select dungeon_id,role_id,start_time,end_time,标签--,是否死亡
from
(
select a.role_id,a.start_time,a.dungeon_id,end_time,1 as '标签',是否死亡
from
(select dungeon_id,role_id,to_date(hours_add(date_time,-18)) as done_dt,start_time
from myth_server.server_enter_dungeon
where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
and game_type = 2
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
group by 1,2,3,4) a 
left join 
(select dungeon_id,role_id,battle_result,log_time as end_time,start_time,
        case when cast(split_part(remain_hp,',',1) as int) = 0 then 1 -- 死亡
             else 2 --主动退出
             end as '是否死亡'
from myth_server.server_dungeon_end
where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
and game_type = 2
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
group by 1,2,3,4,5,6) b 
on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time = b.start_time
where battle_result = 2 -- 有失败日志的

union all

select a.role_id,a.start_time,a.dungeon_id,end_time,2 as '标签',0 as '是否死亡'
from
(select dungeon_id,role_id,to_date(hours_add(date_time,-18)) as done_dt,start_time
from myth_server.server_enter_dungeon
where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
and game_type = 2
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
group by 1,2,3,4) a 
left join 
(select dungeon_id,role_id,battle_result,log_time as end_time,start_time
from myth_server.server_dungeon_end
where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
and game_type = 2
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
group by 1,2,3,4,5) b 
on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time = b.start_time
where battle_result is null -- 无日志的
) c4
group by 1,2,3,4,5
) c3 
on c2.role_id = c3.role_id and c2.dungeon_id=c3.dungeon_id and c2.start_time = c3.start_time
group by 1,2,3,4,5,6
) as c

left join
(
select role_id,to_date(hours_add(date_time,-18)) as enter_dt,start_time,
case game_type 
           when 3 then '战役'
           when 4 then '竞技场'
           when 6 then '远古战场'
           when 7 then '地精宝库'
           when 8 then '诸神试炼'
           when 9 then '诸神试炼'
           when 10 then '诸神试炼'
           when 11 then '诸神试炼'
           when 12 then '诸神试炼'
           when 13 then '诸神试炼'
           when 14 then '宝石矿坑'
           when 16 then '公会领主'
           when 17 then '无尽深渊'
           when 18 then '公会远征'
           when 19 then '次元危机'
           when 20 then '专属副本'
           when 21 then '公会争霸'
           when 22 then '地狱竞技场'
           else 'others'
           end as '玩法类型'
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type in (3,4,6,7,8,9,10,11,12,13,14,16,17,18,19,20,21,22)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) as d
on c.role_id = d.role_id and c.enter_dt = d.enter_dt and d.start_time > c.end_time
group by 1,2,3,4,5,6
) as e  
where 玩法类型 is null
group by 1,2,3,4
) f
on a.role_id = f.role_id and datediff(enter_dt,birth_dt)+1 <= ${life_time}
) as g
group by 1,2,3
order by 1,2,3


-- -- 最高关卡停留且无通关记录的人数且未去其他玩法,3天登录过的玩家
-- left join 
-- (select role_id,role_type,dungeon_id,enter_dt,sum(标签) as num
-- from
-- (select c.role_id,role_type,c.enter_dt,dungeon_id,玩法类型,标签
-- from

-- (select c3.role_id,role_type,enter_dt,c2.dungeon_id,end_time,标签 -- 最高关卡且无通关记录的玩家
-- from
-- (select role_id,role_type,enter_dt,dungeon_id,start_time
-- from
-- (select to_date(hours_add(date_time,-18)) as enter_dt,role_id,role_type,start_time,dungeon_id,row_number() over(partition by role_id order by log_time desc) as num
-- from myth_server.server_enter_dungeon
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and game_type = 2 
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
-- ) c1 
-- where num = 1
-- ) c2

-- left join
-- (
-- select dungeon_id,role_id,start_time,end_time,标签
-- from
-- (
-- select a.role_id,a.start_time,a.dungeon_id,end_time,1 as '标签'
-- from
-- (select dungeon_id,role_id,to_date(hours_add(date_time,-18)) as done_dt,start_time
-- from myth_server.server_enter_dungeon
-- where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
-- and game_type = 2
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
-- group by 1,2,3,4) a 
-- left join 
-- (select dungeon_id,role_id,battle_result,log_time as end_time,start_time
-- from myth_server.server_dungeon_end
-- where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
-- and game_type = 2
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
-- group by 1,2,3,4,5) b 
-- on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time = b.start_time
-- where battle_result = 2 -- 有失败日志的

-- union all

-- select a.role_id,a.start_time,a.dungeon_id,end_time,2 as '标签'
-- from
-- (select dungeon_id,role_id,to_date(hours_add(date_time,-18)) as done_dt,start_time
-- from myth_server.server_enter_dungeon
-- where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
-- and game_type = 2
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
-- group by 1,2,3,4) a 
-- left join 
-- (select dungeon_id,role_id,battle_result,log_time as end_time,start_time
-- from myth_server.server_dungeon_end
-- where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
-- and game_type = 2
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
-- group by 1,2,3,4,5) b 
-- on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time = b.start_time
-- where battle_result is null -- 无日志的
-- ) c4
-- group by 1,2,3,4,5
-- ) c3 
-- on c2.role_id = c3.role_id and c2.dungeon_id=c3.dungeon_id and c2.start_time = c3.start_time
-- group by 1,2,3,4,5,6
-- ) as c

-- left join
-- (
-- select role_id,to_date(hours_add(date_time,-18)) as enter_dt,start_time,
-- case game_type 
--            when 3 then '战役'
--            when 4 then '竞技场'
--            when 6 then '远古战场'
--            when 7 then '地精宝库'
--            when 8 then '诸神试炼'
--            when 9 then '诸神试炼'
--            when 10 then '诸神试炼'
--            when 11 then '诸神试炼'
--            when 12 then '诸神试炼'
--            when 13 then '诸神试炼'
--            when 14 then '宝石矿坑'
--            when 16 then '公会领主'
--            when 17 then '无尽深渊'
--            when 18 then '公会远征'
--            when 19 then '次元危机'
--            when 20 then '专属副本'
--            when 21 then '公会争霸'
--            when 22 then '地狱竞技场'
--            else 'others'
--            end as '玩法类型'
-- from myth_server.server_enter_dungeon
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and game_type in (3,4,6,7,8,9,10,11,12,13,14,16,17,18,19,20,21,22)
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
-- ) as d
-- on c.role_id = d.role_id and c.enter_dt = d.enter_dt and d.start_time > c.end_time
-- group by 1,2,3,4,5,6
-- ) as e  
-- where 玩法类型 is null
-- group by 1,2,3,4
-- ) f
-- on a.role_id = f.role_id and datediff(enter_dt,birth_dt)+1 <= ${life_time}
-- group by 1,2,3,4,5
-- ) a

-- left join 
-- (
-- select role_id,to_date(hours_add(date_time,-18)) as login_dt
-- from myth.server_role_login
-- where day_time>=${beginDate} and day_time<=${doneDate} 
-- and server_id in (${serverIds}) 
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
-- ) d
-- on a.role_id = d.role_id and login_dt>enter_dt
-- group by 1,2,3
-- order by 1







-- 秘境分职业 付费档位的平均战力-中位数
select dungeon_id,case role_type 
             when   '1' then '3雷'
             when   '2' then '1瓦'
             when   '3' then '2齐'
             when   '4' then '4乌'
             when   '5' then '5芙'
             when   '6' then '6贝'
             when   '7' then '7海'
         end as role_type,vip,appx_median(battle_points)
from 
(select dungeon_id,vip,battle_points,a.role_id,role_type
from

(select birth_dt,role_id,
case when total_pay<=8                    then 1
     when total_pay>8  and total_pay<=70  then 2
     when total_pay>70                    then 3 
     else 0 
     end as vip --D7 
from 
(select birth_dt,a.role_id
,sum(case when datediff(vip_dt,birth_dt)< ${lifeTime}  then pay else 0 end ) as 'total_pay'
from

(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(hours_add(date_time,-18)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(hours_add(date_time,-18)) as device_birth_dt
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
select role_id,to_date(hours_add(date_time,-18)) as vip_dt,sum(pay_price) pay 
from myth.order_pay
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
group by 1,2 ) b 
on a.role_id =b.role_id
group by 1,2
) a1 
) a 

left join
(select dungeon_id,role_id,role_type,battle_points,to_date(hours_add(date_time,-18)) as done_dt
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 2 
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
group by 1,2,3,4,5
) as b
on a.role_id = b.role_id
where datediff(b.done_dt,a.birth_dt) < ${lifeTime}
) as new
group by 1,2,3
order by 1,2,3



当日停留用户的次日通关率
select birth_dt,case role_type 
             when   '1' then '3雷'
             when   '2' then '1瓦'
             when   '3' then '2齐'
             when   '4' then '4乌'
             when   '5' then '5芙'
             when   '6' then '6贝'
             when   '7' then '7海'
        end as role_type,max_dungeon,
count(distinct case when battle_result=1  then a.role_id else null end )as '通关玩家',
count(distinct a.role_id) as '停留玩家'
from 
(select birth_dt,country,a.role_id,done_dt,role_type,max_dungeon
from 
(  --新增
select role_id,birth_dt,country
from
(select role_id,device_id,to_date(hours_add(date_time,-18)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(hours_add(date_time,-18)) as device_birth_dt, 
     case when country in ('PH','MY') then 'PH+MY'
     when country in ('GB','IE','CA')  then 'GB+CA'
     end as country
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id --and a1.birth_dt = a2.device_birth_dt
) as a
left join 
(
select role_id,to_date(hours_add(date_time,-18)) as done_dt,role_type,max(dungeon_id) as max_dungeon
from myth_server.server_dungeon_end
where day_time>=${beginDate} and day_time<=${endDate}
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
and game_type =2 
and battle_result =1 
group by 1,2,3
) b 
on a.role_id = b.role_id 
where datediff(done_dt,birth_dt) < ${lifeTime}
) a 
left join 
(select c.role_id,c.end_dt,c.dungeon_id,battle_result
from 
(
select role_id,to_date(hours_add(date_time,-18)) as end_dt,dungeon_id,start_time 
from myth_server.server_enter_dungeon
where day_time>=${beginDate} and day_time<=${end2Date}
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
and game_type =2 
) c 
left join 
(
select role_id,to_date(hours_add(date_time,-18)) as end_dt,battle_result,dungeon_id,start_time
from myth_server.server_dungeon_end
where day_time>=${beginDate} and day_time<=${end2Date}
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
and game_type =2 
) d 
on c.role_id = d.role_id and c.end_dt=d.end_dt and c.dungeon_id=d.dungeon_id and c.start_time = d.start_time
) e  
on a.role_id= e.role_id and a.max_dungeon=e.dungeon_id-1
where datediff(end_dt,done_dt)=1
group by 1,2,3













秘境分主神卡
select dungeon_id,case when god_card_id in (10101,10105,10106,10107,10108,10109,10110,10111,10112,10113,10114,10115,10116) then '奥丁-主神卡'
                       when god_card_id in (20101,20105,20106,20107,20108,20109,20110,20111,20112,20113,20114,20115,20116) then '西芙-主神卡'
                       when god_card_id in (30101,30105,30106,30107,30108,30109,30110,30111,30112,30113,30114,30115,30116) then '弗丽嘉-主神卡'
                       when god_card_id in (40101,40105,40106,40107,40108,40109,40110,40111,40112,40113,40114,40115,40116) then '海姆达尔-主神卡'
                       when god_card_id in (50101,50105,50106,50107,50108,50109,50110,50111,50112,50113,50114,50115,50116) then '巴德尔-主神卡'
                       when god_card_id in (60101,60105,60106,60107,60108,60109,60110,60111,60112,60113,60114,60115,60116) then '瓦尔基里-主神卡'
                  else null
                  end as god_card_name,

-- -- 战力压制 按照颜色 只算俩数据
-- count(distinct case when suppression = '绿色' then start_time else null end) as '绿色进入关卡次数',
-- count(distinct case when battle_result=1 and suppression = '绿色' then b.role_id else null end ) / count(distinct case when suppression = '绿色' then start_time else null end) as '绿色通关率',
-- count(distinct case when suppression = '白色' then start_time else null end) as '白色进入关卡次数',
-- count(distinct case when battle_result=1 and suppression = '白色' then b.role_id else null end ) / count(distinct case when suppression = '白色' then start_time else null end) as '白色通关率',
-- count(distinct case when suppression = '黄色' then start_time else null end) as '黄色进入关卡次数',
-- count(distinct case when battle_result=1 and suppression = '黄色' then b.role_id else null end ) / count(distinct case when suppression = '黄色' then start_time else null end) as '黄色通关率',
-- count(distinct case when suppression = '橙色' then start_time else null end) as '橙色进入关卡次数',
-- count(distinct case when battle_result=1 and suppression = '橙色' then b.role_id else null end ) / count(distinct case when suppression = '橙色' then start_time else null end) as '橙色通关率',
-- count(distinct case when suppression = '红色' then start_time else null end) as '红色进入关卡次数',
-- count(distinct case when battle_result=1 and suppression = '红色' then b.role_id else null end ) / count(distinct case when suppression = '红色' then start_time else null end) as '红色通关率',
-- -- 整体
-- count(distinct a.role_id) as '进入关卡人数',
-- count(distinct case when battle_result=1 then b.role_id else null end ) as '通关人数',
-- count(distinct case when battle_result=1 then b.role_id else null end ) / count(distinct a.role_id) as '通关率',
-- count(distinct case when battle_result=2 then b.role_id else null end ) as '失败人数',
-- count(distinct case when battle_result=2 then b.role_id else null end ) / count(distinct a.role_id) as '失败率',
-- count(distinct case when battle_result is null then b.role_id else null end ) as '无日志人数',
-- count(distinct case when battle_result is null then b.role_id else null end ) / count(distinct a.role_id) as '无日志率'


-- 最高关卡停留且无通关记录的人数且未去其他玩法
num,--die_or_not,
count(distinct g.role_id)

-- 最高关卡停留且无通关记录的人数且未去其他玩法,2天登录过的玩家
-- count(distinct case when datediff(login_dt,enter_dt) <= 1 then a.role_id else null end) as '2日内登录角色数' 


from

-- 最高关卡停留且无通关记录的人数且未去其他玩法,7天登录过的玩家
(select a.role_id,god_card_id,enter_dt,dungeon_id,num--,die_or_not
 from


(  --新增
select role_id,birth_dt,country
from
(select role_id,device_id,to_date(hours_add(date_time,-18)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(hours_add(date_time,-18)) as device_birth_dt,country
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id --and a1.birth_dt = a2.device_birth_dt
) as a


--  -- 进入关卡人数、通关率
-- left join
--  -- 关卡参与情况
-- (select a.dungeon_id,a.role_id,a.start_time,god_card_id,battle_result,battle_time,auto_battle,done_dt,suppression
-- from 
-- (select dungeon_id,role_id,god_card_id,start_time,to_date(hours_add(date_time,-18)) as done_dt
-- from myth_server.server_enter_dungeon
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and game_type = 2
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
-- group by 1,2,3,4,5
-- ) as a
-- left join     
-- (select dungeon_id,role_id,start_time,battle_result,battle_time,auto_battle,
--         case when suppression = 2 then '绿色'
--              when suppression >= 3 and suppression <= 13 then '白色'
--              when suppression >= 14 and suppression <= 23 then '黄色'
--              when suppression >= 24 and suppression <= 53 then '橙色'
--              when suppression >= 54 and suppression <= 83 then '红色'
--         end as suppression
-- from myth_server.server_dungeon_end
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and game_type = 2
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
-- group by 1,2,3,4,5,6,7
-- ) c 
-- on a.dungeon_id=c.dungeon_id and a.role_id=c.role_id and a.start_time=c.start_time 
-- ) as b 
-- on a.role_id = b.role_id and datediff(done_dt,birth_dt)+ 1 <= ${left_time}
-- where b.role_id is not null 
-- group by 1,2 order by 1,2




-- 最高关卡停留且无通关记录的人数且未去其他玩法
left join 
(select role_id,god_card_id,dungeon_id,enter_dt,sum(标签) as num--,sum(是否死亡) as die_or_not
from
(select c.role_id,god_card_id,c.enter_dt,dungeon_id,玩法类型,标签--,是否死亡
from

(select c3.role_id,god_card_id,enter_dt,c2.dungeon_id,end_time,标签--,是否死亡 -- 最高关卡且无通关记录的玩家
from
(select role_id,god_card_id,enter_dt,dungeon_id,start_time
from
(select to_date(hours_add(date_time,-18)) as enter_dt,role_id,god_card_id,start_time,dungeon_id,row_number() over(partition by role_id order by log_time desc) as num
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 2 
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) c1 
where num = 1
) c2

left join
(
select dungeon_id,role_id,start_time,end_time,标签--,是否死亡
from
(
select a.role_id,a.start_time,a.dungeon_id,end_time,1 as '标签',是否死亡
from
(select dungeon_id,role_id,to_date(hours_add(date_time,-18)) as done_dt,start_time
from myth_server.server_enter_dungeon
where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
and game_type = 2
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
group by 1,2,3,4) a 
left join 
(select dungeon_id,role_id,battle_result,log_time as end_time,start_time,
        case when cast(split_part(remain_hp,',',1) as int) = 0 then 1 -- 死亡
             else 2 --主动退出
             end as '是否死亡'
from myth_server.server_dungeon_end
where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
and game_type = 2
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
group by 1,2,3,4,5,6) b 
on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time = b.start_time
where battle_result = 2 -- 有失败日志的

union all

select a.role_id,a.start_time,a.dungeon_id,end_time,2 as '标签',0 as '是否死亡'
from
(select dungeon_id,role_id,to_date(hours_add(date_time,-18)) as done_dt,start_time
from myth_server.server_enter_dungeon
where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
and game_type = 2
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
group by 1,2,3,4) a 
left join 
(select dungeon_id,role_id,battle_result,log_time as end_time,start_time
from myth_server.server_dungeon_end
where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
and game_type = 2
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
group by 1,2,3,4,5) b 
on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time = b.start_time
where battle_result is null -- 无日志的
) c4
group by 1,2,3,4,5
) c3 
on c2.role_id = c3.role_id and c2.dungeon_id=c3.dungeon_id and c2.start_time = c3.start_time
group by 1,2,3,4,5,6
) as c

left join
(
select role_id,to_date(hours_add(date_time,-18)) as enter_dt,start_time,
case game_type 
           when 3 then '战役'
           when 4 then '竞技场'
           when 6 then '远古战场'
           when 7 then '地精宝库'
           when 8 then '诸神试炼'
           when 9 then '诸神试炼'
           when 10 then '诸神试炼'
           when 11 then '诸神试炼'
           when 12 then '诸神试炼'
           when 13 then '诸神试炼'
           when 14 then '宝石矿坑'
           when 16 then '公会领主'
           when 17 then '无尽深渊'
           when 18 then '公会远征'
           when 19 then '次元危机'
           when 20 then '专属副本'
           when 21 then '公会争霸'
           when 22 then '地狱竞技场'
           else 'others'
           end as '玩法类型'
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type in (3,4,6,7,8,9,10,11,12,13,14,16,17,18,19,20,21,22)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) as d
on c.role_id = d.role_id and c.enter_dt = d.enter_dt and d.start_time > c.end_time
group by 1,2,3,4,5,6
) as e  
where 玩法类型 is null
group by 1,2,3,4
) f
on a.role_id = f.role_id and datediff(enter_dt,birth_dt)+1 <= ${life_time}
) as g
group by 1,2,3
order by 1,2,3




-- -- 最高关卡停留且无通关记录的人数且未去其他玩法,3天登录过的玩家
-- left join 
-- (select role_id,god_card_id,dungeon_id,enter_dt,sum(标签) as num
-- from
-- (select c.role_id,god_card_id,c.enter_dt,dungeon_id,玩法类型,标签
-- from

-- (select c3.role_id,god_card_id,enter_dt,c2.dungeon_id,end_time,标签 -- 最高关卡且无通关记录的玩家
-- from
-- (select role_id,god_card_id,enter_dt,dungeon_id,start_time
-- from
-- (select to_date(hours_add(date_time,-18)) as enter_dt,role_id,god_card_id,start_time,dungeon_id,row_number() over(partition by role_id order by log_time desc) as num
-- from myth_server.server_enter_dungeon
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and game_type = 2 
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
-- ) c1 
-- where num = 1
-- ) c2

-- left join
-- (
-- select dungeon_id,role_id,start_time,end_time,标签
-- from
-- (
-- select a.role_id,a.start_time,a.dungeon_id,end_time,1 as '标签'
-- from
-- (select dungeon_id,role_id,to_date(hours_add(date_time,-18)) as done_dt,start_time
-- from myth_server.server_enter_dungeon
-- where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
-- and game_type = 2
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
-- group by 1,2,3,4) a 
-- left join 
-- (select dungeon_id,role_id,battle_result,log_time as end_time,start_time
-- from myth_server.server_dungeon_end
-- where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
-- and game_type = 2
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
-- group by 1,2,3,4,5) b 
-- on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time = b.start_time
-- where battle_result = 2 -- 有失败日志的

-- union all

-- select a.role_id,a.start_time,a.dungeon_id,end_time,2 as '标签'
-- from
-- (select dungeon_id,role_id,to_date(hours_add(date_time,-18)) as done_dt,start_time
-- from myth_server.server_enter_dungeon
-- where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
-- and game_type = 2
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
-- group by 1,2,3,4) a 
-- left join 
-- (select dungeon_id,role_id,battle_result,log_time as end_time,start_time
-- from myth_server.server_dungeon_end
-- where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
-- and game_type = 2
-- and channel_id in (1000,2000)
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
-- group by 1,2,3,4,5) b 
-- on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time = b.start_time
-- where battle_result is null -- 无日志的
-- ) c4
-- group by 1,2,3,4,5
-- ) c3 
-- on c2.role_id = c3.role_id and c2.dungeon_id=c3.dungeon_id and c2.start_time = c3.start_time
-- group by 1,2,3,4,5,6
-- ) as c

-- left join
-- (
-- select role_id,to_date(hours_add(date_time,-18)) as enter_dt,start_time,
-- case game_type 
--            when 3 then '战役'
--            when 4 then '竞技场'
--            when 6 then '远古战场'
--            when 7 then '地精宝库'
--            when 8 then '诸神试炼'
--            when 9 then '诸神试炼'
--            when 10 then '诸神试炼'
--            when 11 then '诸神试炼'
--            when 12 then '诸神试炼'
--            when 13 then '诸神试炼'
--            when 14 then '宝石矿坑'
--            when 16 then '公会领主'
--            when 17 then '无尽深渊'
--            when 18 then '公会远征'
--            when 19 then '次元危机'
--            when 20 then '专属副本'
--            when 21 then '公会争霸'
--            when 22 then '地狱竞技场'
--            else 'others'
--            end as '玩法类型'
-- from myth_server.server_enter_dungeon
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and game_type in (3,4,6,7,8,9,10,11,12,13,14,16,17,18,19,20,21,22)
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
-- ) as d
-- on c.role_id = d.role_id and c.enter_dt = d.enter_dt and d.start_time > c.end_time
-- group by 1,2,3,4,5,6
-- ) as e  
-- where 玩法类型 is null
-- group by 1,2,3,4
-- ) f
-- on a.role_id = f.role_id and datediff(enter_dt,birth_dt)+1 <= ${life_time}
-- group by 1,2,3,4,5
-- ) a

-- left join 
-- (
-- select role_id,to_date(hours_add(date_time,-18)) as login_dt
-- from myth.server_role_login
-- where day_time>=${beginDate} and day_time<=${doneDate} 
-- and server_id in (${serverIds}) 
-- and version_name in ('1.5.1','1.5.2')
-- and country not in ('CN','HK')
-- ) d
-- on a.role_id = d.role_id and login_dt>enter_dt
-- group by 1,2,3
-- order by 1







-- 秘境分主神卡 付费档位的平均战力-中位数
select dungeon_id,case when god_card_id in (10101,10105,10106,10107,10108,10109,10110,10111,10112,10113,10114,10115,10116) then '奥丁-主神卡'
                       when god_card_id in (20101,20105,20106,20107,20108,20109,20110,20111,20112,20113,20114,20115,20116) then '西芙-主神卡'
                       when god_card_id in (30101,30105,30106,30107,30108,30109,30110,30111,30112,30113,30114,30115,30116) then '弗丽嘉-主神卡'
                       when god_card_id in (40101,40105,40106,40107,40108,40109,40110,40111,40112,40113,40114,40115,40116) then '海姆达尔-主神卡'
                       when god_card_id in (50101,50105,50106,50107,50108,50109,50110,50111,50112,50113,50114,50115,50116) then '巴德尔-主神卡'
                       when god_card_id in (60101,60105,60106,60107,60108,60109,60110,60111,60112,60113,60114,60115,60116) then '瓦尔基里-主神卡'
                  else null
                  end as god_card_name,vip,appx_median(battle_points)
from 
(select dungeon_id,vip,battle_points,a.role_id,god_card_id
from

(select birth_dt,role_id,
case when total_pay<=8                    then 1
     when total_pay>8  and total_pay<=70  then 2
     when total_pay>70                    then 3 
     else 0 
     end as vip --D7 
from 
(select birth_dt,a.role_id
,sum(case when datediff(vip_dt,birth_dt)< ${lifeTime}  then pay else 0 end ) as 'total_pay'
from

(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(hours_add(date_time,-18)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(hours_add(date_time,-18)) as device_birth_dt
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
select role_id,to_date(hours_add(date_time,-18)) as vip_dt,sum(pay_price) pay 
from myth.order_pay
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
group by 1,2 ) b 
on a.role_id =b.role_id
group by 1,2
) a1 
) a 

left join
(select dungeon_id,role_id,god_card_id,battle_points,to_date(hours_add(date_time,-18)) as done_dt
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 2 
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
group by 1,2,3,4,5
) as b
on a.role_id = b.role_id
where datediff(b.done_dt,a.birth_dt) < ${lifeTime}
) as new
group by 1,2,3
order by 1,2,3







当日停留用户的次日通关率
select birth_dt,  case when god_card_id in (10101,10105,10106,10107,10108,10109,10110,10111,10112,10113,10114,10115,10116) then '奥丁-主神卡'
                       when god_card_id in (20101,20105,20106,20107,20108,20109,20110,20111,20112,20113,20114,20115,20116) then '西芙-主神卡'
                       when god_card_id in (30101,30105,30106,30107,30108,30109,30110,30111,30112,30113,30114,30115,30116) then '弗丽嘉-主神卡'
                       when god_card_id in (40101,40105,40106,40107,40108,40109,40110,40111,40112,40113,40114,40115,40116) then '海姆达尔-主神卡'
                       when god_card_id in (50101,50105,50106,50107,50108,50109,50110,50111,50112,50113,50114,50115,50116) then '巴德尔-主神卡'
                       when god_card_id in (60101,60105,60106,60107,60108,60109,60110,60111,60112,60113,60114,60115,60116) then '瓦尔基里-主神卡'
                  else null
                  end as god_card_name,max_dungeon,
count(distinct case when battle_result=1  then a.role_id else null end )as '通关玩家',
count(distinct a.role_id) as '停留玩家'
from 
(select birth_dt,country,a.role_id,done_dt,max_dungeon
from 
(  --新增
select role_id,birth_dt,country
from
(select role_id,device_id,to_date(hours_add(date_time,-18)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(hours_add(date_time,-18)) as device_birth_dt, 
     case when country in ('PH','MY') then 'PH+MY'
     when country in ('GB','IE','CA')  then 'GB+CA'
     end as country
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id --and a1.birth_dt = a2.device_birth_dt
) as a
left join 
(
select role_id,to_date(hours_add(date_time,-18)) as done_dt,max(dungeon_id) as max_dungeon
from myth_server.server_dungeon_end
where day_time>=${beginDate} and day_time<=${endDate}
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
and game_type =2
and battle_result =1 
group by 1,2
) b 
on a.role_id = b.role_id 
where datediff(done_dt,birth_dt) < ${lifeTime}
) a 
left join 
(select c.role_id,c.end_dt,c.dungeon_id,battle_result,god_card_id
from 
(
select role_id,to_date(hours_add(date_time,-18)) as end_dt,dungeon_id,start_time,god_card_id 
from myth_server.server_enter_dungeon
where day_time>=${beginDate} and day_time<=${end2Date}
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
and game_type =2 
) c 
left join 
(
select role_id,to_date(hours_add(date_time,-18)) as end_dt,battle_result,dungeon_id,start_time
from myth_server.server_dungeon_end
where day_time>=${beginDate} and day_time<=${end2Date}
and version_name in ('1.5.1','1.5.2')
and country not in ('CN','HK')
and game_type =2
) d 
on c.role_id = d.role_id and c.end_dt=d.end_dt and c.dungeon_id=d.dungeon_id and c.start_time = d.start_time
) e  
on a.role_id= e.role_id and a.max_dungeon=e.dungeon_id-1
where datediff(end_dt,done_dt)=1
group by 1,2,3



