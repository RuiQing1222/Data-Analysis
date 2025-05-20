select 
a.玩法类型,
a.副本ID,
case when a.玩法类型='战役' and a.副本ID=1   then '1-1'
     when a.玩法类型='战役' and a.副本ID=2   then '1-2'
     when a.玩法类型='战役' and a.副本ID=3   then '1-3'
     when a.玩法类型='战役' and a.副本ID=4   then '1-4'
     when a.玩法类型='战役' and a.副本ID=5   then '1-5'
     when a.玩法类型='战役' and a.副本ID=6   then '1-6'
     when a.玩法类型='战役' and a.副本ID=7   then '1-7'
     when a.玩法类型='战役' and a.副本ID=8   then '1-8'
     when a.玩法类型='战役' and a.副本ID=9   then '2-1'
     when a.玩法类型='战役' and a.副本ID=10  then '2-2'
     when a.玩法类型='战役' and a.副本ID=11  then '2-3'
     when a.玩法类型='战役' and a.副本ID=12  then '2-4'
     when a.玩法类型='战役' and a.副本ID=13  then '2-5'
     when a.玩法类型='战役' and a.副本ID=14  then '2-6'
     when a.玩法类型='战役' and a.副本ID=15  then '2-7'
     when a.玩法类型='战役' and a.副本ID=16  then '2-8'
     when a.玩法类型='战役' and a.副本ID=17  then '2-9'
     when a.玩法类型='战役' and a.副本ID=18  then '2-10'
     when a.玩法类型='战役' and a.副本ID=19  then '2-11'
     when a.玩法类型='战役' and a.副本ID=20  then '2-12'
     when a.玩法类型='战役' and a.副本ID=21  then '3-1'
     when a.玩法类型='战役' and a.副本ID=22  then '3-2'
     when a.玩法类型='战役' and a.副本ID=23  then '3-3'
     when a.玩法类型='战役' and a.副本ID=24  then '3-4'
     when a.玩法类型='战役' and a.副本ID=25  then '3-5'
     when a.玩法类型='战役' and a.副本ID=26  then '3-6'
     when a.玩法类型='战役' and a.副本ID=27  then '3-7'
     when a.玩法类型='战役' and a.副本ID=28  then '3-8'
     when a.玩法类型='战役' and a.副本ID=29  then '3-9'
     when a.玩法类型='战役' and a.副本ID=30  then '3-10'
     when a.玩法类型='战役' and a.副本ID=31  then '3-11'
     when a.玩法类型='战役' and a.副本ID=32  then '3-12'
     when a.玩法类型='战役' and a.副本ID=33  then '3-13'
     when a.玩法类型='战役' and a.副本ID=34  then '3-14'
     when a.玩法类型='战役' and a.副本ID=35  then '3-15'
     when a.玩法类型='战役' and a.副本ID=36  then '3-16'
     when a.玩法类型='战役' and a.副本ID=37  then '4-1'
     when a.玩法类型='战役' and a.副本ID=38  then '4-2'
     when a.玩法类型='战役' and a.副本ID=39  then '4-3'
     when a.玩法类型='战役' and a.副本ID=40  then '4-4'
     when a.玩法类型='战役' and a.副本ID=41  then '4-5'
     when a.玩法类型='战役' and a.副本ID=42  then '4-6'
     when a.玩法类型='战役' and a.副本ID=43  then '4-7'
     when a.玩法类型='战役' and a.副本ID=44  then '4-8'
     when a.玩法类型='战役' and a.副本ID=45  then '4-9'
     when a.玩法类型='战役' and a.副本ID=46  then '4-10'
     when a.玩法类型='战役' and a.副本ID=47  then '4-11'
     when a.玩法类型='战役' and a.副本ID=48  then '4-12'
     when a.玩法类型='战役' and a.副本ID=49  then '4-13'
     when a.玩法类型='战役' and a.副本ID=50  then '4-14'
     when a.玩法类型='战役' and a.副本ID=51  then '4-15'
     when a.玩法类型='战役' and a.副本ID=52  then '4-16'
     when a.玩法类型='战役' and a.副本ID=53  then '4-17'
     when a.玩法类型='战役' and a.副本ID=54  then '4-18'
     when a.玩法类型='战役' and a.副本ID=55  then '4-19'
     when a.玩法类型='战役' and a.副本ID=56  then '4-20'
     when a.玩法类型='远古战场' and a.副本ID=701001   then '冰霜巨人'
     when a.玩法类型='远古战场' and a.副本ID=701002   then '夏基'
     when a.玩法类型='远古战场' and a.副本ID=701004   then '赫朗格尼尔'
     when a.玩法类型='地精宝库' and a.副本ID=1        then '蛇发女妖'
     when a.玩法类型='地精宝库' and a.副本ID=2        then '水晶守护者'
     when a.玩法类型='地精宝库' and a.副本ID=3        then '米梅'
     when a.玩法类型='地精宝库' and a.副本ID=4        then '古尔薇格'
     when a.玩法类型='地精宝库' and a.副本ID=5        then '自然守护者'
     when a.玩法类型='地精宝库' and a.副本ID=6        then '黑龙'
     when a.玩法类型='公会领主' and a.副本ID=702017   then '奥丁'
     else  cast(a.副本ID as string) 
     end as '副本名称', 
