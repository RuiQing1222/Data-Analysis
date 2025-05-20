1、数据宽表-计算各个指标与留存的相关性

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
and version_name ='1.3.5'   
and country not in ('CN','HK')
group by 1,2,3,4
) as a
left join
(select device_id,role_id
from myth.server_role_create
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.5'   
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
and version_name ='1.3.5'   
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
and version_name ='1.3.5'   
and country not in ('CN','HK')
group by 1,2
) as c  
on a.role_id = c.role_id and a.day_time = c.day_time

left join  -- 在线时长  分钟
(
select role_id,day_time,count(ping) as '首日在线时长' from myth.client_online
where day_time between ${beginDate} and ${endDate}
and channel_id=1000
and version_name ='1.3.5'   
and country not in ('CN','HK')
group by 1,2
) as d  
on a.role_id = d.role_id and a.day_time = d.day_time

left join -- 装备强化次数
(
select role_id,count(1) as '装备强化次数' from myth_server.server_equip_strengthen
where day_time between ${beginDate} and ${endDate}
and channel_id=1000
and version_name ='1.3.5'   
and country not in ('CN','HK')
group by 1
) as e 
on a.role_id = e.role_id

left join -- 公会建设次数
(
select role_id,day_time,count(1) as '公会建设次数' from myth_server.server_guild_build
where day_time between ${beginDate} and ${endDate}
and channel_id=1000
and version_name ='1.3.5'   
and country not in ('CN','HK')
group by 1,2
) as f 
on a.role_id = f.role_id and a.day_time = f.day_time

left join -- 卡牌抽取   10连抽要*10  单抽计数
(select role_id,day_time,
sum(props_num_1+props_num_10*10+gem_num_1+gem_num_10*10) as '首日抽卡总次数',
sum(props_num_1+props_num_10*10) as '首日道具抽卡次数',
sum(gem_num_1+gem_num_10*10) as '首日钻石抽卡数',
sum(props_num_1+gem_num_1) as '首日单抽次数',
sum(props_num_10*10+gem_num_10*10) as '首日十连次数' 
from
(
select role_id,day_time,
count(case when consume_prop_id <> 0 and gacha_mode = 1 then consume_prop_id else null end) as props_num_1, -- 道具单抽
count(case when consume_prop_id <> 0 and gacha_mode = 2 then consume_prop_id else null end) as props_num_10,-- 道具十连抽
count(case when consume_currency_id <> 0 and gacha_mode = 1 then consume_currency_id else null end) as gem_num_1, -- 货币单抽
count(case when consume_currency_id <> 0 and gacha_mode = 2 then consume_currency_id else null end) as gem_num_10 -- 货币十连抽
from myth_server.server_card_gacha
where day_time between ${beginDate} and ${endDate}
and channel_id=1000
and version_name ='1.3.5'   
and country not in ('CN','HK')
group by 1,2
) as g1
group by 1,2
) as g
on a.role_id = g.role_id and a.day_time = g.day_time


left join -- 玩法结算
(
select role_id,day_time,max(dungeon_id) as '首日通关最高关卡'
from myth_server.server_dungeon_end
where day_time between ${beginDate} and ${endDate}
and channel_id=1000
and version_name ='1.3.5'   
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
and version_name ='1.3.5'   
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
and version_name ='1.3.5'   
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
and version_name ='1.3.5'   
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
and version_name ='1.3.5'   
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
and version_name ='1.3.5'   
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
and version_name ='1.3.5'   
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
and version_name ='1.3.5'   
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
and version_name ='1.3.5'   
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
and version_name ='1.3.5'   
and country not in ('CN','HK')
group by 1,2
) as q
on a.role_id = q.role_id and a.day_time = q.day_time

group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36





2、引导流失：先算新手引导绝对人数、再算各个关卡的进入+通关的绝对人数，最后按照节奏表整理数据

-- 新手引导流程
select datediff(login_dt,birth_dt)+1 as by_day,step,count(distinct a.role_id)
from

