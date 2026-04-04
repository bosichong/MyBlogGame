## 全局的时间控制管理器
extends Node


# 游戏时间
var current_day: int:
	get:
		return GDManager.get_time().current_day if GDManager else 1
	set(value):
		if GDManager:
			GDManager.get_time().current_day = value

var current_week: int:
	get:
		return GDManager.get_time().current_week if GDManager else 1
	set(value):
		if GDManager:
			GDManager.get_time().current_week = value

var current_month: int:
	get:
		return GDManager.get_time().current_month if GDManager else 1
	set(value):
		if GDManager:
			GDManager.get_time().current_month = value

var current_quarter: int:
	get:
		return GDManager.get_time().current_quarter if GDManager else 1
	set(value):
		if GDManager:
			GDManager.get_time().current_quarter = value

var current_year: int:
	get:
		return GDManager.get_time().current_year if GDManager else 2005
	set(value):
		if GDManager:
			GDManager.get_time().current_year = value

const days_in_week = 7     # 每周7天
const weeks_in_month = 4   # 每月4周
const months_in_quarter = 3 # 每季度3个月
const quarters_in_year = 4  # 每年4季度
const six_months = 6 # 半年
const months_in_year = 12 # 每年12个月
## 创建一个系统的时间timer
var timer : Timer
var time_stop : bool = false # 时间是否停止

# 信号
signal day_passed
signal week_passed
signal month_passed
signal quarter_passed
signal year_passed


signal s_ad_money_1 # 每月最后一天结算佣金
signal s_ad_money_2 # 每月第二周第一天发放佣金


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer = Timer.new()
	timer.wait_time = 1 # *秒模拟一天
	add_child(timer)
	timer.timeout.connect(_on_day_passed)
	
	
	

	
	
# 定时器触发
## 每天更新事件，游戏的核心更新信号量
func _on_day_passed():
	# 如果时间已停止（游戏结束），不再处理
	if time_stop:
		return
	
	if GDManager:
		GDManager.advance_day()
		var time_data = GDManager.get_time()

		# 广告联盟佣金结算
		if time_data.current_week == 4 and time_data.current_day == 7:
			emit_signal("s_ad_money_1")
		if time_data.current_week == 2 and time_data.current_day == 1:
			emit_signal("s_ad_money_2")
	
	

## 游戏中时间类型的时间，对比时间时间
func is_time_match(config: Dictionary) -> bool:
	if not GDManager:
		return false

	var time_data = GDManager.get_time()
	var y_values = config.get("y", [])
	var m_values = config.get("m", [])
	var w_values = config.get("w", [])
	var d_values = config.get("d", [])

	# 检查年
	if y_values.size() > 0 and y_values[0] != 0:
		if not is_match(time_data.current_year, y_values):
			return false

	# 检查月
	if m_values.size() > 0 and m_values[0] != 0:
		if not is_match(time_data.current_month, m_values):
			return false

	# 检查周
	if w_values.size() > 0 and w_values[0] != 0:
		if not is_match(time_data.current_week, w_values):
			return false

	# 检查日
	if d_values.size() > 0 and d_values[0] != 0:
		if not is_match(time_data.current_day, d_values):
			return false

	return true


# 辅助函数：检查值是否在数组中
func is_match(value: int, array: Array) -> bool:
	for v in array:
		if v == value:
			return true
	return false


# 安全地停止 Timer
func stop_timer():
	if not TimerManager.time_stop:
		TimerManager.timer.stop()
		TimerManager.time_stop = true

# 安全地启动 Timer
func start_timer():
	if TimerManager.time_stop:
		TimerManager.timer.start()
		TimerManager.time_stop = false
