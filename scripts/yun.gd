extends Node
# 定义域名费用常量
const DOMAIN_RENEWAL_COST = 80.0  # 可以根据实际需求修改这个数值
# 域名信息
var domain_info = {
    "name": "suiyan.cc",
    "start_time": "2000-1-1-1",  # YYYY-M-W-D
    "end_time": "2001-1-1-1",    # YYYY-M-W-D
    "is_active": true
}

func _ready():
    pass

func day_fs():
    """每日检查域名状态"""
    var today = Utils.format_date()
    
    # 检查域名是否到期
    check_domain_expiration(today)

func check_domain_expiration(today: String):
    """检查域名是否到期"""
    if domain_info.is_active and domain_info.end_time != "":
        var days_diff = Utils.calculate_new_game_time_difference(domain_info.end_time, today, false)
        if days_diff >= 0:  # 域名已到期
            domain_info.is_active = false
            emit_signal("domain_expired", domain_info.name)


func renew_domain(duration_years: int = 1) -> Dictionary:
    """续费域名，返回续费结果信息"""
    # 检查账户余额是否足够
    if Blogger.money < DOMAIN_RENEWAL_COST:
        return {
            "success": false,
            "message": "账户余额不足，无法续费域名",
            "error_code": "INSUFFICIENT_FUNDS"
        }
    
    # 检查续费年限是否有效
    if duration_years <= 0:
        return {
            "success": false,
            "message": "续费年限必须大于0",
            "error_code": "INVALID_DURATION"
        }
    
    # 扣除费用
    Blogger.money -= DOMAIN_RENEWAL_COST
    
    # 更新域名信息
    var current_date = Utils.format_date()
     # 如果域名已过期，从当前日期开始续费；如果未过期，从原结束日期开始续费
    var start_time = current_date if not domain_info.is_active else domain_info.start_time
    var end_time = current_date if not domain_info.is_active else domain_info.end_time
    domain_info.start_time = start_time
    domain_info.end_time = add_years_to_date(end_time, duration_years)
    domain_info.is_active = true
    
    # 返回成功信息
    return {
        "success": true,
        "message": "域名续费成功",
        "domain_name": domain_info.name,
        "new_end_time": domain_info.end_time,
        "remaining_balance": Blogger.money
    }

func add_years_to_date(date_str: String, years: int) -> String:
    """给日期添加年份"""
    var parts = date_str.split("-")
    var year = int(parts[0]) + years
    return "%d-%s-%s-%s" % [year, parts[1], parts[2], parts[3]]

func get_domain_status() -> Dictionary:
    """获取域名状态"""
    return domain_info

func get_domain_name() -> String:
    """获取域名名称"""
    return domain_info.name

func is_domain_active() -> bool:
    """检查域名是否激活"""
    return domain_info.is_active

func get_domain_end_time() -> String:
    """获取域名到期时间"""
    return domain_info.end_time

# 信号定义
signal domain_expired(domain_name)