(  --新增 直接生命周期全部算出来，但是新手引导是单天看
select role_id,birth_dt
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name ='1.3.5'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name ='1.3.5'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
) as a

left join
(select role_id,login_dt,step from
(
       
select b1.role_id as role_id,login_dt,step
from
(select role_id,to_date(cast(date_time as timestamp)) as login_dt,day_time
from myth.server_role_login
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and version_name ='1.3.5'
and country not in ('CN','HK')
and role_id in 
              (select role_id
              from
              (select device_id from myth.device_activate where day_time between ${beginDate} and ${endDate}
              and channel_id=1000
              and version_name ='1.3.5'   
              and country not in ('CN','HK')
              group by 1
              ) as a
              left join
              (select device_id,role_id
              from myth.server_role_create
              where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
              group by 1,2) as b
              on a.device_id = b.device_id
              group by 1)
group by 1,2,3) as b1

left join

(select role_id,day_time,step
from myth.server_newbie
where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and version_name ='1.3.5'
and country not in ('CN','HK')
and role_id in 
              (select role_id
              from
              (select device_id from myth.device_activate where day_time between ${beginDate} and ${endDate}
              and channel_id=1000
              and version_name ='1.3.5'   
              and country not in ('CN','HK')
              group by 1
              ) as a
              left join
              (select device_id,role_id
              from myth.server_role_create
              where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
              group by 1,2) as b
              on a.device_id = b.device_id
              group by 1)
group by 1,2,3
order by 3

union all

select role_id,day_time,step
from myth_server.server_event_guide
where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and version_name ='1.3.5'
and country not in ('CN','HK')
and role_id in 
              (select role_id
              from
              (select device_id from myth.device_activate where day_time between ${beginDate} and ${endDate}
              and channel_id=1000
              and version_name ='1.3.5'   
              and country not in ('CN','HK')
              group by 1
              ) as a
              left join
              (select device_id,role_id
              from myth.server_role_create
              where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
              group by 1,2) as b
              on a.device_id = b.device_id
              group by 1)
group by 1,2,3
order by 3
) as b2

on b1.role_id = b2.role_id and b1.day_time = b2.day_time
group by 1,2,3
) as b3
) as b

on a.role_id = b.role_id
group by 1,2
order by 1,2





-- 各个关卡的进入通关人数    生命周期，要一天一天算   excel透视表按照dungeon_id即是进入关卡人数，胜利即为通关人数（节点通过率=下个节点/上个节点人数、整体通过率=每个节点人数/最开始节点的人数、流失点位=下面节点整体通过率-上面节点整体通过率）
select birth_dt, datediff(login_dt,birth_dt)+1 as by_day,dungeon_id,battle_result,count(distinct a.role_id)
from
(
select role_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and version_name ='1.3.5'
and country not in ('CN','HK')
and device_id in 
(select device_id
from myth.device_activate
where day_time>=${beginDate} and day_time<=${endDate}
and version_name ='1.3.5'
and country not in ('CN','HK')) 
group by 1,2
) as a
left join

(select b1.role_id as role_id,login_dt,dungeon_id,battle_result
from
(select role_id,to_date(cast(date_time as timestamp)) as login_dt,day_time
from myth.server_role_login
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3
) as b1
left join

(select role_id,day_time,dungeon_id,battle_result
from
(select a.role_id as role_id,day_time,a.dungeon_id as dungeon_id,battle_result,row_number() over(partition by a.role_id,a.dungeon_id,day_time order by log_time desc) as num
from
(select dungeon_id,role_id,day_time
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and game_type=3
and channel_id=1000
and version_name ='1.3.5'   
and country not in ('CN','HK')
group by 1,2,3) a 
left join 
(select dungeon_id,role_id,battle_result,log_time
from myth_server.server_dungeon_end
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and game_type=3
and channel_id=1000
and version_name ='1.3.5'   
and country not in ('CN','HK')
group by 1,2,3,4) b 
on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id
) as c
where num = 1
group by 1,2,3,4
) as b2 
on b1.role_id = b2.role_id and b1.day_time = b2.day_time
group by 1,2,3,4
) as b

