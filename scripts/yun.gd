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
    # 初始化系统 - 赠送一年免费套餐
    initialize_free_package()

func day_fs():
    """每日检查域名状态"""
    var today = Utils.format_date()
    
    # 检查域名是否到期
    check_domain_expiration(today)

    # 检查服务器套餐是否到期
    check_server_package_expiration(today)
    
        # 检查数据安全防护是否到期
    check_data_security_expiration(today)
    
    # 检查网络安全防护是否到期
    check_network_security_expiration(today)

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



######################
#服务器相关
######################



# 服务器套餐费用常量
const FREE_PACKAGE_COST = 0.0
const BASIC_PACKAGE_COST = 50.0
const STANDARD_PACKAGE_COST = 150.0
const PREMIUM_PACKAGE_COST = 300.0
const ENTERPRISE_PACKAGE_COST = 600.0

# 套餐类型枚举
enum PackageType {
    FREE = 0,
    BASIC = 1,
    STANDARD = 2,
    PREMIUM = 3,
    ENTERPRISE = 4
}

# 套餐名称映射
var package_names = {
    PackageType.FREE: "免费套餐",
    PackageType.BASIC: "基础套餐",
    PackageType.STANDARD: "标准套餐",
    PackageType.PREMIUM: "高级套餐",
    PackageType.ENTERPRISE: "企业套餐"
}

# 套餐访问量限制（单位：万次/月）
var package_traffic_limits = {
    PackageType.FREE: 1,      # 1万次/月
    PackageType.BASIC: 10,    # 10万次/月
    PackageType.STANDARD: 50, # 50万次/月
    PackageType.PREMIUM: 200, # 200万次/月
    PackageType.ENTERPRISE: 1000 # 1000万次/月
}

# 服务器套餐信息
var server_package = {
    "type": PackageType.FREE,
    "name": "免费套餐",
    "start_time": "2000-1-1-1",  # YYYY-M-W-D
    "end_time": "2001-1-1-1",    # YYYY-M-W-D
    "is_active": true,
    "monthly_traffic_limit": 1    # 万次/月
}




func initialize_free_package():
    """初始化免费套餐 - 赠送一年使用期"""
    var current_date = Utils.format_date()
    server_package.start_time = "2000-1-1-1"
    server_package.end_time = "2001-1-1-1"
    server_package.type = PackageType.FREE
    server_package.name = package_names[PackageType.FREE]
    server_package.monthly_traffic_limit = package_traffic_limits[PackageType.FREE]
    server_package.is_active = true



func check_server_package_expiration(today: String):
    """检查服务器套餐是否到期"""
    if server_package.is_active and server_package.end_time != "":
        var days_diff = Utils.calculate_new_game_time_difference(server_package.end_time, today, false)
        if days_diff >= 0:  # 套餐已到期
            # 套餐到期后降级到免费套餐
            downgrade_to_free_package()
            emit_signal("server_package_expired", server_package.name)

func downgrade_to_free_package():
    """降级到免费套餐"""
    server_package.type = PackageType.FREE
    server_package.name = package_names[PackageType.FREE]
    server_package.monthly_traffic_limit = package_traffic_limits[PackageType.FREE]
    server_package.is_active = false  # 到期后变为非激活状态

func upgrade_server_package(new_package_type: PackageType) -> Dictionary:
    """
    升级服务器套餐 - 只升级当前套餐的剩余时间，套餐时间不变
    计算剩余时间并收取相应费用
    """
    # 检查是否已经是目标套餐
    if server_package.type == new_package_type:
        return {
            "success": false,
            "message": "当前已是该套餐类型，无需升级",
            "error_code": "SAME_PACKAGE_TYPE"
        }
    
    # 获取目标套餐费用
    var target_cost = get_package_cost(new_package_type)
    var current_cost = get_package_cost(server_package.type)
    
    # 计算差价
    var price_difference = target_cost - current_cost
    
    # 如果目标套餐比当前套餐便宜，不需要付费（降级）
    if price_difference <= 0:
        # 降级操作
        server_package.type = new_package_type
        server_package.name = package_names[new_package_type]
        server_package.monthly_traffic_limit = package_traffic_limits[new_package_type]
        server_package.is_active = true
        
        return {
            "success": true,
            "message": "套餐降级成功",
            "old_package": package_names[server_package.type],
            "new_package": package_names[new_package_type],
            "end_time": server_package.end_time
        }
    
    # 计算剩余时间
    var current_date = Utils.format_date()
    var remaining_days = Utils.calculate_new_game_time_difference(current_date, server_package.end_time, false)
    
    # 计算剩余时间需要支付的费用
    var total_days = Utils.calculate_new_game_time_difference(server_package.start_time, server_package.end_time, false)
    var upgrade_cost = (price_difference * remaining_days) / total_days
    
    # 检查账户余额是否足够
    if Blogger.money < upgrade_cost:
        return {
            "success": false,
            "message": "账户余额不足，升级需要 %.2f 元" % upgrade_cost,
            "error_code": "INSUFFICIENT_FUNDS",
            "required_amount": upgrade_cost
        }
    
    # 扣除升级费用
    Blogger.money -= upgrade_cost
    
    # 升级套餐信息
    server_package.type = new_package_type
    server_package.name = package_names[new_package_type]
    server_package.monthly_traffic_limit = package_traffic_limits[new_package_type]
    server_package.is_active = true
    
    return {
        "success": true,
        "message": "套餐升级成功，已支付 %.2f 元" % upgrade_cost,
        "old_package": package_names[server_package.type],
        "new_package": package_names[new_package_type],
        "end_time": server_package.end_time,
        "remaining_balance": Blogger.money
    }

