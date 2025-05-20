
海拉活动
开始 2023-8-18 18:00  结束 2023-9-1 18:00 1692352800000 - 1693562400000

一、任务完成情况
任务接取
select task_id,task_type,count(distinct role_id)
from myth_server.server_accept_task
where day_time between ${activityBeginDate} and ${activityEndDate} 
and server_id not in (22001,22002,22003,22004,22005,22006,22007,22008,22009,22010,22011,22012,22013,22014,20901,20902,20905,25001,25002)
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and task_id in (120028,120029,120030,120031,120032,120033,120034,120035,120036,120037,120038,120039,120040
                ,120041,120042,120043,120044,120045,120046,120047,120048,120049,120050,120051,120052)
group by 1,2
order by 1,2


可接取任务人数
select a.role_id,max_f
            -- when max_f >= 79 then '可以进行许愿' 
            -- when max_f >= 23 then '可以接受信徒心愿'  
            -- when max_f >= 21 then '可以挑战世界BOSS'
            -- when max_f >= 20 then '可以进行商店购买' 
            -- when max_f >= 15 then '可以挑战竞技场'
            -- when max_f >= 11 then '可以赠送友情点'
            -- when max_f >= 10 then '可以挑战装备副本'
            -- when max_f >= 6  then '可以领取挂机奖励'
from
(select role_id
from myth_server.server_accept_task
where day_time between ${activityBeginDate} and ${activityEndDate} 
and server_id not in (22001,22002,22003,22004,22005,22006,22007,22008,22009,22010,22011,22012,22013,22014,20901,20902,20905,25001,25002)
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and task_id in (120028,120029,120030,120031,120032,120033,120034,120035,120036,120037,120038,120039,120040
                ,120041,120042,120043,120044,120045,120046,120047,120048,120049,120050,120051,120052)
group by 1
) as a 

left join

(select role_id,max(dungeon_id) as max_f        
from myth_server.server_dungeon_end
where day_time >= 20230728 and log_time <= 1693562400000
and server_id not in (22001,22002,22003,22004,22005,22006,22007,22008,22009,22010,22011,22012,22013,22014,20901,20902,20905,25001,25002)
and game_type = 3
and channel_id in (1000,2000) 
and version_name in ('1.5.1','1.5.2')
and battle_result = 1
group by 1
) as b
on a.role_id = b.role_id
group by 1,2



任务完成未领
select task_id,task_type,count(distinct role_id)
from myth_server.server_disclaim_reward
where day_time between ${activityBeginDate} and ${activityEndDate} 
and server_id not in (22001,22002,22003,22004,22005,22006,22007,22008,22009,22010,22011,22012,22013,22014,20901,20902,20905,25001,25002)
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and task_id in (120028,120029,120030,120031,120032,120033,120034,120035,120036,120037,120038,120039,120040
                ,120041,120042,120043,120044,120045,120046,120047,120048,120049,120050,120051,120052)
group by 1,2
order by 1,2


任务完成领取
select task_id,task_type,count(distinct role_id)
from myth_server.server_complete_task
where day_time between ${activityBeginDate} and ${activityEndDate} 
and server_id not in (22001,22002,22003,22004,22005,22006,22007,22008,22009,22010,22011,22012,22013,22014,20901,20902,20905,25001,25002)
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and task_id in (120028,120029,120030,120031,120032,120033,120034,120035,120036,120037,120038,120039,120040
                ,120041,120042,120043,120044,120045,120046,120047,120048,120049,120050,120051,120052)
group by 1,2
order by 1,2



