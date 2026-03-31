extends Node

## 网站运维数据配置

var items = [
	{
		"name": "SEO优化",
		"tip": "保证博客来自搜索引擎的基础访问量，SEO值过低，博客会没有访问量",
		"isVisible": true,
		"disabled": false,
		"pressed": false,
		"money": 0,
		"stamina": 10,
	},
	{
		"name": "安全维护",
		"tip": "博客的安全数值，安全值过低，博客会遭到攻击，丢失数据或无法打开页面。",
		"isVisible": true,
		"disabled": false,
		"pressed": false,
		"money": 10,
		"stamina": 10,
	},
	{
		"name": "页面美化",
		"tip": "需要绘画等级1后解锁，漂亮的页面会增加访问量。",
		"isVisible": false,
		"disabled": true,
		"pressed": false,
		"money": 0,
		"stamina": 10,
	},
	{
		"name": "互动管理",
		"tip": "良好的互动会增加博客的知名度，进而增加博客访问量。需要有评论或留言的候才会开启。",
		"isVisible": false,
		"disabled": true,
		"pressed": false,
		"money": 0,
		"stamina": 5,
	},
]