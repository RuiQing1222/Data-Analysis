
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
领主争霸赛 

参与数据  -- 分付费档位 分等级段 分层
select cycle_id,vip,level_zone,dungeon_id
       ,count(distinct b.role_id) as '参与人数'
       ,count(distinct start_time) as '参与次数'
       ,count(distinct case when battle_result=1 then b.role_id else null end)  as '通关人数'
       ,count(distinct case when battle_result=1 then start_time else null end) as '通关次数'
       ,round((count(distinct case when battle_result=1 then start_time else null end)/count(distinct start_time)),2) as '通关率'
       ,count(distinct case when battle_result=2 then b.role_id else null end)  as '失败人数'
       ,count(distinct case when battle_result=2 then start_time else null end) as '失败次数'
       ,round((count(distinct case when battle_result=2 then start_time else null end)/count(distinct start_time)),2) as '失败率'
       --,count(distinct case when battle_result is null then start_time else null end) as '无日志次数'
       ,appx_median(battle_time) as '人均时长'
       ,avg(case when battle_result=1 then battle_time else null end) as '人均通关时长'
       ,min(case when battle_result=1 then battle_time else null end) as  '最短通关时长'
       ,max(case when battle_result=1 then battle_time else null end) as  '最短通关时长'

from
-- 付费档位
(select birth_dt,role_id,
case when total_pay<=8                    then 1
     when total_pay>8  and total_pay<=70  then 2
     when total_pay>70                    then 3 
     else 0 
     end as vip --D7
from 
(select birth_dt,a.role_id
,sum(case when datediff(vip_dt,birth_dt)<=${lifeTime}-1  then pay else 0 end ) as 'total_pay'
from

(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id in (1000,2000)
and version_name = '1.5.0'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id in (1000,2000)
and version_name = '1.5.0'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id --and a1.birth_dt = a2.device_birth_dt
group by 1,2
)  a

left join
(
select role_id,to_date(cast(date_time as timestamp)) as vip_dt,sum(pay_price) pay 
from myth.order_pay
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
group by 1,2 ) b 
on a.role_id =b.role_id
group by 1,2
) a1 
) a 

left join
-- 参与活动+结算数据
(select coalesce(c.cycle_id,b.cycle_id) as cycle_id,
  coalesce(c.turn_num,b.turn_num) as turn_num,
  coalesce(c.grade_num,b.grade_num) as dungeon_id,
  coalesce(c.level_zone,b.level_zone) as level_zone,
  coalesce(c.role_id,b.role_id) as role_id,
  coalesce(c.start_time,b.start_time) as start_time, 
  coalesce(c.battle_time,b.battle_time) as battle_time,
  coalesce(c.battle_result,b.battle_result) as battle_result
  from 
(select cycle_id,turn_num,grade_num,level_zone,role_id,start_time,battle_result,battle_time
from myth_server.server_hell_arena_scene
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id in (1000,2000)
and version_name = '1.5.0'
and country not in ('CN','HK')
group by 1,2,3,4,5,6,7,8
) b
left join 
(select cycle_id,turn_num,grade_num,level_zone,role_id,start_time,battle_result,battle_time
from myth_server.server_hell_arena
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id in (1000,2000)
and version_name = '1.5.0'
and country not in ('CN','HK')
group by 1,2,3,4,5,6,7,8
) c 
on b.cycle_id=c.cycle_id and c.grade_num=b.grade_num and c.role_id=b.role_id and c.start_time=b.start_time and c.turn_num = b.turn_num 

) b
on a.role_id = b.role_id
where b.role_id is not null 
group by 1,2,3,4







-- 分层-分BOSS通关率
-- select a.cycle_id, dungeon_id,boss_id
--        ,count(distinct a.start_time) as '进入关卡次数'
--        ,count(distinct case when battle_result = 1 then b.start_time else null end) as '通关次数'
--        ,round((count(distinct case when battle_result = 1 then b.start_time else null end) / count(distinct a.start_time)),2) as '通关率'
-- from
-- (select dungeon_id,role_id,start_time,cycle_id
-- from myth_server.server_enter_dungeon
-- where day_time between ${beginDate} and ${endDate} 
-- and server_id in (${serverIds})
-- and game_type = 22
-- and channel_id in (1000,2000)
-- and version_name = '1.5.0'
-- and country not in ('CN','HK')
-- group by 1,2,3,4
-- ) as a

