---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

分R的战役关卡数和等级停留数据
分三档位付费

select birth_dt,vip,datediff(done_dt,birth_dt)+1 as '生命周期',
--max_level,
count(distinct a.role_id),
appx_median(max_level) 
from 
(select birth_dt,a1.role_id,
-- case when total_pay<=1                   then 1
--      when total_pay>1  and total_pay<=2  then 2
--      when total_pay>2                    then 3 
--      else 0 
--      end as vip --D1  
-- case when total_pay<=3                   then 1
--      when total_pay>3  and total_pay<=5  then 2
--      when total_pay>5                    then 3 
--      else 0 
--      end as vip --D2
-- case when total_pay<=8                    then 1
--      when total_pay>8  and total_pay<=10  then 2
--      when total_pay>10                    then 3 
--      else 0 
--      end as vip --D3
-- case when total_pay<=8                   then 1
--      when total_pay>8  and total_pay<=20 then 2
--      when total_pay>20                    then 3 
--      else 0 
--      end as vip --D4
-- case when total_pay<=8                   then 1
--      when total_pay>8  and total_pay<=33 then 2
--      when total_pay>33                    then 3 
--      else 0 
--      end as vip --D5
case when total_pay<=8                    then 1
     when total_pay>8  and total_pay<=70  then 2
     when total_pay>70                    then 3 
     else 0 
     end as vip --D7
from 
(select birth_dt,a.role_id
,sum(case when datediff(vip_dt,birth_dt)<${lifeTime}  then pay else 0 end ) as 'total_pay'
from
(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(date_time) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id in (1000,2000)
and version_name ='1.5.0'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(date_time) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id in (1000,2000)
and version_name ='1.5.0'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
group by 1,2
)  a
left join
(
select role_id,to_date(date_time) as vip_dt,sum(pay_price) pay 
from myth.order_pay
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
group by 1,2 ) b 
on a.role_id =b.role_id
group by 1,2
) a1
left join  
(
select role_id,to_date(date_time) as login_dt
from myth.server_role_login 
where day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name ='1.5.0'
group by 1,2
) b1 
on a1.role_id=b1.role_id
where datediff(login_dt,birth_dt)=1

) a 
left join 
(select role_id,done_dt,max(max_level) as max_level
    from 
(
(select role_id,to_date(date_time) as done_dt,max(role_level) as max_level
from myth.server_role_login 
where day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name ='1.5.0'
group by 1,2
)  
union all  
(
select role_id,to_date(date_time) as done_dt,max(role_level) as max_level
from myth.server_role_upgrade
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name ='1.5.0'
group by 1,2 ) 
union all  
(
select role_id,to_date(date_time) as done_dt,max(role_level) as max_level
from myth_server.server_dungeon_end
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name ='1.5.0'
group by 1,2 ) 
) c1 
group by 1,2 
)   c 
on a.role_id =c.role_id
--where datediff(done_dt,birth_dt)<${lifeTime} 
group by 1,2,3,4



战役停留

分三档位付费

