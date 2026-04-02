## 欠费惩罚修饰器
class_name SuspendPenaltyModifier
extends ViewsModifier

func _init():
	modifier_name = "suspend_penalty"
	display_name = "欠费惩罚"
	description = "域名或主机欠费时减少或暂停访问量"
	priority = 310
	type = Type.LIMIT

func apply(views: int, post: Dictionary, blogger: Dictionary) -> int:
	# 检查是否暂停
	if Yun.is_blog_suspended():
		return 0
	
	# 检查恢复惩罚
	var penalty = Yun.recovery_penalty
	if penalty > 0 and penalty < 1.0:
		return int(views * (1.0 - penalty))
	
	return views