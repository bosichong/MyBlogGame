#!/usr/bin/env godot --headless --script
extends SceneTree

## 文学技能测试运行器
## 使用方法: godot --headless --script res://tests/test_runner.gd

const LiteratureTest = preload("res://tests/literature_test.gd")

func _init():
	print("\n")
	print("*".repeat(60))
	print("*  文学技能文章解锁测试系统 - 自动化测试")
	print("*".repeat(60))
	
	# 创建测试实例
	var tester = LiteratureTest.new()
	add_child(tester)
	
	# 运行测试
	var results = tester.run_all_tests()
	
	# 输出最终结果
	print("\n")
	print("*".repeat(60))
	if results.failed == 0:
		print("*  ✓ 所有测试通过！")
	else:
		print("*  ✗ 有 %d 个测试失败！" % results.failed)
	print("*".repeat(60))
	
	# 退出
	quit(0 if results.failed == 0 else 1)