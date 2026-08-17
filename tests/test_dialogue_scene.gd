extends Control

## 对话系统调试试用场景
## 启动即显示调试菜单，点击按钮播放对白；结束/Esc 返回后重新显示菜单

func _ready() -> void:
    DialogueManager.return_from_dialogue = false
    _show_debug_panel(true)

func _show_debug_panel(v: bool) -> void:
    if has_node("Panel"):
        $Panel.visible = v

func _on_play_pressed() -> void:
    DialogueManager.play("example", true)

func _on_play_intro_pressed() -> void:
    DialogueManager.play("blog_intro", true)

func _on_play_hacker_pressed() -> void:
    DialogueManager.play("hacker_identity", true)

func _on_play_theme_pressed() -> void:
    DialogueManager.play("theme_review", true)

func _on_back_pressed() -> void:
    Utils.goto_scene("res://scenes/main.tscn")
