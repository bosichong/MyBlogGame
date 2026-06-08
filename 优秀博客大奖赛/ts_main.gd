extends Node2D
const SCENE_2005TZ = "res://优秀博客大奖赛/2005/ts2005tongzhi.tscn"
const SCENE_2005PX = "res://优秀博客大奖赛/2005/ts2005pingxuan.tscn"
const SCENE_2005JX = "res://优秀博客大奖赛/2005/ts2005jiexiao.tscn"
const SCENE_2010TZ = "res://优秀博客大奖赛/2010/ts2010tongzhi.tscn"
const SCENE_2010PX = "res://优秀博客大奖赛/2010/ts2010pingxuan.tscn"
const SCENE_2010JX = "res://优秀博客大奖赛/2010/ts2010jiexiao.tscn"
const SCENE_2015TZ = "res://优秀博客大奖赛/2015/ts2015tongzhi.tscn"
const SCENE_2015PX = "res://优秀博客大奖赛/2015/ts2015pingxuan.tscn"
const SCENE_2015JX = "res://优秀博客大奖赛/2015/ts2015jiexiao.tscn"
const SCENE_2020TZ = "res://优秀博客大奖赛/2020/ts2020tongzhi.tscn"
const SCENE_2020PX = "res://优秀博客大奖赛/2020/ts2020pingxuan.tscn"
const SCENE_2025TZ = "res://优秀博客大奖赛/2025/ts2025tongzhi.tscn"
const SCENE_2025PX = "res://优秀博客大奖赛/2025/ts2025pingxuan.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass


func _on_button_pressed() -> void:
    Utils.goto_scene(SCENE_2005TZ)


func _on_button_2_pressed() -> void:
    Utils.goto_scene(SCENE_2005PX)


func _on_button_3_pressed() -> void:
    Utils.goto_scene(SCENE_2005JX)


func _on_button_4_pressed() -> void:
    Utils.goto_scene(SCENE_2010TZ)


func _on_button_5_pressed() -> void:
    Utils.goto_scene(SCENE_2010PX)


func _on_button_6_pressed() -> void:
    Utils.goto_scene(SCENE_2010JX)


func _on_button_7_pressed() -> void:
    Utils.goto_scene(SCENE_2015TZ)


func _on_button_8_pressed() -> void:
    Utils.goto_scene(SCENE_2015PX)


func _on_button_9_pressed() -> void:
    Utils.goto_scene(SCENE_2015JX)


func _on_button_10_pressed() -> void:
    Utils.goto_scene(SCENE_2020TZ)


func _on_button_11_pressed() -> void:
    Utils.goto_scene(SCENE_2020PX)


func _on_button_12_pressed() -> void:
    Utils.goto_scene(SCENE_2025TZ)


func _on_button_13_pressed() -> void:
    Utils.goto_scene(SCENE_2025PX)
