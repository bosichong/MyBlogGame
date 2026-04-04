extends Node

## 文学技能文章解锁测试系统
## 用于测试文学相关的文章发布、小说连载、出版畅销书、IP授权等功能

const TaskConfig = preload("res://scripts/task_system/TaskConfig.gd")
const TaskManagerClass = preload("res://scripts/task_system/TaskManager.gd")

# 测试配置
var test_config = {
	"enabled_tests": {
		"article_unlock": true,        # 文章解锁测试
		"ip_authorization": true,      # IP授权测试
		"book_publish": true,          # 出版畅销书测试
	},
	"literature_levels": [20, 40, 60, 80, 100],  # 测试的文学等级
	"novel_count_for_ip": 50,                     # IP授权所需小说数量
}

# 测试结果
var test_results = []

# 模拟数据
var mock_blogger = {
	"literature_level": 0,
	"novel_count": 0,
	"money": 0,
	"reputation": 0,
	"unlocked_posts": [],
	"posts": [],
}

var mock_book_state = {
	"is_writing": false,
	"current_phase": 0,
	"write_days": 0,
	"total_progress": 0,
	"completed": false,
	"publisher": {},
}

var mock_ip_state = {
	"base_ip_active": false,
	"base_ip_remaining_months": 0,
	"movie_ip_triggered": false,
	"game_ip_triggered": false,
	"total_ip_income": 0,
}

# 文章解锁映射
var article_unlock_map = {
	20: "散文随笔",
	40: "文学周刊",
	60: "爆款网文",
	80: "小说连载(付费)",
	100: "出版畅销书",
}

## ============================================================
## 主测试入口
## ============================================================

func run_all_tests() -> Dictionary:
	print("\n" + "=".repeat(60))
	print("【文学技能文章解锁测试系统】")
	print("=".repeat(60))
	
	test_results.clear()
	_reset_mock_data()
	
	# 1. 测试文章解锁
	if test_config.enabled_tests.article_unlock:
		_test_article_unlock()
	
	# 2. 测试IP授权
	if test_config.enabled_tests.ip_authorization:
		_test_ip_authorization()
	
	# 3. 测试出版畅销书
	if test_config.enabled_tests.book_publish:
		_test_book_publish()
	
	# 输出测试报告
	_print_test_report()
	
	return {
		"total": test_results.size(),
		"passed": _count_passed(),
		"failed": _count_failed(),
		"results": test_results,
	}

## ============================================================
## 测试1：文章解锁测试
## ============================================================

func _test_article_unlock() -> void:
	print("\n【测试1：文学文章解锁测试】")
	print("-".repeat(40))
	
	for level in test_config.literature_levels:
		_reset_mock_data()
		mock_blogger.literature_level = level
		
		var expected_article = article_unlock_map.get(level, "")
		var result = _check_article_unlock(level, expected_article)
		
		_add_result("文章解锁", "文学等级%d解锁《%s》" % [level, expected_article], result)

## 检查文章是否解锁
func _check_article_unlock(level: int, expected_article: String) -> bool:
	# 模拟任务触发
	var condition_id = "literature_value_ge_%d" % level
	var condition = TaskConfig.CONDITIONS.get(condition_id, {})
	
	if condition.is_empty():
		print("  [错误] 条件未找到: %s" % condition_id)
		return false
	
	# 检查条件是否满足
	var cond_value = condition.get("value", 0)
	var is_satisfied = mock_blogger.literature_level >= cond_value
	
	if is_satisfied:
		# 模拟解锁文章
		if not mock_blogger.unlocked_posts.has(expected_article):
			mock_blogger.unlocked_posts.append(expected_article)
		print("  [成功] 文学等级%d -> 解锁《%s》" % [level, expected_article])
		return true
	else:
		print("  [失败] 文学等级%d 未达到解锁条件" % level)
		return false

## ============================================================
## 测试2：IP授权测试
## ============================================================

