extends Node

var _book_publish_instance = null

var emit_info_msg: Callable = func(_msg): pass
var emit_popup_msg: Callable = func(_title, _content): pass

func _init():
    _book_publish_instance = preload("res://data/book_publish.gd").new()

func set_signal_callbacks(info_callback: Callable, popup_callback: Callable):
    emit_info_msg = info_callback
    emit_popup_msg = popup_callback

func is_book_writing() -> bool:
    if not _book_publish_instance:
        return false
    var book_state = _book_publish_instance.current_book_state
    return book_state.get("is_writing", false) or book_state.get("published", false)

func action_start_book_write() -> void:
    if not _book_publish_instance:
        return
    
    var book_state = _book_publish_instance.current_book_state
    
    var d = Utils.find_category_by_name(Utils.possible_categories, "出版畅销书", true) if Utils else null
    if d != null:
        d.disabled = false
        d.isVisible = true
    
    book_state.is_writing = true
    
    emit_info_msg.call("📖 文学能力达到90级，可以开始创作畅销书了！\n\n💡 提示：发布5篇后，将进入出版社审核阶段！")

func action_book_progress(progress: int) -> void:
    var book_state = _get_or_create_book_state()
    var is_first_article = book_state.get("write_days", 0) == 0
    
    if is_first_article:
        var blogger = null
        if GDManager and GDManager.has_method("get_blogger"):
            blogger = GDManager.get_blogger()
        if blogger and blogger.is_writing_book:
            if not book_state.get("is_writing", false):
                book_state.is_writing = true
            
            var book_notes = Utils.find_category_by_name(Utils.possible_categories, "出书笔记", true) if Utils else null
            if book_notes != null and book_notes.disabled:
                book_notes.disabled = false
                book_notes.isVisible = true
                print("[出版畅销书] 第一次写书，已解锁出书笔记类型")
    
    if book_state.get("is_writing", false):
        book_state.write_days += 1
        book_state.total_progress += progress
        
        # 获取书名，优先从 book_state 取，否则从 blogger 取，并保存到 book_state
        var book_name = book_state.get("book_name", "")
        if book_name == "":
            if GDManager and GDManager.has_method("get_blogger"):
                var blogger = GDManager.get_blogger()
                if blogger:
                    book_name = blogger.book_title if blogger.book_title else "待定书籍"
        if book_name == "":
            book_name = "待定书籍"
        
        # 保存书名到 book_state，确保后续阶段使用同一个名称
        book_state.book_name = book_name
        
        var write_days = book_state.write_days
        
        emit_info_msg.call("📖 创作《%s》中... 第%d篇 / 5篇" % [book_name, write_days])
        
        if write_days >= 5:
            _check_book_phase_complete(book_state)

func action_book_phase_change(new_phase: int) -> void:
    var book_state = _get_or_create_book_state()
    book_state.current_phase = new_phase
    book_state.phase_day = 0
    
    var phases = ["写作阶段", "编辑修改", "出版社审核", "出版上市"]
    if new_phase < phases.size():
        emit_info_msg.call("畅销书进入【%s】" % phases[new_phase])

func _check_book_phase_complete(book_state: Dictionary) -> void:
    var book_name = book_state.get("book_name", "")
    if book_name == "":
        if GDManager and GDManager.has_method("get_blogger"):
            var blogger = GDManager.get_blogger()
            if blogger:
                book_name = blogger.book_title if blogger.book_title else "未知书籍"
    if book_name == "":
        book_name = "待定书籍"
    
    match book_state.current_phase:
        0:
            var publisher = _get_random_publisher()
            if not publisher.is_empty():
                book_state.publisher = publisher
                book_state.current_phase = 1
                book_state.phase_day = 0
                var msg = "📚 出版社【%s】对《%s》表示兴趣！\n\n📋 编辑审核：预计需要 %d 天\n💡 提示：编辑修改期间请继续完善书稿细节" % [publisher.name, book_name, publisher.edit_days]
                emit_popup_msg.call("出版机会", msg)
        1:
            if book_state.phase_day >= book_state.get("publisher", {}).get("edit_days", 5):
                book_state.current_phase = 2
                book_state.phase_day = 0
                _disable_book_publish_category()
                var publisher_name = book_state.get("publisher", {}).get("name", "未知出版社")
                emit_info_msg.call("📝 编辑修改完成！\n\n📋 《%s》已进入【%s】审核阶段...\n\n⏳ 等待出版社终审和ISBN申请..." % [book_name, publisher_name])
        2:
            if book_state.phase_day >= book_state.get("publisher", {}).get("publish_days", 7):
                book_state.current_phase = 3
                _complete_book_publish(book_state)