on a.role_id = b.role_id
group by 1,2,3,4
order by 1,2,3


3、关卡通关率
-- 通过率=下一关进入人数/本关进入关卡人数；通关率=通关人数/进入关卡人数
-- 新增用户
select 副本ID,
进入关卡人数,
人均进入关卡次数,
通关率 as '通关率%', 通关人数,
round(下一关进入人数/进入关卡人数*100,2) as '通过率%'
from 
(select 副本ID,
进入关卡人数,
round(人均进入关卡次数,2) as 人均进入关卡次数 ,
lead(进入关卡人数,1,0)over(order by 副本ID asc) as '下一关进入人数',通关人数,
通关率
from 
(select a.dungeon_id as '副本ID',
count(distinct a.role_id) as '进入关卡人数',
avg(nums) '人均进入关卡次数',
count(distinct b.role_id) as '通关人数',
round(count(distinct b.role_id)/count(distinct a.role_id)*100,2) as '通关率'
from
(select dungeon_id,role_id,count(1) as nums
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and game_type=3 -- 换为7是地精宝库

and channel_id=1000
and version_name ='1.3.5'   
and country not in ('CN','HK')
and role_id in 
                            (select role_id
                            from
                            (select device_id from myth.device_activate where day_time between ${beginDate} and ${endDate}
                            and channel_id=1000
                            and version_name ='1.3.5'   
                            and country not in ('CN','HK')
                            group by 1
                            ) as a
                            left join
                            (select device_id,role_id
                            from myth.server_role_create
                            where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
                            group by 1,2) as b
                            on a.device_id = b.device_id
                            group by 1)
group by 1,2) a 
left join 
(select dungeon_id,role_id
from myth_server.server_dungeon_end
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and game_type=3 -- 换为7是地精宝库

and channel_id=1000
and version_name ='1.3.5'   
and country not in ('CN','HK')
and battle_result=1
and role_id in (select role_id
                            from
                            (select device_id from myth.device_activate where day_time between ${beginDate} and ${endDate}
                            and channel_id=1000
                            and version_name ='1.3.5'   
                            and country not in ('CN','HK')
                            group by 1
                            ) as a
                            left join
                            (select device_id,role_id
                            from myth.server_role_create
                            where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
                            group by 1,2) as b
                            on a.device_id = b.device_id
                            group by 1)
group by 1,2) b 
on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id
group by 1
order by 1) a 
) t 



4、关卡进度 自动战斗 -- 生命周期看关卡进度
select birth_dt,a.role_id,datediff(login_dt,birth_dt)+1 as '天数',dungeon_id,duration,评级,battle_result,auto_battle,date_time
from

(
select role_id,birth_dt
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and version_name ='1.3.5'
and country not in ('CN','HK')
) as a1
right join

(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${endDate}
and version_name ='1.3.5'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
)as a
left join


(select role_id,login_dt,dungeon_id,duration ,评级,battle_result,auto_battle ,date_time
from
(select a.dungeon_id as dungeon_id ,a.role_id as role_id,a.start_time,end_time,(end_time-a.start_time)/60000 as duration,
       case when (end_time-a.start_time)/60000 is null then '无日志'
            when (end_time-a.start_time)/60000 > 3  then '超时'
            when (end_time-a.start_time)/60000 > 2 and (end_time-a.start_time)/60000 <= 3  then '困难'
            when (end_time-a.start_time)/60000 > 1.5 and (end_time-a.start_time)/60000 <= 2  then '较难'
            when (end_time-a.start_time)/60000 > 1 and (end_time-a.start_time)/60000 <= 1.5  then '一般'
            when (end_time-a.start_time)/60000 > 0 and (end_time-a.start_time)/60000 <= 1  then '轻松'
            else '无日志'
       end as '评级',battle_result,auto_battle,a.day_time as day_time,login_dt,date_time
from 
(select dungeon_id,role_id,day_time,start_time,to_date(cast(date_time as timestamp)) as login_dt,date_time
     from myth_server.server_enter_dungeon
     where  day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
     and game_type=3
group by 1,2,3,4,5,6
) as a

left join     
(select dungeon_id,role_id,day_time,log_time  as end_time,start_time,battle_result,auto_battle
     from myth_server.server_dungeon_end
     where  day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
     and game_type=3
) b 
on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time=b.start_time
order by a.role_id,a.start_time asc 
) as e 
) as b 
on a.role_id = b.role_id
group by 1,2,3,4,5,6,7,8,9






