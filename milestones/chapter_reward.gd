extends Control

signal closed

@export var _title: String = "第一章 完成！"
@export var _rewards: Array = ["写作 +5", "技术 +5", "等级 +5", "金钱 +1000"]

@onready var panel: Panel = $Panel
@onready var title_label: Label = $Panel/Margin/Content/Title
@onready var reward_list: VBoxContainer = $Panel/Margin/Content/RewardList
@onready var confirm_btn: Button = $Panel/ConfirmButton
@onready var confetti: Node2D = $Confetti

func setup(title: String, rewards: Array):
    _title = title
    _rewards = rewards

func _ready():
    confetti.auto_emit = false
    title_label.text = _title
    confirm_btn.pressed.connect(_on_confirm)
    for r in _rewards:
        var lbl = Label.new()
        lbl.text = r
        lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        lbl.add_theme_color_override("font_color", Color(1, 1, 1))
        lbl.add_theme_font_size_override("font_size", 18)
        reward_list.add_child(lbl)

    modulate = Color(1, 1, 1, 0)
    var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.3)

    call_deferred("_start_confetti")

func _start_confetti():
    if confetti and confetti.has_method("emit"):
        confetti.emit()

func _on_confirm():
    var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
    tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.2)
    tween.finished.connect(_finish)

func _finish():
    closed.emit()
    queue_free()
