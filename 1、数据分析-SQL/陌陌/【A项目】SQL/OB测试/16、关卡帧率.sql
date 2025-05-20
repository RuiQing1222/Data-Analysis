---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

关卡帧率

select 玩法类型,dungeon_id as '关卡ID',
appx_median(avg_frame) as '平均帧率中位数',
appx_median(min_frame) as '最小帧率中位数',
appx_median(max_frame) as '最大帧率中位数'
from
(select 
case game_type 
           when 2 then '秘境'
           when 3 then '战役' 
           when 4 then '竞技场'
           when 6 then '远古战场'
           when 7 then '地精宝库'
           when 8 then '诸神试炼'
           when 9 then '诸神试炼'
           when 10 then '诸神试炼'
           when 11 then '诸神试炼'
           when 12 then '诸神试炼'
           when 13 then '诸神试炼'
           when 14 then '宝石矿坑'
           when 16 then '公会领主'
           when 17 then '无尽深渊'
           when 18 then '公会远征'
           when 19 then '次元危机'
           else 'others'
           end as '玩法类型'
,dungeon_id,
avg_frame,min_frame,max_frame
from myth_server.server_dungeon_frame 
where  day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id in (1000,2000)
)  a 
group by 1,2         
order by 1,2 asc 


关卡技能




select role_id,role_level,role_type,dungeon_id,battle_time,avg_frame,min_frame,max_frame,skill_list,
    god_card_id,card_list,device_brand,device_code,device_model
    from 
(select role_id,role_level,
  case role_type 
    when   '1' then '3雷神'
    when   '2' then '1瓦尔基里'
    when   '3' then '2齐格飞'
    when   '4' then '4乌勒尔'
    when   '5' then '5芙蕾雅'
    else '未知'
    end as role_type,dungeon_id,battle_time,avg_frame,min_frame,max_frame,skill_list,
    god_card_id,card_list,device_id
from myth_server.server_dungeon_frame 
where  day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id in (1000,2000)
and game_type = 3
)  a 
left join 
(select * from 
(select device_id,device_brand,device_code,device_model,row_number()over(partition by device_id order by log_time desc) as row_num
from myth.device_launch 
where  day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id in (1000,2000)
) b1 
where row_num=1
) b 
on a.device_id= b.device_id
 