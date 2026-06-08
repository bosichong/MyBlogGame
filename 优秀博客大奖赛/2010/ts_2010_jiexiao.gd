extends Node2D
const SCENE_PATH = "res://优秀博客大奖赛/ts_main.tscn"

func _ready() -> void:
    _grant_title()
    _update_con_content()

func _grant_title() -> void:
    var sp = GDManager.get_story_progress()
    sp.set_completed(2, "award_2010")

func _update_con_content() -> void:
    var con_label: Label = get_node_or_null("Panel/con")
    if not con_label:
        return

    var player_name: String = str(Blogger.blog_data.get("blog_name", "我的博客"))

    var content := ""
    content += "恭喜您的博客「%s」入围第 2 届「中文优秀博客大奖」！\n\n" % player_name
    content += "您从本届 200+ 提名中脱颖而出，成为 20 位入围者之一。\n\n"
    content += "您获得称号「博客新锐（2010）」！\n\n"
    content += "评语：「八年来，您用一篇篇文章证明，独立博客不会消亡。」"

    con_label.text = content

func _on_button_pressed() -> void:
    Utils.goto_scene(SCENE_PATH)
