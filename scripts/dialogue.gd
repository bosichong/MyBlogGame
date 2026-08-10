extends Control

## 多人对话展示场景
## 读取 DialogueManager.current_id 对应的对白并逐条播放
## 布局：玩家（side=="right"）在右侧，NPC 在左侧，中间为对白框

const DEFAULT_INTERVAL := 3.0
const PANEL_SIZE := Vector2(600, 150)
const HINT_NORMAL := "␣ 空格 / 点击  继续"
const HINT_CHOICE := "↑↓ 选择 · 回车 确定"
const SCREEN := Vector2(960, 480)

var dialogue_data: Dictionary = {}
var lines: Array = []
var current_index: int = 0
var auto_timer: Timer
var hint_anim: Tween
var finished: bool = false

# UI 引用
var title_label: Label
var speaker_label: Label
var text_label: RichTextLabel
var hint_label: Label
var avatar_left: Panel
var avatar_right: Panel
var choices_box: VBoxContainer
var dialogue_panel: PanelContainer
var bg: ColorRect

func _ready() -> void:
	var id := DialogueManager.current_id
	if not GDManager.has_data("dialogue_" + id):
		GDManager.load_dialogue(id, "res://data/dialogue/%s.gd" % id)
	dialogue_data = GDManager.get_dialogue(id)
	if dialogue_data.is_empty():
		id = "example"
		dialogue_data = GDManager.get_dialogue(id)
	if dialogue_data.is_empty():
		push_error("对话数据为空，无法播放")
		_finish()
		return
	lines = dialogue_data.get("lines", [])
	if lines.is_empty():
		_finish()
		return
	_build_ui()
	_show_line(0)
func _unhandled_input(event: InputEvent) -> void:
	if finished:
		return
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_finish()
		return
	if event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		var line := _current_line()
		if line.is_empty() or not line.has("choices"):
			_advance()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _current_line().is_empty() or not _current_line().has("choices"):
			_advance()

# ===== 数据准备 =====
func _get_character(char_name: String) -> Dictionary:
	var chars = GDManager.get_dialogue_characters()
	if chars and chars.has_method("resolve_character"):
		var blogger = GDManager.get_blogger()
		var blogger_author := ""
		if blogger:
			blogger_author = str(blogger.blog_author)
		return chars.resolve_character(char_name, blogger_author, GDManager.get_lm_members())
	return {"name": char_name, "display": char_name, "color": Color(0.6, 0.6, 0.6)}

func _current_line() -> Dictionary:
	if current_index < 0 or current_index >= lines.size():
		return {}
	return lines[current_index]

# ===== UI 构建 =====
func _build_ui() -> void:
	bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.08, 0.09, 0.13)
	add_child(bg)

	var title := Label.new()
	title.position = Vector2(16, 12)
	title.add_theme_font_size_override("font_size", 24)
	title.text = str(dialogue_data.get("title", ""))
	bg.add_child(title)
	title_label = title

	avatar_left = _make_avatar(Vector2(24, 180))
	avatar_right = _make_avatar(Vector2(864, 180))
	bg.add_child(avatar_left)
	bg.add_child(avatar_right)

	dialogue_panel = PanelContainer.new()
	dialogue_panel.position = Vector2((SCREEN.x - PANEL_SIZE.x) / 2.0, 280)
	dialogue_panel.custom_minimum_size = PANEL_SIZE
	bg.add_child(dialogue_panel)
	dialogue_panel.gui_input.connect(_gui_input)

	var box := VBoxContainer.new()
	dialogue_panel.add_child(box)

	speaker_label = Label.new()
	speaker_label.add_theme_font_size_override("font_size", 20)
	box.add_child(speaker_label)

	text_label = RichTextLabel.new()
	text_label.custom_minimum_size = Vector2(PANEL_SIZE.x - 24, 64)
	text_label.bbcode_enabled = false
	text_label.fit_content = true
	box.add_child(text_label)

	choices_box = VBoxContainer.new()
	choices_box.visible = false
	box.add_child(choices_box)

	hint_label = Label.new()
	hint_label.position = Vector2(SCREEN.x - 240, SCREEN.y - 28)
	bg.add_child(hint_label)

func _make_avatar(pos: Vector2) -> Panel:
	var panel := Panel.new()
	panel.position = pos
	panel.size = Vector2(72, 72)
	return panel

func _set_avatar(panel: Panel, char_data: Dictionary) -> void:
	_clear_avatar(panel)
	var avatar := str(char_data.get("avatar", ""))
	if avatar != "":
		if avatar.begins_with("res://"):
			var tex = load(avatar)
			if tex is Texture2D:
				_show_avatar_texture(panel, tex)
				return
		elif avatar.begins_with("http://") or avatar.begins_with("https://"):
			_show_avatar_fallback(panel, char_data)
			_load_remote_avatar(panel, avatar)
			return
	_show_avatar_fallback(panel, char_data)

func _clear_avatar(panel: Panel) -> void:
	for child in panel.get_children():
		child.queue_free()

