## 热门风向标加成修饰器
class_name TrendModifier
extends ViewsModifier

## 当前热门类型（可动态设置）
var current_trend_type: String = "文学"
## 加成比例
var trend_bonus_ratio: float = 0.2

func _init():
    modifier_name = "trend"
    display_name = "热门风向标"
    description = "文章类型匹配热门风向标时获得加成"
    priority = 250
    type = Type.BOOST

func apply(views: int, post: Dictionary, blogger: Dictionary) -> int:
    var post_type = post.get("type", "")
    
    # 文章类型必须匹配热门风向标
    if post_type != current_trend_type:
        return views
    
    var quality = post.get("quality", 100)
    # 质量关联：高质量文章获得更多加成
    var quality_factor = float(quality) / 200.0
    var bonus = int(views * trend_bonus_ratio * quality_factor)
    
    return views + bonus

## 设置热门风向标
func set_trend(trend_type: String, bonus_ratio: float = 0.2) -> void:
    current_trend_type = trend_type
    trend_bonus_ratio = bonus_ratio