func renew_server_package(duration_years: int = 1) -> Dictionary:
    """
    续费服务器套餐 - 与域名续费类似，只能续费相同的套餐
    套餐类型不变，只延长时间
    """
    # 检查续费年限是否有效
    if duration_years <= 0:
        return {
            "success": false,
            "message": "续费年限必须大于0",
            "error_code": "INVALID_DURATION"
        }
    
    # 获取当前套餐费用
    var current_cost = get_package_cost(server_package.type)
    var total_renewal_cost = current_cost * duration_years
    
    # 检查账户余额是否足够
    if Blogger.money < total_renewal_cost:
        return {
            "success": false,
            "message": "账户余额不足，续费需要 %.2f 元" % total_renewal_cost,
            "error_code": "INSUFFICIENT_FUNDS",
            "required_amount": total_renewal_cost
        }
    
    # 扣除续费费用
    Blogger.money -= total_renewal_cost
    
    # 更新套餐信息
    var current_date = Utils.format_date()
    # 如果套餐已过期，从当前日期开始续费；如果未过期，从原结束日期开始续费
    var start_time = current_date if not server_package.is_active else server_package.start_time
    var end_time = current_date if not server_package.is_active else server_package.end_time
    server_package.start_time = start_time
    server_package.end_time = add_years_to_date(end_time, duration_years)
    server_package.is_active = true
    
    return {
        "success": true,
        "message": "套餐续费成功",
        "package_name": server_package.name,
        "new_end_time": server_package.end_time,
        "duration_years": duration_years,
        "remaining_balance": Blogger.money
    }

func get_package_cost(package_type: PackageType) -> float:
    """获取套餐费用"""
    match package_type:
        PackageType.FREE: return FREE_PACKAGE_COST
        PackageType.BASIC: return BASIC_PACKAGE_COST
        PackageType.STANDARD: return STANDARD_PACKAGE_COST
        PackageType.PREMIUM: return PREMIUM_PACKAGE_COST
        PackageType.ENTERPRISE: return ENTERPRISE_PACKAGE_COST
        _: return FREE_PACKAGE_COST

func get_server_package_status() -> Dictionary:
    """获取服务器套餐状态"""
    return server_package

func get_server_package_type() -> PackageType:
    """获取当前服务器套餐类型"""
    return server_package.type

func get_server_package_name() -> String:
    """获取当前服务器套餐名称"""
    return server_package.name

func is_server_package_active() -> bool:
    """检查服务器套餐是否激活"""
    return server_package.is_active

func get_server_package_end_time() -> String:
    """获取服务器套餐到期时间"""
    return server_package.end_time

func get_monthly_traffic_limit() -> int:
    """获取月访问量限制（万次/月）"""
    return server_package.monthly_traffic_limit

func get_package_traffic_limit(package_type: PackageType) -> int:
    """获取指定套餐的月访问量限制"""
    return package_traffic_limits.get(package_type, 1)

func get_all_package_info() -> Dictionary:
    """获取所有套餐信息"""
    return {
        "package_names": package_names,
        "package_traffic_limits": package_traffic_limits,
        "package_costs": {
            PackageType.FREE: FREE_PACKAGE_COST,
            PackageType.BASIC: BASIC_PACKAGE_COST,
            PackageType.STANDARD: STANDARD_PACKAGE_COST,
            PackageType.PREMIUM: PREMIUM_PACKAGE_COST,
            PackageType.ENTERPRISE: ENTERPRISE_PACKAGE_COST
        }
    }

