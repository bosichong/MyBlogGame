## 爆款文章事件
class_name ViralEvent
extends ViewsEvent

func _init():
    event_id = "viral"
    event_name = "爆款文章"
    description = "文章在社交媒体疯传，访问量大幅提升"
    duration = 3
    bonus_ratio = 2.0  # 200%加成

func check_trigger(blogger: Dictionary) -> bool:
    # 文章质量>150 且 社交能力>50 时有5%概率触发
    var quality = blogger.get("last_post_quality", 0)
    var social = blogger.get("social_ability", 0)
    
    if quality > 150 and social > 50:
        return randf() < 0.05
    
    return false