extends Node

## 出版商/书商列表
## 用于出版畅销书时随机选择合作出版商

var publishers = [
	# ===== 大型出版社 =====
	{
		"name": "人民文学出版社",
		"type": "大型出版社",
		"reputation": 5,            # 声望等级（1-5）
		"reward_multiplier": 1.5,   # 收益倍数
		"edit_days": 5,             # 编辑审核天数
		"publish_days": 7,          # 出版审核天数
		"description": "国内顶级文学出版社，出版质量有保障",
	},
	{
		"name": "中信出版社",
		"type": "大型出版社",
		"reputation": 5,
		"reward_multiplier": 1.4,
		"edit_days": 4,
		"publish_days": 5,
		"description": "知名商业书籍出版社，营销能力强",
	},
	{
		"name": "机械工业出版社",
		"type": "大型出版社",
		"reputation": 4,
		"reward_multiplier": 1.3,
		"edit_days": 3,
		"publish_days": 5,
		"description": "技术书籍权威出版社",
	},
	{
		"name": "清华大学出版社",
		"type": "大学出版社",
		"reputation": 4,
		"reward_multiplier": 1.2,
		"edit_days": 5,
		"publish_days": 10,
		"description": "学术气息浓厚，审核严格",
	},
	
	# ===== 中型出版社 =====
	{
		"name": "新星出版社",
		"type": "中型出版社",
		"reputation": 3,
		"reward_multiplier": 1.0,
		"edit_days": 3,
		"publish_days": 5,
		"description": "新兴出版社，对新人作者友好",
	},
	{
		"name": "浙江文艺出版社",
		"type": "中型出版社",
		"reputation": 3,
		"reward_multiplier": 1.1,
		"edit_days": 4,
		"publish_days": 6,
		"description": "地方文艺出版社，性价比不错",
	},
	{
		"name": "百花洲文艺出版社",
		"type": "中型出版社",
		"reputation": 3,
		"reward_multiplier": 1.0,
		"edit_days": 3,
		"publish_days": 4,
		"description": "文艺类书籍专业出版社",
	},
	
	# ===== 小型出版社 =====
	{
		"name": "独立出版社",
		"type": "小型出版社",
		"reputation": 2,
		"reward_multiplier": 0.8,
		"edit_days": 2,
		"publish_days": 3,
		"description": "小型独立出版社，审核快但收益较低",
	},
	{
		"name": "网络文学出版社",
		"type": "小型出版社",
		"reputation": 2,
		"reward_multiplier": 0.9,
		"edit_days": 2,
		"publish_days": 3,
		"description": "专注网络文学出版，适合网文作者",
	},
]

## 随机选择出版商
## 根据 writings_days（写作天数）决定可选范围
## 写作天数越长，越容易获得大出版社合作
func get_random_publisher(write_days: int) -> Dictionary:
	var available_publishers = []
	
	# 写作天数决定可接触的出版社等级
	if write_days >= 300:        # 写作近一年，大出版社开放
		available_publishers = publishers
	elif write_days >= 240:      # 写作8个月左右
		available_publishers = publishers.filter(func(p): return p.reputation >= 3)
	elif write_days >= 168:      # 写作半年（最低要求）
		available_publishers = publishers.filter(func(p): return p.reputation >= 2)
	else:
		# 未达最低要求，只能选小型出版社
		available_publishers = publishers.filter(func(p): return p.reputation <= 2)
	
	# 随机选择
	if available_publishers.size() > 0:
		return available_publishers[randi() % available_publishers.size()]
	else:
		return publishers[0]  # 默认返回第一个