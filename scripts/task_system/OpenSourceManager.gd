extends Node
## 开源项目管理器 - 处理开源项目创建、开发和厂商赞助相关逻辑

var _open_source_instance = null

## 信号回调
var emit_info_msg: Callable = func(_msg): pass
var emit_popup_msg: Callable = func(_title, _content): pass
var emit_os_event: Callable = func(): pass

func _init():
    _open_source_instance = preload("res://data/open_source_project.gd").new()

func set_signal_callbacks(info_callback: Callable, popup_callback: Callable, os_event_callback: Callable = func(): pass):
    emit_info_msg = info_callback
    emit_popup_msg = popup_callback
    emit_os_event = os_event_callback

## 检查开源项目条件
func check_open_source_project(_context: Dictionary) -> bool:
    if not Blogger:
        return false
    var code_value = Blogger.get_ability_by_type("code")
    return code_value >= 90

## 动作：开始开源项目
func action_start_open_source_project() -> void:
    var os_state = _get_or_create_os_state()
    
    # 解锁开源项目选项
    var os_project = Utils.find_category_by_name(Utils.possible_categories, "开源项目", true) if Utils else null
    if os_project != null:
        os_project.disabled = false
        os_project.isVisible = true
    
    # 开源维护笔记的解锁在 action_os_progress 第一篇时通过 os_event 触发
    
    os_state.is_developing = true
    _update_os_notes_visibility()
    
    # 项目名在用户发布第一篇"开源项目"文章时才生成，这里只显示解锁提示
    emit_info_msg.call("🎉 编程能力达到90级，可以开始创建开源项目了！\n\n💡 提示：发布100篇后，将进入社区运营阶段，有机会获得大厂赞助！")

## 动作：开源项目进度更新
func action_os_progress(progress: int) -> void:
    var os_state = _get_or_create_os_state()
    var is_first_article = os_state.get("write_days", 0) == 0
    
    if is_first_article:
        var blogger = null
        if GDManager and GDManager.has_method("get_blogger"):
            blogger = GDManager.get_blogger()
        if blogger and blogger.is_developing_os:
            if not os_state.get("is_developing", false):
                os_state.is_developing = true
        emit_os_event.call()
    
    if os_state.get("is_developing", false):
        os_state.write_days += 1
        os_state.total_progress += progress
        os_state.stars += randi() % (progress * 10)
        
        # 获取项目名，优先从 os_state 取，否则从 blogger 取，并保存到 os_state
        var project_name = os_state.get("project_name", "")
        if project_name == "":
            if GDManager and GDManager.has_method("get_blogger"):
                var blogger = GDManager.get_blogger()
                if blogger:
                    project_name = blogger.os_project_name if blogger.os_project_name else "待定项目"
        if project_name == "":
            project_name = "待定项目"
        
        # 保存项目名到 os_state，确保后续阶段使用同一个名称
        os_state.project_name = project_name
        
        var write_days = os_state.write_days
        var stars = os_state.stars
        
        emit_info_msg.call("📡 项目《%s》开发中... 第%d篇 / 100篇\n⭐ GitHub Star: %d" % [project_name, write_days, stars])
        
        if write_days >= 100:
            _check_os_phase_complete(os_state)

## 动作：开源项目阶段变化
func action_os_phase_change(new_phase: int) -> void:
    var os_state = _get_or_create_os_state()
    os_state.current_phase = new_phase
    os_state.phase_day = 0
    
    var phases = ["开发阶段", "社区运营", "厂商审核", "赞助上线"]
    if new_phase < phases.size():
        emit_info_msg.call("🚀 开源项目进入【%s】" % phases[new_phase])

