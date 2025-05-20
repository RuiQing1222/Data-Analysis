次元危机
game_type=19
15.16,17    一个周期 17日8点 1663372800000
17,18,19,20 一个周期 20日8点 1663632000000
20,21,22,23 一个周期 23日8点 1663891200000
23,24,25,26 一个周期 26日8点 1664150400000

周期内各房间数据

参与人数


select   dungeon_id,count(distinct role_id) as user, count(1) as nums 
from myth_server.server_enter_dungeon
where day_time>=${beginDate} and day_time<=${doneDate} 
--and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and game_type=19 --次元危机
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1

select a.role_id,case when b.role_id is null then 0 else 1 end as tag
from 
(select   role_id
from myth_server.server_enter_dungeon
where day_time>=${begin1Date} and day_time<=${end1Date} 
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1) a 
left join 
(
select role_id
from myth.server_role_login 
where day_time>=${begin2Date} and day_time<=${end2Date} 
--and log_time<1663372800000
and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and game_type=19 --次元危机
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1) b 
on a.role_id=b.role_id
group by 1,2




select room_id,room_type,
count(distinct role_id) as users ,count(1) as nums,  
sum (get_currency_num) as gets, sum (consume_currency_num) as consumes,
avg(battle_time) as battle_time
from 
(select role_id,room_type,start_time,room_id,get_currency_num,consume_currency_num,battle_time
from myth_server.server_roguelike_scene
where day_time>=${beginDate} and day_time<=${doneDate}
--and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
) a 
group by 1,2


select room_type,grade_num,battle_result,count(distinct role_id) as users,count(1) as nums,
avg(battle_time) as battle_time
from myth_server.server_roguelike 
where day_time>=${beginDate} and day_time<=${doneDate}
--and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2,3


25层时间
select * from 
(select   a.role_id,a.battle_time-b.battle_time
from 
(select role_id,turn_num,battle_time
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
--and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
and grade_num= 25
and battle_result = 1
group by 1,2,3 ) a 
left join 
(select role_id,turn_num,sum(battle_time) as battle_time
from myth_server.server_roguelike_scene
where day_time>=${beginDate} and day_time<=${doneDate}
--and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1,2 ) b 
on a.role_id=b.role_id and a.turn_num=b.turn_num 
) a 


 
最高通关分布

