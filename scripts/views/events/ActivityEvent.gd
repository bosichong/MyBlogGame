## 节日活动事件
class_name ActivityEvent
extends ViewsEvent

var activity_name: String = ""

func _init():
	event_id = "activity"
	event_name = "节日活动"
	description = "节日期间访问量增加"
	duration = 7
	bonus_ratio = 0.3  # 30%加成

## 检查触发条件（活动事件由外部触发，不自动检查）
func check_trigger(blogger: Dictionary) -> bool:
	return false

## 启动活动（由外部调用，如节日系统）
func start_activity(name: String, days: int, bonus: float) -> void:
	activity_name = name
	duration = days
	bonus_ratio = bonus
	trigger()

## 获取活动信息
func get_info() -> Dictionary:
	var info = super.get_info()
	info["activity_name"] = activity_name
	return info