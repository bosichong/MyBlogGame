extends Node

## IP授权公司列表
## 用于触发IP授权事件时随机选择合作公司

var companies = {
	# ===== 基础IP授权公司 =====
	"basic": [
		{
			"name": "星月文化传媒",
			"type": "文化传媒公司",
			"monthly_income": 1000,
			"duration_months": 12,
			"description": "中小型文化传媒公司，喜欢签约潜力作者",
			"contract_type": "基础授权",
		},
		{
			"name": "蓝海版权代理",
			"type": "版权代理公司",
			"monthly_income": 800,
			"duration_months": 12,
			"description": "专业版权代理机构，帮助作者对接各类合作",
			"contract_type": "基础授权",
		},
		{
			"name": "云端文学工作室",
			"type": "文学工作室",
			"monthly_income": 1200,
			"duration_months": 6,
			"description": "新兴文学工作室，短期合作收益较高",
			"contract_type": "基础授权",
		},
		{
			"name": "墨香版权运营",
			"type": "版权运营公司",
			"monthly_income": 1500,
			"duration_months": 12,
			"description": "专业版权运营，长期合作收益稳定",
			"contract_type": "基础授权",
		},
	],
	
	# ===== 影视授权公司 =====
	"movie": [
		{
			"name": "华影影视集团",
			"type": "大型影视公司",
			"one_time_income": 500000,
			"reputation_reward": 5000,
			"description": "国内顶级影视制作公司，IP改编成电影",
			"contract_type": "影视授权",
			"min_novel_count": 70,     # 需要小说连载≥70篇
			"probability": 0.05,       # 触发概率
		},
		{
			"name": "星光影业",
			"type": "中型影视公司",
			"one_time_income": 300000,
			"reputation_reward": 3000,
			"description": "知名影视制作公司，IP改编成电视剧",
			"contract_type": "影视授权",
			"min_novel_count": 60,
			"probability": 0.08,
		},
		{
			"name": "梦想影视工作室",
			"type": "小型影视公司",
			"one_time_income": 100000,
			"reputation_reward": 1000,
			"description": "新兴影视工作室，IP改编成网络剧",
			"contract_type": "影视授权",
			"min_novel_count": 55,
			"probability": 0.10,
		},
		{
			"name": "国际影视联合体",
			"type": "国际影视公司",
			"one_time_income": 800000,
			"reputation_reward": 8000,
			"description": "国际影视公司，IP改编成国际电影",
			"contract_type": "影视授权",
			"min_novel_count": 80,
			"probability": 0.02,       # 概率很低
		},
	],
	
	# ===== 游戏授权公司 =====
	"game": [
		{
			"name": "腾讯游戏",
			"type": "大型游戏公司",
			"one_time_income": 100000,
			"reputation_reward": 2000,
			"description": "顶级游戏公司，IP改编成大型手游",
			"contract_type": "游戏授权",
			"min_novel_count": 60,
			"probability": 0.05,
		},
		{
			"name": "网易游戏",
			"type": "大型游戏公司",
			"one_time_income": 80000,
			"reputation_reward": 1500,
			"description": "知名游戏公司，IP改编成精品游戏",
			"contract_type": "游戏授权",
			"min_novel_count": 55,
			"probability": 0.08,
		},
		{
			"name": "米哈游",
			"type": "中型游戏公司",
			"one_time_income": 50000,
			"reputation_reward": 1000,
			"description": "精品游戏制作公司，IP改编成二次元游戏",
			"contract_type": "游戏授权",
			"min_novel_count": 50,
			"probability": 0.10,
		},
		{
			"name": "独立游戏工作室",
			"type": "小型游戏公司",
			"one_time_income": 20000,
			"reputation_reward": 500,
			"description": "独立游戏开发者，IP改编成独立游戏",
			"contract_type": "游戏授权",
			"min_novel_count": 50,
			"probability": 0.15,
		},
		{
			"name": "日本游戏公司",
			"type": "国际游戏公司",
			"one_time_income": 150000,
			"reputation_reward": 3000,
			"description": "日本知名游戏公司，IP改编成日式RPG",
			"contract_type": "游戏授权",
			"min_novel_count": 70,
			"probability": 0.03,
		},
	],
}

## 随机选择基础授权公司
func get_random_basic_company() -> Dictionary:
	var list = companies["basic"]
	return list[randi() % list.size()]

## 随机选择影视授权公司（根据小说连载数量）
func get_random_movie_company(novel_count: int) -> Dictionary:
	var available = companies["movie"].filter(func(c): return novel_count >= c.min_novel_count)
	if available.size() > 0:
		return available[randi() % available.size()]
	return {}

## 随机选择游戏授权公司（根据小说连载数量）
func get_random_game_company(novel_count: int) -> Dictionary:
	var available = companies["game"].filter(func(c): return novel_count >= c.min_novel_count)
	if available.size() > 0:
		return available[randi() % available.size()]
	return {}

## 检查是否触发影视授权（每月检查）
func check_movie_trigger(novel_count: int) -> Dictionary:
	var available = companies["movie"].filter(func(c): 
		return novel_count >= c.min_novel_count and randf() < c.probability
	)
	if available.size() > 0:
		return available[0]  # 返回第一个匹配的
	return {}

## 检查是否触发游戏授权（每月检查）
func check_game_trigger(novel_count: int) -> Dictionary:
	var available = companies["game"].filter(func(c): 
		return novel_count >= c.min_novel_count and randf() < c.probability
	)
	if available.size() > 0:
		return available[0]
	return {}