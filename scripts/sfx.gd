extends Node

## 全局 UI 音效管理器
## 使用：Sfx.play("click") / Sfx.wire(btn) / Sfx.wire_tree(root)

const UI_SOUNDS := {
    "click": preload("res://assets/sound/400 Sounds Pack/UI/select_1.wav"),
    "hover": preload("res://assets/sound/400 Sounds Pack/UI/sci_fi_hover.wav"),
    "cancel": preload("res://assets/sound/400 Sounds Pack/UI/sci_fi_cancel.wav"),
    "popup_open": preload("res://assets/sound/400 Sounds Pack/UI/pop_2.wav"),
    "popup_close": preload("res://assets/sound/400 Sounds Pack/UI/pop_1.wav"),
    "error": preload("res://assets/sound/400 Sounds Pack/UI/sci_fi_error.wav"),
}

const PLAYER_COUNT := 6
const UI_BUS_NAME := "UI"

var _players: Array[AudioStreamPlayer] = []
var _idx := 0

func _ready() -> void:
    _ensure_ui_bus()
    for i in PLAYER_COUNT:
        var p := AudioStreamPlayer.new()
        p.bus = UI_BUS_NAME
        add_child(p)
        _players.append(p)
    get_tree().node_added.connect(_on_node_added)

## 自动接线：任意 BaseButton 加入场景树即配音（含动态弹窗/独立场景按钮）
func _on_node_added(node: Node) -> void:
    if node is BaseButton:
        wire(node)

func _ensure_ui_bus() -> void:
    if AudioServer.get_bus_index(UI_BUS_NAME) == -1:
        AudioServer.add_bus()
        var idx := AudioServer.get_bus_count() - 1
        AudioServer.set_bus_name(idx, UI_BUS_NAME)
        AudioServer.set_bus_send(idx, "Master")

## 播放音效（自动挑选空闲播放器，避免快速连点截断）
func play(name: String, volume_db := 0.0) -> void:
    if not UI_SOUNDS.has(name):
        push_warning("未注册的UI音效: %s" % name)
        return
    var player := _pick_player()
    player.stream = UI_SOUNDS[name]
    player.volume_db = volume_db
    player.play()

func _pick_player() -> AudioStreamPlayer:
    for p in _players:
        if not p.playing:
            return p
    var p := _players[_idx]
    _idx = (_idx + 1) % _players.size()
    return p

## 给单个按钮接点击音（重复调用自动跳过）
func wire(btn: BaseButton, pressed := "click") -> void:
    if not is_instance_valid(btn) or btn.has_meta("sfx_wired"):
        return
    btn.set_meta("sfx_wired", true)
    btn.pressed.connect(func(): play(pressed))

## 递归遍历 root 下所有按钮批量接线
func wire_tree(root: Node) -> void:
    if root == null:
        return
    for child in root.find_children("*", "BaseButton", true, false):
        wire(child)
