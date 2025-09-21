extends HBoxContainer

signal create_blog_passed
signal open_ad_passed
signal open_lm
signal open_bm

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass


func _on_button_pressed() -> void:
    emit_signal("create_blog_passed")
    


func _on_button_5_pressed() -> void:
    emit_signal("open_ad_passed")


func _on_button_4_pressed() -> void:
    emit_signal("open_lm")


func _on_button_1_pressed() -> void:
    emit_signal("open_bm")
