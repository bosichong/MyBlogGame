extends Node

## 休闲娱乐数据配置

var items = [
	{
		"name": "休息",
		"isVisible": true,
		"disabled": false,
		"pressed": false,
		"money": 0,
		"stamina": 20,  # 从30改为20
	},
	{
		"name": "打游戏",
		"isVisible": true,
		"disabled": false,
		"pressed": false,
		"money": 100,  # 花费将在代码中动态计算
		"stamina": 30,  # 从100改为30
	},
	{
		"name": "国内旅游",
		"isVisible": false,
		"disabled": true,
		"pressed": false,
		"money": 3000,
		"stamina": 80,
	},
	{
		"name": "出国旅游",
		"isVisible": false,
		"disabled": true,
		"pressed": false,
		"money": 10000,
		"stamina": 80,
	},
]