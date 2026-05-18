class_name GameBalanceConfig
extends Node

## ============================================================
## 体力上限配置
## ============================================================

## 获取玩家体力上限（按等级）
static func get_max_stamina(level: int) -> int:
    if level <= 10:
        return 31 + level  # 1级:32, 10级:41
    elif level <= 30:
        return int(41 + (level - 10) * 1.5)  # 11级:42, 30级:71
    elif level <= 50:
        return int(71 + (level - 30) * 0.7)  # 31级:71, 50级:85
    else:
        return mini(85 + (level - 50) * 0.5, 100)  # 封顶100

## ============================================================
## 体力消耗配置 - 从静态文件加载
## ============================================================

static var _stamina_cache: Dictionary = {}

## 从静态文件加载体力消耗
static func load_stamina_from_data() -> Dictionary:
    var cache: Dictionary = {}
    var data_dirs = [
        "res://data/blog_categories",
        "res://data/maintenance",
        "res://data/skills",
    ]

    for dir_path in data_dirs:
        var dir = DirAccess.open(dir_path)
        if dir:
            dir.list_dir_begin()
            var file_name = dir.get_next()
            while file_name != "":
                if file_name.ends_with(".gd"):
                    var full_path = dir_path + "/" + file_name
                    var data = load_data_file(full_path)
                    if data.size() > 0:
                        var name = data.get("name", "")
                        var stamina = data.get("stamina", 0)
                        if name != "" and stamina > 0:
                            cache[name] = stamina
                file_name = dir.get_next()

    return cache

## 加载单个数据文件
static func load_data_file(path: String) -> Dictionary:
    var node = load(path).new()
    if node and "item" in node:
        var data = node.item
        node.queue_free()
        return data
    node.queue_free()
    return {}

## 获取任务类型的体力消耗（从静态文件读取）
static func get_task_stamina_cost(task_name: String) -> int:
    if _stamina_cache.is_empty():
        _stamina_cache = load_stamina_from_data()

    return _stamina_cache.get(task_name, 20)

## ============================================================
## 访问量配置
## ============================================================

## 获取访问量配置
static func get_views_config() -> Dictionary:
    return {
        "seo_max": 100,
        "seo_min": 20,
        "article_base_values": {
            1: 5,
            2: 12,
            3: 20,
            4: 40,
            5: 80,
        }
    }

## 获取文章等级基础值
static func get_article_base_value(article_level: int) -> int:
    var config = get_views_config()
    var base_values = config.get("article_base_values", {})
    return base_values.get(article_level, 10)

## 获取SEO相关配置
static func get_seo_max() -> int:
    return get_views_config().get("seo_max", 100)

static func get_seo_min() -> int:
    return get_views_config().get("seo_min", 20)