进入角色数量,
第1次死亡角色数,
第2次死亡角色数,
第3次死亡角色数,
第4次死亡角色数,
第5次死亡角色数,
第6次死亡角色数,
第7次死亡角色数,
第8次死亡角色数,
第9次死亡角色数,
第10次死亡角色数
from 
(select case game_type 
           when 2  then '秘境'
           when 3  then '战役'
           when 4  then '竞技场'
           when 6  then '远古战场'
           when 7  then '地精宝库'
           when 8  then '诸神试炼'
           when 9  then '诸神试炼'
           when 10 then '诸神试炼'
           when 11 then '诸神试炼'
           when 12 then '诸神试炼'
           when 13 then '诸神试炼'
           when 14 then '宝石矿坑'
           when 16 then '公会领主'
           end as '玩法类型',
           dungeon_id as '副本ID',
count(distinct case when death_times=1 then role_id else null end ) as '第1次死亡角色数',
count(distinct case when death_times=2 then role_id else null end ) as '第2次死亡角色数',
count(distinct case when death_times=3 then role_id else null end ) as '第3次死亡角色数',
count(distinct case when death_times=4 then role_id else null end ) as '第4次死亡角色数',
count(distinct case when death_times=5 then role_id else null end ) as '第5次死亡角色数',
count(distinct case when death_times=6 then role_id else null end ) as '第6次死亡角色数',
count(distinct case when death_times=7 then role_id else null end ) as '第7次死亡角色数',
count(distinct case when death_times=8 then role_id else null end ) as '第8次死亡角色数',
count(distinct case when death_times=9 then role_id else null end ) as '第9次死亡角色数',
count(distinct case when death_times=10 then role_id else null end ) as '第10次死亡角色数'
from 
myth_server.server_death_recording 
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
group by 1,2
) a
left join 
(select  case game_type 
           when 2  then '秘境'
           when 3  then '战役'
           when 4  then '竞技场'
           when 6  then '远古战场'
           when 7  then '地精宝库'
           when 8  then '诸神试炼'
           when 9  then '诸神试炼'
           when 10 then '诸神试炼'
           when 11 then '诸神试炼'
           when 12 then '诸神试炼'
           when 13 then '诸神试炼'
           when 14 then '宝石矿坑'
           when 16 then '公会领主'
           end as '玩法类型',
           dungeon_id as '副本ID',
           count(distinct role_id) as '进入角色数量'
from myth_server.server_enter_dungeon
where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
group by 1,2
)  b 
on a.玩法类型=b.玩法类型 and a.副本ID=b.副本ID
order by 1,2 asc
