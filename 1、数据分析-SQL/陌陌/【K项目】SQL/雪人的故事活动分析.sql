

-- 任务   (√)
任务组 ****************************************
SELECT
    a.task_group_id as task_group_id,
    a.task_group_id_num as '接取角色数',
    b.task_group_id_num as '完成角色数',
    b.task_group_id_num / a.task_group_id_num as '任务组完成率'
FROM
    (SELECT
        task_group_id as task_group_id,
        count(distinct role_id) as task_group_id_num
    FROM fairy_town_server.server_task_accept
    WHERE server_id IN (10001,10002,10003)
      and day_time >= 20220127 and day_time <= 20220203
      AND task_group_id IN ('300200','300201','300202','300203','300204','300205','300206','300207','300208','300209','300210','300211','300212','300213','300214',
                            '300215','300216','300217','300218','300219','300220','300221','300222','300223','300224','300225','300226','300227','300228','300229',
                            '300230','300231','300232','300233','300234','300235','300236','300237','300238','300239')
      and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume 
          where map_id = '30020001' and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1643256000000 and log_time <= 1643828400000)
    group by 1
    ) a
left join
    (SELECT
        task_group_id as task_group_id,
        count(distinct role_id) as task_group_id_num
    FROM fairy_town_server.server_task_completed
    WHERE server_id IN (10001,10002,10003)
      and day_time >= 20220127 and day_time <= 20220203
      AND task_group_id IN ('300200','300201','300202','300203','300204','300205','300206','300207','300208','300209','300210','300211','300212','300213','300214',
                            '300215','300216','300217','300218','300219','300220','300221','300222','300223','300224','300225','300226','300227','300228','300229',
                            '300230','300231','300232','300233','300234','300235','300236','300237','300238','300239')
      and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume 
          where map_id = '30020001' and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1643256000000 and log_time <= 1643828400000)
    group by 1
    ) b
on a.task_group_id = b.task_group_id
order by 1



积分任务
SELECT
    a.task_id as task_id,
    a.task_group_id_num as '接取角色数',
    b.task_group_id_num as '完成角色数',
    b.task_group_id_num / a.task_group_id_num as '任务完成率'
FROM
    (SELECT
        task_id as task_id,
        count(distinct role_id) as task_group_id_num
    FROM fairy_town_server.server_task_accept
    WHERE server_id IN (10001,10002,10003)
      and log_time >= 1643256000000 and log_time <= 1643828400000
      AND task_group_id IN ('1003001','1003002','1003003','1003004','1003005','1003006','1003007','1003008','1003009','1003010',
                            '1003011','1003012','1003013','1003014','1003015','1003016','1003017','1003018','1003019','1003020',
                            '1003021','1003022','1003023','1003024','1003025','1003026','1003027')
      and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume 
          where map_id = '30020001' and server_id in (10001,10002,10003) and log_time >= 1643256000000 and log_time <= 1643828400000)
    group by 1
    ) a
left join
    (SELECT
        task_id as task_id,
        count(distinct role_id) as task_group_id_num
    FROM fairy_town_server.server_task_completed
    WHERE server_id IN (10001,10002,10003)
      and log_time >= 1643256000000 and log_time <= 1643828400000
      AND task_group_id IN ('1003001','1003002','1003003','1003004','1003005','1003006','1003007','1003008','1003009','1003010',
                            '1003011','1003012','1003013','1003014','1003015','1003016','1003017','1003018','1003019','1003020',
                            '1003021','1003022','1003023','1003024','1003025','1003026','1003027')
      and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume 
          where map_id = '30020001' and server_id in (10001,10002,10003) and log_time >= 1643256000000 and log_time <= 1643828400000)
    group by 1
    ) b
on a.task_id = b.task_id
order by  1




任务  ****************************************
SELECT
    a.task_id as task_id,
    a.task_group_id_num as '接取角色数',
    b.task_group_id_num as '完成角色数',
    b.task_group_id_num / a.task_group_id_num as '任务完成率'
