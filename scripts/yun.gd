extends Node

# ===== 信号定义 =====
signal domain_expired(domain_name)
signal server_package_expired(package_name)
signal blog_suspended(source)
signal suspend_warning(message)
signal game_over(suspend_days)
signal domain_renewal_reminder(days_left: int)
signal host_renewal_reminder(days_left: int)
# 厂商系统信号
signal provider_appeared(provider_name: String)
signal provider_runaway(provider_name: String)
signal provider_runaway_active(provider_name: String)
signal runaway_warning(message: String)
signal runaway_seo_wiped(provider_name: String)

# 默认服务商
const DEFAULT_PROVIDER_ID = "yunqi"

# 定义域名费用常量
const DOMAIN_RENEWAL_COST = 80.0  # 可以根据实际需求修改这个数值
# 域名信息
var domain_info = {
    "name": "suiyan.cc",
    "start_time": TimeData.get_game_start_date_str(),     # YYYY-M-W-D
    "end_time": TimeData.get_date_after_years(TimeData.FREE_DURATION_YEARS),
    "is_active": true
}

func _ready():
    # 初始化系统 - 赠送一年免费套餐
    initialize_free_package()
    # 预掷小公司随机日程
    _roll_provider_schedules()
    # 游戏启动时检查一次状态
    var today = Utils.format_date()
    check_domain_expiration(today)
    check_server_package_expiration(today)

######################
# 服务商选择系统
######################

# 厂商状态枚举
enum ProviderStatus {
    LOCKED = 0,
    ACTIVE = 1,
    RUNAWAY = 2,
}

# 当前选中的服务商
var provider_id: String = DEFAULT_PROVIDER_ID
# 小公司随机日程：id -> {appear_date, runaway_date, appeared, runaway}
var _provider_schedule: Dictionary = {}
# 大公司上线播报标记（避免重复弹窗）
var _provider_big_announced: Dictionary = {}
# 正在使用的厂商跑路失联
var runaway_provider_id: String = ""
var runaway_start_date: String = ""
# SEO 清零是否已触发
var _runaway_seo_wiped: bool = false

## 获取厂商列表
func get_providers() -> Array:
    var inst = GDManager.get_yun_providers()
    if inst:
        return inst.providers
    return []

## 按 id 获取厂商字典
func get_provider_by_id(pid: String) -> Dictionary:
    for p in get_providers():
        if p.get("id") == pid:
            return p
    return {}

## 获取当前厂商
func get_current_provider() -> Dictionary:
    return get_provider_by_id(provider_id)

## 预掷小公司出现/跑路日程
func _roll_provider_schedules():
    _provider_schedule = {}
    _provider_big_announced = {}
    _runaway_seo_wiped = false
    for p in get_providers():
        if p.get("is_small", false):
            var appear_range: Array = p.get("appear_year_range", [])
            var lifespan_range: Array = p.get("lifespan_months_range", [])
            var appear_year = randi_range(int(appear_range[0]), int(appear_range[1]))
            var appear_month = randi_range(1, 12)
            var appear_week = randi_range(1, 4)
            var appear_day = randi_range(1, 7)
            var appear_date = "%d-%d-%d-%d" % [appear_year, appear_month, appear_week, appear_day]
            var lifespan_months = randi_range(int(lifespan_range[0]), int(lifespan_range[1]))
            var runaway_date = add_months_to_date(appear_date, lifespan_months)
            _provider_schedule[p.get("id")] = {
                "appear_date": appear_date,
                "runaway_date": runaway_date,
                "appeared": false,
                "runaway": false,
            }

## 给日期增加月份（游戏月份统一 4 周）
func add_months_to_date(date_str: String, months: int) -> String:
    var parts = date_str.split("-")
    var total_months = int(parts[1]) - 1 + months
    var year = int(parts[0]) + int(total_months / 12)
    var month = total_months % 12 + 1
    return "%d-%d-%d-%d" % [year, month, int(parts[2]), int(parts[3])]

