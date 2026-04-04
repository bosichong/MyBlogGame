extends Node

## IP授权数据配置
## 解锁条件：文学能力 ≥100 + 小说连载发布 ≥50篇
## 艺术类：绘画能力 ≥100 + 动漫连载发布 ≥50篇

var ip_types = [
	{
		"name": "基础IP授权",
		"description": "厂商联系授权使用你的小说IP，每月获得固定收益",
		"unlock_condition": "literature_value_ge_100_and_novel_50",
		"type": "授权",
		"trigger_type": "auto",           # 自动触发
		
		# 收益参数
		"monthly_income": 1000,           # 每月收益
		"duration_months": 12,            # 授权期限12个月
		"total_income": 12000,            # 总收益
		
		# 状态
		"isVisible": false,
		"disabled": true,
		"is_active": false,
	},
	{
		"name": "影视IP授权",
		"description": "影视公司购买小说IP改编权，制作电影或电视剧",
		"unlock_condition": "novel_serial_ge_70",    # 小说连载 ≥70篇
		"type": "授权",
		"trigger_type": "random",         # 随机事件触发
		"trigger_probability": 0.1,       # 10%概率（每月检查）
		
		# 收益参数
		"one_time_income": 500000,        # 一次性收益
		"reputation_reward": 5000,        # 声望奖励
		
		# 状态
		"isVisible": false,
		"disabled": true,
	},
	{
		"name": "游戏IP授权",
		"description": "游戏公司购买小说IP改编权，制作游戏",
		"unlock_condition": "novel_serial_ge_60",    # 小说连载 ≥60篇
		"type": "授权",
		"trigger_type": "random",
		"trigger_probability": 0.15,      # 15%概率
		
		# 收益参数
		"one_time_income": 100000,
		"reputation_reward": 2000,
		
		# 状态
		"isVisible": false,
		"disabled": true,
	},
]

## 当前IP授权状态（运行时数据）
var current_ip_state = {
	"base_ip_active": false,          # 基础IP授权是否激活
	"base_ip_remaining_months": 0,    # 基础IP剩余月数
	"movie_ip_triggered": false,      # 影视IP是否已触发
	"game_ip_triggered": false,       # 游戏IP是否已触发
	"total_ip_income": 0,             # 累计IP收益
}

# ====================
# 动漫IP授权（艺术类）
# ====================
var anime_ip_types = [
	{
		"name": "基础IP授权（动漫）",
		"description": "厂商联系授权使用你的动漫IP，每月获得固定收益",
		"unlock_condition": "draw_value_ge_100_and_anime_50",
		"type": "授权",
		"trigger_type": "auto",
		"monthly_income": 1000,
		"duration_months": 12,
		"total_income": 12000,
		"isVisible": false,
		"disabled": true,
		"is_active": false,
	},
	{
		"name": "影视IP授权（动漫）",
		"description": "影视公司购买动漫IP改编权，制作电影或电视剧",
		"unlock_condition": "anime_serial_ge_70",
		"type": "授权",
		"trigger_type": "random",
		"trigger_probability": 0.1,
		"one_time_income": 500000,
		"reputation_reward": 5000,
		"isVisible": false,
		"disabled": true,
	},
	{
		"name": "游戏IP授权（动漫）",
		"description": "游戏公司购买动漫IP改编权，制作游戏",
		"unlock_condition": "anime_serial_ge_60",
		"type": "授权",
		"trigger_type": "random",
		"trigger_probability": 0.15,
		"one_time_income": 100000,
		"reputation_reward": 2000,
		"isVisible": false,
		"disabled": true,
	},
]

## 当前动漫IP授权状态
var current_anime_ip_state = {
	"base_ip_active": false,
	"base_ip_remaining_months": 0,
	"movie_ip_triggered": false,
	"game_ip_triggered": false,
	"total_ip_income": 0,
}