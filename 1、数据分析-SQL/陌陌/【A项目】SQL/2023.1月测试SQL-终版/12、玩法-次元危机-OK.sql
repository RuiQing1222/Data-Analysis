
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
次元危机

参与人数
select cycle_id,dungeon_id,count(distinct role_id) as '参与人数',count(1) as '参与次数'
from myth_server.server_enter_dungeon
where day_time>=${beginDate} and day_time<=${doneDate} 
and server_id in (${serverIds})
and game_type=19 --次元危机
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2
order by 1,2





轮次
select cycle_id,grade_num,room_type,sum(num)
from
(
select cycle_id,grade_num,role_id,
        case when room_type = 1 then '神力'
             when room_type = 2 then '神力升级'
             when room_type = 3 then '商店'
             when room_type = 4 then '宝物'
             when room_type = 5 then '宝箱'
             when room_type = 6 then '怪物'
             when room_type = 7 then 'BOSS'
             when room_type = 8 then '休息'
             when room_type = 9 then '英雄技能'
        end as room_type,max(turn_num) as num
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3,4
) as a
group by 1,2,3




-- 通关人数,通关次数,人均时长
-- 1-29关

select cycle_id,room_id,room_type,
count(distinct role_id) as users ,count(1) as nums,
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
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) a 
group by 1,2,3



-- 最后一层
select cycle_id,case when room_type = 1 then '神力'
             when room_type = 2 then '神力升级'
             when room_type = 3 then '商店'
             when room_type = 4 then '宝物'
             when room_type = 5 then '宝箱'
             when room_type = 6 then '怪物'
             when room_type = 7 then 'BOSS'
             when room_type = 8 then '休息'
             when room_type = 9 then '英雄技能'
        end as room_type,grade_num,battle_result,count(distinct role_id) as users,count(1) as nums,
avg(battle_time) as battle_time
from myth_server.server_roguelike 
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3,4


失败次数
select cycle_id,grade_num,
        case when room_type = 1 then '神力'
             when room_type = 2 then '神力升级'
             when room_type = 3 then '商店'
             when room_type = 4 then '宝物'
             when room_type = 5 then '宝箱'
             when room_type = 6 then '怪物'
             when room_type = 7 then 'BOSS'
             when room_type = 8 then '休息'
             when room_type = 9 then '英雄技能'
        end as room_type,count(1)
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and battle_result = 2
group by 1,2,3




最后一层时间