二、道具兑换情况
select prop_id as '道具ID',
       case when prop_id = '700800' then '死亡面具'
            when prop_id = '100332' then '专属装备自选包'
            when prop_id = '500101' then '1级愈合宝石'
            when prop_id = '500201' then '1级活力宝石'
            when prop_id = '100531' then '命运金币'
            when prop_id = '100784' then '海拉技能书'
            when prop_id = '100335' then '高级火焰精华自选礼包'
            when prop_id = '100502' then '神系祈愿券'
            when prop_id = '100564' then '命运紫晶币'
            when prop_id = '100530' then '命运银币'
            when prop_id = '100523' then '精金'
            when prop_id = '100517' then '智慧泉水'
            when prop_id = '100122' then '高级神器之魂自选宝箱'
            when prop_id = '100524' then '魔龙之血'
            when prop_id = '100062' then '2级原始符石'
            when prop_id = '100083' then '3级随机宝石'
            when prop_id = '100558' then '宠物粮'
            when prop_id = '100559' then '高级宠物粮'
            when prop_id = '100518' then '元素水晶'
            when prop_id = '100525' then '远古之血'
            when prop_id = '100532' then '混沌魔药'
            when prop_id = '100015' then '1万金币'
            end as '道具名称'
      ,count(distinct role_id) as '兑换道具人数'
      ,count(log_time) as '兑换道具次数'
      ,round(count(log_time) / count(distinct role_id),2) as '人均兑换次数'
from myth.server_prop
where day_time between ${activityBeginDate} and ${activityEndDate}  
and server_id not in (22001,22002,22003,22004,22005,22006,22007,22008,22009,22010,22011,22012,22013,22014,20901,20902,20905,25001,25002)
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
and change_method = '150'
and change_type = 'PRODUCE'
and prop_id in 
(
'700800','100332','500101','500201','100531','100784','100335','100502',
'100564','100530','100523','100517','100122','100524','100062','100083',
'100558','100559','100518','100525','100532','100015'
)
group by 1 order by 3



三、礼包购买情况
select game_product_id as '礼包ID',
       case when game_product_id = 'com.managames.myththor.iap_0.99hlyxlb' then '海拉英雄礼包0.99'
            when game_product_id = 'com.managames.myththor.iap_4.99hlyxlb' then '海拉英雄礼包4.99'
            when game_product_id = 'com.managames.myththor.iap_9.99hlyxlb' then '海拉英雄礼包9.99'
            when game_product_id = 'com.managames.myththor.iap_19.99hlyxlb' then '海拉英雄礼包19.99'
            when game_product_id = 'com.managames.myththor.iap_49.99hlyxlb' then '海拉英雄礼包49.99'
            when game_product_id = 'com.managames.myththor.iap_99.99hlyxlb1' then '海拉英雄礼包99.99'
            when game_product_id = 'com.managames.myththor.iap_0.99hlth' then '海拉特惠0.99'
            when game_product_id = 'com.managames.myththor.iap_1.99hlth' then '海拉特惠1.99'
            when game_product_id = 'com.managames.myththor.iap_2.99hlth' then '海拉特惠2.99'
            when game_product_id = 'com.managames.myththor.iap_4.99hlqrlb' then '海拉7日礼包4.99'
       end as '礼包名称'
       ,count(distinct role_id) as '购买人数'
       ,count(distinct log_time) as '购买次数'
       ,sum(pay_price) as '总金额'
from myth.order_pay
where day_time between ${activityBeginDate} and ${activityEndDate} 
and server_id not in (22001,22002,22003,22004,22005,22006,22007,22008,22009,22010,22011,22012,22013,22014,20901,20902,20905,25001,25002)
and game_product_id in 
(
'com.managames.myththor.iap_0.99hlyxlb'
,'com.managames.myththor.iap_4.99hlyxlb'
,'com.managames.myththor.iap_9.99hlyxlb'
,'com.managames.myththor.iap_19.99hlyxlb'
,'com.managames.myththor.iap_49.99hlyxlb'
,'com.managames.myththor.iap_99.99hlyxlb1'
,'com.managames.myththor.iap_0.99hlth'
,'com.managames.myththor.iap_1.99hlth'
,'com.managames.myththor.iap_2.99hlth'
,'com.managames.myththor.iap_4.99hlqrlb'
)
group by 1



vip购买礼包情况 购买礼包前的VIP等级
select max_vip_level
       ,count(distinct a.role_id) as '购买人数'
       ,sum(pay_price) as '礼包付费金额'