## 判断年份月份是否已到达
func _is_year_month_reached(year: int, month: int) -> bool:
    return TimerManager.current_year > year or (TimerManager.current_year == year and TimerManager.current_month >= month)

## 获取厂商状态
func get_provider_status(pid: String) -> Dictionary:
    var p = get_provider_by_id(pid)
    if p.is_empty():
        return {"status": ProviderStatus.LOCKED, "info": ""}
    if p.get("is_small", false):
        var sch = _provider_schedule.get(pid, {})
        if sch.get("runaway", false):
            return {"status": ProviderStatus.RUNAWAY, "info": "已跑路失联"}
        if not sch.get("appeared", false):
            return {"status": ProviderStatus.LOCKED, "info": "上线时间未知"}
        return {"status": ProviderStatus.ACTIVE, "info": "营业中"}
    var launch_year = int(p.get("launch_year", 2001))
    var launch_month = int(p.get("launch_month", 1))
    if not _is_year_month_reached(launch_year, launch_month):
        return {"status": ProviderStatus.LOCKED, "info": "%d年%d月上线" % [launch_year, launch_month]}
    return {"status": ProviderStatus.ACTIVE, "info": "营业中"}

## 厂商是否可选
func is_provider_available(pid: String) -> bool:
    return get_provider_status(pid).status == ProviderStatus.ACTIVE

## 切换服务商，返回是否成功
func set_provider(pid: String) -> bool:
    if not is_provider_available(pid):
        return false
    provider_id = pid
    # 如果离开的是失联中的厂商，恢复正常
    if is_provider_runaway_active() or (runaway_provider_id != "" and provider_id != runaway_provider_id):
        _clear_runaway()
    return true

## 获取指定服务商的域名价格
func get_provider_domain_price(pid: String) -> float:
    var p = get_provider_by_id(pid)
    return float(p.get("domain_price", DOMAIN_RENEWAL_COST))

## 获取指定服务商的指定套餐年费
func get_provider_package_cost(pid: String, package_type: PackageType) -> float:
    var base_cost = 0.0
    if PACKAGE_DEFINITIONS.has(package_type):
        base_cost = PACKAGE_DEFINITIONS[package_type]["cost"]
    var p = get_provider_by_id(pid)
    var mult = float(p.get("host_multiplier", 1.0))
    return round(base_cost * mult * 100.0) / 100.0

## 更换服务商：域名与主机按新服务商价格重新续费一年，原有剩余时间作废
func switch_provider(pid: String) -> Dictionary:
    var p = get_provider_by_id(pid)
    if p.is_empty():
        return {"success": false, "message": "服务商不存在", "error_code": "NOT_FOUND"}
    if not is_provider_available(pid):
        return {"success": false, "message": "该服务商当前不可用", "error_code": "NOT_AVAILABLE"}
    if pid == provider_id:
        return {"success": false, "message": "当前已是该服务商", "error_code": "SAME_PROVIDER"}
    var domain_cost = get_provider_domain_price(pid)
    var host_cost = get_provider_package_cost(pid, server_package.type)
    var total_cost = domain_cost + host_cost
    if Blogger.money < total_cost:
        return {
            "success": false,
            "message": "余额不足，更换服务商需 %.2f 元（域名 %.2f 元 + 主机 %.2f 元）" % [total_cost, domain_cost, host_cost],
            "error_code": "INSUFFICIENT_FUNDS",
            "total_cost": total_cost
        }
    Blogger.money -= total_cost
    var current_date = Utils.format_date()
    # 域名重新续费一年，原有剩余时间作废
    domain_info.start_time = current_date
    domain_info.end_time = add_years_to_date(current_date, 1)
    domain_info.is_active = true
    _domain_reminder_active = false
    # 主机重新续费一年，原有剩余时间作废
    server_package.start_time = current_date
    server_package.end_time = add_years_to_date(current_date, 1)
    server_package.is_active = true
    _host_reminder_active = false
    # 域名主机均已续费，如有欠费暂停则解除
    if is_suspended:
        var penalty_info = calculate_suspend_penalty()
        if not penalty_info.is_game_over:
            start_recovery(penalty_info.views_penalty, penalty_info.recovery_days, current_date)
            clear_suspend_status()
    # 切换服务商
    provider_id = pid
    if is_provider_runaway_active() or (runaway_provider_id != "" and provider_id != runaway_provider_id):
        _clear_runaway()
    return {
        "success": true,
        "message": "更换服务商成功",
        "provider_name": p.get("name"),
        "domain_cost": domain_cost,
        "host_cost": host_cost,
        "total_cost": total_cost,
        "remaining_balance": Blogger.money,
        "new_end_time": domain_info.end_time
    }

