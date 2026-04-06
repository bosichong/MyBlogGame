extends Node
## 开源项目管理器 - 处理开源项目创建、开发和收购相关逻辑

var _open_source_instance = null

## 信号回调
var emit_info_msg: Callable = func(_msg): pass
var emit_popup_msg: Callable = func(_title, _content): pass

func _init():
    _open_source_instance = preload("res://data/open_source_project.gd").new()

func set_signal_callbacks(info_callback: Callable, popup_callback: Callable):
    emit_info_msg = info_callback
    emit_popup_msg = popup_callback

## 检查开源项目条件
func check_open_source_project(_context: Dictionary) -> bool:
    if not Blogger:
        return false
    var code_value = Blogger.get_ability_by_type("code")
    return code_value >= 100

## 动作：开始开源项目
func action_start_open_source_project() -> void:
    var os_state = _get_or_create_os_state()
    os_state.is_developing = true
    os_state.dev_days = 0
    os_state.stars = 0
    
    # 解锁开源维护笔记文章类型
    var os_notes = Utils.find_category_by_name(Utils.possible_categories, "开源维护笔记") if Utils else null
    if os_notes != null:
        os_notes.disabled = false
        os_notes.isVisible = true
    
    emit_info_msg.call("编程能力达到最高境界，可以创建开源项目了！")

## 动作：开源项目进度
func action_open_source_progress(progress: int) -> void:
    var os_state = _get_or_create_os_state()
    if os_state.get("is_developing", false):
        os_state.dev_days = os_state.get("dev_days", 0) + 1
        os_state.stars = os_state.get("stars", 0) + randi() % (progress * 10)

## 动作：开源项目被收购
func action_open_source_acquisition() -> void:
    var os_state = _get_or_create_os_state()
    var stars = os_state.get("stars", 0)
    
    var base_reward = 100000
    var star_factor = min(float(stars) / 1000.0, 10.0)
    var final_reward = int(base_reward * star_factor)
    
    os_state.acquired = true
    os_state.acquisition_reward = final_reward
    
    if Blogger:
        Blogger.money += final_reward
        Blogger.reputation += 500
    
    emit_popup_msg.call("开源项目收购", "您的开源项目被收购！\n收益：%d元\n声望：+500" % final_reward)

## 获取或创建开源项目状态
func _get_or_create_os_state() -> Dictionary:
    return _open_source_instance.current_project_state if _open_source_instance else {}

## 每月结算开源项目赞助收入
func settle_monthly_open_source() -> Dictionary:
    if not _open_source_instance:
        return {"total_income": 0}
    
    var total_income = 0
    var os_state = _get_or_create_os_state()
    
    if os_state.get("acquired", false):
        var stars = os_state.get("stars", 0)
        var monthly_income = int(stars * 0.1)
        total_income += monthly_income
        if Blogger:
            Blogger.money += monthly_income
    
    return {"total_income": total_income}