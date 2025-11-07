extends Node2D
const SCENE_PATH = "res://scenes/s003/s_003.tscn"
@onready var hbc = $Control/VBoxContainer/HBoxContainer3/HBoxContainer
@onready var tip = $Control/VBoxContainer/HBoxContainer3/tip
@onready var blogname = $Control/VBoxContainer/HBoxContainer/bname
@onready var username = $Control/VBoxContainer/HBoxContainer2/uname
var current_button_group: ButtonGroup

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    current_button_group = ButtonGroup.new()
    _on_show_panel()
    
func _on_show_panel():
    # 构建单选
    # 清除之前的子节点
    
    var children = hbc.get_children()
    for child in children: # 使用 duplicate() 避免遍历时修改集合
        if child is FlowContainer or child is Label:
            remove_child(child)
            child.queue_free()
    #print("重绘面板1")
    create_radio_buttons()
    #print(Blogger.Blog_Type)
    tip.text = Strs.blog_type_tip[Blogger.Blog_Type.keys()[Blogger.myblog_type]]


func _on_radio_button_pressed(enum_value):
    Blogger.myblog_type = enum_value
    tip.text = Strs.blog_type_tip[Blogger.Blog_Type.keys()[Blogger.myblog_type]]
    print("博客类型已更新为: ", Blogger.Blog_Type.keys()[enum_value])
    # 在这里可以添加其他更新逻辑

func create_radio_buttons():
    var enum_names = Blogger.Blog_Type.keys()
    
    for i in enum_names.size():
        var check_box = CheckBox.new()
        check_box.button_group = current_button_group  # 使用 button_group 而不是 group
        check_box.text = enum_names[i] as String
        check_box.name = "RadioBtn_" + enum_names[i]
        
        # 设置初始选中状态
        if i == Blogger.myblog_type:
            check_box.button_pressed = true
        
        # 连接按下信号
        check_box.pressed.connect(
            func():
                if check_box.button_pressed:
                    _on_radio_button_pressed(i)
        )
        
        hbc.add_child(check_box)


func _on_startgame_pressed() -> void:
    Blogger.blog_data.blog_author = Blogger
    Blogger.blog_data.blog_name = username
    Utils.goto_scene(SCENE_PATH)
    
    