from
(select role_id,pay_price
from myth.order_pay
where log_time>=1692352800000 and log_time <= 1693562400000 -- 活动期间
and server_id not in (22001,22002,22003,22004,22005,22006,22007,22008,22009,22010,22011,22012,22013,22014,20901,20902,20905,25001,25002)
and game_product_id in 
(
'com.managames.myththor.iap_0.99hlyxlb'
,'com.managames.myththor.iap_4.99hlyxlb'
,'com.managames.myththor.iap_9.99hlyxlb'
,'com.managames.myththor.iap_19.99hlyxlb'
,'com.managames.myththor.iap_49.99hlyxlb'
,'com.managames.myththor.iap_99.99hlyxlb1'
,'com.managames.myththor.iap_0.99hlth'
,'com.managames.myththor.iap_1.99hlth'
,'com.managames.myththor.iap_2.99hlth'
,'com.managames.myththor.iap_4.99hlqrlb'
)
) as a 

left join -- 取最大VIP等级
(select role_id,max(vip_level) as max_vip_level
from
(select a.role_id,vip_level,max_date_time,date_time
from
(select role_id,max(date_time) as max_date_time--每个人买礼包的最大时间
from myth.order_pay
where log_time>=1692352800000 and log_time <= 1693562400000 -- 活动期间
and server_id not in (22001,22002,22003,22004,22005,22006,22007,22008,22009,22010,22011,22012,22013,22014,20901,20902,20905,25001,25002)
and game_product_id in 
(
'com.managames.myththor.iap_0.99hlyxlb'
,'com.managames.myththor.iap_4.99hlyxlb'
,'com.managames.myththor.iap_9.99hlyxlb'
,'com.managames.myththor.iap_19.99hlyxlb'
,'com.managames.myththor.iap_49.99hlyxlb'
,'com.managames.myththor.iap_99.99hlyxlb1'
,'com.managames.myththor.iap_0.99hlth'
,'com.managames.myththor.iap_1.99hlth'
,'com.managames.myththor.iap_2.99hlth'
,'com.managames.myththor.iap_4.99hlqrlb'
)
group by 1
) as a 

left join
(select role_id,date_time,vip_level --在线VIP
from myth.client_online
where log_time>=1692352800000 and log_time <= 1693562400000 -- 活动期间
and server_id not in (22001,22002,22003,22004,22005,22006,22007,22008,22009,22010,22011,22012,22013,22014,20901,20902,20905,25001,25002)
group by 1,2,3
) as b
on a.role_id = b.role_id and date_time <= max_date_time
group by 1,2,3,4
) as c 
group by 1
) as b
on a.role_id = b.role_id
group by 1 order by 1


VIP活跃
select max_vip,count(distinct role_id)
from
(select role_id,max(vip_level) as max_vip
from myth_server.server_login_snapshot
where log_time>=1692352800000 and log_time <= 1693562400000
and server_id not in (22001,22002,22003,22004,22005,22006,22007,22008,22009,22010,22011,22012,22013,22014,20901,20902,20905,25001,25002)
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
group by 1
) as  a 
group by 1
order by 1





四、活动拉收效果
活动期间的付费总额,总人数
select 
       sum(pay_price)
       ,count(distinct b.role_id)
from
(  --新增
select role_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=20230728 and log_time <= 1693562400000
and server_id not in (22001,22002,22003,22004,22005,22006,22007,22008,22009,22010,22011,22012,22013,22014,20901,20902,20905,25001,25002)
and channel_id in (1000,2000)
and version_name in ('1.5.1','1.5.2')
group by 1,2
) a

left join
(select role_id,pay_price,log_time
from myth.order_pay
where log_time>=1692352800000 and log_time <= 1693562400000 -- 活动期间付费
and server_id not in (22001,22002,22003,22004,22005,22006,22007,22008,22009,22010,22011,22012,22013,22014,20901,20902,20905,25001,25002)
group by 1,2,3
) b 
on a.role_id =b.role_id


购买礼包玩家活动期间总付费  
select sum(pay_price)
from myth.order_pay
where log_time>=1692352800000 and log_time <= 1693562400000 
and server_id not in (22001,22002,22003,22004,22005,22006,22007,22008,22009,22010,22011,22012,22013,22014,20901,20902,20905,25001,25002)
and role_id in 
(select role_id
from myth.order_pay
where day_time between ${activityBeginDate} and ${activityEndDate} 
and server_id not in (22001,22002,22003,22004,22005,22006,22007,22008,22009,22010,22011,22012,22013,22014,20901,20902,20905,25001,25002)
and game_product_id in 
(
'com.managames.myththor.iap_0.99hlyxlb'
,'com.managames.myththor.iap_4.99hlyxlb'
,'com.managames.myththor.iap_9.99hlyxlb'
,'com.managames.myththor.iap_19.99hlyxlb'
,'com.managames.myththor.iap_49.99hlyxlb'
,'com.managames.myththor.iap_99.99hlyxlb1'
,'com.managames.myththor.iap_0.99hlth'
,'com.managames.myththor.iap_1.99hlth'
,'com.managames.myththor.iap_2.99hlth'
,'com.managames.myththor.iap_4.99hlqrlb'
)
group by 1
) 