# 信号定义
signal server_package_expired(package_name)


########## 安全防护
# 安全防护价格常量
const DATA_SECURITY_COST = 3000  # 数据安全防护价格
const NETWORK_SECURITY_COST = 3000  # 网络安全防护价格

# 安全防护系统
var data_security = {
    "start_time": "",
    "end_time": "",
    "is_active": false
}

var network_security = {
    "start_time": "",
    "end_time": "",
    "is_active": false
}


func check_data_security_expiration(today: String):
    """检查数据安全防护是否到期"""
    if data_security.is_active and data_security.end_time != "":
        var days_diff = Utils.calculate_new_game_time_difference(data_security.end_time, today)
        if days_diff >= 0:  # 防护已到期
            data_security.is_active = false

func check_network_security_expiration(today: String):
    """检查网络安全防护是否到期"""
    if network_security.is_active and network_security.end_time != "":
        var days_diff = Utils.calculate_new_game_time_difference(network_security.end_time, today)
        if days_diff >= 0:  # 防护已到期
            network_security.is_active = false



func renew_data_security(duration_days: int) -> Dictionary:
    """续费数据安全防护，返回续费结果信息"""
    # 检查账户余额是否足够
    if Blogger.money < DATA_SECURITY_COST:
        return {
            "success": false,
            "message": "账户余额不足，无法续费数据安全防护",
            "error_code": "INSUFFICIENT_FUNDS"
        }
    
    # 检查续费天数是否有效
    if duration_days <= 0:
        return {
            "success": false,
            "message": "续费天数必须大于0",
            "error_code": "INVALID_DURATION"
        }
    
    # 扣除费用
    Blogger.money -= DATA_SECURITY_COST
    
    # 更新数据安全防护信息
    var current_date = Utils.format_date()
    
    if not data_security.is_active or data_security.end_time == "":
        # 如果防护未激活或没有结束时间，从当前日期开始
        data_security.start_time = current_date
        data_security.end_time = add_years_to_date(current_date, duration_days)
    else:
        # 如果防护已激活，从当前结束时间开始延长
        data_security.end_time = add_years_to_date(data_security.end_time, duration_days)
        # 如果之前是未激活状态，现在激活
        if not data_security.is_active:
            data_security.start_time = current_date
    data_security.is_active = true
    
    # 返回成功信息
    return {
        "success": true,
        "message": "数据安全防护续费成功",
        "duration_days": duration_days,
        "new_end_time": data_security.end_time,
        "remaining_balance": Blogger.money
    }
    
    
func renew_network_security(duration_days: int) -> Dictionary:
    """续费网络安全防护，返回续费结果信息"""
    # 检查账户余额是否足够
    if Blogger.money < NETWORK_SECURITY_COST:
        return {
            "success": false,
            "message": "账户余额不足，无法续费网络安全防护",
            "error_code": "INSUFFICIENT_FUNDS"
        }
    
    # 检查续费天数是否有效
    if duration_days <= 0:
        return {
            "success": false,
            "message": "续费天数必须大于0",
            "error_code": "INVALID_DURATION"
        }
    
    # 扣除费用
    Blogger.money -= NETWORK_SECURITY_COST
    
    # 更新网络安全防护信息
    var current_date = Utils.format_date()
    
    if not network_security.is_active or network_security.end_time == "":
        # 如果防护未激活或没有结束时间，从当前日期开始
        network_security.start_time = current_date
        network_security.end_time = add_years_to_date(current_date, duration_days)
    else:
        # 如果防护已激活，从当前结束时间开始延长
        network_security.end_time = add_years_to_date(network_security.end_time, duration_days)
        # 如果之前是未激活状态，现在激活
        if not network_security.is_active:
            network_security.start_time = current_date
    network_security.is_active = true
    
    # 返回成功信息
    return {
        "success": true,
        "message": "网络安全防护续费成功",
        "duration_days": duration_days,
        "new_end_time": network_security.end_time,
        "remaining_balance": Blogger.money
    }
func get_data_security_status() -> Dictionary:
    return data_security

func get_network_security_status() -> Dictionary:
    return network_security

func is_data_security_active() -> bool:
    return data_security.is_active

func is_network_security_active() -> bool:
    return network_security.is_active
