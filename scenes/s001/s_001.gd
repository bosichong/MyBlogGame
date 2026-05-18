extends Node2D

const MAIN_GAME_SCENE_PATH = "res://scenes/s002/s_002.tscn"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


func _on_new_game_pressed() -> void:
    Utils.goto_scene(MAIN_GAME_SCENE_PATH)
