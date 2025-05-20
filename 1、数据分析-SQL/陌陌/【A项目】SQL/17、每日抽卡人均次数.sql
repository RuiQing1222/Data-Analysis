select datediff(pass_dt,birth_dt)+1 as '天数',count(distinct a.role_id) as '角色数量',round(avg(gacha_times),1) as '人均抽卡次数',
appx_median(gacha_times) as '抽卡中位数'
from
(select to_date(cast (date_time as timestamp)) as birth_dt,role_id 
from  myth.server_role_create 
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
group by 1,2) a 
left join 
(select to_date(cast (date_time as timestamp)) as pass_dt,role_id,
sum(case when gacha_mode=1 then 1 
         when gacha_mode=2 then 10
         end ) as gacha_times
from myth_server.server_card_gacha
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
group by 1,2) b 
on a.role_id=b.role_id
where pass_dt>=birth_dt
group by 1
order by 1 asc