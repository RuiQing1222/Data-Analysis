---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
1、1 KPI——新增、留存  市场投放——BI新增、留存 （整体、付费、免费）
22001,22002,22003,22004,22005,22006,22007,22008,22009,22010,22011,22012,22013,22014,22015,22016
国家
GB+CA+IE+AU
NO+SE+FI+DK
PH
MY
ID 
FR

select birth_dt,channel_id,datediff(login_dt,birth_dt) as datediffs,country,广告类型,素材名称,投放方式,
       case when af_ad ='APP_INSTALLS' then '广告量'
       else '自然量'
       end as '用户分类',
       case when c.device_id is null   then '免费'
            else '付费'
            end as pay_or_not,
     count(distinct a.device_id)
from 
(select to_date(cast (date_time as timestamp)) as birth_dt,channel_id,device_id, -- 新增
case when country = 'US'  then  'US'
     when country in ('FR','DE','CA','GB','IE','AU','NZ','NO','SE','DK','FI','SG','AT','CZ','PL','SK') then 'T2'
     when country in ('IT','ES','PH','TH','MY','ID','BR','AR','PE','CL','AL','BG','HR','CY','GR','HU','RO','RS','SI','TR','MK') then 'T3'
else 'others'
end as country
from myth.device_activate
where day_time between ${beginDate} and ${endDate}
and channel_id  in (1000,2000)  
and version_name = '1.5.0'
group by 1,2,3,4) a 

left join 
(select customer_user_id,  -- 广告
case when split_part(af_adset,'-',5) ='ARPG'                    then 'ARPG'
     when split_part(af_adset,'-',5) ='Games'                   then 'Games'
     when split_part(af_adset,'-',5) in('RPG','RPG&Card')       then 'RPG'
   --  when split_part(af_adset,'-',5)='SLG'                      then 'SLG'
   --  when split_part(af_adset,'-',5)='卡牌'                     then '卡牌'
   --  when split_part(af_adset,'-',5)='PurchaseLAL3%'            then 'PurchaseLAL'
   --  when split_part(af_adset,'-',5)=''                         then '未知'
   --  when af_adset is null then '自然量'
     else  '未知'
     end  as '广告类型',
case when split_part(af_adset,'-',4) ='AEO'         then 'AEO'
     when split_part(af_adset,'-',4) ='MAI'         then 'MAI'
     --when split_part(af_adset,'-',4) =''            then '未知'
     else  '未知'
     end  as '投放方式',
case when split_part(af_adset,'-',9) in ('Boss战斗','Build类','割草战斗') 
     then split_part(af_adset,'-',11)
     when  split_part(af_adset,'-',10) in ('20210624','20221207','20230206','20230209','20230224','210624','20220613','20210624','20230418')
     then split_part(af_adset,'-',11)
     else split_part(af_adset,'-',10)
     end as '素材名称',af_ad
from myth.af_push
where day_time between ${beginDate} and ${endDate}
group by 1,2,3,4,5) b 
on a.device_id=customer_user_id

left join
(select device_id,to_date(cast (date_time as timestamp)) as pay_dt --付费
from myth.order_pay
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id  in (1000,2000)  

) as c
on a.device_id = c.device_id and a.birth_dt = c.pay_dt

left join  -- 留存
(select to_date(cast (date_time as timestamp)) as login_dt,device_id
from myth.device_launch
where day_time between ${beginDate} and ${end2Date} 
and channel_id  in (1000,2000)  
and version_name = '1.5.0'

group by 1,2
) d 
on a.device_id=d.device_id
where login_dt>=birth_dt
group by 1,2,3,4,5,6,7,8,9






