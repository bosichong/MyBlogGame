## 主机流量限制修饰器
class_name HostLimitModifier
extends ViewsModifier

func _init():
	modifier_name = "host_limit"
	display_name = "主机流量限制"
	description = "主机套餐的月访问量上限"
	priority = 300
	type = Type.LIMIT

func apply(views: int, post: Dictionary, blogger: Dictionary) -> int:
	# 从Yun系统获取限制
	var monthly_limit = Yun.get_monthly_traffic_limit()
	
	# 无限制
	if monthly_limit < 0:
		return views
	
	var month_views = blogger.get("month_views", 0)
	var limit_count = monthly_limit * 10000
	var remaining = limit_count - month_views
	
	# 已达上限
	if remaining <= 0:
		return randi_range(1, 5)
	
	# 接近上限，截断
	if views > remaining:
		return remaining
	
	return views