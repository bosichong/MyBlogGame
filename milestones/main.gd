extends Control

@onready var m_vb = $"bg/选项组/sc1/VBoxContainer/ScrollContainer/m_hbox"
@onready var sc1 = $"bg/选项组/sc1"
@onready var sc2 = $"bg/选项组/sc2"
@onready var b1 = $"bg/btn_group/vb/mc1/b1"
@onready var b2 = $"bg/btn_group/vb/mc2/b2"

@onready var chapter_btn_vbox = $"bg/选项组/sc2/VBoxContainer/hbox_main/chapter_list"
@onready var chapter_title = $"bg/选项组/sc2/VBoxContainer/hbox_main/content/title"
@onready var progress_bar = $"bg/选项组/sc2/VBoxContainer/hbox_main/content/progress_hbox/bar"
@onready var count_label = $"bg/选项组/sc2/VBoxContainer/hbox_main/content/progress_hbox/count_label"
@onready var milestone_vbox = $"bg/选项组/sc2/VBoxContainer/hbox_main/content/scroll/milestone_vbox"

signal close_mialestones

var _tab_group := ButtonGroup.new()
var _chapter_inited := false
var current_chapter := 1

func setup_ui():
	b1.button_group = _tab_group
	b2.button_group = _tab_group
	b1.button_pressed = true
	sc1.visible = true
	sc2.visible = false

	Utils.clear_children(m_vb)
	var milestones = GDManager.milestones
	for m in milestones.lv:
		var milestone_instance = load("res://milestones/mile.tscn").instantiate()
		milestone_instance.set_milestone_data(m.icon, m.name, m.unlocked, m.locked_icon, m.description)
		milestone_instance.custom_minimum_size = Vector2(70, 90)
		m_vb.add_child(milestone_instance)

func _init_chapter_progress():
	_chapter_inited = true
	Utils.clear_children(chapter_btn_vbox)
	var group = ButtonGroup.new()
	for i in range(1, 6):
		var btn = Button.new()
		btn.text = "第%d章" % i
		btn.toggle_mode = true
		btn.button_group = group
		btn.custom_minimum_size = Vector2(0, 36)
		btn.pressed.connect(_on_chapter_btn_pressed.bind(i))
		chapter_btn_vbox.add_child(btn)

func _refresh_chapter():
	var sp = GDManager.get_story_progress()
	var progress = sp.get_chapter_progress(current_chapter)
	chapter_title.text = sp.get_chapter_name(current_chapter)
	progress_bar.max_value = progress.total
	progress_bar.value = progress.completed
	progress_bar.show_percentage = false
	count_label.text = "%d/%d" % [progress.completed, progress.total]

	Utils.clear_children(milestone_vbox)
	var milestones = sp.get_chapter_milestones(current_chapter)
	for key in milestones:
		var done = milestones[key]
		var desc = sp.get_milestone_description(current_chapter, key)
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		var icon = Label.new()
		icon.text = "✓" if done else "○"
		icon.custom_minimum_size = Vector2(20, 0)
		icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var label = Label.new()
		label.text = desc
		label.modulate = Color(1, 1, 1) if done else Color(0.6, 0.6, 0.6)
		row.add_child(icon)
		row.add_child(label)
		milestone_vbox.add_child(row)

func _on_chapter_btn_pressed(chapter: int):
	current_chapter = chapter
	_refresh_chapter()

func _on_b1_toggled(btn_pressed: bool):
	if btn_pressed:
		sc1.visible = true
		sc2.visible = false

func _on_b2_toggled(btn_pressed: bool):
	if btn_pressed:
		sc1.visible = false
		sc2.visible = true
		if not _chapter_inited:
			_init_chapter_progress()
		_refresh_chapter()

func _on_close_pressed() -> void:
	emit_signal("close_mialestones")
