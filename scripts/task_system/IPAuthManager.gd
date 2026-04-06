extends Node
## IP授权管理器 - 处理文学和动漫IP授权相关逻辑

var _ip_auth_instance = null

## 信号回调
var emit_info_msg: Callable = func(_msg): pass
var emit_popup_msg: Callable = func(_title, _content): pass

func _init():
    _ip_auth_instance = preload("res://data/ip_authorization.gd").new()

func set_signal_callbacks(info_callback: Callable, popup_callback: Callable):
    emit_info_msg = info_callback
    emit_popup_msg = popup_callback

## 检查文学IP授权条件
func check_literature_ip_auth(_context: Dictionary) -> bool:
    if not Blogger:
        return false
    var lit_value = Blogger.get_ability_by_type("literature")
    var novel_count = _get_post_count("小说连载(付费)")
    return lit_value >= 100 and novel_count >= 50

## 检查绘画IP授权条件
func check_draw_ip_auth(_context: Dictionary) -> bool:
    if not Blogger:
        return false
    var draw_value = Blogger.get_ability_by_type("draw")
    var anime_count = _get_post_count("动漫连载(收费)")
    return draw_value >= 100 and anime_count >= 50

## 获取指定类型博文发布次数
func _get_post_count(post_type: String) -> int:
    if not GDManager:
        return 0
    var blogger_data = GDManager.get_blogger()
    if not blogger_data:
        return 0
    var count = 0
    for post in blogger_data.posts:
        if post.get("category", "") == post_type:
            count += 1
    return count

## 动作：触发IP授权
func action_trigger_ip_auth(ip_type: String) -> void:
    var ip_state = _get_or_create_ip_state()
    ip_state.active = true
    ip_state.ip_type = ip_type
    ip_state.remaining_months = 12
    
    var company = _get_random_company()
    ip_state.company = company
    
    if Blogger:
        Blogger.reputation += 500
    
    emit_info_msg.call("作品被【%s】看中，获得IP授权！月收益：%d元" % [company.name, 1000])

## 获取随机授权公司
func _get_random_company() -> Dictionary:
    var companies = [
        {"name": "星耀影视", "type": "movie"},
        {"name": "梦幻游戏", "type": "game"},
        {"name": "九天娱乐", "type": "movie"},
    ]
    return companies[randi() % companies.size()]

## 动作：IP月收益
func action_ip_monthly_income() -> int:
    var ip_state = _get_or_create_ip_state()
    if not ip_state.get("active", false):
        return 0
    
    var monthly_income = ip_state.get("monthly_income", 1000)
    ip_state.remaining_months = ip_state.get("remaining_months", 12) - 1
    
    if ip_state.remaining_months <= 0:
        ip_state.active = false
        emit_info_msg.call("IP授权合同到期！")
    
    if Blogger:
        Blogger.money += monthly_income
    
    return monthly_income

## 获取或创建IP状态
func _get_or_create_ip_state() -> Dictionary:
    return _ip_auth_instance.current_ip_state if _ip_auth_instance else {}