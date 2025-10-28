extends Control

@onready var tb = $mile/TB
@onready var lb = $mile/Label

@export var normal_texture = preload("res://assets/milestones/lv10.png")
var lb_text = "test"
var unlocked = true
var locked_icon = preload("res://assets/milestones/locked.png")
var description = "description"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    setup_ui()

# 添加公共方法来设置属性
func set_milestone_data(texture: Texture, text: String, ul: bool, li:Texture,desc:String):
    normal_texture = texture
    lb_text = text
    unlocked = ul
    locked_icon = li
    description = desc
    setup_ui()

func setup_ui():
    if lb:
        lb.set_text(lb_text)
    else:
        push_error("Label节点未找到，请检查节点路径")
    
    if tb and normal_texture and locked_icon:
        tb.set_tooltip_text(description)
        if not unlocked:
            tb.set_texture_normal(locked_icon)
        else:
            tb.set_texture_normal(normal_texture)
    else:
        push_error("TextureButton节点未找到或纹理为空")
        
    
