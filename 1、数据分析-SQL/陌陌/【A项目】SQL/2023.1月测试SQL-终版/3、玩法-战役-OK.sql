玩法系统数据分析   计算整体时，将付费免费注释掉，区分付费免费时，一天一天算

玩法——3->战役

整体、付费、免费
-- 人数维度进入关卡人数、通关率
select birth_dt,country,dungeon_id,是否付费,
count(distinct a.role_id),
count(distinct case when battle_result=1 then c.role_id else null end ) as '成功通关用户'
from

(select a.role_id,case when b.role_id is not null then '付费'
      else '免费'
      end as '是否付费',
      birth_dt,country
from 
(  --新增
select role_id,birth_dt,country
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt, 
     case when country in ('PH','MY') then 'PH+MY'
     when country in ('GB','IE','CA')  then 'GB+CA'
     else  'others'
     end as country
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
) as a
left join -- 付费免费拆分
(select role_id,to_date(cast(date_time as timestamp)) as pay_dt
from myth.order_pay
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and country not in ('CN','HK')
) b 
on birth_dt=pay_dt and a.role_id=b.role_id
) a 

left join
-- 关卡参与情况
(select a.dungeon_id,a.role_id,a.start_time,battle_result,battle_time,auto_battle,done_dt
from 
(select dungeon_id,role_id,start_time,to_date(cast(date_time as timestamp)) as done_dt-- start_time也可用统计参与次数
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 3 -- 3->战役
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3,4
) as a
left join     
(select dungeon_id,role_id,start_time,battle_result,battle_time,auto_battle
from myth_server.server_dungeon_end
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 3 -- 3->战役
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3,4,5,6
) b 
on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time=b.start_time 
) as c 
on a.role_id = c.role_id and birth_dt=done_dt
where c.role_id is not null 
group by 1,2,3,4 




-- 流失人数 流失率   
select birth_dt,country,是否付费,max_dungeon,datediff(login_dt,birth_dt) as diffs,count(distinct a.role_id)
from

(select a.role_id,是否付费,birth_dt,country,max_dungeon
from

(select a.role_id,case when b.role_id is not null then '付费'
      else '免费'
      end as '是否付费',
      birth_dt , country
from 
(  --新增
select role_id,birth_dt,country
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt, 
     case when country in ('PH','MY') then 'PH+MY'
     when country in ('GB','IE','CA')  then 'GB+CA'
     else  'others'
     end as country
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
) as a
left join -- 付费免费拆分
(select role_id,to_date(cast(date_time as timestamp)) as pay_dt
from myth.order_pay
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and country not in ('CN','HK')
) b 
on birth_dt=pay_dt and a.role_id=b.role_id
) a 

left join   
(select  to_date(cast(date_time as timestamp)) as enter_dt,role_id, max(dungeon_id)  as 'max_dungeon'
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 2 -- 3->战役
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2
)  c 
on a.role_id = c.role_id and birth_dt =enter_dt
) a 
left join 
(
select role_id,to_date(cast(date_time as timestamp)) as login_dt
from myth.server_role_login
where day_time>=${beginDate} and day_time<=${doneDate} 
and server_id in (${serverIds}) 
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by  1,2
) d 
on a.role_id = d.role_id 
where datediff(login_dt,birth_dt)<=1
group by 1,2,3,4,5



整体、付费 -- 复玩率
select birth_dt,country,dungeon_id,是否付费,
       count(distinct b.role_id) as '进入总人数',count(distinct case when 进入次数 > 1 then b.role_id else null end) as '复玩人数'
from

(select a.role_id,case when b.role_id is not null then '付费'
      else '免费'
      end as '是否付费',
      birth_dt,country
from 
(  --新增
select role_id,birth_dt,country
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt, 
     case when country in ('PH','MY') then 'PH+MY'
     when country in ('GB','IE','CA')  then 'GB+CA'
     else  'others'
     end as country
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
) as a
left join -- 付费免费拆分
(select role_id,to_date(cast(date_time as timestamp)) as pay_dt
from myth.order_pay
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and country not in ('CN','HK')
) b 
on birth_dt=pay_dt and a.role_id=b.role_id
) a 

