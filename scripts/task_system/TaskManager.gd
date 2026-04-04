extends Node
## 游戏的任务管理器,负责检查和执行任务

# 引用任务配置
const TaskConfig = preload("res://scripts/task_system/TaskConfig.gd")

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

	# 检查绘画技能
	var draw_level = Blogger.get_ability_by_type("draw") if Blogger.has_method("get_ability_by_type") else 0
	check_tasks_by_trigger("skill_up", {"skill_type": Blogger.Skills.DRAW, "level": draw_level})

	# 检查时间任务
	_check_time_tasks()

## 公开方法:供 main.gd 在连接信号后调用,检查初始任务
func check_initial_tasks() -> void:
	_force_check_skill_tasks()

## 重置任务状态(从配置复制)
func reset_task_states() -> void:
	# 如果任务状态已经有数据,不重复初始化(保留已完成的进度)
	if task_states.size() > 0:
		return

	# 清空本地任务状态
	task_states.clear()

	for task in TaskConfig.TASKS:
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

## 每日任务检查
func day_task_func() -> void:
	check_tasks_by_trigger("time_check", {})

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
		condition = TaskConfig.get_condition(cond)
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
		TaskConfig.ConditionType.SKILL_VALUE:
			return _check_skill_value_condition(condition, context)
		TaskConfig.ConditionType.SKILL_LEVEL:
			return _check_skill_level_condition(condition, context)
		TaskConfig.ConditionType.PLAYER_LEVEL:
			return _check_player_level_condition(condition, context)
		TaskConfig.ConditionType.POST_COUNT:
			return _check_post_count_condition(condition, context)
		TaskConfig.ConditionType.TIME_MATCH:
			return _check_time_condition(condition, context)
		TaskConfig.ConditionType.CUSTOM:
			return _check_custom_condition(condition, context)
		_:
			push_error("[TaskManager] Unknown condition type: %s" % cond_type)
			return false

## 技能数值条件检查(能力值 0-100)
func _check_skill_value_condition(cond: Dictionary, context: Dictionary) -> bool:
	var skill_name = cond.get("skill", "")
	var op = cond.get("op", TaskConfig.CompareOp.GE)
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
	var op = cond.get("op", TaskConfig.CompareOp.EQ)
	var target_value = cond.get("value", 0)
	var current_value = context.get("level", Blogger.level if Blogger else 0)

	return _compare(current_value, op, target_value)

## 发布次数条件检查
func _check_post_count_condition(cond: Dictionary, _context: Dictionary) -> bool:
	var post_type = cond.get("post_type", "")
	var op = cond.get("op", TaskConfig.CompareOp.GE)
	var target_value = cond.get("value", 0)

	var current_value = _get_post_count_by_type(post_type)
	return _compare(current_value, op, target_value)

## 获取指定类型博文发布次数
func _get_post_count_by_type(post_type: String) -> int:
	if not GDManager:
		return 0

	var blogger_data = GDManager.get_blogger()
	if blogger_data == null:
		return 0

	var count = 0
	for post in blogger_data.posts:
		# 检查多个可能的字段:category、type、type1、task_type
		if post.get("category", "") == post_type:
			count += 1
		elif post.get("type", "") == post_type:
			count += 1
		elif post.get("type1", "") == post_type:
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

## 通用比较函数
func _compare(current, op: int, target) -> bool:
	match op:
		TaskConfig.CompareOp.EQ:
			return current == target
		TaskConfig.CompareOp.NE:
			return current != target
		TaskConfig.CompareOp.GT:
			return current > target
		TaskConfig.CompareOp.GE:
			return current >= target
		TaskConfig.CompareOp.LT:
			return current < target
		TaskConfig.CompareOp.LE:
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
		"DRAW": return Blogger.Skills.DRAW
		_:
			return -1

## 获取技能字符串(用于调用 Blogger.get_ability_by_type)
func _get_skill_string(skill_name: String) -> String:
	match skill_name.to_upper():
		"LITERATURE": return "literature"
		"CODE": return "code"
		"DRAW": return "draw"
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

## 检查绘画IP授权条件
func check_draw_ip_auth(_context: Dictionary) -> bool:
	return IPAuthMgr.check_draw_ip_auth(_context) if IPAuthMgr else false

## 检查是否正在开发开源项目
func check_open_source_project(_context: Dictionary) -> bool:
	return OpenSourceMgr.check_open_source_project(_context) if OpenSourceMgr else false

## ============================================================
## 任务执行
## ============================================================

## 执行任务
func _execute_task_at(index: int, _context: Dictionary) -> void:
	if index < 0 or index >= task_states.size():
		push_error("[TaskManager] Invalid task index: %s" % index)
		return

	var task = task_states[index]

	# 标记完成(非长期任务)
	if not task.get("duration_days", false):
		task.is_completed = true

	# 执行所有动作
	for action in task.get("actions", []):
		_execute_action(action)

