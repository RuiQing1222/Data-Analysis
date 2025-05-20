各国家、各渠道新增付费
分国家付费留存
select
	q.day_time_a as day_time,
	sum(case when by_day = 0 then 1 else 0 end) '老用户付费人数',
    sum(case when by_day = 1 then 1 else 0 end) day_2,
    sum(case when by_day = 2 then 1 else 0 end) day_3,
    sum(case when by_day = 3 then 1 else 0 end) day_4,
    sum(case when by_day = 4 then 1 else 0 end) day_5,
    sum(case when by_day = 5 then 1 else 0 end) day_6,
    sum(case when by_day = 6 then 1 else 0 end) day_7,
    sum(case when by_day = 7 then 1 else 0 end) day_8,
    sum(case when by_day = 8 then 1 else 0 end) day_9,
    sum(case when by_day = 9 then 1 else 0 end) day_10,
    sum(case when by_day = 10 then 1 else 0 end) day_11,
    sum(case when by_day = 11 then 1 else 0 end) day_12,
    sum(case when by_day = 12 then 1 else 0 end) day_13,
    sum(case when by_day = 13 then 1 else 0 end) day_14,
    sum(case when by_day = 14 then 1 else 0 end) day_15,
    sum(case when by_day = 15 then 1 else 0 end) day_16,
    sum(case when by_day = 16 then 1 else 0 end) day_17,
    sum(case when by_day = 17 then 1 else 0 end) day_18,
    sum(case when by_day = 18 then 1 else 0 end) day_19,
    sum(case when by_day = 29 then 1 else 0 end) day_20
from
(
	select 
		device_id_a as device_id,
		day_time_a,-- first_day
		day_time_b,
		datediff(day_time_b,day_time_a) as by_day -- 间隔
	from
		(select 
			b.device_id as device_id_b,
			a.device_id as device_id_a,
			a.day_times as day_time_a,
			b.day_times as day_time_b
		from
			 (
			 select 
				device_id,
				to_date(cast(date_time as timestamp)) as day_times 
			 from fairy_town.device_launch
			 where day_time >= ${start_time} and day_time <= ${endDate}
			 group by 1,2
			) b 
		right join 
			(select to_date(cast(date_time as timestamp)) as day_times,c.device_id as device_id from
			(select date_time,day_time,device_id from fairy_town.order_pay where (day_time>=20211017  and day_time<=20211021) or (day_time>=20211118 and day_time<=20211124) 
	                                                                             or (day_time>=20211204 and day_time<=20211208) or (day_time>=20220105 and day_time<=20220109)
 														                         and server_id in (10001,10002,10003)) c
			left join 
			(select day_time,device_id from fairy_town.device_activate) d
			on c.day_time = d.day_time and c.device_id = d.device_id where d.device_id is null
			group by 1,2
			order by 1
			) a
			on a.device_id = b.device_id
		) as reu
	order by device_id_b,day_time_b		 
) as q

group by 1
order by 1




每天新付费用户数
select a.day_time,count(distinct a.device_id) from
(select day_time,device_id from fairy_town.order_pay where (day_time>=20211017  and day_time<=20211021) or (day_time>=20211118 and day_time<=20211124) 
	                                                       or (day_time>=20211204 and day_time<=20211208) or (day_time>=20220105 and day_time<=20220109)
 														   and server_id in (10001,10002,10003)) a
join 
(select day_time,device_id from fairy_town.device_activate where day_time >= ${start_time}) b
on a.day_time = b.day_time and a.device_id = b.device_id
group by 1
order by 1

每天老付费用户
select a.day_time,count(distinct a.device_id) from
(select day_time,device_id from fairy_town.order_pay where (day_time>=20211017  and day_time<=20211021) or (day_time>=20211118 and day_time<=20211124) 
	                                                       or (day_time>=20211204 and day_time<=20211208) or (day_time>=20220105 and day_time<=20220109)
 														   and server_id in (10001,10002,10003)) a
left join 
(select day_time,device_id from fairy_town.device_activate) b
on a.day_time = b.day_time and a.device_id = b.device_id where b.device_id is null
group by 1
order by 1