func _disable_book_publish_category() -> void:
    if Utils and Blogger != null:
        Utils.replace_task_value(Blogger.blog_calendar, "出版畅销书", "休息")
    print("[出版畅销书] 进入审核阶段，日程任务已改为休息")

func _hide_book_notes_category() -> void:
    var book_notes = Utils.find_category_by_name(Utils.possible_categories, "出书笔记", true) if Utils else null
    if book_notes != null:
        book_notes.disabled = true
        book_notes.isVisible = false
        if Utils and Blogger != null:
            Utils.replace_task_value(Blogger.blog_calendar, "出书笔记", "休息")
        print("[出版畅销书] 已隐藏出书笔记类型")

func update_book_phase() -> void:
    var book_state = _get_or_create_book_state()
    if book_state.get("is_writing", false) and book_state.current_phase > 0:
        book_state.phase_day += 1
        
        # 获取书名
        var book_name = book_state.get("book_name", "")
        if book_name == "":
            if GDManager and GDManager.has_method("get_blogger"):
                var blogger = GDManager.get_blogger()
                if blogger:
                    book_name = blogger.book_title if blogger.book_title else "待定书籍"
        if book_name == "":
            book_name = "待定书籍"
        
        var phase_names = ["编辑修改", "出版社审核", "出版上市"]
        var phase_name = phase_names[book_state.current_phase - 1] if book_state.current_phase <= 3 else "未知"
        
        # 根据阶段显示不同提示
        match book_state.current_phase:
            1:
                # 编辑修改阶段
                var edit_days = book_state.get("publisher", {}).get("edit_days", 5)
                emit_info_msg.call("✏️ 《%s》编辑修改中... (%d/%d天)" % [book_name, book_state.phase_day, edit_days])
            2:
                # 出版社审核阶段
                var publish_days = book_state.get("publisher", {}).get("publish_days", 7)
                emit_info_msg.call("🏢 《%s》出版社审核中... (%d/%d天)" % [book_name, book_state.phase_day, publish_days])
            3:
                # 出版上市阶段
                emit_info_msg.call("📚 《%s》出版准备中..." % book_name)
        
        print("[出版畅销书] 阶段进度: %s, 第%d天" % [phase_name, book_state.phase_day])
        _check_book_phase_complete(book_state)

func _get_random_publisher() -> Dictionary:
    var publishers = [
        {"name": "新星出版社", "reward_multiplier": 1.0, "edit_days": 3, "publish_days": 5},
        {"name": "人民文学出版社", "reward_multiplier": 1.5, "edit_days": 5, "publish_days": 7},
        {"name": "中信出版社", "reward_multiplier": 1.4, "edit_days": 4, "publish_days": 5},
    ]
    return publishers[randi() % publishers.size()]