## 执行动作
func _execute_action(action: Dictionary) -> void:
	var action_type = action.get("type")
	if action_type == null:
		push_error("[TaskManager] Action missing 'type' field")
		return

	match action_type:
		TaskConfig.ActionType.SKILL_LEVEL_LOCK:
			_action_skill_lock(action)
		TaskConfig.ActionType.SKILL_LEVEL_UNLOCK:
			_action_skill_unlock(action)
		TaskConfig.ActionType.UNLOCK_POST_TASK:
			_action_unlock_post(action)
		TaskConfig.ActionType.LOCK_POST_TASK:
			_action_lock_post(action)
		TaskConfig.ActionType.HIDE_POST_TASK:
			_action_hide_post(action)
		TaskConfig.ActionType.REPLACE_POST_TREND:
			_action_replace_trend(action)
		TaskConfig.ActionType.UNLOCK_MILESTONES_TASK:
			_action_unlock_milestone(action)
		# ===== 书籍出版、IP授权、开源项目(委托给子模块)=====
		TaskConfig.ActionType.START_BOOK_WRITE:
			BookPublishMgr.action_start_book_write() if BookPublishMgr else null
		TaskConfig.ActionType.BOOK_PROGRESS:
			BookPublishMgr.action_book_progress(action.get("progress", 1)) if BookPublishMgr else null
		TaskConfig.ActionType.BOOK_PHASE_CHANGE:
			BookPublishMgr.action_book_phase_change(action.get("phase", 0)) if BookPublishMgr else null
		TaskConfig.ActionType.TRIGGER_IP_AUTH:
			IPAuthMgr.action_trigger_ip_auth(action.get("ip_type", "movie")) if IPAuthMgr else null
		TaskConfig.ActionType.IP_MONTHLY_INCOME:
			IPAuthMgr.action_ip_monthly_income() if IPAuthMgr else null
		TaskConfig.ActionType.START_OPEN_SOURCE_PROJECT:
			OpenSourceMgr.action_start_open_source_project() if OpenSourceMgr else null
		TaskConfig.ActionType.OPEN_SOURCE_PROGRESS:
			OpenSourceMgr.action_open_source_progress(action.get("progress", 1)) if OpenSourceMgr else null
		TaskConfig.ActionType.OPEN_SOURCE_ACQUISITION:
			OpenSourceMgr.action_open_source_acquisition() if OpenSourceMgr else null
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

	var d = Utils.find_category_by_name(Utils.learning_skills, skill_name)
	if d.is_empty():
		push_error("[TaskManager] Skill not found: %s" % skill_name)
		return

	d.isVisible = false
	d.disabled = true
	Utils.replace_task_value(Blogger.blog_calendar, skill_name, "休息") if Utils else null
	emit_signal("sg_task_info_display_msg", d.get("lock_post_tip", ""))

## 动作:解锁技能
func _action_skill_unlock(action: Dictionary) -> void:
	var skill_name = action.get("skill_name", "")
	if skill_name.is_empty():
		push_error("[TaskManager] SKILL_LEVEL_UNLOCK missing skill_name")
		return

	if not Utils:
		push_error("[TaskManager] Utils 未初始化")
		return

	var d = Utils.find_category_by_name(Utils.learning_skills, skill_name)
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

	var d = Utils.find_category_by_name(Utils.possible_categories, post_type)
	if d.is_empty():
		push_error("[TaskManager] Post type not found: %s" % post_type)
		return

	# 解锁文章类型
	d.disabled = false
	d.isVisible = true

	# 显示解锁提示
	var tip = d.get("unlock_post_tip", "解锁新文章类型:【%s】" % post_type)
	emit_signal("sg_task_info_display_msg", tip)

## 动作:锁定博文类型
func _action_lock_post(action: Dictionary) -> void:
	var post_type = action.get("post_type", "")
	if post_type.is_empty():
		push_error("[TaskManager] LOCK_POST_TASK missing post_type")
		return

	if not Utils:
		push_error("[TaskManager] Utils 未初始化")
		return

	var d = Utils.find_category_by_name(Utils.possible_categories, post_type)
	if d.is_empty():
		push_error("[TaskManager] Post type not found: %s" % post_type)
		return

	if not d.get("disabled", false):
		d.disabled = true
		Utils.replace_task_value(Blogger.blog_calendar, post_type, "休息") if Utils else null
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

	var d = Utils.find_category_by_name(Utils.possible_categories, post_type)
	if d.is_empty():
		push_error("[TaskManager] Post type not found: %s" % post_type)
		return

	# 隐藏并锁定
	d.isVisible = false
	d.disabled = true

	# 如果是第一篇博文,从所有日程中移除这个任务
	if post_type == "第一篇博文":
		for day_task in Blogger.blog_calendar:
			if post_type in day_task.tasks:
				day_task.tasks.erase(post_type)
	else:
		Utils.replace_task_value(Blogger.blog_calendar, post_type, "休息") if Utils else null

	emit_signal("sg_task_info_display_msg", d.get("lock_post_tip", ""))
	emit_signal("schedule_refresh_needed")

## 动作:更换热点
func _action_replace_trend(_action: Dictionary) -> void:
	if not Utils:
		push_error("[TaskManager] Utils not available")
		return

	var random_index = randi() % Utils.bc_type.size()
	Utils.post_trend.type = Utils.bc_type[random_index]
	var tip = Strs.task_str.热点风向[Utils.post_trend.type][random_index] if Strs else ""
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

## ============================================================
## 月结算接口（委托给子模块）
## ============================================================

## 每月结算书籍销售收入
func settle_monthly_book_sales() -> Dictionary:
	return BookPublishMgr.settle_monthly_book_sales() if BookPublishMgr else {"total_income": 0}

## 每月结算开源项目赞助收入
func settle_monthly_open_source() -> Dictionary:
	return OpenSourceMgr.settle_monthly_open_source() if OpenSourceMgr else {"total_income": 0}
