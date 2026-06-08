extends Node
## 游戏的任务管理器,负责检查和执行任务

# 弹窗模板常量
const YEARLY_SUMMARY_TEMPLATE_CONTENT = """📊 今年数据变化（vs {year}年初）
━━━━━━━━━━━━━━━━━━━━━━━━━
📈 等级：{level_before} → {level_after}（{level_change}）
💰 资产：{money_before} → {money_after}（{money_change}）
👀 总访问量：{views_before} → {views_after}（{views_change}）
📨 RSS订阅：{rss_before} → {rss_after}（{rss_change}）
⭐ 文章收藏：{favorites_before} → {favorites_after}（{favorites_change}）

📝 今年发布了 {posts_total} 篇文章
{posts_categories}

🏆 这一年你辛苦了！继续加油！
"""

# 延迟加载 TaskConfig（用于运行时访问）
var TaskConfig = null
func get_task_config():
    if TaskConfig == null:
        TaskConfig = load("res://scripts/task_system/TaskConfig.gd")
    return TaskConfig

# 缓存枚举引用（用于 match 语句 - 必须是常量）
var TaskConfig_ConditionType = null
var TaskConfig_CompareOp = null  
var TaskConfig_ActionType = null
func _init_task_config_refs():
    var cfg = get_task_config()
    TaskConfig_ConditionType = cfg.ConditionType
    TaskConfig_CompareOp = cfg.CompareOp
    TaskConfig_ActionType = cfg.ActionType

## 子模块
var BookPublishMgr = null
var IPAuthMgr = null
var OpenSourceMgr = null

## 任务状态
var task_states: Array[Dictionary] = []

## 信号定义
signal schedule_refresh_needed
signal sg_task_info_display_msg(msg)
signal sg_task_show_popup_msg(title, content)

func _ready():
    # 初始化 TaskConfig 引用（必须在其他初始化之前）
    _init_task_config_refs()
    
    # 初始化子模块
    BookPublishMgr = preload("res://scripts/task_system/BookPublishManager.gd").new()
    IPAuthMgr = preload("res://scripts/task_system/IPAuthManager.gd").new()
    OpenSourceMgr = preload("res://scripts/task_system/OpenSourceManager.gd").new()

    # 设置模块信号回调
    BookPublishMgr.set_signal_callbacks(
        func(msg): emit_signal("sg_task_info_display_msg", msg),
        func(title, content): emit_signal("sg_task_show_popup_msg", title, content)
    )
    IPAuthMgr.set_signal_callbacks(
        func(msg): emit_signal("sg_task_info_display_msg", msg),
        func(title, content): emit_signal("sg_task_show_popup_msg", title, content)
    )
    OpenSourceMgr.set_signal_callbacks(
        func(msg): emit_signal("sg_task_info_display_msg", msg),
        func(title, content): emit_signal("sg_task_show_popup_msg", title, content)
    )

    # 初始化任务状态
    reset_task_states()
    _connect_signals()

## 连接游戏信号
func _connect_signals() -> void:
    if Blogger:
        Blogger.connect("sg_new_blog_post", _on_blog_post)
        Blogger.connect("s_level", _on_level_up)
        Blogger.connect("skill_level_up", _on_skill_level_up)

## 强制检查技能相关任务(游戏启动时调用)
func _force_check_skill_tasks() -> void:
    if not Blogger:
        return

    # 检查文学技能
    var lit_level = Blogger.get_ability_by_type("literature") if Blogger.has_method("get_ability_by_type") else 0
    check_tasks_by_trigger("skill_up", {"skill_type": Blogger.Skills.LITERATURE, "level": lit_level})

    # 检查编程技能
    var code_level = Blogger.get_ability_by_type("code") if Blogger.has_method("get_ability_by_type") else 0
    check_tasks_by_trigger("skill_up", {"skill_type": Blogger.Skills.CODE, "level": code_level})

    # 检查时间任务
    _check_time_tasks()

## 公开方法:供 main.gd 在连接信号后调用,检查初始任务
func check_initial_tasks() -> void:
    _force_check_skill_tasks()

## 重置任务状态(从配置复制)
func reset_task_states() -> void:
    # 如果任务状态已经有数据,需要检查是否有新任务需要添加
    if task_states.size() > 0:
        _add_missing_tasks()
        return

    # 清空本地任务状态
    task_states.clear()

    for task in get_task_config().TASKS:
        var state = task.duplicate(true)
        # 初始化状态字段
        if not state.has("is_active"):
            state.is_active = true
        if not state.has("is_completed"):
            state.is_completed = false
        task_states.append(state)

    # 同步到 GDManager(如果可用)
    if GDManager:
        var task_data = GDManager.get_task()
        task_data.task_states = task_states.duplicate(true)

