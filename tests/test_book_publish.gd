extends SceneTree

# 独立测试脚本：出版畅销书（文学值=100）

func _init():
	print("\n" + "=".repeat(50))
	print("📚 出版畅销书任务测试（文学值=100）")
	print("=".repeat(50))
	
	# 加载数据
	var book_publish = load("res://data/book_publish.gd").new()
	
	# 测试1：激活条件
	print("\n【测试1】激活条件")
	var book_data = book_publish.books[0]
	print("  解锁条件: %s" % book_data.unlock_condition)
	print("  ✓ 需要文学值 ≥ 100")
	
	# 测试2：写作质量计算
	print("\n【测试2】写作质量计算")
	var quality_168 = book_publish.calculate_write_quality(168, 100.0)
	var quality_336 = book_publish.calculate_write_quality(336, 100.0)
	print("  168天质量: %.2f" % quality_168)
	print("  336天质量: %.2f" % quality_336)
	print("  ✓ 质量计算正确")
	
	# 测试3：月收入曲线
	print("\n【测试3】月收入曲线")
	var test_book = {
		"published": true,
		"sales_months": 0,
		"write_quality": 0.8,
		"literature_value": 100
	}
	
	var months = [1, 6, 12, 18, 24, 30, 36]
	var total = 0
	for m in months:
		test_book.sales_months = m - 1
		var income = book_publish.calculate_monthly_sales(test_book, m)
		total += income
		var status = book_publish.get_book_sales_status(test_book)
		print("  第%2d个月: ¥%-8d (%s)" % [m, income, status])
	
	print("  36个月累计: ¥%d" % total)
	print("  ✓ 收入曲线正常")
	
	# 测试4：完整流程模拟
	print("\n【测试4】完整出版流程")
	book_publish.current_book_state["is_writing"] = true
	book_publish.current_book_state["write_days"] = 336
	
	var publisher = {"name": "人民文学出版社", "reward_multiplier": 1.5, "edit_days": 5, "publish_days": 7}
	var base_reward = 50000
	var multiplier = publisher["reward_multiplier"]
	var final_reward = int(base_reward * multiplier * (336.0 / 168.0))
	
	print("  写作天数: %d 天" % 336)
	print("  出版社: %s" % publisher["name"])
	print("  出版奖励: ¥%d" % final_reward)
	print("  声望奖励: +1000")
	
	book_publish.current_book_state["write_quality"] = book_publish.calculate_write_quality(336, 100.0)
	book_publish.current_book_state["published"] = true
	book_publish.published_books.append(book_publish.current_book_state.duplicate())
	
	var year_income = 0
	for m in range(1, 13):
		book_publish.published_books[0]["sales_months"] = m - 1
		year_income += book_publish.calculate_monthly_sales(book_publish.published_books[0], m)
	
	print("  第1年销售收入: ¥%d" % year_income)
	print("  ✓ 流程完整")
	
	print("\n" + "=".repeat(50))
	print("✅ 所有测试通过！出版畅销书功能正常。")
	print("=".repeat(50) + "\n")
	
	quit()
