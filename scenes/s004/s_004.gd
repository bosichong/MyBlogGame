extends Node2D
const S03_SCENE_PATH = "res://scenes/main.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    # 连接确认信号
    $AcceptDialog.confirmed.connect(_on_dialog_confirmed)


func _on_timer_timeout() -> void:
    print("end..........")
    var other_node = get_node('bg/s_004_01')
    var anim_player = other_node.get_node("AnimationPlayer")
    if anim_player:
        anim_player.stop()
        var title = "系统提示！" 
        var content = "经过一番折腾，博客终于搭建了，那么，2005年1月1日"+Blogger.blog_data.blog_name+"正式上线了！"
        $AcceptDialog.title = title
        $AcceptDialog.dialog_text = content
        $AcceptDialog.set_size(Vector2i(400,200))
        $AcceptDialog.popup_centered() 


func _on_dialog_confirmed():
    # 只有当用户点击确认时才执行跳转
    Utils.goto_scene(S03_SCENE_PATH)