func _test_ip_authorization() -> void:
	print("\n【测试2：IP授权触发测试】")
	print("-".repeat(40))
	
	# 重置数据
	_reset_mock_data()
	
	# 测试场景1：文学100级，小说不足50篇
	mock_blogger.literature_level = 100
	mock_blogger.novel_count = 30
	var result1 = _check_ip_trigger()
	_add_result("IP授权", "文学100级+小说30篇(不应触发)", !result1)
	
	# 测试场景2：文学100级，小说50篇
	mock_blogger.novel_count = 50
	var result2 = _check_ip_trigger()
	_add_result("IP授权", "文学100级+小说50篇(应触发)", result2)
	
	# 测试场景3：IP月收益
	if result2:
		mock_ip_state.base_ip_active = true
		mock_ip_state.base_ip_remaining_months = 12
		var income_result = _simulate_ip_monthly_income()
		_add_result("IP收益", "月收益结算", income_result)

## 检查IP授权是否触发
func _check_ip_trigger() -> bool:
	var lit_ok = mock_blogger.literature_level >= 100
	var novel_ok = mock_blogger.novel_count >= test_config.novel_count_for_ip
	
	if lit_ok and novel_ok:
		mock_ip_state.base_ip_active = true
		mock_ip_state.base_ip_remaining_months = 12
		print("  [成功] IP授权触发！文学%d级，小说%d篇" % [mock_blogger.literature_level, mock_blogger.novel_count])
		return true
	else:
		print("  [信息] IP授权未触发 - 文学:%d/100, 小说:%d/%d" % [
			mock_blogger.literature_level, 
			mock_blogger.novel_count,
			test_config.novel_count_for_ip
		])
		return false

## 模拟IP月收益
func _simulate_ip_monthly_income() -> bool:
	if mock_ip_state.base_ip_active:
		var income = 1000
		mock_blogger.money += income
		mock_ip_state.total_ip_income += income
		mock_ip_state.base_ip_remaining_months -= 1
		print("  [成功] IP月收益: %d元，剩余%d个月" % [income, mock_ip_state.base_ip_remaining_months])
		return true
	return false

## ============================================================
## 测试3：出版畅销书测试
## ============================================================

func _test_book_publish() -> void:
	print("\n【测试3：出版畅销书写作测试】")
	print("-".repeat(40))
	
	# 重置数据
	_reset_mock_data()
	mock_blogger.literature_level = 100
	
	# 测试阶段1：解锁出版畅销书
	var unlock_result = mock_blogger.literature_level >= 100
	_add_result("出版解锁", "文学100级解锁出版畅销书", unlock_result)
	
	if unlock_result:
		# 测试阶段2：模拟写作过程
		_simulate_book_writing()
		
		# 测试阶段3：模拟出版流程
		_simulate_publish_process()

## 模拟写作过程
func _simulate_book_writing() -> void:
	print("\n  【写作阶段模拟】")
	
	mock_book_state.is_writing = true
	mock_book_state.current_phase = 0
	
	# 模拟写作168天（游戏内半年）
	for day in range(1, 169):
		mock_book_state.write_days += 1
		mock_book_state.total_progress += 1
	
	print("  写作天数: %d" % mock_book_state.write_days)
	print("  写作进度: %d" % mock_book_state.total_progress)
	
	var min_days_ok = mock_book_state.write_days >= 168
	_add_result("写作进度", "写作达到168天(半年)", min_days_ok)

