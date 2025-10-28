# GlobalDataManager.gd
extends Node

# 存储所有加载的数据
var loaded_data = {}

# 数据配置 - 定义要加载的数据文件
var data_configs = {
    "milestones": "res://milestones/config.gd",
    # 添加更多数据配置...
}

func _ready():
    load_all_data()

# 加载所有数据
func load_all_data():
    for data_name in data_configs:
        load_data(data_name, data_configs[data_name])

# 加载特定数据
func load_data(name: String, script_path: String):
    if ResourceLoader.exists(script_path):
        var script = load(script_path)
        var data_instance = script.new()
        loaded_data[name] = data_instance
        print("Loaded data: ", name)
    else:
        print("Warning: Data file not found: ", script_path)

# 重写 _get 方法，允许点号访问
func _get(property):
    if property in loaded_data:
        return loaded_data[property]
    return null

# 重写 _set 方法，允许点号设置
func _set(property, value):
    if property in data_configs:  # 只允许设置已配置的数据
        loaded_data[property] = value
        return true
    return false

# 检查属性是否存在
func _has_property(property):
    return property in loaded_data

# 重写 _get_property_list 方法，让编辑器知道这些属性
func _get_property_list():
    var properties = []
    for name in data_configs:
        properties.append({
            "name": name,
            "type": TYPE_OBJECT,
            "usage": PROPERTY_USAGE_SCRIPT_VARIABLE
        })
    return properties

# 动态获取数据（如果需要）
func get_data(name: String):
    return loaded_data.get(name)

# 检查是否有数据
func has_data(name: String) -> bool:
    return name in loaded_data

# 刷新特定数据
func reload_data(name: String):
    if name in data_configs:
        var script_path = data_configs[name]
        var script = load(script_path)
        var data_instance = script.new()
        loaded_data[name] = data_instance

# 刷新所有数据
func reload_all_data():
    loaded_data.clear()
    for name in data_configs:
        reload_data(name)

# 保存数据（如果需要持久化）
func save_data(name: String, save_path: String):
    if name in loaded_data:
        ResourceSaver.save(loaded_data[name], save_path)
