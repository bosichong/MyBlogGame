extends Node



# 创建了 日、周、月、年的统计记录数组
# 统计记录包括 日期，访问量

var t_d: Array:
    get:
        return GlobalDataManager.get_statistics().daily_stats if GlobalDataManager else []
    set(value):
        if GlobalDataManager:
            GlobalDataManager.get_statistics().daily_stats = value

var t_w: Array:
    get:
        return GlobalDataManager.get_statistics().weekly_stats if GlobalDataManager else []
    set(value):
        if GlobalDataManager:
            GlobalDataManager.get_statistics().weekly_stats = value

var t_m: Array:
    get:
        return GlobalDataManager.get_statistics().monthly_stats if GlobalDataManager else []
    set(value):
        if GlobalDataManager:
            GlobalDataManager.get_statistics().monthly_stats = value

var t_y: Array:
    get:
        return GlobalDataManager.get_statistics().yearly_stats if GlobalDataManager else []
    set(value):
        if GlobalDataManager:
            GlobalDataManager.get_statistics().yearly_stats = value



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.