func _complete_book_publish(book_state: Dictionary) -> void:
    book_state.completed = true
    book_state.is_writing = false
    book_state.published = true
    
    var publisher = book_state.get("publisher", {})
    var base_reward = 50000
    var multiplier = publisher.get("reward_multiplier", 1.0)
    var final_reward = int(base_reward * multiplier * (book_state.write_days / 5.0))
    
    book_state.publish_date = Utils.format_date() if Utils else ""
    book_state.book_id = "book_" + str(Time.get_ticks_msec())
    if book_state.get("book_name", "") == "" or book_state.get("book_name", "").begins_with("畅销书"):
        var default_names = ["林间微光", "时光流影", "思想的涟漪", "归途笔记", "浮世清欢"]
        book_state.book_name = default_names[randi() % default_names.size()]
    
    var literature_value = Blogger.get_ability_by_type("literature") if Blogger else 50.0
    book_state.write_quality = _calculate_book_quality(book_state.write_days, literature_value)
    book_state.literature_value = literature_value
    book_state.sales_months = 0
    book_state.total_sales_income = 0
    book_state.publisher_name = publisher.get("name", "未知出版社")
    
    var blogger = null
    if GDManager and GDManager.has_method("get_blogger"):
        blogger = GDManager.get_blogger()
    if blogger:
        var current_money = blogger.money
        var current_reputation = blogger.reputation
        blogger.money = current_money + final_reward
        blogger.reputation = current_reputation + 1000
        
        blogger.book_title = ""
        blogger.book_article_count = 0
        print("[出版畅销书] 重置书名和文章计数，准备写新书")
        
        _hide_book_notes_category()
    
    _reset_book_state()
    
    _book_publish_instance.published_books.append(book_state.duplicate())
    
    var book_name = book_state.get("book_name", "")
    if book_name == "":
        if GDManager and GDManager.has_method("get_blogger"):
            blogger = GDManager.get_blogger()
            if blogger:
                book_name = blogger.book_title if blogger.book_title else "未知"
    if book_name == "":
        book_name = "待定书籍"
        
    var publisher_name = publisher.get("name", "未知出版社")
    
    var msg = "🎉 恭喜！《%s》正式出版上市！\n\n" % book_name
    msg += "━━━━━━━━━━━━━━━━━━━━\n"
    msg += "🏢 出版社：%s\n" % publisher_name
    msg += "💰 出版收益：%d 元\n" % final_reward
    msg += "📈 声望：+1000\n"
    msg += "━━━━━━━━━━━━━━━━━━━━\n\n"
    msg += "💡 后续安排：\n"
    msg += "• 书籍将在各大书店上架销售（36个月）\n"
    msg += "• 每月将收到销售版税收入\n"
    msg += "• 声望和文坛影响力大幅提升\n\n"
    msg += "提示：可以开始创作新书了！"
    
    emit_popup_msg.call("📚 出版成功！", msg)

func _calculate_book_quality(write_days: int, literature_value: float) -> float:
    var day_factor = clamp(float(write_days) / 10.0, 0.5, 1.0)
    var lit_factor = literature_value / 100.0
    return day_factor * lit_factor

func _get_or_create_book_state() -> Dictionary:
    return _book_publish_instance.current_book_state if _book_publish_instance else {}

func _reset_book_state() -> void:
    if not _book_publish_instance:
        return
    _book_publish_instance.current_book_state = {
        "is_writing": false,
        "book_id": "",
        "book_name": "",
        "current_phase": 0,
        "write_days": 0,
        "write_quality": 0,
        "total_progress": 0,
        "phase_day": 0,
        "completed": false,
        "publisher": {},
        "published": false,
        "publish_date": "",
        "sales_months": 0,
        "total_sales_income": 0,
    }
    print("[出版畅销书] current_book_state 已重置")

func settle_monthly_book_sales() -> Dictionary:
    if not _book_publish_instance:
        return {"total_income": 0, "books": []}
    
    var total_income = 0
    var books_info = []
    
    for book in _book_publish_instance.published_books:
        if not book.get("published", false) or book.get("sales_months", 0) >= 36:
            continue
        var monthly_income = _calculate_book_monthly_income(book, book.sales_months)
        book.sales_months = book.get("sales_months", 0) + 1
        book.total_sales_income = book.get("total_sales_income", 0) + monthly_income
        
        var book_info = {
            "book_name": book.get("book_name", "未知"),
            "publisher": book.get("publisher_name", "未知出版社"),
            "income": monthly_income,
            "sales_months": book.sales_months,
            "total_income": book.total_sales_income
        }
        books_info.append(book_info)
        
        if monthly_income > 0:
            var blogger = null
            if GDManager and GDManager.has_method("get_blogger"):
                blogger = GDManager.get_blogger()
            if blogger:
                var current_money = blogger.money
                blogger.set("money", current_money + monthly_income)
        total_income += monthly_income
    
    return {"total_income": total_income, "books": books_info}

func _calculate_book_monthly_income(book: Dictionary, sales_months: int) -> int:
    var write_quality = book.get("write_quality", 0.5)
    var peak_income = 100000 + 100000 * write_quality
    
    var income = 0.0
    if sales_months < 12:
        income = peak_income * pow(float(sales_months + 1) / 12.0, 2)
    elif sales_months < 18:
        income = peak_income * (1.0 + randf_range(-0.1, 0.1))
    else:
        var decline = max(1.0 - float(sales_months - 18) / 18.0, 0.0)
        income = peak_income * pow(decline, 1.5) * (0.8 + randf() * 0.4)
    
    return int(max(income, 0))
