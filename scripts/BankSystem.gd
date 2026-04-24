# BankSystem.gd
# 游戏内银行系统：支持活期存款（每年复利结算）、定期存款（多档期限+提前罚息）
# 日期系统完全基于你的格式 "YYYY-M-W-D"，使用 Utils.format_date() 和 Utils.calculate_new_game_time_difference
# 所有新增方法均内置于本文件，无外部依赖

extends Node

# ========== ⚙️ 静态配置（利率常量，方便策划调整） ========== #

# 活期存款日利率（单位：百分比）
# 示例：0.01 表示每日 0.01%，年化约 3.65%
const SAVINGS_DAILY_RATE = 0.01

# 定期存款总利率（单位：百分比），按“游戏年”（336天）等比缩放
# 原自然年利率 → 游戏年利率 = 原利率 × (336 / 365)
const FIXED_RATE_HALF_YEAR = 2.301   # 半年 = 168天 ≈ 5% * 0.5 * (336/365) → 实际年化≈4.6%
const FIXED_RATE_ONE_YEAR   = 4.603   # 一年 = 336天 → 原5% → 缩放后 ≈4.603%
const FIXED_RATE_THREE_YEARS = 13.809 # 三年 = 1008天 → 原15% → 缩放后 ≈13.809%

# 提前支取罚息率：罚没应得利息的比例
# 示例：0.5 表示只给50%利息，罚没另外50%
const PENALTY_RATE_EARLY_WITHDRAWAL = 0.5
const WITHDRAWAL_FEE_RATE = 0.05     # 违约金率：5% 本金（你之前设的是5%，不是1%）

# ========== 💰 存储结构 ========== #

# 活期存款余额（玩家存入后 money 减少，取出后 money 增加）
var savings_balance: float:
    get:
        return GDManager.get_bank().savings_balance if GDManager else 0
    set(value):
        if GDManager:
            GDManager.get_bank().savings_balance = value

# 活期存款利息未结算（玩家存入后 money 减少，取出后 money 增加）
var savings_balance_interest: float:
    get:
        return GDManager.get_bank().savings_interest if GDManager else 0
    set(value):
        if GDManager:
            GDManager.get_bank().savings_interest = value

# 定期存款字典：key=存款ID, value=存款详情
# 结构示例：{1: {amount=5000, full_interest=230, start_date=..., end_date=..., claimed=false}}
var fixed_deposits: Dictionary:
    get:
        return GDManager.get_bank().fixed_deposits if GDManager else {}
    set(value):
        if GDManager:
            GDManager.get_bank().fixed_deposits = value

# 下一个定期存款的唯一ID（自增）
var next_deposit_id: int:
    get:
        return GDManager.get_bank().next_deposit_id if GDManager else 1
    set(value):
        if GDManager:
            GDManager.get_bank().next_deposit_id = value

# ========== 💳 核心公开方法 ========== #

## ———————— 活期存款 ————————

# 存入活期存款
# @param amount: 存入金额（必须 >0 且 ≤ Blogger.money）
# @return: 是否成功
func deposit_savings(amount: float) -> bool:
    if amount <= 0:
        return false
    
    # ✅ 使用误差容忍比较：允许 ±0.005 的误差（因为保留两位小数）
    if !_float_le(amount, Blogger.money):
        return false

    Blogger.money -= amount
    savings_balance += amount

    # 精度修正
    Blogger.money = _round2(Blogger.money)
    savings_balance = _round2(savings_balance)

    return true

# 从活期取出存款
# @param amount: 取出金额（必须 >0 且 ≤ savings_balance）
# @return: 是否成功
# 从活期取出存款
# @param amount: 取出金额（必须 >0 且 ≤ savings_balance）
# @return: 是否成功
func withdraw_savings(amount: float) -> bool:
    if amount <= 0:
        return false
    
    if !_float_le(amount, savings_balance):
        return false

    savings_balance -= amount
    Blogger.money += amount

    savings_balance = _round2(savings_balance)
    Blogger.money = _round2(Blogger.money)

    return true





## ———————— 定期存款 ————————