-- left join     
-- (select cycle_id,grade_num,boss_id,role_id,start_time,battle_result,battle_time,auto_battle
-- from myth_server.server_hell_arena_scene
-- where day_time between ${beginDate} and ${endDate} 
-- and server_id in (${serverIds})
-- and channel_id in (1000,2000)
-- and version_name = '1.5.0'
-- and country not in ('CN','HK')
-- group by 1,2,3,4,5,6,7,8
-- ) b
-- on a.dungeon_id=b.grade_num and a.role_id=b.role_id and a.start_time=b.start_time 
-- group by 1,2,3
-- order by 1,2,3






技能出现和选择
技能出现：
select cycle_id,buff,count(1) as nums 
from 
(select role_id,cycle_id,turn_num,split_part(split_part(fresh_buff_list,'[',2),',',1) as buff 
from myth_server.server_hell_arena_scene
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
and length(fresh_buff_list)>2
union all 
select role_id,cycle_id,turn_num,split_part(split_part(fresh_buff_list,'[',2),',',2) as buff
from myth_server.server_hell_arena_scene
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
and length(fresh_buff_list)>2
union all 
select role_id,cycle_id,turn_num,split_part(split_part(split_part(fresh_buff_list,'[',2),',',3),']',1) as buff
from myth_server.server_hell_arena_scene 
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
and length(fresh_buff_list)>2
) a 
group by 1,2
order by 1




技能选择
select buff,cycle_id,count(1) as nums 
from 
(select role_id,cycle_id,turn_num,split_part(split_part(buff_list,'[',2),',',1) as buff 
from myth_server.server_hell_arena
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
and length(buff_list)>2
union all
select role_id,cycle_id,turn_num,split_part(split_part(buff_list,'[',2),',',2) as buff 
from myth_server.server_hell_arena
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
and length(buff_list)>2
union all
select role_id,cycle_id,turn_num,split_part(split_part(buff_list,'[',2),',',3) as buff 
from myth_server.server_hell_arena
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
and length(buff_list)>2
union all
select role_id,cycle_id,turn_num,split_part(split_part(buff_list,'[',2),',',4) as buff 
from myth_server.server_hell_arena
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
and length(buff_list)>2
union all
select role_id,cycle_id,turn_num,split_part(split_part(buff_list,'[',2),',',5) as buff 
from myth_server.server_hell_arena
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
and length(buff_list)>2
union all
select role_id,cycle_id,turn_num,split_part(split_part(buff_list,'[',2),',',6) as buff 
from myth_server.server_hell_arena
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
and length(buff_list)>2
union all
select role_id,cycle_id,turn_num,split_part(split_part(buff_list,'[',2),',',7) as buff 
from myth_server.server_hell_arena
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
and length(buff_list)>2
union all
select role_id,cycle_id,turn_num,split_part(split_part(buff_list,'[',2),',',8) as buff 
from myth_server.server_hell_arena
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
and length(buff_list)>2
union all
select role_id,cycle_id,turn_num,split_part(split_part(buff_list,'[',2),',',9) as buff 
from myth_server.server_hell_arena
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
and length(buff_list)>2
union all
select role_id,cycle_id,turn_num,split_part(split_part(split_part(buff_list,'[',2),',',10),']',1) as buff
from myth_server.server_hell_arena 
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
and length(buff_list)>2
) a 
group by 1,2