## 检查开源项目阶段完成
func _check_os_phase_complete(os_state: Dictionary) -> void:
    # 从 blogger 获取项目名（如果 os_state 中没有）
    var project_name = os_state.get("project_name", "")
    if project_name == "":
        if GDManager and GDManager.has_method("get_blogger"):
            var blogger = GDManager.get_blogger()
            if blogger:
                project_name = blogger.os_project_name if blogger.os_project_name else "待定项目"
    if project_name == "":
        project_name = "待定项目"
    
    match os_state.current_phase:
        0:
            # 开发完成，随机选择赞助厂商
            var sponsor = _get_random_sponsor()
            if not sponsor.is_empty():
                os_state.sponsor = sponsor
                os_state.current_phase = 1
                os_state.phase_day = 0
                var msg = "🎉 项目《%s》引起【%s】关注！\n\n📋 厂商评估：项目star数达到 %d，技术栈符合厂商需求\n⏱️ 商务谈判预计需要 %d 天\n\n💡 提示：谈判期间请保持项目活跃，积极回复社区issue" % [project_name, sponsor.get("name", "未知厂商"), os_state.stars, sponsor.get("edit_days", 5)]
                emit_popup_msg.call("大厂关注", msg)
        1:
            # 社区运营阶段完成，进入厂商审核
            var edit_days = os_state.get("sponsor", {}).get("edit_days", 5)
            if os_state.phase_day >= edit_days:
                os_state.current_phase = 2
                os_state.phase_day = 0
                # 进入厂商审核阶段，禁用创建新项目功能
                _disable_os_project_category()
                var sponsor_name = os_state.get("sponsor", {}).get("name", "未知厂商")
                emit_info_msg.call("📊 社区运营阶段完成！\n\n⭐ 项目Star: %d\n📧 %s 已发起商务谈判...\n\n⏳ 等待厂商法务和技术团队审核..." % [os_state.stars, sponsor_name])
        2:
            # 厂商审核完成，赞助上线
            var publish_days = os_state.get("sponsor", {}).get("publish_days", 7)
            if os_state.phase_day >= publish_days:
                os_state.current_phase = 3
                _complete_os_project(os_state)

## 禁用开源项目分类（审核期间不再创建新项目）
func _disable_os_project_category() -> void:
    if Blogger:
        for day_task in Blogger.blog_calendar:
            if "开源项目" in day_task.tasks:
                day_task.tasks.erase("开源项目")

## 动态更新开源维护笔记可见性
func _update_os_notes_visibility() -> void:
    var should_show = false
    
    if _open_source_instance.current_project_state.get("is_developing", false):
        should_show = true
    
    if not should_show:
        for project in _open_source_instance.published_projects:
            if project.get("published", false) and project.get("sponsor_months", 0) < 12:
                should_show = true
                break
    
    var os_notes = Utils.find_category_by_name(Utils.possible_categories, "开源维护笔记", true) if Utils else null
    if os_notes:
        os_notes.isVisible = should_show
        if not should_show:
            os_notes.disabled = true
            if Blogger:
                for day_task in Blogger.blog_calendar:
                    if "开源维护笔记" in day_task.tasks:
                        day_task.tasks.erase("开源维护笔记")

## 每日更新项目阶段进度（审核期每天调用）
func update_os_phase() -> void:
    var os_state = _get_or_create_os_state()
    
    # 获取项目名，优先从 os_state 取，否则从 blogger 取
    var project_name = os_state.get("project_name", "")
    if project_name == "":
        if GDManager and GDManager.has_method("get_blogger"):
            var blogger = GDManager.get_blogger()
            if blogger:
                project_name = blogger.os_project_name if blogger.os_project_name else "待定项目"
    if project_name == "":
        project_name = "待定项目"
    
    var sponsor_name = os_state.get("sponsor", {}).get("name", "未知厂商")
    
    if os_state.get("is_developing", false) and os_state.current_phase > 0:
        os_state.phase_day += 1
        var phase_names = ["社区运营", "厂商审核", "赞助上线"]
        var phase_name = phase_names[os_state.current_phase - 1] if os_state.current_phase <= 3 else "未知"
        
        # 根据不同阶段显示不同提示
        match os_state.current_phase:
            1:
                # 社区运营阶段
                var stars = os_state.stars + randi() % 10
                os_state.stars = stars
                emit_info_msg.call("📡 项目《%s》社区运营中...\n⭐ 当前Star: %d\n📢 正在开发者社区推广..." % [project_name, stars])
            2:
                # 厂商审核阶段
                var edit_days = os_state.get("sponsor", {}).get("edit_days", 5)
                var publish_days = os_state.get("sponsor", {}).get("publish_days", 7)
                var total_days = edit_days + publish_days
                var progress = os_state.phase_day
                if progress < edit_days:
                    emit_info_msg.call("⚖️ %s 正在审核项目《%s》...\n📋 技术评估中 (%d/%d天)" % [sponsor_name, project_name, progress, edit_days])
                else:
                    var legal_progress = progress - edit_days
                    emit_info_msg.call("⚖️ %s 法务团队审核中...\n📝 合同条款审查 (%d/%d天)" % [sponsor_name, legal_progress, publish_days])
        
        _check_os_phase_complete(os_state)