5、生命周期——系统参与情况 一天一天算
select birth_dt,a.role_id,datediff(login_dt,birth_dt)+1 as '天数',
case when game_type = 2 then '秘境'
     when game_type = 3 then '战役'
     when game_type = 4 then '竞技场进攻'
     when game_type = 5 then '竞技场防御'
     when game_type = 6 then '远古战场'
     when game_type = 7 then '地精宝库'
     when game_type in (8,9,10,11,12,13) then '诸神试炼'
     when game_type = 14 then '宝石矿坑'
     when game_type = 16 then '公会领主'
     when game_type = 17 then '无尽深渊'
else 'others'
end as '系统参与'

from

(
select role_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and version_name ='1.3.5'
and country not in ('CN','HK')
and device_id in 
               (select device_id
               from myth.device_activate
               where day_time>=${beginDate} and day_time<=${endDate}
               and version_name ='1.3.5'
               and country not in ('CN','HK')) 
               group by 1,2
)as a

left join
(
select b1.role_id as role_id,login_dt,game_type
from
(select role_id,to_date(cast(date_time as timestamp)) as login_dt,day_time
from myth.server_role_login
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3) as b1

left join
(select role_id,day_time,game_type
     from myth_server.server_enter_dungeon
     where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
     and version_name ='1.3.5'
     and country not in ('CN','HK')
group by 1,2,3
) as b2
on b1.role_id = b2.role_id and b1.day_time = b2.day_time
) as b 

on a.role_id = b.role_id
group by 1,2,3,4



6、通关的人，点击各个btn的人数
select a.day_time,btn_type, count(distinct c.role_id)
from 
(select role_id,day_time
     from myth_server.server_dungeon_end
     where  day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
     and version_name ='1.3.5'
     and game_type =3
     and dungeon_id = 2
     and battle_result = 1
     and role_id in 
                     (select role_id
                     from myth.server_role_create 
                     where day_time>=${beginDate} and day_time<=${endDate}
                     and server_id in (${serverIds})
                     and version_name ='1.3.5'
                     and country not in ('CN','HK') )
                     and device_id in 
                                   (select device_id
                                   from myth.device_activate
                                   where day_time>=${beginDate} and day_time<=${endDate}
                                   and version_name ='1.3.5'
                                   and country not in ('CN','HK')) 
group by 1,2) a 


left join 
(select role_id,day_time,btn_type
     from myth_server.server_checkout_btn_click
     where  day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
     and game_type=3
     and dungeon_id = 2
     and role_id in (select role_id
                     from myth.server_role_create 
                     where day_time>=${beginDate} and day_time<=${endDate}
                     and server_id in (${serverIds})
                     and version_name ='1.3.5'
                     and country not in ('CN','HK') )
                     and device_id in 
                                   (select device_id
                                   from myth.device_activate
                                   where day_time>=${beginDate} and day_time<=${endDate}
                                   and version_name ='1.3.5'
                                   and country not in ('CN','HK'))
group by 1,2,3
) c  
on a.role_id=c.role_id and a.day_time=c.day_time
group by 1,2



7、新增_BI
select birth_dt,datediff(login_dt,birth_dt) as datediffs,country,素材名称,素材类型,投放方式,
case when campaign is not null then '广告量' 
     else '自然量' end as campaign,
     count(distinct a.device_id)