left join
(select dungeon_id,role_id,to_date(cast(date_time as timestamp)) as done_dt,count(1) as '进入次数' 
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 3 -- 3->战役
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3
) as b
on a.role_id = b.role_id
where datediff(done_dt,birth_dt) =0
group by 1,2,3,4





次数维度
通关/未通关时长分布、自动/手动、无日志率、总次数 -- 中途退出率，D1次数维度数据
select country,是否付费,dungeon_id,battle_result,battle_time,
       count(distinct start_time) as '总次数',
       count(case when auto_battle = 1 and battle_result = 1 then b.role_id else null end) as '自动战斗通关次数',
       count(case when auto_battle = 1 and battle_result = 2 then b.role_id else null end) as '自动战斗未通关次数',
       count(case when auto_battle = 0 and battle_result = 1 then b.role_id else null end) as '手动战斗通关次数',
       count(case when auto_battle = 0 and battle_result = 2 then b.role_id else null end) as '手动战斗未通关次数',
       count(case when auto_battle is null then b.role_id else null end) as '无日志次数'
from

(select a.role_id,birth_dt,country,
case when b.role_id is not null then '付费'
      else '免费'
      end as '是否付费'
from 
(  --新增
select role_id,birth_dt,country
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt, 
     case when country in ('PH','MY') then 'PH+MY'
     when country in ('GB','IE','CA')  then 'GB+CA'
     end as country
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
) as a
left join -- 付费免费拆分
(select role_id,to_date(cast(date_time as timestamp)) as pay_dt
from myth.order_pay
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and country not in ('CN','HK')
group by 1,2) b 
on pay_dt=birth_dt and a.role_id=b.role_id 
group by 1,2,3,4
) a 


left join
-- 关卡参与情况
(select dungeon_id,role_id,start_time,battle_result,battle_time,auto_battle,done_dt
from
(select a.dungeon_id,a.role_id,a.start_time,battle_result,battle_time,auto_battle,done_dt
from 
(select dungeon_id,role_id,start_time,to_date(cast(date_time as timestamp)) as done_dt
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 3 
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3,4
) as a
left join     
(select dungeon_id,role_id,start_time,battle_result,
        case when battle_time is null then '无日志'
             when battle_time/60 > 3  then '1超时'
             when battle_time/60 > 2 and battle_time/60 <= 3  then '2困难'
             when battle_time/60 > 1 and battle_time/60 <= 2  then '3较难'
             when battle_time/60 > 0 and battle_time/60 <= 1  then '4一般'
             else '无日志'
        end as battle_time,auto_battle
from myth_server.server_dungeon_end
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type = 3
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3,4,5,6
) b 
on a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time=b.start_time
order by a.role_id,a.start_time asc 
) as e  
group by 1,2,3,4,5,6,7
) as b 
on a.role_id = b.role_id

where datediff(done_dt,birth_dt) = 0
group by 1,2,3,4,5





生命周期，D1-D7玩法细拆各个数据 
存在失败日志的人数  失败 √√√√√√√√
select a.role_id as role_id,birth_dt,是否付费,country,game_type,dungeon_id,datediff(done_dt,birth_dt)+1 as '天数',失败人数,无日志人数
from

(select a.role_id,birth_dt,country,
case when b.role_id is not null then '付费'
      else '免费'
      end as '是否付费'
from 
(  --新增
select role_id,birth_dt,country
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt, 
     case when country in ('PH','MY') then 'PH+MY'
     when country in ('GB','IE','CA')  then 'GB+CA'
     end as country
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
) as a
left join -- 付费免费拆分
(select role_id,to_date(cast(date_time as timestamp)) as pay_dt
from myth.order_pay
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and country not in ('CN','HK')
group by 1,2) b 
on pay_dt=birth_dt and a.role_id=b.role_id 
group by 1,2,3,4
) a 