1、2 KPI——ARPU、ARPPU、PR -- 新增口径 市场投放 ARPU、ARPPU、PR
select birth_dt,channel_id,country,广告类型,素材名称,投放方式,
       case when af_ad ='APP_INSTALLS' then '广告量'
       else '自然量'
       end as '用户分类',
       count(distinct a.device_id) as '新增',
       sum(case when datediff(pay_dt,birth_dt)=0 then pay_price end) as '第一天付费总收入',
       sum(case when datediff(pay_dt,birth_dt)<=1 then pay_price end) as '前二天付费总收入',
       sum(case when datediff(pay_dt,birth_dt)<=2 then pay_price end) as '前三天付费总收入',
       sum(case when datediff(pay_dt,birth_dt)<=3 then pay_price end) as '前四天付费总收入',
       sum(case when datediff(pay_dt,birth_dt)<=4 then pay_price end) as '前五天付费总收入',
       sum(case when datediff(pay_dt,birth_dt)<=5 then pay_price end) as '前六天付费总收入',
       sum(case when datediff(pay_dt,birth_dt)<=6 then pay_price end) as '前七天付费总收入',
       sum(case when datediff(pay_dt,birth_dt)<=13 then pay_price end) as '前十四天付费总收入',
       sum(case when datediff(pay_dt,birth_dt)<=29 then pay_price end) as '前三十天付费总收入' 
       count(distinct case when datediff(pay_dt,birth_dt)=0   then b.device_id end) as '第一天新增付费用户数',
       count(distinct case when datediff(pay_dt,birth_dt)<=1  then b.device_id end) as '前二天新增付费用户数',
       count(distinct case when datediff(pay_dt,birth_dt)<=2  then b.device_id end) as '前三天新增付费用户数',
       count(distinct case when datediff(pay_dt,birth_dt)<=3  then b.device_id end) as '前四天新增付费用户数',
       count(distinct case when datediff(pay_dt,birth_dt)<=4  then b.device_id end) as '前五天新增付费用户数',
       count(distinct case when datediff(pay_dt,birth_dt)<=5  then b.device_id end) as '前六天新增付费用户数',
       count(distinct case when datediff(pay_dt,birth_dt)<=6  then b.device_id end) as '前七天新增付费用户数',
       count(distinct case when datediff(pay_dt,birth_dt)<=13 then b.device_id end) as '前十四天新增付费用户数',
       count(distinct case when datediff(pay_dt,birth_dt)<=29 then b.device_id end) as '前三十天新增付费用户数' 
from

(  --新增
select device_id,to_date(cast(date_time as timestamp)) as birth_dt,channel_id,
case when country = 'US'  then  'US'
     when country in ('FR','DE','CA','GB','IE','AU','NZ','NO','SE','DK','FI','SG','AT','CZ','PL','SK') then 'T2'
     when country in ('IT','ES','PH','TH','MY','ID','BR','AR','PE','CL','AL','BG','HR','CY','GR','HU','RO','RS','SI','TR','MK') then 'T3'
else 'others'
end as country
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id  in (1000,2000)  
and version_name = '1.5.0'
) as a

left join
(select device_id,pay_price,to_date(cast (date_time as timestamp)) as pay_dt --付费
from myth.order_pay
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id  in (1000,2000)  
and country not in ('CN','HK')
) as b
on a.device_id = b.device_id

left join 
(select customer_user_id,  -- 广告
case when split_part(af_adset,'-',5) ='ARPG'                    then 'ARPG'
     when split_part(af_adset,'-',5) ='Games'                   then 'Games'
     when split_part(af_adset,'-',5) in('RPG','RPG&Card')       then 'RPG'
   --  when split_part(af_adset,'-',5)='SLG'                      then 'SLG'
   --  when split_part(af_adset,'-',5)='卡牌'                     then '卡牌'
   --  when split_part(af_adset,'-',5)='PurchaseLAL3%'            then 'PurchaseLAL'
   --  when split_part(af_adset,'-',5)=''                         then '未知'
   --  when af_adset is null then '自然量'
     else  '未知'
     end  as '广告类型',
case when split_part(af_adset,'-',4) ='AEO'         then 'AEO'
     when split_part(af_adset,'-',4) ='MAI'         then 'MAI'
     --when split_part(af_adset,'-',4) =''            then '未知'
     else  '未知'
     end  as '投放方式',
case when split_part(af_adset,'-',9) in ('Boss战斗','Build类','割草战斗') 
     then split_part(af_adset,'-',11)
     when  split_part(af_adset,'-',10) in ('20210624','20221207','20230206','20230209','20230224','210624','20220613','20210624','20230418','20221103')
     then split_part(af_adset,'-',11)
     else split_part(af_adset,'-',10)
     end as '素材名称',af_ad
from myth.af_push
where day_time between ${beginDate} and ${endDate}
group by 1,2,3,4,5) c 
on a.device_id=customer_user_id
group by 1,2,3,4,5,6,7
order by 1



