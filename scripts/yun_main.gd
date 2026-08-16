extends Control
signal close_yun
var domain_info = Yun.domain_info
var server_package = Yun.server_package
var data_security = Yun.data_security
var network_security = Yun.network_security
@onready var jh_label = $"bg/选项组/sc1/VBoxContainer/Label2" #域名主机服务商简介
@onready var jh_title_label = $"bg/选项组/sc1/VBoxContainer/Label" #域名主机服务商标题
@onready var domain_label = $"bg/选项组/sc2/VBoxContainer/Label2" #域名信息展示
@onready var server_label = $"bg/选项组/sc2/VBoxContainer/Label4" #服务器信息展示
@onready var gc = $"bg/选项组/sc2/VBoxContainer/GridContainer" #
@onready var ds = $"bg/选项组/sc3/VBoxContainer/Label" # 数据安全信息
@onready var ns = $"bg/选项组/sc3/VBoxContainer/Label4" #网络安全信息
@onready var scs = [
    $"bg/选项组/sc1",
    $"bg/选项组/sc2",
    $"bg/选项组/sc3",
    $"bg/选项组/sc4",
    $"bg/选项组/sc5",
    $"bg/选项组/sc6",
    $"bg/选项组/sc7",
    $"bg/选项组/sc8",
] 

@onready var provider_list_box = $"bg/选项组/sc8/d8/provider_list"
@onready var provider_name_label = $"bg/选项组/sc8/d8/provider_detail/detail_vb/provider_name"
@onready var provider_price_label = $"bg/选项组/sc8/d8/provider_detail/detail_vb/provider_price"
@onready var provider_status_label = $"bg/选项组/sc8/d8/provider_detail/detail_vb/provider_status"
@onready var provider_desc_label = $"bg/选项组/sc8/d8/provider_detail/detail_vb/provider_desc" 

var _pending_provider_id := ""
var _selected_provider_id := ""
var _cancel_btn: Button = null 
@onready var switch_btn = $"bg/选项组/sc8/d8/switch_btn"