left join --存在失败记录的
(
select role_id,done_dt,game_type,dungeon_id,
       count(distinct case when battle_result = 2 then role_id else null end) as '失败人数',
       count(distinct case when battle_result is NULL then role_id else null end) as '无日志人数'
from
(select role_id,done_dt,dungeon_id,battle_result,game_type
from
(select a.role_id as role_id,done_dt,a.dungeon_id as dungeon_id,battle_result,a.game_type as game_type
from
(select dungeon_id,role_id,to_date(cast(date_time as timestamp)) as done_dt,start_time,game_type
from myth_server.server_enter_dungeon
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type =3 -- 3战役
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3,4,5
) a 
left join 
(select dungeon_id,role_id,battle_result,log_time,start_time,game_type
from myth_server.server_dungeon_end
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and game_type =3 -- 3战役
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3,4,5,6
) b 
on a.game_type = b.game_type and a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time = b.start_time
) as c
group by 1,2,3,4,5
) as b
group by 1,2,3,4
) as b
on a.role_id = b.role_id

where datediff(b.done_dt,a.birth_dt) = 0
group by 1,2,3,4,5,6,7,8,9






复玩人数、复玩次数 √√√√√√√√√
select birth_dt,country,datediff(done_dt,birth_dt)+1 as '天数',是否付费,
       game_type,dungeon_id,count(distinct f.role_id) as '复玩人数',sum(进入次数) as '复玩次数'
from

