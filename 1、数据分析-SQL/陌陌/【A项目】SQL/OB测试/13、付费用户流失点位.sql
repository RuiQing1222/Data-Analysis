----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 
付费用户流失点位

D7的付费用户基本属性



付费用户流失点位
=IF(OR(E2=$E$2,E2=$E$3,E2=$E$22),"留存","流失")

D7的付费用户基本属性
流失天数  6月15日至17日未登录


select a.role_id,
birth_dt,
total_pay,
vip,
last_day,
datediff(last_day,birth_dt)+1 as '生命周期',
coalesce(last_pay,0)          as last_pay,
coalesce(战役通关数,0)         as '战役通关数',
coalesce(秘境通关数,0)         as '秘境通关数',
coalesce(zy_nums,0)           as '战役次数',
coalesce(zy_rate,0)           as '战役成功率',
coalesce(mj_nums,0)           as '秘境次数',
coalesce(mj_rate,0)           as '秘境成功率',
coalesce(gem_get,0)           as '钻石获得',
coalesce(gem_cost,0)          as '钻石消耗',
coalesce(gold_get,0)          as '金币获得',
coalesce(gold_cost,0)         as '金币消耗',
coalesce(strength_get,0)      as '强化石获得',
coalesce(strength_cost,0)     as '强化石消耗',
case  e.game_type  
    when 2 then '秘境'      
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
    when 17 then '勇者试炼'
    when 18 then '公会远征'
    when 19 then '死亡迷宫'
    when 20 then '专属副本'
    when 21 then '公会争霸'
    when 22 then '地狱领主'
    else 'others'
    end as '停留玩法',
e.dungeon_id       as '停留关卡',
e.battle_result    as '结算结果' ,
e.battle_points    as '当时战力' 

from 
(select vip,birth_dt,a.role_id,last_day,total_pay
from 
(select vip,birth_dt,role_id,total_pay
from 
(select birth_dt,role_id,total_pay,
case when total_pay>0  and total_pay<=8   then 1
     when total_pay>8  and total_pay<=83  then 2
     when total_pay>83                    then 3 
     else 0 
     end as vip --D14 
from 
(select birth_dt,a.role_id
,sum(case when datediff(vip_dt,birth_dt)< ${lifeTime}  then pay else 0 end ) as 'total_pay'
from

(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(date_time) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id in (1000,2000)
and version_name = '1.5.0'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(date_time) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id in (1000,2000)
and version_name = '1.5.0'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id   --and a1.birth_dt = a2.device_birth_dt
group by 1,2
)  a
left join
(
select role_id,to_date(date_time) as vip_dt,sum(pay_price) pay 
from myth.order_pay
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
group by 1,2 ) b 
on a.role_id =b.role_id
where b.role_id  is not null 
group by 1,2
) a1 
) a 
where total_pay>0 
) a 
left join 
(select role_id,max(to_date(date_time)) as last_day
from myth.client_online
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id in (1000,2000)
and version_name = '1.5.0'
and country not in ('CN','HK')
group by 1) c 
on a.role_id = c.role_id

) a  --基本信息
left join 
(select role_id,done_dt,pay as last_pay 
from 
(
select role_id,to_date(date_time) as done_dt,
row_number()over(partition by role_id order by to_date(date_time) desc ) as row_num1,
sum(pay_price) pay
from myth.order_pay
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
group by 1,2 
) c1 
where row_num1 = 1 
) c --最后登录当日的付费总金额
on a.role_id =c.role_id and last_day=done_dt
left join 
(select d1.role_id,d1.play_dt,
count(case when d1.game_type= 3 then 1 else null end )  as zy_nums,
count(case when d1.game_type= 2 then 1 else null end )  as mj_nums,
round(count(case when d1.game_type= 3 and battle_result=1 then 1 else null end)/count(case when d1.game_type= 3 then 1 else null end)*100,2) as zy_rate,
round(count(case when d1.game_type= 2 and battle_result=1 then 1 else null end)/count(case when d1.game_type= 2 then 1 else null end)*100,2) as mj_rate 
from 
(
select role_id,to_date(date_time) as play_dt,dungeon_id,start_time,game_type
from myth_server.server_enter_dungeon
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and server_id in (${serverIds})
and version_name = '1.5.0'
and game_type in (2,3) 
) d1 
left join 
(
select role_id,to_date(date_time) as play_dt,dungeon_id,start_time,battle_result,game_type
from myth_server.server_dungeon_end
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name = '1.5.0'
and server_id in (${serverIds})
and game_type in (2,3) 
) d2 
on d1.role_id=d2.role_id and d1.play_dt=d2.play_dt and d1.game_type=d2.game_type and d1.start_time=d2.start_time and d1.dungeon_id = d2.dungeon_id
group by 1,2
) d  --流失当天战役秘境数据
on a.role_id =d.role_id and last_day=play_dt

