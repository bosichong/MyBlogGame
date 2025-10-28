extends VBoxContainer

signal time_x
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass




func _on_time_stop_pressed() -> void:
    if TimerManager.time_stop :
        $h1/time_stop.text = "暂停时间"
        TimerManager.time_stop = false
        TimerManager.timer.start()
    else:
        $h1/time_stop.text = "启动时间"
        TimerManager.time_stop = true
        TimerManager.timer.stop()


func _on_time_x_pressed() -> void:
    emit_signal("time_x")