from 
(select to_date(cast (date_time as timestamp)) as birth_dt,device_id,
case when country= 'PH' then 'PH'
     when country in ('AU','NZ')  then 'Oceania'
     when country ='GB'  then 'GB'
     when country ='CA'  then 'CA'
     when country ='MY'  then 'MY'
     when country ='SG'  then 'SG'
     else    'others'
     end as country
from myth.device_activate
where day_time between ${beginDate} and ${endDate}
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3) a 
left join 
(select customer_user_id,  
case when split_part(campaign,'-',5)='ARPG' then '核心受众'
     when media_source ='restricted'        then '未知'
     else  '自然量'
     end  as campaign,
     split_part(af_ad,'-',4) as '投放方式',
     split_part(af_ad,'-',8) as '素材类型',
     split_part(af_ad,'-',10) as '素材名称' 
from myth.af_push
where day_time between ${beginDate} and ${endDate}
group by 1,2,3,4,5) b 
on a.device_id=customer_user_id
left join 
(select to_date(cast (date_time as timestamp)) as login_dt,device_id
from myth.device_launch
where day_time between ${beginDate} and ${endDate} 
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2
) c 
on a.device_id=c.device_id
where login_dt>=birth_dt
group by 1,2,3,4,5,6,7



8、新手引导流失之用户行为
select btn_type,count(distinct a.role_id)
from
(select a.role_id as role_id,back_time from
(select a.role_id as role_id,back_time from 
(select role_id,log_time as back_time
from myth.server_newbie
where day_time between ${beginDate} and ${endDate}  --  新手引导节点
and server_id in (${serverIds}) 
and step ='1010040'
and channel_id = 1000 
and country not in ('CN','HK')
and role_id in (select role_id
               from myth.server_role_create 
               where day_time>=${beginDate} and day_time<=${endDate}
               and server_id in (${serverIds}) 
               and version_name ='1.3.5'
               and country not in ('CN','HK') )
               and device_id in 
                             (select device_id
                             from myth.device_activate
                             where day_time>=${beginDate} and day_time<=${endDate}
                             and version_name ='1.3.5'
                             and country not in ('CN','HK')) 
) a 
left join 
(select role_id 
from myth.server_newbie
where day_time between ${beginDate} and ${endDate}
and server_id in (${serverIds})  
and step ='1011010'
and channel_id = 1000 
and country not in ('CN','HK')
)  b 
on a.role_id=b.role_id 
where b.role_id is null 
) a 

left join
(select role_id   -- 没进入关卡
from myth_server.server_enter_dungeon
where  day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds}) 
and game_type=3
and dungeon_id = 7
and role_id in 
       (select role_id
       from myth.server_role_create 
       where day_time>=${beginDate} and day_time<=${endDate}
       and server_id in (${serverIds})  
       and version_name ='1.3.5'
       and country not in ('CN','HK') )
       and device_id in 
              (select device_id
              from myth.device_activate
              where day_time>=${beginDate} and day_time<=${endDate}
              and version_name ='1.3.5'
              and country not in ('CN','HK'))  
) c  
on a.role_id=c.role_id
where c.role_id is null 
) as a

left join 
(
select role_id,btn_type,day_time,log_time  -- 点击按钮
from myth_server.server_hud_click
where day_time between ${beginDate} and ${endDate}
and server_id in (${serverIds}) 
and channel_id = 1000 
and country not in ('CN','HK')
and btn_style =1
and btn_type<>'comedy'
) d 
on a.role_id=d.role_id 
where  d.log_time>back_time
group by 1





9、角色使用率
select case a.game_type 
           when 2 then '秘境'
           when 3 then '剧情'
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
           end as '玩法类型',a.dungeon_id,   
case a.role_type 
    when   '1' then '雷神'
    when   '2' then '瓦尔基里'
    when   '3' then '奇格飞'
    when   '4' then '乌勒尔'
    end as '角色',battle_result,count(1) as nums 
