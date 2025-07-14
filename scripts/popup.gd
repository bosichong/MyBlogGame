# Popup.gd
extends Control

@export var title: String = "标题"
@export var content: String = "内容"

@onready var background = $Background
@onready var title_label = $Panel/TitleBar/Title
@onready var content_label = $Panel/Content
@onready var close_button = $Panel/TitleBar/CloseButton
@onready var confirm_button = $Panel/ButtonContainer/ConfirmButton

# 自定义信号，当提示框关闭时触发
signal closed

func _ready():
	# 初始化标题和内容
	title_label.text = title
	content_label.text = content

	# 连接按钮信号
	close_button.pressed.connect(hide_popup)
	confirm_button.pressed.connect(hide_popup)

# 动态设置标题和内容
func set_title_and_content(new_title: String, new_content: String):
	title_label.text = new_title
	content_label.text = new_content

# 显示提示框
func show_popup():
	background.visible = true
	visible = true

# 隐藏提示框
func hide_popup(destroy: bool = true):
	background.visible = false
	visible = false
	emit_signal("closed")  # 触发关闭信号
	# 如果启用卸载，则销毁节点
	if destroy:
		queue_free()
