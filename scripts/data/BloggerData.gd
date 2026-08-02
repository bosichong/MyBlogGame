## 博主数据结构
## 存储玩家的所有属性、资源和博客数据
class_name BloggerData

# ============================================
# 核心属性
# ============================================

## 等级（1-100）
var level: int = 28

## 经验值
var exp: int = 0

## 段位（0-9，每10级提升1段位）
## 段位影响访问量加成
var rank_tier: int = 2

## 属性点数（升级获得，用于分配能力值）
var attribute_points: int = 0

# ============================================
# 能力值（范围0-100）
# ============================================

## 写作能力：影响所有文章的质量分
var writing_ability: float = 17

## 技术能力：影响技术类文章质量和网站维护效果
var technical_ability: float = 17

## 编程能力：影响编程教程、黑客攻防等技术文章质量
var code_ability: float = 17

## 文学能力：影响文学类文章质量（年度总结、生活日记、散文等）
var literature_ability: float = 77

# ============================================
# 资源
# ============================================

## 体力（写文章、维护网站消耗体力）
var stamina: int = 51

## 金钱（单位：元）
## 初始10万，用于购买主机、域名、安全服务等
var money: float = 10000000.0

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

## 博客网址
var blog_url: String = "suiyan.cc"

## ICP备案号
var icp_filing_number: String = ""

## ICP备案是否进行中
var icp_filing_in_progress: bool = false

## ICP备案开始日期
var icp_filing_start_date: String = ""

## 移动端适配是否进行中
var mobile_adapt_in_progress: bool = false

## 移动端适配开始日期
var mobile_adapt_start_date: String = ""

## HTTPS升级是否进行中
var https_upgrade_in_progress: bool = false

## HTTPS升级开始日期
var https_upgrade_start_date: String = ""

## CDN加速是否进行中
var cdn_accelerate_in_progress: bool = false

## CDN加速开始日期
var cdn_accelerate_start_date: String = ""

# ============================================
# 博客属性值（范围0-200）
# ============================================

## 安全值（0-100）
## 影响网站被攻击的概率，低于50容易出问题
var safety_value: int = 70

## SEO值（0-100）
## 影响基础访问量和搜索引擎收录
## 新网站SEO效果差，初始值设为50
## 通过"SEO优化"任务逐步提升
var seo_value: int = 10

## 设计值（0-100）
## 影响访问量加成和页面美化效果
## 通过"页面美化"任务提升
var design_value: int = 50

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

## 已发布的活跃文章列表
## 每篇文章包含：id, title, category, task_type, type, type1, quality, views, favorites, date等
var posts: Array[Dictionary] = []

## 已归档的老文章列表（超过84天）
## 数据结构与 posts 一致，月末由 _archive_old_posts() 移入
var archived_posts: Array[Dictionary] = []

# ============================================
# 日程安排（7天循环）
# ============================================

## 每日任务安排
## 每天可以安排多个任务（写作，维护、休息，学习等）
var calendar: Array[Dictionary] = [
    {"tasks": []},      # 周一
    {"tasks": []}, 
    {"tasks": []}, 
    {"tasks": []}, 
    {"tasks": []}, 
    {"tasks": []}, 
    {"tasks": []}, 
]

# ============================================
# 日程冷确（高强度日程的间隔控制）
# key: 类别名称, value: 冷确开始日期（format_date 格式 "year-month-week-day"）
# ============================================

## 日程冷确字典
var cooldowns: Dictionary = {}

# ============================================
# 临时变量（用于统计计算）
# ============================================

## 当前周数
var tmp_week: int = 1

## 当前月份
var tmp_month: int = 1

## 当前年份（游戏起始年份）
var tmp_year: int = TimeData.GAME_START_YEAR

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

## 当前批次IP授权触发目标篇数（批次开始时随机50-80）
var novel_batch_ip_target: int = 0

## 当前批次小说主题名
var novel_batch_title: String = ""

# ============================================
# 黑客攻防课程授权
# ============================================

## 课程授权是否已触发过
var hacker_course_triggered: bool = false

## 黑客攻防当前批次号
var hacker_batch: int = 1

## 黑客攻防当前批次已发布篇数
var hacker_batch_count: int = 0

## 黑客攻防当前批次课程授权触发目标篇数（50-80随机）
var hacker_batch_auth_target: int = 0

## 黑客攻防当前批次主题名
var hacker_batch_topic: String = ""

# ============================================
# 出版畅销书
# ============================================

## 当前出版的书名
var book_title: String = ""

## 当前书已发布篇数
var book_article_count: int = 0

## 是否正在写书
var is_writing_book: bool = false

## 已出版畅销书累计数量（用于第五章结局判定）
var book_publish_count: int = 0

# ============================================
# 开源项目
# ============================================

## 当前开源项目名
var os_project_name: String = ""

