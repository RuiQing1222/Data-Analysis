---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

公会战



select server_id,guild_id,a.role_id,guild_level,fighting_result,integral
from 
(select server_id,role_id,guild_id,fighting_result,integral
from myth_server.server_guild_war
where day_time>=${beginDate} and day_time<=${endDate} and server_id in (${serverIds})
and version_name = '1.5.0'
and channel_id in (1000,2000)
) a 
left join 
(
select guild_id,max(guild_level) as guild_level
from myth_server.server_guild_upgrade
where day_time>=20230103 and day_time<=${endDate} and server_id in (${serverIds})
and channel_id in (1000,2000)
group by 1
) b
on a.role_id=b.role_id 

