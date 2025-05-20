-- 类似的
--领取奖励但没进1-6的人
select case when btn_type = 'pray' then '祈愿'
            when btn_type = 'character' then '角色头像'
            when btn_type = 'mail' then '邮件'
            when btn_type = 'settle' then '设置'
            when btn_type = 'task' then '任务'
            when btn_type = 'achievement' then '成就'
            when btn_type = 'questionnaire' then '问卷'
            when btn_type = 'roles' then '角色'
            when btn_type = 'divine' then '神力'
            when btn_type = 'bag' then '背包'
            when btn_type = 'world' then '世界'
            when btn_type = 'comedy' then '战役'
            when btn_type = 'hangup' then '挂机'
            when btn_type = 'path' then '神王之路'
            when btn_type = 'guild' then '公会'
            when btn_type = 'ranking' then '排行榜'
            when btn_type = 'shop' then '商店'
            when btn_type = 'fateHall' then '命运殿堂'
        end as '按钮类型',
       case when btn_style = 1 then '进入'
            when btn_style = 2 then '退出'
        end as '按钮属性',
        count(distinct role_id) as num

from myth_server.server_hud_click where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and role_id in -- 引导 领取奖励
(select distinct role_id from myth.server_newbie
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and step = '1011030') 
and role_id in  -- 新用户
             (select role_id
             from
             (select device_id from myth.device_activate where day_time between ${beginDate} and ${endDate}
             and channel_id=1000
             and version_name ='1.3.0'   
             and country not in ('CN','HK')
             group by 1
             ) as a
             left join
             (select device_id,role_id
             from myth.server_role_create
             where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
             group by 1,2) as b
             on a.device_id = b.device_id
             group by 1)
and role_id not in -- 没进1-6的
              (select distinct role_id
              from myth_server.server_enter_dungeon
              where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
              and game_type=3
              and dungeon_id = 6
              and channel_id=1000
              and version_name ='1.3.0'   
              and country not in ('CN','HK')
              ) 
group by 1,2