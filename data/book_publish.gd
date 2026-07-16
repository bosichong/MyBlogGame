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
		"min_write_days": 100,          # 最少发布篇数
		"max_write_days": 100,          # 最多发布篇数
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

## 计算写作质量（基于已发布篇数和文学能力值）
func calculate_write_quality(write_days: int, literature_value: float) -> float:
	var day_factor = clamp(float(write_days) / 10.0, 0.5, 1.0)
	var lit_factor = literature_value / 100.0
	return day_factor * lit_factor

## 计算月销售收入（sales_months: 已销售月数，0-indexed）
func calculate_monthly_sales(book: Dictionary, sales_months: int) -> int:
	if not book.get("published", false) or sales_months >= 12:
		return 0
	
	var write_quality = book.get("write_quality", 0.5)
	var peak_income = 100000 + 100000 * write_quality
	
	var income = 0.0
	if sales_months < 4:
		income = peak_income * pow(float(sales_months + 1) / 4.0, 2)
	elif sales_months < 6:
		income = peak_income * (1.0 + randf_range(-0.1, 0.1))
	else:
		var decline = max(1.0 - float(sales_months - 6) / 6.0, 0.0)
		income = peak_income * pow(decline, 1.5) * (0.8 + randf() * 0.4)
	
	return int(max(income, 0))

## 获取书籍销售状态描述
func get_book_sales_status(book: Dictionary) -> String:
	var sales_months = book.get("sales_months", 0)
	
	if sales_months >= 12:
		return "已停售"
	elif sales_months < 4:
		return "热销上升期"
	elif sales_months < 6:
		return "销售高峰期"
	else:
		return "销售衰退期"