select birth_dt,vip,datediff(done_dt,birth_dt)+1 as '生命周期',
max_dungeon,count(distinct a.role_id),
appx_median(max_dungeon) 
from 
(select birth_dt,a1.role_id,
-- case when total_pay<=1                   then 1
--      when total_pay>1  and total_pay<=2  then 2
--      when total_pay>2                    then 3 
--      else 0 
--      end as vip --D1  
-- case when total_pay<=3                   then 1
--      when total_pay>3  and total_pay<=5  then 2
--      when total_pay>5                    then 3 
--      else 0 
--      end as vip --D2
-- case when total_pay<=8                    then 1
--      when total_pay>8  and total_pay<=10  then 2
--      when total_pay>10                    then 3 
--      else 0 
--      end as vip --D3
-- case when total_pay<=8                   then 1
--      when total_pay>8  and total_pay<=20 then 2
--      when total_pay>20                    then 3 
--      else 0 
--      end as vip --D4
-- case when total_pay<=8                   then 1
--      when total_pay>8  and total_pay<=33 then 2
--      when total_pay>33                    then 3 
--      else 0 
--      end as vip --D5
case when total_pay<=8                    then 1
     when total_pay>8  and total_pay<=70  then 2
     when total_pay>70                    then 3 
     else 0 
     end as vip --D7
from 
(select birth_dt,a.role_id
,sum(case when datediff(vip_dt,birth_dt)<${lifeTime}  then pay else 0 end ) as 'total_pay'
from
(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(date_time) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id in (1000,2000)
and version_name ='1.5.0'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(date_time) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id in (1000,2000)
and version_name ='1.5.0'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
group by 1,2
)  a
left join
(
select role_id,to_date(date_time) as vip_dt,sum(pay_price) pay 
from myth.order_pay
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
group by 1,2 ) b 
on a.role_id =b.role_id
group by 1,2
) a1
left join  
(
select role_id,to_date(date_time) as login_dt
from myth.server_role_login 
where day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name ='1.5.0'
group by 1,2
) b1 
on a1.role_id=b1.role_id
where datediff(login_dt,birth_dt)=1
) a

left join
(
select done_dt,role_id,max(max_dungeon) as max_dungeon
from 
(select
  a.done_dt, 
  a.role_id, 
  COALESCE(b.max_dungeon, c.max_dungeon) AS max_dungeon
FROM (
  SELECT done_dt, role_id
  FROM (
    (SELECT role_id,to_date(date_time) as done_dt 
    FROM myth_server.server_dungeon_end
    WHERE day_time >= ${beginDate} AND day_time <= ${endDate}
      AND country NOT IN ('CN', 'HK')
      and version_name ='1.5.0'
      AND game_type = 3
      AND battle_result = 1
    GROUP BY 1,2)
    UNION ALL
    (SELECT role_id,to_date(date_time) as done_dt 
    FROM myth.server_role_login 
    WHERE day_time >= ${beginDate} AND day_time <= ${endDate}
      AND country NOT IN ('CN', 'HK')
      and version_name ='1.5.0'
    GROUP BY 1,2)
    union all  
   (
select role_id,to_date(date_time) as done_dt 
from myth.server_role_upgrade
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name ='1.5.0'
group by 1,2 ) 
  ) t 
  GROUP BY 1, 2
) a
LEFT JOIN (
select role_id,to_date(date_time) as done_dt,max(dungeon_id) as max_dungeon
from myth_server.server_dungeon_end
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name ='1.5.0'
and game_type=3
and battle_result=1
group by 1,2
) as b 
  ON a.done_dt = b.done_dt AND a.role_id = b.role_id
LEFT JOIN (
select role_id,to_date(date_time) as done_dt,max(dungeon_id) as max_dungeon
from myth_server.server_dungeon_end
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name ='1.5.0'
and game_type=3
and battle_result=1
group by 1,2
)as c 
ON a.done_dt > c.done_dt AND a.role_id = c.role_id
  
) e1
group by 1,2
)
 e 
on a.role_id = e.role_id
--where datediff(done_dt,birth_dt)<${lifeTime}
group by 1,2,3,4


 

 


数据验证
select datediff(done_dt,birth_dt)+1,count(distinct a.role_id)
from 
(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(date_time) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id in (1000,2000)
and version_name ='1.5.0'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(date_time) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id in (1000,2000)
and version_name ='1.5.0'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
group by 1,2
)  a
left join
(
select role_id,to_date(date_time) as done_dt
from myth.server_role_login 
where day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name ='1.5.0'
group by 1,2
) c 
where done_dt>=birth_dt
group by 1




