select map_id as '地图ID', 
case map_id 
when 1 then  '家园'
when 2 then  '第一章1'
when 3 then  '第一章2'
when 4 then  '第一章3'
when 5 then  '野餐聚会'
when 6 then  '第二章1'
when 7 then  '第二章2'
when 8 then  '第二章3'
when 9 then  '第二章4'
when 10 then '第二章5'
when 11 then '成人礼'
when 12 then '第三章1'
when 13 then '第三章2'
when 14 then '第三章3'
when 15 then '第三章4'
when 16 then '第三章5'
when 18 then '第四章1'
when 19 then '第四章2'
when 20 then '第四章3'
Else '暂不开启'
Else '暂不开启'
end as '地图名称',
building_id as '建筑物ID', 
case building_id
when '101001' then '烘焙店'  
when '101002' then '锯木场'
when '101003' then '矿石加工厂'
when '101004' then '谷仓'
when '101005' then '神奇道具店'
when '101006' then '铁匠铺'
when '101007' then '篝火'
when '101008' then '乳品店'
when '101009' then '家具店'
when '101010' then '榨汁厂'
when '101011' then '糖果厂'
when '101012' then '纺织工坊'
when '101013' then '裁缝店'
when '101014' then '餐厅'
when '101015' then '材料店'
when '101016' then '印刷厂'
when '101017' then '乐器店'
when '101018' then '艺术品店'
when '101019' then '魔法店'
when '102001' then '炼金台'
when '102003' then '餐车'
when '103001' then '水井'
when '103002' then '报刊亭'
when '103003' then '邮局'
when '103004' then '花店'
when '103005' then '市场'
when '103006' then '马戏团'
when '103007' then '图书馆'
when '104001' then '耕地'
when '104002' then '肥沃耕地'
when '104003' then '温室'
when '104004' then '暖屋'
when '104005' then '耕地'
when '105001' then '养鸡场'
when '105002' then '养牛场'
when '105003' then '养羊场'
when '105004' then '养鹅场'
when '105005' then '养猪场'
when '106001' then '木制长椅'
when '106002' then '铁制长椅'
when '106003' then '白漆栅栏'
when '106004' then '木栅栏'
when '106005' then '优雅路灯'
when '106006' then '木制路灯'
when '106007' then '魔法路灯'
when '106008' then '高树篱'
when '106009' then '花架'
when '106010' then '鲜花簇'
when '106011' then '梅林喷泉'
when '106012' then '毛地黄花坛'
when '106013' then '封路玫瑰栅栏'
when '106014' then '风车'
when '106015' then '黄色野花丛'
when '106016' then '狗舍'
when '106017' then '几株向日葵'
when '106018' then '花朵灯柱'
when '106019' then '梧桐叶路'
when '106020' then '海豚雕像'
when '106021' then '流水的律动'
when '106022' then '邮箱'
when '106023' then '矮树篱'
when '106024' then '高树篱'
when '106025' then '猫头鹰形状树篱'
when '106026' then '方形花坛'
when '106027' then '花坛'
when '106028' then '梧桐树'
when '106029' then '丁香树'
when '106030' then '郁金香'
when '106031' then '铁大门'
when '106032' then '绿植大门'
when '106033' then '白色曲线双人椅'
when '106034' then '秋千'
when '106035' then '大理石喷泉'
when '106036' then '亭子'
when '106037' then '大理石路'
when '106038' then '玉兰树'
when '106039' then '紫薇花树'
when '106040' then '桃树'
when '106041' then '映山红'
when '106042' then '拳击手树'
when '106043' then '拳击手树'
when '106044' then '神秘树'
when '106045' then '神秘树'
when '106046' then '玉兰树'
when '106047' then '紫薇花树'
when '106048' then '桃树'
when '106049' then '映山红'
when '106050' then '蓝花楹'
when '106051' then '水洼（土地）'
when '106052' then '水洼（草地）'
when '106053' then '铁栅栏'
when '106054' then '绿植栅栏'
when '106055' then '童话镇入口'
when '106056' then '藤蔓门'
when '106057' then '草垛'
when '107001' then '石板路'
when '108001' then '民居'
when '108002' then '住宅'
when '108003' then '阁楼'
when '108004' then '别墅'
when '108005' then '公寓'
when '108006' then '酒店'
when '151001' then '猫头鹰货栈'
when '152001' then '火车站'
when '152002' then '火车站隧道'
when '154001' then '收藏建筑'
when '155001' then '码头'
when '2001001' then '石板路'
when '2001002' then '花店'
when '2001003' then '报刊亭'
when '2001004' then '木制长椅'
when '2001005' then '优雅路灯'
when '2001006' then '方形花坛'
when '2001007' then '映山红'
when '2001008' then '流水的律动'
when '2001009' then '矮树篱'
when '2001010' then '邮箱'
when '2007006' then '炼金工作台（2-2）'
when '2007007' then '炼金工作台-（2-2）（关底）'
when '2002001' then '封路石墙1（1-1）'
when '2002002' then '铁栅栏（1-1）'
when '2002003' then '猎人小屋（1-1）'
when '2002004' then '精灵雕像（1-1）'
when '2002005' then '鲜花簇（1-1）'
when '2002006' then '秋千（1-1）'
when '2002007' then '流水的律动（1-1）'
when '2002008' then '藤蔓门（1-1）'
when '2002009' then '月亮井'
when '2002010' then '荆棘墙（1-1）'
when '2002011' then '花沿木桥（1-1）（第一座桥）'
when '2002012' then '睡美人的床（1-1）'
when '2002013' then '绿植栅栏封路（2-3）'
when '2002014' then '宝石放置台（海洋）（1-1）'
when '2002015' then '宝石放置台（森林）（1-1）'
when '2002016' then '宝石放置台（大地）（1-1）'
when '2002017' then '花沿木桥（1-1）（第二座桥）'
when '2002018' then '机关石门1（1-1）'
when '2002019' then '月亮井（装饰）'
when '2002020' then '路标1'
when '2002021' then '路标2'
when '2002022' then '路标3'
when '2002023' then '特效荧光'
when '2002024' then '特效蝴蝶'
when '2002025' then '封路石墙（1-1）'
when '2002026' then '白色曲线双人椅'
when '2002027' then '封路石墙2（1-1）'
when '203003' then '冰钓鱼洞'
when '2003001' then '毛球雕像（1-2）'
when '2003002' then '木栅栏（1-2）'
when '2003003' then '倾倒的花坛（1-2）'
when '2003004' then '山脉入口（1-2）'
when '2003005' then '心型树（1-2）'
when '2003006' then '收藏建筑（1-2）'
when '2003007' then '红枫树（1-2）'
when '2004001' then '魔镜（1-3）'
when '2004002' then '魔豆藤蔓（1-3）'
when '2004003' then '收藏建筑（1-3）'
when '2004004' then '坩埚（1-3）'
when '2004005' then '精灵-可建造（1-3）'
when '2004006' then '民居'
when '2004007' then '封路藤蔓（1-3）'
when '2004008' then '封路藤蔓（1-3）'
when '2004009' then '封路藤蔓（1-3）'
when '2004010' then '封路藤蔓（1-3）'
when '2004011' then '石梯1（1-3）'
when '2004012' then '白漆栅栏（1-3）'
when '2004013' then '路标1'
when '2004014' then '路标1'
when '2004015' then '路标2'
when '2004016' then '路标2'
when '2004017' then '路标1'
when '2004018' then '秋千（1-3）'
when '2006001' then '庭院入口（2-1）'
when '2006002' then '障碍门1（2-1）'
when '2006003' then '障碍门2（2-1）'
when '2006004' then '障碍门3（2-1）'
when '2006005' then '障碍门4（2-1）'
when '2006006' then '贝壳椅（2-1）（2-2）'
when '2006007' then '炼金工作台（2-1）'
when '2006008' then '大海蚌(持续-水)（2-1）'
when '2006009' then '收藏建筑（2-1）'
when '2006010' then '封路石柱海底-5（2-1）'
when '2006011' then '封路石柱海底-6（2-1）'
when '2006012' then '封路石柱海底-7（2-1）'
when '2006013' then '封路石柱海底-8（2-1）'
when '2006014' then '封路巨石海底-1（2-1）'
when '2006015' then '封路巨石海底-2（2-1）'
when '2006016' then '封路巨石海底-3（2-1）'
when '2006017' then '封路巨石海底-4（2-1）'
when '2006018' then '红色垂柳-2（2-1）（2-2）'
when '2006019' then '特效气泡'
when '2006020' then '特效鱼群03'
when '2006021' then '特效鱼群04'
when '2007001' then '红珊瑚制造台1（2-2）'
when '2007002' then '蓝珊瑚制造台2（2-2）'
when '2007003' then '绿珊瑚制造台3（2-2）'
when '2007004' then '黄珊瑚制造台4（2-2）'
when '2007005' then '大海蚌（2-2）'
when '2007008' then '封路巨石海底-1（2-2）'
when '2007009' then '封路巨石海底-2（2-2）'
when '2007010' then '封路巨石海底-3（2-2）'
when '2007011' then '封路巨石海底-4（2-2）'
when '2007012' then '王子雕像（2-2）'
when '2007013' then '珍珠灯（2-2）'
when '2007014' then '沉船（2-2）'
when '2007015' then '封路石柱海底-1（2-2）'
when '2007016' then '封路石柱海底-2（2-2）'
when '2007017' then '封路石柱海底-3（2-2）'
when '2007018' then '封路石柱海底-4（2-2）'
when '2007019' then '红色垂柳-1（2-2）'
when '2007020' then '海螺屋（2-2）'
when '2007021' then '贝壳椅（2-1）（2-2）'
when '2007022' then '障碍门1（2-2）'
when '2007023' then '欧若拉住所的大门（2-2）'
when '2007024' then '障碍门3（2-2）'
when '2007025' then '收藏建筑（2-2）'
when '2007026' then '珊瑚栅栏01'
when '2007027' then '珊瑚栅栏02'
when '2007028' then '珊瑚栅栏03'
when '2007029' then '珍珠灯（2-2）'
when '2007030' then '珍珠灯（2-2）'
when '206061' then '宝石放置台底座（1-1）'
when '2005001' then '亭子（野餐会）'
when '2005002' then '梅林的郊野小屋（野餐会）'
when '2005003' then '木制长椅（野餐会）'
when '2005004' then '花朵灯柱（野餐会）'
when '2005005' then '梧桐树（野餐会）'
when '2005006' then '收藏建筑（野餐会）'
when '2005007' then '堆积的木料大'
when '2005008' then '堆积的木料小'
when '2005009' then '美食餐桌'
when '2005010' then '甜品庄园'
when '2005011' then '棒棒糖制作台(野餐会)'
when '2005012' then '餐车（野餐会）'
when '2005013' then '美食餐桌（礼品箱奖励）'
when '2005014' then '民居（野餐会）'
when '2005015' then '锯木场'
when '2005016' then '篝火（野餐会）'
when '2005017' then '耕地(野餐会）'
when '2005018' then '木栅栏'
when '2005019' then '路标-梅林的郊野小屋'
when '2005020' then '路标-惠特尼住所'
when '2005021' then '路标-林间锯木场'
when '2005022' then '路标-花园'
when '207002' then '石梯2'
when '301001' then '阻挡物4*4'
when '301002' then '阻挡物5*5'
when '301003' then '阻挡物6*6'
when '301004' then '阻挡物8*8'
when '301005' then '阻挡物2*2'
when '301006' then '阻挡物16*16'
when '301007' then '阻挡物32*32'
when '301008' then '王子区域阻挡物27*21'
when '2009011' then '封路石柱沙滩-1（2-4）'
when '2009012' then '封路石柱沙滩-2（2-4）'
when '2009013' then '封路石柱沙滩-3（2-4）'
when '2009014' then '封路石柱沙滩-4（2-4）'
when '404011' then '荧光装饰'
when '2008001' then '凉亭(2-3)'
when '2008002' then '餐桌(2-3)'
when '2008003' then '餐椅(2-3)'
when '2008004' then '航海罗盘底座（2-3）'
when '2008005' then '巨大海龟（2-3）'
when '2008006' then '航海罗盘（2-3）'
when '2008007' then '月亮井宝箱建筑（2-3）'
when '2008008' then '封路巨石森林1（2-3）'
when '2008009' then '封路巨石森林2（2-3）'
when '2008010' then '封路巨石森林3（2-3）'
when '2008011' then '封路巨石森林4（2-3）'
when '2008012' then '封路巨石森林5（2-3）'
when '2008013' then '封路巨石森林6（2-3）'
when '2008014' then '封路巨石森林7（2-3）'
when '2008015' then '封路巨石森林8（2-3）'
when '2008016' then '封路巨石森林9（2-3）'
when '2008017' then '月亮井（2-3）'
when '2008018' then '纺车（2-3）'
when '2008019' then '炼金工作台（2-3）'
when '2008020' then '老船长-持续生产（2-3）'
when '2008021' then '老船长-装饰（2-3）'
when '2008022' then '货船（2-3）'
when '2008023' then '码头-装饰（2-3）'
when '2008024' then '猎人小屋（2-3）'
when '2008025' then '月亮井（装饰）'
when '2009001' then '海洋祭坛（2-4）'
when '2009002' then '炼金台（2-4）'
when '2009003' then '篝火（2-4）'
when '2009004' then '机关石门2（2-4）'
when '2009005' then '巨大竖琴3（3阶段，2-4）'
when '2009006' then '跨海石桥（可修建，2-4）'
when '2009007' then '巨大竖琴1（2阶段，2-4）'
when '2009008' then '鱼群（2-4）'
when '2009009' then '跨海石桥（不可修建，2-4）'
when '2009015' then '巨大竖琴2（2阶段，2-4）'
when '2009016' then '跨海石桥-桥头（2-4）'
when '2009017' then '跨海石桥-桥身（2-4）'
when '2009018' then '跨海石桥-桥尾（2-4）'
when '2010001' then '人鱼之池'
when '2010002' then '宝石机关-红'
when '2010003' then '宝石机关-黄'
when '2010004' then '宝石机关-蓝'
when '2010005' then '篝火（2-5）'
when '2010006' then '机关石门1（2-5）'
when '2010007' then '机关石门2（2-5）'
when '2010008' then '机关石门3（2-5）'
when '2010009' then '流水的律动（2-5）'
when '2010010' then '大理石喷泉（2-5）'
when '2010011' then '封路石柱沙滩-5（2-4）'
when '2010012' then '封路石柱沙滩-6（2-4）'
when '2010013' then '民居（2-5）'
when '2010014' then '烹饪车（2-5）'
when '2010015' then '收藏建筑（2-5）'
when '2010016' then '郁金香（2-5）'
when '2010017' then '人鱼之池2（无美人鱼,2-5）'
when '2010018' then '码头-装饰（2-5）'
when '2012001' then '魔灯1（3-1）'
when '2012002' then '收藏建筑-雪橇（3-1）'
when '2012003' then '冰雪女王雪橇（3-1）'
when '2012004' then '避雪柱（3-1）'
when '2012005' then '人工冰墙（3-1）'
when '2012006' then '封路冰墙-1-1（3-1）'
when '2012007' then '封路冰墙-1-2（3-1）'
when '2012008' then '封路冰墙-2-1（3-1）'
when '2012009' then '封路冰墙-2-2（3-1）'
when '2012010' then '封路冰墙-3-1（3-1）'
when '2012011' then '封路冰墙-3-2（3-1）'
when '2012012' then '封路冰墙-3-3（3-1）'
when '2012013' then '封路冰墙-3-4（3-1）'
when '2012014' then '石砖墙（3-1）'
when '2012015' then '封路冰墙-3-5（3-1）'
when '2012016' then '封路冰墙-3-6（3-1）'
when '2012017' then '魔灯2（3-1）'
when '2012018' then '魔灯3（3-1）'
when '2012019' then '魔灯4（3-1）'
when '2012020' then '覆雪路标1'
when '2012021' then '覆雪路标2'
when '2012022' then '篝火（3-1）'
when '2012023' then '别墅'
when '2012024' then '阁楼'
when '2012025' then '冰梯（3-1）'
when '2012026' then '铁制长椅（3-1）'
when '2012027' then '大理石喷泉（3-1）'
when '2012028' then '格尔达（3-1）'
when '2013001' then '雪人（3-2）'
when '2013002' then '冰雪封路巨石1'
when '2013003' then '冰雪封路巨石2'
when '2013004' then '冰雪封路巨石3'
when '2013005' then '冰雪封路巨石4'
when '2013006' then '藏宝洞窟-宝箱（3-2）'
when '2013007' then '女巫小屋（3-2）'
when '2013008' then '记忆宝珠（3-2）'
when '2013009' then '避雪柱1（3-2）'
when '2013010' then '避雪柱2（3-2）'
when '2013011' then '避雪柱3（3-2）'
when '2013012' then '冰梯1（3-2）'
when '2013013' then '冰梯2（3-2）'
when '2013014' then '坩埚（3-2）'
when '2013015' then '女巫（3-2）'
when '2013016' then '水井（3-2）'
when '2013017' then '藏宝洞窟-装饰（3-2）'
when '2014001' then '冰钓鱼洞（3-3）'
when '2014002' then '强盗帐篷（3-3）'
when '2014003' then '冰桥（3-3）'
when '2014004' then '篝火（3-3）'
when '2014005' then '炼金台（3-3）'
when '2014006' then '冰桥2（3-3）'
when '2014007' then '覆雪路标-葡萄园'
when '2014008' then '覆雪路标-苹果树林'
when '2014009' then '雪人（3-3门口）'
when '2014010' then '雪人（3-3苹果林）'
when '2014011' then '覆雪路标-炼金台'
when '2014012' then '寻物装饰-雪橇（3-3）'
when '2014013' then '帐篷（3-3）'
when '2014014' then '装饰建筑-雪橇（3-3）'
when '2014015' then '篝火（3-3强盗）'
when '2015001' then '雪猎人小屋（3-4）'
when '2015002' then '雪信箱（3-4）'
when '2015003' then '冰桥（3-4）'
when '2015004' then '哈斯曼-可建造（3-4）'
when '2015005' then '篝火'
when '2015006' then '毁坏的贝拉雪橇（3-4）'
when '2015007' then '没有鹿的贝拉雪橇（3-4）'
when '2015008' then '冰钓鱼洞（3-4）'
when '2015009' then '炼金台（3-4）'
when '2015010' then '覆雪路标-哈斯曼小屋'
when '2015011' then '覆雪路标-麋鹿'
when '2015012' then '覆雪路标-钓鱼洞'
when '2015013' then '收藏建筑（3-4）'
when '2015014' then '完好的贝拉雪橇（3-4）'
when '2016004' then '精灵湖（3-5）'
when '2016005' then '女王之门（3-5）'
when '2016006' then '冰珠柳树（3-5）'
when '2016007' then '冰雪城堡（3-5）'
when '2016008' then '冰灵桥（3-5）'
when '9999999' then '礼品箱测试宝箱建筑'
end as '建筑物名称',
group_concat(cast(商品ID as string)) as '商品ID',
group_concat(消耗材料) as '消耗材料',
group_concat(cast(生产商品数量 as string)) as '生产商品数量',
group_concat(cast(消耗材料数量 as string)) as '消耗材料数量',
group_concat(cast(账户数 as string)) as '加速秒材料账户数'
from
(
select round(cast(map_id as int)/10000,0) as map_id, 
building_id, 
product_id as '商品ID', 
consume_materials_ids as '消耗材料', 
sum(product_count) as '生产商品数量', 
sum(cast(consume_materials_count as int)) as '消耗材料数量',
count(distinct user_id) as  '账户数'
FROM fairy_town_server.server_building_produce_speed_up 
where 
day_time between ${beginDate} and ${endDate}
      and server_id in (${serverIds})
group by round(cast(map_id as int)/10000,0), building_id, product_id, consume_materials_ids
) t
group by map_id, building_id
order by 地图ID