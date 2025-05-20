-- 新增维度

select case e.datediffs 
when 0 then '第1天'
when 1 then '第2天'
when 2 then '第3天'
-- when 3 then '第4天'
-- when 4 then '第5天'
-- when 5 then '第6天'
-- when 6 then '第7天' 
end as '新增留存天数',
秘境人数,战役人数,竞技场人数,远古战场人数,地精宝库人数,诸神试炼人数,宝石矿坑人数,公会领主人数,
round(秘境人数/秘境活跃*100,2) as '秘境参与率%',
round(战役人数/战役活跃*100,2) as '战役参与率%',
round(竞技场人数/竞技场活跃*100,2) as '竞技场参与率%',
round(远古战场人数/远古战场活跃*100,2) as '远古战场参与率%',
round(地精宝库人数/地精宝库活跃*100,2) as '地精宝库参与率%', 
round(诸神试炼人数/诸神试炼活跃*100,2) as '诸神试炼参与率%', 
round(宝石矿坑人数/宝石矿坑活跃*100,2) as '宝石矿坑参与率%',
round(公会领主人数/公会领主活跃*100,2) as '公会领主参与率%'
from 
(select datediff(pass_dt,birth_dt) as  datediffs,
count(distinct case when game_type=2   then a.role_id else null end) as '秘境人数',
count(distinct case when game_type=3   then a.role_id else null end) as '战役人数',
count(distinct case when game_type=4   then a.role_id else null end) as '竞技场人数',
count(distinct case when game_type=6   then a.role_id else null end) as '远古战场人数',
count(distinct case when game_type=7   then a.role_id else null end) as '地精宝库人数',
count(distinct case when game_type in (8,9,10,11,12,13)  then a.role_id else null end) as '诸神试炼人数',
count(distinct case when game_type=14  then a.role_id else null end) as '宝石矿坑人数',
count(distinct case when game_type =16 then a.role_id else null end) as '公会领主人数'
from 
(select to_date(cast (date_time as timestamp)) as birth_dt,role_id
from
(select device_id from myth.device_activate where day_time between ${beginDate} and ${endDate}
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
group by 1
) as a
left join
(select device_id,role_id,date_time
from myth.server_role_create
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
group by 1,2,3) as b
on a.device_id = b.device_id
group by 1,2) a 
left join 
(select to_date(cast (date_time as timestamp)) as pass_dt,game_type,role_id
from myth_server.server_enter_dungeon
where  day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
group by 1,2,3
) b 
on a.role_id=b.role_id
where datediff(pass_dt,birth_dt)>=0 and datediff(pass_dt,birth_dt)<=2
group by 1 
) e 
left join 
(select datediff(level_dt,birth_dt) as  datediffs,
count(distinct case when dungeon_id>=14  then d.role_id else null end) as '秘境活跃',
count(distinct case when dungeon_id>=12  then d.role_id else null end) as '竞技场活跃',
count(distinct case when dungeon_id>=34  then d.role_id else null end) as '远古战场活跃',
count(distinct case when dungeon_id>=10  then d.role_id else null end) as '地精宝库活跃',
count(distinct case when dungeon_id>=80  then d.role_id else null end) as '诸神试炼活跃',
count(distinct case when dungeon_id>=28  then d.role_id else null end) as '宝石矿坑活跃',
count(distinct case when dungeon_id>=18  then d.role_id else null end) as '公会领主活跃'
from 
(select to_date(cast (date_time as timestamp)) as birth_dt,role_id
from
(select device_id from myth.device_activate where day_time between ${beginDate} and ${endDate}
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
group by 1
) as a
left join
(select device_id,role_id,date_time
from myth.server_role_create
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
group by 1,2,3) as b
on a.device_id = b.device_id
group by 1,2) c 
left join 
(select to_date(cast (date_time as timestamp)) as level_dt,role_id,dungeon_id
from myth_server.server_dungeon_end
where  day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
and game_type=3 

group by 1,2,3) d
on c.role_id=d.role_id
where datediff(level_dt,birth_dt)>=0 and datediff(level_dt,birth_dt)<=2
group by 1
)  f 
on e.datediffs=f.datediffs
left join 
(select datediff(login_dt,birth_dt) as  datediffs,count(distinct g.role_id) as '战役活跃'
from
(select to_date(cast (date_time as timestamp)) as birth_dt,role_id
from
(select device_id from myth.device_activate where day_time between ${beginDate} and ${endDate}
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
group by 1
) as a
left join
(select device_id,role_id,date_time
from myth.server_role_create
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
group by 1,2,3) as b
on a.device_id = b.device_id
group by 1,2) g 
left join 
(select to_date(cast (date_time as timestamp)) as login_dt,role_id
from myth.server_role_login
where  day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
group by 1,2) h 
on g.role_id=h.role_id
where  datediff(login_dt,birth_dt)>=0 and datediff(login_dt,birth_dt)<=2
group by 1) i 
on e.datediffs=i.datediffs
where e.datediffs is not null 
order by 1 asc