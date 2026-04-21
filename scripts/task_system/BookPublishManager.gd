extends Node
## 书籍出版管理器 - 处理畅销书相关的所有逻辑

## 数据实例
var _book_publish_instance = null

## 信号引用（由 TaskManager 设置）
var emit_info_msg: Callable = func(_msg): pass
var emit_popup_msg: Callable = func(_title, _content): pass

func _init():
    _book_publish_instance = preload("res://data/book_publish.gd").new()

## 设置信号回调
func set_signal_callbacks(info_callback: Callable, popup_callback: Callable):
    emit_info_msg = info_callback
    emit_popup_msg = popup_callback

## 检查是否正在写书
func is_book_writing() -> bool:
    if not _book_publish_instance:
        return false
    var book_state = _book_publish_instance.current_book_state
    return book_state.get("is_writing", false) or book_state.get("published", false)

## 动作：开始写书
func action_start_book_write() -> void:
    if not _book_publish_instance:
        return
    
    var book_state = _book_publish_instance.current_book_state
    
    # 解锁出版畅销书选项
    var d = Utils.find_category_by_name(Utils.possible_categories, "出版畅销书") if Utils else null
    if d != null:
        d.disabled = false
        d.isVisible = true
    
    # 解锁"出书笔记"文章类型
    var book_notes = Utils.find_category_by_name(Utils.possible_categories, "出书笔记") if Utils else null
    if book_notes != null:
        book_notes.disabled = false
        book_notes.isVisible = true
    
    book_state.is_writing = true
    
    # 书名由 blogger.gd 在发布文章时初始化，这里不再处理
    var book_title = "未命名书籍"
    if GDManager and GDManager.has_method("get_blogger"):
        var blogger = GDManager.get_blogger()
        if blogger:
            book_title = blogger.book_title
            if book_title == null or book_title == "":
                # 书名为空时使用随机名称
                var default_names = ["林间微光", "时光流影", "思想的涟漪", "归途笔记", "浮世清欢"]
                book_title = default_names[randi() % default_names.size()]
    
    book_state.book_name = book_title
    emit_info_msg.call("文学能力达到90级，可以开始创作畅销书了！书名：《%s》" % book_title)

## 动作：写书进度更新
func action_book_progress(progress: int) -> void:
    var book_state = _get_or_create_book_state()
    if book_state.get("is_writing", false):
        book_state.write_days += 1
        book_state.total_progress += progress
        if book_state.write_days >= 5:
            _check_book_phase_complete(book_state)

## 动作：书籍阶段变化
func action_book_phase_change(new_phase: int) -> void:
    var book_state = _get_or_create_book_state()
    book_state.current_phase = new_phase
    book_state.phase_day = 0
    
    var phases = ["写作阶段", "编辑修改", "出版社审核", "出版上市"]
    if new_phase < phases.size():
        emit_info_msg.call("畅销书进入【%s】" % phases[new_phase])

## 检查书籍阶段完成
func _check_book_phase_complete(book_state: Dictionary) -> void:
    match book_state.current_phase:
        0:
            var publisher = _get_random_publisher()
            if not publisher.is_empty():
                book_state.publisher = publisher
                book_state.current_phase = 1
                book_state.phase_day = 0
                var msg = "【%s】对您的畅销书表示兴趣！\n编辑审核预计需要%d天。" % [publisher.name, publisher.edit_days]
                emit_popup_msg.call("出版机会", msg)
        1:
            if book_state.phase_day >= book_state.get("publisher", {}).get("edit_days", 5):
                book_state.current_phase = 2
                book_state.phase_day = 0
                # 进入出版社审核阶段，禁用写书功能
                _disable_book_publish_category()
                emit_info_msg.call("编辑修改完成，进入出版社审核阶段...")
        2:
            if book_state.phase_day >= book_state.get("publisher", {}).get("publish_days", 7):
                book_state.current_phase = 3
                _complete_book_publish(book_state)

