extends Control

@onready var m_vb = $"Panel/注册/ScrollContainer/VBoxContainer/HBoxContainer"

signal close_mialestones

func _ready() -> void:
    pass

func setup_ui():
    Utils.clear_children(m_vb)
    # 直接访问里程碑数据
    var milestones = GDManager.milestones
    for m in milestones.lv:
        # 创建场景实例
        var milestone_instance = load("res://milestones/mile.tscn").instantiate()
        # 设置数据
        milestone_instance.set_milestone_data(m.icon, m.name,m.unlocked,m.locked_icon,m.description)
        # 设置自定义最小大小
        milestone_instance.custom_minimum_size = Vector2(70, 90)  # 调整为合适的大小
        # 添加到容器
        m_vb.add_child(milestone_instance)  # 注意：应该是add_child而不是add

func _on_close_pressed() -> void:
    emit_signal("close_mialestones")
