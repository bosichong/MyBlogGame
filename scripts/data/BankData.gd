class_name BankData

# 银行数据存储类
# 注意：所有银行操作逻辑在 BankSystem.gd 中实现

var savings_balance: float = 0.0
var savings_interest: float = 0.0
var fixed_deposits: Dictionary = {}
var next_deposit_id: int = 1

var deposit_history: Array[Dictionary] = []
var withdraw_history: Array[Dictionary] = []

signal balance_changed(new_balance: float)
signal deposit_made(amount: float, deposit_type: String)
signal withdrawal_made(amount: float)
signal interest_earned(amount: float)

# ===== 数据访问方法 =====

func get_total_assets() -> float:
    var total = savings_balance
    for deposit_id in fixed_deposits:
        total += fixed_deposits[deposit_id].amount
    return total