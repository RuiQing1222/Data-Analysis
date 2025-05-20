玩法系统数据分析  
玩法——7->地精宝库
活跃维度
                                                                                                    
-- 副本ID 进入关卡人数 通关率 复玩率  扫荡人数 人均扫荡次数 中途退出率  通关                      未通关                    自动                  手动                总次数
--                                                                超时>3 [3,2) [2,1) [1,0)  超时>3 [3,2) [2,1) [1,0)  自动通关%  自动未通关% 手动通关% 手动未通关%    
-- 1                                       
-- 2    

select a.副本ID,进入关卡人数,通关率,复玩率,扫荡人数,人均扫荡次数,中途退出率
       ,通关1 as '通关超时>3',通关2 as '通关[3,2)',通关3 as '通关[2,1)',通关4 as '通关[1,0)'
       ,未通关1 as '未通关超时>3',未通关2 as '未通关[3,2)',未通关3 as '未通关[2,1)',未通关4 as '未通关[1,0)'
       ,自动通关率,自动未通关率,手动通关率,手动未通关率,总次数
from
(select dungeon_id as '副本ID'      
       ,count(distinct role_id) as '进入关卡人数'
       ,round((count(distinct case when battle_result = 1 then role_id else null end)/count(distinct role_id))*100,2) as '通关率'
       ,round((count(case when 是否退出 = 'yes' then start_time else null end)/count(start_time))*100,2) as '中途退出率'
       ,count(case when battle_result = 1 and battle_time = '1超时' then start_time else null end) as '通关1'
       ,count(case when battle_result = 1 and battle_time = '2困难' then start_time else null end) as '通关2'
       ,count(case when battle_result = 1 and battle_time = '3较难' then start_time else null end) as '通关3'
       ,count(case when battle_result = 1 and battle_time = '4一般' then start_time else null end) as '通关4'
       ,count(case when battle_result = 2 and battle_time = '1超时' then start_time else null end) as '未通关1'
       ,count(case when battle_result = 2 and battle_time = '2困难' then start_time else null end) as '未通关2'
       ,count(case when battle_result = 2 and battle_time = '3较难' then start_time else null end) as '未通关3'
       ,count(case when battle_result = 2 and battle_time = '4一般' then start_time else null end) as '未通关4'
       ,round((count(case when battle_result = 1 and auto_battle = 1 then start_time else null end)/count(start_time))*100,2) as '自动通关率'
       ,round((count(case when battle_result = 2 and auto_battle = 1 then start_time else null end)/count(start_time))*100,2) as '自动未通关率'
       ,round((count(case when battle_result = 1 and auto_battle = 0 then start_time else null end)/count(start_time))*100,2) as '手动通关率'
       ,round((count(case when battle_result = 2 and auto_battle = 0 then start_time else null end)/count(start_time))*100,2) as '手动未通关率'
       ,count(start_time) as '总次数'
from 
       
(select a.dungeon_id,a.role_id,a.start_time,battle_result,battle_time,auto_battle,case when battle_result is null then 'yes' else 'no' end as '是否退出'
from
(select dungeon_id,role_id,start_time,to_date(cast(date_time as timestamp)) as done_dt
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 7 -- 7->地精宝库
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3,4
) as a
left join     
(select dungeon_id,role_id,start_time,battle_result,
        case when battle_time/60000 is null then '无日志'
             when battle_time/60000 > 3  then '1超时'
             when battle_time/60000 > 2 and battle_time/60000 <= 3  then '2困难'
             when battle_time/60000 > 1 and battle_time/60000 <= 2  then '3较难'
             when battle_time/60000 > 0 and battle_time/60000 <= 1  then '4一般'
             else '无日志'
        end as battle_time,auto_battle
from myth_server.server_dungeon_end
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 7 -- 7->地精宝库
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3,4,5,6
) b 
on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time=b.start_time
group by 1,2,3,4,5,6,7
) as a
group by 1
order by 1
) as a

left join
-- 副本扫荡
(select dungeon_id as '副本ID'
       ,count(distinct role_id) as '扫荡人数'
       ,round(count(1)/count(distinct role_id),2) as '人均扫荡次数'
from
(select dungeon_id,role_id,date_time
from myth_server.server_dungeon_blitz
where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id=1000  --Android
and game_type = 7 -- 7地精宝库扫荡
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3
) as b1
group by 1
order by 1
) as b
on a.副本ID = b.副本ID

left join
-- 副本复玩率，多次进入关卡即为此关卡复玩
(select dungeon_id as '副本ID'
       ,round((count(distinct case when 进入次数 > 1 then role_id else null end)/count(distinct role_id))*100,2) as '复玩率'
from
(select dungeon_id,role_id,count(distinct start_time) as '进入次数'
from
(select dungeon_id,role_id,start_time -- start_time也可用统计参与次数
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 7 -- 7->地精宝库
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3
union all
select dungeon_id,role_id,log_time as start_time -- log_time也可用统计参与次数
from myth_server.server_dungeon_blitz
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 7 -- 7->地精宝库
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3
) as c1
group by 1,2
) as c2
group by 1
order by 1
) as c 
on a.副本ID = c.副本ID
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20
order by 1
