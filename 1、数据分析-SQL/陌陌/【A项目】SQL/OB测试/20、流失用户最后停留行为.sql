


select 标签,total_pay,last_day,max_dungeon,datediff(last_day,birth_dt)+1 as '生命周期',
rank3,action_type,detail
,count(distinct a.role_id)  as '用户数'
from 
(select birth_dt,a.role_id,last_day,total_pay,标签,max_dungeon
from 
(select birth_dt,a.role_id,last_day,total_pay,标签
from 

(select birth_dt,a.role_id,
  case when pay is not null then pay 
  else 0 
  end as total_pay,
  case when b.role_id is not null then '付费'
  else  '免费'
  end as '标签'
from

(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(date_time) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and channel_id in (1000,2000)
and version_name  in ('1.5.1','1.5.2')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(date_time) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id in (1000,2000)
and version_name  in ('1.5.1','1.5.2')
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
) a 
 
left join 
(select role_id,max(to_date(date_time)) as last_day
from myth.client_online
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id in (1000,2000)
and version_name  in ('1.5.1','1.5.2')
and country not in ('CN','HK')
group by 1) c 
on a.role_id = c.role_id
where last_day not in ('2023-08-12','2023-08-13','2023-08-14')
) a  --流失用户的基本信息
left join 


(select role_id,max(max_dungeon) as max_dungeon
  from 
(
(select role_id,max(dungeon_id) as max_dungeon
from myth_server.server_dungeon_end
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id in (1000,2000)
and version_name  in ('1.5.1','1.5.2')
and country not in ('CN','HK')
and game_type = 3
group by 1)
union  
(select role_id,max(dungeon_id) as max_dungeon
from myth_server.server_enter_dungeon
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id in (1000,2000)
and version_name  in ('1.5.1','1.5.2')
and country not in ('CN','HK')
and game_type = 3
group by 1)

)  d1 
group by 1
)  d  
on a.role_id = d.role_id
) a 

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
case currency_id 
when '1'   then '经验'
when '2'   then '友情点'
when '3'   then '钻石'
when '4'   then '水晶'
when '5'   then '天赋石'
when '6'   then '装备精粹'
when '7'   then '天赋神石'
when '8'   then '金币'
when '9'   then '神力结晶'
when '10'  then '世界树叶'
when '11'  then '竞技币'
when '12'  then '战魂币'
when '13'  then '公会币'
when '14'  then '宝石粉尘'
when '15'  then '心愿值'
when '16'  then '深渊币'
when '17'  then '次元水晶'
when '18'  then '幻灵币'
when '19'  then '战令币'
when '20'  then 'VIP经验'
when '21'  then '其他'
when '22'  then '地狱幽魂'
when '23'  then '众生之魂'
end as detail
from myth.server_currency
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and change_method  in ('10','4','58')
and change_type='PRODUCE'
and version_name  in ('1.5.1','1.5.2')
union all 
select role_id,to_date(date_time) as action_dt,log_time,case change_method
when '89' then '公会建设' 
end as action_type,
case when currency_id = '3'
then '钻石'
else '其他'
end as detail
from myth.server_currency
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and change_method ='89'
and change_type='CONSUME'
and version_name  in ('1.5.1','1.5.2')
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
and version_name  in ('1.5.1','1.5.2')
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
and version_name  in ('1.5.1','1.5.2')
union all 
select role_id,to_date(date_time) as action_dt,log_time,'角色技能' as action_type,case role_type 
    when   '1' then '雷神'
    when   '2' then '瓦尔基里'
    when   '3' then '齐格飞'
    when   '4' then '乌勒尔'
    when   '5' then '芙丽雅' 
    when   '6' then '贝奥武夫'
    when   '7' then '海拉'
    end as detail
from myth_server.server_skills_upgrade
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
union all 
select role_id,to_date(date_time) as action_dt,log_time,'众神信仰选择' as action_type,faith_id as detail
from myth_server.server_gods_faith_choose
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
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
and version_name  in ('1.5.1','1.5.2')
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
and version_name  in ('1.5.1','1.5.2')
union all 
select role_id,to_date(date_time) as action_dt,log_time,'神器升级' as action_type,cast(weapon_id as string) as detail
from myth_server.server_artifact_upgrade
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
union all 
select role_id,to_date(date_time) as action_dt,log_time,'神性升级' as action_type,'0' as detail
from myth_server.server_deity_upgrade
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
union all 
select role_id,to_date(date_time) as action_dt,log_time,'天赋激活' as action_type,'0' as detail
from myth_server.server_fate_activation
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
union all 
select role_id,to_date(date_time) as action_dt,log_time,'天赋重置' as action_type,'0' as detail
from myth_server.server_fate_reset
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
union all 
select role_id,to_date(date_time) as action_dt,log_time,'宠物升级' as action_type,'0' as detail
from myth_server.server_pet_upgrade
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
union all 
select role_id,to_date(date_time) as action_dt,log_time,'宠物抽取' as action_type,'0' as detail
from myth_server.server_pet_gacha
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
union all 
select role_id,to_date(date_time) as action_dt,log_time,'宠物技能激活' as action_type,'0' as detail
from myth_server.server_pet_skills_activation
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
union all 
select role_id,to_date(date_time) as action_dt,log_time,'卡牌抽取' as action_type,'0' as detail
from myth_server.server_card_gacha
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
union all 
select role_id,to_date(date_time) as action_dt,log_time,'卡牌进阶' as action_type,'0' as detail
from myth_server.server_card_evolution
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
union all 
select role_id,to_date(date_time) as action_dt,log_time,'卡牌羁绊' as action_type,'0' as detail
from myth_server.server_card_bond
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
union all 
select role_id,to_date(date_time) as action_dt,log_time,'装备强化' as action_type,'0' as detail
from myth_server.server_equip_strengthen
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
union all 
select role_id,to_date(date_time) as action_dt,log_time,'装备重铸' as action_type,'0' as detail
from myth_server.server_equip_recast
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
union all 
select role_id,to_date(date_time) as action_dt,log_time,'宝石合成' as action_type,'0' as detail
from myth_server.server_gem_compose
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
union all 
select role_id,to_date(date_time) as action_dt,log_time,'宝石镶嵌' as action_type,'0' as detail
from myth_server.server_gem_set
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
union all 
select role_id,to_date(date_time) as action_dt,log_time,'卢恩符石合成' as action_type,'0' as detail
from myth_server.server_rune_evolution
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
union all 
select role_id,to_date(date_time) as action_dt,log_time,'卢恩符石镶嵌' as action_type,'0' as detail
from myth_server.server_rune_set
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
union all 
select role_id,to_date(date_time) as action_dt,log_time,'卢恩符石镶嵌' as action_type,'0' as detail
from myth_server.server_rune_set
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
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
and version_name  in ('1.5.1','1.5.2')
union all
select role_id,to_date(date_time) as action_dt,log_time,'信徒心愿领取' as action_type,'0' as detail
from myth_server.server_get_believer
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
union all
select role_id,to_date(date_time) as action_dt,log_time,'信徒心愿赐福' as action_type,cast (believer_id_list as string) as detail
from myth_server.server_bless_believer
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
union all
select role_id,to_date(date_time) as action_dt,log_time,'神王之路领奖' as action_type,'0' as detail
from myth_server.server_god_way
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
union all
select role_id,to_date(date_time) as action_dt,log_time,'神王之路领奖' as action_type,'0' as detail
from myth_server.server_god_way
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
union all
select role_id,to_date(date_time) as action_dt,log_time,'礼包页面弹出' as action_type,panel_id as detail
from myth_server.server_panel_triggered
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
union all
select role_id,to_date(date_time) as action_dt,log_time,'点击邀请链接' as action_type,'0' as detail
from myth_server.server_invitation_website_click
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
union all
select role_id,to_date(date_time) as action_dt,log_time,'点击好友申请' as action_type,'0' as detail
from myth_server.server_friends_invite
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
union all
select role_id,to_date(date_time) as action_dt,log_time,'点击好友同意' as action_type,'0' as detail
from myth_server.server_friends_agree
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
union all
select role_id,to_date(date_time) as action_dt,log_time,'点击好友删除' as action_type,'0' as detail
from myth_server.server_friends_delete
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
union all
select role_id,to_date(date_time) as action_dt,log_time,'点击免费刷新' as action_type,
case sys_type 
when 1 then '信徒心愿'
when 2 then '白银殿堂'
when 3 then '黄金殿堂'
when 4 then '紫金殿堂'
end  as detail
from myth_server.server_click_believer
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
union all
select role_id,to_date(date_time) as action_dt,log_time,'尼伯龙根抽奖' as action_type,cast(turn_id as string) as detail
from myth_server.server_lottery
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
union all
select role_id,to_date(date_time) as action_dt,log_time,'尼伯龙根抽奖' as action_type,cast(turn_id as string) as detail
from myth_server.server_lottery
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
union all
select role_id,to_date(date_time) as action_dt,log_time,'战令任务完成' as action_type,task_id as detail
from myth_server.server_battle_pass_task_completed
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
union all
select role_id,to_date(date_time) as action_dt,log_time,'城镇问答' as action_type,npc_id as detail
from myth_server.server_questions
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
union all
select role_id,to_date(date_time) as action_dt,log_time,'关卡进入' as action_type,
case game_type 
when  2    then '秘境'
when  3    then  '战役'
when  4    then  '竞技场'
when  6    then  '远古战场'
when  7    then  '地精宝库'
when  14   then  '宝石矿坑'
when  16   then  '公会领主' 
when  17   then  '英灵试炼'
when  18   then  '公会远征'
when  19   then  '死亡迷宫'
when  20   then  '专属副本'
when  21   then  '公会争霸'
when  22   then  '地狱领主'
else '未知'
end as  detail
from myth_server.server_enter_dungeon
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
union  all 
select role_id,to_date(date_time) as action_dt,log_time,'战役结算' as action_type,
case  battle_result
when 1 then '通关'
when 2 then '未通关'
end as  detail
from myth_server.server_dungeon_end
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
and game_type = 3
union  all 
select role_id,to_date(date_time) as action_dt,log_time,'秘境结算' as action_type,
case  battle_result
when 1 then '通关'
when 2 then '未通关'
end as  detail
from myth_server.server_dungeon_end
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
and game_type = 2
union  all 
select role_id,to_date(date_time) as action_dt,log_time,'地精宝库结算' as action_type,
case  battle_result
when 1 then '通关'
when 2 then '未通关'
end as  detail
from myth_server.server_dungeon_end
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
and game_type = 7
union  all 
select role_id,to_date(date_time) as action_dt,log_time,'宝石矿坑结算' as action_type,cast(dungeon_id as string) as  detail
from myth_server.server_dungeon_end
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
and game_type = 14
union  all 
select role_id,to_date(date_time) as action_dt,log_time,'公会远征结算' as action_type,
case  auto_battle
when 0 then '自动'
when 1 then '手动'
end as  detail
from myth_server.server_dungeon_end
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
and game_type = 18
union  all 
select role_id,to_date(date_time) as action_dt,log_time,'专属副本结算' as action_type,cast(dungeon_id as string) as  detail
from myth_server.server_dungeon_end
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
and game_type = 20
union  all 
select role_id,to_date(date_time) as action_dt,log_time,'快速通关结算' as action_type,
case  game_type
when 2 then '秘境'
when 3 then '战役'
end as  detail
from myth_server.server_fast_pass
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
union  all 
select role_id,to_date(date_time) as action_dt,log_time,'公会领主结算' as action_type,
case  blitz
when 0 then '未扫荡'
when 1 then '扫荡'
end as  detail
from myth_server.server_guild_boss
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
union  all 
select role_id,to_date(date_time) as action_dt,log_time,'公会战结算' as action_type,'0' as  detail
from myth_server.server_guild_war
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
union  all 
select role_id,to_date(date_time) as action_dt,log_time,'英灵试炼初阶结算' as action_type,cast(grade_num as string) as  detail
from myth_server.server_endless_abyss_junior
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
union  all 
select role_id,to_date(date_time) as action_dt,log_time,'英灵试炼深渊结算' as action_type,cast(grade_num as string) as  detail
from myth_server.server_endless_abyss_senior
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
union  all 
select role_id,to_date(date_time) as action_dt,log_time,'死亡迷宫结算' as action_type,cast(grade_num as string) as  detail
from myth_server.server_roguelike
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
union  all 
select role_id,to_date(date_time) as action_dt,log_time,'远古战场结算' as action_type,'0' as  detail
from myth_server.server_world_boss
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
union  all 
select role_id,to_date(date_time) as action_dt,log_time,'竞技场结算' as action_type,
case fighting_result
when 1 then '胜利'
when 2 then '失败'
end  as  detail
from myth_server.server_arena
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
union  all 
select role_id,to_date(date_time) as action_dt,log_time,'地狱领主结算' as action_type,cast(grade_num as string) as  detail
from myth_server.server_hell_arena
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
union  all 
select role_id,to_date(date_time) as action_dt,log_time,'副本扫荡' as action_type,
case game_type 
when 2  then '秘境'
when 7  then '地精宝库'  
end as  detail
from myth_server.server_dungeon_blitz
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name  in ('1.5.1','1.5.2')
) b1 
) b2 
where rank3 =1
) b 
on a.role_id = b.role_id and last_day = action_dt 
group by 1,2,3,4,5,6,7,8
