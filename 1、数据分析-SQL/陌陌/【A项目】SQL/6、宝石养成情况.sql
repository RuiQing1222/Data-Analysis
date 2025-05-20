select 装备部位,宝石孔位,
count(distinct case when jewel_level=1  then role_id else null end ) as '1级人数',
count(distinct case when jewel_level=2  then role_id else null end ) as '2级人数',
count(distinct case when jewel_level=3  then role_id else null end ) as '3级人数',
count(distinct case when jewel_level=4  then role_id else null end ) as '4级人数',
count(distinct case when jewel_level=5  then role_id else null end ) as '5级人数',
count(distinct case when jewel_level=6  then role_id else null end ) as '6级人数',
count(distinct case when jewel_level=7  then role_id else null end ) as '7级人数',
count(distinct case when jewel_level=8  then role_id else null end ) as '8级人数',
count(distinct case when jewel_level=9  then role_id else null end ) as '9级人数',
count(distinct case when jewel_level=10 then role_id else null end ) as '10级人数'
from
(select a.role_id,
	case when b.log_time>=a.log_time then b.装备部位 
	     else a.装备部位
	     end as 装备部位,
	case when b.log_time>=a.log_time then b.宝石孔位 
	     else a.宝石孔位
	     end as 宝石孔位,
	case when b.log_time>=a.log_time then b.jewel_level 
	     else a.jewel_level
	     end as jewel_level
from 	
(
(select 装备部位,宝石孔位,role_id,jewel_level,log_time
from 	
(select 1 as '装备部位',1 as '宝石孔位',role_id,cast(split_part(gear_punch,',',1) as int) as jewel_level,log_time,
	row_number()over(partition by role_id order by log_time desc ) as row_number
from  myth_server.server_login_snapshot
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
) a
where row_number=1
)	
union all 
(select 装备部位,宝石孔位,role_id,jewel_level,log_time
from 
(select 1 as '装备部位',2 as '宝石孔位',role_id,cast(split_part(gear_punch,',',2) as int) as jewel_level,log_time,
	row_number()over(partition by role_id order by log_time desc ) as row_number
from  myth_server.server_login_snapshot
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
) a
where row_number=1
)
union all 
(select 装备部位,宝石孔位,role_id,jewel_level,log_time
from
(select 1 as '装备部位',3 as '宝石孔位',role_id,cast(split_part(gear_punch,',',3) as int) as jewel_level,log_time,
	row_number()over(partition by role_id order by log_time desc ) as row_number
from  myth_server.server_login_snapshot
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
) a
where row_number=1
)
union all 
(select 装备部位,宝石孔位,role_id,jewel_level,log_time
from
(select 2 as '装备部位',1 as '宝石孔位',role_id,cast(split_part(gear_punch,',',4) as int) as jewel_level,log_time,
	row_number()over(partition by role_id order by log_time desc ) as row_number
from  myth_server.server_login_snapshot
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
) a
where row_number=1
)
union all 
(select 装备部位,宝石孔位,role_id,jewel_level,log_time
from
(select 2 as '装备部位',2 as '宝石孔位',role_id,cast(split_part(gear_punch,',',5) as int) as jewel_level,log_time,
	row_number()over(partition by role_id order by log_time desc ) as row_number
from  myth_server.server_login_snapshot
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
) a
where row_number=1
)
union all 
(select 装备部位,宝石孔位,role_id,jewel_level,log_time
from
(select 2 as '装备部位',3 as '宝石孔位',role_id,cast(split_part(gear_punch,',',6) as int) as jewel_level,log_time,
	row_number()over(partition by role_id order by log_time desc ) as row_number
from  myth_server.server_login_snapshot
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
) a
where row_number=1
)
union all 
(select 装备部位,宝石孔位,role_id,jewel_level,log_time
from
(select 3 as '装备部位',1 as '宝石孔位',role_id,cast(split_part(gear_punch,',',7) as int) as jewel_level,log_time,
	row_number()over(partition by role_id order by log_time desc ) as row_number
from  myth_server.server_login_snapshot
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
) a
where row_number=1
)
union all 
(select 装备部位,宝石孔位,role_id,jewel_level,log_time
from
(select 3 as '装备部位',2 as '宝石孔位',role_id,cast(split_part(gear_punch,',',8) as int) as jewel_level,log_time,
	row_number()over(partition by role_id order by log_time desc ) as row_number
from  myth_server.server_login_snapshot
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
) a
where row_number=1
)
union all 
(select 装备部位,宝石孔位,role_id,jewel_level,log_time
from
(select 3 as '装备部位',3 as '宝石孔位',role_id,cast(split_part(gear_punch,',',9) as int) as jewel_level,log_time,
	row_number()over(partition by role_id order by log_time desc ) as row_number
from  myth_server.server_login_snapshot
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
) a
where row_number=1
)
union all 
(select 装备部位,宝石孔位,role_id,jewel_level,log_time
from
(select 4 as '装备部位',1 as '宝石孔位',role_id,cast(split_part(gear_punch,',',10) as int) as jewel_level,log_time,
	row_number()over(partition by role_id order by log_time desc ) as row_number
from  myth_server.server_login_snapshot
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
) a
where row_number=1
)
union all 
(select 装备部位,宝石孔位,role_id,jewel_level,log_time
from
(select 4 as '装备部位',2 as '宝石孔位',role_id,cast(split_part(gear_punch,',',11) as int) as jewel_level,log_time,
	row_number()over(partition by role_id order by log_time desc ) as row_number
from  myth_server.server_login_snapshot
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
) a
where row_number=1
)
union all 
(select 装备部位,宝石孔位,role_id,jewel_level,log_time
from
(select 4 as '装备部位',3 as '宝石孔位',role_id,cast(split_part(gear_punch,',',12) as int) as jewel_level,log_time,
	row_number()over(partition by role_id order by log_time desc ) as row_number
from  myth_server.server_login_snapshot
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
) a
where row_number=1
)
union all 
(select 装备部位,宝石孔位,role_id,jewel_level,log_time
from
(select 5 as '装备部位',1 as '宝石孔位',role_id,cast(split_part(gear_punch,',',13) as int) as jewel_level,log_time,
	row_number()over(partition by role_id order by log_time desc ) as row_number
from  myth_server.server_login_snapshot
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
) a
where row_number=1
)
union all 
(select 装备部位,宝石孔位,role_id,jewel_level,log_time
from
(select 5 as '装备部位',2 as '宝石孔位',role_id,cast(split_part(gear_punch,',',14) as int) as jewel_level,log_time,
	row_number()over(partition by role_id order by log_time desc ) as row_number
from  myth_server.server_login_snapshot
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
) a
where row_number=1
)
union all 
(select 装备部位,宝石孔位,role_id,jewel_level,log_time
from
(select 5 as '装备部位',3 as '宝石孔位',role_id,cast(split_part(gear_punch,',',15) as int) as jewel_level,log_time,
	row_number()over(partition by role_id order by log_time desc ) as row_number
from  myth_server.server_login_snapshot
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
) a
where row_number=1
)
union all 
(select 装备部位,宝石孔位,role_id,jewel_level,log_time
from
(select 6 as '装备部位',1 as '宝石孔位',role_id,cast(split_part(gear_punch,',',16) as int) as jewel_level,log_time,
	row_number()over(partition by role_id order by log_time desc ) as row_number
from  myth_server.server_login_snapshot
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
) a
where row_number=1
)
union all 
(select 装备部位,宝石孔位,role_id,jewel_level,log_time
from
(select 6 as '装备部位',2 as '宝石孔位',role_id,cast(split_part(gear_punch,',',17) as int) as jewel_level,log_time,
	row_number()over(partition by role_id order by log_time desc ) as row_number
from  myth_server.server_login_snapshot
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
) a
where row_number=1
)
union all 
(select 装备部位,宝石孔位,role_id,jewel_level,log_time
from
(select 6 as '装备部位',3 as '宝石孔位',role_id,cast(split_part(gear_punch,',',18) as int) as jewel_level,log_time,
	row_number()over(partition by role_id order by log_time desc ) as row_number
from  myth_server.server_login_snapshot
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
) a
where row_number=1
)
union all 
(select 装备部位,宝石孔位,role_id,jewel_level,log_time
from
(select 7 as '装备部位',1 as '宝石孔位',role_id,cast(split_part(gear_punch,',',19) as int) as jewel_level,log_time,
	row_number()over(partition by role_id order by log_time desc ) as row_number
from  myth_server.server_login_snapshot
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
) a
where row_number=1
)
union all 
(select 装备部位,宝石孔位,role_id,jewel_level,log_time
from
(select 7 as '装备部位',2 as '宝石孔位',role_id,cast(split_part(gear_punch,',',20) as int) as jewel_level,log_time,
	row_number()over(partition by role_id order by log_time desc ) as row_number
from  myth_server.server_login_snapshot
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
) a
where row_number=1
)
union all 
(select 装备部位,宝石孔位,role_id,jewel_level,log_time
from
(select 7 as '装备部位',3 as '宝石孔位',role_id,cast(split_part(gear_punch,',',21) as int) as jewel_level,log_time,
	row_number()over(partition by role_id order by log_time desc ) as row_number
from  myth_server.server_login_snapshot
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
) a
where row_number=1
)
union all 
(select 装备部位,宝石孔位,role_id,jewel_level,log_time
from
(select 8 as '装备部位',1 as '宝石孔位',role_id,cast(split_part(gear_punch,',',22) as int) as jewel_level,log_time,
	row_number()over(partition by role_id order by log_time desc ) as row_number
from  myth_server.server_login_snapshot
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
) a
where row_number=1
)
union all 
(select 装备部位,宝石孔位,role_id,jewel_level,log_time
from
(select 8 as '装备部位',2 as '宝石孔位',role_id,cast(split_part(gear_punch,',',23) as int) as jewel_level,log_time,
	row_number()over(partition by role_id order by log_time desc ) as row_number
from  myth_server.server_login_snapshot
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
) a
where row_number=1
)
union all 
(select 装备部位,宝石孔位,role_id,jewel_level,log_time
from
(select 8 as '装备部位',3 as '宝石孔位',role_id,cast(split_part(gear_punch,',',24) as int) as jewel_level,log_time,
	row_number()over(partition by role_id order by log_time desc ) as row_number
from  myth_server.server_login_snapshot
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
) a
where row_number=1
)
union all 
(select 装备部位,宝石孔位,role_id,jewel_level,log_time
from
(select 9 as '装备部位',1 as '宝石孔位',role_id,cast(split_part(gear_punch,',',25) as int) as jewel_level,log_time,
	row_number()over(partition by role_id order by log_time desc ) as row_number
from  myth_server.server_login_snapshot
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
) a
where row_number=1
)
union all 
(select 装备部位,宝石孔位,role_id,jewel_level,log_time
from
(select 9 as '装备部位',2 as '宝石孔位',role_id,cast(split_part(gear_punch,',',26) as int) as jewel_level,log_time,
	row_number()over(partition by role_id order by log_time desc ) as row_number
from  myth_server.server_login_snapshot
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
) a
where row_number=1
)
union all 
(select 装备部位,宝石孔位,role_id,jewel_level,log_time
from
(select 9 as '装备部位',3 as '宝石孔位',role_id,cast(split_part(gear_punch,',',27) as int) as jewel_level,log_time,
	row_number()over(partition by role_id order by log_time desc ) as row_number
from  myth_server.server_login_snapshot
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
) a
where row_number=1
)
) a 
left join  
(select pos_type as '装备部位',hole_id as '宝石孔位',role_id,jewel_level,log_time
from 	
(select pos_type,hole_id,role_id,gem_level as jewel_level,log_time,
	row_number()over(partition by pos_type,hole_id,role_id order by log_time desc ) as row_number
from  myth_server.server_gem_set
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
) a1
where row_number=1
)  b 
on a.role_id=b.role_id and a.装备部位=b.装备部位 and a.宝石孔位=b.宝石孔位
) a 
group by 1,2
order by 1,2
