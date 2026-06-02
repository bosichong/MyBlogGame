extends Node2D
const S04_SCENE_PATH = "res://scenes/s004/s_004.tscn"

var blog_domain: String = "suiyan.cc"

func _ready() -> void:
    $AcceptDialog.confirmed.connect(_on_dialog_confirmed)
    call_deferred("_update_email_domain")

func _update_email_domain() -> void:
    var blogger = GDManager.get_blogger()
    if blogger and blogger.blog_url:
        blog_domain = blogger.blog_url
    var con2_label = $email_ts/con2
    if con2_label:
        con2_label.text = "您好！\n\n我们正在推广独立博客服务，现送出100个免费域名和主机套餐。\n\n您的域名：%s\n主机：免费套餐（1年）\n\n点击下方按钮立即申请，开启您的博客之旅！" % blog_domain
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
    if anim_name == "play":
        var title = "博客启蒙"
        var content = "免费域名和主机？这封邮件，改变了一切。\n\n我决定，去申请一个属于自己的博客。"
        $AcceptDialog.title = title
        $AcceptDialog.dialog_text = content
        $AcceptDialog.set_size(Vector2i(400,200))
        $AcceptDialog.popup_centered()

func _on_dialog_confirmed():
    GDManager.get_story_progress().set_completed(1, "prologue_completed")
    Utils.goto_scene(S04_SCENE_PATH)

func _on_跳过游戏_pressed() -> void:
    GDManager.get_story_progress().set_completed(1, "prologue_completed")
    Utils.goto_scene(S04_SCENE_PATH)
