## 设计值加成修饰器
class_name DesignModifier
extends ViewsModifier

func _init():
    modifier_name = "design"
    display_name = "页面设计加成"
    description = "根据页面设计值增加访问量"
    priority = 200
    type = Type.BOOST

func apply(views: int, post: Dictionary, blogger: Dictionary) -> int:
    var design = blogger.get("design_value", 0)
    
    # 降低加成比例：设计值100时加成30%
    var bonus = int(views * (design * 0.003))
    return views + bonus