-- 强引导 + 触发式引导

select step as '引导ID',引导名称,act_num as '操作ID',操作内容,角色数量,
case when step ='100101'  then 100
     else round(角色数量/上一步骤人数*100,2) 
     end as '节点通过率',
round(角色数量/第一步人数*100,2)  as '节点总体通过率'   
from     
(select step,引导名称,act_num,操作内容,角色数量,lag(角色数量,1,0)over(order by 角色数量 desc) as '上一步骤人数',
     max(角色数量) over(order by 角色数量 desc) as '第一步人数'
from
(select step ,
case step 
when  '1001010'  then  '移动'
when  '1001020'  then  '行礼'
when  '1001040'  then  '普通攻击'
when  '1001050'  then  '释放技能'
when  '1001060'  then  '血瓶'
when  '1001070'  then  '离开战役'
when  '1002010'  then  '奥丁对话'
when  '1002020'  then  '祈愿'
when  '1002030'  then  '十连抽'
when  '1002040'  then  '退出抽卡'
when  '1003010'  then  '打开战役'
when  '1003020'  then  '备战'
when  '1003030'  then  '主神卡'
when  '1003040'  then  '选择主神卡'
when  '1003050'  then  '出战主神卡'
when  '1003060'  then  '主动卡'
when  '1003070'  then  '选择主动卡'
when  '1003080'  then  '出战主动卡'
when  '1003100'  then  '战役1-2'
when  '1004010'  then  '神力弹窗'
when  '1004020'  then  'XP技能'
when  '1005010'  then  '打开背包'
when  '1005020'  then  '装备图标'
when  '1005030'  then  '穿戴装备'
when  '1006010'  then  '战役1-3'
when  '1006020'  then  '进入1-3'
when  '1007010'  then  '神性引导'
when  '1007020'  then  '神性页签'
when  '1007030'  then  '升级神性'
when  '1008010'  then  '战役1-4'
when  '1008020'  then  '查看奖励'
when  '1008030'  then  '进入1-4'
when  '1009010'  then  '天赋引导'
when  '1009020'  then  '天赋页签'
when  '1009030'  then  '查看天赋'
when  '1009040'  then  '激活天赋'
when  '1009050'  then  '技能选择'
when  '1009060'  then  '技能出战'
when  '1010010'  then  '战役1-5'
when  '1010020'  then  '进入1-5'
when  '1011010'  then  '挂机对话'
when  '1011020'  then  '查看挂机'
when  '1011030'  then  '领取奖励'
when  '1012010'  then  '第2章'
when  '1012020'  then  '查看角色'
when  '1012030'  then  '切换头像'
when  '1012040'  then  '确认切换'
when  '1012050'  then  '确认弹窗'
when  '1012060'  then  '点击角色'
when  '1012070'  then  '点击天赋'
when  '1012080'  then  '一键激活'
when  '1012090'  then  '天赋孔位'
when  '1012100'  then  '选择天赋'
when  '1013010'  then  '地精宝库引导'
when  '1013020'  then  '宝库界面'
when  '1013030'  then  '进入宝库'
when  '1014010'  then  '竞技场引导'
when  '1014020'  then  '查看竞技场'
when  '1015010'  then  '秘境引导'
when  '1015020'  then  '查看秘境'
when  '1016010'  then  '神器引导'
when  '1016020'  then  '神器页签'
when  '1016030'  then  '激活神器'
when  '1018010'  then  '点击下一章'
when  '1018020'  then  '切换索尔'
when  '1018030'  then  '索尔头像'
when  '1018040'  then  '确认切换'
when  '1018050'  then  '确认弹窗'
when  '1019010'  then  '信徒心愿引导'
when  '1019020'  then  '查看心愿'
when  '1019030'  then  '心愿赐福'
when  '1020010'  then  '世界树引导'
when  '1020020'  then  '查看世界树'
when  '1021010'  then  '众神信仰引导'
when  '1021020'  then  '查看信仰'
when  '1021030'  then  '信仰升级'
when  '1022010'  then  '宝石矿坑引导'
when  '1022020'  then  '查看矿坑'
when  '1022030'  then  '选择旷工'
when  '1022040'  then  '开始挖矿'
when  '1024010'  then  '远古战场引导'
when  '1024020'  then  '查看远古战场'
when  '1025010'  then  '卢恩符石引导'
when  '1025020'  then  '查看卢恩符石'
when  '1026010'  then  '点击下一章'
when  '1026020'  then  '切换乌勒尔'
when  '1026030'  then  '乌勒尔头像'
when  '1026040'  then  '确认切换'
when  '1026050'  then  '确认弹窗'
when  '1027010'  then  '诸神试炼引导'
when  '1027020'  then  '查看诸神试炼'

end as '引导名称',
act_num ,
case when step='2001010' and act_num=1 then '离开神殿'
     else '-'
     end as '操作内容',
count(distinct role_id) as '角色数量'
from 
(select role_id,step,0 as act_num
from myth.server_newbie
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
and role_id in (select role_id
from myth.server_role_create
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
group by 1)
union all 
select role_id,step,act_num
from myth_server.server_event_guide
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
and channel_id=1000
and version_name ='1.3.0'   
and country not in ('CN','HK')
and role_id in (select role_id
from myth.server_role_create
where day_time between ${beginDate} and ${endDate}   and server_id in (${serverIds})
group by 1)
) a 
group by 1,2,3,4
) a 
order by 角色数量 desc 
) t 
where step is not null 