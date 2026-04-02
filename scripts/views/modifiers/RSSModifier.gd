## RSS订阅加成修饰器
class_name RSSModifier
extends ViewsModifier

## 有效期（可配置）
var rss_effective_days: int = 14

func _init():
	modifier_name = "rss"
	display_name = "RSS订阅加成"
	description = "根据RSS订阅数增加新文章访问量"
	priority = 220
	type = Type.BOOST

func apply(views: int, post: Dictionary, blogger: Dictionary) -> int:
	var post_date = post.get("date", "")
	if post_date == "":
		return views
	
	var now_date = Utils.format_date()
	var days = Utils.calculate_new_game_time_difference(post_date, now_date)
	
	# 超过有效期不加成
	if days > rss_effective_days:
		return views
	
	var rss = blogger.get("rss", 0)
	if rss <= 0:
		return views
	
	# 根据天数递减RSS加成
	var ratio = 1.0 - float(days) / float(rss_effective_days + 1)
	var bonus = int(rss * 0.1 * ratio)
	
	return views + bonus