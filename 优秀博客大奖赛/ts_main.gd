extends Node2D
const SCENE_TZ = "res://优秀博客大奖赛/tongzhi.tscn"
const SCENE_PX = "res://优秀博客大奖赛/pingxuan.tscn"
const SCENE_JX_WEB = "res://优秀博客大奖赛/jiexiao_web.tscn"
const SCENE_JX_XIANCHANG = "res://优秀博客大奖赛/jiexiao_xianchang.tscn"

func _on_button_pressed() -> void:
    if TaskManager:
        TaskManager.pending_scene_params.notification_ordinal = 1
    Utils.goto_scene(SCENE_TZ)


func _on_button_2_pressed() -> void:
    if TaskManager:
        TaskManager.pending_scene_params.notification_ordinal = 1
    Utils.goto_scene(SCENE_PX)


func _on_button_4_pressed() -> void:
    if TaskManager:
        TaskManager.pending_scene_params.notification_ordinal = 2
    Utils.goto_scene(SCENE_TZ)


func _on_button_5_pressed() -> void:
    if TaskManager:
        TaskManager.pending_scene_params.notification_ordinal = 2
    Utils.goto_scene(SCENE_PX)


func _on_button_7_pressed() -> void:
    if TaskManager:
        TaskManager.pending_scene_params.notification_ordinal = 3
    Utils.goto_scene(SCENE_TZ)


func _on_button_8_pressed() -> void:
    if TaskManager:
        TaskManager.pending_scene_params.notification_ordinal = 3
    Utils.goto_scene(SCENE_PX)


func _on_button_10_pressed() -> void:
    if TaskManager:
        TaskManager.pending_scene_params.notification_ordinal = 4
    Utils.goto_scene(SCENE_TZ)


func _on_button_11_pressed() -> void:
    if TaskManager:
        TaskManager.pending_scene_params.notification_ordinal = 4
    Utils.goto_scene(SCENE_PX)


func _on_button_12_pressed() -> void:
    if TaskManager:
        TaskManager.pending_scene_params.notification_ordinal = 5
    Utils.goto_scene(SCENE_TZ)


func _on_button_13_pressed() -> void:
    if TaskManager:
        TaskManager.pending_scene_params.notification_ordinal = 5
    Utils.goto_scene(SCENE_PX)


func _on_test_not_nominated() -> void:
    if TaskManager:
        TaskManager.pending_scene_params.test_award_result = AwardManager.AwardResult.NONE
    Utils.goto_scene(SCENE_JX_WEB)


func _on_test_nominated() -> void:
    if TaskManager:
        TaskManager.pending_scene_params.test_award_result = AwardManager.AwardResult.NOMINATE
    Utils.goto_scene(SCENE_JX_WEB)


func _on_test_shortlisted() -> void:
    if TaskManager:
        TaskManager.pending_scene_params.test_award_result = AwardManager.AwardResult.SHORTLIST
    Utils.goto_scene(SCENE_JX_WEB)


func _on_test_won() -> void:
    if TaskManager:
        TaskManager.pending_scene_params.test_award_result = AwardManager.AwardResult.WIN
        TaskManager.pending_scene_params.test_is_repeat = false
    Utils.goto_scene(SCENE_JX_XIANCHANG)


func _on_test_repeat_won() -> void:
    if TaskManager:
        TaskManager.pending_scene_params.test_award_result = AwardManager.AwardResult.WIN
        TaskManager.pending_scene_params.test_is_repeat = true
    Utils.goto_scene(SCENE_JX_XIANCHANG)