=IF(OR(D2="AU",D2="NZ"),"Oceania",IF(D2="CA","CA",IF(D2=$D$35,$D$35,IF(D2="PH","PH",IF(OR(D2="IE",D2="GB"),"GB","Nordic")))))




有效用户&一二阶登录比

select birth_dt,channel_id,country,投放方式,用户类型,素材名称,
count(distinct device_id) as newusers,
sum(effect) as effect,
sum(stageone) as stageone,
sum(stagetwo) as stagetwo
from 
(select birth_dt,channel_id,country,投放方式,用户类型,素材名称,a.device_id,
case when count (distinct case when datediff(login_dt,birth_dt)  between 0 and 6  then login_dt else null end)>=2 then 1 else 0 end  as effect,
case when count (distinct case when datediff(login_dt,birth_dt)  between 0 and 6  then login_dt else null end)>=3 then 1 else 0 end  as stageone,
case when count (distinct case when datediff(login_dt,birth_dt)  between 0 and 6  then login_dt else null end)>=3 and
          count (distinct case when datediff(login_dt,birth_dt)  between 7 and 13 then login_dt else null end)>=1 then 1 else 0 end  as stagetwo
from 
(select birth_dt,channel_id,country,device_id,投放方式,用户类型,素材名称
from 
(select to_date(date_time) as birth_dt,device_id,channel_id,
case when country = 'US'  then  'US'
     when country in ('FR','DE','CA','GB','IE','AU','NZ','NO','SE','DK','FI','SG','AT','CZ','PL','SK') then 'T2'
     when country in ('IT','ES','PH','TH','MY','ID','BR','AR','PE','CL','AL','BG','HR','CY','GR','HU','RO','RS','SI','TR','MK') then 'T3'
     else    'others'
     end as country
from myth.device_activate
where day_time between ${beginDate} and ${birthendDate}
and channel_id  in (1000,2000)  
and version_name = '1.5.0'
and country not in ('CN','HK')
group by 1,2,3,4) a 

left join 
(select customer_user_id,  -- 广告
case when split_part(af_adset,'-',5) ='ARPG'                    then 'ARPG'
     when split_part(af_adset,'-',5) ='ARPG&北欧神话'            then 'ARPGARPG&北欧神话'
     when split_part(af_adset,'-',5) in('RPG','RPG&Card')       then 'RPG'
     when split_part(af_adset,'-',5)='SLG'                      then 'SLG'
     when split_part(af_adset,'-',5)='卡牌'                     then '卡牌'
     when split_part(af_adset,'-',5)='PurchaseLAL3%'            then 'PurchaseLAL'
     when split_part(af_adset,'-',5)=''                         then '未知'
     when af_adset is null then '自然量'
     else  '未知'
     end  as '用户类型',
case when split_part(af_adset,'-',4) in ('AEO','')  then 'AEO'
     when split_part(af_adset,'-',4) ='MAI'         then 'MAI'
     when af_adset is null then '自然量'
     else  '未知'
     end  as '投放方式',
case when split_part(af_adset,'-',8) in ('Group1','group1','Group2','Group3','Group4','Group5','Group6') 
     then split_part(af_adset,'-',11)
     when  split_part(af_adset,'-',8) in ('20210624','20221207','20230206','20230209','20230224','210624')
     then split_part(af_adset,'-',9)
     else split_part(af_adset,'-',10)
     end as '素材名称'  
from myth.af_push
where day_time between ${beginDate} and ${birthEndDate}
group by 1,2,3,4) b 
on a.device_id=customer_user_id

) a 
left join

(
select device_id,to_date(date_time) as login_dt
from myth.device_launch
where day_time>=${beginDate} and day_time<=${endDate} 
and channel_id  in (1000,2000)
an_name = '1.4.7'
and country not in ('CN','HK')
group by 1,2)  c 
on a.device_id = c.device_id
group by 1,2,3,4,5,6,7
) t 
group by 1,2,3,4,5,6




-- 分R的战役关卡数和等级停留数据