购买礼包人数，礼包金额上边已经算过了
select count(distinct role_id),sum(pay_price)
from myth.order_pay
where log_time>=1692352800000 and log_time <= 1693562400000 
and server_id not in (22001,22002,22003,22004,22005,22006,22007,22008,22009,22010,22011,22012,22013,22014,20901,20902,20905,25001,25002)
and game_product_id in 
(
'com.managames.myththor.iap_0.99hlyxlb'
,'com.managames.myththor.iap_4.99hlyxlb'
,'com.managames.myththor.iap_9.99hlyxlb'
,'com.managames.myththor.iap_19.99hlyxlb'
,'com.managames.myththor.iap_49.99hlyxlb'
,'com.managames.myththor.iap_99.99hlyxlb1'
,'com.managames.myththor.iap_0.99hlth'
,'com.managames.myththor.iap_1.99hlth'
,'com.managames.myththor.iap_2.99hlth'
,'com.managames.myththor.iap_4.99hlqrlb'
)



海拉礼包破冰人数
select game_product_id,count(distinct role_id)
from
(select role_id,game_product_id
from
(select role_id,game_product_id,row_number() over(partition by role_id order by log_time asc) as num
from myth.order_pay
where day_time >= 20230728 and log_time < 1693562400000
and server_id not in (22001,22002,22003,22004,22005,22006,22007,22008,22009,22010,22011,22012,22013,22014,20901,20902,20905,25001,25002)
) a 
where num = 1
and game_product_id in 
(
'com.managames.myththor.iap_0.99hlyxlb'
,'com.managames.myththor.iap_4.99hlyxlb'
,'com.managames.myththor.iap_9.99hlyxlb'
,'com.managames.myththor.iap_19.99hlyxlb'
,'com.managames.myththor.iap_49.99hlyxlb'
,'com.managames.myththor.iap_99.99hlyxlb1'
,'com.managames.myththor.iap_0.99hlth'
,'com.managames.myththor.iap_1.99hlth'
,'com.managames.myththor.iap_2.99hlth'
,'com.managames.myththor.iap_4.99hlqrlb'
)
) b 
group by 1



五、专属副本通关情况
select dungeon_id,
count(distinct b.role_id) as '进入关卡人数',
count(distinct case when battle_result=1 then b.role_id else null end ) as '通关人数',
count(distinct case when battle_result=1 then b.role_id else null end ) / count(distinct b.role_id) as '通关率',
count(distinct case when battle_result=2 then b.role_id else null end ) as '失败人数',
count(distinct case when battle_result=2 then b.role_id else null end ) / count(distinct b.role_id) as '失败率',
count(distinct case when battle_result is null then b.role_id else null end ) as '无日志人数',
count(distinct case when battle_result is null then b.role_id else null end ) / count(distinct b.role_id) as '无日志率',
count(distinct case when battle_result is null or battle_result =2 then b.role_id  else null end ) as '无日志&失败人数'

-- 复玩人数
-- count(distinct e.role_id)

-- 复玩通关人数
 -- count(distinct f.role_id)