left join 
(select role_id,liu_dt,dungeon_id,game_type,battle_result,battle_points from 
(select role_id,play_dt as liu_dt,dungeon_id,log_time,game_type,battle_result,battle_points,row_number()over(partition by role_id , play_dt order by log_time desc) as row_num2
     from 
(
select role_id,to_date(date_time) as play_dt,dungeon_id,log_time,game_type, 0 as battle_result,battle_points
from myth_server.server_enter_dungeon
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and server_id in (${serverIds})
and version_name = '1.5.0'
union all 
select role_id,to_date(date_time) as play_dt,dungeon_id,log_time,game_type,battle_result,battle_points
from myth_server.server_dungeon_end 
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and server_id in (${serverIds})
and version_name = '1.5.0'
union all 
select role_id,to_date(date_time) as play_dt,boss_id as dungeon_id,log_time,16 as game_type,damage_value as battle_result,battle_points
from myth_server.server_guild_boss 
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and server_id in (${serverIds})
and version_name = '1.5.0'
union all 
select role_id,to_date(date_time) as play_dt,dungeon_id,log_time,18 as game_type,battle_result,battle_points
from myth_server.server_guild_challenge
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and server_id in (${serverIds})
and version_name = '1.5.0'
union all 
select role_id,to_date(date_time) as play_dt,0 as dungeon_id,log_time,18 as game_type,damage_value as battle_result,battle_points
from myth_server.server_guild_endless
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and server_id in (${serverIds})
and version_name = '1.5.0'
union all 
select role_id,to_date(date_time) as play_dt,grade_num+100 as dungeon_id,log_time,17 as game_type,battle_result,battle_points
from myth_server.server_endless_abyss_junior
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and server_id in (${serverIds})
and version_name = '1.5.0'
union all 
select role_id,to_date(date_time) as play_dt,grade_num+200 as dungeon_id,log_time,17 as game_type,battle_result,battle_points
from myth_server.server_endless_abyss_senior
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and server_id in (${serverIds})
and version_name = '1.5.0'
union all 
select role_id,to_date(date_time) as play_dt,grade_num as dungeon_id,log_time,19 as game_type,1 as battle_result,battle_points
from myth_server.server_roguelike
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and server_id in (${serverIds})
and version_name = '1.5.0'
union all 
select role_id,to_date(date_time) as play_dt,boss_id as dungeon_id,log_time,6 as game_type,damage_value as battle_result,battle_points
from myth_server.server_world_boss
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and server_id in (${serverIds})
and version_name = '1.5.0'
union all 
select role_id,to_date(date_time) as play_dt,def_role_pos as dungeon_id,log_time,4 as game_type,fighting_result as battle_result,battle_points
from myth_server.server_arena
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and server_id in (${serverIds})
and version_name = '1.5.0'
union all 
select role_id,to_date(date_time) as play_dt,grade_num as dungeon_id,log_time,22 as game_type,battle_result,battle_points
from myth_server.server_hell_arena
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and server_id in (${serverIds})
and version_name = '1.5.0'
union all 
select role_id,to_date(date_time) as play_dt,def_guild_id as dungeon_id,log_time,21 as game_type,fighting_result as battle_result,battle_points
from myth_server.server_guild_war
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and server_id in (${serverIds})
and version_name = '1.5.0'
union all 
select role_id,to_date(date_time) as play_dt,0 as dungeon_id,log_time,0 as game_type,0 as battle_result,battle_points
from myth_server.server_login_snapshot
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and server_id in (${serverIds})
and version_name = '1.5.0'
) e1 
) e2 
where row_num2 =1
) e 
on a.role_id = e.role_id and last_day = liu_dt

