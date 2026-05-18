## 博客后台系统主控制器
## 管理四个面板的切换：数据看板、文章管理、友链管理、评论管理
extends Node

signal close_blog_dashboard

@onready var panels = [
    $bg/面板组/dashboard_panel,
    $bg/面板组/articles_panel,
    $bg/面板组/friendlinks_panel,
    $bg/面板组/comments_panel,
]

@onready var buttons: Array[Button] = [
    $bg/按钮组/vb/mc1/b1,
    $bg/按钮组/vb/mc2/b2,
    $bg/按钮组/vb/mc3/b3,
    $bg/按钮组/vb/mc4/b4,
]

## 数据看板节点引用
@onready var total_views_value = $bg/面板组/dashboard_panel/VBoxContainer/stats_grid/total_views_value
@onready var today_views_value = $bg/面板组/dashboard_panel/VBoxContainer/stats_grid/today_views_value
@onready var articles_value = $bg/面板组/dashboard_panel/VBoxContainer/stats_grid/articles_value
@onready var comments_value = $bg/面板组/dashboard_panel/VBoxContainer/stats_grid/comments_value
@onready var friendlinks_value = $bg/面板组/dashboard_panel/VBoxContainer/stats_grid/friendlinks_value
@onready var seo_value = $bg/面板组/dashboard_panel/VBoxContainer/stats_grid/seo_value
@onready var design_value = $bg/面板组/dashboard_panel/VBoxContainer/stats_grid/design_value
@onready var trend_container = $bg/面板组/dashboard_panel/VBoxContainer/trend_container

## 文章管理节点引用
@onready var articles_count_label = $bg/面板组/articles_panel/VBoxContainer/count_label
@onready var articles_list = $bg/面板组/articles_panel/VBoxContainer/articles_scroll/articles_list

## 友链管理节点引用
@onready var friendlinks_count_label = $bg/面板组/friendlinks_panel/ScrollContainer/VBoxContainer/count_label
@onready var friendlinks_list = $bg/面板组/friendlinks_panel/ScrollContainer/VBoxContainer/friendlinks_scroll/friendlinks_list
@onready var total_bonus_label = $bg/面板组/friendlinks_panel/ScrollContainer/VBoxContainer/total_bonus
@onready var apply_button = $bg/面板组/friendlinks_panel/ScrollContainer/VBoxContainer/apply_button
@onready var settings_panel = $bg/面板组/friendlinks_panel/ScrollContainer/VBoxContainer/settings_container
@onready var pending_container = $bg/面板组/friendlinks_panel/ScrollContainer/VBoxContainer/pending_scroll/pending_list

## 评论管理节点引用
@onready var comments_count_label = $bg/面板组/comments_panel/VBoxContainer/count_label
@onready var comments_list_container = $bg/面板组/comments_panel/VBoxContainer/comments_scroll/comments_list

var current_panel_index: int = 0

# 待删除的友链ID
var pending_delete_member_id: int = -1

# 自动设置UI引用
var min_level_spinbox: SpinBox
var auto_delete_invalid_check: CheckBox
var auto_delete_spam_check: CheckBox
var level_desc_label: Label
var _selected_member_id: int = -1

func _ready() -> void:
    # 默认显示数据看板
    show_panel(0)
    
    # 连接友链申请按钮
    if apply_button:
        apply_button.pressed.connect(_on_apply_friendlink_pressed)
    
    # 初始化自动设置UI
    _init_auto_settings_ui()

func _on_close_button_pressed() -> void:
    emit_signal("close_blog_dashboard")

## 显示指定面板
func show_panel(index: int) -> void:
    if index < 0 or index >= panels.size():
        return
    
    current_panel_index = index
    
    # 切换面板显示
    for i in range(panels.size()):
        panels[i].visible = (i == index)
    
    # 更新按钮状态
    set_button_pressed(index)
    
    # 刷新面板数据
    _refresh_panel(index)

## 设置按钮按下状态
func set_button_pressed(index: int) -> void:
    for i in range(buttons.size()):
        buttons[i].set_pressed(i == index)