# 创建定期存款（内部使用，建议通过语义化方法调用）
# @param amount: 存入金额（必须 ≥10000 且为 10000 倍数）
# @param days: 存期（天数）
# @return: Dictionary { success:bool, deposit_id:int, msg:String }
func create_fixed_deposit(amount: float, days: int) -> Dictionary:
    # ✅ 校验最小金额 & 是否为 10000 倍数
    if amount < 10000.0:
        return {
            "success": false,
            "deposit_id": -1,
            "msg": "定期存款最低金额为 10,000 元"
        }
    
    # 检查是否为 10000 的整数倍（容忍浮点误差）
    var remainder = _round2(fmod(amount, 10000.0))
    if remainder > 0.005:  # 不是整倍数（考虑浮点误差）
        return {
            "success": false,
            "deposit_id": -1,
            "msg": "定期存款金额必须是 10,000 的整数倍"
        }

    if amount <= 0 or !_float_le(amount, Blogger.money):
        return {
            "success": false,
            "deposit_id": -1,
            "msg": "存款金额无效或余额不足"
        }
    
    var rate = get_fixed_rate_by_days(days)
    if rate < 0:
        return {
            "success": false,
            "deposit_id": -1,
            "msg": "不支持的存期天数"
        }
    
    Blogger.money -= amount
    Blogger.money = _round2(Blogger.money)
    
    var deposit_id = next_deposit_id
    next_deposit_id += 1
    
    var current_date = Utils.format_date()
    var end_date = _add_days_to_date(current_date, days)
    
    # ✅ 计算利息保留两位小数
    var full_interest = _round2(amount * (rate / 100.0))
    
    fixed_deposits[deposit_id] = {
        amount = _round2(amount),
        total_rate_percent = rate,
        full_interest = full_interest,
        start_date = current_date,
        end_date = end_date,
        claimed = false
    }
    
    return {
        "success": true,
        "deposit_id": deposit_id,
        "msg": "定期存款创建成功，到期日: %s" % end_date
    }
    
    
# 根据存期天数返回对应利率（不支持返回 -1）
func get_fixed_rate_by_days(days: int) -> float:
    match days:
        168: return FIXED_RATE_HALF_YEAR
        336: return FIXED_RATE_ONE_YEAR
        1008: return FIXED_RATE_THREE_YEARS
        _: return -1

# ———————— 语义化定期存款（推荐UI使用） ————————

func create_fixed_deposit_half_year(amount: float) -> Dictionary:
    return create_fixed_deposit(amount, 168)

func create_fixed_deposit_year(amount: float) -> Dictionary:
    return create_fixed_deposit(amount, 336)

func create_fixed_deposit_three_years(amount: float) -> Dictionary:
    return create_fixed_deposit(amount, 1008)
    
    
# ———————— 定期取现（含提前罚息+违约金） ————————
func withdraw_fixed_deposit(deposit_id: int) -> Dictionary:
    if not fixed_deposits.has(deposit_id):
        return {"success": false, "msg": "无效存款ID"}
    
    var depo = fixed_deposits[deposit_id]
    
    if depo.claimed:
        return {"success": false, "msg": "该笔存款已结算，无法重复取出"}
    
    var current_date = Utils.format_date()
    var days_to_maturity = Utils.calculate_new_game_time_difference(depo.end_date, current_date, false)
    var is_matured = days_to_maturity >= 0

    var actual_days = Utils.calculate_new_game_time_difference(current_date, depo.start_date)
    if actual_days < 0: actual_days = 0

    var total_days = Utils.calculate_new_game_time_difference(depo.end_date, depo.start_date)
    if total_days <= 0: total_days = 1

    var principal_return = depo.amount
    var interest = 0.0  # ✅ 改为 float
    var penalty_applied = false
    var withdrawal_fee = 0.0  # ✅ 改为 float

    if is_matured:
        interest = depo.full_interest
        fixed_deposits[deposit_id].claimed = true
    else:
        penalty_applied = true
        var proportional_interest = depo.full_interest * (float(actual_days) / total_days)
        interest = round((proportional_interest * (1.0 - PENALTY_RATE_EARLY_WITHDRAWAL)) * 100) / 100.0
        withdrawal_fee = round((depo.amount * WITHDRAWAL_FEE_RATE) * 100) / 100.0
        principal_return = round((depo.amount - withdrawal_fee) * 100) / 100.0

    Blogger.money += principal_return + interest
    Blogger.money = round(Blogger.money * 100) / 100.0  # ✅ 保持玩家金钱精度

    fixed_deposits.erase(deposit_id)

    return {
        "success": true,
        "principal": round(depo.amount * 100) / 100.0,
        "principal_returned": principal_return,
        "interest": interest,
        "withdrawal_fee": withdrawal_fee,
        "penalty_applied": penalty_applied,
        "end_date": depo.end_date,
        "withdraw_date": current_date
    }
## ———————— 每日结算（处理活期利息累积） ————————

# 🆕 每日结算活期利息 → 累积到 savings_balance_interest
func day_fs():
    if savings_balance <= 0:
        return
    
    var daily_interest = round((savings_balance * (SAVINGS_DAILY_RATE / 100.0)) * 100) / 100.0
    
    if daily_interest > 0:
        savings_balance_interest += daily_interest
        savings_balance_interest = round(savings_balance_interest * 100) / 100.0  # ✅ 累积也要保留精度
        #print("📅 活期日利息累积: +%.2f 元，当前累计利息: %.2f 元" % [daily_interest, savings_balance_interest])
