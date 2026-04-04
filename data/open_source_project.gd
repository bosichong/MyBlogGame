extends Node

## 开源项目数据配置
## 解锁条件：编程能力 ≥100

var projects = [
	{
		"name": "开源项目",
		"description": "编程能力达到最高境界后，可以创建开源项目",
		"unlock_condition": "code_value_ge_100",
		"type": "开源",
		
		# 开发阶段参数（游戏时间）
		"stamina_per_dev": 50,         # 每次开发消耗体力
		"min_dev_days": 168,           # 最少开发天数（游戏内半年）
		"max_dev_days": 336,           # 最长开发天数（游戏内一年）
		"progress_per_day": 1,         # 每天开发进度
		
		# 发布流程阶段
		"phases": [
			{
				"name": "开发阶段",
				"duration_type": "dynamic",
				"min_duration": 168,
				"max_duration": 336,
				"description": "持续开发，积累代码和功能",
			},
			{
				"name": "社区运营",
				"duration_type": "ongoing",
				"description": "发布到GitHub，获得Star和关注",
			},
			{
				"name": "收购谈判",
				"duration_type": "event",
				"description": "大公司发出收购意向",
			},
			{
				"name": "收购完成",
				"duration_type": "instant",
				"description": "项目被收购，获得收益",
			}
		],
		
		# 收购收益参数
		"acquisition_base_reward": 500000,   # 基础收购价50万
		"reputation_reward": 2000,          # 声望奖励
		
		# 收购条件
		"min_star_for_acquisition": 1000,   # 最低Star数
		"min_months_for_acquisition": 6,     # 最低运营月数
		
		# 状态
		"isVisible": false,
		"disabled": true,
	},
]

## 可收购的公司列表
var acquirers = [
	{
		"name": "Google",
		"min_star": 5000,
		"reward_range": [1500000, 2000000],
		"reputation": 5000,
	},
	{
		"name": "Microsoft",
		"min_star": 3000,
		"reward_range": [1000000, 1500000],
		"reputation": 4000,
	},
	{
		"name": "Meta",
		"min_star": 2000,
		"reward_range": [800000, 1200000],
		"reputation": 3000,
	},
	{
		"name": "阿里巴巴",
		"min_star": 1000,
		"reward_range": [500000, 800000],
		"reputation": 2000,
	},
	{
		"name": "腾讯",
		"min_star": 1000,
		"reward_range": [500000, 800000],
		"reputation": 2000,
	},
]

## 当前开源项目状态（运行时数据）
var current_project_state = {
	"is_developing": false,
	"project_id": "",
	"project_name": "",
	"current_phase": 0,
	"dev_days": 0,
	"total_progress": 0,
	"completed": false,
	"published": false,
	"publish_date": "",
	"star_count": 0,
	"fork_count": 0,
	"issue_count": 0,
	"months_since_publish": 0,
	"total_sponsor_income": 0,
	"acquired": false,
	"acquirer": {},
}

## 已发布开源项目列表（可同时有多个项目）
var published_projects: Array = []

## 生成项目ID
func generate_project_id() -> String:
	return "project_" + str(Time.get_ticks_msec()) + "_" + str(randi() % 10000)

## 计算项目质量（基于开发天数和编程能力值）
func calculate_project_quality(dev_days: int, code_value: float) -> float:
	var day_factor = clamp(float(dev_days) / 336.0, 0.5, 1.0)
	var code_factor = code_value / 100.0
	return day_factor * code_factor

## 检查是否满足收购条件
func check_acquisition_eligible(project: Dictionary) -> bool:
	if not project.get("published", false):
		return false
	if project.get("acquired", false):
		return false
	
	var star_count = project.get("star_count", 0)
	var months = project.get("months_since_publish", 0)
	
	return star_count >= 1000 and months >= 6

## 获取符合条件的收购方
func get_eligible_acquirers(star_count: int) -> Array:
	var eligible = []
	for acquirer in acquirers:
		if star_count >= acquirer.min_star:
			eligible.append(acquirer)
	return eligible

## 计算收购价格
func calculate_acquisition_price(acquirer: Dictionary, project_quality: float) -> int:
	var min_price = acquirer.reward_range[0]
	var max_price = acquirer.reward_range[1]
	var price = min_price + int((max_price - min_price) * project_quality)
	return price

## 更新所有项目的Star数（每月调用）
func update_all_projects_stars() -> Dictionary:
	var updates = []
	
	for project in published_projects:
		if not project.get("published", false) or project.get("acquired", false):
			continue
		
		# 根据项目质量增加Star
		var quality = project.get("project_quality", 0.5)
		var new_stars = int(randf_range(10, 50) * quality)
		project.star_count = project.get("star_count", 0) + new_stars
		project.months_since_publish = project.get("months_since_publish", 0) + 1
		
		# 赞助收益
		var sponsor_income = int(project.star_count * 0.1)
		project.total_sponsor_income = project.get("total_sponsor_income", 0) + sponsor_income
		
		updates.append({
			"project_name": project.get("project_name", ""),
			"new_stars": new_stars,
			"total_stars": project.star_count,
			"sponsor_income": sponsor_income,
		})
	
	return {"updates": updates}