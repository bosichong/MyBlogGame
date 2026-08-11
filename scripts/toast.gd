extends Control
## 顶部横幅提示（非阻塞 toast）
## 挂在场景根部，通过 add_toast() 弹出；3 秒自动淡出，不暂停游戏计时器。
## tone 决定配色；key 相同时自动合并（更新内容、重置时长，不新增横幅）。

enum Tone { INFO, SUCCESS, LEVELUP, DANGER, TITLE }

const TONE_COLORS := {
    Tone.INFO: Color(0.66, 0.70, 0.76),
    Tone.SUCCESS: Color(0.30, 0.85, 0.45),
    Tone.LEVELUP: Color(1.0, 0.78, 0.22),
    Tone.DANGER: Color(0.96, 0.38, 0.33),
    Tone.TITLE: Color(0.84, 0.64, 1.0),
}

const DURATION := 3.0
const FADE_IN := 0.22
const FADE_OUT := 0.28
const TOAST_MIN_WIDTH := 360.0
const BOX_WIDTH := 400.0
const BOX_TOP := 46.0

var _last_key := ""
var _last_item: Control = null


## 弹出横幅。key 非空时：与上一条同 key 则合并更新，否则记为最新一条。
func add_toast(title: String, content: String, tone: int = Tone.INFO, key: String = "") -> void:
    if key != "" and key == _last_key and is_instance_valid(_last_item):
        _merge_item(_last_item, title, content, tone)
        return

    var item := _build_item(title, content, tone)
    var box := get_node_or_null("Box")
    if box == null:
        return
    _layout_box(box)
    box.add_child(item)
    box.move_child(item, 0)
    if key != "":
        _last_key = key
        _last_item = item
    Sfx.play("popup_open")
    _run_tween(item)


func _layout_box(box: Control) -> void:
    box.anchor_left = 0.0
    box.anchor_top = 0.0
    box.anchor_right = 0.0
    box.anchor_bottom = 0.0
    var vr := get_viewport().get_visible_rect()
    box.position = Vector2((vr.size.x - BOX_WIDTH) * 0.5, BOX_TOP)
    box.size = Vector2(BOX_WIDTH, maxf(vr.size.y - BOX_TOP, 0.0))


func _build_item(title: String, content: String, tone: int) -> PanelContainer:
    var accent: Color = TONE_COLORS[tone]

    var panel := PanelContainer.new()
    panel.custom_minimum_size = Vector2(TOAST_MIN_WIDTH, 0)
    panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var sb := StyleBoxFlat.new()
    sb.bg_color = Color(0.07, 0.09, 0.12, 0.94)
    sb.set_corner_radius_all(8)
    sb.content_margin_left = 14.0
    sb.content_margin_right = 14.0
    sb.content_margin_top = 9.0
    sb.content_margin_bottom = 9.0
    sb.border_width_left = 5
    sb.border_color = accent
    panel.add_theme_stylebox_override("panel", sb)

    var mc := MarginContainer.new()
    mc.name = "Margin"
    mc.add_theme_constant_override("margin_left", 6)
    mc.add_theme_constant_override("margin_right", 2)
    panel.add_child(mc)

    var vb := VBoxContainer.new()
    vb.name = "VBox"
    vb.add_theme_constant_override("separation", 2)
    mc.add_child(vb)

    var tl := Label.new()
    tl.name = "Title"
    tl.text = title
    tl.mouse_filter = Control.MOUSE_FILTER_IGNORE
    tl.add_theme_font_size_override("font_size", 18)
    tl.add_theme_color_override("font_color", accent)
    vb.add_child(tl)

    var cl := Label.new()
    cl.name = "Content"
    cl.text = content
    cl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    cl.mouse_filter = Control.MOUSE_FILTER_IGNORE
    cl.add_theme_font_size_override("font_size", 13)
    cl.add_theme_color_override("font_color", Color(0.93, 0.94, 0.96, 0.96))
    vb.add_child(cl)

    panel.modulate.a = 0.0
    return panel


func _run_tween(item: Control) -> void:
    var tw := create_tween()
    item.set_meta("toast_tween", tw)
    tw.tween_property(item, "modulate:a", 1.0, FADE_IN)
    tw.tween_interval(DURATION)
    tw.tween_property(item, "modulate:a", 0.0, FADE_OUT)
    tw.tween_callback(_free_item.bind(item))


func _merge_item(item: Control, title: String, content: String, tone: int) -> void:
    var old = item.get_meta("toast_tween")
    if old != null and (old as Tween).is_valid():
        old.kill()
    var accent: Color = TONE_COLORS[tone]
    var title_label: Label = item.get_node("Margin/VBox/Title")
    var content_label: Label = item.get_node("Margin/VBox/Content")
    title_label.text = title
    content_label.text = content
    title_label.add_theme_color_override("font_color", accent)
    var sb: StyleBoxFlat = item.get_theme_stylebox("panel")
    sb.border_color = accent
    Sfx.play("popup_open")
    _run_tween(item)


func _free_item(item: Control) -> void:
    if is_instance_valid(item):
        item.set_meta("toast_tween", null)
        item.queue_free()
