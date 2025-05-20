公会

公会远征：普通                                                
简单模式                                              
关卡ID  格子类型  参与人数  "参与比例（参与人数/有公会人数）" 人均参与次数  人均时长 通关率  无日志率 自动次数 手动次数


select dungeon_id as '关卡ID',blank_type as '格子类型'
       ,count(distinct a.role_id) as  '参与人数'
       ,round(count(distinct a.role_id)/count(distinct b.role_id),2) as '参与比例'
       ,round(count(a.start_time) / count(distinct a.role_id),2) as '人均参与次数'
       ,round(sum(battle_time)/count(distinct a.role_id),2) as '人均时长'
       ,round((count(distinct case when battle_result = 1 then a.role_id else null end)/count(distinct a.role_id))*100,2) as '通关率'
       ,round((count(distinct case when battle_result is null then a.start_time else null end)/count(distinct a.start_time))*100,2) as '无日志率'
       ,count(case when auto_battle = 1 then a.start_time else null end) as '自动次数'
       ,count(case when auto_battle = 0 then a.start_time else null end) as '手动次数'
from

-- 简单模式
(select dungeon_id,
        case when blank_type = 1 then '普通'
             when blank_type = 2 then '精英'
             when blank_type = 3 then '守卫'
             when blank_type = 4 then '领主'
             when blank_type = 0 then '宝箱'
         end as blank_type,role_id,start_time,battle_result,battle_time,auto_battle
from myth_server.server_guild_challenge
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3,4,5,6,7
) a 

left join -- 有公会的人
(select role_id
from myth_server.server_login_snapshot
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and guild_id is not null
) b
on a.role_id = b.role_id
group by 1,2
order by 1,2



公会远征：无尽                                 
                                    
日期  参与人数    "参与比例（参与人数/有公会人数）"   人均参与次数  人均时长    人均伤害值    自动次数    手动次数

select a.day_time as '日期'
       ,count(distinct a.role_id) as  '参与人数'
       ,round(count(distinct a.role_id)/count(distinct b.role_id),2) as '参与比例'
       ,round(count(a.start_time) / count(distinct a.role_id),2) as '人均参与次数'
       ,round(sum(battle_time)/count(distinct a.role_id),2) as '人均时长'
       ,round(sum(damage_value)/count(distinct a.role_id),2) as '人均伤害值'
       ,count(case when auto_battle = 1 then a.start_time else null end) as '自动次数'
       ,count(case when auto_battle = 0 then a.start_time else null end) as '手动次数'
from

-- 简单模式
(select day_time,role_id,start_time,battle_time,auto_battle,damage_value
from myth_server.server_guild_endless
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3,4,5,6,7
) a 

left join -- 有公会的人
(select role_id,day_time
from myth_server.server_login_snapshot
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and guild_id is not null
group by 1,2
) b
on a.role_id = b.role_id and a.day_time = b.day_time
group by 1
order by 1