## 刷新面板数据
func _refresh_panel(index: int) -> void:
    match index:
        0:
            refresh_dashboard()
        1:
            refresh_articles()
        2:
            refresh_friendlinks()
        3:
            refresh_comments()

## ==================== 数据看板 ====================

func refresh_dashboard() -> void:
    if not Blogger:
        return
    
    var blog_data = Blogger.blog_data
    
    total_views_value.text = Utils.format_number(blog_data.get("views", 0))
    today_views_value.text = str(blog_data.get("today_views", 0))
    articles_value.text = str(len(blog_data.get("posts", [])))
    
    var total_comments = 0
    for post in blog_data.get("posts", []):
        total_comments += post.get("comments", 0)
    comments_value.text = str(total_comments)
    
    var fl_manager = GDManager.get_friend_link_manager()
    if fl_manager:
        friendlinks_value.text = str(fl_manager.get_links().size())
    else:
        friendlinks_value.text = "0"
    
    seo_value.text = str(blog_data.get("seo_value", 0))
    design_value.text = str(blog_data.get("design_value", 0))
    
    _update_trend()

func _update_trend() -> void:
    for child in trend_container.get_children():
        child.queue_free()
    
    # 尝试从 Blogger 获取7天访问数据
    var weekly_views = []
    
    if Blogger and Blogger.blog_data.has("weekly_views_data"):
        weekly_views = Blogger.blog_data.get("weekly_views_data")
    
    if weekly_views.size() == 0:
        # 没有历史数据，显示提示
        var no_data_label = Label.new()
        no_data_label.text = "暂无7天访问数据"
        no_data_label.add_theme_font_size_override("font_size", 14)
        trend_container.add_child(no_data_label)
        return
    
    var days = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"]
    # 显示最近的数据（不足7天也显示）
    var display_count = mini(7, weekly_views.size())
    for i in range(display_count):
        var hbox = HBoxContainer.new()
        
        var day_label = Label.new()
        day_label.text = days[i]
        day_label.custom_minimum_size.x = 50
        hbox.add_child(day_label)
        
        var views = weekly_views[i] if i < weekly_views.size() else 0
        var value_label = Label.new()
        value_label.text = str(views)
        hbox.add_child(value_label)
        
        trend_container.add_child(hbox)

## ==================== 创作数据 ====================

