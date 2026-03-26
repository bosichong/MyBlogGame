class_name TaskData extends Resource

var task_states: Array[Dictionary] = []
var completed_tasks: int = 0
var active_tasks: int = 0
var total_rewards: Dictionary = {"money": 0.0, "exp": 0}

signal task_completed(task_id: String)
signal task_started(task_id: String)
signal rewards_claimed(rewards: Dictionary)

# ===== 辅助方法 =====

func initialize_task(task_id: String, task_config: Dictionary):
    var task_state = {
        "id": task_id,
        "name": task_config.get("name", ""),
        "description": task_config.get("description", ""),
        "type": task_config.get("type", "daily"),
        "status": "available",  # available, active, completed, claimed
        "progress": 0,
        "target": task_config.get("target", 1),
        "rewards": task_config.get("rewards", {}),
        "start_date": "",
        "completed_date": "",
        "claimed_date": "",
        "repeat_count": 0
    }
    task_states.append(task_state)

func start_task(task_id: String):
    for i in range(task_states.size()):
        if task_states[i]["id"] == task_id and task_states[i]["status"] == "available":
            task_states[i]["status"] = "active"
            task_states[i]["start_date"] = Time.get_date_string_from_system()
            active_tasks += 1
            emit_signal("task_started", task_id)
            return true
    return false

func update_task_progress(task_id: String, progress: int):
    for i in range(task_states.size()):
        if task_states[i]["id"] == task_id and task_states[i]["status"] == "active":
            task_states[i]["progress"] = progress
            if progress >= task_states[i]["target"]:
                complete_task(task_id)
            return true
    return false

func complete_task(task_id: String):
    for i in range(task_states.size()):
        if task_states[i]["id"] == task_id and task_states[i]["status"] == "active":
            task_states[i]["status"] = "completed"
            task_states[i]["completed_date"] = Time.get_date_string_from_system()
            task_states[i]["progress"] = task_states[i]["target"]
            completed_tasks += 1
            active_tasks -= 1
            emit_signal("task_completed", task_id)
            return true
    return false

func claim_rewards(task_id: String) -> Dictionary:
    for i in range(task_states.size()):
        if task_states[i]["id"] == task_id and task_states[i]["status"] == "completed":
            var rewards = task_states[i]["rewards"]
            task_states[i]["status"] = "claimed"
            task_states[i]["claimed_date"] = Time.get_date_string_from_system()

            # 累积奖励
            if rewards.has("money"):
                total_rewards.money += rewards["money"]
            if rewards.has("exp"):
                total_rewards.exp += rewards["exp"]

            # 增加重复计数（用于重复任务）
            task_states[i]["repeat_count"] += 1

            # 如果是每日/每周任务，重置状态
            if task_states[i]["type"] in ["daily", "weekly"]:
                task_states[i]["status"] = "available"
                task_states[i]["progress"] = 0

            emit_signal("rewards_claimed", rewards)
            return rewards
    return {}

func get_task_by_id(task_id: String) -> Dictionary:
    for task_state in task_states:
        if task_state["id"] == task_id:
            return task_state
    return {}

func get_tasks_by_status(status: String) -> Array[Dictionary]:
    var result = []
    for task_state in task_states:
        if task_state["status"] == status:
            result.append(task_state)
    return result

func get_active_tasks() -> Array[Dictionary]:
    return get_tasks_by_status("active")

func get_available_tasks() -> Array[Dictionary]:
    return get_tasks_by_status("available")

func get_completed_tasks() -> Array[Dictionary]:
    return get_tasks_by_status("completed")

func get_completion_rate() -> float:
    if task_states.is_empty():
        return 0.0
    return float(completed_tasks) / float(task_states.size())

func reset_daily_tasks():
    for i in range(task_states.size()):
        if task_states[i]["type"] == "daily":
            if task_states[i]["status"] != "claimed":
                # 未完成的每日任务重置
                task_states[i]["status"] = "available"
                task_states[i]["progress"] = 0
            else:
                # 已完成的每日任务重新激活
                task_states[i]["status"] = "available"
                task_states[i]["progress"] = 0

func reset_weekly_tasks():
    for i in range(task_states.size()):
        if task_states[i]["type"] == "weekly":
            if task_states[i]["status"] != "claimed":
                task_states[i]["status"] = "available"
                task_states[i]["progress"] = 0
            else:
                task_states[i]["status"] = "available"
                task_states[i]["progress"] = 0