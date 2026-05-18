## 被动友链申请事件
## 每月第1周第3天触发，从低等级联盟成员中随机生成1-3个被动申请
class_name FriendLinkPassiveEvent
extends ViewsEvent

## 每月触发一次，不需要持续效果
func _init():
    event_id = "friendlink_passive"
    event_name = "友链申请"
    description = "低等级联盟成员向您发起友链申请"
    duration = 0  # 仅触发，不持续

func check_trigger(blogger: Dictionary) -> bool:
    # 每月第1周第3天触发
    if GDManager:
        var time_data = GDManager.get_time()
        if time_data.current_week == 1 and time_data.current_day == 3:
            return true
    return false

func trigger() -> void:
    if not GDManager:
        return
    
    var fl_manager = GDManager.friend_link_manager
    if not fl_manager:
        return
    
    # 添加被动申请
    var new_requests = fl_manager.add_passive_requests()
    
    if new_requests.size() > 0:
        print("[友链事件] 收到%d个被动申请" % new_requests.size())
