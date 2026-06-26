extends Node2D

# 撒花特效：在屏幕上生成彩色纸片并下落，适用于奖励/成就弹窗等场景
#
# 调用方式：
#   var confetti = preload("res://scenes/confetti.tscn").instantiate()
#   add_child(confetti)
#   confetti.emit()
#
# 如果 auto_emit = false，可反复调用 emit() 多次触发

class ConfettiPiece:
    var x: float           # 纸片 X 坐标
    var y: float           # 纸片 Y 坐标
    var vx: float          # X 方向速度（左右飘动）
    var vy: float          # Y 方向速度（下落/弹起）
    var color: Color       # 纸片颜色
    var w: float           # 纸片宽度
    var h: float           # 纸片高度
    var rot: float         # 当前旋转角度（弧度）
    var rot_speed: float   # 旋转角速度（弧度/秒）
    var life: float        # 剩余生命值（秒）
    var max_life: float    # 初始生命值（用于计算透明度）

# 8 种纸片颜色
const COLORS: Array[Color] = [
    Color(1.0, 0.2, 0.2),   # 红
    Color(0.2, 0.8, 1.0),   # 蓝
    Color(1.0, 0.8, 0.0),   # 黄
    Color(0.2, 1.0, 0.2),   # 绿
    Color(1.0, 0.4, 0.7),   # 粉
    Color(1.0, 0.6, 0.0),   # 橙
    Color(0.6, 0.2, 1.0),   # 紫
    Color(0.0, 1.0, 0.8),   # 青
]

# 所有纸片实例列表
var pieces: Array[ConfettiPiece] = []
# 是否正在播放撒花动画
var emitting: bool = false

# --- 导出属性（可在编辑器中调整）---
# 纸片数量
@export var count: int = 100
# 纸片存活时长（秒），实际值会在 0.7~1.0 倍之间随机
@export var lifetime: float = 4.0
# 场景加载后是否自动播放撒花效果
@export var auto_emit: bool = true

func _ready():
    z_index = 128
    if auto_emit:
        call_deferred("emit")

# 触发撒花效果：在屏幕上方随机位置生成纸片并向上抛出
func emit():
    var screen = get_viewport_rect().size

    for i in range(count):
        var p = ConfettiPiece.new()
        p.x = randf_range(0, screen.x)
        p.y = randf_range(-screen.y * 0.3, -10)
        p.vx = randf_range(-80, 80)
        p.vy = randf_range(-250, -50)
        p.color = COLORS[randi() % COLORS.size()]
        p.w = randf_range(4, 10)
        p.h = randf_range(6, 14)
        p.rot = randf_range(0, TAU)
        p.rot_speed = randf_range(-PI, PI)
        p.life = randf_range(lifetime * 0.7, lifetime)
        p.max_life = p.life
        pieces.append(p)

    emitting = true

func _process(delta):
    if not emitting:
        return

    var all_dead = true
    var screen = get_viewport_rect().size

    for p in pieces:
        if p.life <= 0 or p.y > screen.y + 50:
            continue
        all_dead = false
        p.vy += 350 * delta  # 重力加速度
        p.x += p.vx * delta
        p.y += p.vy * delta
        p.rot += p.rot_speed * delta
        p.life -= delta

    queue_redraw()

    # 所有纸片消失后自动销毁节点（auto_emit = false 时由外部管理生命周期）
    if all_dead and auto_emit:
        queue_free()

func _draw():
    for p in pieces:
        if p.life <= 0:
            continue
        # 剩余生命 < 1.5 秒时开始渐隐
        var fade = min(p.max_life, 1.5)
        var a = clamp(p.life / fade, 0, 1)
        draw_set_transform(Vector2(p.x, p.y), p.rot)
        draw_rect(Rect2(-p.w / 2, -p.h / 2, p.w, p.h), Color(p.color, a))

    draw_set_transform(Vector2.ZERO, 0.0)
