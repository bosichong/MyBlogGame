## 访问量计算器
## 整合修饰器、事件、统计、文章统计四大系统
class_name ViewsCalculator
extends RefCounted

var modifier_manager: ViewsModifierManager
var event_manager: ViewsEventManager
var stats_manager: ViewsStatsManager
var post_stats_manager: PostStatsManager
var debug_mode: bool = false

signal event_triggered(event_name: String, event_display_name: String)

func _init():
	modifier_manager = ViewsModifierManager.new()
	event_manager = ViewsEventManager.new()
	stats_manager = ViewsStatsManager.new()
	post_stats_manager = PostStatsManager.new()
	
	modifier_manager.debug_mode = debug_mode
	
	_register_default_modifiers()
	_register_default_events()

## 注册默认修饰器
func _register_default_modifiers() -> void:
	# 基础层
	modifier_manager.register(SEOBaseModifier.new())
	modifier_manager.register(QualityModifier.new())
	
	# 衰减层
	modifier_manager.register(TimeDecayModifier.new())
	
	# 加成层
	modifier_manager.register(DesignModifier.new())
	modifier_manager.register(RankModifier.new())
	modifier_manager.register(RSSModifier.new())
	modifier_manager.register(FavoritesModifier.new())
	modifier_manager.register(ShareModifier.new())
	modifier_manager.register(TrendModifier.new())
	modifier_manager.register(TaskBonusModifier.new())  # 任务加成
	
	# 限制层
	modifier_manager.register(HostLimitModifier.new())
	modifier_manager.register(SuspendPenaltyModifier.new())
	modifier_manager.register(AdImpactModifier.new())

## 注册默认事件
func _register_default_events() -> void:
	event_manager.register(ViralEvent.new())
	event_manager.register(FeaturedEvent.new())
	event_manager.register(ActivityEvent.new())

## 每日计算（在blogger.gd中调用）
## 注意：会直接修改 posts 中每篇文章的 views 字段
func calculate_daily(blogger_data: Dictionary) -> Dictionary:
	# 1. 检查事件触发
	var triggered_events = event_manager.check_daily(blogger_data)
	
	# 2. 计算每篇文章访问量
	var total_views = 0
	var sources = {
		"direct": 0,
		"search": 0,
		"social": 0,
		"rss": 0,
		"favorite": 0,
		"event": 0,
		"task": 0
	}
	
	var posts = blogger_data.get("posts", [])
	for post in posts:
		var result = _calculate_post_views(post, blogger_data)
		total_views += result.views
		
		# 更新文章的 views 字段
		post.views = post.get("views", 0) + result.views
		
		# 记录单篇文章统计
		var post_id = post.get("id", "")
		if post_id != "":
			post_stats_manager.record_post_views(post_id, result.views, result.sources)
		
		# 统计来源
		for key in result.sources:
			if sources.has(key):
				sources[key] += result.sources[key]
	
	# 3. 记录总体统计
	var date = Utils.format_date()
	stats_manager.record_daily(date, total_views, posts.size(), sources)
	
	# 4. 发送事件信号
	for event_name in triggered_events:
		var event = event_manager.get_event(event_name)
		if event:
			emit_signal("event_triggered", event_name, event.event_name)
	
	return {
		"views": total_views,
		"triggered_events": triggered_events,
		"sources": sources
	}

## 计算单篇文章访问量
func _calculate_post_views(post: Dictionary, blogger: Dictionary) -> Dictionary:
	# 1. 应用修饰器
	var mod_result = modifier_manager.apply_all(0, post, blogger)
	var views = mod_result.views
	
	# 2. 应用事件
	var event_bonus = 0
	var active_events = event_manager.get_active_events()
	for event in active_events:
		var before = views
		views = event.apply(views, post, blogger)
		event_bonus += views - before
	
	# 3. 分析来源
	var sources = _analyze_sources(views, post, blogger, mod_result.debug_log)
	sources.event = event_bonus
	
	return {
		"views": views,
		"sources": sources,
		"debug_log": mod_result.debug_log if debug_mode else []
	}