-- select birth_dt,vip,datediff(done_dt,birth_dt)+1 as '生命周期',max_level,count(distinct a.role_id)
-- from 
-- (select birth_dt,a1.role_id,
-- case when total_pay>0     and total_pay<=13    then 1
--      when total_pay>13    and total_pay<=105   then 2 
--      when total_pay>105   and total_pay<=277   then 3
--      when total_pay>277                        then 4 
--      else 0 
--      end as vip    
-- from 
-- (select birth_dt,a.role_id
-- ,sum(case when datediff(vip_dt,birth_dt)<=${lifeTime}  then pay else 0 end ) as 'total_pay'
-- from
-- (  --新增
-- select role_id,birth_dt
-- from
-- (select role_id,device_id,to_date(date_time) as birth_dt
-- from myth.server_role_create 
-- where day_time>=${beginDate} and day_time<=${birthEndDate} 
-- and server_id in (${serverIds}) 
-- and channel_id  in (1000,2000)  
-- and version_name = '1.5.0'
-- and country not in ('CN','HK')
-- ) as a1
-- right join
-- (select device_id,to_date(date_time) as device_birth_dt
-- from myth.device_activate
-- where day_time>=${beginDate} and day_time<=${birthEndDate}
-- and channel_id  in (1000,2000)  
-- and version_name = '1.5.0'
-- and country not in ('CN','HK')
-- ) as a2 
-- on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
-- group by 1,2
-- )  a
-- left join
-- (
-- select role_id,to_date(date_time) as vip_dt,sum(pay_price) pay 
-- from myth.order_pay
-- where  day_time>=${beginDate} and day_time<=${endDate}
-- and country not in ('CN','HK')
-- group by 1,2 ) b 
-- on a.role_id =b.role_id
-- group by 1,2
-- ) a1
-- left join  
-- (
-- select role_id,to_date(date_time) as login_dt
-- from myth.server_role_login 
-- where day_time>=${beginDate} and day_time<=${endDate}
-- and country not in ('CN','HK')
-- and version_name = '1.5.0'
-- group by 1,2
-- ) b1 
-- on a1.role_id=b1.role_id
-- where datediff(login_dt,birth_dt)=1

-- ) a 
-- left join 
-- (select c.role_id,done_dt,max(max_level) as max_level
--     from 
-- (
-- select role_id,to_date(date_time) as done_dt
-- from myth.server_role_login 
-- where day_time>=${beginDate} and day_time<=${endDate}
-- and country not in ('CN','HK')
-- and version_name = '1.5.0'
-- group by 1,2
-- ) c 
-- left join 
-- (
-- select role_id,to_date(date_time) as level_dt,max(role_level) as max_level
-- from myth.server_role_upgrade
-- where  day_time>=${beginDate} and day_time<=${endDate}
-- and country not in ('CN','HK')
-- and version_name = '1.5.0'
-- group by 1,2 ) d   
-- on c.role_id =d.role_id
-- where level_dt<=done_dt
-- group by 1,2 ) e
-- on a.role_id = e.role_id
-- where done_dt>=birth_dt
-- group by 1,2,3,4




-- select datediff(done_dt,birth_dt)+1,count(distinct a.role_id)
-- from 
-- (  --新增
-- select role_id,birth_dt
-- from
-- (select role_id,device_id,to_date(date_time) as birth_dt
-- from myth.server_role_create 
-- where day_time>=${beginDate} and day_time<=${birthEndDate} 
-- and server_id in (${serverIds}) 
-- and channel_id  in (1000,2000)  
-- and version_name = '1.5.0'
-- and country not in ('CN','HK')
-- ) as a1
-- right join
-- (select device_id,to_date(date_time) as device_birth_dt
-- from myth.device_activate
-- where day_time>=${beginDate} and day_time<=${birthEndDate}
-- and channel_id  in (1000,2000)  
-- and version_name = '1.5.0'
-- and country not in ('CN','HK')
-- ) as a2 
-- on a1.device_id = a2.device_id and a1.birth_dt = a2.device_birth_dt
-- group by 1,2
-- )  a
-- left join
-- (
-- select role_id,to_date(date_time) as done_dt
-- from myth.server_role_login 
-- where day_time>=${beginDate} and day_time<=${endDate}
-- and country not in ('CN','HK')
-- and version_name = '1.5.0'
-- group by 1,2
-- ) c 
-- where done_dt>=birth_dt
-- group by 1





