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
        "commission":0.15,
        "affect":0.15
    },
    {
        "name":"弹窗广告",
        "tip":"在所有页面上弹出一个展示页面展示广告，点击进入广告主页面。
        对访问量有很大的影响。",
        "disabled":false,
        "pressed":false,
        "ctr" : 0.03,#
        "commission":0.2,
        "affect":0.3
    },
]

var ad_set: String:
    get:
        return GDManager.get_ad().current_ad_type if GDManager else "文字广告"
    set(value):
        if GDManager:
            GDManager.get_ad().set_ad_type(value)

var ad_0: bool:
    get:
        return GDManager.get_ad().is_registered if GDManager else false
    set(value):
        if GDManager:
            GDManager.get_ad().is_registered = value

var ad_1: bool:
    get:
        return GDManager.get_ad().is_under_review if GDManager else false
    set(value):
        if GDManager:
            GDManager.get_ad().is_under_review = value

var ad_2: bool:
    get:
        return GDManager.get_ad().is_approved if GDManager else false
    set(value):
        if GDManager:
            GDManager.get_ad().is_approved = value

var ad_1_day: int:
    get:
        return GDManager.get_ad().review_days if GDManager else 0
    set(value):
        if GDManager:
            GDManager.get_ad().review_days = value

signal sig_ad_1_day # 审核截止日期信号量
signal sig_ad_commission_settled(msg) # 佣金结算信号
signal sig_ad_commission_paid(msg) # 佣金发放信号


var ad_money_0: float:
    get:
        return GDManager.get_ad().pending_commission if GDManager else 0.0
    set(value):
        if GDManager:
            GDManager.get_ad().pending_commission = value

var ad_money_1: float:
    get:
        return GDManager.get_ad().settled_commission if GDManager else 0.0
    set(value):
        if GDManager:
            GDManager.get_ad().settled_commission = value

var ad_money_2: float:
    get:
        return GDManager.get_ad().total_commission if GDManager else 0.0
    set(value):
        if GDManager:
            GDManager.get_ad().total_commission = value

#这个数组中存放着每日的广告统计，每条数据包括:日期，点击率，广告类型
var ad_data: Array:
    get:
        return GDManager.get_ad().ad_statistics if GDManager else []
    set(value):
        if GDManager:
            GDManager.get_ad().ad_statistics = value


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
    # 结算佣金
    var amount = ad_money_0
    if amount > 0:
        emit_signal("sig_ad_commission_settled", "广告联盟佣金结算：%.2f 元" % amount)
    ad_money_1 = ad_money_0
    ad_money_0 = 0.0

func _on_s_ad_money_2():
    # 发放佣金到用户账户
    var payout = ad_money_1
    if payout > 0:
        if GDManager:
            GDManager.add_money(payout)
            emit_signal("sig_ad_commission_paid", "广告联盟佣金发放：%.2f 元，已转入账户" % payout)
        elif Blogger:
            Blogger.money += payout
    ad_money_2 += payout
    ad_money_1 = 0.0
    
    

# 从广告联盟赚取佣金
func update_ad(views):
    if not GDManager:
        return views

    var ad_data_obj = GDManager.get_ad()
    var ad = get_ad_by_name(ad_data_obj.current_ad_type)
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
    ad_data_obj.pending_commission += today_money
    var today = Utils.format_date()
    ad_data_obj.ad_statistics.append([today,today_money])
    #print(ad_data)

    return end_views
    
## 广告联盟审核时间刷新
func ad_day():
    if ad_1:
        ad_1_day += 1
        if ad_1_day == 3 :
            emit_signal("sig_ad_1_day")
            
            
            

    
        