## ———————— 每年结算（新增：活期年利息结算） ————————

# 🆕 每年结算一次活期利息（复利），由你连接到年度信号调用
# 将全年累计的 savings_balance_interest 加入 savings_balance
func year_fs():
    if savings_balance_interest <= 0:
        print("ℹ️ 活期年利息结算: 无累计利息。")
        return
    
    savings_balance += savings_balance_interest
    savings_balance = round(savings_balance * 100) / 100.0
    #print("🎉 活期年利息结算: +%.2f 元已加入本金，当前活期余额: %.2f 元" % [savings_balance_interest, savings_balance])
    savings_balance_interest = 0.0
# ========== 🧰 工具方法（供UI或其他系统调用） ========== #
# 格式化金额显示（保留两位小数，带千分位可选）
func format_money(amount: float) -> String:
    return "%.2f" % amount

func get_total_bank_assets() -> float:  # ✅ 返回 float
    var total = savings_balance 
    for id in fixed_deposits:
        total += fixed_deposits[id].amount
    return round(total * 100) / 100.0

func get_active_fixed_count() -> int:
    return fixed_deposits.size()

func get_fixed_deposit_info(deposit_id: int) -> Dictionary:
    if fixed_deposits.has(deposit_id):
        return fixed_deposits[deposit_id].duplicate()
    return {}

func get_all_fixed_deposits() -> Array:
    var today = Utils.format_date()
    var list = []
    for id in fixed_deposits:
        var depo = fixed_deposits[id]
        var days_diff = Utils.calculate_new_game_time_difference(depo.end_date, today, false)
        list.append({
            "id": id,
            "amount": round(depo.amount * 100) / 100.0,           # ✅
            "rate_percent": depo.total_rate_percent,
            "full_interest": round(depo.full_interest * 100) / 100.0,  # ✅
            "end_date": depo.end_date,
            "is_matured": days_diff >= 0,
            "claimed": depo.claimed,
            "days_left": -days_diff if days_diff < 0 else 0
        })
    return list

# 获取所有定期存款记录（已按到期时间排序，最近到期在前）
func get_all_fixed_deposits_sorted() -> Array:
    var today = Utils.format_date()
    var list = []
    
    for id in fixed_deposits:
        var depo = fixed_deposits[id]
        var days_diff = Utils.calculate_new_game_time_difference(depo.end_date, today, false)
        list.append({
            "id": id,
            "amount": depo.amount,
            "rate_percent": depo.total_rate_percent,
            "full_interest": depo.full_interest,
            "end_date": depo.end_date,
            "is_matured": days_diff >= 0,
            "claimed": depo.claimed,
            "days_left": -days_diff if days_diff < 0 else 0,
            "status_text": _get_deposit_status_text(days_diff, depo.claimed),
            "interest_preview": depo.full_interest  # ✅ 直接使用预存值
        })
    
    list.sort_custom(_sort_by_days_left)
    return list

# ========== 🔐 私有方法（内部使用，不对外暴露） ========== #
func _float_le(a: float, b: float) -> bool:
    return a - b <= 0.005  # a <= b（容忍误差）
    
func _round2(value: float) -> float:
    return round(value * 100.0) / 100.0

    
func _add_days_to_date(start_date: String, days: int) -> String:
    if days == 0:
        return start_date
    
    var current = start_date
    for i in range(days + 10):
        var candidate = _next_day(current)
        var diff = Utils.calculate_new_game_time_difference(start_date, candidate, false)
        if diff == days:
            return candidate
        current = candidate
    
    push_error("日期推进失败: %s + %d 天" % [start_date, days])
    return start_date

func _next_day(date_str: String) -> String:
    var parts = date_str.split("-")
    var y = int(parts[0])
    var m = int(parts[1])
    var w = int(parts[2])
    var d = int(parts[3])
    
    d += 1
    if d > 7:
        d = 1
        w += 1
        if w > 4:
            w = 1
            m += 1
            if m > 12:
                m = 1
                y += 1
    
    return "%d-%d-%d-%d" % [y, m, w, d]

func _calculate_full_interest(amount: float, rate_percent: float) -> float:  # ✅ 参数和返回值改为 float
    return round((amount * (rate_percent / 100.0)) * 100) / 100.0

func _get_deposit_status_text(days_diff: int, claimed: bool) -> String:
    if days_diff >= 0:
        return "已到期" if not claimed else "利息已结算"
    else:
        return "未到期"

func _sort_by_days_left(a, b):
    return a.days_left > b.days_left