参与数据  -- 分付费档位 分等级段 分层
select cycle_id,vip,level_zone,grade_num
       -- ,count(distinct b.role_id) as '参与人数'
       -- ,count(distinct start_time) as '参与次数'
       ,count(distinct case when battle_result=1 then b.role_id else null end) as '通关人数'
       ,count(distinct case when battle_result=1 then start_time else null end) as '通关次数'
       ,count(distinct case when battle_result=2 then b.role_id else null end) as '失败人数'
       ,count(distinct case when battle_result=2 then start_time else null end) as '失败次数'

from

-- 付费档位
(select birth_dt,role_id,
case when total_pay<=8                    then 1
     when total_pay>8  and total_pay<=71  then 2
     when total_pay>71                    then 3 
     else 0 
     end as vip --D7
from 
(select birth_dt,a.role_id
,sum(case when datediff(vip_dt,birth_dt)<=${lifeTime}-1  then pay else 0 end ) as 'total_pay'
from

(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id in (1000,2000)
and version_name = '1.5.0'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id in (1000,2000)
and version_name = '1.5.0'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id --and a1.birth_dt = a2.device_birth_dt
group by 1,2
)  a

left join
(
select role_id,to_date(cast(date_time as timestamp)) as vip_dt,sum(pay_price) pay 
from myth.order_pay
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
group by 1,2 ) b 
on a.role_id =b.role_id
group by 1,2
) a1 
) a 


-- left join
-- -- 参与数据
-- (select cycle_id,turn_num,grade_num,level_zone,role_id,start_time
-- from
-- (select cycle_id,turn_num,grade_num,level_zone,role_id,start_time
-- from myth_server.server_hell_arena_scene
-- where day_time between ${beginDate} and ${endDate} 
-- and server_id in (${serverIds})
-- and channel_id in (1000,2000)
-- and version_name = '1.5.0'
-- and country not in ('CN','HK')
-- group by 1,2,3,4,5,6
-- union all 
-- select cycle_id,turn_num,grade_num,level_zone,role_id,start_time
-- from myth_server.server_hell_arena
-- where day_time between ${beginDate} and ${endDate} 
-- and server_id in (${serverIds})
-- and channel_id in (1000,2000)
-- and version_name = '1.5.0'
-- and country not in ('CN','HK')
-- group by 1,2,3,4,5,6
-- ) b1
-- group by 1,2,3,4,5,6
-- ) b
-- on a.role_id = b.role_id
-- group by 1,2,3,4


-- 通关、失败
left join
(select cycle_id,turn_num,grade_num,level_zone,role_id,start_time,battle_result
from myth_server.server_hell_arena
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id in (1000,2000)
and version_name = '1.5.0'
and country not in ('CN','HK')
group by 1,2,3,4,5,6,7
) b
on a.role_id = b.role_id
group by 1,2,3,4