## 获取随机赞助厂商（从数据文件读取，按 Star 数筛选）
func _get_random_sponsor() -> Dictionary:
    if not _open_source_instance:
        return {"name": "未知厂商", "reward_multiplier": 1.0, "edit_days": 5, "publish_days": 7, "monthly_base": 100000, "description": ""}
    var stars = _open_source_instance.current_project_state.get("stars", 0)
    var eligible = _open_source_instance.get_eligible_sponsors(stars)
    if eligible.is_empty():
        eligible = _open_source_instance.sponsors
    return eligible[randi() % eligible.size()]

## 完成项目赞助上线
func _complete_os_project(os_state: Dictionary) -> void:
    # 从 blogger 获取项目名（如果 os_state 中没有）
    var project_name = os_state.get("project_name", "")
    if project_name == "":
        if GDManager and GDManager.has_method("get_blogger"):
            var blogger = GDManager.get_blogger()
            if blogger:
                project_name = blogger.os_project_name if blogger.os_project_name else "待定项目"
    if project_name == "":
        project_name = "待定项目"
        
    var sponsor = os_state.get("sponsor", {})
    var sponsor_name = sponsor.get("name", "未知厂商")
    
    os_state.completed = true
    os_state.is_developing = false
    os_state.published = true
    
    # 计算一次性奖励
    var base_reward = 80000
    var multiplier = sponsor.get("reward_multiplier", 1.0)
    var write_days = os_state.get("write_days", 100)
    var final_reward = int(base_reward * multiplier * (write_days / 100.0))
    
    os_state.publish_date = Utils.format_date() if Utils else ""
    os_state.project_id = "os_" + str(Time.get_ticks_msec())
    
    # 只在项目名为空时设置默认名称
    if os_state.get("project_name", "") == "" or os_state.get("project_name", "").begins_with("开源项目"):
        var default_names = ["FastAPI", "Gin", "Vue.js", "TensorFlow", "React", "Docker", "Kubernetes"]
        os_state.project_name = default_names[randi() % default_names.size()]
        project_name = os_state.project_name
    
    var code_value = Blogger.get_ability_by_type("code") if Blogger else 50.0
    os_state.write_quality = _open_source_instance.calculate_project_quality(os_state.write_days, code_value) if _open_source_instance else 0.5
    os_state.code_value = code_value
    os_state.sponsor_months = 0
    os_state.total_sponsor_income = 0
    os_state.sponsor_name = sponsor_name
    
    # 发放赞助收益
    var blogger = null
    if GDManager and GDManager.has_method("get_blogger"):
        blogger = GDManager.get_blogger()
    if blogger:
        var current_money = blogger.money
        var current_reputation = blogger.reputation
        blogger.set("money", current_money + final_reward)
        blogger.set("reputation", current_reputation + 2000)
        
        # 重置项目名和文章计数，为下一个项目做准备
        blogger.set("os_project_name", "")
        blogger.set("os_article_count", 0)
        blogger.set("is_developing_os", false)

        # 赞助完成后不立即隐藏，由月度结算动态管理
    
    # 重置 current_project_state，为新项目做准备
    _reset_os_state()
    
    # 项目完成后冷确180天
    if blogger:
        var d = Utils.find_category_by_name(Utils.possible_categories, "开源项目", true)
        if not d.is_empty():
            blogger.cooldowns["开源项目"] = Utils.format_date()
            d.disabled = true
    
    _open_source_instance.published_projects.append(os_state.duplicate())
    
    if TaskManager:
        TaskManager._on_open_source_complete()
    
    # 完整的赞助成功提示
    var msg = "🎉 恭喜！项目《%s》正式获得 %s 赞助！\n\n" % [project_name, sponsor_name]
    msg += "━━━━━━━━━━━━━━━━━━━━\n"
    msg += "🏢 赞助厂商：%s\n" % sponsor_name
    msg += "💰 上线奖励：%d 元\n" % final_reward
    msg += "⭐ 项目Star：%d\n" % os_state.stars
    msg += "📈 声望：+2000\n"
    msg += "━━━━━━━━━━━━━━━━━━━━\n\n"
    msg += "💡 后续安排：\n"
    msg += "• 每月将收到厂商赞助费（12个月）\n"
    msg += "• 项目将获得厂商技术支持\n"
    msg += "• 声望和影响力大幅提升\n\n"
    msg += "提示：可以开始新的开源项目了！"
    
    emit_popup_msg.call("🚀 赞助签约成功！", msg)