分手机品牌留存


select birth_dt,channel_id,datediff(login_dt,birth_dt) as datediffs,country,用户类型,素材名称,投放方式,
       case when 素材名称 is not null then '广告量' 
            else '自然量' 
            end as campaign,
       case when c.device_id is null then '免费'
            else '付费'
            end as pay_or_not,
     count(distinct a.device_id)
from 
(select to_date(cast (date_time as timestamp)) as birth_dt,device_id,channel_id,
case when country = 'US'  then  'US'
     when country in ('FR','DE','CA','GB','IE','AU','NZ','NO','SE','DK','FI','SG','AT','CZ','PL','SK') then 'T2'
     when country in ('IT','ES','PH','TH','MY','ID','BR','AR','PE','CL','AL','BG','HR','CY','GR','HU','RO','RS','SI','TR','MK') then 'T3'
     else    'others'
     end as country
from myth.device_activate
where day_time between ${beginDate} and ${endDate}
and channel_id  in (1000,2000)  
and version_name = '1.5.0'
and country not in ('CN','HK')
group by 1,2,3,4) a 

left join 
(select customer_user_id,  -- 广告
  
case when split_part(af_adset,'-',5) ='ARPG'                    then 'ARPG'
     when split_part(af_adset,'-',5) ='ARPG&北欧神话'            then 'ARPGARPG&北欧神话'
     when split_part(af_adset,'-',5) in('RPG','RPG&Card')       then 'RPG'
     when split_part(af_adset,'-',5)='SLG'                      then 'SLG'
     when split_part(af_adset,'-',5)='卡牌'                     then '卡牌'
     when split_part(af_adset,'-',5)='PurchaseLAL3%'            then 'PurchaseLAL'
     when split_part(af_adset,'-',5)=''                         then '未知'
     when af_adset is null then '自然量'
     else  '未知'
     end  as '用户类型',
case when split_part(af_adset,'-',4) in ('AEO','')  then 'AEO'
     when split_part(af_adset,'-',4) ='MAI'         then 'MAI'
     when af_adset is null then '自然量'
     else  '未知'
     end  as '投放方式',
case when split_part(af_adset,'-',8) in ('Group1','group1','Group2','Group3','Group4','Group5','Group6') 
     then split_part(af_adset,'-',11)
     when  split_part(af_adset,'-',8) in ('20210624','20221207','20230206','20230209','20230224','210624')
     then split_part(af_adset,'-',9)
     else split_part(af_adset,'-',10)
     end as '素材名称'
from myth.af_push
where  day_time>=${beginDate} and day_time<=${endDate} 
group by 1,2,3,4 ) b 
on a.device_id=customer_user_id

left join
(select device_id,to_date(cast (date_time as timestamp)) as pay_dt --付费
from myth.order_pay
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id  in (1000,2000)  
and country not in ('CN','HK')
) as c
on a.device_id = c.device_id and a.birth_dt = c.pay_dt

left join  -- 留存
(select to_date(cast (date_time as timestamp)) as login_dt,device_id
from myth.device_launch
where day_time between ${beginDate} and ${end2Date} 
and channel_id  in (1000,2000)  
and version_name = '1.5.0'
and country not in ('CN','HK')
group by 1,2
) d 
on a.device_id=d.device_id
where login_dt>=birth_dt
group by 1,2,3,4,5,6,7,8,9









机型的留存和付费



select birth_dt,channel_id,datediff(login_dt,birth_dt) as datediffs,country,广告类型,素材名称,投放方式,
       case when af_ad ='APP_INSTALLS' then '广告量'
       else '自然量'
       end as '用户分类',
       case when c.device_id is null   then '免费'
            else '付费'
            end as pay_or_not,device_code,
     count(distinct a.device_id)
from 
(select to_date(cast (date_time as timestamp)) as birth_dt,device_id,device_code,channel_id,
case when country = 'US'  then  'US'
     when country in ('FR','DE','CA','GB','IE','AU','NZ','NO','SE','DK','FI','SG','AT','CZ','PL','SK') then 'T2'
     when country in ('IT','ES','PH','TH','MY','ID','BR','AR','PE','CL','AL','BG','HR','CY','GR','HU','RO','RS','SI','TR','MK') then 'T3'
else 'others'
end as country
from myth.device_activate
where day_time between ${beginDate} and ${endDate}
and channel_id  in (1000,2000)  
and version_name = '1.5.0'
group by 1,2,3,4,5) a 

