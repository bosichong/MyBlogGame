class_name ConfigManager extends Node

var static_config: StaticConfig = StaticConfig.new()

signal config_loaded
signal config_failed(error: String)

func _ready():
	load_all_configs()

# ===== 加载所有配置 =====

func load_all_configs():
	var success = true
	var errors = []

	# 加载文章类型配置
	if not load_post_categories():
		success = false
		errors.append("Failed to load post categories")

	# 加载技能配置
	if not load_skills_config():
		success = false
		errors.append("Failed to load skills config")

	# 加载维护配置
	if not load_maintenance_config():
		success = false
		errors.append("Failed to load maintenance config")

	# 加载娱乐配置
	if not load_recreation_config():
		success = false
		errors.append("Failed to load recreation config")

	# 加载广告配置
	if not load_ad_config():
		success = false
		errors.append("Failed to load ad config")

	# 加载游戏文本
	if not load_game_strings():
		success = false
		errors.append("Failed to load game strings")

	# 加载头衔配置
	if not load_rank_titles():
		success = false
		errors.append("Failed to load rank titles")

	# 加载成就配置
	if not load_milestones_config():
		success = false
		errors.append("Failed to load milestones config")

	if success:
		emit_signal("config_loaded")
	else:
		var error_str = "Config loading failed: " + ", ".join(errors)
		emit_signal("config_failed", error_str)

# ===== 加载文章类型配置 =====

func load_post_categories() -> bool:
	if not Utils:
		return false

	var categories = Utils.possible_categories.duplicate()
	static_config.post_categories.clear()
	for category in categories:
		static_config.post_categories.append(category)
	return true

# ===== 加载技能配置 =====

func load_skills_config() -> bool:
	if not Utils:
		return false

	var skills = Utils.learning_skills.duplicate()
	static_config.skills_config.clear()
	for skill in skills:
		static_config.skills_config.append(skill)
	return true

# ===== 加载维护配置 =====

func load_maintenance_config() -> bool:
	if not Utils:
		return false

	var maintenance = Utils.website_maintenance.duplicate()
	static_config.maintenance_config.clear()
	for task in maintenance:
		static_config.maintenance_config.append(task)
	return true

# ===== 加载娱乐配置 =====

func load_recreation_config() -> bool:
	if not Utils:
		return false

	var recreation = Utils.recreation.duplicate()
	static_config.recreation_config.clear()
	for activity in recreation:
		static_config.recreation_config.append(activity)
	return true
# ===== 加载广告配置 =====

func load_ad_config() -> bool:
	if not AdManager:
		return false

	var ads_array = AdManager.ads.duplicate()
	static_config.ad_config.clear()
	for ad in ads_array:
		static_config.ad_config.append(ad)
	return true

# ===== 加载游戏文本 =====

func load_game_strings() -> bool:
    if not Strs:
        return false

    static_config.game_strings = Strs.game_strs.duplicate(true)
    return true

# ===== 加载头衔配置 =====

func load_rank_titles() -> bool:
    if not Strs:
        return false

    static_config.rank_titles.clear()
    if Strs.game_strs.has("头衔"):
        var titles = Strs.game_strs["头衔"].duplicate()
        for title in titles:
            static_config.rank_titles.append(title)
    return true

# ===== 加载成就配置 =====

func load_milestones_config() -> bool:
    if not GDManager or not GDManager.has_data("milestones"):
        return false

    var milestones = GDManager.get_data("milestones")
    if milestones and milestones.has("milestones"):
        var ms = milestones.milestones
        static_config.milestones_config.clear()
        for key in ms:
            static_config.milestones_config[key] = ms[key]
    else:
        static_config.milestones_config = {}
    return true

# ===== 获取配置 =====

func get_static_config() -> StaticConfig:
	return static_config

func get_post_categories() -> Array[Dictionary]:
	return static_config.post_categories

func get_skills_config() -> Array[Dictionary]:
	return static_config.skills_config

func get_maintenance_config() -> Array[Dictionary]:
	return static_config.maintenance_config

func get_recreation_config() -> Array[Dictionary]:
	return static_config.recreation_config

func get_ad_config() -> Array[Dictionary]:
	return static_config.ad_config

func get_game_strings() -> Dictionary:
	return static_config.game_strings

func get_rank_titles() -> Array[String]:
	return static_config.rank_titles

func get_milestones_config() -> Dictionary:
	return static_config.milestones_config

# ===== 刷新配置 =====

func reload_configs():
	load_all_configs()
