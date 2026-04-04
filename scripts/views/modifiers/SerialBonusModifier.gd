## 连载加成修饰器
## 用于文学周刊等连续性文章
## 加成公式：1.0 + 发布篇数 × 0.01
class_name SerialBonusModifier
extends ViewsModifier

## 连载文章类型列表（文学周刊、程序员周刊、艺术周刊）
## 小说连载、动漫连载是付费文章不计入总访问量
var serial_types: Array = ["文学周刊", "程序员周刊", "艺术周刊", "动漫连载(收费)"]

func _init():
	modifier_name = "serial_bonus"
	display_name = "连载加成"
	description = "周刊文章根据发布篇数获得递增加成"
	priority = 260
	type = Type.BOOST

func apply(views: int, post: Dictionary, blogger: Dictionary) -> int:
	var category = post.get("category", "")
	
	# 检查是否是连载类型文章
	if not category in serial_types:
		return views
	
	# 计算该类型文章的发布篇数
	var serial_count = _get_serial_count(category, blogger)
	
	# 加成公式：1.0 + 发布篇数 × 0.01
	# 即：每发布1篇，加成增加1%
	var bonus_ratio = 1.0 + float(serial_count) * 0.01
	
	# 应用加成
	var bonus = int(views * (bonus_ratio - 1.0))
	
	return views + bonus

## 获取指定类型连载文章的发布篇数
func _get_serial_count(category: String, blogger: Dictionary) -> int:
	var posts = blogger.get("posts", [])
	var count = 0
	
	for post in posts:
		if post.get("category", "") == category:
			count += 1
	
	return count

## 获取连载加成信息（用于UI显示）
func get_serial_bonus_info(category: String, blogger: Dictionary) -> Dictionary:
	var count = _get_serial_count(category, blogger)
	var bonus_ratio = 1.0 + float(count) * 0.01
	
	return {
		"category": category,
		"published_count": count,
		"bonus_ratio": bonus_ratio,
		"bonus_percent": int((bonus_ratio - 1.0) * 100)
	}