select dungeon_id,
case when dungeon_id = 1 then '1-1'
     when dungeon_id = 2 then '1-2'
     when dungeon_id = 3 then '1-3'
     when dungeon_id = 4 then '1-4'
     when dungeon_id = 5 then '1-5'
     when dungeon_id = 6 then '1-6'
     when dungeon_id = 7 then '1-7'
     when dungeon_id = 8 then '2-1'
     when dungeon_id = 9 then '2-2'
     when dungeon_id = 10 then '2-3'
     when dungeon_id = 11 then '2-4'
     when dungeon_id = 12 then '2-5'
     when dungeon_id = 13 then '2-6'
     when dungeon_id = 14 then '2-7'
     when dungeon_id = 15 then '2-8'
     when dungeon_id = 16 then '2-9'
     when dungeon_id = 17 then '2-10'
     when dungeon_id = 18 then '2-11'
     when dungeon_id = 19 then '2-12'
     when dungeon_id = 20 then '3-1'
     when dungeon_id = 21 then '3-2'
     when dungeon_id = 22 then '3-3'
     when dungeon_id = 23 then '3-4'
     when dungeon_id = 24 then '3-5'
     when dungeon_id = 25 then '3-6'
     when dungeon_id = 26 then '3-7'
     when dungeon_id = 27 then '3-8'
     when dungeon_id = 28 then '3-9'
     when dungeon_id = 29 then '3-10'
     when dungeon_id = 30 then '3-11'
     when dungeon_id = 31 then '3-12'
     when dungeon_id = 32 then '3-13'
     when dungeon_id = 33 then '3-14'
     when dungeon_id = 34 then '3-15'
     when dungeon_id = 35 then '3-16'
     when dungeon_id = 36 then '4-1'
     when dungeon_id = 37 then '4-2'
     when dungeon_id = 38 then '4-3'
     when dungeon_id = 39 then '4-4'
     when dungeon_id = 40 then '4-5'
     when dungeon_id = 41 then '4-6'
     when dungeon_id = 42 then '4-7'
     when dungeon_id = 43 then '4-8'
     when dungeon_id = 44 then '4-9'
     when dungeon_id = 45 then '4-10'
     when dungeon_id = 46 then '4-11'
     when dungeon_id = 47 then '4-12'
     when dungeon_id = 48 then '4-13'
     when dungeon_id = 49 then '4-14'
     when dungeon_id = 50 then '4-15'
     when dungeon_id = 51 then '4-16'
     when dungeon_id = 52 then '4-17'
     when dungeon_id = 53 then '4-18'
     when dungeon_id = 54 then '4-19'
     when dungeon_id = 55 then '4-20'
     when dungeon_id = 56 then '5-1'
     when dungeon_id = 57 then '5-2'
     when dungeon_id = 58 then '5-3'
     when dungeon_id = 59 then '5-4'
     when dungeon_id = 60 then '5-5'
     when dungeon_id = 61 then '5-6'
     when dungeon_id = 62 then '5-7'
     when dungeon_id = 63 then '5-8'
     when dungeon_id = 64 then '5-9'
     when dungeon_id = 65 then '5-10'
     when dungeon_id = 66 then '5-11'
     when dungeon_id = 67 then '5-12'
     when dungeon_id = 68 then '5-13'
     when dungeon_id = 69 then '5-14'
     when dungeon_id = 70 then '5-15'
     when dungeon_id = 71 then '5-16'
     when dungeon_id = 72 then '5-17'
     when dungeon_id = 73 then '5-18'
     when dungeon_id = 74 then '5-19'
     when dungeon_id = 75 then '5-20'
     when dungeon_id = 76 then '5-21'
     when dungeon_id = 77 then '5-22'
     when dungeon_id = 78 then '5-23'
     when dungeon_id = 79 then '5-24'
     when dungeon_id = 80 then '6-1'
     when dungeon_id = 81 then '6-2'
     when dungeon_id = 82 then '6-3'
     when dungeon_id = 83 then '6-4'
     when dungeon_id = 84 then '6-5'
     when dungeon_id = 85 then '6-6'
     when dungeon_id = 86 then '6-7'
     when dungeon_id = 87 then '6-8'
     when dungeon_id = 88 then '6-9'
     when dungeon_id = 89 then '6-10'
     when dungeon_id = 90 then '6-11'
     when dungeon_id = 91 then '6-12'
     when dungeon_id = 92 then '6-13'
     when dungeon_id = 93 then '6-14'
     when dungeon_id = 94 then '6-15'
     when dungeon_id = 95 then '6-16'
     when dungeon_id = 96 then '6-17'
     when dungeon_id = 97 then '6-18'
     when dungeon_id = 98 then '6-19'
     when dungeon_id = 99 then '6-20'
     when dungeon_id = 100 then '6-21'
     when dungeon_id = 101 then '6-22'
     when dungeon_id = 102 then '6-23'
     when dungeon_id = 103 then '6-24'
     when dungeon_id = 104 then '6-25'
     when dungeon_id = 105 then '6-26'
     when dungeon_id = 106 then '6-27'
     when dungeon_id = 107 then '6-28'
     when dungeon_id = 108 then '7-1'
     when dungeon_id = 109 then '7-2'
     when dungeon_id = 110 then '7-3'
     when dungeon_id = 111 then '7-4'
     when dungeon_id = 112 then '7-5'
     when dungeon_id = 113 then '7-6'
     when dungeon_id = 114 then '7-7'
     when dungeon_id = 115 then '7-8'
     when dungeon_id = 116 then '7-9'
     when dungeon_id = 117 then '7-10'
     when dungeon_id = 118 then '7-11'
     when dungeon_id = 119 then '7-12'
     when dungeon_id = 120 then '7-13'
     when dungeon_id = 121 then '7-14'
     when dungeon_id = 122 then '7-15'
     when dungeon_id = 123 then '7-16'
     when dungeon_id = 124 then '7-17'
     when dungeon_id = 125 then '7-18'
     when dungeon_id = 126 then '7-19'
     when dungeon_id = 127 then '7-20'
     when dungeon_id = 128 then '7-21'
     when dungeon_id = 129 then '7-22'
     when dungeon_id = 130 then '7-23'
     when dungeon_id = 131 then '7-24'
     when dungeon_id = 132 then '7-25'
     when dungeon_id = 133 then '7-26'
     when dungeon_id = 134 then '7-27'
     when dungeon_id = 135 then '7-28'
     when dungeon_id = 136 then '7-29'
     when dungeon_id = 137 then '7-30'
     when dungeon_id = 138 then '7-31'
     when dungeon_id = 139 then '7-32'
     when dungeon_id = 140 then '8-1'
     when dungeon_id = 141 then '8-2'
     when dungeon_id = 142 then '8-3'
     when dungeon_id = 143 then '8-4'
     when dungeon_id = 144 then '8-5'
     when dungeon_id = 145 then '8-6'
     when dungeon_id = 146 then '8-7'
     when dungeon_id = 147 then '8-8'
     when dungeon_id = 148 then '8-9'
     when dungeon_id = 149 then '8-10'
     when dungeon_id = 150 then '8-11'
     when dungeon_id = 151 then '8-12'
     when dungeon_id = 152 then '8-13'
     when dungeon_id = 153 then '8-14'
     when dungeon_id = 154 then '8-15'
     when dungeon_id = 155 then '8-16'
     when dungeon_id = 156 then '8-17'
     when dungeon_id = 157 then '8-18'
     when dungeon_id = 158 then '8-19'
     when dungeon_id = 159 then '8-20'
     when dungeon_id = 160 then '8-21'
     when dungeon_id = 161 then '8-22'
     when dungeon_id = 162 then '8-23'
     when dungeon_id = 163 then '8-24'
     when dungeon_id = 164 then '8-25'
     when dungeon_id = 165 then '8-26'
     when dungeon_id = 166 then '8-27'
     when dungeon_id = 167 then '8-28'
     when dungeon_id = 168 then '8-29'
     when dungeon_id = 169 then '8-30'
     when dungeon_id = 170 then '8-31'
     when dungeon_id = 171 then '8-32'
     when dungeon_id = 172 then '8-33'
     when dungeon_id = 173 then '8-34'
     when dungeon_id = 174 then '8-35'
     when dungeon_id = 175 then '8-36'
     when dungeon_id = 176 then '9-1'
     when dungeon_id = 177 then '9-2'
     when dungeon_id = 178 then '9-3'
     when dungeon_id = 179 then '9-4'
     when dungeon_id = 180 then '9-5'
     when dungeon_id = 181 then '9-6'
     when dungeon_id = 182 then '9-7'
     when dungeon_id = 183 then '9-8'
     when dungeon_id = 184 then '9-9'
     when dungeon_id = 185 then '9-10'
     when dungeon_id = 186 then '9-11'
     when dungeon_id = 187 then '9-12'
     when dungeon_id = 188 then '9-13'
     when dungeon_id = 189 then '9-14'
     when dungeon_id = 190 then '9-15'
     when dungeon_id = 191 then '9-16'
     when dungeon_id = 192 then '9-17'
     when dungeon_id = 193 then '9-18'
     when dungeon_id = 194 then '9-19'
     when dungeon_id = 195 then '9-20'
     when dungeon_id = 196 then '9-21'
     when dungeon_id = 197 then '9-22'
     when dungeon_id = 198 then '9-23'
     when dungeon_id = 199 then '9-24'
     when dungeon_id = 200 then '9-25'
     when dungeon_id = 201 then '9-26'
     when dungeon_id = 202 then '9-27'
     when dungeon_id = 203 then '9-28'
     when dungeon_id = 204 then '9-29'
     when dungeon_id = 205 then '9-30'
     when dungeon_id = 206 then '9-31'
     when dungeon_id = 207 then '9-32'
     when dungeon_id = 208 then '9-33'
     when dungeon_id = 209 then '9-34'
     when dungeon_id = 210 then '9-35'
     when dungeon_id = 211 then '9-36'
     when dungeon_id = 212 then '9-37'
     when dungeon_id = 213 then '9-38'
     when dungeon_id = 214 then '9-39'
     when dungeon_id = 215 then '9-40'
     when dungeon_id = 216 then '10-1'
     when dungeon_id = 217 then '10-2'
     when dungeon_id = 218 then '10-3'
     when dungeon_id = 219 then '10-4'
     when dungeon_id = 220 then '10-5'
     when dungeon_id = 221 then '10-6'
     when dungeon_id = 222 then '10-7'
     when dungeon_id = 223 then '10-8'
     when dungeon_id = 224 then '10-9'
     when dungeon_id = 225 then '10-10'
     when dungeon_id = 226 then '10-11'
     when dungeon_id = 227 then '10-12'
     when dungeon_id = 228 then '10-13'
     when dungeon_id = 229 then '10-14'
     when dungeon_id = 230 then '10-15'
     when dungeon_id = 231 then '10-16'
     when dungeon_id = 232 then '10-17'
     when dungeon_id = 233 then '10-18'
     when dungeon_id = 234 then '10-19'
     when dungeon_id = 235 then '10-20'
     when dungeon_id = 236 then '10-21'
     when dungeon_id = 237 then '10-22'
     when dungeon_id = 238 then '10-23'
     when dungeon_id = 239 then '10-24'
     when dungeon_id = 240 then '10-25'
     when dungeon_id = 241 then '10-26'
     when dungeon_id = 242 then '10-27'
     when dungeon_id = 243 then '10-28'
     when dungeon_id = 244 then '10-29'
     when dungeon_id = 245 then '10-30'
     when dungeon_id = 246 then '10-31'
     when dungeon_id = 247 then '10-32'
     when dungeon_id = 248 then '10-33'
     when dungeon_id = 249 then '10-34'
     when dungeon_id = 250 then '10-35'
     when dungeon_id = 251 then '10-36'
     when dungeon_id = 252 then '10-37'
     when dungeon_id = 253 then '10-38'
     when dungeon_id = 254 then '10-39'
     when dungeon_id = 255 then '10-40'
     else null
     end as '关卡名',
