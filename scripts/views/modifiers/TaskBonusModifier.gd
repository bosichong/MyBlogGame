## 任务加成修饰器
## 任务型文章（节日/活动等）的访问量加成
class_name TaskBonusModifier
extends ViewsModifier

## 活跃的任务加成
var active_task_bonuses: Dictionary = {}

func _init():
	modifier_name = "task_bonus"
	display_name = "任务加成"
	description = "任务型文章的访问量加成（节日/活动等）"
	priority = 500  # 在所有基础计算之后
	type = Type.BOOST

func apply(views: int, post: Dictionary, blogger: Dictionary) -> int:
	var task_type = post.get("task_type", "")
	
	# 非任务型文章不加成
	if task_type == "":
		return views
	
	# 根据任务类型获取加成比例
	var bonus_ratio = _get_task_bonus_ratio(task_type)
	
	return int(views * (1.0 + bonus_ratio))

## 获取任务加成比例
func _get_task_bonus_ratio(task_type: String) -> float:
	match task_type:
		"第一篇博文":
			# 第一篇博文：50%-100%加成
			return randf_range(0.5, 1.0)
		"年度总结":
			# 年度总结：50%-100%加成
			return randf_range(0.5, 1.0)
		"节日文章":
			# 节日文章：100%-400%加成
			return randf_range(1.0, 4.0)
		"活动文章":
			# 活动文章：200%-900%加成
			return randf_range(2.0, 9.0)
		"专题文章":
			# 专题文章：100%-300%加成
			return randf_range(1.0, 3.0)
		_:
			return 0.0

## 激活任务加成（由任务系统调用）
func activate_task_bonus(task_type: String, bonus_ratio: float, duration: int) -> void:
	active_task_bonuses[task_type] = {
		"ratio": bonus_ratio,
		"duration": duration,
		"remaining": duration
	}

## 每日更新（减少剩余天数）
func daily_update() -> void:
	for task_type in active_task_bonuses.keys():
		var bonus = active_task_bonuses[task_type]
		bonus.remaining -= 1
		if bonus.remaining <= 0:
			active_task_bonuses.erase(task_type)

## 获取活跃的任务加成列表
func get_active_bonuses() -> Array:
	var result = []
	for task_type in active_task_bonuses:
		result.append({
			"task_type": task_type,
			"ratio": active_task_bonuses[task_type].ratio,
			"remaining": active_task_bonuses[task_type].remaining
		})
	return result