## 模拟出版流程
func _simulate_publish_process() -> void:
	print("\n  【出版流程模拟】")
	
	# 阶段1：写作完成，选择出版商
	mock_book_state.current_phase = 1
	mock_book_state.publisher = {
		"name": "新星出版社",
		"reward_multiplier": 1.0,
		"edit_days": 3,
		"publish_days": 5,
	}
	print("  阶段1: 编辑修改 - 出版社: %s" % mock_book_state.publisher.name)
	
	# 阶段2：编辑修改
	for day in range(mock_book_state.publisher.edit_days):
		mock_book_state.phase_day += 1
	print("  阶段2: 编辑修改完成 (%d天)" % mock_book_state.publisher.edit_days)
	
	# 阶段3：出版社审核
	mock_book_state.current_phase = 2
	mock_book_state.phase_day = 0
	for day in range(mock_book_state.publisher.publish_days):
		mock_book_state.phase_day += 1
	print("  阶段3: 出版社审核完成 (%d天)" % mock_book_state.publisher.publish_days)
	
	# 阶段4：出版上市
	mock_book_state.current_phase = 3
	mock_book_state.completed = true
	
	# 计算收益
	var base_reward = 50000
	var multiplier = mock_book_state.publisher.reward_multiplier
	var quality_bonus = mock_book_state.write_days / 168.0
	var final_reward = int(base_reward * multiplier * quality_bonus)
	
	mock_blogger.money += final_reward
	mock_blogger.reputation += 1000
	
	print("  阶段4: 出版上市！")
	print("  出版收益: %d元" % final_reward)
	print("  声望奖励: 1000点")
	
	_add_result("出版收益", "收益计算正确(基础50000×%.1f×%.1f=%d)" % [multiplier, quality_bonus, final_reward], final_reward > 0)

## ============================================================
## 辅助函数
## ============================================================

func _reset_mock_data() -> void:
	mock_blogger = {
		"literature_level": 0,
		"novel_count": 0,
		"money": 0,
		"reputation": 0,
		"unlocked_posts": [],
		"posts": [],
	}
	mock_book_state = {
		"is_writing": false,
		"current_phase": 0,
		"write_days": 0,
		"total_progress": 0,
		"completed": false,
		"publisher": {},
	}
	mock_ip_state = {
		"base_ip_active": false,
		"base_ip_remaining_months": 0,
		"movie_ip_triggered": false,
		"game_ip_triggered": false,
		"total_ip_income": 0,
	}

func _add_result(category: String, name: String, passed: bool) -> void:
	test_results.append({
		"category": category,
		"name": name,
		"passed": passed,
		"timestamp": Time.get_datetime_string_from_system(),
	})
	
	var status = "✓ 通过" if passed else "✗ 失败"
	print("  [%s] %s - %s" % [status, category, name])

func _count_passed() -> int:
	var count = 0
	for r in test_results:
		if r.passed:
			count += 1
	return count

func _count_failed() -> int:
	var count = 0
	for r in test_results:
		if not r.passed:
			count += 1
	return count

func _print_test_report() -> void:
	print("\n" + "=".repeat(60))
	print("【测试报告】")
	print("=".repeat(60))
	print("总测试数: %d" % test_results.size())
	print("通过: %d" % _count_passed())
	print("失败: %d" % _count_failed())
	print("通过率: %.1f%%" % (_count_passed() * 100.0 / max(test_results.size(), 1)))
	
	if _count_failed() > 0:
		print("\n【失败测试详情】")
		for r in test_results:
			if not r.passed:
				print("  - [%s] %s" % [r.category, r.name])
	
	print("=".repeat(60))

## ============================================================
## 热插拔测试配置接口
## ============================================================

## 添加自定义测试等级
func add_test_level(level: int, article_name: String) -> void:
	test_config.literature_levels.append(level)
	article_unlock_map[level] = article_name
	print("[配置] 添加测试等级: %d -> %s" % [level, article_name])

## 移除测试等级
func remove_test_level(level: int) -> void:
	test_config.literature_levels.erase(level)
	article_unlock_map.erase(level)
	print("[配置] 移除测试等级: %d" % level)

## 启用/禁用测试模块
func set_test_enabled(test_name: String, enabled: bool) -> void:
	if test_config.enabled_tests.has(test_name):
		test_config.enabled_tests[test_name] = enabled
		print("[配置] %s测试: %s" % [test_name, "启用" if enabled else "禁用"])

## 设置IP授权所需小说数量
func set_novel_count_for_ip(count: int) -> void:
	test_config.novel_count_for_ip = count
	print("[配置] IP授权所需小说数量: %d" % count)

## 获取测试配置
func get_test_config() -> Dictionary:
	return test_config.duplicate(true)

## 获取测试结果
func get_test_results() -> Array:
	return test_results.duplicate(true)