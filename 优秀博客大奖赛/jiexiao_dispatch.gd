extends Node2D

const YEAR_MAP = {
    1: 2005, 2: 2010, 3: 2015, 4: 2020, 5: 2025,
}

const SCENE_WEB = "res://优秀博客大奖赛/jiexiao_web.tscn"
const SCENE_XIANCHANG = "res://优秀博客大奖赛/jiexiao_xianchang.tscn"

func _ready() -> void:
    var ordinal = 1
    if TaskManager and TaskManager.pending_scene_params.has("notification_ordinal"):
        ordinal = TaskManager.pending_scene_params.notification_ordinal

    var year = YEAR_MAP.get(ordinal, 2005)
    var player_name: String = str(Blogger.blog_data.get("blog_name", "我的博客"))
    var player_level: int = Blogger.level

    var result = AwardManager.process_award(ordinal, year, player_level, player_name)
    var is_win = result.result == AwardManager.AwardResult.WIN

    if TaskManager:
        TaskManager.pending_scene_params.notification_ordinal = ordinal
        TaskManager.pending_scene_params.award_result_data = result

    Utils.goto_scene(SCENE_XIANCHANG if is_win else SCENE_WEB)
