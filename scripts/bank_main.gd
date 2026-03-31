extends Control
signal close_bm


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	on_show_panel()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func on_show_panel():
	upd_total_bank_assets()
	upd_dqck_tab()
  
func upd_dqck_tab():
	var tab = $"bg/选项组/sc1/VBoxContainer/ScrollContainer/dqck"
	Utils.clear_children(tab)
	# ========== 定期存款列表 UI ========== #

	# 👇 添加表头（加粗 + 大字号 + 颜色）
	var header_lab = Label.new()
	header_lab.text = "存款编号    本金(元)        利率(%)       到期日        状态  "
	header_lab.add_theme_font_size_override("font_size", 16)
	header_lab.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))  # 浅灰白
	# header_lab.theme_override_fonts.font = get_theme_font("bold")  # 如需加粗，取消注释
	tab.add_child(header_lab)

	# 👇 添加分隔虚线（可选，增强视觉）
	var divider = Label.new()
	divider.text = "────────────────────────────────────────────────────"
	divider.add_theme_font_size_override("font_size", 12)
	divider.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	tab.add_child(divider)

	# 👇 遍历每条存款记录
	# 👇 遍历每条存款记录
	for deposit_id in Bs.fixed_deposits:
		var record = Bs.fixed_deposits[deposit_id]
		var today = Utils.format_date()
		var days_diff = Utils.calculate_new_game_time_difference(record.end_date, today, false)
		var is_matured = days_diff >= 0

		var id_str = "%-8s" % str(deposit_id)
		var amount_str = "%-14s" % ("%.2f" % record.amount)
		var rate_str = "%-12s" % ("%.2f%%" % record.total_rate_percent)
		var date_str = "%-12s" % record.end_date

		# ✅ 优化状态文字
		var status_text = "未到期"
		if is_matured:
			status_text = "可取出"  # 到期了就能取，不管是否已结算（取出即结算）
		if record.claimed:
			status_text = "已结算"

		var claimed_str = "%-6s" % status_text

		var lab = Label.new()
		lab.text = id_str + amount_str + rate_str + date_str + claimed_str

		# ✅ 优化颜色
		if record.claimed:
			lab.add_theme_color_override("font_color", Color(0.3, 0.9, 0.3))  # 绿
		elif is_matured:
			lab.add_theme_color_override("font_color", Color(1.0, 0.8, 0.0))  # 黄
		else:
			lab.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))  # 白

		tab.add_child(lab)

	# 👇 无存款时的提示（推荐添加）
	if Bs.fixed_deposits.size() == 0:
		var empty_lab = Label.new()
		empty_lab.text = "📭 当前没有定期存款记录"
		empty_lab.add_theme_font_size_override("font_size", 16)
		empty_lab.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		empty_lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		tab.add_child(empty_lab)
	
	
func upd_total_bank_assets():
	var zs = str(Bs.get_total_bank_assets())
	var s = "总资产:%s" %[zs]
	$"bg/选项组/sc1/VBoxContainer/Label".text = s
	var hqzs = Bs.format_money(Bs.savings_balance)
	var hqstr = "活期存款:%s" %[hqzs]
	$"bg/选项组/sc1/VBoxContainer/HBoxContainer/HBoxContainer/Label3".text = hqstr
	var hqlx = Bs.format_money(Bs.savings_balance_interest)
	var hqlxstr = "未结算活期存款利息:%s" %[hqlx]
	$"bg/选项组/sc1/VBoxContainer/HBoxContainer/HBoxContainer/Label4".text = hqlxstr

func _on_button_pressed() -> void:
	emit_signal("close_bm")


func _on_b_1_pressed() -> void:
	var d = int($"bg/选项组/sc1/VBoxContainer/HBoxContainer/HBoxContainer/LineEdit".get_text())
	var b = Bs.deposit_savings(d)
	if b:
		open_dialog("活期存款存储%s成功！" %[d])
		on_show_panel()
	else:
		open_dialog("活期存款存储失败！")


func _on_b_2_pressed() -> void:
	var d = int($"bg/选项组/sc1/VBoxContainer/HBoxContainer/HBoxContainer/LineEdit".get_text())
	var b = Bs.withdraw_savings(d)
	if b:
		open_dialog("活期存款取现%s成功！" %[d])
		on_show_panel()
	else:
		open_dialog("活期存款取现失败！")


func _on_b_3_pressed() -> void:
	var text = $"bg/选项组/sc1/VBoxContainer/HBoxContainer2/LineEdit".get_text()
	var amount = float(text) if text.is_valid_float() else 0.0  # ✅ 安全转换，避免崩溃
	var id = $"bg/选项组/sc1/VBoxContainer/HBoxContainer2/OptionButton".get_selected_id()

	var result: Dictionary

	match id:
		0:
			result = Bs.create_fixed_deposit_half_year(amount)
		1:
			result = Bs.create_fixed_deposit_year(amount)
		2:
			result = Bs.create_fixed_deposit_three_years(amount)
		_:
			open_dialog("❌ 请选择有效存期！")
			return

	if result.success:
		# ✅ 成功：显示格式化金额 + 自定义成功消息
		var formatted_amount = "%.2f" % amount
		open_dialog("🎉 定期存款半年期存储 %s 元成功！\n%s" % [formatted_amount, result.msg])
		on_show_panel()
	else:
		# ✅ 失败：直接显示错误原因
		open_dialog("❌ 存款失败：\n" + result.msg)
		

## 取出定存
func _on_b_5_pressed() -> void:
	var id = int($"bg/选项组/sc1/VBoxContainer/HBoxContainer2/LineEdit2".text)
	var result = Bs.withdraw_fixed_deposit(id)
	if result.success:
		var msg = "🏦 定期存款结算通知\n"
		msg += "──────────────────────\n"

		# 本金部分（显示原始本金 + 实际返还本金，如果被扣违约金）
		if result.withdrawal_fee > 0:
			msg += "原始本金：%.2f 元\n" % result.principal
			msg += "违约金（5%%）：-%.2f 元\n" % result.withdrawal_fee  # ✅ 修正为 5%
			msg += "实际返还本金：%.2f 元\n" % result.principal_returned
		else:
			msg += "本金返还：%.2f 元\n" % result.principal

		# 利息部分
		var interest_str = "%.2f 元" % result.interest
		if result.penalty_applied:
			interest_str += "（已按比例计息并罚息）"
		msg += "利息收入：%s\n" % interest_str

		# 日期信息
		msg += "原定到期日：%s\n" % result.end_date
		msg += "实际取出日：%s\n" % result.withdraw_date

		# 总结到账金额
		var total_received = result.principal_returned + result.interest
		msg += "──────────────────────\n"
		msg += "✅ 本次到账总额：%.2f 元\n" % total_received

		# 结尾语（根据是否提前支取，语气不同）
		if result.penalty_applied:
			msg += "\n⚠️ 温馨提示：提前支取会损失利息并收取违约金，建议存满期限以获得最大收益！"
		else:
			msg += "\n🎉 恭喜！您的存款已到期，全额本息已到账！"

		msg += "\n──────────────────────\n"
		msg += "感谢您使用本行服务，祝您财源滚滚！"

		# 示例显示方式（如用 AcceptDialog）：
		open_dialog(msg)
		on_show_panel()
	else:
		open_dialog("取出定期存款失败！")
		
func open_dialog(text,title="提示"):
	$AcceptDialog.title = title
	$AcceptDialog.dialog_text = text
	$AcceptDialog.set_size(Vector2i(400,200))
	$AcceptDialog.popup_centered()  
