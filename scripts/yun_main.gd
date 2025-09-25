extends Control
signal close_bm
var domain_info = Yun.domain_info
@onready var domain_label = $"bg/选项组/sc2/VBoxContainer/Label2" #域名信息展示
@onready var jh_label = $"bg/选项组/sc1/VBoxContainer/Label2" #域名主机服务商简介

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
    
    domain_label.text = "域名: " + domain_info.name + "  " + \
                   "开始时间: " + domain_info.start_time + "  " + \
                   "结束时间: " + domain_info.end_time + "  " + \
                   "状态: " + ("正常" if domain_info.is_active else "过期")

  
  

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
