
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
次元危机/死亡迷宫
参与数据
select a.cycle_id,a.dungeon_id,room_type,
       count(distinct a.role_id) as '参与人数',
       count(a.start_time) as '参与次数',
       count(distinct case when battle_result = 1 then b.role_id else null end) as '通关人数',
       count(case when battle_result = 1 then b.start_time else null end) as '通关次数',
       count(case when battle_result = 2 then b.start_time else null end) as '失败次数',
       round(count(case when battle_result = 2 then b.start_time else null end) / count(a.start_time),2) as '失败率',
       count(case when battle_result is null then a.start_time else null end) as '无日志次数'
from


-- 进入关卡
(select cycle_id,dungeon_id,role_id,start_time
from myth_server.server_enter_dungeon
where day_time>=${beginDate} and day_time<=${doneDate} 
and server_id in (${serverIds})
and game_type=19 --次元危机
and version_name = '1.5.0'
and country not in ('CN','HK')
group by 1,2,3,4
) as a

left join
(select cycle_id,role_id,room_id,battle_time,battle_result,start_time,room_type
from
(
-- 通关人数,通关次数,人均时长
-- 1-29关
select cycle_id,role_id,room_id,battle_time,1 as battle_result,start_time, 
        case when room_type = 1 then '神力'
             when room_type = 2 then '神力升级'
             when room_type = 3 then '商店'
             when room_type = 4 then '宝物'
             when room_type = 5 then '宝箱'
             when room_type = 6 then '怪物'
             when room_type = 7 then 'BOSS'
             when room_type = 8 then '休息'
             when room_type = 9 then '英雄技能'
        end as room_type
from myth_server.server_roguelike_scene
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
group by 1,2,3,4,5,6,7

union all

select cycle_id,role_id,grade_num as room_id,battle_time,battle_result,start_time,
       case when room_type = 1 then '神力'
             when room_type = 2 then '神力升级'
             when room_type = 3 then '商店'
             when room_type = 4 then '宝物'
             when room_type = 5 then '宝箱'
             when room_type = 6 then '怪物'
             when room_type = 7 then 'BOSS'
             when room_type = 8 then '休息'
             when room_type = 9 then '英雄技能'
        end as room_type
from myth_server.server_roguelike 
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
group by 1,2,3,4,5,6,7
) as b1
) as b 

on a.cycle_id = b.cycle_id and a.dungeon_id = b.room_id and a.role_id = b.role_id and a.start_time = b.start_time
group by 1,2,3
order by 1,2,3



-- 人均时长   1-29关
select cycle_id,room_id,room_type,
avg(battle_time) as battle_time
from 
(select cycle_id,role_id,
        case when room_type = 1 then '神力'
             when room_type = 2 then '神力升级'
             when room_type = 3 then '商店'
             when room_type = 4 then '宝物'
             when room_type = 5 then '宝箱'
             when room_type = 6 then '怪物'
             when room_type = 7 then 'BOSS'
             when room_type = 8 then '休息'
             when room_type = 9 then '英雄技能'
        end as room_type
        ,room_id,battle_time
from myth_server.server_roguelike_scene
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
) a 
group by 1,2,3
order by 1,2,3


-- 30关
select cycle_id,avg(battleTime)
from
(select cycle_id,role_id,(log_time - start_time)/1000 as battleTime
from myth_server.server_roguelike 
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
and grade_num = 30
and battle_result = 1
group by 1,2,3) as a
group by 1 
order by 1




通关用户的耗时
30层时间
select cycle_id,count(distinct a.role_id) as '通关人数',avg(battle_time) as '人均通关时长',max(battle_time) as '最慢通关时长', min(battle_time) as '最快通关时长' 
from 
(select cycle_id,role_id,battle_time
from 
(select role_id,cycle_id,turn_num,battle_time
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
and grade_num= 30
and battle_result = 1
group by 1,2,3,4 ) a1 
) a 
group by 1
order by 1



总体出现和选择
卡牌出现：

select a.cycle_id,card,count(1) as nums 
from 
(select role_id,cycle_id,turn_num 
from myth_server.server_roguelike_scene
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
and room_type in (1,7)
group by 1,2,3) a 
left join 
(select role_id,cycle_id,turn_num,split_part(split_part(god_skills_fresh,'[',2),',',1) as card 
from myth_server.server_roguelike_fresh
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
and length(god_skills_fresh)>2
and room_type in (1,7)
union all 
select role_id,cycle_id,turn_num,split_part(split_part(god_skills_fresh,'[',2),',',2) as card
from myth_server.server_roguelike_fresh
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
and length(god_skills_fresh)>2
and room_type in (1,7)
union all 
select role_id,cycle_id,turn_num,split_part(split_part(split_part(god_skills_fresh,'[',2),',',3),']',1) as card
from myth_server.server_roguelike_fresh 
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
and length(god_skills_fresh)>2
and room_type in (1,7)
) b 
on a.role_id=b.role_id and a.turn_num=b.turn_num and a.cycle_id=b.cycle_id
group by 1,2


