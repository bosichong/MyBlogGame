extends Node
## 游戏的事件管理器，负责遍历触发各个事件

# 引用任务配置
const TaskConfig = preload("res://scripts/task_system/TaskConfig.gd")
# 任务状态副本（用于运行时修改）
var task_states: Array[Dictionary] = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    reset_task_states()
    Blogger.connect("sg_new_blog_post",check_new_blog_post)
    Blogger.connect("s_level",check_lv_based_tasks)
    Blogger.connect("skill_level_up",check_skill_level_up)

# 重置任务状态
func reset_task_states():
    task_states.clear()
    
    # 复制任务配置到运行时状态
    for task in TaskConfig.TASKS:
        var task_state = task.duplicate(true)
        task_states.append(task_state)


#任务生命周期：
#start_task(): 开始任务，标记为进行中
#execute_task(): 执行任务，对于短期任务立即完成，对于长期任务标记为进行中
#complete_task(): 完成任务，应用奖励和后果
#cancel_task(): 取消进行中的任务


# 这个方法是每天信号量，每天遍历一次。
func day_task_func():
    check_time_based_tasks()

## 根据技能属性值以及种类来触发相关人物
func check_skill_level_up(type:int,lv:float):
    for task in task_states:
        
        if task.type != TaskConfig.TaskType.SKILL_BASED:
            continue
        
        if task.skill_type != type:
            continue
            
        if task.level != lv:
            continue
            
        if lv > Blogger.MAX_SKILL_LEVEL: #大于100跳过
            continue
        
            
        # 跳过非激活任务
        if not task.is_active:
            continue
            
        # 跳过已完成且不可重复的任务
        if task.is_completed and not task.is_repeatable:
            continue
            
        # 如果是长期任务，标记为进行中但不立即完成
        if task.has("duration_days"):
            if not task.is_in_progress:
                start_task(task)
            else: #任务行中则直接开始
                execute_task(task)
        else:
            execute_task(task)   

# 检查等级段位成就LV_BASED类型任务
func check_lv_based_tasks(lv : int):
    for task in task_states:
        if task.type != TaskConfig.TaskType.LV_BASED:
            continue
        if lv != task.lv:
            continue
        # 跳过非激活任务
        if not task.is_active:
            continue
            
        # 跳过已完成且不可重复的任务
        if task.is_completed and not task.is_repeatable:
            continue
            
        # 如果是长期任务，标记为进行中但不立即完成
        if task.has("duration_days"):
            if not task.is_in_progress:
                start_task(task)
            else: #任务行中则直接开始
                execute_task(task)
        else:
            execute_task(task)

# 这里定义了一个博文发布信号量，当有博文成功发布时候触发，用来检查有关博文发布先关的任务。
func check_new_blog_post(category: String):
    for task in task_states:
        # 跳过非此类型任务
        if task.type != TaskConfig.TaskType.NEW_BLOG_POST:
            continue
        #如果发布的博文类型不在当前任务配置触发的类型中。
        if category != task.post_type:
            continue
        
        # 跳过非激活任务
        if not task.is_active:
            continue
            
        # 跳过已完成且不可重复的任务
        if task.is_completed and not task.is_repeatable:
            continue
            
        # 如果是长期任务，标记为进行中但不立即完成
        if task.has("duration_days"):
            if not task.is_in_progress:
                start_task(task)
            else: #任务行中则直接开始
                execute_task(task)
        else:
            execute_task(task)

# 检查时间基础任务
func check_time_based_tasks():
    for task in task_states:
        # 跳过非时间任务
        if task.type != TaskConfig.TaskType.TIME_BASED:
            continue
            
        # 跳过非激活任务
        if not task.is_active:
            continue
            
        # 跳过已完成且不可重复的任务
        if task.is_completed and not task.is_repeatable:
            continue
            
        # 检查时间条件
        if TimerManager.is_time_match(task.event_date):
            if task.is_currently_valid: # 在有效的时间内执行任务
                # 如果是长期任务，标记为进行中但不立即完成
                if task.has("duration_days"):
                    if not task.is_in_progress:
                        start_task(task)
                    else: #任务行中则直接始
                        execute_task(task)
                else:
                    execute_task(task)
        else:
            if not task.is_currently_valid: #在无效的时间内执行任务
                # 如果是长期任务，标记为进行中但不立即完成
                if task.has("duration_days"):
                    if not task.is_in_progress:
                        start_task(task)
                    else: #任务行中则直接始
                        execute_task(task)
                else:
                    execute_task(task)

# 开始任务（标记为进行中）
func start_task(task: Dictionary):
    print("开始任务: ", task.id)
    print("任务描述: ", task.description)
    
    # 标记任务为进行中
    task.is_in_progress = true
    
    # 执行任务动作
    for action in task.actions:
        execute_action(action)
    
    
# 执行任务（立即完成）
func execute_task(task: Dictionary):
    print("执行任务: ", task.id)
    print("任务描述: ", task.description)
    
    
    # 如果任务有持续时间，也标记为进行中
    if task.has("duration_days"):
        task.is_in_progress = true
    else: #短期任务
        task.is_in_progress = false #不在任务中，执行一次就完成了
        task.is_completed = true #标记任务结束
    
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
            emit_signal("sg_task_show_popup_msg","提示", tmp_tips)
        TaskConfig.ActionType.UNLOCK_POST_TASK:
            var d = Utils.find_category_by_name(Utils.possible_categories,action.post_type)
            if d.disabled:
                d.disabled = false
                emit_signal("sg_task_info_display_msg",d.unlock_post_tip)
        TaskConfig.ActionType.LOCK_POST_TASK:
            var d = Utils.find_category_by_name(Utils.possible_categories,action.post_type)
            if d.disabled:
                pass
            else:
                d.disabled = true
                Utils.replace_task_value(Blogger.blog_calendar, action.post_type, "休息")  # 更新日历任务为休息
                emit_signal("sg_task_info_display_msg",d.lock_post_tip)
        TaskConfig.ActionType.HIDE_POST_TASK:
            var d = Utils.find_category_by_name(Utils.possible_categories,action.post_type)
            if not d.isVisible:
                pass
            else:
                d.isVisible = false
                Utils.replace_task_value(Blogger.blog_calendar, action.post_type, "休息") 
                emit_signal("sg_task_info_display_msg",d.lock_post_tip)
        TaskConfig.ActionType.UNLOCK_MILESTONES_TASK:
            var m = Utils.find_category_by_id(GDManager["milestones"][action.milestones_name],action.milestones_id)
            m.unlocked=true
            
        TaskConfig.ActionType.SKILL_LEVEL_LOCK:
            var d = Utils.find_category_by_name(Utils.learning_skills,action.skill_name)
            d.isVisible = false
            d.disabled = true
            Utils.replace_task_value(Blogger.blog_calendar, action.skill_name, "休息") 
            emit_signal("sg_task_info_display_msg",d.lock_post_tip)
        TaskConfig.ActionType.SKILL_LEVEL_UNLOCK:  
            var d = Utils.find_category_by_name(Utils.learning_skills,action.skill_name)
            d.isVisible = true
            d.disabled = false
            emit_signal("sg_task_info_display_msg",d.unlock_post_tip)
            
            
        
        
            
            
signal sg_task_info_display_msg(msg:String)
signal sg_task_show_popup_msg(title: String, content: String)
