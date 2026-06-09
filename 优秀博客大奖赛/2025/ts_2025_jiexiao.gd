extends Node2D
const SCENE_PATH = "res://scenes/main.tscn"

func _ready() -> void:
    _grant_title()
    _update_con_content()

func _grant_title() -> void:
    var sp = GDManager.get_story_progress()
    sp.set_completed(3, "award_2025")

func _update_con_content() -> void:
    var con_label: Label = get_node_or_null("Panel/con")
    if not con_label:
        return

    var player_name: String = str(Blogger.blog_data.get("blog_name", "我的博客"))

    var content := ""
    content += "第 5 届「中文优秀博客大奖」获奖名单正式公布——\n\n"
    content += "本届共有 6 位博主荣获优秀博客大奖，「%s」是其中之一！\n\n" % player_name
    content += "您获得称号「优秀博客（2015）」！\n\n"
    content += "评语：「您的博客代表了中文独立博客的精神。在这个喧嚣的时代，您守住了自己的角落。」"

    con_label.text = content

func _on_button_pressed() -> void:
    TimerManager.start_timer()
    Utils.goto_scene(SCENE_PATH)
