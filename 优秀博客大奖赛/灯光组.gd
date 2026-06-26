extends Node2D

var light_nodes: Array[Sprite2D] = []
var rot_origins: Array[float] = []
var rot_amps: Array[float] = []
var rot_speeds: Array[float] = []
var rot_phases: Array[float] = []
var alpha_origins: Array[float] = []
var alpha_amps: Array[float] = []
var alpha_speeds: Array[float] = []
var alpha_phases: Array[float] = []

func _ready() -> void:
    for i in range(1, 5):
        var node = get_node("灯光" + str(i)) as Sprite2D
        if node:
            light_nodes.append(node)
            rot_origins.append(node.rotation)
            rot_amps.append(randf_range(0.05, 0.2))
            rot_speeds.append(randf_range(0.4, 1.5))
            rot_phases.append(randf_range(0, TAU))
            alpha_origins.append(node.modulate.a)
            alpha_amps.append(randf_range(0.12, 0.25))
            alpha_speeds.append(randf_range(0.3, 1.2))
            alpha_phases.append(randf_range(0, TAU))

func _process(delta: float) -> void:
    var t = Time.get_ticks_msec() / 1000.0
    for i in light_nodes.size():
        var c = light_nodes[i].modulate
        c.a = clamp(alpha_origins[i] + sin(t * alpha_speeds[i] + alpha_phases[i]) * alpha_amps[i], 0, 1)
        light_nodes[i].modulate = c
        light_nodes[i].rotation = rot_origins[i] + sin(t * rot_speeds[i] + rot_phases[i]) * rot_amps[i]