select grade_num,role_type,count(distinct role_id) as users,
round(avg(count_turn),1) as turns,
round(avg(loses),1) as loses,
sum(神力)  as '神力',
sum(神力升级)  as '神力升级',
sum(商店)  as '商店',
sum(case when grade_num=25 then 宝物+1 else 宝物 end)  as '宝物',
sum(宝箱)  as '宝箱',
sum(怪物)  as '怪物',
sum(BOSS)  as 'BOSS',
round(avg(battle_time),0) as battle_time
from 
(select role_id,role_type,loses,grade_num,
battle_time,
count_turn,
count(case when room_type=1 then 1 else null end ) '神力',
count(case when room_type=2 then 1 else null end ) '神力升级',
count(case when room_type=3 then 1 else null end ) '商店',
count(case when room_type=4 then 1 else null end ) '宝物',
count(case when room_type=5 then 1 else null end ) '宝箱',
count(case when room_type=6 then 1 else null end ) '怪物',
count(case when room_type=7 then 1 else null end ) 'BOSS'
from 
(select a.role_id,a.role_type,grade_num,room_type,battle_time,a.turn_num,count_turn,loses
from 
(select role_id,role_type,grade_num,battle_time,turn_num from 
(select role_id,role_type,grade_num,battle_time,turn_num,row_num,row_number()over(partition by role_id order by battle_time asc ) as row_num2
	from 
(select role_id,
case role_type 
    when   '1' then '3雷'
    when   '2' then '1瓦'
    when   '3' then '2齐'
    when   '4' then '4乌'
    end as role_type,turn_num,
case when grade_num=25 and battle_result=1 then 25 else grade_num-1
end as grade_num,battle_time,rank()over(partition by role_id order by grade_num desc) as row_num
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')) t1
where row_num =1 
) t2
where row_num2 = 1
) a 
left join 
(select role_id,
case role_type 
    when   '1' then '3雷'
    when   '2' then '1瓦'
    when   '3' then '2齐'
    when   '4' then '4乌'
    end as role_type,room_type,turn_num
from myth_server.server_roguelike_scene
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
)  b 
on a.role_id=b.role_id and a.turn_num=b.turn_num 
left join 
(select role_id,
count(case when battle_result<>1  then 1 else null end ) as loses,
count(turn_num) as count_turn
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1) c 
on a.role_id=c.role_id 
) a 
group by 1,2,3,4,5,6) a 
group by 1,2


通过关卡的后续留存
select role_id,max(room_id) as room_id
from
(
(select role_id,max(room_id) as room_id
from myth_server.server_roguelike_scene
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
group by 1)
union all
(select role_id,max(grade_num) as room_id
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
and battle_result=1
group by 1)
) a 
group by 1



总体出现和选择
出现：

select card,count(1) as nums 
from 
(select role_id,turn_num 
from myth_server.server_roguelike_scene
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
and room_type in (1,7)
group by 1,2) a 
left join 
(select role_id,turn_num,split_part(split_part(god_skills_fresh,'[',2),',',1) as card 
from myth_server.server_roguelike_fresh
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
and length(god_skills_fresh)>2
and room_type in (1,7)
union all 
select role_id,turn_num,split_part(split_part(god_skills_fresh,'[',2),',',2) as card
from myth_server.server_roguelike_fresh
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
and length(god_skills_fresh)>2
and room_type in (1,7)
union all 
select role_id,turn_num,split_part(split_part(split_part(god_skills_fresh,'[',2),',',3),']',1) as card
from myth_server.server_roguelike_fresh 
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
and length(god_skills_fresh)>2
and room_type in (1,7)
) b 
on a.role_id=b.role_id and a.turn_num=b.turn_num
group by 1


选择
select god_skills,count(1) as nums 
from 
(select role_id, god_skills 
from myth_server.server_roguelike_scene
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
and room_type in (1,7)
and length(god_skills) in (5,6)
union all 
select role_id, split_part(god_skills,',',1) as god_skills 
from myth_server.server_roguelike_scene
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
and room_type in (1,7)
and length(god_skills) >6
union all 
select role_id, split_part(god_skills,',',2) as god_skills 
from myth_server.server_roguelike_scene
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
and room_type in (1,7)
and length(god_skills) >6
) a 
group by 1
 

道具
出现
select items,count(1) as nums 
from 
(select role_id,turn_num 
from myth_server.server_roguelike_scene
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
and room_type =3
group by 1,2) a 
left join 
(select role_id,turn_num,split_part(split_part(items_fresh,'[',2),',',1) as items 
from myth_server.server_roguelike_fresh
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
and length(items_fresh)>2
and room_type =3
union all 
select role_id,turn_num,split_part(split_part(items_fresh,'[',2),',',2) as items
from myth_server.server_roguelike_fresh
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
and length(items_fresh)>2
and room_type =3
union all 
select role_id,turn_num,split_part(split_part(split_part(items_fresh,'[',2),',',3),']',1) as items
from myth_server.server_roguelike_fresh 
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
and length(items_fresh)>2
and room_type =3
) b 
on a.role_id=b.role_id and a.turn_num=b.turn_num
group by 1


选择
select god_skills,count(1) as nums 
from 
(select role_id, god_skills 
from myth_server.server_roguelike_scene
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
and room_type =3
and length(god_skills)=6
union all 
select role_id, split_part(god_skills,',',1) as god_skills 
from myth_server.server_roguelike_scene
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
and room_type =3
and length(god_skills) =13
union all 
select role_id, split_part(god_skills,',',2) as god_skills 
from myth_server.server_roguelike_scene
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
and room_type =3
and length(god_skills) =13
union all 
select role_id, split_part(god_skills,',',1) as god_skills 
from myth_server.server_roguelike_scene
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
and room_type =3
and length(god_skills) =20
union all 
select role_id, split_part(god_skills,',',2) as god_skills 
from myth_server.server_roguelike_scene
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
and room_type =3
and length(god_skills) =20
union all 
select role_id, split_part(god_skills,',',3) as god_skills 
from myth_server.server_roguelike_scene
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
and room_type =3
and length(god_skills) =20
union all 
select role_id, split_part(god_skills,',',1) as god_skills 
from myth_server.server_roguelike_scene
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
and room_type =3
and length(god_skills) =27
union all 
select role_id, split_part(god_skills,',',2) as god_skills 
from myth_server.server_roguelike_scene
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
and room_type =3
and length(god_skills) =27
union all 
select role_id, split_part(god_skills,',',3) as god_skills 
from myth_server.server_roguelike_scene
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
and room_type =3
and length(god_skills) =27
union all 
select role_id, split_part(god_skills,',',4) as god_skills 
from myth_server.server_roguelike_scene
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
and room_type =3
and length(god_skills) =27
) a 
group by 1


 
select treasure_id,count(1) as nums 
from 
(select role_id, treasure_id 
from myth_server.server_roguelike_scene
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
and room_type =3
and length(treasure_id) =3
union all 
select role_id, split_part(treasure_id,',',1) as treasure_id 
from myth_server.server_roguelike_scene
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
and room_type =3
and length(treasure_id)= 7
union all 
select role_id, split_part(treasure_id,',',2) as treasure_id 
from myth_server.server_roguelike_scene
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
and room_type =3
and length(treasure_id)= 7
) a 
group by 1



HP量
select count(hp) as hp_times,sum(hp) as hp 
from  myth_server.server_roguelike_scene
where day_time>=${beginDate} and day_time<=${doneDate}
--and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  
and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
and hp>0
and room_type =3


最高通关英雄结合神力的选择分布

select a.grade_num,
case a.role_type 
    when   '1' then '3雷'
    when   '2' then '1瓦'
    when   '3' then '2齐'
    when   '4' then '4乌'
    end as role_type,god_skills,count(1) as nums 
from 
(select role_id,role_type,grade_num,battle_time,turn_num from 
(select role_id,role_type,grade_num,battle_time,turn_num,row_num,row_number()over(partition by role_id order by battle_time asc ) as row_num2
	from 
(select role_id,role_type,turn_num,
case when grade_num=25 and battle_result=1 then 25 else grade_num-1
end as grade_num,battle_time,rank()over(partition by role_id order by grade_num desc) as row_num
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')) t1
where row_num =1 
) t2
where row_num2 = 1
) a   -- 最高通关
left join 
(select role_id,role_type,grade_num,turn_num,god_skills
	from
(
select role_id,role_type,grade_num,turn_num,split_part(god_skills_list,',',1) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
and split_part(god_skills_list,',',1) <>'0'
union all 
select role_id,role_type,grade_num,turn_num,split_part(god_skills_list,',',2) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
and split_part(god_skills_list,',',2) <>'0'
union all 
select role_id,role_type,grade_num,turn_num,split_part(god_skills_list,',',3) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
union all 
select role_id,role_type,grade_num,turn_num,split_part(god_skills_list,',',4) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
union all 
select role_id,role_type,grade_num,turn_num,split_part(god_skills_list,',',5) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
union all 
select role_id,role_type,grade_num,turn_num,split_part(god_skills_list,',',6) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
union all 
select role_id,role_type,grade_num,turn_num,split_part(god_skills_list,',',7) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
union all 
select role_id,role_type,grade_num,turn_num,split_part(god_skills_list,',',8) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
union all 
select role_id,role_type,grade_num,turn_num,split_part(god_skills_list,',',9) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
union all 
select role_id,role_type,grade_num,turn_num,split_part(god_skills_list,',',10) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
union all 
select role_id,role_type,grade_num,turn_num,split_part(god_skills_list,',',11) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
union all 
select role_id,role_type,grade_num,turn_num,split_part(god_skills_list,',',12) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
union all 
select role_id,role_type,grade_num,turn_num,split_part(god_skills_list,',',13) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
union all 
select role_id,role_type,grade_num,turn_num,split_part(god_skills_list,',',14) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
union all 
select role_id,role_type,grade_num,turn_num,split_part(god_skills_list,',',15) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and log_time<1663372800000
--and log_time>=1663372800000  and log_time<1663632000000
--and log_time>=1663632000000  and log_time<1663891200000
--and log_time>=1663891200000  and log_time<1664150400000
and server_id in (20001,20002)
and version_name ='1.3.5'
and country not in ('CN','HK')
) b1
where god_skills<>'0' and god_skills is not null
) b 
on a.role_id=b.role_id and a.role_type=b.role_type and a.grade_num=b.grade_num  and a.turn_num=b.turn_num
group by 1,2,3