## 添加缺失的新任务（用于兼容旧存档）
func _add_missing_tasks() -> void:
    var config_tasks = get_task_config().TASKS
    var existing_ids = []
    
    # 获取已存在的任务ID列表
    for state in task_states:
        var task_id = state.get("id", "")
        if not task_id.is_empty():
            existing_ids.append(task_id)
    
    # 检查配置中的任务是否都存在于 task_states 中
    for task in config_tasks:
        var task_id = task.get("id", "")
        if not existing_ids.has(task_id):
            # 发现新任务，添加到 task_states
            var state = task.duplicate(true)
            if not state.has("is_active"):
                state.is_active = true
            if not state.has("is_completed"):
                state.is_completed = false
            task_states.append(state)
    
    # 同步到 GDManager
    if GDManager:
        var task_data = GDManager.get_task()
        task_data.task_states = task_states.duplicate(true)

## ============================================================
## 信号处理
## ============================================================

## 技能升级信号
func _on_skill_level_up(skill_type: int, level: float) -> void:
    check_tasks_by_trigger("skill_up", {"skill_type": skill_type, "level": level})

## 玩家升级信号
func _on_level_up(level: int) -> void:
    check_tasks_by_trigger("level_up", {"level": level})

## 博文发布信号
func _on_blog_post(category: String) -> void:
    check_tasks_by_trigger("post_event", {"post_type": category})

## 广告联盟佣金发放信号
func _on_ad_income_paid(msg: String) -> void:
    var income_amount = _parse_income_from_msg(msg)
    check_tasks_by_trigger("ad_income_paid", {"msg": msg, "income_amount": income_amount})

## 从消息中解析收入金额
func _parse_income_from_msg(msg: String) -> String:
    var regex = RegEx.new()
    regex.compile(r"(\d+\.\d+)")
    var result = regex.search(msg)
    if result:
        return result.get_string(1)
    return "0.00"

## RSS订阅首次触发信号
func _on_rss_first_subscriber(rss_count: int) -> void:
    check_tasks_by_trigger("rss_subscribe", {"rss_count": rss_count})

## 文章首次被收藏触发信号
func _on_article_first_favorited(favorites_count: int) -> void:
    check_tasks_by_trigger("article_favorited", {"favorites_count": favorites_count})

## ICP备案完成触发信号
func _on_icp_filing_complete() -> void:
    check_tasks_by_trigger("icp_filing_complete", {})

## 每日任务检查
func day_task_func() -> void:
    check_tasks_by_trigger("time_check", {})
    # 更新书籍阶段进度
    if BookPublishMgr and BookPublishMgr.has_method("update_book_phase"):
        BookPublishMgr.update_book_phase()
    
    # 更新开源项目阶段进度
    if OpenSourceMgr and OpenSourceMgr.has_method("update_os_phase"):
        OpenSourceMgr.update_os_phase()

## ============================================================
## 任务检查
## ============================================================

## 按触发类型检查任务
func check_tasks_by_trigger(trigger_type: String, context: Dictionary) -> void:
    for i in range(task_states.size()):
        var task = task_states[i]

        # 检查触发类型
        var task_trigger = task.get("trigger_type", "")
        if task_trigger != trigger_type:
            continue
        
        # 检查 post_type_filter（如果有）
        var post_type_filter = task.get("post_type_filter", "")
        if post_type_filter != "":
            var post_type = context.get("post_type", "")
            if post_type != post_type_filter:
                continue

        # 检查任务是否可执行
        if not _can_execute_task(task):
            continue

        # 检查所有条件
        if not _check_all_conditions(task, context):
            continue

        # 执行任务
        _execute_task_at(i, context)

## 检查任务是否可执行
func _can_execute_task(task: Dictionary) -> bool:
    if not task.get("is_active", true):
        return false

    if task.get("is_completed", false) and not task.get("is_repeatable", false):
        return false

    return true

## 检查任务的所有条件
func _check_all_conditions(task: Dictionary, context: Dictionary) -> bool:
    var conditions = task.get("conditions", [])

    for cond in conditions:
        if not _check_single_condition(cond, context):
            return false

    return true