left join 
(select customer_user_id,  -- 广告
case when split_part(af_adset,'-',5) ='ARPG'                    then 'ARPG'
   --  when split_part(af_adset,'-',5) ='ARPG&北欧神话'            then 'ARPGARPG&北欧神话'
     when split_part(af_adset,'-',5) in('RPG','RPG&Card')       then 'RPG'
   --  when split_part(af_adset,'-',5)='SLG'                      then 'SLG'
   --  when split_part(af_adset,'-',5)='卡牌'                     then '卡牌'
   --  when split_part(af_adset,'-',5)='PurchaseLAL3%'            then 'PurchaseLAL'
   --  when split_part(af_adset,'-',5)=''                         then '未知'
   --  when af_adset is null then '自然量'
     else  '未知'
     end  as '广告类型',
case when split_part(af_adset,'-',4) ='AEO'         then 'AEO'
     when split_part(af_adset,'-',4) ='MAI'         then 'MAI'
     --when split_part(af_adset,'-',4) =''            then '未知'
     else  '未知'
     end  as '投放方式',
case when split_part(af_adset,'-',9) in ('Boss战斗','Build类','割草战斗') 
     then split_part(af_adset,'-',11)
     --when  split_part(af_adset,'-',8) in ('20210624','20221207','20230206','20230209','20230224','210624')
     --then split_part(af_adset,'-',9)
     else split_part(af_adset,'-',10)
     end as '素材名称',af_ad
from myth.af_push
where day_time between ${beginDate} and ${endDate}
group by 1,2,3,4,5) b 
on a.device_id=customer_user_id

left join
(select device_id,to_date(cast (date_time as timestamp)) as pay_dt
from myth.order_pay
where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
and channel_id  in (1000,2000)  
group by 1,2 
) as c
on a.device_id = c.device_id and a.birth_dt = c.pay_dt

left join  -- 留存
(select to_date(cast (date_time as timestamp)) as login_dt,device_id
from myth.device_launch
where day_time between ${beginDate} and ${end2Date} 
and channel_id  in (1000,2000)  
and version_name = '1.5.0'

group by 1,2
) d 
on a.device_id=d.device_id
where login_dt>=birth_dt
group by 1,2,3,4,5,6,7,8,9,10



-- select birth_dt,country,device_code,广告类型,素材名称,投放方式,
--        case when af_ad ='APP_INSTALLS' then '广告量'
--        else '自然量'
--        end as '用户分类',
--        count(distinct a.device_id) as '新增',
--        sum(case when datediff(pay_dt,birth_dt)=0 then pay_price end) as '第一天付费总收入',
--        sum(case when datediff(pay_dt,birth_dt)<=1 then pay_price end) as '前二天付费总收入',
--        sum(case when datediff(pay_dt,birth_dt)<=2 then pay_price end) as '前三天付费总收入',
--        sum(case when datediff(pay_dt,birth_dt)<=3 then pay_price end) as '前四天付费总收入',
--        sum(case when datediff(pay_dt,birth_dt)<=6 then pay_price end) as '前七天付费总收入',
--        sum(case when datediff(pay_dt,birth_dt)<=13 then pay_price end) as '前十四天付费总收入',
--        sum(case when datediff(pay_dt,birth_dt)<=18 then pay_price end) as '前十九天付费总收入',
--        sum(case when datediff(pay_dt,birth_dt)<=29 then pay_price end) as '前三十天付费总收入',
--        count(distinct case when datediff(pay_dt,birth_dt)=0   then b.device_id end) as '第一天新增付费用户数',
--        count(distinct case when datediff(pay_dt,birth_dt)<=1  then b.device_id end) as '前二天新增付费用户数',
--        count(distinct case when datediff(pay_dt,birth_dt)<=2  then b.device_id end) as '前三天新增付费用户数',
--        count(distinct case when datediff(pay_dt,birth_dt)<=3  then b.device_id end) as '前四天新增付费用户数',
--        count(distinct case when datediff(pay_dt,birth_dt)<=6  then b.device_id end) as '前七天新增付费用户数',
--        count(distinct case when datediff(pay_dt,birth_dt)<=13 then b.device_id end) as '前十四天新增付费用户数',
--        count(distinct case when datediff(pay_dt,birth_dt)<=29 then b.device_id end) as '前三十天新增付费用户数'
-- from

