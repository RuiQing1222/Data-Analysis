----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 
通行证 第三期


本期购买金额及购买人数 是否也购买过前两期



select month(date_time) as vip_month,count(distinct role_id),sum(pay_price) as pay
from myth.order_pay
where day_time>=${beginDate} and day_time<${vipDate}
and channel_id=1000  --Android
and country not in ('CN','HK')
and game_product_id in ('com.managames.myththor.iap_9.99jh',
'com.managames.myththor.iap_19.99jh')
group by 1 
order by 1 asc 


select month(date_time) as vip_month,role_id
from myth.order_pay
where day_time>=${beginDate} and day_time<${vipDate}
and channel_id=1000  --Android
and country not in ('CN','HK')
and game_product_id in ('com.managames.myththor.iap_9.99jh',
'com.managames.myththor.iap_19.99jh')
group by 1,2
order by 1 asc 





购买第三期的用户的生命周期 

select a.role_id,birth_dt,pay_dt,game_id,
sum(case when vip_dt<pay_dt then pay else 0 end ) as '买前付费'
from 
(select  role_id,to_date(date_time) as pay_dt,
case when game_product_id  ='com.managames.myththor.iap_9.99jh'  then '普通'
     when game_product_id  ='com.managames.myththor.iap_19.99jh' then '豪华'
end as game_id 
from myth.order_pay
where day_time>=${beginDate} and day_time<${endDate}
and channel_id=1000  --Android
and country not in ('CN','HK')
and game_product_id in ('com.managames.myththor.iap_9.99jh',
'com.managames.myththor.iap_19.99jh')
 ) a 
left join 
(select role_id,to_date(date_time) as birth_dt
from myth.server_role_create 
where day_time>=${birthBeginDate} and day_time<${endDate}
and server_id in (${serverIds}) 
and channel_id=1000  --Android
--and version_name  = '1.4.3'
and country not in ('CN','HK')
group by 1,2
)  b 
on a.role_id= b.role_id
left join 
(select role_id,to_date(date_time) as vip_dt,sum(pay_price) as pay
from myth.order_pay
where day_time>=${beginDate} and day_time<${endDate}
and channel_id=1000  --Android
and country not in ('CN','HK')
group by 1,2) c 
on a.role_id = c.role_id

group by 1,2,3,4 




等级进度
select a.role_id,birth_dt,max_pass,pass_diff,    
case when b.role_id is not null then game_id
     else  '非付费' end as game_id
from 
(select role_id,max_pass,datediff(max_dt,min_dt) as pass_diff
     from 
(select role_id,max(pass_level) as max_pass,group_concat(distinct max_dt)  as max_dt,group_concat(distinct min_dt) as min_dt
     from 
(select role_id,pass_level,
     case when row_num1=1 then pass_dt else null end as max_dt,
     case when row_num2=1 then pass_dt else null end as min_dt
     from 
(
select role_id,pass_level,to_date(date_time) as pass_dt,
row_number()over(partition by role_id order by log_time desc) as row_num1,
row_number()over(partition by role_id order by log_time asc)  as row_num2
from myth_server.server_battle_pass_task_completed
where day_time>=${beginDate} and day_time<${endDate}
and channel_id=1000  --Android
and country not in ('CN','HK')
and version_name  = '1.4.3'
and pass_id='4'
 ) c1 
where row_num1 =1  or row_num2 =1
) c2 
group by 1) c3
) a   
left join 
(select  role_id,to_date(date_time) as pay_dt,
case when game_product_id  ='com.managames.myththor.iap_9.99jh'  then '普通'
     when game_product_id  ='com.managames.myththor.iap_19.99jh' then '豪华'
end as game_id 
from myth.order_pay
where day_time>=${beginDate} and day_time<${endDate}
and channel_id=1000  --Android
and country not in ('CN','HK')
and game_product_id in ('com.managames.myththor.iap_9.99jh',
'com.managames.myththor.iap_19.99jh')
 ) b 
on a.role_id = b.role_id
left join 
(select role_id,to_date(date_time) as birth_dt
from myth.server_role_create 
where day_time>=${birthBeginDate} and day_time<${endDate}
and server_id in (${serverIds}) 
and channel_id=1000  --Android
--and version_name  = '1.4.3'
and country not in ('CN','HK')
group by 1,2
)  c 
on a.role_id= c .role_id

group by 1,2,3,4,5



任务完成率


select 是否满级,task_id,
case when b.role_id is not null then game_id
     else  '非付费' end as game_id,count(distinct a.role_id) as '接取人数',
     count(distinct complete_role) as '完成人数'
from 
(select role_id,
case when max_pass=60 then '满级' else '不满级'
     end as '是否满级',datediff(max_dt,min_dt) as pass_diff
     from 
(select role_id,max(pass_level) as max_pass,group_concat(distinct max_dt)  as max_dt,group_concat(distinct min_dt) as min_dt
     from 
(select role_id,pass_level,
     case when row_num1=1 then pass_dt else null end as max_dt,
     case when row_num2=1 then pass_dt else null end as min_dt
     from 
(
select role_id,pass_level,to_date(date_time) as pass_dt,
row_number()over(partition by role_id order by log_time desc) as row_num1,
row_number()over(partition by role_id order by log_time asc)  as row_num2
from myth_server.server_battle_pass_task_completed
where day_time>=${beginDate} and day_time<${endDate}
and channel_id=1000  --Android
and country not in ('CN','HK')
and version_name  = '1.4.3'
and pass_id='4'
 ) c1 
where row_num1 =1  or row_num2 =1
) c2 
group by 1) c3
) a   
left join 
(select  role_id,to_date(date_time) as pay_dt,
case when game_product_id  ='com.managames.myththor.iap_9.99jh'  then '普通'
     when game_product_id  ='com.managames.myththor.iap_19.99jh' then '豪华'
end as game_id 
from myth.order_pay
where day_time>=${beginDate} and day_time<${endDate}
and channel_id=1000  --Android
and country not in ('CN','HK')
and game_product_id in ('com.managames.myththor.iap_9.99jh',
'com.managames.myththor.iap_19.99jh')
 ) b 
on a.role_id = b.role_id
left join 
(select role_id,to_date(date_time) as birth_dt
from myth.server_role_create 
where day_time>=${birthBeginDate} and day_time<${endDate}
and server_id in (${serverIds}) 
and channel_id=1000  --Android
--and version_name  = '1.4.3'
and country not in ('CN','HK')
group by 1,2
)  c 
on a.role_id= c .role_id
left join 
(select accept_role,d.task_id,complete_role
from 
(select role_id as accept_role,task_id
from myth_server.server_accept_task
where day_time>=${beginDate} and day_time<${endDate}
and channel_id=1000  --Android
and country not in ('CN','HK')
and version_name  = '1.4.3'
and task_type in (9,10)
group by 1,2 
) d 
left join 

(select role_id as complete_role,task_id
from myth_server.server_complete_task
where day_time>=${beginDate} and day_time<${endDate}
and channel_id=1000  --Android
and country not in ('CN','HK')
and version_name  = '1.4.3'
and task_type in (9,10)
) e 
on accept_role=complete_role and d.task_id = e.task_id 
) f 
on a.role_id = accept_role
group by 1,2,3


 