---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

2、引导流失：先算新手引导绝对人数、再算各个关卡的进入+通关的绝对人数，最后按照节奏表整理数据

-- 新手引导流程  （节点通过率=下个节点/上个节点人数、整体通过率=每个节点人数/最开始节点的人数、流失点位=下面节点整体通过率-上面节点整体通过率）
select online_dt,step,付费档位,count(distinct a.role_id)
from

(-- 当天活跃
select role_id,to_date(cast (date_time as timestamp)) as online_dt
from myth.client_online
where day_time = ${endDate} 
and channel_id=1000
and version_name ='1.3.5'
and country not in ('CN','HK')
and role_id in (select distinct role_id 
                from myth.server_role_create
                where day_time>=${beginDate} and day_time<=${endDate} 
                and server_id in (${serverIds}) 
                and channel_id=1000  --Android
                and version_name ='1.3.5'
                and country not in ('CN','HK')
               )
) as a

left join
(    
select role_id,step_dt,step
from
(select role_id,day_time,step,to_date(cast(date_time as timestamp)) as step_dt
from myth.server_newbie
where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')

union all

select role_id,day_time,step,to_date(cast(date_time as timestamp)) as step_dt
from myth_server.server_event_guide
where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name ='1.3.5'
and country not in ('CN','HK')
) as b1
) as b
on a.role_id = b.role_id

left join -- 付费分档 分天来计算
(select role_id,
       -- 5号按照第一天分
       case when sum_pay = 0 then '零氪'
            when sum_pay > 0 and sum_pay <= 6 then '小R'
            when sum_pay > 6 and sum_pay <= 36 then '中R'
            when sum_pay > 36 and sum_pay <= 268 then '大R'
            else 'others'
            end as '付费档位'

       -- -- 6号按照第二天分
       -- case when sum_pay = 0 then '零氪'
       --      when sum_pay > 0 and sum_pay <= 36 then '小R'
       --      when sum_pay > 36 and sum_pay <= 108 then '中R'
       --      when sum_pay > 108 and sum_pay <= 566 then '大R'
       --      else 'others'
       --      end as '付费档位'

       -- -- 7号按照第三天分
       -- case when sum_pay = 0 then '零氪'
       --      when sum_pay > 0 and sum_pay <= 66 then '小R'
       --      when sum_pay > 66 and sum_pay <= 274 then '中R'
       --      when sum_pay > 274 and sum_pay <= 500 then '大R'
       --      else 'others'
       --      end as '付费档位'

       -- -- 8号按照第四天分
       -- case when sum_pay = 0 then '零氪'
       --      when sum_pay > 0 and sum_pay <= 78 then '小R'
       --      when sum_pay > 78 and sum_pay <= 500 then '中R'
       --      when sum_pay > 500 and sum_pay <= 882 then '大R'
       --      else 'others'
       --      end as '付费档位'

       -- -- 9号按照第五天分
       -- case when sum_pay = 0 then '零氪'
       --      when sum_pay > 0 and sum_pay <= 78 then '小R'
       --      when sum_pay > 78 and sum_pay <= 628 then '中R'
       --      when sum_pay > 628 and sum_pay <= 912 then '大R'
       --      else 'others'
       --      end as '付费档位'
from
(select role_id,to_date(cast(date_time as timestamp)) as pay_dt,sum(pay_price) as sum_pay
from myth.order_pay
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and country not in ('CN','HK')
group by 1,2
) c1
group by 1,2
) c
on a.role_id = c.role_id and c.pay_dt <= a.online_dt 
where datediff(b.step_dt,a.online_dt) = 0
group by 1,2,3
order by 1,2,3




-- 各个关卡的进入\通关人数  要一天一天算  excel透视表按照dungeon_id即是进入关卡人数，胜利即为通关人数
select online_dt,付费档位,dungeon_id,scene_id,battle_result,count(distinct a.role_id)
from