## 检查单个条件
func _check_single_condition(cond, context: Dictionary) -> bool:
    # 支持字符串ID引用或内联条件字典
    var condition: Dictionary

    if cond is String:
        condition = get_task_config().get_condition(cond)
        if condition.is_empty():
            push_error("[TaskManager] Condition not found: %s" % cond)
            return false
    elif cond is Dictionary:
        condition = cond
    else:
        push_error("[TaskManager] Invalid condition type: %s" % typeof(cond))
        return false

    var cond_type = condition.get("type")

    match cond_type:
        TaskConfig_ConditionType.SKILL_VALUE:
            return _check_skill_value_condition(condition, context)
        TaskConfig_ConditionType.SKILL_LEVEL:
            return _check_skill_level_condition(condition, context)
        TaskConfig_ConditionType.PLAYER_LEVEL:
            return _check_player_level_condition(condition, context)
        TaskConfig_ConditionType.POST_COUNT:
            return _check_post_count_condition(condition, context)
        TaskConfig_ConditionType.ARTICLE_COUNT:
            return _check_article_count_condition(condition, context)
        TaskConfig_ConditionType.SEO_VALUE:
            return _check_seo_value_condition(condition, context)
        TaskConfig_ConditionType.TIME_MATCH:
            return _check_time_condition(condition, context)
        TaskConfig_ConditionType.MILESTONE_COMPLETED:
            return _check_milestone_condition(condition, context)
        TaskConfig_ConditionType.CUSTOM:
            return _check_custom_condition(condition, context)
        _:
            push_error("[TaskManager] Unknown condition type: %s" % cond_type)
            return false

## 技能数值条件检查(能力值 0-100)
func _check_skill_value_condition(cond: Dictionary, context: Dictionary) -> bool:
    var skill_name = cond.get("skill", "")
    var op = cond.get("op", TaskConfig_CompareOp.GE)
    var target_value = cond.get("value", 0)

    # 获取技能枚举值
    var skill_enum = _get_skill_enum(skill_name)
    if skill_enum == -1:
        push_error("[TaskManager] Unknown skill: %s" % skill_name)
        return false

    # 从上下文获取当前数值(信号触发时)
    var current_value: float
    if context.has("skill_type") and context.skill_type == skill_enum:
        current_value = context.get("level", 0.0)
    else:
        # 从 Blogger 获取当前能力值
        var skill_type_str = _get_skill_string(skill_name)
        current_value = Blogger.get_ability_by_type(skill_type_str) if Blogger else 0.0

    return _compare(current_value, op, target_value)

## 技能等级条件检查(学习阶段 1-4)
func _check_skill_level_condition(cond: Dictionary, context: Dictionary) -> bool:
    # 目前技能等级也通过能力值判断
    return _check_skill_value_condition(cond, context)

## 玩家等级条件检查
func _check_player_level_condition(cond: Dictionary, context: Dictionary) -> bool:
    var op = cond.get("op", TaskConfig_CompareOp.EQ)
    var target_value = cond.get("value", 0)
    var current_value = context.get("level", Blogger.level if Blogger else 0)

    return _compare(current_value, op, target_value)

## 发布次数条件检查
func _check_post_count_condition(cond: Dictionary, _context: Dictionary) -> bool:
    var post_type = cond.get("post_type", "")
    var op = cond.get("op", TaskConfig_CompareOp.GE)
    var target_value = cond.get("value", 0)

    var current_value = _get_post_count_by_type(post_type)
    return _compare(current_value, op, target_value)

## 文章总数条件检查
func _check_article_count_condition(cond: Dictionary, _context: Dictionary) -> bool:
    var op = cond.get("op", TaskConfig_CompareOp.GE)
    var target_value = cond.get("value", 0)
    var current_value = _get_total_article_count()
    return _compare(current_value, op, target_value)

## SEO值条件检查
func _check_seo_value_condition(cond: Dictionary, _context: Dictionary) -> bool:
    var op = cond.get("op", TaskConfig_CompareOp.EQ)
    var target_value = cond.get("value", 0)
    var current_value = _get_seo_value()
    return _compare(current_value, op, target_value)

## 获取SEO值
func _get_seo_value() -> int:
    if GDManager:
        var blogger_data = GDManager.get_blogger()
        if blogger_data:
            return blogger_data.seo_value
    return 0

## 获取文章总数
func _get_total_article_count() -> int:
    if not GDManager:
        return 0
    var blogger_data = GDManager.get_blogger()
    if blogger_data == null:
        return 0
    return blogger_data.posts.size()

## 获取指定类型博文发布次数
func _get_post_count_by_type(post_type: String) -> int:
    if not GDManager:
        return 0

    var blogger_data = GDManager.get_blogger()
    if blogger_data == null:
        return 0

    var count = 0
    for post in blogger_data.posts:
        # 检查多个可能的字段:category、post_category、article_category、content_type、task_type
        if post.get("post_category", "") == post_type:
            count += 1
        elif post.get("article_category", "") == post_type:
            count += 1
        elif post.get("content_type", "") == post_type:
            count += 1
        elif post.get("task_type", "") == post_type:
            count += 1
    return count