## 是否处于厂商跑路失联状态
func is_provider_runaway_active() -> bool:
    return runaway_provider_id != "" and provider_id == runaway_provider_id

## 清除跑路失联状态
func _clear_runaway():
    runaway_provider_id = ""
    runaway_start_date = ""
    _runaway_seo_wiped = false

## 当前厂商域名续费价格
func get_domain_renewal_cost() -> float:
    var p = get_current_provider()
    return float(p.get("domain_price", DOMAIN_RENEWAL_COST))

## 每日检查厂商上线/跑路
func _check_provider_appearance(today: String):
    for p in get_providers():
        var pid: String = p.get("id")
        var pname: String = p.get("name")
        if p.get("is_small", false):
            if not _provider_schedule.has(pid):
                continue
            var sch = _provider_schedule[pid]
            if not sch.appeared:
                if Utils.calculate_new_game_time_difference(sch.appear_date, today, false) >= 1:
                    sch.appeared = true
                    # 若出现的同时跑路日期也已到达（存档加载时点已过），不重复播报上线
                    if Utils.calculate_new_game_time_difference(sch.runaway_date, today, false) < 1:
                        emit_signal("provider_appeared", pname)
            if sch.appeared and not sch.runaway:
                if Utils.calculate_new_game_time_difference(sch.runaway_date, today, false) >= 1:
                    sch.runaway = true
                    emit_signal("provider_runaway", pname)
                    if provider_id == pid:
                        runaway_provider_id = pid
                        runaway_start_date = today
                        _runaway_seo_wiped = false
                        emit_signal("provider_runaway_active", pname)
        else:
            var launch_year = int(p.get("launch_year", 2001))
            var launch_month = int(p.get("launch_month", 1))
            if _is_year_month_reached(launch_year, launch_month) and not _provider_big_announced.has(pid):
                _provider_big_announced[pid] = true
                # 仅在刚到达上线月份时提示，避免存档加载后重复播报
                if TimerManager.current_year == launch_year and TimerManager.current_month == launch_month:
                    emit_signal("provider_appeared", pname)

## 每日检查跑路失联倒计时
func _check_runaway(today: String):
    if runaway_provider_id == "":
        return
    if provider_id != runaway_provider_id:
        _clear_runaway()
        return
    var pname: String = get_provider_by_id(runaway_provider_id).get("name", runaway_provider_id)
    var days = Utils.calculate_new_game_time_difference(runaway_start_date, today, false)
    if days == 5:
        emit_signal("runaway_warning", "服务商「%s」已失联%d天，还剩2天必须更换服务商，否则SEO将清零！" % [pname, days])
    if days >= 7 and not _runaway_seo_wiped:
        _runaway_seo_wiped = true
        var blogger = GDManager.get_blogger()
        if blogger:
            blogger.seo_value = 0
        emit_signal("runaway_seo_wiped", pname)

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
    
    # 检查暂停状态和欠费天数
    check_suspend_status(today)
    
    # 更新恢复进度（新增）
    update_recovery_progress(today)
    
    # 到期前提醒检查
    _check_domain_reminder(today)
    _check_host_reminder(today)
    
    # 服务商上线/跑路检查
    _check_provider_appearance(today)
    _check_runaway(today)

