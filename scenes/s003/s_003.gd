extends Node2D
const S03_SCENE_PATH = "res://scenes/s003/s_003.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    # 连接确认信号
    $AcceptDialog.confirmed.connect(_on_dialog_confirmed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
    if anim_name == "play":
        print("动画播放完了。")
        var title = "系统提示！" 
        var content = "看起来很不错的样子！那么，闲着也是无聊，我也去搞一个博客玩玩。"
        $AcceptDialog.title = title
        $AcceptDialog.dialog_text = content
        $AcceptDialog.set_size(Vector2i(400,200))
        $AcceptDialog.popup_centered()  
        
        
func _on_dialog_confirmed():
    # 只有当用户点击确认时才执行跳转
    Utils.goto_scene(S03_SCENE_PATH)
