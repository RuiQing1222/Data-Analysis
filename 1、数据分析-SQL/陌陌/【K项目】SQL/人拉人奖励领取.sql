人拉人奖励只有体力、钻石   100，101 邀请进度奖励，邀请单人奖励



单人奖励领取
select a.day_time,a.device_id,a.recovery_method,a.recovery_count
from

(SELECT day_time,device_id,recovery_method,sum(recovery_count) as recovery_count
FROM fairy_town_server.server_physical_recovery
WHERE day_time>=20211215
  AND day_time<=20211223
  and recovery_method in ('100','101')
GROUP BY 1,2,3
ORDER BY 1) a

join 
(select customer_user_id
from fairy_town.af_push
where day_time>=20211215 and day_time<=20211223
and media_source ='af_app_invites'
group by 1
) b 
on a.device_id = b.customer_user_id



进度奖励领取  只有邀请人才能领取里程碑奖励
SELECT day_time,device_id,recovery_method,sum(recovery_count) as recovery_count
FROM fairy_town_server.server_gem_recovery
WHERE day_time>=20211215
  AND day_time<=20211223
  and recovery_method in ('100','101')
GROUP BY 1,2,3
ORDER BY 1