卡牌选择
select god_skills,cycle_id,count(1) as nums 
from 
(select role_id,cycle_id, god_skills 
from myth_server.server_roguelike_scene
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
and room_type in (1,7)
and length(god_skills) in (5,6)
union all 
select role_id,cycle_id, split_part(god_skills,',',1) as god_skills 
from myth_server.server_roguelike_scene
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
and room_type in (1,7)
and length(god_skills) >6
union all 
select role_id,cycle_id, split_part(god_skills,',',2) as god_skills 
from myth_server.server_roguelike_scene
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
and room_type in (1,7)
and length(god_skills) >6
) a 
group by 1,2



商店 道具出现
select a.cycle_id,items,count(1) as nums 
from 
(select role_id,cycle_id,turn_num 
from myth_server.server_roguelike_scene
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
and room_type =3
group by 1,2,3) a 
left join 
(select role_id,cycle_id,turn_num,split_part(split_part(items_fresh,'[',2),',',1) as items 
from myth_server.server_roguelike_fresh
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
and length(items_fresh)>2
and room_type =3
union all 
select role_id,cycle_id,turn_num,split_part(split_part(items_fresh,'[',2),',',2) as items
from myth_server.server_roguelike_fresh
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
and length(items_fresh)>2
and room_type =3
union all 
select role_id,cycle_id,turn_num,split_part(split_part(split_part(items_fresh,'[',2),',',3),']',1) as items
from myth_server.server_roguelike_fresh 
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
and length(items_fresh)>2
and room_type =3
) b 
on a.role_id=b.role_id and a.turn_num=b.turn_num and a.cycle_id=b.cycle_id
group by 1,2





商店购买 宝物 
select cycle_id,treasure_id,count(1) as nums 
from 
(select role_id,cycle_id, treasure_id 
from myth_server.server_roguelike_scene
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
and room_type =3
and length(treasure_id) =3
union all 
select role_id,cycle_id, split_part(treasure_id,',',1) as treasure_id 
from myth_server.server_roguelike_scene
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
and room_type =3
and length(treasure_id)= 7
union all 
select role_id,cycle_id, split_part(treasure_id,',',2) as treasure_id 
from myth_server.server_roguelike_scene
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
and room_type =3
and length(treasure_id)= 7
) a 
group by 1,2



商店 神系选择
select cycle_id,god_skills,count(distinct role_id) 
from myth_server.server_roguelike_shop
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
and is_upgrade=0
group by 1,2


商店 神系升级选择
select cycle_id,god_skills,count(distinct role_id) 
from myth_server.server_roguelike_shop
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
and is_upgrade=1
group by 1,2





HP量(总量/7500)就是次数
select cycle_id,sum(hp) as hp 
from  myth_server.server_roguelike_scene
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
and hp>0
and room_type =3
group by 1













最高通关英雄结合神力的选择分布
-- 提前算一下最大长度
-- select max(char_length(god_skills_list)-char_length(replace(god_skills_list,',',''))+1) as tag
-- from myth_server.server_roguelike
-- where day_time>=${beginDate} and day_time<=${doneDate}
-- and server_id in (${serverIds})
-- and version_name = '1.5.0'
-- and country not in ('CN','HK')

最高通关角色数
select a.cycle_id,a.grade_num,
case a.role_type 
    when   '1' then '3雷'
    when   '2' then '1瓦'
    when   '3' then '2齐'
    when   '4' then '4乌'
    when   '5' then '5芙'
    end as role_type,count(distinct role_id) as role_id_nums 
from 
(select role_id,role_type,cycle_id,grade_num,battle_time,turn_num from 
(select role_id,role_type,cycle_id,grade_num,battle_time,turn_num,row_num,row_number()over(partition by role_id order by battle_time asc ) as row_num2
      from 
(select role_id,cycle_id,role_type,turn_num,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,battle_time,rank()over(partition by role_id order by grade_num desc) as row_num
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')) t1
where row_num =1 
) t2
where row_num2 = 1
) a   -- 最高通关
group by 1,2,3



select a.cycle_id,a.grade_num,
case a.role_type 
    when   '1' then '3雷'
    when   '2' then '1瓦'
    when   '3' then '2齐'
    when   '4' then '4乌'
    when   '5' then '5芙'
    end as role_type,god_skills,count(1) as nums 
from 
(select role_id,role_type,cycle_id,grade_num,battle_time,turn_num from 
(select role_id,role_type,cycle_id,grade_num,battle_time,turn_num,row_num,row_number()over(partition by role_id order by battle_time asc ) as row_num2
      from 
(select role_id,cycle_id,role_type,turn_num,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,battle_time,rank()over(partition by role_id order by grade_num desc) as row_num
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')) t1
where row_num =1 
) t2
where row_num2 = 1
) a   -- 最高通关
left join 
(select role_id,role_type,cycle_id,grade_num,turn_num,god_skills
      from
(
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,
turn_num,split_part(god_skills_list,',',1) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
and split_part(god_skills_list,',',1) <>'0'
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',2) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
and split_part(god_skills_list,',',2) <>'0'
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',3) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',4) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',5) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',6) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',7) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',8) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',9) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',10) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',11) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',12) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',13) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',14) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',15) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',16) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',17) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',18) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',19) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',20) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',21) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',22) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',23) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',24) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
) b1
where god_skills<>'0' and god_skills is not null
) b 
on a.role_id=b.role_id and a.role_type=b.role_type and a.grade_num=b.grade_num  and a.turn_num=b.turn_num and a.cycle_id=b.cycle_id
group by 1,2,3,4





