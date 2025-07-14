extends Control

@onready var popup_scene = preload("res://scenes/Popup.tscn")
var popup: Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Panel/注册/内容.text = Strs.game_strs.广告联盟.注册简介
	$Panel/注册/内容.set_autowrap_mode(TextServer.AUTOWRAP_WORD_SMART)
	
	$Panel/审核/内容.text = Strs.game_strs.广告联盟.审核简介
	$Panel/审核/内容.set_autowrap_mode(TextServer.AUTOWRAP_WORD_SMART)
	
	_on_show_panel()
	
	
	
func _on_show_panel():
	print("重绘AD面板")
	
	
	
	$Panel/管理.visible = AdManager.ad_2
	$Panel/审核.visible = AdManager.ad_1
	$Panel/注册.visible = AdManager.ad_0
	$Panel/管理/Panel2/m_0.text = "未结算佣金：" + str(AdManager.ad_money_0)
	$Panel/管理/Panel2/m_1.text = "已结算佣金：" + str(AdManager.ad_money_1)
	$Panel/管理/Panel2/m_2.text = "累计发放佣金：" + str(AdManager.ad_money_2)
	
	if Tongji.t_w.size() > 0:
		var w_views = Tongji.t_w[Tongji.t_w.size()-1][1]
		if w_views / 1 >= 100 :
			$Panel/注册/HBoxContainer/Btn1.disabled = false
		else:
			$Panel/注册/HBoxContainer/Btn1.disabled = true
	else:
		$Panel/注册/HBoxContainer/Btn1.disabled = true
	
func _on_btn_1_pressed() -> void:
	visible = false
	TimerManager.timer.start()
	TimerManager.time_stop = false


func _on_注册_pressed() -> void:
	#平均访问量
	if AdManager.ad_0 == true and AdManager.ad_1 == false :
		AdManager.ad_0 = false
		AdManager.ad_1 = true
		$Panel/审核.visible = AdManager.ad_1
		$Panel/注册.visible = AdManager.ad_0
