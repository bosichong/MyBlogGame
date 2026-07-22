extends Node

## 安全事件配置
## 每个事件包含触发条件、惩罚、解决天数、升级链等

var events: Array[Dictionary] = [
	# ==================== 一般事件 ====================
	{
		"id": "hidden_link",
		"tier": "general",
		"name": "暗链植入",
		"trigger_threshold": 40,
		"trigger_probability": 0.10,
		"popup_title": "安全警告：暗链植入",
		"popup_desc": "你的博客页面被植入了隐藏链接！这些链接会导致搜索引擎降权，并且可能被用于 SEO 作弊。\n\n安全值 -5\n访问量 -50\n\n请在日程中安排「紧急排险」来解决问题。",
		"penalty": { "safety_value": -5, "views_loss": -50 },
		"total_days": 3,
		"daily_stamina": 15,
		"daily_penalty": { "safety_value": -2 },
		"escalate_days": 5,
		"escalate_to": "homepage_defaced",
		"reward": { "safety_value": 10, "exp": 50, "money": 200 }
	},
	{
		"id": "image_hotlink",
		"tier": "general",
		"name": "图片外链被盗用",
		"trigger_threshold": 35,
		"trigger_probability": 0.10,
		"popup_title": "资源盗用：图片外链",
		"popup_desc": "有外部网站直接引用你的博客图片资源，大量消耗你的带宽流量！\n\n安全值 -3\n每日访问量损失 -100（直到解决）\n\n请在日程中安排「紧急排险」来解决问题。",
		"penalty": { "safety_value": -3, "views_loss": -100 },
		"total_days": 3,
		"daily_stamina": 12,
		"daily_penalty": { "views_loss": -100 },
		"escalate_days": 5,
		"escalate_to": "",
		"reward": { "safety_value": 8, "exp": 40, "money": 100 }
	},
	{
		"id": "suspicious_login",
		"tier": "general",
		"name": "后台异常登录",
		"trigger_threshold": 30,
		"trigger_probability": 0.10,
		"popup_title": "安全提醒：异常登录",
		"popup_desc": "检测到来自异常 IP 的后台登录尝试！可能有人试图破解你的管理员账号。\n\n安全值 -8\n\n请在日程中安排「紧急排险」来解决问题。",
		"penalty": { "safety_value": -8 },
		"total_days": 3,
		"daily_stamina": 15,
		"daily_penalty": { "safety_value": -3 },
		"escalate_days": 5,
		"escalate_to": "data_leak",
		"reward": { "safety_value": 12, "exp": 60 }
	},
	# ==================== 严重事件 ====================
	{
		"id": "homepage_defaced",
		"tier": "severe",
		"name": "首页被篡改",
		"trigger_threshold": 20,
		"trigger_probability": 0.10,
		"popup_title": "严重警告：首页被篡改！",
		"popup_desc": "你的博客首页被恶意篡改！页面显示异常内容，严重影响博客形象。\n\n安全值 -10\n访问量 -200\n声望 -20\n\n请在日程中安排「紧急排险」来解决问题。",
		"penalty": { "safety_value": -10, "views_loss": -200, "reputation": -20 },
		"total_days": 4,
		"daily_stamina": 18,
		"daily_penalty": { "safety_value": -5, "views_loss": -50 },
		"escalate_days": 5,
		"escalate_to": "server_hacked",
		"reward": { "safety_value": 15, "exp": 100, "money": 300 }
	},
	{
		"id": "malware_injected",
		"tier": "severe",
		"name": "网站被挂木马",
		"trigger_threshold": 15,
		"trigger_probability": 0.10,
		"popup_title": "极度危险：网站被挂木马！",
		"popup_desc": "你的网站被植入了恶意木马程序！访问者可能被感染，浏览器会标记你的网站为危险。\n\n安全值 -12\n访问量 -300\n\n请在日程中安排「紧急排险」来解决问题。",
		"penalty": { "safety_value": -12, "views_loss": -300 },
		"total_days": 5,
		"daily_stamina": 20,
		"daily_penalty": { "safety_value": -6, "views_loss": -100 },
		"escalate_days": 5,
		"escalate_to": "ddos_attack",
		"reward": { "safety_value": 18, "exp": 120, "money": 400 }
	},
	{
		"id": "data_leak",
		"tier": "severe",
		"name": "数据泄露",
		"trigger_threshold": 10,
		"trigger_probability": 0.10,
		"popup_title": "重大事故：数据泄露！",
		"popup_desc": "你的数据库遭到泄露！用户评论信息、注册邮箱等可能已被窃取。\n\n安全值 -15\n声望 -50\n\n请在日程中安排「紧急排险」来解决问题。",
		"penalty": { "safety_value": -15, "reputation": -50 },
		"total_days": 6,
		"daily_stamina": 22,
		"daily_penalty": { "safety_value": -5, "reputation": -5 },
		"escalate_days": 5,
		"escalate_to": "server_hacked",
		"reward": { "safety_value": 20, "exp": 150, "money": 500 }
	},
	# ==================== 致命事件 ====================
	{
		"id": "ddos_attack",
		"tier": "critical",
		"name": "DDoS攻击",
		"trigger_threshold": 5,
		"trigger_probability": 0.10,
		"popup_title": "站点瘫痪：DDoS攻击！",
		"popup_desc": "你的博客正遭受分布式拒绝服务攻击！网站访问极慢或完全无法打开。\n\n安全值 -20\n访问量损失 -500\n\n请在日程中安排「紧急排险」来解决问题。",
		"penalty": { "safety_value": -20, "views_loss": -500 },
		"total_days": 6,
		"daily_stamina": 25,
		"daily_penalty": { "safety_value": -8, "views_loss": -200 },
		"escalate_days": 5,
		"escalate_to": "",
		"reward": { "safety_value": 25, "exp": 200, "money": 600 }
	},
	{
		"id": "server_hacked",
		"tier": "critical",
		"name": "服务器被入侵",
		"trigger_threshold": 3,
		"trigger_probability": 0.10,
		"popup_title": "服务器沦陷：完全入侵！",
		"popup_desc": "你的服务器已被黑客完全控制！所有数据面临风险，需要立即重装系统。\n\n安全值 -25\n访问量损失 -1000\n\n请在日程中安排「紧急排险」来解决问题。",
		"penalty": { "safety_value": -25, "views_loss": -1000 },
		"total_days": 7,
		"daily_stamina": 30,
		"daily_penalty": { "safety_value": -10, "views_loss": -300 },
		"escalate_days": 5,
		"escalate_to": "",
		"reward": { "safety_value": 30, "exp": 250, "money": 1000 }
	}
]
