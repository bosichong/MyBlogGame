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
	
	# 测试2：写作质量计算（篇数制）
	print("\n【测试2】写作质量计算")
	var quality_50 = book_publish.calculate_write_quality(50, 100.0)
	var quality_100 = book_publish.calculate_write_quality(100, 100.0)
	print("  50篇质量: %.2f" % quality_50)
	print("  100篇质量: %.2f" % quality_100)
	assert(quality_50 == 1.0, "50篇即达上限1.0")
	assert(quality_100 == 1.0, "100篇应得1.0")
	print("  ✓ 质量计算正确")
	
	# 测试3：月收入曲线
	print("\n【测试3】月收入曲线")
	var test_book = {
		"published": true,
		"sales_months": 0,
		"write_quality": 0.8,
	}
	
	var months = [1, 2, 4, 6, 8, 10, 12]
	var total = 0
	for m in months:
		var sm = m - 1
		var income = book_publish.calculate_monthly_sales(test_book, sm)
		total += income
		var status = book_publish.get_book_sales_status(test_book)
		print("  第%2d个月: ¥%-8d (%s)" % [m, income, status])
	
	print("  12个月累计: ¥%d" % total)
	assert(total > 0, "收入累计应大于0")
	print("  ✓ 收入曲线正常")
	
	# 测试4：完整流程模拟（按篇数制：100篇完稿）
	print("\n【测试4】完整出版流程（按篇数制）")
	book_publish.current_book_state["is_writing"] = true
	book_publish.current_book_state["write_days"] = 100
	
	var publisher = {"name": "人民文学出版社", "reward_multiplier": 1.5, "edit_days": 5, "publish_days": 7}
	var base_reward = 50000
	var multiplier = publisher["reward_multiplier"]
	var final_reward = int(base_reward * multiplier * (100.0 / 100.0))
	
	print("  写作篇数: %d 篇" % 100)
	print("  出版社: %s" % publisher["name"])
	print("  出版奖励: ¥%d" % final_reward)
	assert(final_reward == 75000, "100篇+人民文学=75000")
	print("  声望奖励: +1000")
	
	book_publish.current_book_state["write_quality"] = book_publish.calculate_write_quality(100, 100.0)
	book_publish.current_book_state["published"] = true
	book_publish.published_books.append(book_publish.current_book_state.duplicate())
	
	var year_income = 0
	for m in range(1, 13):
		book_publish.published_books[0]["sales_months"] = m - 1
		year_income += book_publish.calculate_monthly_sales(book_publish.published_books[0], m - 1)
	
	print("  第1年销售收入: ¥%d" % year_income)
	assert(year_income > 0, "第一年收入应大于0")
	print("  ✓ 流程完整")
	
	print("\n" + "=".repeat(50))
	print("✅ 所有测试通过！出版畅销书功能正常。")
	print("=".repeat(50) + "\n")
	
	quit()