最高通关关卡角色使用情况
select cycle_id,grade_num,role_type,count(distinct role_id) as users,
round(avg(count_turn),1) as turns,
round(avg(loses),1) as loses,
sum(神力)  as '神力',
sum(神力升级)  as '神力升级',
sum(商店)  as '商店',
sum(case when grade_num=30 then 宝物+1 else 宝物 end)  as '宝物',
sum(宝箱)  as '宝箱',
sum(怪物)  as '怪物',
sum(BOSS)  as 'BOSS',
sum(休息)  as '休息',
sum(英雄技能)  as '英雄技能',
round(avg(battle_time),0) as battle_time
from 
(select role_id,cycle_id,role_type,loses,grade_num,
battle_time,
count_turn,
count(case when room_type=1 then 1 else null end ) '神力',
count(case when room_type=2 then 1 else null end ) '神力升级',
count(case when room_type=3 then 1 else null end ) '商店',
count(case when room_type=4 then 1 else null end ) '宝物',
count(case when room_type=5 then 1 else null end ) '宝箱',
count(case when room_type=6 then 1 else null end ) '怪物',
count(case when room_type=7 then 1 else null end ) 'BOSS',
count(case when room_type=8 then 1 else null end ) '休息',
count(case when room_type=9 then 1 else null end ) '英雄技能'
from 
(select a.role_id,a.role_type,a.cycle_id,grade_num,room_type,battle_time,a.turn_num,count_turn,loses
from 
(select role_id,role_type,cycle_id,grade_num,battle_time,turn_num from 
(select role_id,role_type,cycle_id,grade_num,battle_time,turn_num,row_num,row_number()over(partition by role_id order by battle_time asc ) as row_num2
from 
(select role_id,cycle_id,
case role_type 
    when   '1' then '3雷'
    when   '2' then '1瓦'
    when   '3' then '2齐'
    when   '4' then '4乌'
    when   '5' then '5芙'
    end as role_type,turn_num,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,battle_time,rank()over(partition by role_id order by grade_num desc) as row_num
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')) t1
where row_num =1 
) t2
where row_num2 = 1
) a 
left join 
(select role_id,cycle_id,
case role_type 
    when   '1' then '3雷'
    when   '2' then '1瓦'
    when   '3' then '2齐'
    when   '4' then '4乌'
    when   '5' then '5芙'
    end as role_type,room_type,turn_num
from myth_server.server_roguelike_scene
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
)  b 
on a.role_id=b.role_id and a.turn_num=b.turn_num and a.cycle_id=b.cycle_id
left join 
(select role_id,cycle_id,
count(case when battle_result<>1  then 1 else null end ) as loses,
count(turn_num) as count_turn
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
group by 1,2) c 
on a.role_id=c.role_id  and a.cycle_id=c.cycle_id
) a 
group by 1,2,3,4,5,6,7) a 
where cycle_id is not null 
group by 1,2,3




同周期按照拆分次数分布
select 
      case when num = 1 then "1次"
           when num = 2 then "2次"
           when num = 3 then "3次"
           when num = 4 then "4次"
           when num >= 5 and num < 10 then "5-10次"
           when num >= 10 then "6-10+次"
      end as num,count(distinct a.role_id),
      count(case when battle_result = 1 then a.role_id else null end) as '通关人数',
      count(case when battle_result = 2 then a.role_id else null end) as '未通关人数'
from
(select role_id,count(turn_num) as num -- 轮次
from myth_server.server_roguelike
where server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
and channel_id=1000  --Android
and cycle_id = ${cycleId}
group by 1
) as a 

left join
(select role_id,battle_result
from
(select role_id,battle_result,row_number() over(partition by role_id order by turn_num desc) as nums
from myth_server.server_roguelike
where server_id in (${serverIds})
and version_name = '1.5.0'
and country not in ('CN','HK')
and channel_id=1000  --Android
and cycle_id = ${cycleId}
) as b1
where nums = 1
) as b
on a.role_id = b.role_id
group by 1
order by 1


