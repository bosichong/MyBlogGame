## 文章质量加成修饰器
## 质量分越高，加成越明显（后期爆发）
class_name QualityModifier
extends ViewsModifier

func _init():
	modifier_name = "quality"
	display_name = "文章质量加成"
	description = "根据文章质量分数增加访问量"
	priority = 10
	type = Type.BASE

func apply(views: int, post: Dictionary, blogger: Dictionary) -> int:
	var quality = post.get("quality", 100)
	
	# 质量加成：质量分越高，加成越明显
	# 新手期质量分约50: ×1.33
	# 中期质量分约100: ×1.67
	# 满级期质量分200: ×2.33
	var multiplier = 1.0 + float(quality) / 150.0
	return int(views * multiplier)