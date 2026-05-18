extends VBoxContainer

# 体力显示Label
var stamina_label: Label
# 弹窗提示
var stamina_popup: AcceptDialog
# 阻止选择的标志
var blocking_selection: bool = false

# 根据节点名自动计算 KEY（d1 -> 0, d2 -> 1, ...）
var KEY: int:
    get:
        var name = get_name()
        return int(name.substr(1)) - 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    _create_stamina_popup()
    _on_show_panel()

func _create_stamina_popup() -> void:
    stamina_popup = AcceptDialog.new()
    stamina_popup.title = "体力不足"
    stamina_popup.dialog_text = ""
    add_child(stamina_popup)

func _on_show_panel():
    for child in get_children().duplicate():
        if child is FlowContainer or child is Label or child is PanelContainer:
            remove_child(child)
            child.queue_free()

    _create_schedule_preview()
    _create_stamina_display()

    Utils.create_all_checkbox(self, KEY, _on_checkbox_toggled)

    _update_schedule_preview()
    _update_stamina_display()

func _create_schedule_preview() -> void:
    var container = PanelContainer.new()
    container.custom_minimum_size.y = 60
    
    var vbox = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 5)
    container.add_child(vbox)
    
    var title_label = Label.new()
    title_label.text = "📋 当前已选择的日程："
    title_label.add_theme_font_size_override("font_size", 14)
    title_label.add_theme_color_override("font_color", Color(1, 0.84, 0, 1))
    vbox.add_child(title_label)
    
    var content_label = Label.new()
    content_label.name = "schedule_content"
    content_label.autowrap_mode = TextServer.AUTOWRAP_WORD
    content_label.add_theme_font_size_override("font_size", 13)
    content_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
    vbox.add_child(content_label)
    
    add_child(container)

func _update_schedule_preview() -> void:
    var blogger = GDManager.get_blogger()
    var tasks = Blogger.blog_calendar[KEY].tasks
    
    for child in get_children():
        if child is PanelContainer:
            for subchild in child.get_children():
                if subchild is VBoxContainer:
                    for label in subchild.get_children():
                        if label is Label and label.name == "schedule_content":
                            if tasks.size() == 0:
                                label.text = "（未选择任何日程）"
                            else:
                                label.text = "，" .join(tasks)

func _create_stamina_display() -> void:
    # 获取当前体力信息
    var blogger = GDManager.get_blogger()
    var max_stamina = Utils.get_max_stamina(blogger.level)
    var tasks = Blogger.blog_calendar[KEY].tasks
    var used_stamina = Utils.calculate_day_stamina(tasks)
    var remaining = max_stamina - used_stamina

    # 创建体力显示Label
    stamina_label = Label.new()
    stamina_label.text = "体力：%d / %d  (剩余: %d)" % [max_stamina, max_stamina, remaining]
    stamina_label.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2, 1))  # 绿色

    if remaining < 0:
        stamina_label.text = "体力：%d / %d  (超出: %d)" % [max_stamina, max_stamina, -remaining]
        stamina_label.add_theme_color_override("font_color", Color(1, 0.2, 0.2, 1))  # 红色

    add_child(stamina_label)

func _on_checkbox_toggled(button_pressed: bool, option: String) -> void:
    var blogger = GDManager.get_blogger()
    var max_stamina = Utils.get_max_stamina(blogger.level)

    if button_pressed:
        var current_used = Utils.calculate_day_stamina(Blogger.blog_calendar[KEY].tasks)
        var new_cost = Utils.get_task_stamina_cost(option)
        var total = current_used + new_cost

        print("DEBUG: option='%s', cost=%d, current_used=%d, total=%d, max=%d" % [option, new_cost, current_used, total, max_stamina])

        if total > max_stamina:
            var remaining = max_stamina - current_used
            var message = "体力不足！\n\n"
            message += "当前任务消耗: %d\n" % current_used
            message += "选择项目消耗: %d\n" % new_cost
            message += "总计需要: %d\n" % total
            message += "最大体力: %d\n" % max_stamina
            message += "剩余可用: %d\n\n" % remaining
            message += "请减少任务后再试！"

            # 立即恢复复选框为未选中状态
            _restore_checkbox_state(option)

            stamina_popup.dialog_text = message
            stamina_popup.popup_centered()

            print("警告：体力不足！需要 %d，最大 %d" % [total, max_stamina])
            return

        print("选项 '" + option + "' 被选中")
        if option not in Blogger.blog_calendar[KEY].tasks:
            Blogger.blog_calendar[KEY].tasks.append(option)
    else:
        print("选项 '" + option + "' 被取消")
        Blogger.blog_calendar[KEY].tasks.erase(option)

    print("当前任务：", Blogger.blog_calendar[KEY].tasks, "，体力消耗：", Utils.calculate_day_stamina(Blogger.blog_calendar[KEY].tasks))

    _update_schedule_preview()
    _update_stamina_display()

func _restore_checkbox_state(option: String) -> void:
    for child in get_children():
        if child is FlowContainer:
            for checkbox in child.get_children():
                if checkbox is CheckBox and checkbox.text == option:
                    checkbox.set_pressed_no_signal(false)
                    break

func _update_stamina_display() -> void:
    var blogger = GDManager.get_blogger()
    var max_stamina = Utils.get_max_stamina(blogger.level)
    var tasks = Blogger.blog_calendar[KEY].tasks
    var used_stamina = Utils.calculate_day_stamina(tasks)
    var remaining = max_stamina - used_stamina

    if stamina_label:
        stamina_label.text = "体力：%d / %d  (剩余: %d)" % [max_stamina, max_stamina, remaining]
        stamina_label.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2, 1))

        if remaining < 0:
            stamina_label.text = "体力：%d / %d  (超出: %d)" % [max_stamina, max_stamina, -remaining]
            stamina_label.add_theme_color_override("font_color", Color(1, 0.2, 0.2, 1))
