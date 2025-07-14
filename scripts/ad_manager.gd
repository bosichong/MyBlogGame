extends Node


var ads = [
	{
		"name":"文字广告",
		"tip":"在页面上展示一行文字链接，点击进入广告页面。",
		"disabled":false,
		"pressed":false,
		"ctr" : 0.003,# 点击率
		"commission":0.1,# 佣金
		"affect":0.0 #对访问量的最终影响
	},
	{
		"name":"图文广告",
		"tip":"在页面上展示图片与文字并链接，点击进入广告页面。",
		"disabled":false,
		"pressed":false,
		"ctr" : 0.005,#
		"commission":0.1,
		"affect":0.1
	},
	{
		"name":"全站图文",
		"tip":"在所有页面上多个位置展示图片并链接，点击进入广告页面。
		对访问量有一定影响。",
		"disabled":false,
		"pressed":false,
		"ctr" : 0.01,#
		"commission":0.1,
		"affect":0.3
	},
	{
		"name":"弹窗广告",
		"tip":"在所有页面上弹出一个展示页面展示广告，点击进入广告主页面。
		对访问量有很大的影响。",
		"disabled":false,
		"pressed":false,
		"ctr" : 0.01,#
		"commission":0.1,
		"affect":0.5
	},
]

var ad_set = "文字广告" # 当前博客选择的广告投放模式

var ad_0 = true # 注册
var ad_1 = false # 审核
var ad_2 = false # 管理

var ad_1_day = 0
signal sig_ad_1_day # 审核截止日期信号量


var ad_money_0 = 0.0 #周期未结算佣金
var ad_money_1 = 0.0 #周期已结算佣金
var ad_money_2 = 0.0 #累计已发放的所有佣金

#这个数组中存放着每日的广告统计，每条数据包括:日期，点击率，广告类型
var ad_data = [] # 所有广告的统计


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if TimerManager:
		TimerManager.connect("s_ad_money_1",_on_s_ad_money_1) # 每月最后一天结算佣金
		TimerManager.connect("s_ad_money_2",_on_s_ad_money_2) # 每月第二周第一天发放佣金
	
	
func get_ad_by_name(name: String) -> Dictionary:
	for ad in ads:
		if ad["name"] == name:
			return ad
	return {}  # 如果未找到，返回空字典

func _on_s_ad_money_1():
	ad_money_1 = ad_money_0
	ad_money_0 = 0.0
	
func _on_s_ad_money_2():
	ad_money_2 += ad_money_1
	ad_money_1 = 0.0
	
	

# 从广告联盟赚取佣金
func update_ad(views):
	var ad = get_ad_by_name(AdManager.ad_set)
	var end_views = views - int(views * ad.affect)
	
	#联盟的访问量福利，访问量越高，点击率也会越高
	var ctr = 0.0
	var commission = 0.0
	if views <=1000:
		ctr = ad.ctr
		commission = ad.commission
	elif views >1000 and views <= 3000:
		ctr = ad.ctr + 0.005
		commission = ad.commission + 0.05
	elif views >3000 and views <= 5000:
		ctr = ad.ctr + 0.01
		commission = ad.commission + 0.1
	elif views >5000 and views <= 10000:
		ctr = ad.ctr + 0.02
		commission = ad.commission + 0.15
	elif views >10000 and views <= 30000:
		ctr = ad.ctr + 0.03
		commission = ad.commission + 0.2
	elif views >30000 and views <= 100000:
		ctr = ad.ctr + 0.05
		commission = ad.commission + 0.22
	else :
		ctr = ad.ctr + 0.1
		commission = ad.commission + 0.25
	
	var today_money = int(end_views * ctr )* commission
	ad_money_0 += today_money
	var today = Utils.format_date()
	ad_data.append([today,today_money])
	#print(ad_data)
	
	return end_views
	
func ad_day():
	print(ad_1,ad_1_day)
	if ad_1:
		ad_1_day += 1
		if ad_1_day == 3 :
			emit_signal("sig_ad_1_day")
			
			
			

	
		
