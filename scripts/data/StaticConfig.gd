class_name StaticConfig

var post_categories: Array[Dictionary] = []
var skills_config: Array[Dictionary] = []
var maintenance_config: Array[Dictionary] = []
var recreation_config: Array[Dictionary] = []
var ad_config: Array[Dictionary] = []
var game_strings: Dictionary = {}
var rank_titles: Array[String] = []
var milestones_config: Dictionary = {}

# 常量
const MAX_LEVEL = 100
const MAX_SKILL_LEVEL = 100
const DAYS_IN_WEEK = 7
const WEEKS_IN_MONTH = 4
const MONTHS_IN_YEAR = 12

# ===== 辅助方法 =====

func get_post_category(index: int) -> Dictionary:
    if index >= 0 and index < post_categories.size():
        return post_categories[index]
    return {}

func get_post_category_by_name(name: String) -> Dictionary:
    for category in post_categories:
        if category.has("name") and category["name"] == name:
            return category
    return {}

func get_skill_config(skill_name: String) -> Dictionary:
    for skill in skills_config:
        if skill.has("name") and skill["name"] == skill_name:
            return skill
    return {}

func get_milestone(level: int) -> Dictionary:
    if milestones_config.has(str(level)):
        return milestones_config[str(level)]
    return {}

func get_rank_title(tier: int) -> String:
    if tier >= 0 and tier < rank_titles.size():
        return rank_titles[tier]
    return ""

func get_string(key: String, default: String = "") -> String:
    if game_strings.has(key):
        return game_strings[key]
    return default

func get_all_post_categories() -> Array[Dictionary]:
    return post_categories

func get_all_skills() -> Array[Dictionary]:
    return skills_config

func get_all_maintenance_tasks() -> Array[Dictionary]:
    return maintenance_config

func get_all_recreation_activities() -> Array[Dictionary]:
    return recreation_config

func get_all_ad_types() -> Array[Dictionary]:
    return ad_config