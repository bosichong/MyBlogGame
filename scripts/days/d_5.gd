extends VBoxContainer

const KEY = 4
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    _on_show_panel()

func _on_show_panel():
    # 清除之前的子节点
    for child in get_children().duplicate():
        if child is FlowContainer or child is Label:
            remove_child(child)
            child.queue_free()
    Utils.create_all_checkbox(self, KEY, _on_checkbox_toggled)


func _on_checkbox_toggled(button_pressed, option):
    if button_pressed:
        print("选项 '" + option + "' 被选中")
        if option not in Blogger.blog_calendar[KEY].tasks:
            Blogger.blog_calendar[KEY].tasks.append(option)
    else:
        print("选项 '" + option + "' 被取消")
        Blogger.blog_calendar[KEY].tasks.erase(option)
    print(Blogger.blog_calendar[KEY].tasks)