from 
(select game_type,dungeon_id,role_type,start_time,role_id
     from myth_server.server_enter_dungeon
     where  day_time between ${beginDate} and ${endDate}   and server_id in (20001,20002,20003)
     and role_id in (select role_id
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (20001,20002,20003) 
and version_name ='1.3.5'
and country not in ('CN','HK') )
     and device_id in 
(select device_id
from myth.device_activate
where day_time>=${beginDate} and day_time<=${doneDate}
and version_name ='1.3.5'
and country not in ('CN','HK')) 
) a
left join     
(select game_type,dungeon_id,role_id,start_time,battle_result
     from myth_server.server_dungeon_end
     where  day_time between ${beginDate} and ${endDate}   and server_id in (20001,20002,20003)
     and role_id in (select role_id
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (20001,20002,20003) 
and version_name ='1.3.5'
and country not in ('CN','HK') )
     and device_id in 
(select device_id
from myth.device_activate
where day_time>=${beginDate} and day_time<=${doneDate}
and version_name ='1.3.5'
and country not in ('CN','HK')) 
) b 
on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.game_type=b.game_type and a.start_time=b.start_time
group by 1,2,3,4



10、卡牌出战 自动  一天一天算
select birth_dt,a.role_id,god_card_id,datediff(login_dt,birth_dt)+1 as '天数',dungeon_id,duration,评级,battle_result,auto_battle
from

(
select role_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and version_name ='1.3.5'
and country not in ('CN','HK')
and device_id in 
               (select device_id
               from myth.device_activate 
               where day_time>=${beginDate} and day_time<=${endDate}
               and version_name ='1.3.5'
               and country not in ('CN','HK')) 
               group by 1,2
)as a

left join

(select * from
(
select b.role_id as role_id,login_dt,dungeon_id,duration,god_card_id ,评级,battle_result,auto_battle
from
(select role_id,to_date(cast(date_time as timestamp)) as login_dt,day_time
from myth.server_role_login
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3) as b
left join
(select * from
(select a.dungeon_id as dungeon_id ,god_card_id,a.role_id,a.start_time,end_time,(end_time-a.start_time)/60000 as duration,
       case when (end_time-a.start_time)/60000 is null then '无日志'
            when (end_time-a.start_time)/60000 > 3  then '超时'
            when (end_time-a.start_time)/60000 > 2 and (end_time-a.start_time)/60000 <= 3  then '困难'
            when (end_time-a.start_time)/60000 > 1.5 and (end_time-a.start_time)/60000 <= 2  then '较难'
            when (end_time-a.start_time)/60000 > 1 and (end_time-a.start_time)/60000 <= 1.5  then '一般'
            when (end_time-a.start_time)/60000 > 0 and (end_time-a.start_time)/60000 <= 1  then '轻松'
            else '无日志'
       end as '评级',battle_result,auto_battle,a.day_time as day_time
from 
(select dungeon_id,role_id,god_card_id,day_time,start_time
     from myth_server.server_enter_dungeon
     where  day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
     and game_type=3
group by 1,2,3,4,5
) as a

left join     
(select dungeon_id,role_id,day_time,log_time  as end_time,start_time,battle_result,auto_battle
     from myth_server.server_dungeon_end
     where  day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
     and game_type=3
) b 
on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time=b.start_time
order by a.role_id,a.start_time asc 
) as e ) as c
on b.role_id = c.role_id and b.day_time = c.day_time
) as d 
) as b 
on a.role_id = b.role_id
group by 1,2,3,4,5,6,7,8,9





