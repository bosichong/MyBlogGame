## 访问量修饰器基类
## 所有访问量增加方式都继承此类
class_name ViewsModifier
extends RefCounted

## 修饰器唯一标识
var modifier_name: String = ""

## 显示名称（用于UI显示）
var display_name: String = ""

## 描述说明
var description: String = ""

## 优先级（数值越小越先执行）
## 0-99: 基础计算
## 100-199: 时间衰减
## 200-299: 正向加成
## 300-399: 负向限制
var priority: int = 0

## 是否启用
var enabled: bool = true

## 修饰器类型
enum Type {
	BASE,    # 基础计算
	DECAY,   # 时间衰减
	BOOST,   # 正向加成
	LIMIT    # 负向限制
}
var type: Type = Type.BASE

## 应用修饰器
## views: 当前访问量
## post: 文章数据
## blogger: 博主数据
## 返回: 修改后的访问量
func apply(views: int, post: Dictionary, blogger: Dictionary) -> int:
	return views

## 获取修饰器信息（用于UI显示）
func get_info() -> Dictionary:
	return {
		"name": modifier_name,
		"display_name": display_name,
		"description": description,
		"priority": priority,
		"enabled": enabled,
		"type": type
	}

## 获取调试信息
func get_debug_info(views_before: int, views_after: int) -> Dictionary:
	return {
		"name": display_name,
		"before": views_before,
		"after": views_after,
		"change": views_after - views_before
	}