-- (  --新增
-- select device_id,to_date(cast(date_time as timestamp)) as birth_dt,device_code,
-- case when country = 'US'  then  'US'
--      when country in ('FR','DE','CA','GB','IE','AU','NZ','NO','SE','DK','FI','SG','AT','CZ','PL','SK') then 'T2'
--      when country in ('IT','ES','PH','TH','MY','ID','BR','AR','PE','CL','AL','BG','HR','CY','GR','HU','RO','RS','SI','TR','MK') then 'T3'
-- else 'others'
-- end as country
-- from myth.device_activate
-- where day_time>=${beginDate} and day_time<=${birthEndDate}
-- and channel_id  in (1000,2000)  
-- and version_name = '1.5.0'
-- ) as a

-- left join
-- (select device_id,pay_price,to_date(cast (date_time as timestamp)) as pay_dt --付费
-- from myth.order_pay
-- where day_time between ${beginDate} and ${endDate} and server_id in (${serverIds})
-- and channel_id  in (1000,2000)  
-- and country not in ('CN','HK')
-- ) as b
-- on a.device_id = b.device_id

-- left join 
-- (select customer_user_id,  -- 广告
-- case when split_part(af_adset,'-',5) ='ARPG'                    then 'ARPG'
--    --  when split_part(af_adset,'-',5) ='ARPG&北欧神话'            then 'ARPGARPG&北欧神话'
--      when split_part(af_adset,'-',5) in('RPG','RPG&Card')       then 'RPG'
--    --  when split_part(af_adset,'-',5)='SLG'                      then 'SLG'
--    --  when split_part(af_adset,'-',5)='卡牌'                     then '卡牌'
--    --  when split_part(af_adset,'-',5)='PurchaseLAL3%'            then 'PurchaseLAL'
--    --  when split_part(af_adset,'-',5)=''                         then '未知'
--    --  when af_adset is null then '自然量'
--      else  '未知'
--      end  as '广告类型',
-- case when split_part(af_adset,'-',4) ='AEO'         then 'AEO'
--      when split_part(af_adset,'-',4) ='MAI'         then 'MAI'
--      --when split_part(af_adset,'-',4) =''            then '未知'
--      else  '未知'
--      end  as '投放方式',
-- case when split_part(af_adset,'-',9) in ('Boss战斗','Build类','割草战斗') 
--      then split_part(af_adset,'-',11)
--      --when  split_part(af_adset,'-',8) in ('20210624','20221207','20230206','20230209','20230224','210624')
--      --then split_part(af_adset,'-',9)
--      else split_part(af_adset,'-',10)
--      end as '素材名称',af_ad
-- from myth.af_push
-- where day_time between ${beginDate} and ${endDate}
-- group by 1,2,3,4,5) c 
-- on a.device_id=customer_user_id
-- group by 1,2,3,4,5,6,7
-- order by 1




付费留存(付费为起点) 留存/LTV