主神卡胜率
-- select a.dungeon_id,god_card_id,a.role_id,a.start_time,end_time,(end_time-a.start_time)/60000 as duration ,battle_result
-- from 
-- (select dungeon_id,god_card_id,role_id,day_time,start_time
--      from myth_server.server_enter_dungeon
--      where  day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
--      and game_type=3
--      and role_id in (select role_id
-- from myth.server_role_create 
-- where day_time>=${beginDate} and day_time<=${doneDate}
-- and server_id in (${serverIds}) 
-- and version_name ='1.3.0'
-- and country not in ('CN','HK') )
--      and device_id in 
-- (select device_id
-- from myth.device_activate
-- where day_time>=${beginDate} and day_time<=${doneDate}
-- and version_name ='1.3.0'
-- and country not in ('CN','HK')) 
-- ) a
-- left join     
-- (select dungeon_id,role_id,day_time,log_time  as end_time,start_time,battle_result
--      from myth_server.server_dungeon_end
--      where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
--      and game_type=3
--      and role_id in (select role_id
-- from myth.server_role_create 
-- where day_time>=${beginDate} and day_time<=${doneDate}
-- and server_id in (${serverIds}) 
-- and version_name ='1.3.0'
-- and country not in ('CN','HK') )
--      and device_id in 
-- (select device_id
-- from myth.device_activate
-- where day_time>=${beginDate} and day_time<=${doneDate}
-- and version_name ='1.3.0'
-- and country not in ('CN','HK')) 
-- ) b 
-- on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time=b.start_time
-- order by a.role_id,a.start_time asc 





































-- 5、货币产消（钻石、金币）
-- select max_level,currency_id,change_type,count(distinct a.role_id),sum(change_count)
-- from
-- (
-- select role_id,max_level
-- from
-- (
-- select role_id,max(role_level) as max_level
-- from
-- myth.server_role_login
-- where day_time between ${start_time} and ${end_time}
-- and server_id in (${serverIds}) 
-- and version_name ='1.3.5'
-- and country not in ('CN','HK')
-- and role_id in (select role_id
--                             from
--                             (select device_id from myth.device_activate where day_time between ${start_time} and ${end_time}
--                             and channel_id=1000
--                             and version_name ='1.3.5'   
--                             and country not in ('CN','HK')
--                             group by 1
--                             ) as a
--                             left join
--                             (select device_id,role_id
--                             from myth.server_role_create
--                             where day_time between ${start_time} and ${end_time} and server_id in (${serverIds})
--                             group by 1,2) as b
--                             on a.device_id = b.device_id
--                             group by 1)
-- group by 1
-- union all
-- select role_id,max(role_level) as max_level
-- from
-- myth.server_role_upgrade
-- where day_time between ${start_time} and ${end_time}
-- and server_id in (${serverIds}) 
-- and version_name ='1.3.5'
-- and country not in ('CN','HK')
-- and role_id in (select role_id
--                             from
--                             (select device_id from myth.device_activate where day_time between ${start_time} and ${end_time}
--                             and channel_id=1000
--                             and version_name ='1.3.5'   
--                             and country not in ('CN','HK')
--                             group by 1
--                             ) as a
--                             left join
--                             (select device_id,role_id
--                             from myth.server_role_create
--                             where day_time between ${start_time} and ${end_time} and server_id in (${serverIds})
--                             group by 1,2) as b
--                             on a.device_id = b.device_id
--                             group by 1)
-- group by 1
-- ) as a1
-- ) as a 
-- left join
-- (
-- select role_id,change_type,change_method,currency_id,change_count
-- from myth.server_currency
-- where day_time between ${start_time} and ${end_time}
-- and channel_id = 1000
-- and version_name ='1.3.5'
-- and country not in ('CN','HK')
-- and currency_id in ('3','8')
-- group by 1,2,3,4,5
-- ) as b  
-- on a.role_id = b.role_id
-- group by 1,2,3
-- order by 1,2,3













