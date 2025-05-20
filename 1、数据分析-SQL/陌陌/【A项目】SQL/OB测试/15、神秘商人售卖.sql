---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

神秘商人物品售卖情况


生命周期维度


select datediff(pay_dt,birth_dt)+1 as '天数',商品名称,count(distinct a.role_id) as '购买人数',
sum(change_count) as '购买数量'
from 
(  --新增
select role_id,birth_dt
from
(select role_id,device_id,to_date(date_time) as birth_dt
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id in (1000,2000)
and version_name = '1.5.0'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(date_time) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id in (1000,2000)
and version_name = '1.5.0'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id --and a1.birth_dt = a2.device_birth_dt
group by 1,2
)  a

left join


(select to_date(date_time) as pay_dt,case get_prop_id
when '105131'  then '10级金币神秘装备箱'
when '105132'  then '20级金币神秘装备箱'
when '105133'  then '30级金币神秘装备箱'
when '105134'  then '40级金币神秘装备箱'
when '105135'  then '50级金币神秘装备箱'
when '105136'  then '60级金币神秘装备箱'
when '105137'  then '70级金币神秘装备箱'
when '105138'  then '80级金币神秘装备箱'
when '105139'  then '90级金币神秘装备箱'
when '105140'  then '100级金币神秘装备箱'
when '105141'  then '110级金币神秘装备箱'
when '105142'  then '120级金币神秘装备箱'
when '105143'  then '130级金币神秘装备箱'
when '105144'  then '140级金币神秘装备箱'
when '105145'  then '150级金币神秘装备箱'
when '105146'  then '160级金币神秘装备箱'
when '105147'  then '170级金币神秘装备箱'
when '105148'  then '180级金币神秘装备箱'
when '105149'  then '190级金币神秘装备箱'
when '105150'  then '200级金币神秘装备箱'
when '105151'  then '210级金币神秘装备箱'
when '105152'  then '220级金币神秘装备箱'
when '105153'  then '230级金币神秘装备箱'
when '105154'  then '240级金币神秘装备箱'
when '105155'  then '250级金币神秘装备箱'
when '105156'  then '260级金币神秘装备箱'
when '105157'  then '270级金币神秘装备箱'
when '105158'  then '280级金币神秘装备箱'
when '105159'  then '290级金币神秘装备箱'
when '105160'  then '300级金币神秘装备箱'
when '105161'  then '10级神秘武器箱'
when '105162'  then '20级神秘武器箱'
when '105163'  then '30级神秘武器箱'
when '105164'  then '40级神秘武器箱'
when '105165'  then '50级神秘武器箱'
when '105166'  then '60级神秘武器箱'
when '105167'  then '70级神秘武器箱'
when '105168'  then '80级神秘武器箱'
when '105169'  then '90级神秘武器箱'
when '105170'  then '100级神秘武器箱'
when '105171'  then '110级神秘武器箱'
when '105172'  then '120级神秘武器箱'
when '105173'  then '130级神秘武器箱'
when '105174'  then '140级神秘武器箱'
when '105175'  then '150级神秘武器箱'
when '105176'  then '160级神秘武器箱'
when '105177'  then '170级神秘武器箱'
when '105178'  then '180级神秘武器箱'
when '105179'  then '190级神秘武器箱'
when '105180'  then '200级神秘武器箱'
when '105181'  then '210级神秘武器箱'
when '105182'  then '220级神秘武器箱'
when '105183'  then '230级神秘武器箱'
when '105184'  then '240级神秘武器箱'
when '105185'  then '250级神秘武器箱'
when '105186'  then '260级神秘武器箱'
when '105187'  then '270级神秘武器箱'
when '105188'  then '280级神秘武器箱'
when '105189'  then '290级神秘武器箱'
when '105190'  then '300级神秘武器箱'
when '105101'  then '10级钻石神秘防具箱'
when '105102'  then '20级钻石神秘防具箱'
when '105103'  then '30级钻石神秘防具箱'
when '105104'  then '40级钻石神秘防具箱'
when '105105'  then '50级钻石神秘防具箱'
when '105106'  then '60级钻石神秘防具箱'
when '105107'  then '70级钻石神秘防具箱'
when '105108'  then '80级钻石神秘防具箱'
when '105109'  then '90级钻石神秘防具箱'
when '105110'  then '100级钻石神秘防具箱'
when '105111'  then '110级钻石神秘防具箱'
when '105112'  then '120级钻石神秘防具箱'
when '105113'  then '130级钻石神秘防具箱'
when '105114'  then '140级钻石神秘防具箱'
when '105115'  then '150级钻石神秘防具箱'
when '105116'  then '160级钻石神秘防具箱'
when '105117'  then '170级钻石神秘防具箱'
when '105118'  then '180级钻石神秘防具箱'
when '105119'  then '190级钻石神秘防具箱'
when '105120'  then '200级钻石神秘防具箱'
when '105121'  then '210级钻石神秘防具箱'
when '105122'  then '220级钻石神秘防具箱'
when '105123'  then '230级钻石神秘防具箱'
when '105124'  then '240级钻石神秘防具箱'
when '105125'  then '250级钻石神秘防具箱'
when '105126'  then '260级钻石神秘防具箱'
when '105127'  then '270级钻石神秘防具箱'
when '105128'  then '280级钻石神秘防具箱'
when '105129'  then '290级钻石神秘防具箱'
when '105130'  then '300级钻石神秘防具箱'
when '100502'  then '神系秘钥'
when '100530'  then  '命运银币'
when '100503'  then  '魔法神力碎片'
when '100504'  then  '稀有神力碎片'
when '100564'  then  '命运紫晶币'
when '100523'  then  '精金'
when '100083'  then  '3级随机宝石'
when '100062'  then  '2级原始符石'
when '100552'  then  '宠物蛋'
when '100356'  then  '1000万金币'
when '100565'  then '奥丁神系秘钥'
when '100566'  then '希芙神系秘钥'
when '100567'  then '弗丽嘉神系秘钥'
when '100568'  then '海姆达尔神系秘钥'
when '100569'  then '巴德尔神系秘钥'
when '100570'  then '瓦尔基里神系秘钥'
when '100505'  then '精品奥丁神力碎片'
when '100506'  then '精品希芙神力碎片'
when '100507'  then '精品弗丽嘉神力碎片'
when '100508'  then '精品海姆达尔神力碎片'
when '100509'  then '精品巴德尔神力碎片'
when '100510'  then '精品瓦尔基里神力碎片'
when '100511'  then '稀有奥丁神力碎片'
when '100512'  then '稀有希芙神力碎片'
when '100513'  then '稀有弗丽嘉神力碎片'
when '100514'  then '稀有海姆达尔神力碎片'
when '100515'  then '稀有巴德尔神力碎片'
when '100516'  then '稀有瓦尔基里神力碎片'
when '100564'  then '命运紫晶币'
when '100531'  then '命运金币'
when '100701'  then '布里希加曼(碎片)'
when '100702'  then '德罗普尼尔(碎片)'
when '100703'  then '加拉尔(碎片)'
when '100704'  then '艾瑞尼尔(碎片)'
when '100705'  then '仙酒(碎片)'
when '100706'  then '燧石巨棒(碎片)'
when '100707'  then '黄金竖琴(碎片)'
when '100708'  then '铁手套(碎片)'
when '100709'  then '神圣法典(碎片)'
when '100711'  then '青春苹果(碎片)'
else get_prop_id
end as '商品名称',
role_id,
sum(cast(get_prop_num as int)) as change_count
from myth_server.server_mall_buy
where day_time between ${beginDate} and ${endDate}
and channel_id in (1000,2000)
and server_id     in (${serverIds})
--and mall_type=13
and mall_type = 1
and cost_currency_id = 3
and version_name='1.5.0'
group by 1,2,3
) b 
on a.role_id = b.role_id
where b.role_id is not null 
and datediff(pay_dt,birth_dt)<${lifeTime}
group by  1,2 










活跃维度
select day_time,case prop_id
when '105131'  then '10级金币神秘装备箱'
when '105132'  then '20级金币神秘装备箱'
when '105133'  then '30级金币神秘装备箱'
when '105134'  then '40级金币神秘装备箱'
when '105135'  then '50级金币神秘装备箱'
when '105136'  then '60级金币神秘装备箱'
when '105137'  then '70级金币神秘装备箱'
when '105138'  then '80级金币神秘装备箱'
when '105139'  then '90级金币神秘装备箱'
when '105140'  then '100级金币神秘装备箱'
when '105141'  then '110级金币神秘装备箱'
when '105142'  then '120级金币神秘装备箱'
when '105143'  then '130级金币神秘装备箱'
when '105144'  then '140级金币神秘装备箱'
when '105145'  then '150级金币神秘装备箱'
when '105146'  then '160级金币神秘装备箱'
when '105147'  then '170级金币神秘装备箱'
when '105148'  then '180级金币神秘装备箱'
when '105149'  then '190级金币神秘装备箱'
when '105150'  then '200级金币神秘装备箱'
when '105151'  then '210级金币神秘装备箱'
when '105152'  then '220级金币神秘装备箱'
when '105153'  then '230级金币神秘装备箱'
when '105154'  then '240级金币神秘装备箱'
when '105155'  then '250级金币神秘装备箱'
when '105156'  then '260级金币神秘装备箱'
when '105157'  then '270级金币神秘装备箱'
when '105158'  then '280级金币神秘装备箱'
when '105159'  then '290级金币神秘装备箱'
when '105160'  then '300级金币神秘装备箱'
when '105161'  then '10级神秘武器箱'
when '105162'  then '20级神秘武器箱'
when '105163'  then '30级神秘武器箱'
when '105164'  then '40级神秘武器箱'
when '105165'  then '50级神秘武器箱'
when '105166'  then '60级神秘武器箱'
when '105167'  then '70级神秘武器箱'
when '105168'  then '80级神秘武器箱'
when '105169'  then '90级神秘武器箱'
when '105170'  then '100级神秘武器箱'
when '105171'  then '110级神秘武器箱'
when '105172'  then '120级神秘武器箱'
when '105173'  then '130级神秘武器箱'
when '105174'  then '140级神秘武器箱'
when '105175'  then '150级神秘武器箱'
when '105176'  then '160级神秘武器箱'
when '105177'  then '170级神秘武器箱'
when '105178'  then '180级神秘武器箱'
when '105179'  then '190级神秘武器箱'
when '105180'  then '200级神秘武器箱'
when '105181'  then '210级神秘武器箱'
when '105182'  then '220级神秘武器箱'
when '105183'  then '230级神秘武器箱'
when '105184'  then '240级神秘武器箱'
when '105185'  then '250级神秘武器箱'
when '105186'  then '260级神秘武器箱'
when '105187'  then '270级神秘武器箱'
when '105188'  then '280级神秘武器箱'
when '105189'  then '290级神秘武器箱'
when '105190'  then '300级神秘武器箱'
when '105101'  then '10级钻石神秘防具箱'
when '105102'  then '20级钻石神秘防具箱'
when '105103'  then '30级钻石神秘防具箱'
when '105104'  then '40级钻石神秘防具箱'
when '105105'  then '50级钻石神秘防具箱'
when '105106'  then '60级钻石神秘防具箱'
when '105107'  then '70级钻石神秘防具箱'
when '105108'  then '80级钻石神秘防具箱'
when '105109'  then '90级钻石神秘防具箱'
when '105110'  then '100级钻石神秘防具箱'
when '105111'  then '110级钻石神秘防具箱'
when '105112'  then '120级钻石神秘防具箱'
when '105113'  then '130级钻石神秘防具箱'
when '105114'  then '140级钻石神秘防具箱'
when '105115'  then '150级钻石神秘防具箱'
when '105116'  then '160级钻石神秘防具箱'
when '105117'  then '170级钻石神秘防具箱'
when '105118'  then '180级钻石神秘防具箱'
when '105119'  then '190级钻石神秘防具箱'
when '105120'  then '200级钻石神秘防具箱'
when '105121'  then '210级钻石神秘防具箱'
when '105122'  then '220级钻石神秘防具箱'
when '105123'  then '230级钻石神秘防具箱'
when '105124'  then '240级钻石神秘防具箱'
when '105125'  then '250级钻石神秘防具箱'
when '105126'  then '260级钻石神秘防具箱'
when '105127'  then '270级钻石神秘防具箱'
when '105128'  then '280级钻石神秘防具箱'
when '105129'  then '290级钻石神秘防具箱'
when '105130'  then '300级钻石神秘防具箱'
when '100502'  then '神系秘钥'
when '100530'  then  '命运银币'
when '100503'  then  '魔法神力碎片'
when '100504'  then  '稀有神力碎片'
when '100564'  then  '命运紫晶币'
when '100523'  then  '精金'
when '100083'  then  '3级随机宝石'
when '100062'  then  '2级原始符石'
when '100552'  then  '宠物蛋'
when '100356'  then  '1000万金币'
when '100565'  then '奥丁神系秘钥'
when '100566'  then '希芙神系秘钥'
when '100567'  then '弗丽嘉神系秘钥'
when '100568'  then '海姆达尔神系秘钥'
when '100569'  then '巴德尔神系秘钥'
when '100570'  then '瓦尔基里神系秘钥'
when '100505'  then '精品奥丁神力碎片'
when '100506'  then '精品希芙神力碎片'
when '100507'  then '精品弗丽嘉神力碎片'
when '100508'  then '精品海姆达尔神力碎片'
when '100509'  then '精品巴德尔神力碎片'
when '100510'  then '精品瓦尔基里神力碎片'
when '100511'  then '稀有奥丁神力碎片'
when '100512'  then '稀有希芙神力碎片'
when '100513'  then '稀有弗丽嘉神力碎片'
when '100514'  then '稀有海姆达尔神力碎片'
when '100515'  then '稀有巴德尔神力碎片'
when '100516'  then '稀有瓦尔基里神力碎片'
when '100564'  then '命运紫晶币'
when '100531'  then '命运金币'
when '100701'  then '布里希加曼(碎片)'
when '100702'  then '德罗普尼尔(碎片)'
when '100703'  then '加拉尔(碎片)'
when '100704'  then '艾瑞尼尔(碎片)'
when '100705'  then '仙酒(碎片)'
when '100706'  then '燧石巨棒(碎片)'
when '100707'  then '黄金竖琴(碎片)'
when '100708'  then '铁手套(碎片)'
when '100709'  then '神圣法典(碎片)'
when '100711'  then '青春苹果(碎片)'
end as '商品名称'
 ,sum(change_count) as '购买数量'
from myth.server_prop 
where day_time between ${beginDate} and ${endDate}
and channel_id in (1000,2000)
and server_id     in (${serverIds})
and change_method = '10'
and prop_id in (
'105131',
'105132',
'105133',
'105134',
'105135',
'105136',
'105137',
'105138',
'105139',
'105140',
'105141',
'105142',
'105143',
'105144',
'105145',
'105146',
'105147',
'105148',
'105149',
'105150',
'105151',
'105152',
'105153',
'105154',
'105155',
'105156',
'105157',
'105158',
'105159',
'105160',
'105161',
'105162',
'105163',
'105164',
'105165',
'105166',
'105167',
'105168',
'105169',
'105170',
'105171',
'105172',
'105173',
'105174',
'105175',
'105176',
'105177',
'105178',
'105179',
'105180',
'105181',
'105182',
'105183',
'105184',
'105185',
'105186',
'105187',
'105188',
'105189',
'105190',
'105101',
'105102',
'105103',
'105104',
'105105',
'105106',
'105107',
'105108',
'105109',
'105110',
'105111',
'105112',
'105113',
'105114',
'105115',
'105116',
'105117',
'105118',
'105119',
'105120',
'105121',
'105122',
'105123',
'105124',
'105125',
'105126',
'105127',
'105128',
'105129',
'105130',
'100565',
'100566',
'100567',
'100568',
'100569',
'100570',
'100505',
'100506',
'100507',
'100508',
'100509',
'100510',
'100511',
'100512',
'100513',
'100514',
'100515',
'100516',
'100564',
'100531',
'100701',
'100702',
'100703',
'100704',
'100705',
'100706',
'100707',
'100708',
'100709',
'100711')
and change_type = 'PRODUCE'
group by 1,2