select birth_dt,channel_id,country,first_pay_dt
,count(distinct a.device_id) as '新增'
,count(distinct case when datediff(log_dt,first_pay_dt)=1  then a.device_id else null end) as '次留'
,count(distinct case when datediff(log_dt,first_pay_dt)=2  then a.device_id else null end) as '3留'
,count(distinct case when datediff(log_dt,first_pay_dt)=3  then a.device_id else null end) as '4留'
,count(distinct case when datediff(log_dt,first_pay_dt)=4  then a.device_id else null end) as '5留'
,count(distinct case when datediff(log_dt,first_pay_dt)=5  then a.device_id else null end) as '6留'
,count(distinct case when datediff(log_dt,first_pay_dt)=6  then a.device_id else null end) as '7留'
,count(distinct case when datediff(log_dt,first_pay_dt)=13 then a.device_id else null end) as '14留'
,count(distinct case when datediff(log_dt,first_pay_dt)=29 then a.device_id else null end) as '30留'
,sum(case when datediff(log_dt,first_pay_dt)=0 then pay_price end) as '第一天付费总收入'
,sum(case when datediff(log_dt,first_pay_dt)<=2 then pay_price end) as '前三天付费总收入'
,sum(case when datediff(log_dt,first_pay_dt)<=6 then pay_price end) as '前七天付费总收入'
,sum(case when datediff(log_dt,first_pay_dt)<=13 then pay_price end) as '前十四天付费总收入'
,sum(case when datediff(log_dt,first_pay_dt)<=29 then pay_price end) as '前三十天付费总收入'
from 
(select device_id,birth_dt,channel_id,country,first_pay_dt
from 
(select a.device_id,birth_dt,channel_id,country,first_pay_dt
from 
(select  device_id,channel_id,min(to_date(date_time )) as first_pay_dt
from myth.order_pay
where day_time >=20230104 and day_time<=20230606
and channel_id  in (1000,2000)  
group by 1,2) a 
left join 

(select  to_date(date_time ) as birth_dt,country,device_id
from myth.device_activate
where day_time >=20211202 and day_time<=20230606
and channel_id  in (1000,2000)  
group by 1,2,3) b 
on a.device_id=b.device_id
) a1
-- where first_pay_dt in ('2023-01-05','2023-01-06','2023-01-07','2023-03-15','2023-03-16','2023-03-17','2023-03-18','2023-03-19','2023-06-03','2023-06-04','2023-06-05','2023-06-06') 
where first_pay_dt in ('2023-07-28','2023-07-29','2023-07-30','2023-07-31')
) a 
left join 

(select  to_date(date_time ) as log_dt,device_id
from myth.device_launch
where day_time >=20230105 and day_time<=20230705
and channel_id  in (1000,2000)  
group by 1,2) c  
 

-- (select  to_date(date_time ) as log_dt,device_id,sum(pay_price) as pay_price
-- from myth.order_pay
-- where day_time >=20230105 and day_time<=20230620
-- and channel_id  in (1000,2000)  
-- group by 1,2) c 

on a.device_id = c.device_id

group by 1,2,3,4




 付费为起点+当期新增

select pay_dt,channel_id,datediff(login_dt,pay_dt)+1 as '天数',count(distinct a.role_id)
,sum(pay) as pay
from 
(select a.role_id,pay_dt,channel_id
from 
(  --新增
select role_id,birth_dt,channel_id
from
(select role_id,device_id,to_date(date_time) as birth_dt,channel_id
from myth.server_role_create 
where day_time>=${beginDate} and day_time<=${birthEndDate} 
and server_id in (${serverIds}) 
and channel_id  in (1000,2000)  
and version_name = '1.5.0'
and country not in ('CN','HK')
) as a1
right join
(select device_id,to_date(date_time) as device_birth_dt
from myth.device_activate
where day_time>=${beginDate} and day_time<=${birthEndDate}
and channel_id  in (1000,2000)  
and version_name = '1.5.0'
and country not in ('CN','HK')
) as a2 
on a1.device_id = a2.device_id   --and a1.birth_dt = a2.device_birth_dt
group by 1,2
)  a
left join
(
select role_id,min(to_date(date_time)) as pay_dt
from myth.order_pay
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id  in (1000,2000)  
and country not in ('CN','HK')
group by 1 
) b  
on a.role_id = b.role_id 
where b.role_id is not null 
and datediff(pay_dt,birth_dt)<6
) a 
left join 
-- (
-- select role_id,to_date(date_time) as login_dt
-- from myth.server_role_login
-- where day_time>=${beginDate} and day_time<=${endDate}
-- and channel_id  in (1000,2000)  
-- and version_name = '1.5.0'
-- and country not in ('CN','HK')
-- group by 1,2 
-- ) c 

(
select role_id,to_date(date_time) as login_dt,sum(pay_price) as pay
from myth.order_pay
where day_time>=${beginDate} and day_time<=${endDate}
and channel_id  in (1000,2000)  
and country not in ('CN','HK')
group by 1,2 
) c 
on a.role_id = c.role_id 
where login_dt>=pay_dt
group by 1,2,3

