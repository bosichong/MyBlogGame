class_name StatisticsData

var daily_stats: Array[Dictionary] = []
var weekly_stats: Array[Dictionary] = []
var monthly_stats: Array[Dictionary] = []
var yearly_stats: Array[Dictionary] = []

var total_posts: int = 0
var paid_posts: int = 0
var free_posts: int = 0

var total_income: float = 0.0
var ad_income: float = 0.0
var post_income: float = 0.0
var bank_income: float = 0.0

signal stats_updated

# ===== 辅助方法 =====

func record_daily_stat(date: String, views: int, income: float):
	var stat_entry = {
		"date": date,
		"views": views,
		"income": income,
		"posts": 0,
		"timestamp": Time.get_unix_time_from_system()
	}

	# 更新或创建今日统计
	var existing_index = -1
	for i in range(daily_stats.size()):
		if daily_stats[i]["date"] == date:
			existing_index = i
			break

	if existing_index >= 0:
		daily_stats[existing_index]["views"] += views
		daily_stats[existing_index]["income"] += income
	else:
		daily_stats.append(stat_entry)

	# 保持最近30天的记录
	if daily_stats.size() > 30:
		daily_stats.pop_front()

	emit_signal("stats_updated")

func record_post(is_paid: bool, income: float = 0.0):
	total_posts += 1
	if is_paid:
		paid_posts += 1
		post_income += income
	else:
		free_posts += 1

	# 更新当日统计
	if not daily_stats.is_empty():
		daily_stats[-1]["posts"] += 1

	emit_signal("stats_updated")

func record_income(source: String, amount: float):
	total_income += amount
	match source:
		"ad":
			ad_income += amount
		"post":
			post_income += amount
		"bank":
			bank_income += amount

	# 更新当日统计
	if not daily_stats.is_empty():
		daily_stats[-1]["income"] += amount

	emit_signal("stats_updated")

func get_daily_average_views(days: int = 7) -> float:
	if daily_stats.is_empty():
		return 0.0

	var total_views = 0
	var count = min(days, daily_stats.size())

	for i in range(count):
		total_views += daily_stats[daily_stats.size() - 1 - i]["views"]

	return float(total_views) / float(count)

func get_daily_average_income(days: int = 7) -> float:
	if daily_stats.is_empty():
		return 0.0

	var total_income_local = 0.0
	var count = min(days, daily_stats.size())

	for i in range(count):
		total_income_local += daily_stats[daily_stats.size() - 1 - i]["income"]

	return total_income_local / float(count)

func get_income_breakdown() -> Dictionary:
	return {
		"total": total_income,
		"ad": ad_income,
		"post": post_income,
		"bank": bank_income
	}

func get_post_breakdown() -> Dictionary:
	return {
		"total": total_posts,
		"paid": paid_posts,
		"free": free_posts
	}
