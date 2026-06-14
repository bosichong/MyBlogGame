extends Node2D
const SCENE_PATH = "res://scenes/main.tscn"
const ORDINAL = 2
const YEAR = 2010

func _ready() -> void:
    _update_content()

func _update_content() -> void:
    var player_name: String = str(Blogger.blog_data.get("blog_name", "我的博客"))
    var player_level: int = Blogger.level

    var result = AwardManager.process_award(ORDINAL, YEAR, player_level, player_name)

    var tit_label: Label = get_node_or_null("Panel/tit")
    if tit_label:
        tit_label.text = result.title

    var con_label: Label = get_node_or_null("Panel/con")
    if con_label:
        con_label.text = result.content

func _on_button_pressed() -> void:
    TimerManager.start_timer()
    Utils.goto_scene(SCENE_PATH)
