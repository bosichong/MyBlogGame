class_name BloggerData extends Resource

# ===== 核心属性 =====
var level: int = 1
var exp: int = 0
var rank_tier: int = 0  # 段位（0-9）
var attribute_points: int = 0

# ===== 能力值 =====
var writing_ability: int = 23
var technical_ability: int = 23
var code_ability: int = 23
var literature_ability: int = 23
var drawing_ability: int = 23

# ===== 资源 =====
var stamina: int = 100
var money: float = 100000.0
var social_ability: int = 5

# ===== 博客数据 =====
var blog_name: String = "我的博客"
var blog_author: String = "J.sky"
var blog_type: int = 1

var safety_value: int = 100
var seo_value: int = 100
var design_value: int = 100
var ui_value: int = 0

var views: int = 0
var rss: int = 0
var favorites: int = 0

var today_views: int = 0
var week_views: int = 0
var month_views: int = 0
var year_views: int = 0

var posts: Array[Dictionary] = []

# ===== 日程安排（7天）=====
var calendar: Array[Dictionary] = [
    {"tasks": ["阅读名著"]},
    {"tasks": ["阅读名著"]},
    {"tasks": ["阅读名著"]},
    {"tasks": ["阅读名著"]},
    {"tasks": ["安全维护"]},
    {"tasks": ["SEO优化"]},
    {"tasks": ["打游戏"]},
]

# ===== 临时变量 =====
var tmp_week: int = 1
var tmp_month: int = 1
var tmp_year: int = 2000
var last_post_quality: int = 0

# ===== 信号 =====
signal level_changed(new_level: int)
signal exp_changed(new_exp: int)
signal ability_changed(ability_type: String, new_value: int)
signal blog_views_changed(new_views: int)
signal post_added(post_data: Dictionary)

# ===== 辅助方法 =====

func add_exp(amount: int):
    exp += amount
    emit_signal("exp_changed", exp)

func set_level(new_level: int):
    level = new_level
    emit_signal("level_changed", level)

func set_ability(ability_type: String, new_value: int):
    match ability_type:
        "writing":
            writing_ability = new_value
        "technical":
            technical_ability = new_value
        "code":
            code_ability = new_value
        "literature":
            literature_ability = new_value
        "drawing":
            drawing_ability = new_value
    emit_signal("ability_changed", ability_type, new_value)

func add_post(post_data: Dictionary):
    posts.append(post_data)
    emit_signal("post_added", post_data)

func set_views(new_views: int):
    views = new_views
    emit_signal("blog_views_changed", views)