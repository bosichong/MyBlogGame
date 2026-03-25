extends Control

signal close_calendar_passed

func _on_close_pressed() -> void:
	emit_signal("close_calendar_passed")