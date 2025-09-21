extends Control

signal close_calendar_passed

@onready var scs : Array[ScrollContainer] = [
    $"bg/选项组/sc1",
    $"bg/选项组/sc2",
    $"bg/选项组/sc3",
    $"bg/选项组/sc4",
    $"bg/选项组/sc5",
    $"bg/选项组/sc6",
    $"bg/选项组/sc7",
] 

@onready var buttons: Array[Button] = [
    $"bg/按钮组/vb/mc1/b1",
    $"bg/按钮组/vb/mc2/b2",
    $"bg/按钮组/vb/mc3/b3",
    $"bg/按钮组/vb/mc4/b4",
    $"bg/按钮组/vb/mc5/b5",
    $"bg/按钮组/vb/mc6/b6",
    $"bg/按钮组/vb/mc7/b7",
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    show_scroll_container(1)
    


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
    


func _on_button_pressed() -> void:
    emit_signal("close_calendar_passed")


func _on_b_1_pressed() -> void:
    show_scroll_container(1)
    set_button_pressed(0)


func _on_b_2_pressed() -> void:
    show_scroll_container(2)
    set_button_pressed(1)


func _on_b_3_pressed() -> void:
    show_scroll_container(3)
    set_button_pressed(2)


func _on_b_4_pressed() -> void:
    show_scroll_container(4)
    set_button_pressed(3)


func _on_b_5_pressed() -> void:
    show_scroll_container(5)
    set_button_pressed(4)


func _on_b_6_pressed() -> void:
    show_scroll_container(6)
    set_button_pressed(5)


func _on_b_7_pressed() -> void:
    show_scroll_container(7)
    set_button_pressed(6)


# 控制显示的方法
func show_scroll_container(index: int) -> void:
    for i in range(scs.size()):
        if i == index - 1:  # 因为数组是0开始，index从1开始
            scs[i].visible = true
        else:
            scs[i].visible = false
            
# 返回当前显示的 ScrollContainer 的数组索引（0-based）
func get_visible_scroll_array_index() -> int:
    for i in range(scs.size()):
        if scs[i].visible:
            return i  # 返回数组下标
    return -1  # 没有可见项时返回 -1

# 设置指定索引的按钮为按下状态，其余取消
func set_button_pressed(index: int):
    for i in range(buttons.size()):
        if i == index:
            buttons[i].set_pressed(true)
        else:
            buttons[i].set_pressed(false)
