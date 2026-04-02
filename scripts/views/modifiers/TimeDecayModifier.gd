## 时间衰减修饰器
## 新文章14天内正常访问量，之后随机零星访问，3年后不再增加
class_name TimeDecayModifier
extends ViewsModifier

## 配置参数
var new_article_days: int = 14          # 新文章期（天）
var active_article_years: int = 3       # 有效文章年限
var random_visit_chance: float = 0.3    # 随机访问概率（30%）
var min_random_views: int = 1           # 随机访问最小值
var max_random_views: int = 5           # 随机访问最大值

func _init():
	modifier_name = "time_decay"
	display_name = "时间衰减"
	description = "新文章14天内正常，之后随机零星访问，3年后不再增加"
	priority = 100
	type = Type.DECAY

func apply(views: int, post: Dictionary, blogger: Dictionary) -> int:
	var post_date = post.get("date", "")
	if post_date == "":
		return views
	
	# 计算文章年龄（天数）
	var now_date = Utils.format_date()
	var days = Utils.calculate_new_game_time_difference(post_date, now_date)
	
	# 1. 新文章期（0-14天）：正常访问量
	if days <= new_article_days:
		return views
	
	# 2. 超过3年（游戏年336天，3年约1008天）：不再增加访问量
	var max_active_days = active_article_years * 336
	if days > max_active_days:
		return 0  # 完全不再增加
	
	# 3. 14天-3年：随机零星访问量
	# 30%概率有访问量，70%概率没有
	if randf() > random_visit_chance:
		return 0  # 今天没有访问量
	
	# 有访问量时，返回少量随机值（模拟搜索引擎/RSS来源）
	var random_views = randi_range(min_random_views, max_random_views)
	
	# 随着时间推移，访问量逐渐减少
	# 第15天：100%，第3年：约30%
	var decay_factor = 1.0 - (float(days - new_article_days) / float(max_active_days - new_article_days)) * 0.7
	
	return int(float(random_views) * decay_factor)

## 获取文章访问状态描述
func get_article_status(days: int) -> String:
	var max_days = active_article_years * 336
	
	if days <= new_article_days:
		return "新文章期（正常访问）"
	elif days <= max_days:
		return "活跃期（随机访问）"
	else:
		return "归档期（无访问）"