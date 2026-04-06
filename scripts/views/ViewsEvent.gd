## 访问量事件基类
## 事件是随机或条件触发的临时加成
class_name ViewsEvent
extends RefCounted

## 事件唯一标识
var event_id: String = ""

## 事件名称
var event_name: String = ""

## 事件描述
var description: String = ""

## 持续时间（天），0表示仅当天
var duration: int = 0

## 剩余天数
var remaining_days: int = 0

## 加成比例（如0.5表示50%加成）
var bonus_ratio: float = 0.0

## 是否正在生效
var is_active: bool = false

## 检查触发条件
## blogger: 博主数据
## 返回: 是否触发
func check_trigger(blogger: Dictionary) -> bool:
    return false

## 应用事件效果
func apply(views: int, post: Dictionary, blogger: Dictionary) -> int:
    if remaining_days <= 0:
        return views
    return int(views * (1.0 + bonus_ratio))

## 每日更新（减少剩余天数）
func daily_update() -> void:
    if remaining_days > 0:
        remaining_days -= 1
        if remaining_days <= 0:
            is_active = false

## 触发事件
func trigger() -> void:
    remaining_days = duration
    is_active = true

## 强制结束事件
func end() -> void:
    remaining_days = 0
    is_active = false

## 获取事件信息
func get_info() -> Dictionary:
    return {
        "event_id": event_id,
        "event_name": event_name,
        "description": description,
        "duration": duration,
        "remaining_days": remaining_days,
        "bonus_ratio": bonus_ratio,
        "is_active": is_active
    }
