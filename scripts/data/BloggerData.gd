## 博主数据结构
## 存储玩家的所有属性、资源和博客数据
class_name BloggerData

# ============================================
# 核心属性
# ============================================

## 等级（1-100）
var level: int = 8

## 经验值
var exp: int = 0

## 段位（0-9，每10级提升1段位）
## 段位影响访问量加成
var rank_tier: int = 0

## 属性点数（升级获得，用于分配能力值）
var attribute_points: int = 0

# ============================================
# 能力值（范围0-100）
# ============================================

## 写作能力：影响所有文章的质量分
var writing_ability: float = 0

## 技术能力：影响技术类文章质量和网站维护效果
var technical_ability: float = 0

## 编程能力：影响编程教程、黑客攻防等技术文章质量
var code_ability: float = 0

## 文学能力：影响文学类文章质量（年度总结、生活日记、散文等）
var literature_ability: float = 91

## 绘画能力：影响艺术类文章质量（插画壁纸、绘画教程等）
var drawing_ability: float = 0

# ============================================
# 资源
# ============================================

## 体力（写文章、维护网站消耗体力）
var stamina: int = 51

## 金钱（单位：元）
## 初始10万，用于购买主机、域名、安全服务等
var money: float = 100000.0

## 社交能力：影响文章分享、爆款事件触发概率
var social_ability: int = 5

## 声望
var reputation: int = 0

# ============================================
# 博客基础数据
# ============================================

## 博客名称
var blog_name: String = "我的博客"

## 博主昵称
var blog_author: String = "J.sky"

## 博客类型（0=文学, 1=编程, 2=艺术, 3=综合）
var blog_type: int = 1

# ============================================
# 博客属性值（范围0-200）
# ============================================

## 安全值（0-100）
## 影响网站被攻击的概率，低于50容易出问题
var safety_value: int = 100

## SEO值（0-200）
## 影响基础访问量和搜索引擎收录
## 新网站SEO效果差，初始值设为50
## 通过"SEO优化"任务逐步提升
var seo_value: int = 50

## 设计值（0-200）
## 影响访问量加成和页面美化效果
## 通过"页面美化"任务提升
var design_value: int = 60

## UI值（暂未使用）
var ui_value: int = 0

# ============================================
# 博客访问量统计
# ============================================

## 总访问量
var views: int = 0

## RSS订阅数
## 影响新文章的访问量加成（发布14天内有效）
var rss: int = 0

## 总收藏数
## 影响文章访问量加成
var favorites: int = 0

## 今日访问量
var today_views: int = 0

## 本周访问量
var week_views: int = 0

## 本月访问量
var month_views: int = 0

## 今年访问量
var year_views: int = 0

# ============================================
# 文章列表
# ============================================

## 已发布的文章列表
## 每篇文章包含：id, title, category, task_type, type, type1, quality, views, favorites, date等
var posts: Array[Dictionary] = []

# ============================================
# 日程安排（7天循环）
# ============================================

## 每日任务安排
## 每天可以安排多个任务（写作、维护、休息、学习等）
var calendar: Array[Dictionary] = [
    {"tasks": ["文学入门", ]},      # 周一
    {"tasks": ["文学入门", ]},      # 周二
    {"tasks": ["文学入门", ]},      # 周三
    {"tasks": ["文学入门", ]},      # 周四
    {"tasks": ["安全维护"]},      # 周五
    {"tasks": ["SEO优化"]},       # 周六
    {"tasks": ["打游戏"]},        # 周日
]

# ============================================
# 临时变量（用于统计计算）
# ============================================

## 当前周数
var tmp_week: int = 1

## 当前月份
var tmp_month: int = 1

## 当前年份（游戏起始年份）
var tmp_year: int = 2005

## 最后一篇文章的质量分
var last_post_quality: int = 0

# ============================================
# 小说连载批次
# ============================================

## 当前小说连载批次号（从1开始）
var novel_batch: int = 1

## 当前批次已发布的小说篇数
var novel_batch_count: int = 0

## 当前批次是否已触发过IP授权
var novel_batch_ip_triggered: bool = false

## 当前批次小说主题名
var novel_batch_title: String = ""

# ============================================
# 出版畅销书
# ============================================

## 当前出版的书名
var book_title: String = ""

## 当前书已发布篇数
var book_article_count: int = 0

## 是否正在写书
var is_writing_book: bool = false

# ============================================
# 技能学习
# ============================================

## 已学会的技能列表
var learned_skills: Array[String] = []

# ============================================
# 信号
# ============================================

## 等级变化信号
signal level_changed(new_level: int)

## 经验值变化信号
signal exp_changed(new_exp: int)

## 能力值变化信号
signal ability_changed(ability_type: String, new_value: float)

## 访问量变化信号
signal blog_views_changed(new_views: int)

## 发布文章信号
signal post_added(post_data: Dictionary)

# ============================================
# 辅助方法
# ============================================

## 增加经验值
func add_exp(amount: int):
    exp += amount
    emit_signal("exp_changed", exp)

## 设置等级
func set_level(new_level: int):
    level = new_level
    emit_signal("level_changed", level)

## 设置能力值
## ability_type: "writing", "technical", "code", "literature", "drawing"
func set_ability(ability_type: String, new_value: float):
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

## 添加新文章
func add_post(post_data: Dictionary):
    posts.append(post_data)
    emit_signal("post_added", post_data)

## 设置访问量
func set_views(new_views: int):
    views = new_views
    emit_signal("blog_views_changed", views)