func refresh_articles() -> void:
    if not Blogger:
        return
    
    var blog_data = Blogger.blog_data
    var posts = blog_data.get("posts", [])
    
    # 去重（按 id 去重）
    var unique_posts = []
    var seen_ids = {}
    for post in posts:
        var post_id = post.get("id", "")
        if post_id != "" and not seen_ids.has(post_id):
            seen_ids[post_id] = true
            unique_posts.append(post)
    
    articles_count_label.text = "创作统计 (共 %d 篇)" % unique_posts.size()
    
    for child in articles_list.get_children():
        child.queue_free()
    
    # 统计分类数据
    var category_stats = {}
    var novel_count = 0
    var book_count = 0
    var os_count = 0
    
    for post in unique_posts:
        var category = post.get("category", "未分类")
        if category_stats.has(category):
            category_stats[category] += 1
        else:
            category_stats[category] = 1
        
        # 特殊内容统计
        if category == "小说连载_付费" or category == "小说连载":
            novel_count += 1
        elif category == "出书笔记" or category == "出版畅销书":
            book_count += 1
        elif category == "开源项目" or category == "开源维护笔记":
            os_count += 1
    
    # 加载所有分类配置
    var categories_config = []
    var dir = DirAccess.open("res://data/blog_categories/")
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if file_name.ends_with(".gd") and file_name != "blog_categories.gd":
                var full_path = "res://data/blog_categories/" + file_name
                var script = load(full_path)
                if script:
                    var instance = script.new()
                    if "item" in instance:
                        categories_config.append(instance.get("item"))
            file_name = dir.get_next()
        dir.list_dir_end()
    
    # 创建自适应流容器
    var flow = HFlowContainer.new()
    flow.add_theme_constant_override("h_separation", 12)
    flow.add_theme_constant_override("v_separation", 12)
    articles_list.add_child(flow)
    
    # 显示分类统计
    # 先显示已有的文章分类
    var displayed_categories = {}
    for category_config in categories_config:
        var cat_name = category_config.get("name", "")
        if cat_name != "":
            var count = category_stats.get(cat_name, 0)
            displayed_categories[cat_name] = true
            var item = _create_category_item(cat_name, count)
            flow.add_child(item)
    
    # 显示其他分类（可能不在配置中的）
    for category in category_stats:
        if not displayed_categories.has(category):
            var count = category_stats.get(category, 0)
            var item = _create_category_item(category, count)
            flow.add_child(item)
    
    # 分隔符
    var separator = HSeparator.new()
    separator.custom_minimum_size.y = 10
    articles_list.add_child(separator)
    
    # 显示特殊创作内容统计
    if novel_count > 0 or blog_data.get("novel_batch_count", 0) > 0:
        var novel_item = _create_special_item("📚 小说创作", 
            blog_data.get("novel_batch_count", 0), 
            "第 %d 部小说，已发布 %d 篇" % [blog_data.get("novel_batch", 1), blog_data.get("novel_batch_count", 0)])
        articles_list.add_child(novel_item)
    
    if book_count > 0 or blog_data.get("is_writing_book", false):
        var book_item = _create_special_item("📖 出版书籍", 
            blog_data.get("book_article_count", 0), 
            "《%s》，已发布 %d 篇" % [blog_data.get("book_title", "无名之书"), blog_data.get("book_article_count", 0)])
        articles_list.add_child(book_item)
    
    if os_count > 0 or blog_data.get("is_developing_os", false):
        var os_item = _create_special_item("💻 开源项目", 
            blog_data.get("os_article_count", 0), 
            "项目《%s》，已发布 %d 篇技术文档" % [blog_data.get("os_project_name", "神秘项目"), blog_data.get("os_article_count", 0)])
        articles_list.add_child(os_item)

func _create_category_item(category_name: String, count: int) -> Control:
    var panel = PanelContainer.new()
    panel.custom_minimum_size.y = 45
    panel.custom_minimum_size.x = 140
    
    var vbox = VBoxContainer.new()
    vbox.add_theme_constant_override("separation", 4)
    panel.add_child(vbox)
    
    # 分类名称
    var name_label = Label.new()
    name_label.text = category_name
    name_label.add_theme_font_size_override("font_size", 16)
    name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    name_label.autowrap_mode = TextServer.AUTOWRAP_WORD
    vbox.add_child(name_label)
    
    # 数量
    var count_label = Label.new()
    count_label.text = "%d" % count
    count_label.add_theme_color_override("font_color", Color(0.9, 0.7, 0.2))
    count_label.add_theme_font_size_override("font_size", 20)
    count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    vbox.add_child(count_label)
    
    return panel

func _create_special_item(title: String, count: int, desc: String) -> Control:
    var panel = PanelContainer.new()
    panel.custom_minimum_size.y = 55
    
    var vbox = VBoxContainer.new()
    panel.add_child(vbox)
    
    # 标题行
    var title_hbox = HBoxContainer.new()
    title_hbox.add_theme_constant_override("separation", 10)
    vbox.add_child(title_hbox)
    
    var title_label = Label.new()
    title_label.text = title
    title_label.add_theme_font_size_override("font_size", 18)
    title_label.add_theme_color_override("font_color", Color(0.2, 0.8, 0.8))
    title_hbox.add_child(title_label)
    
    var count_label = Label.new()
    count_label.text = "(%d)" % count
    count_label.add_theme_color_override("font_color", Color(0.9, 0.7, 0.2))
    count_label.add_theme_font_size_override("font_size", 18)
    title_hbox.add_child(count_label)
    
    # 描述
    var desc_label = Label.new()
    desc_label.text = desc
    desc_label.add_theme_font_size_override("font_size", 14)
    desc_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
    vbox.add_child(desc_label)
    
    return panel

