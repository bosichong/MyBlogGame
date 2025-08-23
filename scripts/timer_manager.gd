## 全局的时间控制管理器
extends Node


# 游戏时间
var current_day = 1      # 当前天，从1开始
var current_week = 1     # 当前周
var current_month = 1    # 当前月
var current_quarter = 1  # 当前季度
var current_year = 2000  # 当前年，从2000年开始
const days_in_week = 7     # 每周7天
const weeks_in_month = 4   # 每月4周
const months_in_quarter = 3 # 每季度3个月
const quarters_in_year = 4  # 每年4季度
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
	current_day +=1
	# 检查是否到新的一周
	if current_day > days_in_week:
		current_day = 1
		current_week += 1
		if current_week > weeks_in_month:
			current_week = 1
			current_month += 1
			
			# 检查是否到新的一季度（每3个月为1季度）
			if current_month % months_in_quarter == 1 :  # 新季度开始
				current_quarter = (current_month - 1) / months_in_quarter + 1
				if current_quarter > quarters_in_year :
					current_quarter = 1
				emit_signal("quarter_passed")
			
			# 检查是否到新的一年（每年12）
			if current_month > months_in_year:
				current_month = 1
				current_year += 1
				emit_signal("year_passed")
			emit_signal("month_passed")	
		emit_signal("week_passed")
	emit_signal("day_passed")
	
	# 广告联盟佣金结算
	if current_week == 4 and current_day == 7:
		emit_signal("s_ad_money_1")
	if current_week == 2 and current_day == 1:
		emit_signal("s_ad_money_2")
	
	

## 游戏中时间类型的时间，对比时间时间	
func is_time_match(config: Dictionary) -> bool:
	var y_values = config.get("y", [])
	var m_values = config.get("m", [])
	var w_values = config.get("w", [])
	var d_values = config.get("d", [])

	# 检查年
	if y_values.size() > 0 and y_values[0] != 0:
		if not is_match(current_year, y_values):
			return false

	# 检查月
	if m_values.size() > 0 and m_values[0] != 0:
		if not is_match(current_month, m_values):
			return false

	# 检查周
	if w_values.size() > 0 and w_values[0] != 0:
		if not is_match(current_week, w_values):
			return false

	# 检查日
	if d_values.size() > 0 and d_values[0] != 0:
		if not is_match(current_day, d_values):
			return false

	return true


# 辅助函数：检查值是否在数组中
func is_match(value: int, array: Array) -> bool:
	for v in array:
		if v == value:
			return true
	return false
