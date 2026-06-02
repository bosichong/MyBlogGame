## 年度总结数据结构
## 存储每年初的快照数据，用于生成年度总结弹窗
class_name YearlySummaryData

# ============================================
# 年度快照数据
# ============================================

## 每年初的快照数据
## {year: {level, exp, money, views, rss, favorites, stamina, ...}}
## 用于计算"今年数据变化（vs 年初）"
var yearly_snapshots: Dictionary = {}

# ============================================
# 辅助方法
# ============================================

## 记录年度初的快照
func record_yearly_snapshot(year: int, blogger: BloggerData) -> void:
    yearly_snapshots[year] = {
        "level": blogger.level,
        "exp": blogger.exp,
        "money": blogger.money,
        "views": blogger.views,
        "rss": blogger.rss,
        "favorites": blogger.favorites,
        "stamina": blogger.stamina,
        "reputation": blogger.reputation
    }

## 获取年度变化数据
func get_yearly_change(year: int, current_blogger: BloggerData) -> Dictionary:
    var snapshot = yearly_snapshots.get(year, {})
    if snapshot.is_empty():
        return _empty_change()

    return {
        "year": year,
        "level_before": snapshot.get("level", 0),
        "level_after": current_blogger.level,
        "level_change": current_blogger.level - snapshot.get("level", 0),
        "money_before": snapshot.get("money", 0.0),
        "money_after": current_blogger.money,
        "money_change": current_blogger.money - snapshot.get("money", 0.0),
        "views_before": snapshot.get("views", 0),
        "views_after": current_blogger.views,
        "views_change": current_blogger.views - snapshot.get("views", 0),
        "rss_before": snapshot.get("rss", 0),
        "rss_after": current_blogger.rss,
        "rss_change": current_blogger.rss - snapshot.get("rss", 0),
        "favorites_before": snapshot.get("favorites", 0),
        "favorites_after": current_blogger.favorites,
        "favorites_change": current_blogger.favorites - snapshot.get("favorites", 0)
    }

## 获取年度发布的文章统计
func count_posts_by_year(year: int, posts: Array) -> Dictionary:
    var total = 0
    var paid = 0
    var free = 0
    var categories: Dictionary = {}

    for post in posts:
        var post_date = post.get("date", "")
        if post_date.begins_with(str(year)):
            total += 1
            var is_paid = post.get("is_money", false)
            if is_paid:
                paid += 1
            else:
                free += 1
            var cat = post.get("article_category", "其他")
            categories[cat] = categories.get(cat, 0) + 1

    return {
        "total": total,
        "paid": paid,
        "free": free,
        "categories": categories
    }

## 检查是否有指定年份的快照
func has_snapshot(year: int) -> bool:
    return yearly_snapshots.has(year)

## 清空所有数据
func clear() -> void:
    yearly_snapshots.clear()

## 内部方法：返回空变化数据
func _empty_change() -> Dictionary:
    return {
        "year": 0,
        "level_before": 0,
        "level_after": 0,
        "level_change": 0,
        "money_before": 0.0,
        "money_after": 0.0,
        "money_change": 0.0,
        "views_before": 0,
        "views_after": 0,
        "views_change": 0,
        "rss_before": 0,
        "rss_after": 0,
        "rss_change": 0,
        "favorites_before": 0,
        "favorites_after": 0,
        "favorites_change": 0
    }