select a.cycle_id,avg(a.battle_time-b.battle_time)
from 
(select cycle_id,role_id,sum(battle_time) as battle_time
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and battle_result = 1
group by 1,2) a 
left join 
(select cycle_id,role_id,sum(battle_time) as  battle_time
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and battle_result = 2
group by 1,2) b
on a.cycle_id = b.cycle_id and a.role_id = b.role_id
group by 1



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
and version_name in ('1.4.0','1.4.1')
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
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and room_type in (1,7)
group by 1,2,3) a 
left join 
(select role_id,cycle_id,turn_num,split_part(split_part(god_skills_fresh,'[',2),',',1) as card 
from myth_server.server_roguelike_fresh
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and length(god_skills_fresh)>2
and room_type in (1,7)
union all 
select role_id,cycle_id,turn_num,split_part(split_part(god_skills_fresh,'[',2),',',2) as card
from myth_server.server_roguelike_fresh
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and length(god_skills_fresh)>2
and room_type in (1,7)
union all 
select role_id,cycle_id,turn_num,split_part(split_part(split_part(god_skills_fresh,'[',2),',',3),']',1) as card
from myth_server.server_roguelike_fresh 
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
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
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and room_type in (1,7)
and length(god_skills) in (5,6)
union all 
select role_id,cycle_id, split_part(god_skills,',',1) as god_skills 
from myth_server.server_roguelike_scene
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and room_type in (1,7)
and length(god_skills) >6
union all 
select role_id,cycle_id, split_part(god_skills,',',2) as god_skills 
from myth_server.server_roguelike_scene
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
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
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and room_type =3
group by 1,2,3) a 
left join 
(select role_id,cycle_id,turn_num,split_part(split_part(items_fresh,'[',2),',',1) as items 
from myth_server.server_roguelike_fresh
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and length(items_fresh)>2
and room_type =3
union all 
select role_id,cycle_id,turn_num,split_part(split_part(items_fresh,'[',2),',',2) as items
from myth_server.server_roguelike_fresh
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and length(items_fresh)>2
and room_type =3
union all 
select role_id,cycle_id,turn_num,split_part(split_part(split_part(items_fresh,'[',2),',',3),']',1) as items
from myth_server.server_roguelike_fresh 
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
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
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and room_type =3
and length(treasure_id) =3
union all 
select role_id,cycle_id, split_part(treasure_id,',',1) as treasure_id 
from myth_server.server_roguelike_scene
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and room_type =3
and length(treasure_id)= 7
union all 
select role_id,cycle_id, split_part(treasure_id,',',2) as treasure_id 
from myth_server.server_roguelike_scene
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
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
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and is_upgrade=0
group by 1,2


商店 神系升级选择
select cycle_id,god_skills,count(distinct role_id) 
from myth_server.server_roguelike_shop
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and is_upgrade=1
group by 1,2






-- 商店 神系选择
-- select cycle_id,god_skills,count(1) as nums 
-- from 
-- (select role_id,cycle_id,god_skills 
-- from myth_server.server_roguelike_shop
-- where day_time>=${beginDate} and day_time<=${doneDate}
-- and server_id in (${serverIds})
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- and length(god_skills)=6
-- and is_upgrade=0
-- union all 
-- select role_id,cycle_id,split_part(god_skills,',',1) as god_skills 
-- from myth_server.server_roguelike_shop
-- where day_time>=${beginDate} and day_time<=${doneDate}
-- and server_id in (${serverIds})
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- and length(god_skills) =13
-- and is_upgrade=0
-- union all 
-- select role_id,cycle_id, split_part(god_skills,',',2) as god_skills 
-- from myth_server.server_roguelike_shop
-- where day_time>=${beginDate} and day_time<=${doneDate}
-- and server_id in (${serverIds})
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- and length(god_skills) =13
-- and is_upgrade=0
-- union all 
-- select role_id,cycle_id, split_part(god_skills,',',1) as god_skills 
-- from myth_server.server_roguelike_shop
-- where day_time>=${beginDate} and day_time<=${doneDate}
-- and server_id in (${serverIds})
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- and length(god_skills) =20
-- and is_upgrade=0
-- union all 
-- select role_id,cycle_id, split_part(god_skills,',',2) as god_skills 
-- from myth_server.server_roguelike_shop
-- where day_time>=${beginDate} and day_time<=${doneDate}
-- and server_id in (${serverIds})
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- and length(god_skills) =20
-- and is_upgrade=0
-- union all 
-- select role_id,cycle_id, split_part(god_skills,',',3) as god_skills 
-- from myth_server.server_roguelike_shop
-- where day_time>=${beginDate} and day_time<=${doneDate}
-- and server_id in (${serverIds})
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- and length(god_skills) =20
-- and is_upgrade=0
-- union all 
-- select role_id,cycle_id, split_part(god_skills,',',1) as god_skills 
-- from myth_server.server_roguelike_shop
-- where day_time>=${beginDate} and day_time<=${doneDate}
-- and server_id in (${serverIds})
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- and length(god_skills) =27
-- and is_upgrade=0
-- union all 
-- select role_id,cycle_id, split_part(god_skills,',',2) as god_skills 
-- from myth_server.server_roguelike_shop
-- where day_time>=${beginDate} and day_time<=${doneDate}
-- and server_id in (${serverIds})
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- and length(god_skills) =27
-- and is_upgrade=0
-- union all 
-- select role_id,cycle_id, split_part(god_skills,',',3) as god_skills 
-- from myth_server.server_roguelike_shop
-- where day_time>=${beginDate} and day_time<=${doneDate}
-- and server_id in (${serverIds})
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- and length(god_skills) =27
-- and is_upgrade=0
-- union all 
-- select role_id,cycle_id, split_part(god_skills,',',4) as god_skills 
-- from myth_server.server_roguelike_shop
-- where day_time>=${beginDate} and day_time<=${doneDate}
-- and server_id in (${serverIds})
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- and length(god_skills) =27
-- and is_upgrade=0
-- ) a 
-- group by 1,2


-- 商店 神系升级
-- select cycle_id,god_skills,count(1) as nums 
-- from 
-- (select role_id,cycle_id,god_skills 
-- from myth_server.server_roguelike_shop
-- where day_time>=${beginDate} and day_time<=${doneDate}
-- and server_id in (${serverIds})
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- and length(god_skills)=6
-- and is_upgrade=1
-- union all 
-- select role_id,cycle_id,split_part(god_skills,',',1) as god_skills 
-- from myth_server.server_roguelike_shop
-- where day_time>=${beginDate} and day_time<=${doneDate}
-- and server_id in (${serverIds})
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- and length(god_skills) =13
-- and is_upgrade=1
-- union all 
-- select role_id,cycle_id, split_part(god_skills,',',2) as god_skills 
-- from myth_server.server_roguelike_shop
-- where day_time>=${beginDate} and day_time<=${doneDate}
-- and server_id in (${serverIds})
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- and length(god_skills) =13
-- and is_upgrade=1
-- union all 
-- select role_id,cycle_id, split_part(god_skills,',',1) as god_skills 
-- from myth_server.server_roguelike_shop
-- where day_time>=${beginDate} and day_time<=${doneDate}
-- and server_id in (${serverIds})
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- and length(god_skills) =20
-- and is_upgrade=1
-- union all 
-- select role_id,cycle_id, split_part(god_skills,',',2) as god_skills 
-- from myth_server.server_roguelike_shop
-- where day_time>=${beginDate} and day_time<=${doneDate}
-- and server_id in (${serverIds})
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- and length(god_skills) =20
-- and is_upgrade=1
-- union all 
-- select role_id,cycle_id, split_part(god_skills,',',3) as god_skills 
-- from myth_server.server_roguelike_shop
-- where day_time>=${beginDate} and day_time<=${doneDate}
-- and server_id in (${serverIds})
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- and length(god_skills) =20
-- and is_upgrade=1
-- union all 
-- select role_id,cycle_id, split_part(god_skills,',',1) as god_skills 
-- from myth_server.server_roguelike_shop
-- where day_time>=${beginDate} and day_time<=${doneDate}
-- and server_id in (${serverIds})
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- and length(god_skills) =27
-- and is_upgrade=1
-- union all 
-- select role_id,cycle_id, split_part(god_skills,',',2) as god_skills 
-- from myth_server.server_roguelike_shop
-- where day_time>=${beginDate} and day_time<=${doneDate}
-- and server_id in (${serverIds})
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- and length(god_skills) =27
-- and is_upgrade=1
-- union all 
-- select role_id,cycle_id, split_part(god_skills,',',3) as god_skills 
-- from myth_server.server_roguelike_shop
-- where day_time>=${beginDate} and day_time<=${doneDate}
-- and server_id in (${serverIds})
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- and length(god_skills) =27
-- and is_upgrade=1
-- union all 
-- select role_id,cycle_id, split_part(god_skills,',',4) as god_skills 
-- from myth_server.server_roguelike_shop
-- where day_time>=${beginDate} and day_time<=${doneDate}
-- and server_id in (${serverIds})
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- and length(god_skills) =27
-- and is_upgrade=1
-- ) a 
-- group by 1,2



HP量(总量/7500)就是次数
select cycle_id,sum(hp) as hp 
from  myth_server.server_roguelike_scene
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
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
-- and version_name = '1.3.5'
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
and version_name in ('1.4.0','1.4.1')
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
and version_name in ('1.4.0','1.4.1')
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
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and split_part(god_skills_list,',',1) <>'0'
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',2) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and split_part(god_skills_list,',',2) <>'0'
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',3) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',4) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',5) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',6) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',7) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',8) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',9) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',10) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',11) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',12) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',13) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',14) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',15) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',16) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',17) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',18) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',19) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',20) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',21) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',22) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',23) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
union all 
select role_id,role_type,cycle_id,
case when grade_num=30 and battle_result=1 then 30 else grade_num-1
end as grade_num,turn_num,split_part(god_skills_list,',',24) as god_skills
from myth_server.server_roguelike
where day_time>=${beginDate} and day_time<=${doneDate}
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
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
and version_name in ('1.4.0','1.4.1')
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
and version_name in ('1.4.0','1.4.1')
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
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2) c 
on a.role_id=c.role_id  and a.cycle_id=c.cycle_id
) a 
group by 1,2,3,4,5,6,7) a 
where cycle_id is not null 
group by 1,2,3