-- -- 时长 通关-死亡-主动退出remain_hp 是否为0
-- count(distinct case when battle_result = 2 and remain_hp = 0 and battle_time <> '1超时' then b.role_id else null end) as '死亡人数',
-- count(distinct case when battle_result = 2 and battle_time = '1超时' and remain_hp <> 0 then b.role_id else null end) as '超时人数',
-- count(distinct case when battle_result = 2 and remain_hp <> 0 and battle_time <> '1超时' then b.role_id else null end) as '主动退出人数',
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
-- count(case when battle_result = 2 and remain_hp <> 0 and battle_time = '1超时' then start_time else null end) as '超时未通关次数',
-- count(case when battle_result = 2 and battle_time = '2困难' and remain_hp <> 0 then start_time else null end) as '主动退出2困难次数',
-- count(case when battle_result = 2 and battle_time = '3较难' and remain_hp <> 0 then start_time else null end) as '主动退出3较难次数',
-- count(case when battle_result = 2 and battle_time = '4一般' and remain_hp <> 0 then start_time else null end) as '主动退出4一般次数',
-- count(case when battle_result = 2 and remain_hp <> 0 and battle_time <> '1超时' then start_time else null end) as '主动退出汇总次数',
-- count(case when auto_battle is null then b.role_id else null end) as '无日志次数',
-- count(distinct start_time) as '总次数'

from

 -- 关卡参与情况
(select a.dungeon_id,a.role_id,a.start_time,battle_result,battle_time,auto_battle
from 
(select dungeon_id,role_id,start_time
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} 
and server_id not in (22001,22002,22003,22004,22005,22006,22007,22008,22009,22010,22011,22012,22013,22014,20901,20902,20905,25001,25002)
and game_type = 20
and dungeon_id in (8,9,10,11,12,13,14)
and channel_id in (1000,2000) 
and version_name in ('1.5.1','1.5.2')

group by 1,2,3
) as a
left join     
(select dungeon_id,role_id,start_time,battle_result,battle_time,auto_battle
from myth_server.server_dungeon_end
where day_time between ${beginDate} and ${endDate} 
and server_id not in (22001,22002,22003,22004,22005,22006,22007,22008,22009,22010,22011,22012,22013,22014,20901,20902,20905,25001,25002)
and game_type = 20
and dungeon_id in (8,9,10,11,12,13,14)
and channel_id in (1000,2000) 
and version_name in ('1.5.1','1.5.2')

group by 1,2,3,4,5,6
) c 
on a.dungeon_id=c.dungeon_id and a.role_id=c.role_id and a.start_time=c.start_time 
) as b 
group by 1 order by 1




-- -- 重复进入（复玩）人数
-- (select role_id,dungeon_id
-- from
-- (select dungeon_id,role_id,count(distinct start_time) as '进入次数'
-- from myth_server.server_enter_dungeon
-- where day_time>=${beginDate} and day_time<=${endDate} 
-- and server_id not in (22001,22002,22003,22004,22005,22006,22007,22008,22009,22010,22011,22012,22013,22014,20901,20902,20905,25001,25002)
-- and game_type = 20
-- and dungeon_id in (8,9,10,11,12,13,14)
-- and channel_id in (1000,2000) 
-- and version_name in ('1.5.1','1.5.2')
-- 
-- group by 1,2
-- ) c1
-- where 进入次数 > 1
-- group by 1,2
-- ) as e
-- group by 1 order by 1


-- -- 重复进入（复玩）最终通关人数
-- (select d.role_id,d.dungeon_id
-- from
-- (select role_id,dungeon_id,done_dt
-- from
-- (select dungeon_id,role_id,to_date(cast(date_time as timestamp)) as done_dt,count(distinct start_time) as '进入次数'
-- from myth_server.server_enter_dungeon
-- where day_time>=${beginDate} and day_time<=${endDate} 
-- and server_id not in (22001,22002,22003,22004,22005,22006,22007,22008,22009,22010,22011,22012,22013,22014,20901,20902,20905,25001,25002)
-- and game_type = 20
-- and dungeon_id in (8,9,10,11,12,13,14)
-- and channel_id in (1000,2000) 
-- and version_name in ('1.5.1','1.5.2')

-- group by 1,2,3
-- ) c1
-- where 进入次数 > 1
-- group by 1,2,3
-- ) as c
-- left join 
-- (select a.role_id as role_id,a.dungeon_id as dungeon_id,battle_result,done_dt
-- from
-- (select dungeon_id,role_id,to_date(cast(date_time as timestamp)) as done_dt,start_time
-- from myth_server.server_enter_dungeon
-- where day_time>=${beginDate} and day_time<=${endDate} 
-- and server_id not in (22001,22002,22003,22004,22005,22006,22007,22008,22009,22010,22011,22012,22013,22014,20901,20902,20905,25001,25002)
-- and game_type = 20
-- and dungeon_id in (8,9,10,11,12,13,14)
-- and channel_id in (1000,2000) 
-- and version_name in ('1.5.1','1.5.2')

-- group by 1,2,3,4) a 
-- left join 
-- (select dungeon_id,role_id,battle_result,log_time,start_time
-- from myth_server.server_dungeon_end
-- where day_time>=${beginDate} and day_time<=${endDate} 
-- and server_id not in (22001,22002,22003,22004,22005,22006,22007,22008,22009,22010,22011,22012,22013,22014,20901,20902,20905,25001,25002)
-- and game_type = 20
-- and dungeon_id in (8,9,10,11,12,13,14)
-- and channel_id in (1000,2000) 
-- and version_name in ('1.5.1','1.5.2')

-- group by 1,2,3,4,5) b 
-- on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time = b.start_time
-- where battle_result = 1 -- 有成功日志的
-- group by 1,2,3,4
-- ) as d 
-- on c.dungeon_id=d.dungeon_id and c.role_id=d.role_id
-- group by 1,2
-- ) as f 
-- group by 1
-- order by 1