func _set_story_milestone(chapter: int, milestone: String) -> void:
    if GDManager and GDManager.has_method("get_story_progress"):
        var sp = GDManager.get_story_progress()
        if sp:
            sp.set_completed(chapter, milestone)

## 获取或创建项目状态
func _get_or_create_os_state() -> Dictionary:
    return _open_source_instance.current_project_state if _open_source_instance else {}

func get_published_projects_ref() -> Array:
    return _open_source_instance.published_projects if _open_source_instance else []

func get_current_project_state() -> Dictionary:
    return _open_source_instance.current_project_state.duplicate(true) if _open_source_instance else {}

func get_published_projects() -> Array:
    return _open_source_instance.published_projects.duplicate(true) if _open_source_instance else []

func restore_state(project_state: Dictionary, published: Array) -> void:
    if not _open_source_instance:
        return
    if not project_state.is_empty():
        _open_source_instance.current_project_state = project_state
    if not published.is_empty():
        _open_source_instance.published_projects = published

## 重置项目状态（用于赞助完成后开始新项目）
func _reset_os_state() -> void:
    if not _open_source_instance:
        return
    _open_source_instance.current_project_state = {
        "is_developing": false,
        "project_id": "",
        "project_name": "",
        "current_phase": 0,
        "write_days": 0,
        "write_quality": 0,
        "total_progress": 0,
        "phase_day": 0,
        "completed": false,
        "sponsor": {},
        "published": false,
        "publish_date": "",
        "sponsor_months": 0,
        "total_sponsor_income": 0,
        "stars": 0,
        "fork_count": 0,
        "issue_count": 0,
        "sponsor_name": "",
        "code_value": 0,
    }

## 每月结算项目赞助收入
func settle_monthly_open_source() -> Dictionary:
    if not _open_source_instance:
        return {"total_income": 0, "projects": []}
    
    var total_income = 0
    var projects_info = []
    
    for project in _open_source_instance.published_projects:
        if not project.get("published", false) or project.get("sponsor_months", 0) >= 12:
            continue
        
        var sponsor = project.get("sponsor", {})
        var monthly_base = sponsor.get("monthly_base", 100000)
        var monthly_income = _open_source_instance.calculate_monthly_sponsor(project, project.sponsor_months, monthly_base) if _open_source_instance else 0
        project.sponsor_months = project.get("sponsor_months", 0) + 1
        project.total_sponsor_income = project.get("total_sponsor_income", 0) + monthly_income
        
        # 记录每个项目的收入信息
        var project_info = {
            "project_name": project.get("project_name", "未知"),
            "sponsor": project.get("sponsor_name", project.get("sponsor", {}).get("name", "未知厂商")),
            "income": monthly_income,
            "sponsor_months": project.sponsor_months,
            "total_income": project.total_sponsor_income
        }
        projects_info.append(project_info)
        
        if monthly_income > 0:
            var blogger = null
            if GDManager and GDManager.has_method("get_blogger"):
                blogger = GDManager.get_blogger()
            if blogger:
                var current_money = blogger.money
                blogger.set("money", current_money + monthly_income)
        total_income += monthly_income
    
    _update_os_notes_visibility()
    
    return {"total_income": total_income, "projects": projects_info}

## 动作：开源项目赞助完成（兼容旧版本）
## 实际赞助流程在 update_os_phase 中自动完成，这里提供兼容接口
func action_open_source_acquisition() -> void:
    var os_state = _get_or_create_os_state()
    if os_state.get("is_developing", false) and os_state.get("current_phase", 0) >= 3:
        _complete_os_project(os_state)
