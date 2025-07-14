extends Control

signal close_calendar_passed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#visible = false
	
	#for day in range(7):
		#var button_group = ButtonGroup.new()
		#for category in Utils.possible_categories:
			#var checkbox = CheckBox.new()
			#checkbox.text = category.name
			#checkbox.disabled = category.disabled
			#print(Blogger.blog_calendar[day].task,"+",category.name)
			#if Blogger.blog_calendar[day].task == category.name:
				#checkbox.set_pressed_no_signal(category.pressed)
			#checkbox.button_group = button_group
			#var node = find_child(str(day))
			#node.add_child(checkbox)
			#checkbox.toggled.connect(_on_checkbox_toggled.bind(node.name,category.name))

#func _on_checkbox_toggled(button_pressed,node_name, option):
	#if button_pressed:
		#print("选项 '" + option + "' 被选中")
		## 更新写作类型的配置文件。
		#var key = int(node_name)
		#Blogger.blog_calendar[key].task = option
		
	

func _on_close_pressed() -> void:
	emit_signal("close_calendar_passed")
