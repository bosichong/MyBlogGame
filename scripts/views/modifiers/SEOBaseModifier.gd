## SEO基础访问量修饰器
## 新网站SEO效果差，半年后逐步提升
class_name SEOBaseModifier
extends ViewsModifier

func _init():
    modifier_name = "seo_base"
    display_name = "SEO基础访问量"
    description = "根据SEO值和网站年龄计算基础访问量（占50%）"
    priority = 0
    type = Type.BASE

func apply(views: int, post: Dictionary, blogger: Dictionary) -> int:
    var seo = blogger.get("seo_value", 50)
    var game_start_year = blogger.get("tmp_year", 2005)
    
    # 获取当前游戏时间（通过TimerManager）
    var current_year = TimerManager.current_year if TimerManager else 2005
    var current_month = TimerManager.current_month if TimerManager else 1
    var current_week = TimerManager.current_week if TimerManager else 1
    
    # 计算网站年龄（月数）
    var months = (current_year - game_start_year) * 12 + (current_month - 1)
    
    # 网站年龄系数（新网站SEO效果差）
    # 前3个月：30%，3-6个月：50%，6-12个月：70%，1年后：100%
    var age_factor = 1.0
    if months < 3:
        age_factor = 0.3
    elif months < 6:
        age_factor = 0.5
    elif months < 12:
        age_factor = 0.7
    else:
        age_factor = 1.0
    
    # 基础访问量（占50%，预留任务加成空间）
    var base = randi_range(20, 50)
    
    # SEO系数：SEO值 × 年龄系数
    # 新手期 SEO=50, 年龄<3月: 50/100 × 0.3 = 0.15
    # 半年后 SEO=70, 年龄=6月: 70/100 × 0.5 = 0.35
    # 1年后 SEO=100, 年龄=12月: 100/100 × 0.7 = 0.7
    # 满级期 SEO=200, 年龄>12月: 200/100 × 1.0 = 2.0
    
    var seo_factor = (float(seo) / 100.0) * age_factor
    
    # 立方增长，让后期爆发
    seo_factor = pow(seo_factor, 2.5)
    
    # 计算结果
    var result = int(float(base) * seo_factor * 10.0)
    
    return max(result, 2)  # 最低2

## 获取网站年龄系数说明
func get_age_factor_description(months: int) -> String:
    if months < 3:
        return "新站期(30%效果)"
    elif months < 6:
        return "成长期(50%效果)"
    elif months < 12:
        return "稳定期(70%效果)"
    else:
        return "成熟期(100%效果)"
