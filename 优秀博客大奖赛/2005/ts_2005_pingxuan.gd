extends Node2D
const SCENE_PATH = "res://scenes/main.tscn"

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
    if anim_name == "main":
        TimerManager.start_timer()
        Utils.goto_scene(SCENE_PATH)
        
