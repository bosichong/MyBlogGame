## 平台推荐事件
class_name FeaturedEvent
extends ViewsEvent

func _init():
	event_id = "featured"
	event_name = "平台推荐"
	description = "文章被平台推荐，持续获得流量"
	duration = 7
	bonus_ratio = 0.5  # 50%加成

func check_trigger(blogger: Dictionary) -> bool:
	# SEO>150 且 设计值>150 时有3%概率触发
	var seo = blogger.get("seo_value", 0)
	var design = blogger.get("design_value", 0)
	
	if seo > 150 and design > 150:
		return randf() < 0.03
	
	return false