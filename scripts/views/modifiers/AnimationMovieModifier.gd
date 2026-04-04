## 动画影视创作访问量修饰器
## 访问量基于玩家的绘画技能评分计算
## 绘画评分 = 绘画能力值
class_name AnimationMovieModifier
extends ViewsModifier

func _init():
	modifier_name = "animation_movie"
	display_name = "动画影视加成"
	description = "动画影视创作访问量基于绘画技能评分"
	priority = 240
	type = Type.BOOST

func apply(views: int, post: Dictionary, blogger: Dictionary) -> int:
	var category = post.get("category", "")
	
	# 只对动画影视创作生效
	if category != "动画影视创作":
		return views
	
	# 计算绘画技能评分
	var draw_score = _calculate_draw_score(blogger)
	
	# 绘画评分加成：0-100分对应0%-200%加成
	# 公式：加成 = 评分 / 50 （即50分时加成100%，100分时加成200%）
	var bonus_ratio = draw_score / 50.0
	
	# 应用加成
	var bonus = int(views * bonus_ratio)
	
	return views + bonus

## 计算绘画技能评分
func _calculate_draw_score(blogger: Dictionary) -> float:
	var draw = blogger.get("draw_level", 0.0)
	
	# 如果博客数据没有直接的技能值，尝试从Blogger获取
	if Blogger and Blogger.has_method("get_ability_by_type"):
		draw = Blogger.get_ability_by_type("draw")
	
	return draw

## 获取绘画评分信息（用于UI显示）
func get_draw_score_info(blogger: Dictionary) -> Dictionary:
	var draw = 0.0
	
	if Blogger and Blogger.has_method("get_ability_by_type"):
		draw = Blogger.get_ability_by_type("draw")
	
	var bonus_ratio = draw / 50.0
	
	return {
		"draw": draw,
		"bonus_ratio": bonus_ratio,
		"bonus_percent": int(bonus_ratio * 100)
	}