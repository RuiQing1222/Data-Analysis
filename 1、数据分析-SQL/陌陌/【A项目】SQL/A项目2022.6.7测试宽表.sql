select a.role_id as role_id
       ,a.date_time as '注册时间'
       ,a.day_time as '注册日期'
       ,a.country as '注册国家'
       ,case when 广告自然 is null then '自然量'
             else '广告量'
             end as '广告自然'
       ,case when by_day = 1 then '是'
            else '否'
       end as '次日留存'
       ,cishu as '首日登录次数'
       ,首日在线时长
       ,装备强化次数
       ,公会建设次数
       ,首日抽卡总次数
       ,首日道具抽卡次数
       ,首日钻石抽卡数
       ,首日单抽次数
       ,首日十连次数
       ,首日通关最高关卡
       ,首日进入最高关卡
       ,count_pvp as '首日PVP次数'
       ,pvp as '首日PVP胜率'
       ,首日公会领主伤害
       ,首日公会领主次数
       ,首日通关地精宝库最高关卡
       ,首日进入地精宝库最高关卡
       ,首日通关秘境最高关卡
       ,首日进入秘境最高关卡
       ,首日最高战力
       ,首日金币获得
       ,首日金币消耗
       ,首日钻石获得
       ,首日钻石消耗
       ,首日星辰密匙获得
       ,首日星辰密匙消耗
       ,首日神力水晶获得
       ,首日神力水晶消耗
       ,首日公会币获得
       ,首日公会币消耗
from


(
select a.role_id as role_id,a.device_id as device_id, a.date_time as date_time, a.day_time as day_time,
       a.country as country,
       datediff(b.day_times,a.day_times) as by_day
from
(
select a.device_id as device_id, role_id,date_time,day_time,country,to_date(cast(date_time as timestamp)) as day_times
from
(select day_time,device_id,date_time,country
from myth.device_activate where day_time between ${beginDate} and ${endDate}
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
group by 1,2,3,4
) as a
left join
(select device_id,role_id
from myth.server_role_create
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
group by 1,2
) as b
on a.device_id = b.device_id
) as a

left join
(SELECT role_id,day_time,to_date(cast(date_time as timestamp)) as day_times
from myth.server_role_login
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
GROUP BY 1,2,3
) as b
on a.role_id = b.role_id and a.day_time = b.day_time - 1
where a.role_id is not null
group by 1,2,3,4,5,6
) as a


left join
(
select customer_user_id  --广告自然
       ,case when split_part(campaign,'-',5)='次核心受众' then '广告量'
        when split_part(campaign,'-',5)='核心受众'   then '广告量'
        when split_part(campaign,'-',5)='卡牌素材'   then '广告量'
        when media_source ='restricted'             then '广告量'
        else  '自然量'
        end as '广告自然'
       from myth.af_push
 where day_time between ${beginDate} and ${endDate}
group by 1,2
) as b  
on a.device_id = b.customer_user_id

left join -- 登录次数/战力
(
select role_id,day_time,count(role_id) as cishu,max(battle_points) as '首日最高战力'
from myth.server_role_login
where day_time between ${beginDate} and ${endDate}
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
group by 1,2
) as c  
on a.role_id = c.role_id and a.day_time = c.day_time

left join  -- 在线时长  分钟
(
select role_id,day_time,count(ping) as '首日在线时长' from myth.client_online
where day_time between ${beginDate} and ${endDate}
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
group by 1,2
) as d  
on a.role_id = d.role_id and a.day_time = d.day_time

left join -- 装备强化次数
(
select role_id,count(1) as '装备强化次数' from myth_server.server_equip_strengthen
where day_time between ${beginDate} and ${endDate}
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
group by 1
) as e 
on a.role_id = e.role_id

left join -- 公会建设次数
(
select role_id,day_time,count(1) as '公会建设次数' from myth_server.server_guild_build
where day_time between ${beginDate} and ${endDate}
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
group by 1,2
) as f 
on a.role_id = f.role_id and a.day_time = f.day_time

-- left join -- 卡牌抽取   10连抽要*10  单抽计数
-- (
-- select role_id,day_time, count(role_id) as '首日抽卡总次数' ,
-- count(case when consume_prop_id <> 0 then consume_prop_id else null end) as '首日道具抽卡次数',
-- count(case when consume_currency_id <> 0 then consume_currency_id else null end) as '首日钻石抽卡次数',
-- count(case when gacha_mode = 1 then gacha_mode else null end) as '首日单抽次数',
-- count(case when gacha_mode = 2 then gacha_mode else null end) as '首日十连次数'
-- from myth_server.server_card_gacha
-- where day_time between ${beginDate} and ${endDate}
-- and channel_id=1000
-- and version_name ='1.3.0'   
-- and country not in ('CN','HK')
-- group by 1,2
-- ) as g
on a.role_id = g.role_id and a.day_time = g.day_time

