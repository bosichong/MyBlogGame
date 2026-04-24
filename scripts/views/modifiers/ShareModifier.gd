## 分享加成修饰器
class_name ShareModifier
extends ViewsModifier

func _init():
    modifier_name = "share"
    display_name = "分享加成"
    description = "文章被分享带来的额外访问量"
    priority = 240
    type = Type.BOOST

func apply(views: int, post: Dictionary, blogger: Dictionary) -> int:
    # 分享加成与当前访问量正相关
    # 基础5% + 最高20%（当访问量超过10000时）
    var share_ratio = 0.05 + min(float(views) / 50000.0, 0.2)
    var bonus = int(views * share_ratio)
    return views + bonus