## 禁用出版畅销书分类（审核期间不再写新书）
func _disable_book_publish_category() -> void:
    # 清空日程中的出书任务（改为休息），但保持分类可用
    if Utils and typeof(Blogger) == TYPE_OBJECT:
        Utils.replace_task_value(Blogger.blog_calendar, "出版畅销书", "休息")
    print("[出版畅销书] 进入审核阶段，日程任务已改为休息")

## 每日更新书籍阶段进度（审核期每天调用）
func update_book_phase() -> void:
    var book_state = _get_or_create_book_state()
    if book_state.get("is_writing", false) and book_state.current_phase > 0:
        book_state.phase_day += 1
        var phase_names = ["编辑修改", "出版社审核", "出版上市"]
        var phase_name = phase_names[book_state.current_phase - 1] if book_state.current_phase <= 3 else "未知"
        print("[出版畅销书] 阶段进度: %s, 第%d天" % [phase_name, book_state.phase_day])
        _check_book_phase_complete(book_state)

## 获取随机出版商
func _get_random_publisher() -> Dictionary:
    var publishers = [
        {"name": "新星出版社", "reward_multiplier": 1.0, "edit_days": 3, "publish_days": 5},
        {"name": "人民文学出版社", "reward_multiplier": 1.5, "edit_days": 5, "publish_days": 7},
        {"name": "中信出版社", "reward_multiplier": 1.4, "edit_days": 4, "publish_days": 5},
    ]
    return publishers[randi() % publishers.size()]

## 完成书籍出版
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
    # 只在书名为空时设置默认名称
    if book_state.get("book_name", "") == "" or book_state.get("book_name", "").begins_with("畅销书"):
        var default_names = ["林间微光", "时光流影", "思想的涟漪", "归途笔记", "浮世清欢"]
        book_state.book_name = default_names[randi() % default_names.size()]
    
    var literature_value = Blogger.get_ability_by_type("literature") if Blogger else 50.0
    book_state.write_quality = _calculate_book_quality(book_state.write_days, literature_value)
    book_state.literature_value = literature_value
    book_state.sales_months = 0
    book_state.total_sales_income = 0
    book_state.publisher_name = publisher.get("name", "未知出版社")
    
    # 发放出版收益
    var blogger = null
    if GDManager and GDManager.has_method("get_blogger"):
        blogger = GDManager.get_blogger()
    if blogger:
        var current_money = blogger.money
        var current_reputation = blogger.reputation
        blogger.set("money", current_money + final_reward)
        blogger.set("reputation", current_reputation + 1000)
    
    _book_publish_instance.published_books.append(book_state.duplicate())
    
    var book_name = book_state.get("book_name", "未知")
    var msg = "恭喜！《%s》正式出版上市！\n\n出版社：【%s】\n出版收益：%d元\n声望：+1000\n销售周期：12个月\n\n提示：书籍将开始产生持续销售收入" % [book_name, publisher.get("name", "未知"), final_reward]
    emit_popup_msg.call("出版成功", msg)

## 计算书籍写作质量
func _calculate_book_quality(write_days: int, literature_value: float) -> float:
    var day_factor = clamp(float(write_days) / 10.0, 0.5, 1.0)
    var lit_factor = literature_value / 100.0
    return day_factor * lit_factor

## 获取或创建书籍状态
func _get_or_create_book_state() -> Dictionary:
    return _book_publish_instance.current_book_state if _book_publish_instance else {}

## 每月结算书籍销售收入
func settle_monthly_book_sales() -> Dictionary:
    if not _book_publish_instance:
        return {"total_income": 0}
    
    var total_income = 0
    for book in _book_publish_instance.published_books:
        if not book.get("published", false) or book.get("sales_months", 0) >= 36:
            continue
        var monthly_income = _calculate_book_monthly_income(book, book.sales_months)
        book.sales_months = book.get("sales_months", 0) + 1
        book.total_sales_income = book.get("total_sales_income", 0) + monthly_income
        if monthly_income > 0:
            var blogger = null
            if GDManager and GDManager.has_method("get_blogger"):
                blogger = GDManager.get_blogger()
            if blogger:
                var current_money = blogger.money
                blogger.set("money", current_money + monthly_income)
        total_income += monthly_income
    
    return {"total_income": total_income}

## 计算书籍月销售收入
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