## 时间衰减修饰器
## 文章访问量随时间衰减
class_name TimeDecayModifier
extends ViewsModifier

## 配置参数
var new_article_days: int = 7          # 新文章期（天）
var mid_period_1_days: int = 14         # 第二阶段（天）
var mid_period_2_days: int = 28         # 第三阶段（天）
var active_article_years: float = 0.25  # 有效文章年限（3个月，28天×3=84天）
var mid_period_1_chance: float = 0.5   # 7-14天访问概率
var mid_period_2_chance: float = 0.25  # 14-28天访问概率
var old_period_chance: float = 0.05     # 28-半年访问概率
var min_random_views: int = 1            # 随机访问最小值
var max_random_views: int = 5            # 随机访问最大值

func _init():
    modifier_name = "time_decay"
    display_name = "时间衰减"
    description = "新文章7天正常，之后随时间递减，3个月后无访问"
    priority = 100
    type = Type.DECAY

func apply(views: int, post: Dictionary, blogger: Dictionary) -> int:
    var post_date = post.get("date", "")
    if post_date == "":
        return views
    
    var now_date = Utils.format_date()
    var days = Utils.calculate_new_game_time_difference(post_date, now_date)
    var max_active_days = active_article_years * 336
    
    # 1. 新文章期（0-7天）：正常访问量
    if days <= new_article_days:
        return views
    
    # 2. 超过半年：不再增加访问量
    if days > max_active_days:
        return 0
    
    # 3. 根据时间段计算访问概率和衰减
    var visit_chance: float
    var decay_factor: float
    
    if days <= mid_period_1_days:
        # 7-14天：50%概率
        visit_chance = mid_period_1_chance
        decay_factor = 1.0 - (float(days - new_article_days) / float(mid_period_1_days - new_article_days)) * 0.5
    elif days <= mid_period_2_days:
        # 14-28天：25%概率
        visit_chance = mid_period_2_chance
        decay_factor = 0.5 - (float(days - mid_period_1_days) / float(mid_period_2_days - mid_period_1_days)) * 0.45
    else:
        # 28-半年：5%概率
        visit_chance = old_period_chance
        decay_factor = 0.05
    
    if randf() > visit_chance:
        return 0
    
    var random_views = randi_range(min_random_views, max_random_views)
    return int(float(random_views) * decay_factor)

func get_article_status(days: int) -> String:
    var max_days = active_article_years * 336
    
    if days <= new_article_days:
        return "新文章期（正常访问）"
    elif days <= mid_period_1_days:
        return "成长期（50%概率）"
    elif days <= mid_period_2_days:
        return "稳定期（25%概率）"
    elif days <= max_days:
        return "衰退期（5%概率）"
    else:
        return "归档期（无访问）"