class_name BankData extends Resource

var savings_balance: float = 0.0
var savings_interest: float = 0.0
var fixed_deposits: Dictionary = {}
var next_deposit_id: int = 1

# 利率常量
const SAVINGS_DAILY_RATE = 0.01
const FIXED_RATE_HALF_YEAR = 2.301
const FIXED_RATE_ONE_YEAR = 4.603
const FIXED_RATE_THREE_YEARS = 13.809

var deposit_history: Array[Dictionary] = []
var withdraw_history: Array[Dictionary] = []

signal balance_changed(new_balance: float)
signal deposit_made(amount: float, deposit_type: String)
signal withdrawal_made(amount: float)
signal interest_earned(amount: float)

# ===== 辅助方法 =====

func add_savings(amount: float):
    savings_balance += amount
    deposit_history.append({
        "id": next_deposit_id,
        "type": "savings",
        "amount": amount,
        "timestamp": Time.get_unix_time_from_system()
    })
    emit_signal("balance_changed", savings_balance)
    emit_signal("deposit_made", amount, "savings")

func withdraw_savings(amount: float) -> bool:
    if savings_balance >= amount:
        savings_balance -= amount
        withdraw_history.append({
            "id": next_deposit_id,
            "type": "savings",
            "amount": amount,
            "timestamp": Time.get_unix_time_from_system()
        })
        emit_signal("balance_changed", savings_balance)
        emit_signal("withdrawal_made", amount)
        return true
    return false

func add_fixed_deposit(amount: float, duration_months: int) -> int:
    var deposit_id = next_deposit_id
    next_deposit_id += 1

    fixed_deposits[deposit_id] = {
        "id": deposit_id,
        "amount": amount,
        "duration_months": duration_months,
        "start_date": Time.get_unix_time_from_system(),
        "rate": get_fixed_rate(duration_months)
    }

    deposit_history.append({
        "id": deposit_id,
        "type": "fixed",
        "amount": amount,
        "duration_months": duration_months,
        "timestamp": Time.get_unix_time_from_system()
    })

    emit_signal("deposit_made", amount, "fixed")
    return deposit_id

func get_fixed_rate(duration_months: int) -> float:
    if duration_months <= 6:
        return FIXED_RATE_HALF_YEAR
    elif duration_months <= 12:
        return FIXED_RATE_ONE_YEAR
    else:
        return FIXED_RATE_THREE_YEARS

func calculate_daily_interest() -> float:
    var daily_interest = savings_balance * (SAVINGS_DAILY_RATE / 100.0)
    savings_interest += daily_interest
    emit_signal("interest_earned", daily_interest)
    return daily_interest

func collect_interest():
    if savings_interest > 0:
        savings_balance += savings_interest
        var interest_collected = savings_interest
        savings_interest = 0
        emit_signal("balance_changed", savings_balance)
        return interest_collected
    return 0.0

func get_total_assets() -> float:
    var total = savings_balance
    for deposit_id in fixed_deposits:
        total += fixed_deposits[deposit_id].amount
    return total