func _show_avatar_fallback(panel: Panel, char_data: Dictionary) -> void:
	var rect := ColorRect.new()
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.color = char_data.get("color", Color(0.6, 0.6, 0.6))
	panel.add_child(rect)
	var lbl := Label.new()
	lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	lbl.text = str(char_data.get("display", "?")).substr(0, 1)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 34)
	panel.add_child(lbl)

func _show_avatar_texture(panel: Panel, tex: Texture2D) -> void:
	panel.size = tex.get_size()
	var tr := TextureRect.new()
	tr.texture = tex
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tr.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_child(tr)

func _load_remote_avatar(panel: Panel, url: String) -> void:
	var http := HTTPRequest.new()
	http.timeout = 8.0
	http.request_completed.connect(_on_avatar_downloaded.bind(panel))
	panel.add_child(http)
	http.request(url)

func _on_avatar_downloaded(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, panel: Panel) -> void:
	if not is_instance_valid(panel) or not panel.is_inside_tree():
		return
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200 or body.is_empty():
		return
	var img := Image.new()
	var err := img.load_png_from_buffer(body)
	if err != OK:
		err = img.load_jpg_from_buffer(body)
	if err != OK:
		return
	_clear_avatar(panel)
	_show_avatar_texture(panel, ImageTexture.create_from_image(img))

# ===== 播放逻辑 =====
func _show_line(index: int) -> void:
	current_index = index
	_clear_choices()
	var line := _current_line()
	if line.is_empty():
		_finish()
		return
	var char_data := _get_character(str(line.get("speaker", "")))
	var is_player: bool = str(line.get("speaker", "")) == "player" or str(char_data.get("side", "")) == "right"

	speaker_label.text = str(char_data.get("display", "?"))
	text_label.text = str(line.get("text", ""))
	title_label.text = str(dialogue_data.get("title", ""))

	if is_player:
		_set_avatar(avatar_right, char_data)
		avatar_right.position.x = SCREEN.x - avatar_right.size.x - 24
		avatar_right.visible = true
		avatar_left.visible = false
	else:
		_set_avatar(avatar_left, char_data)
		avatar_left.position.x = 24
		avatar_left.visible = true
		avatar_right.visible = false

	if line.has("choices"):
		_stop_timer()
		hint_label.text = HINT_CHOICE
		_show_choices(line["choices"])
	else:
		hint_label.text = HINT_NORMAL
		_start_timer(float(line.get("duration", dialogue_data.get("auto_interval", DEFAULT_INTERVAL))))
	_start_hint_blink()

func _show_choices(choices: Array) -> void:
	for c in choices:
		var btn := Button.new()
		btn.text = str(c.get("text", ""))
		btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		Sfx.wire(btn)
		btn.pressed.connect(_on_choice.bind(c))
		choices_box.add_child(btn)
	choices_box.visible = true
	if choices.size() > 0:
		choices_box.get_child(0).grab_focus()

func _clear_choices() -> void:
	for child in choices_box.get_children():
		child.queue_free()
	choices_box.visible = false

func _on_choice(choice: Dictionary) -> void:
	var target := str(choice.get("next", ""))
	var target_index := _find_label_index(target)
	if target_index >= 0:
		_show_line(target_index)
	else:
		_advance()

func _find_label_index(label: String) -> int:
	for i in lines.size():
		if str(lines[i].get("label", "")) == label:
			return i
	return -1

func _advance() -> void:
	if finished:
		return
	var line := _current_line()
	if line.has("goto"):
		var gi := _find_label_index(str(line["goto"]))
		if gi >= 0:
			_show_line(gi)
		else:
			_finish()
		return
	if line.has("end"):
		_finish()
		return
	if current_index + 1 < lines.size():
		_show_line(current_index + 1)
	else:
		_finish()

func _start_hint_blink() -> void:
	if hint_anim:
		hint_anim.kill()
	hint_label.modulate.a = 1.0
	hint_anim = create_tween()
	hint_anim.set_loops()
	hint_anim.tween_interval(0.5)
	hint_anim.tween_property(hint_label, "modulate:a", 0.25, 0.4)
	hint_anim.tween_interval(0.5)
	hint_anim.tween_property(hint_label, "modulate:a", 1.0, 0.4)

func _start_timer(interval: float) -> void:
	_stop_timer()
	auto_timer = Timer.new()
	auto_timer.one_shot = true
	auto_timer.wait_time = maxf(interval, 0.1)
	auto_timer.timeout.connect(_advance)
	add_child(auto_timer)
	auto_timer.start()

func _stop_timer() -> void:
	if auto_timer:
		auto_timer.stop()
		auto_timer.queue_free()
		auto_timer = null

func _finish() -> void:
	finished = true
	_stop_timer()
	if hint_anim:
		hint_anim.kill()
	var after := str(dialogue_data.get("after_finish", ""))
	if after != "":
		Utils.goto_scene(after)
	else:
		DialogueManager.notify_finished(str(dialogue_data.get("id", "")))
		# 调试场景发起时回到调试面板，便于循环调试
		if DialogueManager.from_test:
			DialogueManager.return_from_dialogue = true
			Utils.goto_scene("res://tests/test_dialogue_scene.tscn")