(select a.role_id,birth_dt,country,
case when b.role_id is not null then '付费'
      else '免费'
      end as '是否付费'
from 
(  --新增
select role_id,birth_dt,country
from
(select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt, 
     case when country in ('PH','MY') then 'PH+MY'
     when country in ('GB','IE','CA')  then 'GB+CA'
     end as country
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
) as a
left join -- 付费免费拆分
(select role_id,to_date(cast(date_time as timestamp)) as pay_dt
from myth.order_pay
where day_time between ${beginDate} and ${endDate} 
and server_id in (${serverIds})
and channel_id=1000  --Android
and country not in ('CN','HK')
group by 1,2) b 
on pay_dt=birth_dt and a.role_id=b.role_id 
group by 1,2,3,4
) a 

left join
(
select role_id,done_dt,game_type,dungeon_id,进入次数 -- 对应着复玩人数、次数
from
(select d.role_id,c.done_dt,c.dungeon_id,c.game_type,进入次数
from
(select a.role_id,a.done_dt,a.dungeon_id,a.game_type -- 有失败的玩家
from
(select dungeon_id,role_id,to_date(cast(date_time as timestamp)) as done_dt,start_time,game_type
from myth_server.server_enter_dungeon
where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
and game_type =3 -- 3战役
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3,4,5) a 
left join 
(select dungeon_id,role_id,battle_result,log_time,start_time,game_type
from myth_server.server_dungeon_end
where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
and game_type =3 -- 3战役
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3,4,5,6) b 
on a.game_type = b.game_type and a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time = b.start_time
where battle_result is null -- =2是有失败记录的/is null是无日志记录的
group by 1,2,3,4 
) c 
left join 
(select a.role_id as role_id,done_dt,a.game_type as game_type,a.dungeon_id as dungeon_id,count(a.start_time) as '进入次数'
from
(select dungeon_id,role_id,to_date(cast(date_time as timestamp)) as done_dt,start_time,game_type
from myth_server.server_enter_dungeon
where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
and game_type =3 -- 3战役
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3,4,5) a 
left join 
(select dungeon_id,role_id,battle_result,log_time,start_time,game_type
from myth_server.server_dungeon_end
where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
and game_type =3 -- 3战役
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3,4,5,6) b 
on a.game_type = b.game_type and a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time = b.start_time
group by 1,2,3,4
) as d 
on c.game_type = d.game_type and c.dungeon_id=d.dungeon_id  and c.role_id=d.role_id and c.done_dt=d.done_dt
group by 1,2,3,4,5
) as  e 
group by 1,2,3,4,5
) as f 
on a.role_id = f.role_id 
where datediff(done_dt,birth_dt) = 0  and 进入次数 > 1
group by 1,2,3,4,5,6






失败后通关人数 去重日志条数 = 1  √√√√√√√√√

select role_id,birth_dt,country,game_type,dungeon_id,天数--,付费档位
from

(select a.role_id as role_id,birth_dt,country,game_type,dungeon_id,num,datediff(done_dt,birth_dt)+1 as '天数',是否付费
from
-- (select a.role_id,birth_dt,country,
-- case when b.role_id is not null then '付费'
--       else '免费'
--       end as '是否付费'
-- from 
-- (  --新增
-- select role_id,birth_dt,country
-- from
-- (select role_id,device_id,to_date(cast(date_time as timestamp)) as birth_dt
-- from myth.server_role_create 
-- where day_time>=${beginDate} and day_time<=${birthEndDate} 
-- and server_id in (${serverIds}) 
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- ) as a1
-- right join
-- (select device_id,to_date(cast(date_time as timestamp)) as device_birth_dt, 
--      case when country in ('PH','MY') then 'PH+MY'
--      when country in ('GB','IE','CA')  then 'GB+CA'
--      end as country
-- from myth.device_activate
-- where day_time>=${beginDate} and day_time<=${birthEndDate}
-- and version_name in ('1.4.0','1.4.1')
-- and country not in ('CN','HK')
-- ) as a2 
-- on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
-- ) as a
-- left join -- 付费免费拆分
-- (select role_id,to_date(cast(date_time as timestamp)) as pay_dt
-- from myth.order_pay
-- where day_time between ${beginDate} and ${endDate} 
-- and server_id in (${serverIds})
-- and channel_id=1000  --Android
-- and country not in ('CN','HK')
-- group by 1,2) b 
-- on pay_dt=birth_dt and a.role_id=b.role_id 
-- group by 1,2,3,4
-- ) a 


left join
(select c.role_id,c.done_dt,c.dungeon_id,c.game_type,count(distinct battle_result) as num -- 去重日志条数
from
(select a.role_id,a.done_dt,a.dungeon_id,a.game_type -- 有失败/无日志的玩家
from
(select dungeon_id,role_id,to_date(cast(date_time as timestamp)) as done_dt,start_time,game_type
from myth_server.server_enter_dungeon
where day_time>=${beginDate} and day_time<=${end2Date} and server_id in (${serverIds})
and game_type =3 -- 3战役
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3,4,5) a 
left join 
(select dungeon_id,role_id,battle_result,log_time,start_time,game_type
from myth_server.server_dungeon_end
where day_time>=${beginDate} and day_time<=${end2Date} and server_id in (${serverIds})
and game_type =3 -- 3战役
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3,4,5,6) b 
on a.game_type = b.game_type and a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time = b.start_time
where battle_result is null -- =2是有失败记录的/is null是无日志记录的
group by 1,2,3,4 
) c 
left join 
(select a.role_id as role_id,done_dt,a.game_type as game_type,a.dungeon_id as dungeon_id,battle_result
from
(select dungeon_id,role_id,to_date(cast(date_time as timestamp)) as done_dt,start_time,game_type
from myth_server.server_enter_dungeon
where day_time>=${beginDate} and day_time<=${end2Date} and server_id in (${serverIds})
and game_type =3 -- 3战役
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3,4,5) a 
left join 
(select dungeon_id,role_id,battle_result,log_time,start_time,game_type
from myth_server.server_dungeon_end
where day_time>=${beginDate} and day_time<=${end2Date} and server_id in (${serverIds})
and game_type =3 -- 3战役
and channel_id=1000  --Android
and version_name in ('1.4.0','1.4.1')
and country not in ('CN','HK')
group by 1,2,3,4,5,6) b 
on a.game_type = b.game_type and a.dungeon_id=b.dungeon_id and a.role_id=b.role_id and a.start_time = b.start_time
where battle_result = 1 -- 有成功日志的
group by 1,2,3,4,5
) as d 
on c.game_type = d.game_type and c.dungeon_id=d.dungeon_id and c.role_id=d.role_id and c.done_dt=d.done_dt
group by 1,2,3,4
) as f 
on a.role_id = f.role_id 
where datediff(f.done_dt,a.birth_dt) = 0 
) as new
where num = 1
group by 1,2,3,4,5,6








