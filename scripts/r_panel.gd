extends Control

@export var max_messages: int = 10 # 设置最大显示信息条数
@onready var message_container: VBoxContainer # 获取 VBoxContainer 节点
@onready var sc: ScrollContainer # 获取 ScrollContainer 节点


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    message_container = get_node("bot/Sm/VBm") # 根据你的节点树结构调整路径
    sc = get_node("bot/Sm") # 根据你的节点树结构调整路径


func add_message(text: String):
    var new_label = Label.new()
    new_label.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
    new_label.text = text
    message_container.add_child(new_label)

    # 检查是否超出最大信息条数，超出则删除旧的信息
    if message_container.get_child_count() > max_messages:
        var old_message = message_container.get_child(0)
        message_container.remove_child(old_message)
        old_message.queue_free() # 正确的用法，不带参数

    # (可选) 滚动到底部，以便看到最新的信息
    if message_container.get_parent() is ScrollContainer:
        message_container.get_parent().set_deferred("scroll_vertical",  message_container.size.y - sc.size.y);

func clear_messages():
    # 清空所有显示的信息
    for child in message_container.get_children():
        message_container.remove_child(child)
        child.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