FROM
    (SELECT
        task_id as task_id,
        count(distinct role_id) as task_group_id_num
    FROM fairy_town_server.server_task_accept
    WHERE server_id IN (10001,10002,10003)
      and log_time >= 1643256000000 and log_time <= 1643828400000
      AND task_group_id IN ('300200','300201','300202','300203','300204','300205','300206','300207','300208','300209','300210','300211','300212','300213','300214',
                            '300215','300216','300217','300218','300219','300220','300221','300222','300223','300224','300225','300226','300227','300228','300229',
                            '300230','300231','300232','300233','300234','300235','300236','300237','300238','300239')
      and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume 
          where map_id = '30020001' and server_id in (10001,10002,10003) and log_time >= 1643256000000 and log_time <= 1643828400000)
    group by 1
    ) a
left join
    (SELECT
        task_id as task_id,
        count(distinct role_id) as task_group_id_num
    FROM fairy_town_server.server_task_completed
    WHERE server_id IN (10001,10002,10003)
      and log_time >= 1643256000000 and log_time <= 1643828400000
      AND task_group_id IN ('300200','300201','300202','300203','300204','300205','300206','300207','300208','300209','300210','300211','300212','300213','300214',
                            '300215','300216','300217','300218','300219','300220','300221','300222','300223','300224','300225','300226','300227','300228','300229',
                            '300230','300231','300232','300233','300234','300235','300236','300237','300238','300239')
      and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume 
          where map_id = '30020001' and server_id in (10001,10002,10003) and log_time >= 1643256000000 and log_time <= 1643828400000)
    group by 1
    ) b
on a.task_id = b.task_id
order by  1






活动奖励领取情况   (√) ****************************************
SELECT 
    building_id,
    count(distinct role_id) as num
FROM 
    fairy_town_server.server_building_get
WHERE building_id in ('4005055','4005056','4005057','4005058','4005059','4005060','4005070','4005071') 
      and server_id in (10001,10002,10003)
      and log_time >= 1643256000000 and log_time <= 1643828400000
GROUP BY 1
order by 1


运营要的
SELECT 装饰物,count(distinct role_id)
from
(SELECT
    role_id,
    case when building_id in ('4005055','4005058') then '可可店'
         when building_id in ('4005056','4005059') then '苹果树'
         when building_id in ('4005057','4005060') then '凯西的蛋糕'
         when building_id in ('4005070','4005071') then '甘薯炉子'
    end as '装饰物'
from 
(SELECT 
    building_id,
    role_id
FROM 
    fairy_town_server.server_building_get
WHERE building_id in ('4005055','4005056','4005057','4005058','4005059','4005060','4005070','4005071') 
      and server_id in (10001,10002,10003)
      and log_time >= 1643256000000 and log_time <= 1643828400000
) as aa
) as bb
group by 1 



积分奖励
SELECT
    building_id,
    count(distinct role_id) as num
from
    fairy_town_server.server_limited_decorations
where building_id in ('4005072','4005073','4005074')
      and server_id in (10001,10002,10003)
      and log_time >= 1643256000000 and log_time <= 1643828400000
GROUP BY 1
order by 1



活动礼包购买行为  (√)  ****************************************
SELECT 
    day_time,
    game_product_id,
    count(game_product_id) as `购买数量`,
    sum(pay_price) as `流水`
FROM 
    fairy_town.order_pay
where game_product_id in ('com.managames.fairytown.iap_3.99ve','com.managames.fairytown.iap_9.99ve','com.managames.fairytown.iap_19.99ve')
and server_id in (10001,10002,10003) and day_time >= 20220127 and day_time <= 20220203
GROUP BY 1,2
ORDER BY 1,2



# 活动收入
—————————————————————————————— 参与 ——————————————————————————————
********************************************************************************