-- 5、次留（分登录次数、在线时长）
-- 在线时长有跨天行为，需要算出每人的在线时长宽表再做留存处理
-- 首日在线时长次留
-- select a.role_id,birth_dt,on_time,datediff(login_dt,birth_dt)+1 as '天数'
-- from 
-- (
-- select a.role_id,birth_dt,
--        case when on_time > 0 and on_time <=5 then '1(0,5]'
--             when on_time > 5 and on_time <=10 then '2(5,10]'
--             when on_time > 10 and on_time <=30 then '3(10,30]'
--             when on_time > 30 then '30+'
--        end as on_time
-- from
-- (  --新增
-- select role_id,birth_dt
-- from
-- (select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
-- from myth.server_role_create 
-- where day_time>=${beginDate} and day_time<=${birthEndDate} 
-- and server_id in (${serverIds}) 
-- and version_name ='1.3.5'
-- and country not in ('CN','HK')
-- ) as a1
-- right join
-- (select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
-- from myth.device_activate
-- where day_time>=${beginDate} and day_time<=${birthEndDate}
-- and version_name ='1.3.5'
-- and country not in ('CN','HK')
-- ) as a2 
-- on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
-- ) as a

-- left join
-- (
-- select role_id,to_date(cast(date_time as timestamp)) as login_dt,count(ping) as on_time 
-- from myth.client_online
-- where day_time>=${beginDate} and day_time<=${endDate}
-- and channel_id=1000
-- and version_name ='1.3.5'   
-- and country not in ('CN','HK')
-- group by 1,2
-- ) as b
-- on a.role_id = b.role_id
-- where datediff(login_dt,birth_dt) = 0
-- group by 1,2,3
-- ) as a

-- left join
-- (
-- select role_id,to_date(cast(date_time as timestamp)) as login_dt
-- from myth.server_role_login
-- where day_time>=${beginDate} and day_time<=${endDate}
-- and channel_id=1000
-- and version_name ='1.3.5'   
-- and country not in ('CN','HK')
-- group by 1,2
-- ) as b
-- on a.role_id = b.role_id
-- where datediff(login_dt,birth_dt) in (0,1)
-- group by 1,2,3,4



-- select a.role_id,birth_dt,datediff(login_dt,birth_dt)+1 as '天数',
--        case when on_time > 0 and on_time <=5 then '1(0,5]'
--             when on_time > 5 and on_time <=10 then '2(5,10]'
--             when on_time > 10 and on_time <=30 then '3(10,30]'
--             when on_time > 30 then '30+'
--        end as on_time
-- from
-- (  --新增
-- select role_id,birth_dt
-- from
-- (select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
-- from myth.server_role_create 
-- where day_time>=${beginDate} and day_time<=${birthEndDate} 
-- and server_id in (${serverIds}) 
-- and version_name ='1.3.5'
-- and country not in ('CN','HK')
-- ) as a1
-- right join
-- (select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
-- from myth.device_activate
-- where day_time>=${beginDate} and day_time<=${birthEndDate}
-- and version_name ='1.3.5'
-- and country not in ('CN','HK')
-- ) as a2 
-- on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
-- ) as a

-- left join
-- (
-- select role_id,to_date(cast(date_time as timestamp)) as login_dt,count(ping) as on_time 
-- from myth.client_online
-- where day_time>=${beginDate} and day_time<=${endDate}
-- and channel_id=1000
-- and version_name ='1.3.5'   
-- and country not in ('CN','HK')
-- group by 1,2
-- ) as b
-- on a.role_id = b.role_id
-- where datediff(login_dt,birth_dt) in (0,1)
-- group by 1,2,3,4






-- 首日登录次数次留
-- select
--      birth_dt,
--      a.device_id as device_id,
--      cishu,
--      datediff(login_dt,birth_dt)
-- from

-- (select device_id,to_date(cast(date_time as timestamp)) as birth_dt
-- from myth.device_activate
-- where day_time between ${start_time} and ${end_time}
-- and channel_id = 1000
-- and version_name = '1.3.0'
-- and country not in ('CN','HK')
-- group by 1,2) as a

-- left join
-- (
-- select device_id,to_date(cast(date_time as timestamp)) as login_dt,count(device_id) as cishu  -- 跨天不一定登录，在线即为登录 
-- from myth.device_launch
-- where day_time between ${start_time} and ${end_time}
-- and channel_id=1000
-- and version_name ='1.3.5'   
-- and country not in ('CN','HK')
-- group by 1,2
-- )
-- as b
-- on a.device_id = b.device_id

-- group by 1,2,3,4
-- order by 1

