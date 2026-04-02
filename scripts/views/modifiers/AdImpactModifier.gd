## 广告影响修饰器
class_name AdImpactModifier
extends ViewsModifier

func _init():
	modifier_name = "ad_impact"
	display_name = "广告影响"
	description = "投放广告对访问量的影响"
	priority = 320
	type = Type.LIMIT

func apply(views: int, post: Dictionary, blogger: Dictionary) -> int:
	# 检查是否投放广告
	if not AdManager.ad_2:
		return views
	
	# 获取当前广告类型的影响比例
	var ad_affect = _get_current_ad_affect()
	
	return int(views * (1.0 - ad_affect))

## 获取当前广告对访问量的影响比例
func _get_current_ad_affect() -> float:
	var ad_type = AdManager.ad_set
	
	# 根据广告类型返回影响比例
	match ad_type:
		"文字广告":
			return 0.0
		"图文广告":
			return 0.1
		"全站图文":
			return 0.15
		"弹窗广告":
			return 0.3
		_:
			return 0.0