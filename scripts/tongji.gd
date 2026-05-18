## 统计接口 - 提供便捷的统计查询
## 使用方式：通过 /root/Tongji 节点访问
extends Node

# 缓存 ViewsStatsManager 实例
var _stats_manager: ViewsStatsManager = null

func _ready() -> void:
    # 初始化统计管理器
    _stats_manager = ViewsStatsManager.new()
    # 延迟加载保存的统计数据（确保 GDManager 数据已就绪）
    call_deferred("_load_saved_stats")

func _load_saved_stats() -> void:
    # 从 StatisticsData 加载保存的统计（兼容旧系统）
    var stats_data = GDManager.get_statistics() if GDManager else null
    if stats_data:
        if stats_data.daily_stats.size() > 0:
            var saved_data = {
                "daily_stats": stats_data.daily_stats,
                "weekly_stats": stats_data.weekly_stats,
                "monthly_stats": stats_data.monthly_stats,
                "yearly_stats": stats_data.yearly_stats,
            }
            _stats_manager.load_all_stats(saved_data)

## 获取统计管理器实例
func get_stats_manager() -> ViewsStatsManager:
    return _stats_manager

## 设置统计管理器（从外部注入，如 GDManager）
func set_stats_manager(manager: ViewsStatsManager) -> void:
    _stats_manager = manager

## ==================== 便捷查询接口 ====================

## 获取最近7天每天的访问量数组 [day1, day2, ..., day7]
func get_weekly_views() -> Array:
    if not _stats_manager:
        return []
    var trend = _stats_manager.get_trend(7)
    var result = []
    for day in trend:
        result.append(day.get("views", 0))
    return result

## 获取最近30天趋势数据
func get_trend(days: int = 30) -> Array:
    if not _stats_manager:
        return []
    return _stats_manager.get_trend(days)

## 获取今日访问量
func get_today_views() -> int:
    if not _stats_manager:
        return 0
    return _stats_manager.data.get_today_views()

## 获取最近N天总访问量
func get_recent_views(days: int) -> int:
    if not _stats_manager:
        return 0
    return _stats_manager.data.get_recent_views(days)

## 获取总访问量
func get_total_views() -> int:
    if not _stats_manager:
        return 0
    return _stats_manager.data.get_total_views()

## 获取统计摘要（完整数据）
func get_summary() -> Dictionary:
    if not _stats_manager:
        return {}
    return _stats_manager.get_summary()

## 获取来源占比
func get_source_ratio() -> Dictionary:
    if not _stats_manager:
        return {}
    return _stats_manager.get_source_ratio()

## 获取增长率
func get_growth_rate(days: int = 7) -> float:
    if not _stats_manager:
        return 0.0
    return _stats_manager.get_growth_rate(days)

## ==================== 记录接口 ====================

## 记录每日统计（通常由日程自动调用）
func record_daily(date: String, views: int, posts_count: int, sources: Dictionary) -> void:
    if not _stats_manager:
        return
    _stats_manager.record_daily(date, views, posts_count, sources)

## 记录周统计
func record_weekly(year: int, week: int) -> void:
    if not _stats_manager:
        return
    _stats_manager.record_weekly(year, week)

## 记录月统计
func record_monthly(year: int, month: int) -> void:
    if not _stats_manager:
        return
    _stats_manager.record_monthly(year, month)

## 记录年统计
func record_yearly(year: int) -> void:
    if not _stats_manager:
        return
    _stats_manager.record_yearly(year)

## ==================== 存储接口 ====================

## 获取所有统计数据（用于保存）
func get_all_stats() -> Dictionary:
    if not _stats_manager:
        return {}
    return _stats_manager.get_all_stats()

## 加载统计数据
func load_all_stats(stats_data: Dictionary) -> void:
    if not _stats_manager:
        return
    _stats_manager.load_all_stats(stats_data)
