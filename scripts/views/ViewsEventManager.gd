## 访问量事件管理器
## 负责注册、触发、应用所有事件
class_name ViewsEventManager
extends RefCounted

var events: Array = []
var active_events: Array = []

## 注册事件
func register(event: ViewsEvent) -> void:
    events.append(event)

## 注销事件
func unregister(event_id: String) -> bool:
    for i in range(events.size()):
        if events[i].event_id == event_id:
            events.remove_at(i)
            return true
    return false

## 获取事件
func get_event(event_id: String) -> ViewsEvent:
    for e in events:
        if e.event_id == event_id:
            return e
    return null

## 每日检查触发
## 返回: 触发的事件名称列表
func check_daily(blogger: Dictionary) -> Array:
    var triggered = []
    for event in events:
        if event.check_trigger(blogger):
            event.trigger()
            if not active_events.has(event):
                active_events.append(event)
            triggered.append(event.event_name)
    return triggered

## 手动触发事件（如活动系统调用）
func trigger_event(event_id: String) -> bool:
    var event = get_event(event_id)
    if event:
        event.trigger()
        if not active_events.has(event):
            active_events.append(event)
        return true
    return false

## 手动结束事件
func end_event(event_id: String) -> bool:
    var event = get_event(event_id)
    if event:
        event.end()
        return true
    return false

## 应用所有活跃事件
func apply_all(views: int, post: Dictionary, blogger: Dictionary) -> int:
    for event in active_events:
        if event.remaining_days > 0:
            views = event.apply(views, post, blogger)
    return views

## 每日更新（减少剩余天数，移除过期事件）
func daily_update() -> void:
    for event in active_events:
        event.daily_update()
    # 移除过期事件
    active_events = active_events.filter(func(e): return e.remaining_days > 0)

## 获取活跃事件列表
func get_active_events() -> Array:
    return active_events.filter(func(e): return e.remaining_days > 0)

## 获取所有事件信息
func get_all_info() -> Array:
    return events.map(func(e): return e.get_info())

## 获取活跃事件数量
func get_active_count() -> int:
    return get_active_events().size()