-- -- 时长 通关-死亡-主动退出remain_hp 是否为0
-- (select dungeon_id,role_id,start_time,battle_result,battle_time,auto_battle,cast(split_part(remain_hp,',',1) as int) as remain_hp
-- from
-- (select a.dungeon_id,a.role_id,a.start_time,battle_result,battle_time,auto_battle,remain_hp
-- from 
-- (select dungeon_id,role_id,start_time
-- from myth_server.server_enter_dungeon
-- where day_time between ${beginDate} and ${endDate} 
-- and server_id not in (22001,22002,22003,22004,22005,22006,22007,22008,22009,22010,22011,22012,22013,22014,20901,20902,20905,25001,25002)
-- and game_type = 20
-- and dungeon_id in (8,9,10,11,12,13,14)
-- and channel_id in (1000,2000) 
-- and version_name in ('1.5.1','1.5.2')
-- 
-- group by 1,2,3
-- ) as a
-- left join     
-- (select dungeon_id,role_id,start_time,battle_result,
--         case when battle_time is null then '无日志'
--              when battle_time/60 >=3  then '1超时'
--              when battle_time/60 >=2 and battle_time/60 < 3  then '2困难'
--              when battle_time/60 >=1 and battle_time/60 < 2  then '3较难'
--              when battle_time/60 >=0 and battle_time/60 < 1  then '4一般'
--              else '无日志'
--         end as battle_time,auto_battle,remain_hp
-- from myth_server.server_dungeon_end
-- where day_time between ${beginDate} and ${endDate} 
-- and server_id not in (22001,22002,22003,22004,22005,22006,22007,22008,22009,22010,22011,22012,22013,22014,20901,20902,20905,25001,25002)
-- and game_type = 20
-- and dungeon_id in (8,9,10,11,12,13,14)
-- and channel_id in (1000,2000) 
-- and version_name in ('1.5.1','1.5.2')
-- 
-- group by 1,2,3,4,5,6,7
-- ) b 
-- on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time=b.start_time
-- order by a.role_id,a.start_time asc 
-- ) as e  
-- group by 1,2,3,4,5,6,7
-- ) as b 
-- group by 1
-- order by 1






