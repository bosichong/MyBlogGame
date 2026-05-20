## SEO基础访问量修饰器
## 根据SEO值和文章等级计算基础访问量
class_name SEOBaseModifier
extends ViewsModifier

func _init():
    modifier_name = "seo_base"
    display_name = "SEO基础访问量"
    description = "根据SEO值和文章等级计算基础访问量"
    priority = 0
    type = Type.BASE

func apply(views: int, post: Dictionary, blogger: Dictionary) -> int:
    var seo = blogger.get("seo_value", 50)

    var article_level = post.get("article_level", 2)

    var config = GameBalanceConfig.get_views_config()
    var seo_max = config.get("seo_max", 100)
    var base_values = config.get("article_base_values", {})
    var base_value = base_values.get(article_level, 10)

    var seo_factor = float(seo) / float(seo_max)
    var min_base = base_value / 3
    var actual_base = randi_range(min_base, base_value)
    var result = int(seo_factor * actual_base)

    var min_views = base_value / 10
    var final_views = max(result, max(min_views, 1))
    
    return final_views


## 获取访问量计算说明（调试用）
static func get_calculation_description(post: Dictionary, blogger: Dictionary) -> String:
    var seo = blogger.get("seo_value", 50)
    var article_level = post.get("article_level", 1)
    var config = GameBalanceConfig.get_views_config()
    var seo_max = config.get("seo_max", 100)
    var seo_base = config.get("seo_base", 50)
    var base_values = config.get("article_base_values", {})
    var base_value = base_values.get(article_level, 10)

    var seo_factor = float(seo) / float(seo_max)
    var result = int(seo_factor * (seo_base + base_value))

    return "SEO=%d/%d × (基数%d + 基础值%d) = %d" % [seo, seo_max, seo_base, base_value, result]