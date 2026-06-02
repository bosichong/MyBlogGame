## 年度总结格式化工具
## 用于生成年度总结弹窗的占位符替换内容
class_name YearlySummaryFormatter
extends RefCounted

## 生成占位符替换字典
## 返回的字典可以用于替换模板中的 {key} 占位符
static func build_template_data(year: int) -> Dictionary:
    if not GDManager:
        return {}
    var yearly = GDManager.get_yearly_summary()
    var blogger = GDManager.get_blogger()
    if not yearly or not blogger:
        return {}
    
    var change = yearly.get_yearly_change(year, blogger)
    var posts_stats = yearly.count_posts_by_year(year, blogger.posts)
    
    # 生成分类文本
    var category_text = _format_categories(posts_stats.get("categories", {}))
    
    return {
        "year": str(year),
        "level_before": str(change.get("level_before", 0)),
        "level_after": str(change.get("level_after", 0)),
        "level_change": _format_change(change.get("level_change", 0), "", "级"),
        "money_before": _format_money(change.get("money_before", 0.0)),
        "money_after": _format_money(change.get("money_after", 0.0)),
        "money_change": _format_change(change.get("money_change", 0.0), "", "元", true),
        "views_before": str(change.get("views_before", 0)),
        "views_after": str(change.get("views_after", 0)),
        "views_change": _format_change(change.get("views_change", 0), "+", ""),
        "rss_before": str(change.get("rss_before", 0)),
        "rss_after": str(change.get("rss_after", 0)),
        "rss_change": _format_change(change.get("rss_change", 0), "+", ""),
        "favorites_before": str(change.get("favorites_before", 0)),
        "favorites_after": str(change.get("favorites_after", 0)),
        "favorites_change": _format_change(change.get("favorites_change", 0), "+", ""),
        "posts_total": str(posts_stats.get("total", 0)),
        "posts_paid": str(posts_stats.get("paid", 0)),
        "posts_free": str(posts_stats.get("free", 0)),
        "posts_categories": category_text
    }

## 替换模板中的 {key} 占位符
static func render(template: String, data: Dictionary) -> String:
    var result = template
    for key in data:
        var placeholder = "{" + key + "}"
        result = result.replace(placeholder, str(data[key]))
    return result

## 格式化变化值（带正负号）
static func _format_change(value, prefix: String = "+", suffix: String = "", is_money: bool = false) -> String:
    if is_money:
        return _format_money(value)
    var sign = "+" if value > 0 else ("" if value == 0 else "")
    return "%s%d%s" % [sign, value, suffix]

## 格式化分类文本
static func _format_categories(categories: Dictionary) -> String:
    if categories.is_empty():
        return "（暂无）"
    var parts = []
    for cat in categories:
        parts.append("  - %s：%d 篇" % [cat, categories[cat]])
    return "\n".join(parts)

## 格式化金额
static func _format_money(amount: float) -> String:
    if amount >= 10000:
        return "%.1f万" % (amount / 10000.0)
    return "%.0f元" % amount
