## 动画影视创作访问量修饰器【已禁用】
## 由于艺术类文章已隐藏，此修饰器不再生效
class_name AnimationMovieModifier
extends ViewsModifier

func _init():
    modifier_name = "animation_movie"
    display_name = "动画影视加成【已禁用】"
    description = "艺术类文章已隐藏，此修饰器不再生效"
    priority = 240
    type = Type.BOOST

func apply(views: int, post: Dictionary, blogger: Dictionary) -> int:
    # 艺术类已禁用，直接返回原始访问量
    return views
