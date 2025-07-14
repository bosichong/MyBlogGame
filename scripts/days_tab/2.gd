extends VBoxContainer

const KEY = 2
# 存储当前的 ButtonGroup，方便在重新创建时使用
var current_button_group: ButtonGroup
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_button_group = ButtonGroup.new()
	Utils.create_all_checkbox(self,KEY,current_button_group,_on_checkbox_toggled)

func _on_show_panel():
	# 在面板显示时重新创建单选框
	# 直接创建一个新的 ButtonGroup 实例
	current_button_group = ButtonGroup.new()
	# 清除之前的子节点
	for child in get_children().duplicate(): # 使用 duplicate() 避免遍历时修改集合
		if child is FlowContainer or child is Label:
			remove_child(child)
			child.queue_free()
	Utils.create_all_checkbox(self, KEY, current_button_group, _on_checkbox_toggled)


func _on_checkbox_toggled(button_pressed, option):
	if button_pressed:
		print("选项 '" + option + "' 被选中")
		Blogger.blog_calendar[KEY].task = option
		print(Blogger.blog_calendar[KEY].task)
