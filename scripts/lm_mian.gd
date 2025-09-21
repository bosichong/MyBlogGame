extends Control
signal close_lm

var jh_lables : Array

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
    $"bg/选项组/sc1/VBoxContainer/hbox/zl".visible = true
    $"bg/选项组/sc1/VBoxContainer/hbox/zl2".visible = false
    on_show_panel()
    
    
    
    
func on_show_panel():
    
    $bg/选项组/sc1/VBoxContainer/VBoxContainer/tit.text = Strs.game_strs.博客联盟.联盟名称
    $bg/选项组/sc1/VBoxContainer/VBoxContainer/lm_con.text = Strs.game_strs.博客联盟.联盟简介
    $bg/选项组/sc1/VBoxContainer/VBoxContainer/lm_con.set_autowrap_mode(TextServer.AUTOWRAP_WORD_SMART)
    $bg/选项组/sc2/VBoxContainer/VBoxContainer/lm_con.text = Strs.game_strs.博客联盟.江湖榜简介
    $"bg/选项组/sc3/VBoxContainer/VBoxContainer/lm_con".text = Strs.game_strs.博客联盟.关于联盟
    $"bg/选项组/sc3/VBoxContainer/VBoxContainer/lm_con".set_autowrap_mode(TextServer.AUTOWRAP_WORD_SMART)
    $"bg/选项组/sc1/VBoxContainer/hbox/zl/VBoxContainer/Label".text = Strs.game_strs.博客联盟.加入联盟
    $"bg/选项组/sc1/VBoxContainer/hbox/zl/VBoxContainer/Label".set_autowrap_mode(TextServer.AUTOWRAP_WORD_SMART)
    
    
    show_scroll_container(0)
    set_button_pressed(0)
    var jhpb_node = $bg/选项组/sc1/VBoxContainer/hbox/jhb/pb
    create_phb(Lm.jhph,jhpb_node)
    
    var jhpb_wx = $bg/选项组/sc2/VBoxContainer/hbox/jhb/pb
    create_phb(Lm.jhph_wx,jhpb_wx)
    
    var jhpb_js = $"bg/选项组/sc2/VBoxContainer/hbox/jhb2/pb"
    create_phb(Lm.jhph_js,jhpb_js)
    
    var jhpb_ys = $"bg/选项组/sc2/VBoxContainer/hbox/jhb3/pb"
    create_phb(Lm.jhph_ys,jhpb_ys)
    
    var jhpb_jz = $"bg/选项组/sc1/VBoxContainer/hbox/jzb/pb"
    create_labels_jz(Lm.jhph_jz,jhpb_jz)
    
    var jzjl = $"bg/选项组/sc4/VBoxContainer/VBoxContainer/ScrollContainer/VBoxContainer"
    create_jzjl(Lm.donate_data,jzjl)
    var zl = "您好！%s 欢迎加入博客江湖！" % [Blogger.blog_data.blog_name]
    $"bg/选项组/sc1/VBoxContainer/hbox/zl2/VBoxContainer/Label".text = zl

    
func create_phb(arr,node):
    Utils.clear_children(node)
    var newarr = arr.slice(0,10)
    create_labels(newarr,node)
    


func _on_button_pressed() -> void:
    emit_signal("close_lm")


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

func create_labels(jh, node):
    for i in range(jh.size()):
        var label = Label.new()
        var dw = Utils.get_rank_title(jh[i].lv, Strs.game_strs.头衔)
        label.text = "%d.%s lv:%d %s" % [i+1, jh[i].blog_name, jh[i].lv, dw]
        node.add_child(label)
        
func create_labels_jz(jh, node):
    Utils.clear_children(node)
    var arr = jh.slice(0,10)
    for i in range(arr.size()):
        var label = Label.new()
        var tmp_b = Lm.find_by_id(arr[i][0])
        label.text = "%d.%s 捐赠:%d元" % [i+1, tmp_b.blog_name, arr[i][1]]
        node.add_child(label)

func create_jzjl(data,node):
    print('start')
    Utils.clear_children(node)
    for d in data:
        var lb = Label.new()
        var blog = Lm.find_by_id(d[0])
        lb.text = "%s %s捐赠：%d元" % [blog.blog_name,blog.blog_author,d[1]]
        node.add_child(lb)

## 加入联盟
func _join_lm() -> void:
    Lm.join_lm()
    $"bg/选项组/sc1/VBoxContainer/hbox/zl".visible = false
    $"bg/选项组/sc1/VBoxContainer/hbox/zl2".visible = true
    
    on_show_panel()


func _on_exit_lm() -> void:
    Lm.exit_lm()
    $"bg/选项组/sc1/VBoxContainer/hbox/zl".visible = true
    $"bg/选项组/sc1/VBoxContainer/hbox/zl2".visible = false
    on_show_panel()
