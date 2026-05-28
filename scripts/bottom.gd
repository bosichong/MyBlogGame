extends HBoxContainer

signal create_blog_passed
signal open_ad_passed
signal open_lm
signal open_bm
signal open_yun
signal open_mialestones
signal open_blog_dashboard

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var btn = $h2/Button4
    if btn and GDManager:
        var sp = GDManager.get_story_progress()
        if sp:
            btn.disabled = not sp.is_completed(1, "blog_union_joined")

func update_story_progress() -> void:
    var btn = $h2/Button4
    if btn and GDManager:
        var sp = GDManager.get_story_progress()
        if sp:
            btn.disabled = not sp.is_completed(1, "blog_union_joined")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass


func _on_button_pressed() -> void:
    emit_signal("create_blog_passed")
    


func _on_button_5_pressed() -> void:
    emit_signal("open_ad_passed")


func _on_button_4_pressed() -> void:
    emit_signal("open_lm")


func _on_button_1_pressed() -> void:
    emit_signal("open_bm")


func _on_open_yun_pressed() -> void:
   emit_signal("open_yun")


func _on_mialestones_pressed() -> void:
    emit_signal("open_mialestones")

func _on_blog_dashboard_btn_pressed() -> void:
    emit_signal("open_blog_dashboard")
