## 单篇文章统计管理器
class_name PostStatsManager
extends RefCounted

## 文章统计数据
## {post_id: {total_views, daily_views, weekly_views, ...}}
var post_stats: Dictionary = {}

## 记录文章每日访问量
func record_post_views(post_id: String, views: int, sources: Dictionary) -> void:
    if not post_stats.has(post_id):
        _init_post_stats(post_id)
    
    var stats = post_stats[post_id]
    stats.total_views += views
    
    # 记录每日访问量
    stats.daily_views.append({
        "date": Utils.format_date(),
        "views": views,
        "sources": sources.duplicate()
    })
    
    # 更新来源统计
    for key in sources:
        if stats.sources.has(key):
            stats.sources[key] += sources[key]

## 初始化文章统计
func _init_post_stats(post_id: String) -> void:
    post_stats[post_id] = {
        "total_views": 0,
        "daily_views": [],
        "weekly_views": [],
        "monthly_views": [],
        "quarterly_views": [],
        "yearly_views": [],
        "sources": {
            "direct": 0,
            "search": 0,
            "social": 0,
            "rss": 0,
            "favorite": 0,
            "event": 0,
            "task": 0
        }
    }

## 获取文章统计
func get_post_stats(post_id: String) -> Dictionary:
    return post_stats.get(post_id, {})

## 获取文章总访问量
func get_post_total_views(post_id: String) -> int:
    var stats = post_stats.get(post_id, {})
    return stats.get("total_views", 0)

## 获取文章每日访问量趋势
func get_post_daily_views(post_id: String, days: int = 30) -> Array:
    var stats = post_stats.get(post_id, {})
    var daily = stats.get("daily_views", [])
    return daily.slice(-days)

## 获取文章来源统计
func get_post_sources(post_id: String) -> Dictionary:
    var stats = post_stats.get(post_id, {})
    return stats.get("sources", {})

## 更新周统计
func update_weekly_stats(post_id: String) -> void:
    if not post_stats.has(post_id):
        return
    
    var stats = post_stats[post_id]
    var daily = stats.get("daily_views", [])
    
    if daily.size() < 7:
        return
    
    # 计算最近7天总访问量
    var week_total = 0
    for i in range(7):
        week_total += daily[-(i + 1)].get("views", 0)
    
    stats.weekly_views.append({
        "week": TimerManager.current_week,
        "year": TimerManager.current_year,
        "total": week_total
    })

## 更新月统计
func update_monthly_stats(post_id: String) -> void:
    if not post_stats.has(post_id):
        return
    
    var stats = post_stats[post_id]
    var daily = stats.get("daily_views", [])
    
    if daily.size() < 28:
        return
    
    # 计算最近28天总访问量
    var month_total = 0
    for i in range(28):
        month_total += daily[-(i + 1)].get("views", 0)
    
    stats.monthly_views.append({
        "month": TimerManager.current_month,
        "year": TimerManager.current_year,
        "total": month_total
    })

## 获取热门文章（按访问量排序）
func get_top_posts(limit: int = 10) -> Array:
    var result = []
    for post_id in post_stats:
        result.append({
            "post_id": post_id,
            "total_views": post_stats[post_id].total_views
        })
    
    # 按访问量排序
    result.sort_custom(func(a, b): return a.total_views > b.total_views)
    
    return result.slice(0, limit)

## 获取统计数据（用于保存）
func get_all_stats() -> Dictionary:
    return post_stats.duplicate()

## 加载统计数据
func load_all_stats(data: Dictionary) -> void:
    post_stats = data.duplicate()
