extends Node
## 游戏的事件管理器，负责遍历触发各个事件

# 引用任务配置
const TaskConfig = preload("res://scripts/task_system/TaskConfig.gd")
# 任务状态副本（用于运行时修改）
var task_states: Array[Dictionary]:
    get:
        if GDManager:
            return GDManager.get_task().task_states
        return []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    reset_task_states()
    Blogger.connect("sg_new_blog_post", check_new_blog_post)
    Blogger.connect("s_level", check_lv_based_tasks)
    Blogger.connect("skill_level_up", check_skill_level_up)

# 重置任务状态
func reset_task_states():
    if not GDManager:
        return

    var task_data = GDManager.get_task()
    task_data.task_states.clear()

    # 复制任务配置到运行时状态
    for task in TaskConfig.TASKS:
        var task_state = task.duplicate(true)
        task_data.task_states.append(task_state)


# 这个方法是每天信号量，每天遍历一次。
func day_task_func():
    check_time_based_tasks()

## 根据技能属性值以及种类来触发相关任务
func check_skill_level_up(type: int, lv: float):
    for i in range(task_states.size()):
        var task = task_states[i]
        
        if task.type != TaskConfig.TaskType.SKILL_BASED:
            continue
        
        if task.skill_type != type:
            continue
        
        # 使用 >= 判断，能力值达到或超过阈值时触发
        if lv < task.level:
            continue
        
        if task.level > Blogger.MAX_SKILL_LEVEL:
            continue
        
        # 跳过非激活任务
        if not task.is_active:
            continue
        
        # 跳过已完成且不可重复的任务
        if task.is_completed and not task.is_repeatable:
            continue
        
        execute_task_at(i)

# 检查等级段位成就LV_BASED类型任务
func check_lv_based_tasks(lv: int):
    for i in range(task_states.size()):
        var task = task_states[i]
        
        if task.type != TaskConfig.TaskType.LV_BASED:
            continue
        if lv != task.lv:
            continue
        if not task.is_active:
            continue
        if task.is_completed and not task.is_repeatable:
            continue
        
        execute_task_at(i)

# 这里定义了一个博文发布信号量，当有博文成功发布时候触发
func check_new_blog_post(category: String):
    for i in range(task_states.size()):
        var task = task_states[i]
        
        if task.type != TaskConfig.TaskType.NEW_BLOG_POST:
            continue
        if category != task.post_type:
            continue
        if not task.is_active:
            continue
        if task.is_completed and not task.is_repeatable:
            continue
        
        execute_task_at(i)

# 检查时间基础任务
func check_time_based_tasks():
    for i in range(task_states.size()):
        var task = task_states[i]
        
        if task.type != TaskConfig.TaskType.TIME_BASED:
            continue
        if not task.is_active:
            continue
        if task.is_completed and not task.is_repeatable:
            continue
        
        if TimerManager.is_time_match(task.event_date):
            if task.is_currently_valid:
                execute_task_at(i)
        else:
            if not task.is_currently_valid:
                execute_task_at(i)

# 执行任务（立即完成）
func execute_task_at(index: int):
    var task = task_states[index]
    
    # 标记完成
    if not task.has("duration_days"):
        task.is_completed = true
    
    print("[任务完成] ", task.id)
    
    # 执行任务动作
    for action in task.actions:
        execute_action(action)

# 执行动作
func execute_action(action: Dictionary):
    var action_type = action.get("type", TaskConfig.ActionType.CUSTOM_ACTION)
    
    match action_type:
        TaskConfig.ActionType.REPLACE_POST_TREND:
            var random_index = randi() % Utils.bc_type.size()
            Utils.post_trend.type = Utils.bc_type[random_index]
            var tmp_tips = Strs.task_str.热点风向[Utils.post_trend.type][random_index]
            emit_signal("sg_task_show_popup_msg", "提示", tmp_tips)
        
        TaskConfig.ActionType.UNLOCK_POST_TASK:
            var d = Utils.find_category_by_name(Utils.possible_categories, action.post_type)
            if d.disabled:
                d.disabled = false
                emit_signal("sg_task_info_display_msg", d.unlock_post_tip)
        
        TaskConfig.ActionType.LOCK_POST_TASK:
            var d = Utils.find_category_by_name(Utils.possible_categories, action.post_type)
            if not d.disabled:
                d.disabled = true
                Utils.replace_task_value(Blogger.blog_calendar, action.post_type, "休息")
                emit_signal("sg_task_info_display_msg", d.lock_post_tip)
        
        TaskConfig.ActionType.HIDE_POST_TASK:
            var d = Utils.find_category_by_name(Utils.possible_categories, action.post_type)
            if d.isVisible:
                d.isVisible = false
                Utils.replace_task_value(Blogger.blog_calendar, action.post_type, "休息")
                emit_signal("sg_task_info_display_msg", d.lock_post_tip)
        
        TaskConfig.ActionType.UNLOCK_MILESTONES_TASK:
            var m = Utils.find_category_by_id(GDManager.milestones[action.milestones_name], action.milestones_id)
            m.unlocked = true
        
        TaskConfig.ActionType.SKILL_LEVEL_LOCK:
            var d = Utils.find_category_by_name(Utils.learning_skills, action.skill_name)
            d.isVisible = false
            d.disabled = true
            Utils.replace_task_value(Blogger.blog_calendar, action.skill_name, "休息")
            emit_signal("sg_task_info_display_msg", d.lock_post_tip)
        
        TaskConfig.ActionType.SKILL_LEVEL_UNLOCK:
            var d = Utils.find_category_by_name(Utils.learning_skills, action.skill_name)
            d.isVisible = true
            d.disabled = false
            emit_signal("sg_task_info_display_msg", d.unlock_post_tip)

signal sg_task_info_display_msg(msg: String)
signal sg_task_show_popup_msg(title: String, content: String)