count(distinct case when suppression = '绿色' then start_time else null end) as '绿色进入关卡次数',
round((count(distinct case when battle_result=1 and suppression = '绿色' then b.role_id else null end ) / count(distinct case when suppression = '绿色' then start_time else null end))*100,2) as '绿色通关率%',
count(distinct case when suppression = '白色' then start_time else null end) as '白色进入关卡次数',
round((count(distinct case when battle_result=1 and suppression = '白色' then b.role_id else null end ) / count(distinct case when suppression = '白色' then start_time else null end))*100,2) as '白色通关率%',
count(distinct case when suppression = '黄色' then start_time else null end) as '黄色进入关卡次数',
round((count(distinct case when battle_result=1 and suppression = '黄色' then b.role_id else null end ) / count(distinct case when suppression = '黄色' then start_time else null end))*100,2) as '黄色通关率%',
count(distinct case when suppression = '橙色' then start_time else null end) as '橙色进入关卡次数',
round((count(distinct case when battle_result=1 and suppression = '橙色' then b.role_id else null end ) / count(distinct case when suppression = '橙色' then start_time else null end))*100,2) as '橙色通关率%',
count(distinct case when suppression = '红色' then start_time else null end) as '红色进入关卡次数',
round((count(distinct case when battle_result=1 and suppression = '红色' then b.role_id else null end ) / count(distinct case when suppression = '红色' then start_time else null end))*100,2) as '红色通关率%'
from
(select a.dungeon_id,a.role_id,a.start_time,battle_result,battle_time,auto_battle,done_dt,suppression
from 
(select dungeon_id,role_id,start_time,to_date(cast(date_time as timestamp)) as done_dt
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 3 -- 3->战役
and channel_id in (1000,2000)
and version_name ='1.5.0'
and country not in ('CN','HK')
group by 1,2,3,4
) as a
left join     
(select dungeon_id,role_id,start_time,battle_result,battle_time,auto_battle,
        case when suppression = 84 then '绿色'
             when suppression >= 85 and suppression <= 95 then '白色'
             when suppression >= 96 and suppression <= 105 then '黄色'
             when suppression >= 106 and suppression <= 135 then '橙色'
             when suppression >= 136 and suppression <= 165 then '红色'
        end as suppression
from myth_server.server_dungeon_end
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 3 -- 3->战役
and channel_id in (1000,2000)
and version_name ='1.5.0'
and country not in ('CN','HK')
group by 1,2,3,4,5,6,7
) c 
on a.dungeon_id=c.dungeon_id and a.role_id=c.role_id and a.start_time=c.start_time 
) as b 
group by 1,2 order by 1




