## 访问量统计数据结构
class_name ViewsStatsData
extends RefCounted

## 日统计
## [{date, views, posts_count, sources}]
var daily_stats: Array = []

## 周统计
## [{year, week, total_views, avg_views}]
var weekly_stats: Array = []

## 月统计
## [{year, month, total_views, avg_views}]
var monthly_stats: Array = []

## 年统计
## [{year, total_views, avg_views}]
var yearly_stats: Array = []

## 来源累计统计
var source_stats: Dictionary = {
    "direct": 0,      # 直接访问
    "search": 0,      # 搜索引擎
    "social": 0,      # 社交媒体
    "rss": 0,         # RSS订阅
    "favorite": 0,    # 收藏
    "event": 0,       # 事件加成
    "task": 0         # 任务加成
}

## 单篇文章统计
## {post_id: {views, sources, first_date, last_date}}
var post_stats: Dictionary = {}

## 清空所有统计
func clear() -> void:
    daily_stats.clear()
    weekly_stats.clear()
    monthly_stats.clear()
    yearly_stats.clear()
    source_stats = {
        "direct": 0,
        "search": 0,
        "social": 0,
        "rss": 0,
        "favorite": 0,
        "event": 0,
        "task": 0
    }
    post_stats.clear()

## 获取总访问量
func get_total_views() -> int:
    var total = 0
    for d in daily_stats:
        total += d.get("views", 0)
    return total

## 获取今日访问量
func get_today_views() -> int:
    if daily_stats.size() > 0:
        return daily_stats[-1].get("views", 0)
    return 0

## 获取最近N天访问量
func get_recent_views(days: int) -> int:
    var total = 0
    var start = max(0, daily_stats.size() - days)
    for i in range(start, daily_stats.size()):
        total += daily_stats[i].get("views", 0)
    return total