left join -- 玩法结算
(
select role_id,day_time,max(dungeon_id) as '首日通关最高关卡'
from myth_server.server_dungeon_end
where day_time between ${beginDate} and ${endDate}
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
and battle_result=1
and game_type=3
group by 1,2
) as h
on a.role_id = h.role_id and a.day_time = h.day_time

left join -- 玩法进入
(
select role_id,day_time,max(dungeon_id) as '首日进入最高关卡'
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate}
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
and game_type=3
group by 1,2
) as i
on a.role_id = i.role_id and a.day_time = i.day_time

left join -- PVP
(
select role_id,day_time,count(1) as count_pvp,
round(count(case when fighting_result=1 then 1 else null end)/count(1)*100,2)  as pvp
from
(select role_id,day_time,fighting_result
from myth_server.server_arena
where day_time between ${beginDate} and ${endDate}
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
group by 1,2,3) as a
group by 1,2
) as j
on a.role_id = j.role_id and a.day_time = j.day_time

left join -- 公会迷境
(
select role_id,day_time,sum(damage_value) as '首日公会领主伤害',count(1) as '首日公会领主次数'
from myth_server.server_guild_boss
where day_time between ${beginDate} and ${endDate}
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
group by 1,2
) as k
on a.role_id = k.role_id and a.day_time = k.day_time

left join -- 玩法结算地精宝库
(
select role_id,day_time,max(dungeon_id) as '首日通关地精宝库最高关卡'
from myth_server.server_dungeon_end
where day_time between ${beginDate} and ${endDate}
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
and battle_result=1
and game_type=7
group by 1,2
) as l
on a.role_id = l.role_id and a.day_time = l.day_time

left join -- 玩法进入地精宝库
(
select role_id,day_time,max(dungeon_id) as '首日进入地精宝库最高关卡'
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate}
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
and game_type=7
group by 1,2
) as m
on a.role_id = m.role_id and a.day_time = m.day_time

left join -- 玩法结算秘境
(
select role_id,day_time,max(dungeon_id) as '首日通关秘境最高关卡'
from myth_server.server_dungeon_end
where day_time between ${beginDate} and ${endDate}
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
and battle_result=1
and game_type=2
group by 1,2
) as n
on a.role_id = n.role_id and a.day_time = n.day_time

left join -- 玩法进入秘境
(
select role_id,day_time,max(dungeon_id) as '首日进入秘境最高关卡'
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate}
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
and game_type=2
group by 1,2
) as o
on a.role_id = o.role_id and a.day_time = o.day_time

left join -- 货币
(
select role_id,day_time,
sum(case when change_type = 'PRODUCE' and currency_id = '8' then change_count else null end) as '首日金币获得',
sum(case when change_type = 'CONSUME' and currency_id = '8' then change_count else null end) as '首日金币消耗',
sum(case when change_type = 'PRODUCE' and currency_id = '3' then change_count else null end) as '首日钻石获得',
sum(case when change_type = 'CONSUME' and currency_id = '3' then change_count else null end) as '首日钻石消耗',
sum(case when change_type = 'PRODUCE' and currency_id = '9' then change_count else null end) as '首日神力水晶获得',
sum(case when change_type = 'CONSUME' and currency_id = '9' then change_count else null end) as '首日神力水晶消耗',
sum(case when change_type = 'PRODUCE' and currency_id = '13' then change_count else null end) as '首日公会币获得',
sum(case when change_type = 'CONSUME' and currency_id = '13' then change_count else null end) as '首日公会币消耗'
from myth.server_currency
where day_time between ${beginDate} and ${endDate}
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
group by 1,2
) as p
on a.role_id = p.role_id and a.day_time = p.day_time

left join -- 道具
(
select role_id,day_time,
sum(case when change_type = 'PRODUCE' and prop_id = '100501' then change_count else null end) as '首日星辰密匙获得',
sum(case when change_type = 'CONSUME' and prop_id = '100501' then change_count else null end) as '首日星辰密匙消耗'
from myth.server_prop
where day_time between ${beginDate} and ${endDate}
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
group by 1,2
) as q
on a.role_id = q.role_id and a.day_time = q.day_time

group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36