## 分析访问量来源
func _analyze_sources(views: int, post: Dictionary, blogger: Dictionary, debug_log: Array) -> Dictionary:
	var sources = {
		"direct": 0,
		"search": 0,
		"social": 0,
		"rss": 0,
		"favorite": 0,
		"event": 0,
		"task": 0
	}
	
	# 根据修饰器贡献分配来源
	for log in debug_log:
		var name = log.name
		var change = log.change
		
		match name:
			"SEO基础访问量", "文章质量加成":
				sources.direct += change
			"RSS订阅加成":
				sources.rss += change
			"收藏加成":
				sources.favorite += change
			"分享加成":
				sources.social += change
			"任务加成":
				sources.task += change
			_:
				sources.direct += change
	
	return sources

## 每日更新（在main.gd中调用）
func daily_update() -> void:
	event_manager.daily_update()
	
	# 更新任务加成
	var task_modifier = modifier_manager.get_modifier("task_bonus")
	if task_modifier and task_modifier is TaskBonusModifier:
		task_modifier.daily_update()

## 周统计更新
func weekly_update(year: int, week: int) -> void:
	stats_manager.record_weekly(year, week)
	
	# 更新每篇文章周统计
	for post_id in post_stats_manager.post_stats:
		post_stats_manager.update_weekly_stats(post_id)

## 月统计更新
func monthly_update(year: int, month: int) -> void:
	stats_manager.record_monthly(year, month)
	
	# 更新每篇文章月统计
	for post_id in post_stats_manager.post_stats:
		post_stats_manager.update_monthly_stats(post_id)

## 年统计更新
func yearly_update(year: int) -> void:
	stats_manager.record_yearly(year)

## ========== 预留接口：任务系统关联 ==========

## 激活任务型文章加成
func activate_task_article(task_type: String, bonus_ratio: float, duration: int) -> void:
	var modifier = modifier_manager.get_modifier("task_bonus")
	if modifier and modifier is TaskBonusModifier:
		modifier.activate_task_bonus(task_type, bonus_ratio, duration)

## 解锁文章类型（由任务系统调用）
func unlock_article_category(category: String) -> void:
	# 预留接口，由任务系统实现
	pass

## ========== 统计查询接口 ==========

## 获取统计摘要
func get_stats_summary() -> Dictionary:
	return stats_manager.get_summary()

## 获取趋势数据
func get_trend(days: int = 30) -> Array:
	return stats_manager.get_trend(days)

## 获取单篇文章统计
func get_post_stats(post_id: String) -> Dictionary:
	return post_stats_manager.get_post_stats(post_id)

## 获取热门文章
func get_top_posts(limit: int = 10) -> Array:
	return post_stats_manager.get_top_posts(limit)

## 获取活跃事件
func get_active_events() -> Array:
	return event_manager.get_active_events()

## 获取活跃任务加成
func get_active_task_bonuses() -> Array:
	var modifier = modifier_manager.get_modifier("task_bonus")
	if modifier and modifier is TaskBonusModifier:
		return modifier.get_active_bonuses()
	return []

## ========== 修饰器控制接口 ==========

## 启用/禁用修饰器
func set_modifier_enabled(name: String, enabled: bool) -> bool:
	return modifier_manager.set_enabled(name, enabled)

## 获取所有修饰器信息
func get_all_modifiers_info() -> Array:
	return modifier_manager.get_all_info()

## ========== 数据持久化接口 ==========

## 获取所有统计数据（用于保存）
func get_all_stats_data() -> Dictionary:
	return {
		"overall_stats": stats_manager.get_all_stats(),
		"post_stats": post_stats_manager.get_all_stats()
	}

## 加载统计数据
func load_all_stats_data(data: Dictionary) -> void:
	if data.has("overall_stats"):
		stats_manager.data = data.overall_stats
	if data.has("post_stats"):
		post_stats_manager.load_all_stats(data.post_stats)