分服算
服务器 22001  
1    1672825810121  1672999137417 
2    1672999208114  1673258105878 
3    1673258566297  1673517340476 
4    1673517767790  1673776790131 
5    1673776820195  1674029397521 
6    1674038366802  1674294788407 
7    1674295319056  1674554382098 
8    1674554400637  1674813530341 
9    1674813742087  1675070854114 
服务器 22002
1    1672914911372  1673085593494 
2    1673086099807  1673344698226 
3    1673344856923  1673603926718 
4    1673604000014  1673862099948 
5    1673864210003  1674122352507 
6    1674122541739  1674376205293 
7    1674382300542  1674622418122 
8    1674641690005  1674896244138 
9    1674900469740  1675153385948 
服务器 22003
1    1672994559415  1673171967996 
2    1673172064096  1673431168493 
3    1673431205219  1673689250968 
4    1673691329772  1673940615369 
5    1673950913248  1674207883693 
6    1674209160163  1674467981535 
7    1674468004663  1674727175085 
8    1674729052374  1674985751388 
9    1674986649662  1675244945220 
服务器 22004
1    1673086472384  1673258394314 
2    1673258406678  1673517597917 
3    1673517610615  1673776799655 
4    1673777149535  1674035139772 
5    1674036035831  1674295179166 
6    1674295243612  1674553638261 
7    1674554708330  1674811925986 
8    1674813869550  1675071388711 
9    1675072985714  1675331994155 


登录
select case when b.role_id is null then 0 else 1 end as tag,count(distinct a.role_id)
from 
(select role_id
from myth_server.server_enter_dungeon
where log_time>=${beginDate} and log_time<=${doneDate}
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and game_type = 19
and cycle_id = 1
group by 1) a 
left join 
(
select role_id
from myth.server_role_login 
where log_time>=${begin2Date} and log_time<=${end2Date} 
and server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1) b 
on a.role_id=b.role_id
group by 1


复玩
select server_id,case when b.role_id is null then 0 else 1 end as tag,count(distinct a.role_id)
from 
(select role_id,server_id
from myth_server.server_enter_dungeon
where server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and game_type = 19
and cycle_id = ${ID1}
group by 1,2) a 
left join 
(
select role_id
from myth_server.server_enter_dungeon
where server_id in (${serverIds})
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
and game_type = 19
and cycle_id = ${ID2}
group by 1) b 
on a.role_id=b.role_id
group by 1,2
order by 2 desc,1