func check_domain_expiration(today: String):
    """检查域名是否到期"""
    if domain_info.is_active and domain_info.end_time != "":
        var days_diff = Utils.calculate_new_game_time_difference(domain_info.end_time, today, false)
        if days_diff >= 0:  # 域名已到期
            domain_info.is_active = false
            emit_signal("domain_expired", domain_info.name)
            # 记录欠费状态
            update_suspend_status(today, "domain")


func renew_domain(duration_years: int = 1) -> Dictionary:
    """续费域名，返回续费结果信息"""
    var domain_cost = get_domain_renewal_cost()
    # 检查账户余额是否足够
    if Blogger.money < domain_cost:
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
    Blogger.money -= domain_cost
    
    # 更新域名信息
    var current_date = Utils.format_date()
     # 如果域名已过期，从当前日期开始续费；如果未过期，从原结束日期开始续费
    var start_time = current_date if not domain_info.is_active else domain_info.start_time
    var end_time = current_date if not domain_info.is_active else domain_info.end_time
    domain_info.start_time = start_time
    domain_info.end_time = add_years_to_date(end_time, duration_years)
    domain_info.is_active = true
    
    # 重置域名提醒标记，明年的到期提醒会重新触发
    _domain_reminder_active = false
    
    # ===== 恢复惩罚处理 =====
    # 如果之前处于暂停状态，检查是否可以解除暂停
    if is_suspended and suspend_source in ["domain", "both"]:
        # 计算恢复惩罚
        var penalty_info = calculate_suspend_penalty()
        if not penalty_info.is_game_over:
            # 设置恢复惩罚
            start_recovery(penalty_info.views_penalty, penalty_info.recovery_days, current_date)
            # 清除暂停状态（如果主机也正常）
            if server_package.is_active or suspend_source == "domain":
                clear_suspend_status()
    
    # 返回成功信息
    return {
        "success": true,
        "message": "域名续费成功",
        "domain_name": domain_info.name,
        "new_end_time": domain_info.end_time,
        "remaining_balance": Blogger.money,
        "recovery_penalty": recovery_penalty,
        "recovery_days": recovery_total_days
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

######################
#服务器相关
######################

# 套餐类型枚举
enum PackageType {
    FREE = 0,
    BASIC = 1,
    STANDARD = 2,
    PREMIUM = 3,
    ENTERPRISE = 4,
    ULTIMATE = 5
}

# 套餐配置统一管理 - 所有套餐信息集中在一处，方便修改
const PACKAGE_DEFINITIONS: Dictionary = {
    PackageType.FREE: {
        "name": "免费套餐",
        "cost": 0.0,
        "traffic_limit": 1,
        "description": "入门级套餐，适合体验"
    },
    PackageType.BASIC: {
        "name": "基础套餐",
        "cost": 300.0,
        "traffic_limit": 3,
        "description": "适合个人博主日常使用"
    },
    PackageType.STANDARD: {
        "name": "标准套餐",
        "cost": 1000.0,
        "traffic_limit": 10,
        "description": "适合有一定影响力的博主"
    },
    PackageType.PREMIUM: {
        "name": "高级套餐",
        "cost": 5000.0,
        "traffic_limit": 50,
        "description": "适合知名博主和大V"
    },
    PackageType.ENTERPRISE: {
        "name": "企业套餐",
        "cost": 10000.0,
        "traffic_limit": 100,
        "description": "适合企业和机构"
    },
    PackageType.ULTIMATE: {
        "name": "终极套餐",
        "cost": 50000.0,
        "traffic_limit": -1,
        "description": "顶级配置，无访问量上限"
    }
}

# 服务器套餐信息
var server_package = {
    "type": PackageType.FREE,
    "name": PACKAGE_DEFINITIONS[PackageType.FREE]["name"],
    "start_time": TimeData.get_game_start_date_str(),
    "end_time": TimeData.get_date_after_years(TimeData.FREE_DURATION_YEARS),
    "is_active": true,
    "monthly_traffic_limit": PACKAGE_DEFINITIONS[PackageType.FREE]["traffic_limit"]
}

# ===== 欠费暂停追踪变量 =====
# 欠费开始时间（域名或主机任一项欠费时记录）
var suspend_start_time: String = ""  # YYYY-M-W-D
# 累计欠费天数
var suspend_days: int = 0
# 是否处于暂停状态
var is_suspended: bool = false
# 欠费来源（"domain" / "host" / "both"）
var suspend_source: String = ""
# 游戏是否已结束（避免重复触发 game_over 信号）
var is_game_over: bool = false

# ===== 到期提醒追踪标记 =====
var _domain_reminder_active: bool = false
var _host_reminder_active: bool = false

# ===== 恢复惩罚追踪变量 =====
# 当前惩罚系数（0.0-1.0，表示访问量损失比例）
var recovery_penalty: float = 0.0
# 恢复总天数
var recovery_total_days: int = 0
# 恢复开始时间
var recovery_start_time: String = ""
# 恢复已进行天数
var recovery_current_day: int = 0




func initialize_free_package():
    """初始化免费套餐 - 赠送一年使用期"""
    var current_date = Utils.format_date()
    server_package.start_time = TimeData.get_game_start_date_str()
    server_package.end_time = TimeData.get_date_after_years(TimeData.FREE_DURATION_YEARS)
    server_package.type = PackageType.FREE
    server_package.name = PACKAGE_DEFINITIONS[PackageType.FREE]["name"]
    server_package.monthly_traffic_limit = PACKAGE_DEFINITIONS[PackageType.FREE]["traffic_limit"]
    server_package.is_active = true



func check_server_package_expiration(today: String):
    """检查服务器套餐是否到期"""
    if server_package.is_active and server_package.end_time != "":
        var days_diff = Utils.calculate_new_game_time_difference(server_package.end_time, today, false)
        if days_diff >= 0:  # 套餐已到期
            # 套餐到期后降级到免费套餐
            downgrade_to_free_package()
            emit_signal("server_package_expired", server_package.name)
            # 记录欠费状态
            update_suspend_status(today, "host")

func downgrade_to_free_package():
    """降级到免费套餐"""
    server_package.type = PackageType.FREE
    server_package.name = PACKAGE_DEFINITIONS[PackageType.FREE]["name"]
    server_package.monthly_traffic_limit = PACKAGE_DEFINITIONS[PackageType.FREE]["traffic_limit"]
    server_package.is_active = false

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
        server_package.name = PACKAGE_DEFINITIONS[new_package_type]["name"]
        server_package.monthly_traffic_limit = PACKAGE_DEFINITIONS[new_package_type]["traffic_limit"]
        server_package.is_active = true
        
        return {
            "success": true,
            "message": "套餐降级成功",
            "old_package": PACKAGE_DEFINITIONS[server_package.type]["name"],
            "new_package": PACKAGE_DEFINITIONS[new_package_type]["name"],
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
    server_package.name = PACKAGE_DEFINITIONS[new_package_type]["name"]
    server_package.monthly_traffic_limit = PACKAGE_DEFINITIONS[new_package_type]["traffic_limit"]
    server_package.is_active = true
    
    return {
        "success": true,
        "message": "套餐升级成功，已支付 %.2f 元" % upgrade_cost,
        "old_package": PACKAGE_DEFINITIONS[server_package.type]["name"],
        "new_package": PACKAGE_DEFINITIONS[new_package_type]["name"],
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
    
    # 重置主机提醒标记，明年的到期提醒会重新触发
    _host_reminder_active = false
    
    # ===== 恢复惩罚处理 =====
    # 如果之前处于暂停状态，检查是否可以解除暂停
    if is_suspended and suspend_source in ["host", "both"]:
        # 计算恢复惩罚
        var penalty_info = calculate_suspend_penalty()
        if not penalty_info.is_game_over:
            # 设置恢复惩罚
            start_recovery(penalty_info.views_penalty, penalty_info.recovery_days, current_date)
            # 清除暂停状态（如果域名也正常）
            if domain_info.is_active or suspend_source == "host":
                clear_suspend_status()
    
    return {
        "success": true,
        "message": "套餐续费成功",
        "package_name": server_package.name,
        "new_end_time": server_package.end_time,
        "duration_years": duration_years,
        "remaining_balance": Blogger.money,
        "recovery_penalty": recovery_penalty,
        "recovery_days": recovery_total_days
    }

func get_package_cost(package_type: PackageType) -> float:
    """获取套餐费用（按当前服务商价格系数换算）"""
    var base_cost = 0.0
    if PACKAGE_DEFINITIONS.has(package_type):
        base_cost = PACKAGE_DEFINITIONS[package_type]["cost"]
    var p = get_current_provider()
    var mult = float(p.get("host_multiplier", 1.0))
    return round(base_cost * mult * 100.0) / 100.0

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
    """获取月访问量限制（万次/月），-1表示无限制"""
    # 如果处于暂停状态，返回0（完全禁止访问）
    if is_blog_suspended():
        return 0
    # 终极套餐返回-1表示无限制
    if server_package.type == PackageType.ULTIMATE:
        return -1
    return server_package.monthly_traffic_limit

func get_package_traffic_limit(package_type: PackageType) -> int:
    """获取指定套餐的月访问量限制"""
    if PACKAGE_DEFINITIONS.has(package_type):
        return PACKAGE_DEFINITIONS[package_type]["traffic_limit"]
    return PACKAGE_DEFINITIONS[PackageType.FREE]["traffic_limit"]

func get_all_package_info() -> Dictionary:
    """获取所有套餐信息"""
    return PACKAGE_DEFINITIONS

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


# ===== 到期前提醒检查 =====

func _check_domain_reminder(today: String):
    if not domain_info.is_active or domain_info.end_time == "":
        _domain_reminder_active = false
        return
    var days_diff = Utils.calculate_new_game_time_difference(domain_info.end_time, today, false)
    var days_left = -days_diff
    if 0 < days_left and days_left <= 30:
        if not _domain_reminder_active:
            _domain_reminder_active = true
            emit_signal("domain_renewal_reminder", days_left)
    else:
        _domain_reminder_active = false


func _check_host_reminder(today: String):
    if not server_package.is_active or server_package.end_time == "":
        _host_reminder_active = false
        return
    var days_diff = Utils.calculate_new_game_time_difference(server_package.end_time, today, false)
    var days_left = -days_diff
    if 0 < days_left and days_left <= 30:
        if not _host_reminder_active:
            _host_reminder_active = true
            emit_signal("host_renewal_reminder", days_left)
    else:
        _host_reminder_active = false


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

# ===== 欠费暂停系统 =====

func update_suspend_status(today: String, source: String):
    """更新欠费暂停状态"""
    # 如果已经有暂停记录，不重复记录
    if is_suspended:
        # 更新欠费来源（可能两项都欠费）
        if suspend_source != "both" and suspend_source != source:
            suspend_source = "both"
        return
    
    # 记录欠费开始时间
    suspend_start_time = today
    suspend_days = 0
    is_suspended = true
    suspend_source = source
    
    emit_signal("blog_suspended", source)

func check_suspend_status(today: String):
    """每日检查暂停状态和欠费天数"""
    # 如果游戏已结束，不再处理
    if is_game_over:
        return
    
    if not is_suspended:
        return
    
    # 计算欠费天数
    if suspend_start_time != "":
        suspend_days = Utils.calculate_new_game_time_difference(suspend_start_time, today, false)
    
    # 检查是否游戏结束（欠费满4周=28天）
    if suspend_days >= 28:
        is_game_over = true  # 标记游戏已结束，避免重复触发
        emit_signal("game_over", suspend_days)
        return
    
    # 最后三天每天提示（第25、26、27天）
    if suspend_days >= 25:
        var remaining = 28 - suspend_days
        emit_signal("suspend_warning", "⚠️ 紧急警告！博客将在%d天后永久下线！请立即续费！" % remaining)
        return
    
    # 每周提示一次（第7、14、21天）
    if suspend_days == 7:
        emit_signal("suspend_warning", "博客已暂停运营1周，请尽快续费，否则将永久下线")
    elif suspend_days == 14:
        emit_signal("suspend_warning", "博客已暂停运营2周，剩余2周时间，请立即续费！")
    elif suspend_days == 21:
        emit_signal("suspend_warning", "博客已暂停运营3周，只剩最后1周！请马上续费否则游戏结束！")

func is_blog_suspended() -> bool:
    """判断博客是否暂停"""
    # 域名或主机任一项欠费 → 博客暂停；服务商跑路失联同样暂停
    return is_suspended or not domain_info.is_active or not server_package.is_active or is_provider_runaway_active()

func calculate_suspend_penalty() -> Dictionary:
    """根据欠费天数计算惩罚梯度"""
    if suspend_days <= 7:  # 第1周内
        return {
            "views_penalty": 0.1,  # 访问量-10%
            "recovery_days": 7,    # 1周恢复
            "is_game_over": false,
            "warning_level": 1
        }
    elif suspend_days <= 14:  # 第2周内
        return {
            "views_penalty": 0.3,  # 访问量-30%
            "recovery_days": 30,   # 1个月恢复
            "is_game_over": false,
            "warning_level": 2
        }
    elif suspend_days <= 21:  # 第3周内
        return {
            "views_penalty": 0.5,  # 访问量-50%
            "recovery_days": 90,   # 3个月恢复
            "is_game_over": false,
            "warning_level": 3
        }
    else:  # 第4周（满1月）
        return {
            "views_penalty": 1.0,  # 访问量-100%
            "recovery_days": 0,    # 无法恢复
            "is_game_over": true,  # 游戏结束
            "warning_level": 4
        }

func get_suspend_info() -> Dictionary:
    """获取当前暂停状态信息"""
    return {
        "is_suspended": is_suspended,
        "suspend_days": suspend_days,
        "suspend_source": suspend_source,
        "suspend_start_time": suspend_start_time,
        "penalty": calculate_suspend_penalty()
    }

# ===== 恢复惩罚系统 =====

func start_recovery(penalty: float, total_days: int, start_date: String):
    """开始恢复计时"""
    recovery_penalty = penalty
    recovery_total_days = total_days
    recovery_start_time = start_date
    recovery_current_day = 0

func clear_suspend_status():
    """清除暂停状态"""
    is_suspended = false
    suspend_start_time = ""
    suspend_days = 0
    suspend_source = ""

func update_recovery_progress(today: String):
    """每日更新恢复进度"""
    if recovery_penalty <= 0 or recovery_total_days <= 0:
        return
    
    # 计算已恢复天数
    if recovery_start_time != "":
        recovery_current_day = Utils.calculate_new_game_time_difference(recovery_start_time, today, false)
    
    # 计算当前惩罚（逐渐减少）
    if recovery_current_day >= recovery_total_days:
        # 恢复完成
        recovery_penalty = 0.0
        recovery_total_days = 0
        recovery_start_time = ""
        recovery_current_day = 0
    else:
        # 按进度减少惩罚
        var progress = float(recovery_current_day) / float(recovery_total_days)
        # 初始惩罚 × (1 - 恢复进度)
        var initial_penalty = 0.0
        # 根据初始欠费天数确定初始惩罚
        if suspend_days <= 7:
            initial_penalty = 0.1
        elif suspend_days <= 14:
            initial_penalty = 0.3
        elif suspend_days <= 21:
            initial_penalty = 0.5
        
        recovery_penalty = initial_penalty * (1.0 - progress)

func get_recovery_info() -> Dictionary:
    """获取恢复状态信息"""
    return {
        "recovery_penalty": recovery_penalty,
        "recovery_total_days": recovery_total_days,
        "recovery_current_day": recovery_current_day,
        "recovery_start_time": recovery_start_time
    }
