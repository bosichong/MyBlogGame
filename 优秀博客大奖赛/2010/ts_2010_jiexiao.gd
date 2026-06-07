extends Node2D
const SCENE_PATH = "res://优秀博客大奖赛/ts_main.tscn"

## 缓存随机抽中的第一名（场景生命周期内保持稳定）
var _first_place_winner: Dictionary = {}


func _ready() -> void:
    _first_place_winner = _pick_random_top10_winner()
    _update_con_content()


func _update_con_content() -> void:
    var con_label: Label = get_node_or_null("Panel/con")
    if not con_label:
        return

    # 玩家属性（Blogger.blog_data 是动态计算的字典）
    var player_name: String = str(Blogger.blog_data.get("blog_name", "我的博客"))
    var player_author: String = str(Blogger.blog_data.get("blog_author", "博主"))
    var player_lv: int = int(Blogger.level)

    # 第一名属性（来自江湖榜前十随机抽取）
    var winner_name: String = "未知博主"
    var winner_author: String = "未知"
    var winner_lv: int = 1
    if not _first_place_winner.is_empty():
        winner_name = str(_first_place_winner.get("blog_name", winner_name))
        winner_author = str(_first_place_winner.get("blog_author", winner_author))
        winner_lv = int(_first_place_winner.get("lv", winner_lv))

    var content := ""
    content += "现在，公布第 1 届「中文优秀博客大奖」的结果——\n\n"
    content += "本届第一名是 —— 「%s」！\n" % winner_name
    content += "（作者：%s · Lv.%d）\n\n" % [winner_author, winner_lv]
    content += "恭喜您的博客「%s」> 入围第 2 届「中文优秀博客大赛」！\n" % player_name
    content += "（作者：%s · Lv.%d）\n\n" % [player_author, player_lv]
    content += "评语：「三年坚持，初心未改。您的博客是中文独立博客圈新生的力量。」"

    con_label.text = content


## 从江湖榜（Lm.jhph）前十名中随机抽取一名作为本届第一名
func _pick_random_top10_winner() -> Dictionary:
    if Lm == null or Lm.jhph.is_empty():
        return {}
    var top_n: int = min(10, Lm.jhph.size())
    var idx: int = randi() % top_n
    return Lm.jhph[idx]


func _on_button_pressed() -> void:
    Utils.goto_scene(SCENE_PATH)
