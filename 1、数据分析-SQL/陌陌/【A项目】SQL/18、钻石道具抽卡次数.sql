select gacha_id as '卡池编号',
count(distinct case when gem_ten_gacha>0 then l1.role_id else null end ) as '钻石十连抽角色数',
round(avg(gem_ten_gacha),2) as '平均角色十连抽取次数',
count(distinct case when gem_one_gacha>0 then l1.role_id else null end ) as '钻石单抽角色数',
round(avg(gem_one_gacha),2) as '平均角色单抽取次数',
count(distinct case when item_ten_gacha>0 then l1.role_id else null end ) as '道具十连抽角色数',
round(avg(item_ten_gacha),2) as '平均角色十连抽取次数',
count(distinct case when item_one_gacha>0 then l1.role_id else null end ) as '道具单抽角色数',
round(avg(item_one_gacha),2) as '平均角色单抽取次数'
from
(select gacha_id,role_id,
count(case when gacha_mode=1 and consume_currency_id=3 then card_id else null end) as gem_one_gacha,
count(case when gacha_mode=2 and consume_currency_id=3 then card_id else null end) as gem_ten_gacha,
count(case when gacha_mode=1 and consume_prop_id in (100501,100502) then card_id else null end) as item_one_gacha,
count(case when gacha_mode=2 and consume_prop_id in (100501,100502) then card_id else null end) as item_ten_gacha
from myth_server.server_card_gacha 
where  day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
group by 1,2 
) l1
group by 1
order by 1,2