select dungeon_id,
count(distinct case when suppression = '绿色' then start_time else null end) as '绿色进入关卡次数',
round((count(distinct case when battle_result=1 and suppression = '绿色' then b.role_id else null end ) / count(distinct case when suppression = '绿色' then start_time else null end))*100,2) as '绿色通关率%',
count(distinct case when suppression = '白色' then start_time else null end) as '白色进入关卡次数',
round((count(distinct case when battle_result=1 and suppression = '白色' then b.role_id else null end ) / count(distinct case when suppression = '白色' then start_time else null end))*100,2) as '白色通关率%',
count(distinct case when suppression = '黄色' then start_time else null end) as '黄色进入关卡次数',
round((count(distinct case when battle_result=1 and suppression = '黄色' then b.role_id else null end ) / count(distinct case when suppression = '黄色' then start_time else null end))*100,2) as '黄色通关率%',
count(distinct case when suppression = '橙色' then start_time else null end) as '橙色进入关卡次数',
round((count(distinct case when battle_result=1 and suppression = '橙色' then b.role_id else null end ) / count(distinct case when suppression = '橙色' then start_time else null end))*100,2) as '橙色通关率%',
count(distinct case when suppression = '红色' then start_time else null end) as '红色进入关卡次数',
round((count(distinct case when battle_result=1 and suppression = '红色' then b.role_id else null end ) / count(distinct case when suppression = '红色' then start_time else null end))*100,2) as '红色通关率%'
from
(select a.dungeon_id,a.role_id,a.start_time,battle_result,battle_time,auto_battle,done_dt,suppression
from 
(select dungeon_id,role_id,start_time,to_date(cast(date_time as timestamp)) as done_dt
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 2
and channel_id in (1000,2000)
and version_name ='1.5.0'
and country not in ('CN','HK')
group by 1,2,3,4
) as a
left join     
(select dungeon_id,role_id,start_time,battle_result,battle_time,auto_battle,
        case when suppression = 2 then '绿色'
             when suppression >= 3 and suppression <= 13 then '白色'
             when suppression >= 14 and suppression <= 23 then '黄色'
             when suppression >= 24 and suppression <= 53 then '橙色'
             when suppression >= 54 and suppression <= 83 then '红色'
        end as suppression
from myth_server.server_dungeon_end
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 2
and channel_id in (1000,2000)
and version_name ='1.5.0'
and country not in ('CN','HK')
group by 1,2,3,4,5,6,7
) c 
on a.dungeon_id=c.dungeon_id and a.role_id=c.role_id and a.start_time=c.start_time 
) as b 
group by 1 order by 1