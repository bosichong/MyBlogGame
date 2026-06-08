extends Node2D
const SCENE_PATH = "res://优秀博客大奖赛/ts_main.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass


func _on_button_pressed() -> void:
    Utils.goto_scene(SCENE_PATH)
