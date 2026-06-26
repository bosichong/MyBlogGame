extends Node2D
const SCENE_PATH = "res://scenes/main.tscn"
const CONFETTI_SCENE = preload("res://scenes/confetti.tscn")

const YEAR_MAP = {
    1: 2005, 2: 2010, 3: 2015, 4: 2020, 5: 2025,
}

func _ready() -> void:
    _update_content()

func _play_confetti_if_celebrated(award_result_value: int) -> void:
    if award_result_value in [AwardManager.AwardResult.NOMINATE, AwardManager.AwardResult.SHORTLIST]:
        var confetti = CONFETTI_SCENE.instantiate()
        confetti.auto_emit = false
        add_child(confetti)
        confetti.emit()

func _update_content() -> void:
    var player_name: String = str(Blogger.blog_data.get("blog_name", "我的博客"))
    var player_level: int = Blogger.level

    var ordinal = 1
    var year = 2005
    var result: Dictionary
    var award_result_value: int = AwardManager.AwardResult.NONE

    if TaskManager and TaskManager.pending_scene_params.has("award_result_data"):
        var award_data = TaskManager.pending_scene_params.award_result_data
        result = award_data
        award_result_value = result.get("result", AwardManager.AwardResult.NONE)
        if TaskManager.pending_scene_params.has("notification_ordinal"):
            ordinal = TaskManager.pending_scene_params.notification_ordinal
        TaskManager.pending_scene_params.erase("award_result_data")
        TaskManager.pending_scene_params.erase("notification_ordinal")
    elif TaskManager and TaskManager.pending_scene_params.has("test_award_result"):
        var test_result = TaskManager.pending_scene_params.test_award_result
        award_result_value = test_result
        var test_is_repeat = TaskManager.pending_scene_params.get("test_is_repeat", false)
        if TaskManager.pending_scene_params.has("test_ordinal"):
            ordinal = TaskManager.pending_scene_params.test_ordinal
        if TaskManager.pending_scene_params.has("test_year"):
            year = TaskManager.pending_scene_params.test_year
        var content = AwardManager.get_award_content(ordinal, year, player_name, test_result, test_is_repeat)
        var title = AwardManager.get_award_title(ordinal)
        result = {"title": title, "content": content, "label": AwardManager.get_result_label(test_result)}
        TaskManager.pending_scene_params.erase("test_award_result")
        TaskManager.pending_scene_params.erase("test_is_repeat")
        TaskManager.pending_scene_params.erase("test_ordinal")
        TaskManager.pending_scene_params.erase("test_year")
    else:
        year = YEAR_MAP.get(ordinal, 2005)
        result = AwardManager.process_award(ordinal, year, player_level, player_name)
        award_result_value = result.get("result", AwardManager.AwardResult.NONE)

    var tit_label: Label = get_node_or_null("Panel/tit")
    if tit_label:
        tit_label.text = result.get("title", "")

    var con_label: Label = get_node_or_null("Panel/con")
    if con_label:
        con_label.text = result.get("content", "")

    _play_confetti_if_celebrated(award_result_value)

func _on_button_pressed() -> void:
    TimerManager.start_timer()
    Utils.goto_scene(SCENE_PATH)