(-- 当天活跃
select role_id,to_date(cast (date_time as timestamp)) as online_dt
from myth.client_online
where day_time = ${endDate} 
and channel_id=1000
and version_name ='1.3.5'
and country not in ('CN','HK')
and role_id in (select distinct role_id 
                from myth.server_role_create
                where day_time>=${beginDate} and day_time<=${endDate} 
                and server_id in (${serverIds}) 
                and channel_id=1000  --Android
                and version_name ='1.3.5'
                and country not in ('CN','HK')
               )
) as a

left join
(select role_id,enter_dt,dungeon_id,scene_id,battle_result
from
(select role_id,dungeon_id,scene_id,battle_result,enter_dt
from
(select a.role_id as role_id,enter_dt,a.dungeon_id as dungeon_id,a.scene_id as scene_id,battle_result,row_number() over(partition by a.role_id,a.dungeon_id,enter_dt order by log_time desc) as num --取最后一条是因为关卡只能打一次
from
(select dungeon_id,scene_id,role_id,to_date(cast(date_time as timestamp)) as enter_dt
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type=3
and channel_id=1000
and version_name ='1.3.5'   
and country not in ('CN','HK')) a 
left join 
(select dungeon_id,scene_id,role_id,battle_result,log_time
from myth_server.server_dungeon_end
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type=3
and channel_id=1000
and version_name ='1.3.5'   
and country not in ('CN','HK')) b 
on a.dungeon_id=b.dungeon_id and a.scene_id = b.scene_id and a.role_id=b.role_id
) as c
where num = 1
group by 1,2,3,4,5
) as b1
) as b
on a.role_id = b.role_id

left join -- 付费分档 分天来计算
(select role_id,
       -- 5号按照第一天分
       case when sum_pay = 0 then '零氪'
            when sum_pay > 0 and sum_pay <= 6 then '小R'
            when sum_pay > 6 and sum_pay <= 36 then '中R'
            when sum_pay > 36 and sum_pay <= 268 then '大R'
            else 'others'
            end as '付费档位'

       -- -- 6号按照第二天分
       -- case when sum_pay = 0 then '零氪'
       --      when sum_pay > 0 and sum_pay <= 36 then '小R'
       --      when sum_pay > 36 and sum_pay <= 108 then '中R'
       --      when sum_pay > 108 and sum_pay <= 566 then '大R'
       --      else 'others'
       --      end as '付费档位'

       -- -- 7号按照第三天分
       -- case when sum_pay = 0 then '零氪'
       --      when sum_pay > 0 and sum_pay <= 66 then '小R'
       --      when sum_pay > 66 and sum_pay <= 274 then '中R'
       --      when sum_pay > 274 and sum_pay <= 500 then '大R'
       --      else 'others'
       --      end as '付费档位'

       -- -- 8号按照第四天分
       -- case when sum_pay = 0 then '零氪'
       --      when sum_pay > 0 and sum_pay <= 78 then '小R'
       --      when sum_pay > 78 and sum_pay <= 500 then '中R'
       --      when sum_pay > 500 and sum_pay <= 882 then '大R'
       --      else 'others'
       --      end as '付费档位'

       -- -- 9号按照第五天分
       -- case when sum_pay = 0 then '零氪'
       --      when sum_pay > 0 and sum_pay <= 78 then '小R'
       --      when sum_pay > 78 and sum_pay <= 628 then '中R'
       --      when sum_pay > 628 and sum_pay <= 912 then '大R'
       --      else 'others'
       --      end as '付费档位'
from
(select role_id,to_date(cast(date_time as timestamp)) as pay_dt,sum(pay_price) as sum_pay
from myth.order_pay
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and country not in ('CN','HK')
group by 1,2
) c1
group by 1,2
) c
on a.role_id = c.role_id and c.pay_dt <= a.online_dt 
where datediff(b.enter_dt,a.online_dt) = 0
group by 1,2,3,4,5
order by 1,2,3,5



-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
