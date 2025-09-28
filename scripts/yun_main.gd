extends Control
signal close_bm
var domain_info = Yun.domain_info
var server_package = Yun.server_package
var data_security = Yun.data_security
var network_security = Yun.network_security
@onready var jh_label = $"bg/选项组/sc1/VBoxContainer/Label2" #域名主机服务商简介
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
] 

@onready var buttons: Array[Button] = [
    $"bg/按钮组/vb/mc1/b1",
    $"bg/按钮组/vb/mc2/b2",
    $"bg/按钮组/vb/mc3/b3",
    $"bg/按钮组/vb/mc4/b4",
    $"bg/按钮组/vb/mc5/b5",
    $"bg/按钮组/vb/mc6/b6",
    $"bg/按钮组/vb/mc7/b7",
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    on_show_panel()
    


    
func on_show_panel():
    jh_label.text = Strs.yun.江湖主机域名简介
    jh_label.set_autowrap_mode(TextServer.AUTOWRAP_WORD_SMART)
    $"bg/选项组/sc3/VBoxContainer/Label2".text = Strs.yun.数据安全简介
    $"bg/选项组/sc3/VBoxContainer/Label2".set_autowrap_mode(TextServer.AUTOWRAP_WORD_SMART)
    $"bg/选项组/sc3/VBoxContainer/Label5".text = Strs.yun.网络安全简介
    $"bg/选项组/sc3/VBoxContainer/Label5".set_autowrap_mode(TextServer.AUTOWRAP_WORD_SMART)
    create_package_ui()
    domain_label.text = "域名: " + domain_info.name + "  " + \
                   "开始时间: " + domain_info.start_time + "  " + \
                   "结束时间: " + domain_info.end_time + "  " + \
                   "状态: " + ("正常" if domain_info.is_active else "过期")
                
    server_label.text = "主机: " + server_package.name + "  " + \
                   "开始时间: " + server_package.start_time + "  " + \
                   "结束时间: " + server_package.end_time + "  " + \
                   "状态: " + ("正常" if server_package.is_active else "过期") + "  " + \
                   "月访问量限制: " + str(server_package.monthly_traffic_limit) + "万次/月"
    ds.text = "数据安全: " + \
          ("开始时间: " + data_security.start_time + "  " + \
           "结束时间: " + data_security.end_time + "  " + \
           "状态: " + ("正常" if data_security.is_active else "过期") if data_security.start_time != "" else "未购买此服务，为了你的数据安全请购买此服务")      
    ns.text = "网络安全: " + \
          ("开始时间: " + network_security.start_time + "  " + \
           "结束时间: " + network_security.end_time + "  " + \
           "状态: " + ("正常" if network_security.is_active else "过期") if network_security.start_time != "" else "未购买此服务，为了你的网络安全请购买此服务")
    
  

func _on_button_pressed() -> void:
    emit_signal("close_bm")




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
        show_popup_message("续费成功", rst.message + "\n域名: " + rst.domain_name + "\n到期时间: " + rst.new_end_time + "\n剩余余额: " + str(rst.remaining_balance))
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
        show_popup_message("续费成功", rst.message + "\n套餐: " + rst.package_name + "\n续费年限: " + str(rst.duration_years) + "年\n到期时间: " + rst.new_end_time + "\n剩余余额: " + str(rst.remaining_balance))
    else:
        show_popup_message("续费失败", rst.message)



# UI界面代码

func create_package_ui():
    """创建套餐UI界面"""
    # 清空现有内容
    for child in gc.get_children():
        child.queue_free()
    
    # 获取所有套餐信息
    var all_packages = Yun.get_all_package_info()
    var package_names = all_packages["package_names"]
    var package_costs = all_packages["package_costs"]
    var package_limits = all_packages["package_traffic_limits"]
    
    # 为每个套餐创建UI组件
    for package_type in range(5):
        create_single_package_ui(package_type, package_names[package_type], 
                                package_costs[package_type], package_limits[package_type])


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
        _: return Color.WHITE

func _on_change_package_pressed(package_type: int):
    """更换套餐按钮点击事件"""

    var result = Yun.upgrade_server_package(package_type)
        
        # 处理结果
    if result.success:
            # 升级成功，重新创建UI界面
        on_show_panel()
            
         # 显示成功消息
        print("套餐升级成功: %s" % result.message)
        # 这里可以添加弹窗或其他UI反馈
    else:
        # 升级失败，显示错误信息
        print("套餐升级失败: %s" % result.message)
        # 这里可以添加弹窗或其他UI反馈

func _on_refresh_ui():
    """刷新UI界面"""
    create_package_ui()



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