## 时间条件检查
func _check_time_condition(cond: Dictionary, _context: Dictionary) -> bool:
    var event_date = cond.get("event_date", {})
    if event_date.is_empty():
        return false

    return TimerManager.is_time_match(event_date) if TimerManager else false

## 里程碑条件检查（用于跳过剧情调试）
## completed=false: 里程碑未完成时条件为真
## completed=true: 里程碑已完成时条件为真
func _check_milestone_condition(cond: Dictionary, _context: Dictionary) -> bool:
    var chapter = cond.get("chapter", 1)
    var milestone = cond.get("milestone", "")
    var should_be_completed = cond.get("completed", false)
    
    if milestone.is_empty():
        push_error("[TaskManager] MILESTONE_COMPLETED: milestone is empty")
        return false
    
    if GDManager:
        var sp = GDManager.get_story_progress()
        if sp:
            var is_completed = sp.is_completed(chapter, milestone)
            return is_completed == should_be_completed
    
    return false

## 自定义条件检查
func _check_custom_condition(cond: Dictionary, context: Dictionary) -> bool:
    var func_name = cond.get("check_func", "")
    if func_name.is_empty():
        push_error("[TaskManager] Custom condition missing check_func")
        return false

    if not has_method(func_name):
        push_error("[TaskManager] Method not found: %s" % func_name)
        return false

    return call(func_name, context)

## 友链添加条件检查（用于 friendlink_added 触发类型）
func check_friend_link_added(context: Dictionary) -> bool:
    return true

## 获取友链博客名称（用于弹窗内容替换）
func get_link_blog_name(link_data: Dictionary) -> String:
    if link_data.has("blog_name"):
        return link_data.get("blog_name", "未知博客")
    var member_id = link_data.get("member_id", 0)
    var static_members = GDManager.get_lm_members() if GDManager else []
    for m in static_members:
        if m.get("id") == member_id:
            return m.get("blog_name", "未知博客")
    return "未知博客"

## 通用比较函数
func _compare(current, op: int, target) -> bool:
    match op:
        TaskConfig_CompareOp.EQ:
            return current == target
        TaskConfig_CompareOp.NE:
            return current != target
        TaskConfig_CompareOp.GT:
            return current > target
        TaskConfig_CompareOp.GE:
            return current >= target
        TaskConfig_CompareOp.LT:
            return current < target
        TaskConfig_CompareOp.LE:
            return current <= target
        _:
            push_error("[TaskManager] Unknown compare op: %s" % op)
            return false

## 获取技能枚举值
func _get_skill_enum(skill_name: String) -> int:
    if not Blogger:
        return -1

    match skill_name.to_upper():
        "LITERATURE": return Blogger.Skills.LITERATURE
        "CODE": return Blogger.Skills.CODE
        _:
            return -1

## 获取技能字符串(用于调用 Blogger.get_ability_by_type)
func _get_skill_string(skill_name: String) -> String:
    match skill_name.to_upper():
        "LITERATURE": return "literature"
        "CODE": return "code"
        _:
            return ""

## ============================================================
## 自定义条件检查函数
## ============================================================

## 检查是否正在写书
func check_book_writing(_context: Dictionary) -> bool:
    return BookPublishMgr.is_book_writing() if BookPublishMgr else false

## 检查文学IP授权条件
func check_literature_ip_auth(_context: Dictionary) -> bool:
    return IPAuthMgr.check_literature_ip_auth(_context) if IPAuthMgr else false

## 检查是否正在开发开源项目
func check_open_source_project(_context: Dictionary) -> bool:
    return OpenSourceMgr.check_open_source_project(_context) if OpenSourceMgr else false

## 检查博客联盟是否未加入
func check_blog_union_not_joined(_context: Dictionary) -> bool:
    if GDManager:
        var sp = GDManager.get_story_progress()
        if sp:
            return not sp.is_completed(1, "blog_union_joined")
    return false

## 检查搜索引擎是否未收录
func check_sousuo_not_indexed(_context: Dictionary) -> bool:
    if GDManager:
        var sp = GDManager.get_story_progress()
        if sp:
            return not sp.is_completed(1, "sousuo_indexed")
    return false

## ============================================================
## 任务执行
## ============================================================

## 执行任务
func _execute_task_at(index: int, context: Dictionary) -> void:
    if index < 0 or index >= task_states.size():
        push_error("[TaskManager] Invalid task index: %s" % index)
        return

    var task = task_states[index]

    # 标记完成(非长期任务)
    if not task.get("duration_days", false):
        task.is_completed = true

    # 执行所有动作
    for action in task.get("actions", []):
        _execute_action(action, context)

