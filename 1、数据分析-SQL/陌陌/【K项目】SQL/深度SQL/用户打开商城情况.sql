select t1.day_time as '日期',
count(distinct t1.user_id) as '打开商城账户数',
count(distinct t2.user_id) as '付费账户数',
sum(花费金额) as '总付费金额',
round(count(distinct t2.user_id)/count(distinct t1.user_id)*100,2) as '打开商城并付费用户比例%',
count(distinct t1.user_id)-count(distinct t2.user_id) as '打开商城没付费用户数',
round(sum(账户打开商城次数)/count(distinct t1.user_id),2) as '账户平均打开商城次数',
round(sum(账户付费次数)/count(distinct t2.user_id),2) as '账户平均付费次数',
round(sum(花费金额)/count(distinct t2.user_id),2) as '账户平均付费金额',
round(sum(账户付费次数)/sum(账户打开商城次数)*100,2) as '付费次数与打开商城次数比例%'
from
(
SELECT day_time, user_id, count(1) as '账户打开商城次数'
FROM fairy_town_server.server_open_mall_panel 
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by day_time, user_id
)t1 left join
(
select day_time, user_id, count(1) as '账户付费次数', sum(pay_price) as '花费金额'
from fairy_town.order_pay
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by day_time, user_id
)t2 on t1.day_time=t2.day_time and t1.user_id=t2.user_id
group by t1.day_time
order by 日期
