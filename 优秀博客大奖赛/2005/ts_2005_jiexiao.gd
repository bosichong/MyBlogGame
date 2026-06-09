extends Node2D
const SCENE_PATH = "res://scenes/main.tscn"

func _ready() -> void:
    _grant_title()
    _update_con_content()

func _grant_title() -> void:
    var sp = GDManager.get_story_progress()
    sp.set_completed(1, "award_2005")

func _update_con_content() -> void:
    var con_label: Label = get_node_or_null("Panel/con")
    if not con_label:
        return

    var player_name: String = str(Blogger.blog_data.get("blog_name", "我的博客"))

    var content := ""
    content += "恭喜您的博客「%s」获得第 1 届「中文优秀博客大奖」提名！\n\n" % player_name
    content += "本届共有 50 位优秀博主获得提名，您的博客名列其中。\n\n"
    content += "您获得称号「博客新星（2005）」！\n\n"
    content += "评语：「三年坚持，初心未改。您的博客是中文独立博客圈新生的力量。」"

    con_label.text = content

func _on_button_pressed() -> void:
    TimerManager.start_timer()
    Utils.goto_scene(SCENE_PATH)