## 执行动作
func _execute_action(action: Dictionary, context: Dictionary = {}) -> void:
    var action_type = action.get("type")
    if action_type == null:
        push_error("[TaskManager] Action missing 'type' field")
        return

    match action_type:
        TaskConfig_ActionType.SKILL_LEVEL_LOCK:
            _action_skill_lock(action)
        TaskConfig_ActionType.SKILL_LEVEL_UNLOCK:
            _action_skill_unlock(action)
        TaskConfig_ActionType.UNLOCK_POST_TASK:
            _action_unlock_post(action)
        TaskConfig_ActionType.LOCK_POST_TASK:
            _action_lock_post(action)
        TaskConfig_ActionType.HIDE_POST_TASK:
            _action_hide_post(action)
        TaskConfig_ActionType.UNLOCK_WEBSITE_MAINTENANCE:
            _action_unlock_website_maintenance(action)
        TaskConfig_ActionType.REPLACE_POST_TREND:
            _action_replace_trend(action)
        TaskConfig_ActionType.UNLOCK_MILESTONES_TASK:
            _action_unlock_milestone(action)
        # ===== 书籍出版、IP授权、开源项目(委托给子模块)=====
        TaskConfig_ActionType.START_BOOK_WRITE:
            BookPublishMgr.action_start_book_write() if BookPublishMgr else null
        TaskConfig_ActionType.BOOK_PROGRESS:
            BookPublishMgr.action_book_progress(action.get("progress", 1)) if BookPublishMgr else null
        TaskConfig_ActionType.BOOK_PHASE_CHANGE:
            BookPublishMgr.action_book_phase_change(action.get("phase", 0)) if BookPublishMgr else null
        TaskConfig_ActionType.TRIGGER_IP_AUTH:
            IPAuthMgr.action_trigger_ip_auth(action.get("ip_type", "movie")) if IPAuthMgr else null
        TaskConfig_ActionType.IP_MONTHLY_INCOME:
            IPAuthMgr.action_ip_monthly_income() if IPAuthMgr else null
        TaskConfig_ActionType.START_OPEN_SOURCE_PROJECT:
            OpenSourceMgr.action_start_open_source_project() if OpenSourceMgr else null
        TaskConfig_ActionType.OPEN_SOURCE_PROGRESS:
            OpenSourceMgr.action_os_progress(action.get("progress", 1)) if OpenSourceMgr else null
        TaskConfig_ActionType.OPEN_SOURCE_ACQUISITION:
            OpenSourceMgr.action_open_source_acquisition() if OpenSourceMgr else null
        TaskConfig_ActionType.UNLOCK_INITIAL_TASKS:
            _action_unlock_initial_tasks()
        TaskConfig_ActionType.START_GAME_TIME:
            _action_start_game_time()
        TaskConfig_ActionType.SET_STORY_MILESTONE:
            _action_set_story_milestone(action)
        TaskConfig_ActionType.SHOW_NOTIFICATION:
            _action_show_notification(action)
        TaskConfig_ActionType.SHOW_POPUP_NOTIFICATION:
            _action_show_popup_notification(action, context)
        TaskConfig_ActionType.SET_ICP_FILING_NUMBER:
            _action_icp_filing_complete(action)
        TaskConfig_ActionType.UPDATE_BLOG_UNION_BUTTON:
            _action_update_blog_union_button()
        TaskConfig_ActionType.SEO_NOTIFICATION:
            _action_seo_notification()
        TaskConfig_ActionType.ADD_ARCHIVE_EVENT:
            _action_add_archive_event(action)
        TaskConfig_ActionType.CHANGE_SCENE:
            _action_change_scene(action)
        _:
            push_warning("[TaskManager] Unhandled action type: %s" % action_type)

## 动作:锁定技能
func _action_skill_lock(action: Dictionary) -> void:
    var skill_name = action.get("skill_name", "")
    if skill_name.is_empty():
        push_error("[TaskManager] SKILL_LEVEL_LOCK missing skill_name")
        return

    if not Utils:
        push_error("[TaskManager] Utils 未初始化")
        return

    var d = Utils.find_category_by_name(Utils.learning_skills, skill_name, true)
    if d.is_empty():
        push_error("[TaskManager] Skill not found: %s" % skill_name)
        return

    d.isVisible = false
    d.disabled = true
    
    _remove_task_from_calendar(skill_name)
    
    emit_signal("sg_task_info_display_msg", d.get("lock_post_tip", ""))
    emit_signal("schedule_refresh_needed")