## ==================== 友链管理 ====================

func refresh_friendlinks() -> void:
    var fl_manager = GDManager.get_friend_link_manager()
    if not fl_manager:
        friendlinks_count_label.text = "友链列表 (0个)"
        return
    
    var links = fl_manager.get_links()
    friendlinks_count_label.text = "友链列表 (%d个)" % links.size()
    
    for child in friendlinks_list.get_children():
        child.queue_free()
    
    var sorted_links = links.duplicate()
    sorted_links.sort_custom(_compare_links_by_level_desc)
    
    for link in sorted_links:
        var item = _create_friendlink_item(link)
        friendlinks_list.add_child(item)
    
    var bonus = fl_manager.get_total_bonus()
    total_bonus_label.text = "总加成：流量+%d/日  SEO+%d" % [bonus.views_bonus, bonus.seo_bonus]
    
    refresh_pending_requests()

func _compare_links_by_level_desc(a: Dictionary, b: Dictionary) -> bool:
    return a.get("lv", 0) > b.get("lv", 0)

func _create_friendlink_item(link: Dictionary) -> Control:
    var panel = PanelContainer.new()
    panel.custom_minimum_size.y = 30
    
    var hbox = HBoxContainer.new()
    hbox.add_theme_constant_override("separation", 10)
    hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
    panel.add_child(hbox)
    
    var info_vbox = VBoxContainer.new()
    info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    info_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
    hbox.add_child(info_vbox)
    
    var name_label = Label.new()
    var level = link.get("lv", 1)
    var name = link.get("blog_name", "未知博客")
    var status = "active"
    var add_date = link.get("add_date", "")
    var status_text = "互链" if link.get("is_friend_link", false) else "待审"
    name_label.text = "%s (lv%d) [%s]" % [name, level, status_text]
    name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    info_vbox.add_child(name_label)
    
    var delete_btn = Button.new()
    delete_btn.text = "删除"
    delete_btn.custom_minimum_size.y = 24
    delete_btn.set_meta("member_id", link.get("id"))
    delete_btn.pressed.connect(_on_delete_friendlink_pressed.bind(link.get("id")))
    hbox.add_child(delete_btn)
    
    return panel

func _on_delete_friendlink_pressed(member_id: int) -> void:
    pending_delete_member_id = member_id
    _show_confirm_dialog("删除友链", "确定要删除这个友链吗？")

func _delete_friendlink(member_id: int) -> void:
    var fl_manager = GDManager.get_friend_link_manager()
    if fl_manager:
        fl_manager.delete_link(member_id)
        print("已删除友链ID: %d" % member_id)
        refresh_friendlinks()

func refresh_pending_requests() -> void:
    var fl_manager = GDManager.get_friend_link_manager()
    if not fl_manager:
        return
    
    for child in pending_container.get_children():
        child.queue_free()
    
    var requests = fl_manager.get_pending_requests()
    
    if requests.size() == 0:
        var empty_label = Label.new()
        empty_label.text = "暂无待处理申请"
        empty_label.add_theme_font_size_override("font_size", 12)
        pending_container.add_child(empty_label)
        return
    
    for req in requests:
        var item = _create_pending_request_item(req)
        pending_container.add_child(item)

