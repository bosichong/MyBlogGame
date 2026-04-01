extends Control

@onready var popup_scene = preload("res://scenes/popup.tscn")
var popup: Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    $Panel/注册/内容.text = Strs.game_strs.广告联盟.注册简介
    $Panel/注册/内容.set_autowrap_mode(TextServer.AUTOWRAP_WORD_SMART)
    
    $Panel/审核/内容.text = Strs.game_strs.广告联盟.审核简介
    $Panel/审核/内容.set_autowrap_mode(TextServer.AUTOWRAP_WORD_SMART)
    
    on_show_panel()
    
    
    
func on_show_panel():
    # 判断当前状态，显示对应面板
    # 未注册且未审核：显示注册面板
    # 审核中：显示审核面板
    # 已通过审核：显示管理面板
    
    var show_register = not AdManager.ad_0 and not AdManager.ad_1 and not AdManager.ad_2
    var show_review = AdManager.ad_1 and not AdManager.ad_2
    var show_manage = AdManager.ad_2
    
    $Panel/管理.visible = show_manage
    $Panel/审核.visible = show_review
    $Panel/注册.visible = show_register
    
    $Panel/管理/Panel2/m_0.text = "未结算佣金：" + str(AdManager.ad_money_0)
    $Panel/管理/Panel2/m_1.text = "已结算佣金：" + str(AdManager.ad_money_1)
    $Panel/管理/Panel2/m_2.text = "累计发放佣金：" + str(AdManager.ad_money_2)
    
    # 注册按钮：周访问量 >= 100 才可点击
    # 使用当前周的实时访问量，而不是历史统计数据
    var current_week_views = Blogger.week_views if Blogger else 0
    if current_week_views >= 100:
        $Panel/注册/HBoxContainer/Btn1.disabled = false
    else:
        $Panel/注册/HBoxContainer/Btn1.disabled = true
    
func _on_btn_1_pressed() -> void:
    visible = false
    TimerManager.timer.start()
    TimerManager.time_stop = false


func _on_注册_pressed() -> void:
    # 点击注册按钮，进入审核状态
    if not AdManager.ad_0 and not AdManager.ad_1 and not AdManager.ad_2:
        AdManager.ad_1 = true  # 进入审核状态
        AdManager.ad_1_day = 0  # 重置审核天数
        $Panel/审核.visible = true
        $Panel/注册.visible = false
