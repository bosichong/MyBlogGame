## 收藏加成修饰器
class_name FavoritesModifier
extends ViewsModifier

## 有效期（天）
var effective_days: int = 280

func _init():
	modifier_name = "favorites"
	display_name = "收藏加成"
	description = "根据文章收藏数增加访问量"
	priority = 230
	type = Type.BOOST

func apply(views: int, post: Dictionary, blogger: Dictionary) -> int:
	var post_date = post.get("date", "")
	if post_date == "":
		return views
	
	var now_date = Utils.format_date()
	var days = Utils.calculate_new_game_time_difference(post_date, now_date)
	
	# 超过有效期不加成
	if days > effective_days:
		return views
	
	var favorites = post.get("favorites", 0)
	if favorites <= 0:
		return views
	
	var quality = post.get("quality", 100)
	
	# 收藏数 × 质量系数 × 5%
	var quality_factor = float(quality) / 100.0
	var bonus = int(favorites * 0.05 * quality_factor)
	
	return views + bonus