select game_product_id,sum(nums) as nums,sum(pay_price) as pay_price
from 
(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(date_time) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id in (1000,2000)
and version_name ='1.5.0'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(date_time) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id in (1000,2000)
and version_name ='1.5.0'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
group by 1,2
)  a
left join
(
select role_id,game_product_id,count(1) as nums,sum(pay_price) as pay_price
from myth.order_pay
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id in (1000,2000)
and country not in ('CN','HK')
and game_product_id in ('com.managames.myththor.iap_4.99yk','com.managames.myththor.iap_4.99ck','com.managames.myththor.iap_1.99gj','com.managames.myththor.iap_4.99mj',
'com.managames.myththor.iap_0.99kf','com.managames.myththor.iap_1.99kfzk')
group by 1,2 
) b 
on a.role_id = b.role_id 
group by 1

 


战力分布


-- select datediff(done_dt,birth_dt)+1 as '天数',vip,count(distinct role_id) as '角色数',
-- round(avg(battle_points),0) as '平均战力',
-- round(avg(case when row_num<=0.25*cnt                      then battle_points else null end ),0) as `角色平均战力1%~25%`,
-- round(avg(case when row_num<=0.50*cnt and row_num>0.25*cnt then battle_points else null end ),0) as `角色平均战力25%~50%`,
-- round(avg(case when row_num<=0.75*cnt and row_num>0.50*cnt then battle_points else null end ),0) as `角色平均战力50%~75%`,
-- round(avg(case when row_num<=cnt      and row_num>0.75*cnt then battle_points else null end ),0) as `角色平均战力75%~100%`
-- from 
-- (select a.role_id,vip,birth_dt,done_dt,battle_points,row_number() over(partition by done_dt order by battle_points asc) as row_num,count(1) over(partition by done_dt) as cnt 
-- from 
select a.role_id,vip,datediff(done_dt,birth_dt)+1 as '天数',battle_points
from 
(select birth_dt,a1.role_id,
-- case when total_pay<=1                   then 1
--      when total_pay>1  and total_pay<=2  then 2
--      when total_pay>2                    then 3 
--      else 0 
--      end as vip --D1  
-- case when total_pay<=3                   then 1
--      when total_pay>3  and total_pay<=5  then 2
--      when total_pay>5                    then 3 
--      else 0 
--      end as vip --D2
case when total_pay<=8                    then 1
     when total_pay>8  and total_pay<=10  then 2
     when total_pay>10                    then 3 
     else 0 
     end as vip --D3
-- case when total_pay<=8                   then 1
--      when total_pay>8  and total_pay<=20 then 2
--      when total_pay>20                    then 3 
--      else 0 
--      end as vip --D4
-- case when total_pay<=8                   then 1
--      when total_pay>8  and total_pay<=33 then 2
--      when total_pay>33                    then 3 
--      else 0 
--      end as vip --D5
-- case when total_pay<=8                    then 1
--      when total_pay>8  and total_pay<=70  then 2
--      when total_pay>70                    then 3 
--      else 0 
--      end as vip --D7
from 
(select birth_dt,a.role_id
,sum(case when datediff(vip_dt,birth_dt)<${lifeTime}  then pay else 0 end ) as 'total_pay'
from
(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(date_time) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id in (1000,2000)
and version_name ='1.5.0'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(date_time) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id in (1000,2000)
and version_name ='1.5.0'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
group by 1,2
)  a
left join
(
select role_id,to_date(date_time) as vip_dt,sum(pay_price) pay 
from myth.order_pay
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
group by 1,2 ) b 
on a.role_id =b.role_id
group by 1,2
) a1
left join  
(
select role_id,to_date(date_time) as login_dt
from myth.server_role_login 
where day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name ='1.5.0'
group by 1,2
) b1 
on a1.role_id=b1.role_id
where datediff(login_dt,birth_dt)=1
) a 

left join 

(select role_id,done_dt,max(battle_points) as battle_points
 from 
(
select role_id,to_date(date_time) as done_dt,battle_points
from myth_server.server_dungeon_end
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and country not in ('CN','HK')
union 
select role_id,to_date(date_time) as done_dt,battle_points
from myth.server_role_login
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and country not in ('CN','HK')
union 
select role_id,to_date(date_time) as done_dt,battle_points
from myth_server.server_card_gacha
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and country not in ('CN','HK')
union 
select role_id,to_date(date_time) as done_dt,battle_points
from myth.server_prop
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and country not in ('CN','HK')
union 
select role_id,to_date(date_time) as done_dt,battle_points
from myth.server_role_upgrade
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and country not in ('CN','HK')
union 
select role_id,to_date(date_time) as done_dt,battle_points
from myth.server_currency
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and country not in ('CN','HK')
) c1 
group by 1,2) d  
on a.role_id = d.role_id 
-- where datediff(done_dt,birth_dt) < ${lifeTime}
-- ) t 
-- group by 1,2






