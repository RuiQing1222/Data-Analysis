-- 新增用户

select datediff(pvp_dt,birth_dt)+1 as '天数',
count(distinct a.role_id) as '角色数量',
round(count(case when fighting_result=1 then 1 else null end)/count(1)*100,2)  as 'PVP胜率%',
round(sum(nums)/count(distinct a.role_id),2) as '人均PVP次数'
from 
(select to_date(cast(date_time as timestamp)) as birth_dt,role_id
from myth.server_role_create 
where day_time>=20220607 and day_time<=${endDate}
and server_id in (20001,20002,20003) 
and version_name ='1.3.0'
and country not in ('CN','HK') 
and device_id in 
(select device_id
from myth.device_activate
where day_time>=20220607 and day_time<=${endDate}
and version_name ='1.3.0'
and country not in ('CN','HK')) 
group by 1,2) a 
left join
(
select to_date(cast(date_time as timestamp)) as pvp_dt,role_id,fighting_result,count(1) as nums
from myth_server.server_arena
where day_time>=20220607 and day_time<=${endDate}
and version_name ='1.3.0'
group by 1,2,3) b 
on a.role_id=b.role_id
where datediff(pvp_dt,birth_dt) is not null
group by 1
order by 1 asc