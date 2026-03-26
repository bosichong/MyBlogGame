# GlobalDataManager.gd
extends Node

# ===== 存储所有加载的数据（向后兼容）=====
var loaded_data = {}

# 数据配置 - 定义要加载的数据文件
var data_configs = {
    "milestones": "res://milestones/config.gd",
}

# ===== 数据容器 =====
var data_container: DataContainer = DataContainer.new()

# ===== 管理器 =====
var save_manager: SaveManager = SaveManager.new()
var config_manager: ConfigManager = ConfigManager.new()

# ===== 信号 =====
signal money_changed(new_money: float)
signal level_changed(new_level: int)
signal day_passed
signal week_passed
signal month_passed
signal year_passed
signal game_loaded(slot: int)
signal game_saved(slot: int)

func _ready():
    # 添加管理器为子节点
    add_child(save_manager)
    add_child(config_manager)

    # 加载所有配置数据
    load_all_data()

    # 连接数据容器的信号
    connect_data_signals()

    # 加载静态配置
    config_manager.load_all_configs()
    data_container.static_config = config_manager.get_static_config()

# ===== 向后兼容：加载配置数据 =====

func load_all_data():
    for data_name in data_configs:
        load_data(data_name, data_configs[data_name])

func load_data(name: String, script_path: String):
    if ResourceLoader.exists(script_path):
        var script = load(script_path)
        var data_instance = script.new()
        loaded_data[name] = data_instance
        print("Loaded data: ", name)
    else:
        print("Warning: Data file not found: ", script_path)

func _get(property):
    if property in loaded_data:
        return loaded_data[property]
    return null

func _set(property, value):
    if property in data_configs:
        loaded_data[property] = value
        return true
    return false

func _has_property(property):
    return property in loaded_data

func _get_property_list():
    var properties = []
    for name in data_configs:
        properties.append({
            "name": name,
            "type": TYPE_OBJECT,
            "usage": PROPERTY_USAGE_SCRIPT_VARIABLE
        })
    return properties

func get_data(name: String):
    return loaded_data.get(name)

func has_data(name: String) -> bool:
    return name in loaded_data

func reload_data(name: String):
    if name in data_configs:
        var script_path = data_configs[name]
        var script = load(script_path)
        var data_instance = script.new()
        loaded_data[name] = data_instance

func reload_all_data():
    loaded_data.clear()
    for name in data_configs:
        reload_data(name)

func save_data(name: String, save_path: String):
    if name in loaded_data:
        ResourceSaver.save(loaded_data[name], save_path)

# ===== 信号连接 =====

func connect_data_signals():
    var blogger = data_container.get_blogger()
    var time = data_container.get_time()
    var bank = data_container.get_bank()
    var ad = data_container.get_ad()

    if blogger:
        blogger.connect("level_changed", _on_blogger_level_changed)
        blogger.connect("exp_changed", _on_blogger_exp_changed)
        blogger.connect("blog_views_changed", _on_blogger_views_changed)

    if time:
        time.connect("day_passed", _on_time_day_passed)
        time.connect("week_passed", _on_time_week_passed)
        time.connect("month_passed", _on_time_month_passed)
        time.connect("year_passed", _on_time_year_passed)

    if bank:
        bank.connect("balance_changed", _on_bank_balance_changed)

    if ad:
        ad.connect("commission_earned", _on_ad_commission_earned)

    if save_manager:
        save_manager.connect("save_completed", _on_save_completed)
        save_manager.connect("load_completed", _on_load_completed)

# ===== 信号处理函数 =====

func _on_blogger_level_changed(new_level: int):
    emit_signal("level_changed", new_level)

func _on_blogger_exp_changed(new_exp: int):
    pass

func _on_blogger_views_changed(new_views: int):
    pass

func _on_time_day_passed():
    emit_signal("day_passed")

func _on_time_week_passed():
    emit_signal("week_passed")

func _on_time_month_passed():
    emit_signal("month_passed")

func _on_time_year_passed():
    emit_signal("year_passed")

func _on_bank_balance_changed(new_balance: float):
    var blogger = data_container.get_blogger()
    blogger.money = new_balance
    emit_signal("money_changed", new_balance)

func _on_ad_commission_earned(amount: float):
    pass

func _on_save_completed(slot: int, success: bool):
    if success:
        emit_signal("game_saved", slot)

func _on_load_completed(slot: int, success: bool):
    if success:
        emit_signal("game_loaded", slot)

# ===== 数据访问快捷方法 =====

func get_blogger() -> BloggerData:
    return data_container.get_blogger()

func get_time() -> TimeData:
    return data_container.get_time()

func get_bank() -> BankData:
    return data_container.get_bank()

func get_ad() -> AdData:
    return data_container.get_ad()

func get_statistics() -> StatisticsData:
    return data_container.get_statistics()

func get_task() -> TaskData:
    return data_container.get_task()

func get_league() -> LeagueData:
    return data_container.get_league()

func get_static_config() -> StaticConfig:
    return data_container.get_static_config()

# ===== 常用数据访问方法 =====

func get_level() -> int:
    return data_container.get_blogger().level

func set_level(new_level: int):
    data_container.get_blogger().set_level(new_level)

func get_money() -> float:
    return data_container.get_blogger().money

func add_money(amount: float):
    var blogger = data_container.get_blogger()
    blogger.money += amount
    emit_signal("money_changed", blogger.money)

func deduct_money(amount: float) -> bool:
    var blogger = data_container.get_blogger()
    if blogger.money >= amount:
        blogger.money -= amount
        emit_signal("money_changed", blogger.money)
        return true
    return false

func get_current_date() -> String:
    return data_container.get_time().get_formatted_date()

func advance_day():
    data_container.get_time().advance_day()

# ===== 存档管理方法 =====

func save_game(slot: int = 0) -> Dictionary:
    return save_manager.save_game(slot, data_container)

func load_game(slot: int = 0) -> Dictionary:
    var result = save_manager.load_game(slot)
    if result.get("success", false):
        var save_data = result.get("data", {})
        if save_data.has("runtime_data"):
            data_container.runtime_data = save_manager.deserialize_runtime_data(save_data["runtime_data"])
            connect_data_signals()
    return result

func delete_save(slot: int) -> bool:
    return save_manager.delete_save(slot)

func list_saves() -> Array:
    return save_manager.list_saves()

func auto_save() -> Dictionary:
    return save_manager.auto_save(data_container)

# ===== 配置管理方法 =====

func get_config() -> StaticConfig:
    return config_manager.get_static_config()

func reload_configs():
    config_manager.reload_configs()
    data_container.static_config = config_manager.get_static_config()