老付费用户宽表
select day_time,q.role_id, m_day,sum_pay,map_id,physical,gold,gem,bomb 
from
(select a.day_time as day_time,a.role_id as role_id from -- 每天老付费用户
(select day_time,role_id from fairy_town.order_pay where (day_time>=20211017  and day_time<=20211021) or (day_time>=20211118 and day_time<=20211124) 
	                                                       or (day_time>=20211204 and day_time<=20211208) or (day_time>=20220105 and day_time<=20220111)
 														   and server_id in (10001,10002,10003)
 														   ) a
left join 
(select day_time,role_id from fairy_town.server_role_create where day_time>=20210420 and day_time<=20220111) b
on a.day_time = b.day_time and a.role_id = b.role_id where b.role_id is null
) q


-- left join -- 最后登录时间 留存流失
-- (select device_id,max(day_time) as m_day from fairy_town.server_role_login group by 1) w
-- on q.device_id = w.device_id

-- left join -- 历史付费 大小R
-- (select device_id,sum(pay_price) as sum_pay from fairy_town.order_pay where server_id in (10001,10002,10003) and day_time>=20210420 and day_time<=20220111 group by 1) e
-- on q.device_id = e.device_id

-- left join -- 目前关卡
-- (select device_id,map_id from
-- (select device_id,max(cast(map_id as int)) as map_id
-- from fairy_town_server.server_map_enter where server_id in (10001,10002,10003) and day_time>=20210420 and day_time<=20220111 
-- and map_id in ('10001','20001','30001','30002','40001','50001','50002','60001','70001','80001','90001','100001','110001','120001','130001',
-- '140001','150001','160001','180001','190001','200001','210001') group by 1) as n
-- ) r
-- on q.device_id = r.device_id

left join -- 登录快照 体力 金币 钻石 炸弹
(select role_id,day_time, physical,gold,gem,bomb
from fairy_town_server.server_login_snap_shot where server_id in (10001,10002,10003)) y
on q.day_time = y.day_time and q.role_id = y.role_id

group by 1,2,3,4,5,6,7,8,9,10,11
order by 1




-- 礼包购买
select day_time,game_product_id,product_name,count(1) as '购买次数',count(distinct role_id) as '购买人数',sum(pay_price) as '购买金额' from fairy_town.order_pay 
where day_time>=20211017 and day_time <= 20220111 and server_id in (10001,10002,10003)
and role_id in 
(select distinct role_id
from
(select a.role_id as role_id from -- 每天老付费用户
(select day_time,role_id from fairy_town.order_pay where (day_time>=20211017  and day_time<=20211021) or (day_time>=20211118 and day_time<=20211124) 
	                                                       or (day_time>=20211204 and day_time<=20211208) or (day_time>=20220105 and day_time<=20220111)
 														   and server_id in (10001,10002,10003)
 														   ) a
left join 
(select day_time,role_id from fairy_town.server_role_create where day_time>=20210420 and day_time<=20220111) b
on a.day_time = b.day_time and a.role_id = b.role_id where b.role_id is null
) aa 
)
group by 1,2,3
order by 1



select q.day_time,q.role_id,map_id
from

(select a.day_time as day_time,a.role_id as role_id from -- 每天老付费用户
(select day_time,role_id from fairy_town.order_pay where (day_time>=20211017  and day_time<=20211021) or (day_time>=20211118 and day_time<=20211124) 
	                                                       or (day_time>=20211204 and day_time<=20211208) or (day_time>=20220105 and day_time<=20220111)
 														   and server_id in (10001,10002,10003)
 														   ) a
left join 
(select day_time,role_id from fairy_town.server_role_create where day_time>=20210420 and day_time<=20220111 and server_id in (10001,10002,10003)) b
on a.day_time = b.day_time and a.role_id = b.role_id where b.role_id is null
) q

left join -- 目前关卡
(select role_id,day_time, map_id from
(select role_id,day_time, max(cast(map_id as int)) as map_id
from fairy_town_server.server_map_enter where server_id in (10001,10002,10003)
and map_id in ('10001','20001','30001','30002','40001','50001','50002','60001','70001','80001','90001','100001','110001','120001','130001',
'140001','150001','160001','180001','190001','200001','210001') group by 1,2) as n
) r
on q.day_time = r.day_time and q.role_id = r.role_id
group by 1,2,3
order by 1