分档位通关战役、秘境关卡数



select a.role_id,vip,datediff(done_dt,birth_dt)+1 as '天数',dungeon_nums
from 
(select birth_dt,a1.role_id,
-- case when total_pay<=1                   then 1
--      when total_pay>1  and total_pay<=2  then 2
--      when total_pay>2                    then 3 
--      else 0 
--      end as vip --D1  
-- case when total_pay<=3                   then 1
--      when total_pay>3  and total_pay<=5  then 2
--      when total_pay>5                    then 3 
--      else 0 
--      end as vip --D2
-- case when total_pay<=8                    then 1
--      when total_pay>8  and total_pay<=10  then 2
--      when total_pay>10                    then 3 
--      else 0 
--      end as vip --D3
-- case when total_pay<=8                   then 1
--      when total_pay>8  and total_pay<=20 then 2
--      when total_pay>20                    then 3 
--      else 0 
--      end as vip --D4
-- case when total_pay<=8                   then 1
--      when total_pay>8  and total_pay<=33 then 2
--      when total_pay>33                    then 3 
--      else 0 
--      end as vip --D5
case when total_pay<=8                    then 1
     when total_pay>8  and total_pay<=70  then 2
     when total_pay>70                    then 3 
     else 0 
     end as vip --D7
from 
(select birth_dt,a.role_id
,sum(case when datediff(vip_dt,birth_dt)<${lifeTime} then pay else 0 end ) as 'total_pay'
from
(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(date_time) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id in (1000,2000)
and version_name ='1.5.0'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(date_time) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id in (1000,2000)
and version_name ='1.5.0'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id --and a1.birth_dt = a2.device_birth_dt
group by 1,2
)  a
left join
(
select role_id,to_date(date_time) as vip_dt,sum(pay_price) pay 
from myth.order_pay
where  day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
group by 1,2 ) b 
on a.role_id =b.role_id
group by 1,2
) a1
left join  
(
select role_id,to_date(date_time) as login_dt
from myth.server_role_login 
where day_time>=${beginDate} and day_time<=${endDate}
and country not in ('CN','HK')
and version_name ='1.5.0'
group by 1,2
) b1 
on a1.role_id=b1.role_id
where datediff(login_dt,birth_dt)=1
) a 

left join 



( select c1.role_id,c1.done_dt,case when  c2.done_dt  is null then 0 else dungeon_nums end as dungeon_nums
from 
(
select role_id,to_date(date_time) as done_dt
from myth.server_role_login
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and country not in ('CN','HK')
group by 1,2 
) c1 

left join 

(select role_id,to_date(date_time) as done_dt,count(distinct dungeon_id) as dungeon_nums
from myth_server.server_dungeon_end
where day_time>=${beginDate} and day_time<=${endDate} 
and server_id in (${serverIds}) 
and country not in ('CN','HK')
and game_type = 3 
and battle_result=1
group by 1,2) c2


-- (select role_id,to_date(date_time) as done_dt,count(distinct dungeon_id) as dungeon_nums
-- from myth_server.server_dungeon_end
-- where day_time>=${beginDate} and day_time<=${endDate} 
-- and server_id in (${serverIds}) 
-- and country not in ('CN','HK')
-- and game_type = 2 
-- and battle_result=1
-- group by 1,2) c2
on c1.role_id = c2.role_id  and c1.done_dt = c2.done_dt
) c 
on a.role_id = c.role_id
--where datediff(done_dt,birth_dt) < ${lifeTime}
group by 1,2,3,4 