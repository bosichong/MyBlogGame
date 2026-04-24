## 访问量统计管理器
class_name ViewsStatsManager
extends RefCounted

var data: ViewsStatsData

func _init():
    data = ViewsStatsData.new()

## 记录每日统计
func record_daily(date: String, views: int, posts_count: int, sources: Dictionary) -> void:
    data.daily_stats.append({
        "date": date,
        "views": views,
        "posts_count": posts_count,
        "sources": sources.duplicate()
    })
    
    # 更新来源累计统计
    for key in sources:
        if data.source_stats.has(key):
            data.source_stats[key] += sources[key]

## 记录周统计
func record_weekly(year: int, week: int) -> void:
    var week_data = data.daily_stats.slice(-7)
    
    var total = 0
    for d in week_data:
        total += d.get("views", 0)
    
    var avg = 0
    if week_data.size() > 0:
        avg = total / week_data.size()
    
    data.weekly_stats.append({
        "year": year,
        "week": week,
        "total_views": total,
        "avg_views": avg
    })

## 记录月统计
func record_monthly(year: int, month: int) -> void:
    var month_data = data.daily_stats.slice(-28)
    
    var total = 0
    for d in month_data:
        total += d.get("views", 0)
    
    var avg = 0
    if month_data.size() > 0:
        avg = total / month_data.size()
    
    data.monthly_stats.append({
        "year": year,
        "month": month,
        "total_views": total,
        "avg_views": avg
    })

## 记录年统计
func record_yearly(year: int) -> void:
    var year_data = data.daily_stats.slice(-336)
    
    var total = 0
    for d in year_data:
        total += d.get("views", 0)
    
    var avg = 0
    if year_data.size() > 0:
        avg = total / year_data.size()
    
    data.yearly_stats.append({
        "year": year,
        "total_views": total,
        "avg_views": avg
    })

## 获取趋势数据（最近N天）
func get_trend(days: int = 30) -> Array:
    return data.daily_stats.slice(-days)

## 获取来源占比
func get_source_ratio() -> Dictionary:
    var total = 0
    for key in data.source_stats:
        total += data.source_stats[key]
    
    if total == 0:
        return data.source_stats.duplicate()
    
    var ratio = {}
    for key in data.source_stats:
        ratio[key] = float(data.source_stats[key]) / float(total)
    return ratio

## 获取增长率（最近N天 vs 再前N天）
func get_growth_rate(days: int = 7) -> float:
    if data.daily_stats.size() < days * 2:
        return 0.0
    
    var recent = 0
    var previous = 0
    
    for i in range(days):
        recent += data.daily_stats[-(i + 1)].get("views", 0)
        previous += data.daily_stats[-(i + 1 + days)].get("views", 0)
    
    if previous == 0:
        return 0.0
    
    return float(recent - previous) / float(previous)

## 获取统计摘要
func get_summary() -> Dictionary:
    return {
        "total_views": data.get_total_views(),
        "today_views": data.get_today_views(),
        "recent_7_days": data.get_recent_views(7),
        "recent_30_days": data.get_recent_views(30),
        "source_ratio": get_source_ratio(),
        "growth_rate": get_growth_rate(7),
        "daily_count": data.daily_stats.size(),
        "weekly_count": data.weekly_stats.size(),
        "monthly_count": data.monthly_stats.size()
    }

## 清空统计数据
func clear() -> void:
    data.clear()

## 获取所有统计数据（用于保存）
func get_all_stats() -> Dictionary:
    return {
        "daily_stats": data.daily_stats.duplicate(),
        "weekly_stats": data.weekly_stats.duplicate(),
        "monthly_stats": data.monthly_stats.duplicate(),
        "yearly_stats": data.yearly_stats.duplicate(),
        "source_stats": data.source_stats.duplicate()
    }

## 加载统计数据
func load_all_stats(stats_data: Dictionary) -> void:
    data.daily_stats = stats_data.get("daily_stats", [])
    data.weekly_stats = stats_data.get("weekly_stats", [])
    data.monthly_stats = stats_data.get("monthly_stats", [])
    data.yearly_stats = stats_data.get("yearly_stats", [])
    data.source_stats = stats_data.get("source_stats", {
        "direct": 0,
        "search": 0,
        "social": 0,
        "rss": 0,
        "favorite": 0,
        "event": 0,
        "task": 0
    })
