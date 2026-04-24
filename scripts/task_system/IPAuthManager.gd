extends Node
## IP授权管理器（简化版）
## 逻辑已移至 blogger.gd 的 _handle_novel_batch 和 _try_trigger_ip_auth
## 此文件保留用于任务配置兼容性

var _ip_auth_instance = null

## 信号回调
var emit_info_msg: Callable = func(_msg): pass
var emit_popup_msg: Callable = func(_title, _content): pass

func _init():
    _ip_auth_instance = preload("res://data/ip_authorization.gd").new()

func set_signal_callbacks(info_callback: Callable, popup_callback: Callable):
    emit_info_msg = info_callback
    emit_popup_msg = popup_callback

## 获取当前IP状态
func get_ip_state() -> Dictionary:
    return _ip_auth_instance.current_ip_state if _ip_auth_instance else {}