func _create_pending_request_item(request: Dictionary) -> Control:
    var panel = PanelContainer.new()
    panel.custom_minimum_size.y = 30
    
    var hbox = HBoxContainer.new()
    hbox.add_theme_constant_override("separation", 15)
    panel.add_child(hbox)
    
    var member_id = request.get("member_id")
    var member_level = request.get("level", 1)
    var is_passive = request.get("is_passive", false)
    
    var info_vbox = VBoxContainer.new()
    info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    info_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
    hbox.add_child(info_vbox)
    
    var fl_manager = GDManager.get_friend_link_manager()
    var member_info = fl_manager.get_member_by_id(member_id) if fl_manager else {}
    var member_name = member_info.get("blog_name", "未知博客")
    var member_type = "对方申请" if is_passive else "我方申请"
    
    var name_label = Label.new()
    name_label.text = "%s (lv%d) - %s" % [member_name, member_level, member_type]
    name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    info_vbox.add_child(name_label)
    
    var tooltip_text = ""
    if is_passive:
        var rate_desc = fl_manager.get_success_rate_description(member_level) if fl_manager else "未知"
        tooltip_text = "维护时将根据设置自动处理，成功率：%s" % rate_desc
    else:
        var wait_days = request.get("wait_days", 0)
        var apply_date = request.get("apply_date", "未知")
        tooltip_text = "申请日期：%s\n预计等待：%d天" % [apply_date, wait_days]
    
    panel.tooltip_text = tooltip_text
    
    return panel

func _init_auto_settings_ui() -> void:
    if not settings_panel:
        return
    
    var fl_manager = GDManager.get_friend_link_manager()
    if not fl_manager:
        return
    
    var settings = fl_manager.get_auto_settings()
    
    for child in settings_panel.get_children():
        child.queue_free()
    
    var vbox = VBoxContainer.new()
    settings_panel.add_child(vbox)
    
    var title_label = Label.new()
    title_label.text = "⚙️ 自动处理设置"
    title_label.add_theme_font_size_override("font_size", 14)
    vbox.add_child(title_label)
    
    var hbox1 = HBoxContainer.new()
    hbox1.add_theme_constant_override("separation", 10)
    vbox.add_child(hbox1)
    
    var level_label = Label.new()
    level_label.text = "主动申请等级下限:"
    level_label.custom_minimum_size.x = 100
    hbox1.add_child(level_label)
    
    min_level_spinbox = SpinBox.new()
    min_level_spinbox.min_value = 0
    min_level_spinbox.max_value = 100
    min_level_spinbox.step = 5
    min_level_spinbox.value = settings.get("min_level_diff", 5)
    min_level_spinbox.custom_minimum_size.x = 80
    min_level_spinbox.value_changed.connect(_on_min_level_changed)
    hbox1.add_child(min_level_spinbox)
    
    level_desc_label = Label.new()
    level_desc_label.text = "(≥%d级的申请者自动通过)" % int(settings.get("min_level_diff", 5))
    level_desc_label.add_theme_font_size_override("font_size", 10)
    hbox1.add_child(level_desc_label)
    
    auto_delete_invalid_check = CheckBox.new()
    auto_delete_invalid_check.text = "失效链接自动删除"
    auto_delete_invalid_check.button_pressed = settings.get("auto_delete_invalid", true)
    auto_delete_invalid_check.toggled.connect(_on_auto_delete_invalid_toggled)
    vbox.add_child(auto_delete_invalid_check)
    
    auto_delete_spam_check = CheckBox.new()
    auto_delete_spam_check.text = "垃圾友链自动删除"
    auto_delete_spam_check.button_pressed = settings.get("auto_delete_spam", true)
    auto_delete_spam_check.toggled.connect(_on_auto_delete_spam_toggled)
    vbox.add_child(auto_delete_spam_check)

func _on_min_level_changed(value: float) -> void:
    var fl_manager = GDManager.get_friend_link_manager()
    if fl_manager:
        var settings = fl_manager.get_auto_settings()
        settings["min_level_diff"] = int(value)
        fl_manager.set_auto_settings(settings)
        level_desc_label.text = "(≥%d级的申请者自动通过)" % int(value)

func _on_auto_delete_invalid_toggled(toggled: bool) -> void:
    var fl_manager = GDManager.get_friend_link_manager()
    if fl_manager:
        var settings = fl_manager.get_auto_settings()
        settings["auto_delete_invalid"] = toggled
        fl_manager.set_auto_settings(settings)

func _on_auto_delete_spam_toggled(toggled: bool) -> void:
    var fl_manager = GDManager.get_friend_link_manager()
    if fl_manager:
        var settings = fl_manager.get_auto_settings()
        settings["auto_delete_spam"] = toggled
        fl_manager.set_auto_settings(settings)