@onready var buttons: Array[Button] = [
    $"bg/按钮组/vb/mc1/b1",
    $"bg/按钮组/vb/mc2/b2",
    $"bg/按钮组/vb/mc3/b3",
    $"bg/按钮组/vb/mc4/b4",
    $"bg/按钮组/vb/mc5/b5",
    $"bg/按钮组/vb/mc6/b6",
    $"bg/按钮组/vb/mc7/b7",
    $"bg/按钮组/vb/mc8/b8",
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    $AcceptDialog.confirmed.connect(_on_accept_dialog_confirmed)
    $AcceptDialog.custom_action.connect(_on_accept_dialog_custom_action)
    switch_btn.pressed.connect(_on_switch_btn_pressed)
    on_show_panel()
    


    
func on_show_panel():
    _selected_provider_id = Yun.provider_id
    $"bg/选项组/sc3/VBoxContainer/Label2".text = Strs.yun.数据安全简介
    $"bg/选项组/sc3/VBoxContainer/Label2".set_autowrap_mode(TextServer.AUTOWRAP_WORD_SMART)
    $"bg/选项组/sc3/VBoxContainer/Label5".text = Strs.yun.网络安全简介
    $"bg/选项组/sc3/VBoxContainer/Label5".set_autowrap_mode(TextServer.AUTOWRAP_WORD_SMART)
    create_package_list_ui(gc)
    create_provider_list_ui()
    refresh_provider_detail()
    update_renew_buttons()
    _update_provider_labels()

func _update_provider_labels():
    """根据当前服务商刷新域名主机面板数据（sc1简介/sc2域名主机信息）"""
    var p = Yun.get_current_provider()
    if p.is_empty():
        return
    jh_title_label.text = p.get("name") + "域名"
    jh_label.text = "【%s——域名主机服务商】\n%s" % [p.get("name"), p.get("desc", "")]
    jh_label.set_autowrap_mode(TextServer.AUTOWRAP_WORD_SMART)
    var suspend_info = Yun.get_suspend_info()
    var suspend_status_text = ""
    if suspend_info.is_suspended:
        suspend_status_text = "\n⚠️ [暂停中] 已欠费 %d 天，请尽快续费！" % suspend_info.suspend_days
    
    domain_label.text = "服务商: " + p.get("name") + "  域名: " + domain_info.name + "  " + \
                   "开始时间: " + domain_info.start_time + "  " + \
                   "结束时间: " + domain_info.end_time + "  " + \
                   "状态: " + ("正常" if domain_info.is_active else "❌ 过期") + suspend_status_text
                
    server_label.text = "服务商: " + p.get("name") + "  主机: " + server_package.name + "  " + \
                   "开始时间: " + server_package.start_time + "  " + \
                   "结束时间: " + server_package.end_time + "  " + \
                   "状态: " + ("正常" if server_package.is_active else "❌ 过期") + "  " + \
                   "月访问量限制: " + ("无限制" if server_package.monthly_traffic_limit == -1 else str(server_package.monthly_traffic_limit) + "万次/月") + suspend_status_text
    ds.text = "数据安全: " + \
          ("开始时间: " + data_security.start_time + "  " + \
           "结束时间: " + data_security.end_time + "  " + \
           "状态: " + ("正常" if data_security.is_active else "过期") if data_security.start_time != "" else "未购买此服务，为了你的数据安全请购买此服务")      
    ns.text = "网络安全: " + \
          ("开始时间: " + network_security.start_time + "  " + \
           "结束时间: " + network_security.end_time + "  " + \
           "状态: " + ("正常" if network_security.is_active else "过期") if network_security.start_time != "" else "未购买此服务，为了你的网络安全请购买此服务")
    
  

func _on_button_pressed() -> void:
    emit_signal("close_yun")




func _on_b_1_pressed() -> void:
    show_scroll_container(0)
    set_button_pressed(0)


func _on_b_2_pressed() -> void:
    show_scroll_container(1)
    set_button_pressed(1)


func _on_b_3_pressed() -> void:
    show_scroll_container(2)
    set_button_pressed(2)


func _on_b_4_pressed() -> void:
    show_scroll_container(3)
    set_button_pressed(3)


func _on_b_5_pressed() -> void:
    show_scroll_container(4)
    set_button_pressed(4)


func _on_b_6_pressed() -> void:
    show_scroll_container(5)
    set_button_pressed(5)


func _on_b_7_pressed() -> void:
    show_scroll_container(6)
    set_button_pressed(6)


func _on_b_8_pressed() -> void:
    show_scroll_container(7)
    set_button_pressed(7)


# 控制显示的方法
func show_scroll_container(index: int) -> void:
    for i in range(scs.size()):
        if i == index:  # 因为数组是0开始，index从1开始
            scs[i].visible = true
        else:
            scs[i].visible = false
            
# 返回当前显示的 ScrollContainer 的数组索引（0-based）
func get_visible_scroll_array_index() -> int:
    for i in range(scs.size()):
        if scs[i].visible:
            return i  # 返回数组下标
    return -1  # 没有可见项时返回 -1

# 设置指定索引的按钮为按下状态，其余取消
func set_button_pressed(index: int):
    for i in range(buttons.size()):
        if i == index:
            buttons[i].set_pressed(true)
        else:
            buttons[i].set_pressed(false)

    
func open_dialog(text,title="提示"):
    $AcceptDialog.title = title
    $AcceptDialog.dialog_text = text
    $AcceptDialog.set_size(Vector2i(400,200))
    $AcceptDialog.popup_centered()  


func _on_xfbut_pressed() -> void:
    var rst = Yun.renew_domain()
    on_show_panel()
    
    if rst.success:
        show_popup_message("续费成功", rst.message + "\n域名: " + rst.domain_name + "\n到期时间: " + rst.new_end_time + "\n剩余余额: %.2f" % rst.remaining_balance)
    else:
        show_popup_message("续费失败", rst.message)
    
    
## 显示通用弹窗
func show_popup_message(title: String, content: String) -> void:
    $AcceptDialog.title = title
    $AcceptDialog.dialog_text = content
    $AcceptDialog.set_size(Vector2i(400,200))
    $AcceptDialog.popup_centered()  

## 续费当前服务器套餐
func _on_xfzj_pressed() -> void:
    var rst = Yun.renew_server_package()
    on_show_panel()
    
    if rst.success:
        show_popup_message("续费成功", rst.message + "\n套餐: " + rst.package_name + "\n续费年限: " + str(rst.duration_years) + "年\n到期时间: " + rst.new_end_time + "\n剩余余额: %.2f" % rst.remaining_balance)
    else:
        show_popup_message("续费失败", rst.message)



# UI界面代码

func create_package_list_ui(gc: GridContainer):
    """创建套餐UI界面"""
    # 清空现有内容
    for child in gc.get_children():
        child.queue_free()
    
    # 获取所有套餐信息
    var all_packages = Yun.get_all_package_info()
    
    # 为每个套餐创建UI组件（包含终极套餐）
    for package_type in range(6):  # 0-5，包含ULTIMATE
        var package_info = all_packages[package_type]
        create_single_package_ui(
            package_type, 
            package_info["name"],
            Yun.get_package_cost(package_type), 
            package_info["traffic_limit"]
        )


func create_single_package_ui(package_type: int, package_name: String, 
                            package_cost: float, traffic_limit: int):
    """创建单个套餐的UI组件"""
    
    # 创建主容器
    var main_container = VBoxContainer.new()
    main_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    
    # 套餐名称标签
    var name_label = Label.new()
    name_label.text = package_name
    name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    name_label.add_theme_color_override("font_color", get_package_color(package_type))
    name_label.add_theme_font_size_override("font_size", 16)
    main_container.add_child(name_label)
    
    # 套餐信息标签
    var info_label = Label.new()
    # 处理终极套餐无限制的情况
    if traffic_limit == -1:
        info_label.text = "月访问量: 无限制\n年费用: %.2f元" % [package_cost]
    else:
        info_label.text = "月访问量: %d万次\n年费用: %.2f元" % [traffic_limit, package_cost]
    info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    main_container.add_child(info_label)
    
    # 当前套餐标识
    var current_label = Label.new()
    var current_package_type = Yun.get_server_package_type()
    if package_type == current_package_type:
        current_label.text = "当前套餐"
        current_label.add_theme_color_override("font_color", Color.GREEN)
    else:
        current_label.text = ""
    current_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    main_container.add_child(current_label)
    
    # 更换套餐按钮
    var change_button = Button.new()
    change_button.text = "更换套餐"
    change_button.flat = false
    Sfx.wire(change_button)
    
    # 根据当前套餐状态设置按钮文本和颜色
    if package_type == current_package_type:
        change_button.text = "当前套餐"
        change_button.disabled = true
    else:
        change_button.connect("pressed", Callable(self, "_on_change_package_pressed").bind(package_type))
    
    main_container.add_child(change_button)
    
    # 添加到GridContainer
    gc.add_child(main_container)

func get_package_color(package_type: int) -> Color:
    """根据套餐类型返回对应颜色"""
    match package_type:
        Yun.PackageType.FREE: return Color.YELLOW
        Yun.PackageType.BASIC: return Color.BLUE
        Yun.PackageType.STANDARD: return Color.GREEN
        Yun.PackageType.PREMIUM: return Color.PURPLE
        Yun.PackageType.ENTERPRISE: return Color.GOLD
        Yun.PackageType.ULTIMATE: return Color.RED  # 终极套餐用红色
        _: return Color.WHITE

func _on_change_package_pressed(package_type: int):
    """更换套餐按钮点击事件"""

    var result = Yun.upgrade_server_package(package_type)
        
        # 处理结果
    if result.success:
            # 升级成功，重新创建UI界面
        on_show_panel()

         # 显示成功消息
        # 这里可以添加弹窗或其他UI反馈
    else:
        # 升级失败，显示错误信息
        # 这里可以添加弹窗或其他UI反馈
        pass

func _on_refresh_ui():
    """刷新UI界面"""
    create_package_list_ui(gc)

# ===== 服务商选择 UI =====

func get_star_string(stars: int) -> String:
    """根据星级生成 ★ 字符串"""
    var text = ""
    for i in range(5):
        text += "★" if i < stars else "☆"
    return text

func create_provider_list_ui():
    """创建服务商单选列表"""
    for child in provider_list_box.get_children():
        child.queue_free()
    var group = ButtonGroup.new()
    group.allow_unpress = false
    var providers = Yun.get_providers()
    for p in providers:
        var pid: String = p.get("id")
        var pname: String = p.get("name")
        var status = Yun.get_provider_status(pid)
        if status.status == Yun.ProviderStatus.LOCKED:
            continue
        var btn = CheckBox.new()
        btn.button_group = group
        btn.focus_mode = Control.FOCUS_NONE
        match status.status:
            Yun.ProviderStatus.ACTIVE:
                btn.text = pname + "（营业中）"
                if pid == Yun.provider_id:
                    btn.button_pressed = true
                btn.toggled.connect(_on_provider_toggled.bind(pid))
            Yun.ProviderStatus.RUNAWAY:
                btn.text = pname + "（已跑路）"
                btn.disabled = true
                btn.modulate = Color(0.6, 0.6, 0.6)
                if pid == Yun.provider_id:
                    btn.button_pressed = true
        provider_list_box.add_child(btn)

func _on_provider_toggled(checked: bool, pid: String):
    if not checked:
        return
    _selected_provider_id = pid
    refresh_provider_detail()

func _on_switch_btn_pressed():
    if _selected_provider_id == "" or _selected_provider_id == Yun.provider_id:
        show_popup_message("提示", "已是当前服务商，无需更换")
        return
    _open_switch_confirm(_selected_provider_id)

func _open_switch_confirm(pid: String):
    _pending_provider_id = pid
    var p = Yun.get_provider_by_id(pid)
    if p.is_empty():
        return
    var domain_cost = Yun.get_provider_domain_price(pid)
    var host_cost = Yun.get_provider_package_cost(pid, Yun.get_server_package_type())
    var dlg = $AcceptDialog
    dlg.title = "更换服务商"
    dlg.dialog_text = "更换服务商为【%s】？\n\n将按新服务商价格重新续费：\n  域名一年：%.2f元\n  主机一年：%.2f元\n  合计：%.2f元\n\n原有剩余时间将作废，是否确认更换？" % [p.get("name"), domain_cost, host_cost, domain_cost + host_cost]
    dlg.ok_button_text = "确认更换"
    if _cancel_btn == null:
        _cancel_btn = dlg.add_button("取消", true, "cancel")
    else:
        _cancel_btn.visible = true
    dlg.set_size(Vector2i(480, 260))
    dlg.popup_centered()

func _on_accept_dialog_confirmed():
    if _pending_provider_id == "":
        return
    var rst = Yun.switch_provider(_pending_provider_id)
    _pending_provider_id = ""
    if _cancel_btn != null:
        _cancel_btn.visible = false
    $AcceptDialog.ok_button_text = "确定"
    if rst.success:
        _selected_provider_id = Yun.provider_id
        create_provider_list_ui()
        refresh_provider_detail()
        create_package_list_ui(gc)
        update_renew_buttons()
        _update_provider_labels()
        show_popup_message("更换成功", "已切换至【%s】\n扣除费用：%.2f元（域名%.2f + 主机%.2f）\n域名/主机到期：%s\n剩余余额：%.2f元" % [rst.provider_name, rst.total_cost, rst.domain_cost, rst.host_cost, rst.new_end_time, rst.remaining_balance])
    else:
        _selected_provider_id = Yun.provider_id
        create_provider_list_ui()
        refresh_provider_detail()
        show_popup_message("更换失败", rst.message)

func _on_accept_dialog_custom_action(action: String):
    if action == "cancel":
        _pending_provider_id = ""
        if _cancel_btn != null:
            _cancel_btn.visible = false
        $AcceptDialog.hide()
        _selected_provider_id = Yun.provider_id
        create_provider_list_ui()
        refresh_provider_detail()

func refresh_provider_detail():
    """刷新服务商详情面板（显示当前选中服务商）"""
    var pid = _selected_provider_id
    if pid == "":
        pid = Yun.provider_id
    var p = Yun.get_provider_by_id(pid)
    if p.is_empty():
        return
    provider_name_label.text = p.get("name") + "  " + get_star_string(int(p.get("stars", 0)))
    var domain_cost = Yun.get_provider_domain_price(pid)
    var all_packages = Yun.get_all_package_info()
    var txt = "域名续费：%.2f元/年\n" % domain_cost
    txt += "主机套餐年费：\n"
    for package_type in range(6):
        var pinfo = all_packages[package_type]
        var cost = Yun.get_provider_package_cost(pid, package_type)
        var limit_txt = "无限制" if pinfo["traffic_limit"] == -1 else str(pinfo["traffic_limit"]) + "万次/月"
        txt += "  %s：%.2f元/年（月访问 %s）\n" % [pinfo["name"], cost, limit_txt]
    provider_price_label.text = txt
    provider_desc_label.text = p.get("desc", "")
    provider_desc_label.set_autowrap_mode(TextServer.AUTOWRAP_WORD_SMART)
    var status = Yun.get_provider_status(pid)
    if pid == Yun.provider_id and Yun.is_provider_runaway_active():
        provider_status_label.text = "❌ 当前服务商已跑路失联！网站无法访问，请立即更换其他服务商！"
    elif status.status == Yun.ProviderStatus.RUNAWAY:
        provider_status_label.text = "❌ 该服务商已跑路失联，不可使用"
    elif p.get("is_small", false):
        provider_status_label.text = "⚠️ 小型服务商，价格便宜但服务可能不稳定，随时可能跑路，请谨慎！"
    else:
        provider_status_label.text = ""

func update_renew_buttons():
    """更新续费按钮价格文案"""
    var domain_cost = Yun.get_domain_renewal_cost()
    $"bg/选项组/sc2/VBoxContainer/xfbut".text = "续费域名一年时间（%.0f元）" % domain_cost
    var pkg_cost = Yun.get_package_cost(Yun.get_server_package_type())
    $"bg/选项组/sc2/VBoxContainer/xfzj".text = "续费主机一年使用时间（%.0f元）" % pkg_cost



func _on_ds_button_pressed() -> void:
    var rst = Yun.renew_data_security(1) # 默认续费7天
    on_show_panel()
    
    if rst.success:
        show_popup_message("续费成功", rst.message + "\n续费天数: " + str(rst.duration_days) + "天\n到期时间: " + rst.new_end_time + "\n剩余余额: " + str(rst.remaining_balance))
    else:
        show_popup_message("续费失败", rst.message)


func _on_ns_button_pressed() -> void:
    var rst = Yun.renew_network_security(1) # 默认续费1天
    on_show_panel()
    
    if rst.success:
        show_popup_message("续费成功", rst.message + "\n续费天数: " + str(rst.duration_days) + "天\n到期时间: " + rst.new_end_time + "\n剩余余额: " + str(rst.remaining_balance))
    else:
        show_popup_message("续费失败", rst.message)