## 动作:解锁技能
func _action_skill_unlock(action: Dictionary) -> void:
    var skill_name = action.get("skill_name", "")
    if skill_name.is_empty():
        push_error("[TaskManager] SKILL_LEVEL_UNLOCK missing skill_name")
        return

    if not Utils:
        push_error("[TaskManager] Utils 未初始化")
        return

    var d = Utils.find_category_by_name(Utils.learning_skills, skill_name, true)
    if d.is_empty():
        push_error("[TaskManager] Skill not found: %s" % skill_name)
        return

    d.isVisible = true
    d.disabled = false
    emit_signal("sg_task_info_display_msg", d.get("unlock_post_tip", ""))

## 检查时间相关任务
func _check_time_tasks() -> void:
    check_tasks_by_trigger("time_check", {})

## 动作:解锁博文类型
func _action_unlock_post(action: Dictionary) -> void:
    var post_type = action.get("post_type", "")
    if post_type.is_empty():
        push_error("[TaskManager] UNLOCK_POST_TASK missing post_type")
        return

    if not Utils:
        push_error("[TaskManager] Utils 未初始化")
        return

    # 使用 include_disabled=true 以便找到被禁用的分类并进行解锁
    var d = Utils.find_category_by_name(Utils.possible_categories, post_type, true)
    if d.is_empty():
        push_error("[TaskManager] Post type not found: %s" % post_type)
        return

    # 解锁文章类型
    d.disabled = false
    d.isVisible = true

    # 显示解锁提示
    var tip = d.get("unlock_post_tip", "解锁新文章类型:【%s】" % post_type)
    emit_signal("sg_task_info_display_msg", tip)

## 动作:解锁网站维护任务
func _action_unlock_website_maintenance(action: Dictionary) -> void:
    var task_name = action.get("task_name", "")
    if task_name.is_empty():
        push_error("[TaskManager] UNLOCK_WEBSITE_MAINTENANCE missing task_name")
        return

    if not Utils:
        push_error("[TaskManager] Utils 未初始化")
        return

    # 在 website_maintenance 中查找
    var d = Utils.find_category_by_name(Utils.website_maintenance, task_name, true)
    if d.is_empty():
        push_error("[TaskManager] Website maintenance task not found: %s" % task_name)
        return

    # 解锁任务
    d.disabled = false
    d.isVisible = true

    # 显示解锁提示
    var tip = d.get("unlock_tip", "解锁新网站维护任务:【%s】" % task_name)
    emit_signal("sg_task_info_display_msg", tip)
    emit_signal("schedule_refresh_needed")

## 动作:ICP备案完成
func _action_icp_filing_complete(action: Dictionary) -> void:
    if not GDManager:
        push_error("[TaskManager] GDManager 未初始化")
        return
    
    var blogger = GDManager.get_blogger()
    
    # 标记备案完成
    blogger.icp_filing_in_progress = false
    
    # 保存备案号
    blogger.icp_filing_number = "ICP备88888888号"

## 动作:隐藏网站维护任务
func _action_lock_post(action: Dictionary) -> void:
    var post_type = action.get("post_type", "")
    if post_type.is_empty():
        push_error("[TaskManager] LOCK_POST_TASK missing post_type")
        return

    if not Utils:
        push_error("[TaskManager] Utils 未初始化")
        return

    var d = Utils.find_category_by_name(Utils.possible_categories, post_type, true)
    if d.is_empty():
        push_error("[TaskManager] Post type not found: %s" % post_type)
        return

    if not d.get("disabled", false):
        d.disabled = true
        
        _remove_task_from_calendar(post_type)
        
        emit_signal("sg_task_info_display_msg", d.get("lock_post_tip", ""))
        emit_signal("schedule_refresh_needed")

## 动作:隐藏博文类型
func _action_hide_post(action: Dictionary) -> void:
    var post_type = action.get("post_type", "")
    if post_type.is_empty():
        push_error("[TaskManager] HIDE_POST_TASK missing post_type")
        return

    if not Utils:
        push_error("[TaskManager] Utils 未初始化")
        return

    var d = Utils.find_category_by_name(Utils.possible_categories, post_type, true)
    if d.is_empty():
        push_error("[TaskManager] Post type not found: %s" % post_type)
        return

    # 隐藏并锁定
    d.isVisible = false
    d.disabled = true
    
    _remove_task_from_calendar(post_type)
    
    emit_signal("sg_task_info_display_msg", d.get("lock_post_tip", ""))
    emit_signal("schedule_refresh_needed")

## 动作:更换热点
func _action_replace_trend(_action: Dictionary) -> void:
    if not Utils:
        push_error("[TaskManager] Utils not available")
        return

    var random_index = randi() % Utils.bc_type.size()
    Utils.post_trend.category = Utils.bc_type[random_index]
    var tip = Strs.task_str.热点风向[Utils.post_trend.category][random_index] if Strs else ""
    emit_signal("sg_task_show_popup_msg", "提示", tip)