六、付费签到分析
免费 100133 700811  138方式
没买礼包领取情况
select max_f,count(distinct role_id)
from
(select role_id,max(score) as max_f
from
(select
    case 
        when prop_id = '700811' and change_count >= 48 then 7
        when prop_id = '700811' and change_count >= 40 and change_count < 48 then 6
        when prop_id = '700811' and change_count >= 32 and change_count < 40 then 5
        when prop_id = '700811' and change_count >= 24 and change_count < 32 then 4
        when prop_id = '700811' and change_count >= 16 and change_count < 24 then 3
        when prop_id = '700811' and change_count >= 8 and change_count < 16 then 2
        when prop_id = '100133' and change_count = 1 then 1
        else 0 
    end as score,role_id
from
(select role_id,prop_id,sum(change_count) as change_count
from myth.server_prop
where log_time>=1692352800000 and log_time <= 1693562400000 -- 活动期间
and server_id not in (22001,22002,22003,22004,22005,22006,22007,22008,22009,22010,22011,22012,22013,22014,20901,20902,20905,25001,25002)
and change_type = 'PRODUCE'
and change_method = '138'
and prop_id in ('100133','700811') 
and role_id not in 
(select role_id
from myth.order_pay
where log_time>=1692352800000 and log_time <= 1693562400000 -- 活动期间
and server_id not in (22001,22002,22003,22004,22005,22006,22007,22008,22009,22010,22011,22012,22013,22014,20901,20902,20905,25001,25002)
and game_product_id = 'com.managames.myththor.iap_4.99hlqrlb'
group by 1
)
group by 1,2
) a 
group by 1,2
) b
group by 1
) c
group by 1 order by 1


买了礼包领取情况
select max_f,count(distinct role_id)
from
(select role_id,max(score) as max_f
from
(select
    case 
        when prop_id = '700811' and change_count >= 48 then 7
        when prop_id = '700811' and change_count >= 40 and change_count < 48 then 6
        when prop_id = '700811' and change_count >= 32 and change_count < 40 then 5
        when prop_id = '700811' and change_count >= 24 and change_count < 32 then 4
        when prop_id = '700811' and change_count >= 16 and change_count < 24 then 3
        when prop_id = '700811' and change_count >= 8 and change_count < 16 then 2
        when prop_id = '100133' and change_count = 1 then 1
        else 0 
    end as score,role_id
from
(select role_id,prop_id,sum(change_count) as change_count
from myth.server_prop
where log_time>=1692352800000 and log_time <= 1693562400000 -- 活动期间
and server_id not in (22001,22002,22003,22004,22005,22006,22007,22008,22009,22010,22011,22012,22013,22014,20901,20902,20905,25001,25002)
and change_type = 'PRODUCE'
and change_method = '138'
and prop_id in ('100133','700811') 
and role_id in 
(select role_id
from myth.order_pay
where log_time>=1692352800000 and log_time <= 1693562400000 -- 活动期间
and server_id not in (22001,22002,22003,22004,22005,22006,22007,22008,22009,22010,22011,22012,22013,22014,20901,20902,20905,25001,25002)
and game_product_id = 'com.managames.myththor.iap_4.99hlqrlb'
group by 1
)
group by 1,2
) a 
group by 1,2
) b
group by 1
) c
group by 1 order by 1



付费 100332 专属装备自选包 100502 神秘秘钥  143方式 礼包'com.managames.myththor.iap_4.99hlqrlb'
select max_f,count(distinct role_id)
from
(select role_id,max(score) as max_f
from
(select
    case 
        when prop_id = '100332' and change_count >= 1 then 7
        when prop_id = '100502' and change_count >= 60 then 6
        when prop_id = '100502' and change_count >= 50 and change_count < 60 then 5
        when prop_id = '100502' and change_count >= 40 and change_count < 50 then 4
        when prop_id = '100502' and change_count >= 30 and change_count < 40 then 3
        when prop_id = '100502' and change_count >= 20 and change_count < 30 then 2
        when prop_id = '100502' and change_count >= 10 and change_count < 20 then 1
        else 0 
    end as score,role_id
from
(select role_id,prop_id,sum(change_count) as change_count
from myth.server_prop
where log_time>=1692352800000 and log_time <= 1693562400000 -- 活动期间
and server_id not in (22001,22002,22003,22004,22005,22006,22007,22008,22009,22010,22011,22012,22013,22014,20901,20902,20905,25001,25002)
and change_type = 'PRODUCE'
and change_method = '143'
and prop_id in ('100332','100502')
and role_id in 
(select role_id
from myth.order_pay
where log_time>=1692352800000 and log_time <= 1693562400000 -- 活动期间
and server_id not in (22001,22002,22003,22004,22005,22006,22007,22008,22009,22010,22011,22012,22013,22014,20901,20902,20905,25001,25002)
and game_product_id = 'com.managames.myththor.iap_4.99hlqrlb'
group by 1
)
group by 1,2
) a 
group by 1,2
) b
group by 1
) c 
group by 1 order by 1

