class_name TimeData

var current_year: int = 2000
var current_month: int = 1
var current_week: int = 1
var current_day: int = 1
var current_quarter: int = 1

var time_scale: float = 1.0
var is_paused: bool = false

var game_start_date: String = "2000-1-1-1"
var current_date_str: String = "2000-1-1-1"

signal day_passed
signal week_passed
signal month_passed
signal quarter_passed
signal year_passed
signal date_changed(new_date: String)

# 常量
const DAYS_IN_WEEK = 7
const WEEKS_IN_MONTH = 4
const MONTHS_IN_YEAR = 12
const QUARTERS_IN_YEAR = 4

# ===== 辅助方法 =====

func get_total_days() -> int:
    return (current_year - 2000) * 12 * 4 * 7 + \
           (current_month - 1) * 4 * 7 + \
           (current_week - 1) * 7 + \
           current_day

func get_formatted_date() -> String:
    return "%d-%d-%d-%d" % [current_year, current_month, current_week, current_day]

func advance_day():
    current_day += 1
    current_date_str = get_formatted_date()

    # 检查是否跨周
    if current_day > DAYS_IN_WEEK:
        current_day = 1
        advance_week()

    emit_signal("day_passed")
    emit_signal("date_changed", current_date_str)

func advance_week():
    current_week += 1

    # 检查是否跨月
    if current_week > WEEKS_IN_MONTH:
        current_week = 1
        advance_month()

    emit_signal("week_passed")

func advance_month():
    current_month += 1

    # 检查是否跨年
    if current_month > MONTHS_IN_YEAR:
        current_month = 1
        advance_year()

    # 检查是否跨季度（每3个月为1季度）
    if current_month % 3 == 1:
        current_quarter = (current_month - 1) / 3 + 1
        if current_quarter > quarters_in_year:
            current_quarter = 1
        emit_signal("quarter_passed")

    emit_signal("month_passed")

func advance_year():
    current_year += 1
    emit_signal("year_passed")

func set_date(year: int, month: int, week: int, day: int):
    current_year = year
    current_month = month
    current_week = week
    current_day = day
    current_date_str = get_formatted_date()
    emit_signal("date_changed", current_date_str)

func set_paused(paused: bool):
    is_paused = paused

func set_time_scale(scale: float):
    time_scale = scale