## 动作:解锁成就
func _action_unlock_milestone(action: Dictionary) -> void:
    var milestone_id = action.get("milestones_id", "")
    var milestone_name = action.get("milestones_name", "")

    if milestone_id.is_empty() or milestone_name.is_empty():
        push_error("[TaskManager] UNLOCK_MILESTONES_TASK missing milestone_id or milestones_name")
        return

    if not GDManager:
        push_error("[TaskManager] GDManager not available")
        return

    var milestones = GDManager.milestones.get(milestone_name)
    if milestones == null:
        push_error("[TaskManager] Milestone category not found: %s" % milestone_name)
        return

    var m = Utils.find_category_by_id(milestones, milestone_id) if Utils else null
    if m == null:
        push_error("[TaskManager] Milestone not found: %s" % milestone_id)
        return

    m.unlocked = true

## 动作:解锁初始任务选项
func _action_unlock_initial_tasks() -> void:
    if not Utils:
        push_error("[TaskManager] Utils not available")
        return
    
    # 日常创作
    _set_category_disabled("生活日记", false)
    _set_category_disabled("网站运维", false)
    _set_category_disabled("观影读书", false)
    _set_category_disabled("Coding笔记", false)
    
    # 网站维护
    _set_maintenance_disabled("安全维护", false)
    _set_maintenance_disabled("SEO优化", false)
    _set_maintenance_disabled("页面美化", false)
    _set_maintenance_disabled("友链维护", false)
    _set_maintenance_disabled("评论管理", false)
    
    # 休闲娱乐
    _set_recreation_disabled("打游戏", false)
    _set_recreation_disabled("吃烧烤", false)
    _set_recreation_disabled("和宠物玩", false)
    _set_recreation_disabled("城市周边自驾游", false)
    _set_recreation_disabled("开Party", false)
    
    # 自律学习
    _set_skill_disabled("文学入门", false)
    _set_skill_disabled("自学编程", false)

## 动作:启动游戏时间（弹窗关闭后生效）
func _action_start_game_time() -> void:
    # 不在这里启动，等弹窗关闭后在 main.gd 中启动
    pass

## 动作:显示信息通知
func _action_show_notification(action: Dictionary) -> void:
    var message = action.get("message", "")
    if not message.is_empty():
        emit_signal("sg_task_info_display_msg", message)

## 动作:显示弹窗通知
func _action_show_popup_notification(action: Dictionary, context: Dictionary = {}) -> void:
    var title = action.get("title", "通知")
    var content = action.get("content", "")
    var template = action.get("template", "")
    
    # 模板处理
    if not template.is_empty():
        var rendered = _render_popup_template(template, title, context)
        if not rendered.is_empty():
            title = rendered.get("title", title)
            content = rendered.get("content", content)
    
    if not content.is_empty():
        var link_data = context.get("link_data", {})
        var link_blog_name = get_link_blog_name(link_data)
        content = content.replace("{link_blog_name}", link_blog_name)
        var income_amount = context.get("income_amount", "0.00")
        content = content.replace("{income_amount}", income_amount)
        emit_signal("sg_task_show_popup_msg", title, content)

## 渲染弹窗模板
func _render_popup_template(template_name: String, default_title: String, context: Dictionary) -> Dictionary:
    match template_name:
        "yearly_summary":
            return _render_yearly_summary_template(default_title, context)
        _:
            return {}

## 渲染年度总结模板
func _render_yearly_summary_template(default_title: String, context: Dictionary) -> Dictionary:
    if not GDManager:
        return {}
    var time = GDManager.get_time()
    if not time:
        return {}
    
    var year = context.get("year", time.current_year)
    var data = YearlySummaryFormatter.build_template_data(year)
    if data.is_empty():
        return {}
    
    var title = default_title
    var content = YEARLY_SUMMARY_TEMPLATE_CONTENT
    
    return {
        "title": YearlySummaryFormatter.render(title, data),
        "content": YearlySummaryFormatter.render(content, data)
    }

## 动作:更新博客联盟按钮状态
func _action_update_blog_union_button() -> void:
    if get_tree().get_root().has_node("main/ui/bottom"):
        get_tree().get_root().get_node("main/ui/bottom").update_story_progress()

