## 连载加成修饰器
## 用于文学周刊等连续性文章
## 加成公式：每10篇 +2%，100篇到顶（20%）
class_name SerialBonusModifier
extends ViewsModifier

## 连载文章类型列表（文学周刊、程序员周刊，【艺术周刊已禁用】）
## 小说连载、动漫连载是付费文章不计入总访问量
var serial_types: Array = ["文学周刊", "程序员周刊"]

## 缓存各类型连载篇数，每日更新一次
var _cached_counts: Dictionary = {}

func _init():
    modifier_name = "serial_bonus"
    display_name = "连载加成"
    description = "周刊文章根据发布篇数获得递增加成"
    priority = 260
    type = Type.BOOST

## 每天开始前刷新缓存
func refresh_cache(blogger: Dictionary) -> void:
    _cached_counts.clear()
    for post in blogger.get("posts", []) + blogger.get("archived_posts", []):
        var cat = post.get("category", "")
        if cat in serial_types:
            _cached_counts[cat] = _cached_counts.get(cat, 0) + 1

func apply(views: int, post: Dictionary, blogger: Dictionary) -> int:
    var category = post.get("category", "")
    
    if not category in serial_types:
        return views
    
    var serial_count = _cached_counts.get(category, 0)
    
    var bonus_percent = int(serial_count / 10) * 2
    bonus_percent = min(bonus_percent, 20)
    var bonus_ratio = 1.0 + float(bonus_percent) / 100.0
    
    var bonus = int(views * (bonus_ratio - 1.0))
    
    return views + bonus

## 获取指定类型连载文章的发布篇数（优先读取缓存，未缓存时回退扫描）
func _get_serial_count(category: String, blogger: Dictionary) -> int:
    if _cached_counts.is_empty():
        refresh_cache(blogger)
    return _cached_counts.get(category, 0)

## 获取连载加成信息（用于UI显示）
func get_serial_bonus_info(category: String, blogger: Dictionary) -> Dictionary:
    var count = _get_serial_count(category, blogger)
    var bonus_percent = int(count / 10) * 2
    bonus_percent = min(bonus_percent, 20)
    var bonus_ratio = 1.0 + float(bonus_percent) / 100.0
    
    return {
        "category": category,
        "published_count": count,
        "bonus_ratio": bonus_ratio,
        "bonus_percent": bonus_percent
    }