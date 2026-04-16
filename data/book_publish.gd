extends Node

## 出版畅销书数据配置
## 解锁条件：文学能力 ≥90（测试版）

var books = [
	{
		"name": "畅销书写作",
		"description": "文学能力达到最高境界后，可以开始创作畅销书",
		"unlock_condition": "literature_value_ge_90",
		"type": "出版",
		
		# 写作阶段参数（游戏时间）
		"stamina_per_write": 50,        # 每次写作消耗体力
		"min_write_days": 5,            # 最少发布篇数（测试用）
		"max_write_days": 10,          # 最多发布篇数（测试用）
		"progress_per_day": 1,          # 每天写作进度
		
		# 出版流程阶段（游戏时间）
		"phases": [
			{
				"name": "写作阶段",
				"duration_type": "dynamic",
				"min_duration": 168,
				"max_duration": 336,
				"description": "持续写作，积累内容进度",
			},
			{
				"name": "编辑修改",
				"duration_type": "fixed",
				"duration": 5,
				"description": "编辑审核并提出修改意见",
			},
			{
				"name": "出版社审核",
				"duration_type": "fixed",
				"duration": 7,
				"description": "出版社最终审核确认",
			},
			{
				"name": "出版上市",
				"duration_type": "instant",
				"description": "书籍正式出版上市",
			}
		],
		
		# 出版收益参数
		"publish_reward": 50000,         # 出版一次性收益
		"reputation_reward": 1000,       # 声望奖励
		
		# 销售持续收入参数
		"sales_duration_months": 12,     # 销售周期12个月（1年，测试用）
		"peak_month": 6,                 # 峰值月份（半年）
		"decline_start_month": 9,        # 开始下降月份（9个月）
		
		# 峰值收入（文学值≥90时）
		"peak_income_max": 200000,       # 峰值最高月收入
		"peak_income_min": 100000,       # 峰值最低月收入
		
		# 状态
		"isVisible": false,
		"disabled": true,
	},
]

## 当前书籍状态（运行时数据）
var current_book_state = {
	"is_writing": false,
	"book_id": "",                    # 书籍唯一ID
	"book_name": "",                  # 书名
	"current_phase": 0,               # 当前阶段
	"write_days": 0,                  # 写作天数
	"write_quality": 0,               # 写作质量（影响销售收入）
	"total_progress": 0,
	"phase_day": 0,
	"completed": false,
	"publisher": {},                  # 出版商信息
	
	# 销售相关
	"published": false,               # 是否已出版
	"publish_date": "",               # 出版日期
	"sales_months": 0,                # 已销售月数
	"total_sales_income": 0,          # 累计销售收入
}

## 已出版书籍列表（可同时有多本书在销售）
var published_books: Array = []

## 生成书籍ID
func generate_book_id() -> String:
	return "book_" + str(Time.get_ticks_msec()) + "_" + str(randi() % 10000)

## 计算写作质量（基于写作天数和文学能力值）
func calculate_write_quality(write_days: int, literature_value: float) -> float:
	# 写作天数系数：最少168天，最多336天
	var day_factor = clamp(float(write_days) / 336.0, 0.5, 1.0)
	
	# 文学能力系数：0-100
	var lit_factor = literature_value / 100.0
	
	# 综合质量：0.0-1.0
	return day_factor * lit_factor

## 计算月销售收入
func calculate_monthly_sales(book: Dictionary, current_month: int) -> int:
	if not book.get("published", false):
		return 0
	
	var sales_months = book.get("sales_months", 0)
	var max_months = 36  # 3年
	
	# 超过3年，不再有收入
	if sales_months >= max_months:
		return 0
	
	var write_quality = book.get("write_quality", 0.5)
	var literature_value = book.get("literature_value", 50)
	
	# 峰值收入范围
	var peak_min = 100000
	var peak_max = 200000
	
	# 根据文学值和写作质量计算峰值
	var quality_peak = peak_min + (peak_max - peak_min) * write_quality
	
	# 收入曲线
	var income = 0.0
	var month_ratio = float(sales_months) / float(max_months)
	
	if sales_months < 12:
		# 0-12月：上升期
		var growth_rate = float(sales_months) / 12.0
		income = quality_peak * growth_rate * growth_rate  # 二次增长
	elif sales_months < 18:
		# 12-18月：峰值期
		var peak_factor = 1.0 + randf_range(-0.1, 0.1)  # 波动±10%
		income = quality_peak * peak_factor
	else:
		# 18-36月：下降期
		var decline_rate = 1.0 - (float(sales_months - 18) / 18.0)
		decline_rate = max(decline_rate, 0.0)
		# 指数衰减
		income = quality_peak * pow(decline_rate, 1.5)
		# 添加随机波动
		income *= (0.8 + randf() * 0.4)  # 波动±20%
	
	return int(max(income, 0))

## 获取书籍销售状态描述
func get_book_sales_status(book: Dictionary) -> String:
	var sales_months = book.get("sales_months", 0)
	
	if sales_months >= 36:
		return "已停售"
	elif sales_months < 12:
		return "热销上升期"
	elif sales_months < 18:
		return "销售高峰期"
	else:
		return "销售衰退期"

## 更新所有书籍的销售状态（每月调用）
func update_all_books_sales() -> Dictionary:
	var total_income = 0
	var sales_report = []
	
	for book in published_books:
		if not book.get("published", false):
			continue
		
		var sales_months = book.get("sales_months", 0)
		if sales_months >= 36:
			continue
		
		# 计算本月收入
		var monthly_income = calculate_monthly_sales(book, sales_months)
		
		# 更新书籍状态
		book.sales_months = sales_months + 1
		book.total_sales_income = book.get("total_sales_income", 0) + monthly_income
		total_income += monthly_income
		
		sales_report.append({
			"book_name": book.get("book_name", "未知"),
			"monthly_income": monthly_income,
			"total_income": book.total_sales_income,
			"sales_months": book.sales_months,
			"status": get_book_sales_status(book)
		})
	
	return {
		"total_income": total_income,
		"sales_report": sales_report
	}