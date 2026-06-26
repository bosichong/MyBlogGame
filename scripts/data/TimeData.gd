class_name TimeData

## 游戏起始时间相关常量（修改此处即可调整游戏起始时间）
## 游戏的默认启动时间 2001年12月4周7天
const GAME_START_YEAR: int = 2005
const GAME_START_MONTH: int = 12
const GAME_START_WEEK: int = 1
const GAME_START_DAY: int = 1

## 云主机和域名免费时长（年）
const FREE_DURATION_YEARS: int = 1

var current_year: int = GAME_START_YEAR
var current_month: int = GAME_START_MONTH
var current_week: int = GAME_START_WEEK
var current_day: int = GAME_START_DAY
var current_quarter: int = 1

var time_scale: float = 1.0
var is_paused: bool = false

## 游戏起始日期（格式：年-月-周-日）
var game_start_date: String = get_game_start_date_str()

## 当前日期字符串
var current_date_str: String = get_game_start_date_str()

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

## 获取从游戏开始到现在的总天数
func get_total_days() -> int:
    return (current_year - GAME_START_YEAR) * 12 * 4 * 7 + \
           (current_month - 1) * 4 * 7 + \
           (current_week - 1) * 7 + \
           current_day

func get_formatted_date() -> String:
    return "%d-%d-%d-%d" % [current_year, current_month, current_week, current_day]

## 获取游戏起始日期字符串（格式：年-月-周-日）
static func get_game_start_date_str() -> String:
    return "%d-%d-%d-%d" % [GAME_START_YEAR, GAME_START_MONTH, GAME_START_WEEK, GAME_START_DAY]

## 获取起始时间 N 年后的日期字符串（用于域名/主机到期时间计算）
## 简化处理：月份/周/日保持与起始时间一致
static func get_date_after_years(years: int) -> String:
    return "%d-%d-%d-%d" % [GAME_START_YEAR + years, GAME_START_MONTH, GAME_START_WEEK, GAME_START_DAY]

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
        if current_quarter > QUARTERS_IN_YEAR:
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
