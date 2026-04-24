## 开源维护笔记访问量修饰器
## 访问量基于玩家的综合技能评分计算
## 与出书笔记加成方式一致
class_name OpenSourceModifier
extends ViewsModifier

func _init():
    modifier_name = "open_source_notes"
    display_name = "开源维护笔记加成"
    description = "开源维护笔记访问量基于综合技能评分"
    priority = 241
    type = Type.BOOST

func apply(views: int, post: Dictionary, blogger: Dictionary) -> int:
    var category = post.get("category", "")
    
    # 只对开源维护笔记生效
    if category != "开源维护笔记":
        return views
    
    # 计算综合技能评分
    var avg_score = _calculate_avg_skill_score(blogger)
    
    # 综合评分加成：0-100分对应0%-200%加成
    # 公式：加成 = 评分 / 50 （即50分时加成100%，100分时加成200%）
    var bonus_ratio = avg_score / 50.0
    
    # 应用加成
    var bonus = int(views * bonus_ratio)
    
    return views + bonus

## 计算综合技能评分
func _calculate_avg_skill_score(blogger: Dictionary) -> float:
    var literature = blogger.get("literature_level", 0.0)
    var code = blogger.get("code_level", 0.0)
    var draw = blogger.get("draw_level", 0.0)
    
    # 如果博客数据没有直接的技能值，尝试从Blogger获取
    if Blogger and Blogger.has_method("get_ability_by_type"):
        literature = Blogger.get_ability_by_type("literature")
        code = Blogger.get_ability_by_type("code")
        draw = Blogger.get_ability_by_type("draw")
    
    # 综合评分 = 三项技能平均值
    return (literature + code + draw) / 3.0