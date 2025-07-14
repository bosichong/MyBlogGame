extends HFlowContainer
# 存储当前的 ButtonGroup，方便在重新创建时使用
var current_button_group: ButtonGroup

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_on_show_panel()

func _on_show_panel():
	# 在面板显示时重新创建单选框
	# 直接创建一个新的 ButtonGroup 实例
	current_button_group = ButtonGroup.new()
	# 清除之前的子节点
	for child in get_children().duplicate():
		if child is HFlowContainer:
			remove_child(child)
			child.queue_free()
	print("重绘面板")
	Utils.create_ad_checkbox(self,AdManager.ads,current_button_group,_on_checkbox_toggled)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func _on_checkbox_toggled(button_pressed, option):
	if button_pressed:
		print("选项 '" + option + "' 被选中")
		AdManager.ad_set = option
		print(AdManager.ad_set)