## 当前项目已发布篇数
var os_article_count: int = 0

## 是否正在开发开源项目
var is_developing_os: bool = false

## 已发布开源项目累计数量（用于第五章结局判定）
var open_source_count: int = 0

# ============================================
# 贾维斯计划
# ============================================

## 贾维斯计划当前进度天数（0-50，每轮重置）
var jarvis_project_days: int = 0

# ============================================
# 虫洞算法研究
# ============================================

## 虫洞算法研究当前进度天数（0-50，每轮重置）
var wormhole_research_days: int = 0

# ============================================
# 文学结局
# ============================================

## 沉思录当前进度天数（0-50，每轮重置）
var contemplation_days: int = 0

## 无为篇当前进度天数（0-50，每轮重置）
var wuwei_days: int = 0

# ============================================
# 游戏结局
# ============================================

## 游戏开发当前进度天数（0-50，每轮重置）
var game_dev_days: int = 0

## 游戏发布当前进度天数（0-30，每轮重置）
var game_release_days: int = 0

# ============================================
# 公众号
# ============================================

## 公众号运营数据
var wechat_data: Dictionary = {
    "is_active": false,
    "total_articles": 0,
    "followers": 0,
    "total_views": 0,
    "weekly_views": 0,
    "monthly_income": 0.0,
    "monthly_tax": 0.0,
    "total_income": 0.0,
    "total_tax": 0.0,
    "synced_category_counts": {},
}

# ============================================
# 技能学习
# ============================================

## 已学会的技能列表
var learned_skills: Array[String] = []

# ============================================
# Obaby 无视后续计数器（选择无视后计数天数）
# ============================================

## 选择无视后经过的天数（0 表示未触发）
var obaby_ignore_days: int = 0

## Obaby 评论区暗链清理进度（连续安排紧急排险的天数，0 表示未开始）
var obaby_comment_cleanup_days: int = 0

## Obaby 评论区暗链未处理天数（满 10 天引发安全事件）
var obaby_comment_spam_days: int = 0

## Obaby 暗链升级：SEO 是否被锁定为 0
var obaby_spam_seo_locked: bool = false

## Obaby 暗链升级：SEO 恢复天数（7 天紧急排险/SEO优化）
var obaby_spam_seo_recovery_days: int = 0

## Obaby 暗链是否已升级过（防止恢复后再次触发）
var obaby_comment_spam_escalated: bool = false

## Obaby 第三方统计代码广告：选无视后的累计天数
var obaby_redirect_ad_ignore_days: int = 0

## Obaby DDoS：是否已购买安全防护
var obaby_ddos_protection_bought: bool = false
## Obaby DDoS：防护已生效天数
var obaby_ddos_protection_days: int = 0
## Obaby DDoS：自处理累计天数
var obaby_ddos_self_days: int = 0

## Obaby 供应链木马：是否已发文
var supply_chain_post_written: bool = false

# ============================================
# 莫比乌斯延迟计数器（天数，-1 表示未激活）
# ============================================

var mo_lv1_delay_days: int = -1
var mo_lv2_delay_days: int = -1
var mo_lv3_delay_days: int = -1
var mo_lv4_delay_days: int = -1
var mo_lv5_delay_days: int = -1

# ============================================
# 莫比乌斯支线状态
# ============================================

## Lv1 初遇已完成
var mo_lv1_done: bool = true

## Lv1 选了选项1，玩家注意到莫比乌斯话里的矛盾
var mo_noticed_gap: bool = true

## Lv2 回访已完成
var mo_lv2_done: bool = true

## Lv3 深谈已完成
var mo_lv3_done: bool = true

## Lv4 认可已完成
var mo_lv4_done: bool = true  # TODO(测试): 原值false，测试临时改为true

## Lv5 告别已完成
var mo_lv5_done: bool = true  # TODO(测试): 原值false，测试临时改为true

## Lv5 选了隐藏选项3，触发莫比乌斯承认自己写不出
var mo_confession_triggered: bool = false

## 出版后互文收束完成，莫比乌斯重新执笔
var mo_resolved: bool = false

# ============================================
# 安全事件系统
# ============================================

## 当前激活的安全事件（无事件时为 {}）
## { "id": String, "progress": int, "choice": int, "escalate_days": int, "total_days": int }
var active_event: Dictionary = {}

## 事件冷却天数（触发后递减，0 表示可触发新事件）
var event_cooldown: int = 0

## 已解决的事件记录（用于 60 天不重复）
var resolved_events: Array[String] = []

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
## ability_type: "writing", "technical", "code", "literature"
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
    emit_signal("ability_changed", ability_type, new_value)

## 添加新文章
func add_post(post_data: Dictionary):
    posts.append(post_data)
    emit_signal("post_added", post_data)

## 设置访问量
func set_views(new_views: int):
    views = new_views
    emit_signal("blog_views_changed", views)