func _on_apply_friendlink_pressed() -> void:
    _show_apply_dialog()

func _show_apply_dialog() -> void:
    var fl_manager = GDManager.get_friend_link_manager()
    if not fl_manager:
        return
    
    var available = fl_manager.get_available_members()
    
    if available.size() == 0:
        var dialog = AcceptDialog.new()
        dialog.title = "申请友链"
        dialog.dialog_text = "没有可申请的友链（所有联盟成员都已是友链或有待处理申请）"
        add_child(dialog)
        dialog.popup_centered()
        return
    
    var blogger = GDManager.get_blogger()
    if blogger and blogger.stamina < 5:
        var dialog = AcceptDialog.new()
        dialog.title = "申请友链"
        dialog.dialog_text = "体力不足，需要5点体力才能申请友链"
        add_child(dialog)
        dialog.popup_centered()
        return
    
    var dialog = ConfirmationDialog.new()
    dialog.title = "申请友链"
    dialog.ok_button_text = "申请"
    dialog.cancel_button_text = "取消"
    
    var scroll = ScrollContainer.new()
    scroll.custom_minimum_size.y = 250
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    
    var vbox = VBoxContainer.new()
    vbox.custom_minimum_size.y = 400
    scroll.add_child(vbox)
    
    var desc_label = Label.new()
    desc_label.text = "选择要申请友链的博客（消耗5点体力）:"
    vbox.add_child(desc_label)
    
    for member in available:
        var member_id = member.get("id")
        var name = member.get("blog_name", "未知")
        var level = member.get("lv", 1)
        var rate = fl_manager.get_success_rate_description(level)
        
        var member_btn = Button.new()
        member_btn.text = "• %s (lv%d) - 成功率: %s" % [name, level, rate]
        member_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
        member_btn.set_meta("member_id", member_id)
        member_btn.pressed.connect(_on_member_button_pressed.bind(member_id, member_btn, dialog, vbox))
        vbox.add_child(member_btn)
    
    var hint_label = Label.new()
    hint_label.text = "\n提示: 点击上方选项选择目标博客"
    hint_label.add_theme_font_size_override("font_size", 10)
    vbox.add_child(hint_label)
    
    dialog.add_child(scroll)
    add_child(dialog)
    dialog.confirmed.connect(_on_apply_dialog_confirmed.bind(dialog, vbox))
    
    dialog.popup_centered()
    dialog.min_size = Vector2(400, 350)

func _on_member_button_pressed(member_id: int, button: Button, dialog: ConfirmationDialog, vbox: VBoxContainer) -> void:
    _selected_member_id = member_id
    for child in vbox.get_children():
        if child is Button:
            child.add_theme_color_override("font_color", Color(1, 1, 1))
            if child.text.begins_with("►"):
                child.text = "• " + child.text.lstrip("► ")
    button.add_theme_color_override("font_color", Color(0, 1, 0))
    button.text = "► " + button.text.lstrip("• ")

func _on_apply_dialog_confirmed(dialog: ConfirmationDialog, vbox: VBoxContainer) -> void:
    # 如果没有选中成员，弹出警告并返回，不默认选择第一个
    if _selected_member_id == -1:
        var warn_dialog = AcceptDialog.new()
        warn_dialog.title = "请先选择"
        warn_dialog.dialog_text = "请先在列表中选择一个联盟成员，再点击申请。"
        add_child(warn_dialog)
        warn_dialog.popup_centered()
        dialog.queue_free()
        return
    
    var fl_manager = GDManager.get_friend_link_manager()
    if fl_manager:
        var result = fl_manager.apply_for_link(_selected_member_id)
        if result.get("success"):
            var dialog2 = AcceptDialog.new()
            dialog2.title = "申请已发送"
            dialog2.dialog_text = result.get("message", "申请已发送")
            add_child(dialog2)
            dialog2.popup_centered()
            refresh_friendlinks()
        else:
            var dialog2 = AcceptDialog.new()
            dialog2.title = "申请失败"
            dialog2.dialog_text = result.get("reason", "申请失败")
            add_child(dialog2)
            dialog2.popup_centered()
    
    _selected_member_id = -1
    dialog.queue_free()