left join 

(select role_id,
    sum(case when currency_id = '3' and change_type = 'PRODUCE' then change_count else 0 end ) as gem_get,
    sum(case when currency_id = '3' and change_type = 'CONSUME' then change_count else 0 end ) as gem_cost,
    sum(case when currency_id = '8' and change_type = 'PRODUCE' then change_count else 0 end ) as gold_get,
    sum(case when currency_id = '8' and change_type = 'CONSUME' then change_count else 0 end ) as gold_cost 
from myth.server_currency
where day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and server_id in (${serverIds})
and version_name = '1.5.0'
and currency_id in ('3','8')
group by 1
) f 
on a.role_id = f.role_id

left join

(select role_id,
    sum(case when prop_id = '100521' and change_type = 'PRODUCE' then change_count 
             when prop_id = '100522' and change_type = 'PRODUCE' then change_count*10
             when prop_id = '100523' and change_type = 'PRODUCE' then change_count*100
        else 0 end ) as strength_get,
    sum(case when prop_id = '100521' and change_type = 'CONSUME' then change_count 
             when prop_id = '100522' and change_type = 'CONSUME' then change_count*10
             when prop_id = '100523' and change_type = 'CONSUME' then change_count*100
        else 0 end ) as strength_cost
from myth.server_prop
where day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and server_id in (${serverIds})
and version_name = '1.5.0'
and prop_id in ('100521','100522','100523')
group by 1
) g
on a.role_id = g.role_id

left join 

(
select role_id,
max(distinct case when game_type = 3 then dungeon_id else 0 end) as '战役通关数',
max(distinct case when game_type = 2 then dungeon_id else 0 end) as '秘境通关数'
from myth_server.server_dungeon_end
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name = '1.5.0'
and server_id in (${serverIds})
and game_type in (2,3) 
and battle_result = 1 
group by 1
)  h  
on a.role_id = h.role_id

group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23






---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


select a.role_id,birth_dt,total_pay,vip,last_day,datediff(last_day,birth_dt)+1 as '生命周期',
rank3,action_type,detail
from 
(select vip,birth_dt,a.role_id,last_day,total_pay
from 
(select vip,birth_dt,role_id,total_pay
from 
(select birth_dt,role_id,total_pay,
case when total_pay>0  and total_pay<=8   then 1
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
(select role_id,device_id,to_date(date_time) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id in (1000,2000)
and version_name = '1.5.0'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(date_time) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id in (1000,2000)
and version_name = '1.5.0'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id   --and a1.birth_dt = a2.device_birth_dt
group by 1,2
)  a
left join
(
select role_id,to_date(date_time) as vip_dt,sum(pay_price) pay 
from myth.order_pay
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
group by 1,2 ) b 
on a.role_id =b.role_id
where b.role_id  is not null 
group by 1,2
) a1 
) a 
where total_pay>0 
) a 
left join 
(select role_id,max(to_date(date_time)) as last_day
from myth.client_online
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id in (1000,2000)
and version_name = '1.5.0'
and country not in ('CN','HK')
group by 1) c 
on a.role_id = c.role_id
-- where last_day not in ('2023-03-27','2023-03-28','2023-03-29')
) a  --流失用户的基本信息
left join 

