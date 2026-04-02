## 段位加成修饰器
class_name RankModifier
extends ViewsModifier

func _init():
	modifier_name = "rank"
	display_name = "段位加成"
	description = "根据博主段位增加访问量"
	priority = 210
	type = Type.BOOST

func apply(views: int, post: Dictionary, blogger: Dictionary) -> int:
	var rank = blogger.get("rank_tier", 0)
	
	# 指数加成：段位越高，加成越明显
	# 公式：rank² × 0.006
	# 段位0: 0%
	# 段位5: 25 × 0.006 = 15%
	# 段位9: 81 × 0.006 = 49%
	var bonus_ratio = float(rank * rank) * 0.006
	var bonus = int(views * bonus_ratio)
	return views + bonus