活跃人数
新用户
SELECT count(DISTINCT role_id) FROM fairy_town_server.server_activity_triggered WHERE server_id IN (10001,10002,10003) AND activity_id = 12
AND log_time >= 1643256000000 and log_time <= 1643828400000
AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time >= 1643256000000 and log_time <= 1643828400000) 
and role_id in (select distinct role_id from fairy_town_server.server_physical_consume where map_id = '30020001' and consume_count>0 
                  and server_id in (10001,10002,10003) and log_time >= 1643256000000 and log_time <= 1643828400000)

老用户
SELECT count(DISTINCT role_id) FROM fairy_town_server.server_activity_triggered WHERE server_id IN (10001,10002,10003) AND activity_id = 12
AND log_time >= 1643256000000 and log_time <= 1643828400000
AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time < 1643256000000)
and role_id in (select distinct role_id from fairy_town_server.server_physical_consume where map_id = '30020001' and consume_count>0 
                  and server_id in (10001,10002,10003) and log_time >= 1643256000000 and log_time <= 1643828400000)




当期充值人数
新用户
SELECT count(DISTINCT role_id)
FROM fairy_town.order_pay
WHERE server_id IN (10001,10002,10003)
  AND log_time >= 1643256000000 and log_time <= 1643828400000
  AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time >= 1643256000000 and log_time <= 1643828400000)
  and role_id in (SELECT DISTINCT role_id FROM fairy_town_server.server_activity_triggered WHERE server_id IN (10001,10002,10003) AND activity_id = 12
                AND log_time >= 1643256000000 and log_time <= 1643828400000)
  and role_id in (select distinct role_id from fairy_town_server.server_physical_consume where map_id = '30020001' and consume_count>0 
                  and server_id in (10001,10002,10003) and log_time >= 1643256000000 and log_time <= 1643828400000)
  and product_name <> '战令'


老用户
SELECT count(DISTINCT role_id)
FROM fairy_town.order_pay
WHERE server_id IN (10001,10002,10003)
  AND log_time >= 1643256000000 and log_time <= 1643828400000
  AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time < 1643256000000)
  and role_id in (SELECT DISTINCT role_id FROM fairy_town_server.server_activity_triggered WHERE server_id IN (10001,10002,10003) AND activity_id = 12
                AND log_time >= 1643256000000 and log_time <= 1643828400000)
  and role_id in (select distinct role_id from fairy_town_server.server_physical_consume where map_id = '30020001' and consume_count>0 
                  and server_id in (10001,10002,10003) and log_time >= 1643256000000 and log_time <= 1643828400000)
  and product_name <> '战令'


当期充值金额
新用户
SELECT sum(pay_price)
    FROM fairy_town.order_pay
WHERE server_id IN (10001,10002,10003)
  AND log_time >= 1643256000000 and log_time <= 1643828400000
  AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time >= 1643256000000 and log_time <= 1643828400000)
  and role_id in (SELECT DISTINCT role_id FROM fairy_town_server.server_activity_triggered WHERE server_id IN (10001,10002,10003) AND activity_id = 12
                AND log_time >= 1643256000000 and log_time <= 1643828400000)
  and role_id in (select distinct role_id from fairy_town_server.server_physical_consume where map_id = '30020001' and consume_count>0 
                  and server_id in (10001,10002,10003) and log_time >= 1643256000000 and log_time <= 1643828400000)
  and product_name <> '战令'


老用户
SELECT sum(pay_price)
    FROM fairy_town.order_pay
WHERE server_id IN (10001,10002,10003)
  AND log_time >= 1643256000000 and log_time <= 1643828400000
  AND role_id IN (SELECT distinct role_id FROM fairy_town.server_role_create WHERE log_time < 1643256000000)
  and role_id in (SELECT DISTINCT role_id FROM fairy_town_server.server_activity_triggered WHERE server_id IN (10001,10002,10003) AND activity_id = 12
                AND log_time >= 1643256000000 and log_time <= 1643828400000)
  and role_id in (select distinct role_id from fairy_town_server.server_physical_consume where map_id = '30020001' and consume_count>0 
                  and server_id in (10001,10002,10003) and log_time >= 1643256000000 and log_time <= 1643828400000)
  and product_name <> '战令'






