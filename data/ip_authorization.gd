extends Node

## IP授权数据配置（简化版）
## 触发条件：小说连载 >= 50篇（每批次）
## 触发概率：20%
## 收益：10万 + (文学能力值%)，最高20万
## 每批次只能触发一次

var ip_types = [
	{
		"name": "影视IP授权",
		"description": "影视公司购买你的小说IP改编权，一次性获得收益！",
		"unlock_condition": "novel_batch_ge_50",
		"type": "授权",
		"trigger_type": "manual",           # 手动触发（在 blogger.gd 中处理）
		
		# 收益参数
		"base_income": 100000,              # 基础收益10万
		"max_bonus_rate": 1.0,              # 最高加成100%
		
		# 状态
		"isVisible": false,
		"disabled": true,
		"is_active": false,
	},
]

## 当前IP授权状态（运行时数据）
var current_ip_state = {
	"ip_triggered": false,           # IP授权是否已触发（当前批次）
	"total_ip_income": 0,            # 累计IP收益
}