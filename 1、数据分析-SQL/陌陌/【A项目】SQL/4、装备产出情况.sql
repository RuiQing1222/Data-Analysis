select quality as '品质编号',
case when quality=1  then '灰色'
     when quality=2  then '白色'
     when quality=3  then '蓝色'
     when quality=4  then '蓝色+'
     when quality=5  then '金色'
     when quality=6  then '金色+'
     when quality=7  then '橙色'
     when quality=8  then '橙色+'
     when quality=9  then '绿色'
     when quality=10 then '绿色+'
     when quality=11 then '红色'
     when quality=12 then '红色+'
     end as '品质备注',
count(distinct role_id) as '掉落角色数',
round(avg(nums),2) as '人均掉落次数'     
from
(select role_id,equip_quality as quality,count(1) as nums
from myth_server.server_equip_drop
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
group by 1,2) a 
group by 1,2
order by 1