登陆次数  ****************************************
select 
    day_time,
    count(role_id),
    avg(cishu) cishu_avg,
    appx_median(cishu) cishu_median
from
    (select
        day_time,
        role_id,
        count(role_id) as cishu
    from
        fairy_town.server_role_login
    where 
        day_time >= 20220119 and day_time <= 20220203
        and server_id IN (10001,10002,10003)
        and role_id in
        (SELECT
            distinct role_id
         FROM fairy_town_server.server_physical_consume 
         where map_id = '30020001' and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1643256000000 and log_time <= 1643828400000
        )
    group by 1,2
    ) a
group by day_time
order by day_time



在线时长  ****************************************
select
    day_time,
    count(role_id) as role_num,
    avg(num) as num_avg,
    appx_median(num) as num_median
from
(
    SELECT
        role_id,
        day_time,
        count(ping) as num
    from 
        fairy_town.client_online
    where 
        day_time >= 20220119 and day_time <= 20220203
        and server_id IN (10001,10002,10003)
        and role_id in
        (SELECT
            distinct role_id
         FROM fairy_town_server.server_physical_consume 
         where map_id = '30020001' and consume_count > 0 and server_id in (10001,10002,10003) and log_time >= 1643256000000 and log_time <= 1643828400000
        )
    group by 1,2
) a
group by day_time
order by day_time



雪人故事 积分排行榜

SELECT a.role_id,change_sum as '积分数量',activity_group_id as '小组',physical_sum as '活动体力总消耗', 
recovery_count as '免费体力获得',(physical_sum - recovery_count) as '体力净消耗',country as '注册国家',paysum as '历史总付费',pay_2 as '当期付费'   
from

(SELECT role_id,country, sum(change_count) as change_sum from fairy_town.server_prop 
where prop_id = '330101' and change_type = 'PRODUCE' and day_time >= 20220127 and day_time <= 20220203 group by 1,2) as a
left join
(SELECT role_id,activity_group_id from fairy_town_server.server_activity_group WHERE activity_id = 12 GROUP BY 1,2) as b
on a.role_id = b.role_id
left join
(SELECT role_id,sum(physical_consume) as physical_sum   -- 活动体力总消耗
from
(SELECT role_id,consume_count as physical_consume from fairy_town_server.server_physical_consume   -- 采集
where map_id = '30020001'
and server_id in (10001,10002,10003) and role_level >= 10 and log_time >= 1643256000000

union all 

SELECT role_id,consume_physical_count as physical_consume from fairy_town_server.server_hunt       -- 打猎
where map_id = '30020001'
and server_id in (10001,10002,10003) and role_level >= 10 and log_time >= 1643256000000

) a
group by 1
order by 1) as c
on a.role_id = c.role_id
left join
(SELECT role_id,sum(recovery_count) as recovery_count  from fairy_town_server.server_physical_recovery
where log_time >= 1643256000000 and log_time <= 1643828400000
and server_id in (10001,10002,10003) and role_level >= 10  
and role_id in (SELECT distinct role_id FROM fairy_town_server.server_physical_consume where map_id = '30020001'
                and server_id in (10001,10002,10003) and log_time >= 1643256000000)
and recovery_method in ('4','5','6','13','14','15','17','19','20','22','23','27','28','29','67','71','72','75','77','78','80','83','88','90','91','93',
                        '94','97','101','108','111','116','118','119')
-- and role_id in (select distinct role_id from fairy_town.order_pay WHERE server_id IN (10001,10002,10003) and log_time < 1643828400000)
group by 1 order by 1) as d
on a.role_id = d.role_id
left join 
(select role_id,sum(pay_price) as paysum from fairy_town.order_pay where log_time <=1643828400000  group by 1) as f 
on a.role_id = f.role_id
left join 
(select role_id,sum(pay_price) as pay_2 from fairy_town.order_pay where day_time >= ${d1} and day_time <= ${d2} group by 1) as g 
on a.role_id = g.role_id

GROUP BY 1,2,3,4,5,6,7,8,9