## 动作:SEO收录通知（弹窗+升级奖励）
func _action_seo_notification() -> void:
    var title = "搜索引擎收录通知"
    var content = """您的博客文章已被搜索引擎收录！

📊 SEO值越高，搜索排名越靠前，访问量越大
💡 建议每周进行一次SEO维护

🎁 任务奖励：等级直升1级！"""

    emit_signal("sg_task_show_popup_msg", title, content)

    if GDManager:
        var blogger_data = GDManager.get_blogger()
        if blogger_data:
            var current_level = blogger_data.level
            var new_level = min(current_level + 1, 100)
            if new_level > current_level:
                blogger_data.set_level(new_level)

## 从玩家日程中移除指定任务（所有日期）
func _remove_task_from_calendar(task_name: String) -> void:
    if not Blogger:
        return
    
    for day_task in Blogger.blog_calendar:
        if task_name in day_task.tasks:
            day_task.tasks.erase(task_name)

## 动作:设置剧情里程碑
func _action_set_story_milestone(action: Dictionary) -> void:
    var chapter = action.get("chapter", 1)
    var milestone = action.get("milestone", "")
    if milestone.is_empty():
        push_error("[TaskManager] SET_STORY_MILESTONE: milestone is empty")
        return
    if GDManager:
        var story = GDManager.get_story_progress()
        story.set_completed(chapter, milestone)

        if milestone == "blog_union_joined":
            _update_blog_union_button_now()

        _record_milestone_archive(chapter, milestone)

## 里程碑完成时自动记录博客历史事件
func _record_milestone_archive(chapter: int, milestone: String) -> void:
    if not GDManager:
        return
    var story = GDManager.get_story_progress()
    if not story:
        return
    var desc = story.get_milestone_description(chapter, milestone)
    var parts = desc.split("：")
    var title = parts[0]
    var detail = parts[1] if parts.size() > 1 else ""
    GDManager.add_archive_event(milestone, title, detail)

## 动作:切换场景
func _action_change_scene(action: Dictionary) -> void:
    var scene_path = action.get("scene_path", "")
    if scene_path.is_empty():
        push_error("[TaskManager] CHANGE_SCENE missing scene_path")
        return
    if Utils and Utils.has_method("goto_scene"):
        Utils.goto_scene(scene_path)

## 动作:添加博客历史事件
func _action_add_archive_event(action: Dictionary) -> void:
    var event_id = action.get("event_id", "")
    var title = action.get("title", "")
    var description = action.get("description", "")
    if event_id.is_empty() or title.is_empty():
        push_error("[TaskManager] ADD_ARCHIVE_EVENT missing event_id or title")
        return
    if GDManager:
        GDManager.add_archive_event(event_id, title, description)

func _update_blog_union_button_now() -> void:
    if get_tree().get_root().has_node("Main/ui/bottom"):
        get_tree().get_root().get_node("Main/ui/bottom").update_story_progress()

## 设置分类项目禁用状态
func _set_category_disabled(name: String, disabled: bool) -> void:
    if not Utils:
        return
    var d = Utils.find_category_by_name(Utils.possible_categories, name, true)
    if not d.is_empty():
        d["disabled"] = disabled

## 设置维护项目禁用状态
func _set_maintenance_disabled(name: String, disabled: bool) -> void:
    if not Utils:
        return
    var d = Utils.find_category_by_name(Utils.website_maintenance, name, true)
    if not d.is_empty():
        d["disabled"] = disabled

## 设置娱乐项目禁用状态
func _set_recreation_disabled(name: String, disabled: bool) -> void:
    if not Utils:
        return
    var d = Utils.find_category_by_name(Utils.recreation, name, true)
    if not d.is_empty():
        d["disabled"] = disabled

## 设置技能项目禁用状态
func _set_skill_disabled(name: String, disabled: bool) -> void:
    if not Utils:
        return
    var d = Utils.find_category_by_name(Utils.learning_skills, name, true)
    if not d.is_empty():
        d["disabled"] = disabled

## ============================================================
## 月结算接口（委托给子模块）
## ============================================================

## 每月结算书籍销售收入
func settle_monthly_book_sales() -> Dictionary:
    return BookPublishMgr.settle_monthly_book_sales() if BookPublishMgr else {"total_income": 0}

## 每月结算开源项目赞助收入
func settle_monthly_open_source() -> Dictionary:
    return OpenSourceMgr.settle_monthly_open_source() if OpenSourceMgr else {"total_income": 0}

## 自定义条件检查:2005年度总结已发布
func check_year_summary_2005(context: Dictionary) -> bool:
    if not GDManager:
        return false
    var time = GDManager.get_time()
    return time != null and time.current_year == 2005

## 自定义条件检查:ICP备案进行中
func check_icp_filing_in_progress(context: Dictionary) -> bool:
    if not GDManager:
        return false
    var blogger = GDManager.get_blogger()
    return blogger.icp_filing_in_progress
