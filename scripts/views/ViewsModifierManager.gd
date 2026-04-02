## 访问量修饰器管理器
## 负责注册、排序、应用所有修饰器
class_name ViewsModifierManager
extends RefCounted

var modifiers: Array = []
var debug_mode: bool = false

## 注册修饰器
func register(modifier: ViewsModifier) -> void:
	modifiers.append(modifier)
	_sort()

## 注销修饰器（按名称）
func unregister(name: String) -> bool:
	for i in range(modifiers.size()):
		if modifiers[i].modifier_name == name:
			modifiers.remove_at(i)
			return true
	return false

## 获取修饰器（按名称）
func get_modifier(name: String) -> ViewsModifier:
	for m in modifiers:
		if m.modifier_name == name:
			return m
	return null

## 启用/禁用修饰器
func set_enabled(name: String, enabled: bool) -> bool:
	var m = get_modifier(name)
	if m:
		m.enabled = enabled
		return true
	return false

## 按优先级排序
func _sort() -> void:
	modifiers.sort_custom(func(a, b): return a.priority < b.priority)

## 应用所有修饰器
## 返回包含访问量和调试日志的字典
func apply_all(base_views: int, post: Dictionary, blogger: Dictionary) -> Dictionary:
	var views = base_views
	var debug_log = []
	
	for m in modifiers:
		if m.enabled:
			var before = views
			views = m.apply(views, post, blogger)
			if debug_mode and views != before:
				debug_log.append(m.get_debug_info(before, views))
	
	return {
		"views": views,
		"debug_log": debug_log
	}

## 获取所有修饰器信息
func get_all_info() -> Array:
	var result = []
	for m in modifiers:
		result.append(m.get_info())
	return result

## 获取启用的修饰器数量
func get_enabled_count() -> int:
	var count = 0
	for m in modifiers:
		if m.enabled:
			count += 1
	return count