## ==================== 评论管理 ====================

func refresh_comments() -> void:
    if not Blogger:
        return
    
    var blog_data = Blogger.blog_data
    var posts = blog_data.get("posts", [])
    var comment_manager = GDManager.get_comment_manager() if GDManager else null
    
    var total_comments = 0
    var post_comments = {}
    
    for post in posts:
        var post_id = int(post.get("id", 0))
        var comments_count = post.get("comments", 0)
        total_comments += comments_count
        
        if comments_count > 0 and comment_manager:
            var real_comments = comment_manager.get_comments(post_id)
            var display_comments = []
            for comment in real_comments:
                display_comments.append({
                    "commenter": "访客",
                    "content": comment.get("content", ""),
                    "date": comment.get("date", ""),
                    "status": comment.get("status", "normal"),
                    "source": comment.get("source", "league"),
                })
            if display_comments.is_empty():
                for i in range(min(comments_count, 3)):
                    display_comments.append({
                        "commenter": "访客%d" % (i + 1),
                        "content": "评论内容示例 %d" % (i + 1),
                        "date": post.get("date", ""),
                    })
            post_comments[post_id] = {
                "title": post.get("title", "无标题"),
                "comments": display_comments,
            }
        elif comments_count > 0:
            var comments = []
            for i in range(min(comments_count, 3)):
                comments.append({
                    "commenter": "访客%d" % (i + 1),
                    "content": "评论内容示例 %d" % (i + 1),
                    "date": post.get("date", ""),
                })
            post_comments[post_id] = {
                "title": post.get("title", "无标题"),
                "comments": comments,
            }
    
    comments_count_label.text = "评论列表 (%d条)" % total_comments
    
    for child in comments_list_container.get_children():
        child.queue_free()
    
    for post_id in post_comments:
        var post_data = post_comments[post_id]
        
        var title_panel = PanelContainer.new()
        var title_label = Label.new()
        title_label.text = "📌 《%s》" % post_data.title
        title_panel.add_child(title_label)
        comments_list_container.add_child(title_panel)
        
        for comment in post_data.comments:
            var comment_item = _create_comment_item(comment, post_id)
            comments_list_container.add_child(comment_item)

func _create_comment_item(comment: Dictionary, post_id: int) -> Control:
    var panel = PanelContainer.new()
    panel.custom_minimum_size.y = 40
    
    var hbox = HBoxContainer.new()
    panel.add_child(hbox)
    
    var commenter_label = Label.new()
    commenter_label.text = "○ %s: \"%s\" %s" % [comment.get("commenter", "匿名"), comment.get("content", ""), comment.get("date", "")]
    commenter_label.size_flags_horizontal = 3
    hbox.add_child(commenter_label)
    
    return panel

func _on_dialog_confirmed() -> void:
    if pending_delete_member_id != -1:
        _delete_friendlink(pending_delete_member_id)
        pending_delete_member_id = -1

func _on_dialog_canceled() -> void:
    pending_delete_member_id = -1

func _show_confirm_dialog(title: String, message: String) -> void:
    var dialog = ConfirmationDialog.new()
    dialog.title = title
    dialog.dialog_text = message
    dialog.ok_button_text = "确定"
    dialog.cancel_button_text = "取消"
    
    dialog.confirmed.connect(_on_dialog_confirmed)
    dialog.canceled.connect(_on_dialog_canceled)
    
    add_child(dialog)
    dialog.popup_centered()

## ==================== 按钮信号 ====================

func _on_b_1_pressed() -> void:
    show_panel(0)

func _on_b_2_pressed() -> void:
    show_panel(1)

func _on_b_3_pressed() -> void:
    show_panel(2)

func _on_b_4_pressed() -> void:
    show_panel(3)