(select role_id,action_dt,action_type,detail,rank3
from 
(select role_id,action_dt,action_type,detail,rank()over(partition by action_dt,role_id order by log_time desc) as rank3
     from
(
select role_id,to_date(date_time) as action_dt,log_time,'支付' as action_type,cast(pay_price  as string) as detail
from myth.order_pay
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
union all 
select role_id,to_date(date_time) as action_dt,log_time,case change_method
when '10' then '商店购买' 
when '4'  then '邮件领取'
when '58' then '挂机领取'
end as action_type,
cast(currency_id as string) as detail
from myth.server_currency
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and change_method  in ('10','4','58')
and change_type='PRODUCE'
and version_name = '1.5.0'
union all 
select role_id,to_date(date_time) as action_dt,log_time,case change_method
when '89' then '公会建设' 
end as action_type,
cast(currency_id as string) as detail
from myth.server_currency
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and change_method ='89'
and change_type='CONSUME'
and version_name = '1.5.0'
union all 
select role_id,to_date(date_time) as action_dt,log_time,
case change_method
when '13' then '神器激活' 
when '59' then '挂机加速'
end as action_type,
'0'  as detail
from myth.server_prop
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and change_method   in ('13','59')
and change_type='CONSUME'
and version_name = '1.5.0'
union all
select role_id,to_date(date_time) as action_dt,log_time,
case change_method
when '10' then '商店购买' 
when '4'  then '邮件领取'
when '58' then '挂机领取'
when '135' then '秘境挂机领取'
end as action_type,
cast(prop_id as string) as detail
from myth.server_prop
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and change_method  in ('10','4','58','135')
and change_type='PRODUCE'
and version_name = '1.5.0'
union all 
select role_id,to_date(date_time) as action_dt,log_time,'角色技能' as action_type,case role_type 
    when   '1' then '雷神'
    when   '2' then '瓦尔基里'
    when   '3' then '齐格飞'
    when   '4' then '乌勒尔'
    when   '5' then '芙丽雅' 
    end as detail
from myth_server.server_skills_upgrade
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name = '1.5.0'
union all 
select role_id,to_date(date_time) as action_dt,log_time,'众神信仰选择' as action_type,faith_id as detail
from myth_server.server_gods_faith_choose
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name = '1.5.0'
union all 
select role_id,to_date(date_time) as action_dt,log_time,'众神信仰升级' as action_type,
case faith_type 
when 1 then '奥丁'
when 2 then '西芙'
when 3 then '弗丽嘉'
when 4 then '海姆达尔'
when 5 then '巴德尔'
when 6 then '瓦尔基里'
when 0 then '主干'
end as detail
from myth_server.server_gods_faith_upgrade
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name = '1.5.0'
union all 
select role_id,to_date(date_time) as action_dt,log_time,'世界树升级' as action_type,
case tree_type 
when 1 then '奥丁'
when 2 then '西芙'
when 3 then '弗丽嘉'
when 4 then '海姆达尔'
when 5 then '巴德尔'
when 6 then '瓦尔基里'
when 0 then '主干' 
end as detail
from myth_server.server_world_tree
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name = '1.5.0'
union all 
select role_id,to_date(date_time) as action_dt,log_time,'神器升级' as action_type,cast(weapon_id as string) as detail
from myth_server.server_artifact_upgrade
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name = '1.5.0'
union all 
select role_id,to_date(date_time) as action_dt,log_time,'神性升级' as action_type,'0' as detail
from myth_server.server_deity_upgrade
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name = '1.5.0'
union all 
select role_id,to_date(date_time) as action_dt,log_time,'天赋激活' as action_type,'0' as detail
from myth_server.server_fate_activation
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name = '1.5.0'
union all 
select role_id,to_date(date_time) as action_dt,log_time,'天赋重置' as action_type,'0' as detail
from myth_server.server_fate_reset
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name = '1.5.0'
union all 
select role_id,to_date(date_time) as action_dt,log_time,'宠物升级' as action_type,'0' as detail
from myth_server.server_pet_upgrade
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name = '1.5.0'
union all 
select role_id,to_date(date_time) as action_dt,log_time,'宠物抽取' as action_type,'0' as detail
from myth_server.server_pet_gacha
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name = '1.5.0'
union all 
select role_id,to_date(date_time) as action_dt,log_time,'宠物技能激活' as action_type,'0' as detail
from myth_server.server_pet_skills_activation
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name = '1.5.0'
union all 
select role_id,to_date(date_time) as action_dt,log_time,'卡牌抽取' as action_type,'0' as detail
from myth_server.server_card_gacha
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name = '1.5.0'
union all 
select role_id,to_date(date_time) as action_dt,log_time,'卡牌进阶' as action_type,'0' as detail
from myth_server.server_card_evolution
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name = '1.5.0'
union all 
select role_id,to_date(date_time) as action_dt,log_time,'卡牌羁绊' as action_type,'0' as detail
from myth_server.server_card_bond
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name = '1.5.0'
union all 
select role_id,to_date(date_time) as action_dt,log_time,'装备强化' as action_type,'0' as detail
from myth_server.server_equip_strengthen
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name = '1.5.0'
union all 
select role_id,to_date(date_time) as action_dt,log_time,'装备重铸' as action_type,'0' as detail
from myth_server.server_equip_recast
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name = '1.5.0'
union all 
select role_id,to_date(date_time) as action_dt,log_time,'宝石合成' as action_type,'0' as detail
from myth_server.server_gem_compose
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name = '1.5.0'
union all 
select role_id,to_date(date_time) as action_dt,log_time,'宝石镶嵌' as action_type,'0' as detail
from myth_server.server_gem_set
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name = '1.5.0'
union all 
select role_id,to_date(date_time) as action_dt,log_time,'卢恩符石合成' as action_type,'0' as detail
from myth_server.server_rune_evolution
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name = '1.5.0'
union all 
select role_id,to_date(date_time) as action_dt,log_time,'卢恩符石镶嵌' as action_type,'0' as detail
from myth_server.server_rune_set
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name = '1.5.0'
union all 
select role_id,to_date(date_time) as action_dt,log_time,'卢恩符石镶嵌' as action_type,'0' as detail
from myth_server.server_rune_set
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name = '1.5.0'
union all 
select role_id,to_date(date_time) as action_dt,log_time,'命运殿堂许愿' as action_type,
case wish_mode 
when 1 then '紫金' 
when 2 then '白银'
when 3 then '黄金' 
end as detail
from myth_server.server_wish_room
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name = '1.5.0'
union all
select role_id,to_date(date_time) as action_dt,log_time,'信徒心愿领取' as action_type,'0' as detail
from myth_server.server_wish_room
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name = '1.5.0'
union all
select role_id,to_date(date_time) as action_dt,log_time,'信徒心愿赐福' as action_type,cast (believer_id_list as string) as detail
from myth_server.server_bless_believer
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name = '1.5.0'
union all
select role_id,to_date(date_time) as action_dt,log_time,'神王之路领奖' as action_type,'0' as detail
from myth_server.server_god_way
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name = '1.5.0'
) b1 
) b2 
where rank3 <=5 
) b 
on a.role_id = b.role_id and last_day = action_dt 





------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



(select a.role_id,birth_dt,last_dt,datediff(last_dt,birth_dt) +1 as lt
from 
(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(date_time) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id in (1000,2000)
and version_name = '1.5.0'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(date_time) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id in (1000,2000)
and version_name = '1.5.0'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id   --and a1.birth_dt = a2.device_birth_dt
group by 1,2
)  a

left join

(select role_id,max(to_date(date_time)) as last_dt
from myth.client_online
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id in (1000,2000)
and version_name = '1.5.0'
and country not in ('CN','HK')
group by 1) c 
on a.role_id = c.role_id
where datediff(last_dt,birth_dt)>6
) a 
left join 