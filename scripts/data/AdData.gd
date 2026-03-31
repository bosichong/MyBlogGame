class_name AdData

var current_ad_type: String = "文字广告"
var is_registered: bool = true
var is_under_review: bool = false
var is_approved: bool = false
var review_days: int = 0

var pending_commission: float = 0.0
var settled_commission: float = 0.0
var total_commission: float = 0.0

var ad_statistics: Array[Dictionary] = []

signal ad_type_changed(new_type: String)
signal registration_status_changed(approved: bool)
signal commission_earned(amount: float)
signal commission_settled(amount: float)

# ===== 辅助方法 =====

func set_ad_type(ad_type: String):
	current_ad_type = ad_type
	emit_signal("ad_type_changed", ad_type)

func register_for_review():
	is_registered = true
	is_under_review = true
	is_approved = false
	review_days = 0
	emit_signal("registration_status_changed", false)

func process_review():
	if is_under_review:
		review_days += 1
		if review_days >= 7:  # 假设审核需要7天
			is_under_review = false
			is_approved = true
			emit_signal("registration_status_changed", true)

func add_pending_commission(amount: float):
	pending_commission += amount
	emit_signal("commission_earned", amount)

func settle_commission() -> float:
	var settled = pending_commission
	pending_commission = 0.0
	settled_commission += settled
	total_commission += settled
	emit_signal("commission_settled", settled)
	return settled

func get_total_earnings() -> float:
	return settled_commission + pending_commission

func record_ad_stat(date: String, views: int, clicks: int, commission: float):
	ad_statistics.append({
		"date": date,
		"ad_type": current_ad_type,
		"views": views,
		"clicks": clicks,
		"commission": commission,
		"timestamp": Time.get_unix_time_from_system()
	})

func get_recent_stats(days: int = 7) -> Array[Dictionary]:
	var recent_stats = []
	var cutoff_time = Time.get_unix_time_from_system() - (days * 24 * 3600)

	for stat in ad_statistics:
		if stat["timestamp"] >= cutoff_time:
			recent_stats.append(stat)

	return recent_stats
