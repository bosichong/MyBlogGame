extends VBoxContainer

var _cells: Array[ColorRect] = []
var _value_label: Label

const LIT_GREEN := Color(0.2, 0.9, 0.2, 1)
const LIT_YELLOW := Color(0.9, 0.8, 0.1, 1)
const LIT_RED := Color(0.9, 0.15, 0.15, 1)
const DIM_BG := Color(0.15, 0.15, 0.15, 1)

func _ready() -> void:
    _value_label = $ValueLabel
    var cells_container = $Cells
    if cells_container:
        for child in cells_container.get_children():
            if child is ColorRect:
                _cells.append(child)

    for cell in _cells:
        cell.color = DIM_BG

    if GDManager:
        GDManager.game_loaded.connect(_on_game_loaded)
    _refresh()

func _on_game_loaded(_slot: int) -> void:
    _refresh()

func _process(_delta: float) -> void:
    if GDManager:
        var blogger = GDManager.get_blogger()
        if blogger:
            _refresh()

func _refresh() -> void:
    if not GDManager:
        return
    var blogger = GDManager.get_blogger()
    if not blogger:
        return

    var val = blogger.safety_value
    if _value_label:
        _value_label.text = "安全指数：" + str(val)

    var lit_color: Color
    if val >= 80:
        lit_color = LIT_GREEN
    elif val >= 50:
        lit_color = LIT_YELLOW
    else:
        lit_color = LIT_RED

    for i in range(_cells.size()):
        if i * 10 < val:
            _cells[i].color = lit_color
        else:
            _cells[i].color = DIM_BG
