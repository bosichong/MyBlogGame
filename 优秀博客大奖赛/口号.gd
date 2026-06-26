extends Node2D

const AMPLITUDE := 6.0
const SPEED := 1.5

var _time := 0.0
var _sprite1: Sprite2D
var _sprite2: Sprite2D
var _base_y1: float
var _base_y2: float


func _ready() -> void:
    _sprite1 = $口号2 as Sprite2D
    _sprite2 = $Sprite2D as Sprite2D
    _base_y1 = _sprite1.position.y
    _base_y2 = _sprite2.position.y


func _process(delta: float) -> void:
    _time += delta * SPEED
    _sprite1.position.y = _base_y1 + sin(_time) * AMPLITUDE
    _sprite2.position.y = _base_y2 + sin(_time + PI * 0.7) * AMPLITUDE
