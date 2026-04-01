# TaskConfig.gd
# 任务配置文件 - 数据驱动的任务系统

## ============================================================
## 枚举定义
## ============================================================

# 比较运算符
enum CompareOp {
	EQ,      # ==
	NE,      # !=
	GT,      # >
	GE,      # >=
	LT,      # <
	LE,      # <=
}

# 条件类型
enum ConditionType {
	SKILL_LEVEL,     # 技能等级
	PLAYER_LEVEL,    # 玩家等级
	POST_COUNT,      # 发布次数
	TIME_MATCH,      # 时间匹配
	CUSTOM,          # 自定义条件（通过函数名调用）
}

# 任务动作类型
enum ActionType {
	SKILL_LEVEL_UNLOCK,      # 技能解锁
	SKILL_LEVEL_LOCK,        # 技能锁定
	UNLOCK_POST_TASK,        # 解锁博文类型
	LOCK_POST_TASK,          # 锁定博文类型
	HIDE_POST_TASK,          # 隐藏博文类型
	REPLACE_POST_TREND,      # 更换博文热点
	MODIFY_ATTRIBUTE,        # 修改属性
	UNLOCK_MILESTONES_TASK,  # 解锁成就
	CHANGE_SCENE,            # 切换场景
	SHOW_NOTIFICATION,       # 显示通知
	CUSTOM_ACTION,           # 自定义动作
}

## ============================================================
## 可复用条件定义
## ============================================================

const CONDITIONS: Dictionary = {
	# 技能等级条件
	"literature_ge_25": {"type": ConditionType.SKILL_LEVEL, "skill": "LITERATURE", "op": CompareOp.GE, "value": 25},
	"literature_ge_50": {"type": ConditionType.SKILL_LEVEL, "skill": "LITERATURE", "op": CompareOp.GE, "value": 50},
	"literature_ge_75": {"type": ConditionType.SKILL_LEVEL, "skill": "LITERATURE", "op": CompareOp.GE, "value": 75},
	"literature_ge_100": {"type": ConditionType.SKILL_LEVEL, "skill": "LITERATURE", "op": CompareOp.GE, "value": 100},
	
	"code_ge_25": {"type": ConditionType.SKILL_LEVEL, "skill": "CODE", "op": CompareOp.GE, "value": 25},
	"code_ge_50": {"type": ConditionType.SKILL_LEVEL, "skill": "CODE", "op": CompareOp.GE, "value": 50},
	"code_ge_75": {"type": ConditionType.SKILL_LEVEL, "skill": "CODE", "op": CompareOp.GE, "value": 75},
	"code_ge_100": {"type": ConditionType.SKILL_LEVEL, "skill": "CODE", "op": CompareOp.GE, "value": 100},
	
	"draw_ge_25": {"type": ConditionType.SKILL_LEVEL, "skill": "DRAW", "op": CompareOp.GE, "value": 25},
	"draw_ge_50": {"type": ConditionType.SKILL_LEVEL, "skill": "DRAW", "op": CompareOp.GE, "value": 50},
	"draw_ge_75": {"type": ConditionType.SKILL_LEVEL, "skill": "DRAW", "op": CompareOp.GE, "value": 75},
	"draw_ge_100": {"type": ConditionType.SKILL_LEVEL, "skill": "DRAW", "op": CompareOp.GE, "value": 100},
	
	# 玩家等级条件
	"player_eq_10": {"type": ConditionType.PLAYER_LEVEL, "op": CompareOp.EQ, "value": 10},
	"player_eq_20": {"type": ConditionType.PLAYER_LEVEL, "op": CompareOp.EQ, "value": 20},
	"player_eq_30": {"type": ConditionType.PLAYER_LEVEL, "op": CompareOp.EQ, "value": 30},
	"player_eq_40": {"type": ConditionType.PLAYER_LEVEL, "op": CompareOp.EQ, "value": 40},
	"player_eq_50": {"type": ConditionType.PLAYER_LEVEL, "op": CompareOp.EQ, "value": 50},
	"player_eq_60": {"type": ConditionType.PLAYER_LEVEL, "op": CompareOp.EQ, "value": 60},
	"player_eq_70": {"type": ConditionType.PLAYER_LEVEL, "op": CompareOp.EQ, "value": 70},
	"player_eq_80": {"type": ConditionType.PLAYER_LEVEL, "op": CompareOp.EQ, "value": 80},
	"player_eq_90": {"type": ConditionType.PLAYER_LEVEL, "op": CompareOp.EQ, "value": 90},
	"player_eq_100": {"type": ConditionType.PLAYER_LEVEL, "op": CompareOp.EQ, "value": 100},
	
	# 发布次数条件
	"first_post_eq_1": {"type": ConditionType.POST_COUNT, "post_type": "第一篇博文", "op": CompareOp.EQ, "value": 1},
	"year_summary_eq_1": {"type": ConditionType.POST_COUNT, "post_type": "年度总结", "op": CompareOp.EQ, "value": 1},
	
	# 时间条件（配合 event_date 使用）
	"time_first_post_unlock": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [2000], "m": [1], "w": [1], "d": [3]}},
	"time_year_summary_unlock": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [0], "m": [12], "w": [2], "d": [1]}},
	"time_year_summary_lock": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [0], "m": [12], "w": [4], "d": [7]}},
	"time_trend_change": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [0], "m": [1, 6], "w": [2], "d": [1]}},
}

## ============================================================
## 技能任务模板 - 避免重复代码
## ============================================================

const SKILL_PROGRESS_CONFIG: Dictionary = {
	"LITERATURE": {
		"skill_enum": "LITERATURE",
		"progress": {
			25: {"lock": "阅读名著", "unlock": "写作基础理论"},
			50: {"lock": "写作基础理论", "unlock": "高级文学"},
			75: {"lock": "高级文学", "unlock": "小说家"},
			100: {"lock": "小说家", "unlock": null},
		}
	},
	"CODE": {
		"skill_enum": "CODE",
		"progress": {
			25: {"lock": "自学编程", "unlock": "学习前端"},
			50: {"lock": "学习前端", "unlock": "高级编程"},
			75: {"lock": "高级编程", "unlock": "成为黑客"},
			100: {"lock": "成为黑客", "unlock": null},
		}
	},
	"DRAW": {
		"skill_enum": "DRAW",
		"progress": {
			25: {"lock": "自学画画", "unlock": "素描和色彩"},
			50: {"lock": "素描和色彩", "unlock": "原画师之路"},
			75: {"lock": "原画师之路", "unlock": "大画家"},
			100: {"lock": "大画家", "unlock": null},
		}
	},
}

## ============================================================
## 任务定义
## ============================================================

const TASKS: Array = [
	# ====================
	# 技能进阶任务（自动生成）
	# ====================
	
	# 文学技能线
	{
		"id": "literature_unlock_25",
		"description": "文学能力达到25级，解锁下一阶段技能学习",
		"conditions": ["literature_ge_25"],
		"trigger_type": "skill_up",
		"is_repeatable": false,
		"actions": [
			{"type": ActionType.SKILL_LEVEL_LOCK, "skill_name": "阅读名著"},
			{"type": ActionType.SKILL_LEVEL_UNLOCK, "skill_name": "写作基础理论"},
		],
	},
	{
		"id": "literature_unlock_50",
		"description": "文学能力达到50级，解锁下一阶段技能学习",
		"conditions": ["literature_ge_50"],
		"trigger_type": "skill_up",
		"is_repeatable": false,
		"actions": [
			{"type": ActionType.SKILL_LEVEL_LOCK, "skill_name": "写作基础理论"},
			{"type": ActionType.SKILL_LEVEL_UNLOCK, "skill_name": "高级文学"},
		],
	},
	{
		"id": "literature_unlock_75",
		"description": "文学能力达到75级，解锁下一阶段技能学习",
		"conditions": ["literature_ge_75"],
		"trigger_type": "skill_up",
		"is_repeatable": false,
		"actions": [
			{"type": ActionType.SKILL_LEVEL_LOCK, "skill_name": "高级文学"},
			{"type": ActionType.SKILL_LEVEL_UNLOCK, "skill_name": "小说家"},
		],
	},
	{
		"id": "literature_unlock_100",
		"description": "文学能力达到100级，已达到最高境界",
		"conditions": ["literature_ge_100"],
		"trigger_type": "skill_up",
		"is_repeatable": false,
		"actions": [
			{"type": ActionType.SKILL_LEVEL_LOCK, "skill_name": "小说家"},
		],
	},
	
	# 编程技能线
	{
		"id": "code_unlock_25",
		"description": "编程能力达到25级，解锁下一阶段技能学习",
		"conditions": ["code_ge_25"],
		"trigger_type": "skill_up",
		"is_repeatable": false,
		"actions": [
			{"type": ActionType.SKILL_LEVEL_LOCK, "skill_name": "自学编程"},
			{"type": ActionType.SKILL_LEVEL_UNLOCK, "skill_name": "学习前端"},
		],
	},
	{
		"id": "code_unlock_50",
		"description": "编程能力达到50级，解锁下一阶段技能学习",
		"conditions": ["code_ge_50"],
		"trigger_type": "skill_up",
		"is_repeatable": false,
		"actions": [
			{"type": ActionType.SKILL_LEVEL_LOCK, "skill_name": "学习前端"},
			{"type": ActionType.SKILL_LEVEL_UNLOCK, "skill_name": "高级编程"},
		],
	},
	{
		"id": "code_unlock_75",
		"description": "编程能力达到75级，解锁下一阶段技能学习",
		"conditions": ["code_ge_75"],
		"trigger_type": "skill_up",
		"is_repeatable": false,
		"actions": [
			{"type": ActionType.SKILL_LEVEL_LOCK, "skill_name": "高级编程"},
			{"type": ActionType.SKILL_LEVEL_UNLOCK, "skill_name": "成为黑客"},
		],
	},
	{
		"id": "code_unlock_100",
		"description": "编程能力达到100级，已达到最高境界",
		"conditions": ["code_ge_100"],
		"trigger_type": "skill_up",
		"is_repeatable": false,
		"actions": [
			{"type": ActionType.SKILL_LEVEL_LOCK, "skill_name": "成为黑客"},
		],
	},
	
	# 绘画技能线
	{
		"id": "draw_unlock_25",
		"description": "绘画能力达到25级，解锁下一阶段技能学习",
		"conditions": ["draw_ge_25"],
		"trigger_type": "skill_up",
		"is_repeatable": false,
		"actions": [
			{"type": ActionType.SKILL_LEVEL_LOCK, "skill_name": "自学画画"},
			{"type": ActionType.SKILL_LEVEL_UNLOCK, "skill_name": "素描和色彩"},
		],
	},
	{
		"id": "draw_unlock_50",
		"description": "绘画能力达到50级，解锁下一阶段技能学习",
		"conditions": ["draw_ge_50"],
		"trigger_type": "skill_up",
		"is_repeatable": false,
		"actions": [
			{"type": ActionType.SKILL_LEVEL_LOCK, "skill_name": "素描和色彩"},
			{"type": ActionType.SKILL_LEVEL_UNLOCK, "skill_name": "原画师之路"},
		],
	},
	{
		"id": "draw_unlock_75",
		"description": "绘画能力达到75级，解锁下一阶段技能学习",
		"conditions": ["draw_ge_75"],
		"trigger_type": "skill_up",
		"is_repeatable": false,
		"actions": [
			{"type": ActionType.SKILL_LEVEL_LOCK, "skill_name": "原画师之路"},
			{"type": ActionType.SKILL_LEVEL_UNLOCK, "skill_name": "大画家"},
		],
	},
	{
		"id": "draw_unlock_100",
		"description": "绘画能力达到100级，已达到最高境界",
		"conditions": ["draw_ge_100"],
		"trigger_type": "skill_up",
		"is_repeatable": false,
		"actions": [
			{"type": ActionType.SKILL_LEVEL_LOCK, "skill_name": "大画家"},
		],
	},
	
	# ====================
	# 博文发布任务
	# ====================
	
	{
		"id": "unlock_first_post",
		"description": "经过一阵子的折腾，博客终于正式上线了！当你准备好就可以发表博客的第一篇博文了！",
		"conditions": ["time_first_post_unlock"],
		"is_repeatable": false,
		"trigger_type": "time_check",  # 需要定时检查
		"actions": [
			{"type": ActionType.UNLOCK_POST_TASK, "post_type": "第一篇博文"},
		],
	},
	{
		"id": "lock_first_post",
		"description": "你已经发布了博客第一篇博文，博客第一篇博文类型发布已锁定。",
		"conditions": ["first_post_eq_1"],
		"is_repeatable": false,
		"trigger_type": "post_event",  # 发布时触发
		"actions": [
			{"type": ActionType.HIDE_POST_TASK, "post_type": "第一篇博文"},
		],
	},
	{
		"id": "unlock_year_summary",
		"description": "每年12月份发布一次年度总结博文",
		"conditions": ["time_year_summary_unlock"],
		"is_repeatable": true,
		"trigger_type": "time_check",
		"duration_days": true,
		"actions": [
			{"type": ActionType.UNLOCK_POST_TASK, "post_type": "年度总结"},
		],
	},
	{
		"id": "lock_year_summary_by_time",
		"description": "发布年度总结最佳时间已过，年度总结博文类型发布已锁定。",
		"conditions": ["time_year_summary_lock"],
		"is_repeatable": true,
		"trigger_type": "time_check",
		"duration_days": true,
		"actions": [
			{"type": ActionType.LOCK_POST_TASK, "post_type": "年度总结"},
		],
	},
	{
		"id": "lock_year_summary_by_post",
		"description": "你已经发布了年度总结，年度总结博文类型发布已锁定。",
		"conditions": ["year_summary_eq_1"],
		"is_repeatable": true,
		"trigger_type": "post_event",
		"duration_days": true,
		"actions": [
			{"type": ActionType.LOCK_POST_TASK, "post_type": "年度总结"},
		],
	},
	
	# ====================
	# 等级成就任务
	# ====================
	
	{
		"id": "milestone_lv10",
		"description": "恭喜您的等级升级到10级，江湖段位达到[出入江湖]！",
		"conditions": ["player_eq_10"],
		"is_repeatable": false,
		"trigger_type": "level_up",
		"actions": [
			{"type": ActionType.UNLOCK_MILESTONES_TASK, "milestones_id": "level_10", "milestones_name": "lv"},
		],
	},
	{
		"id": "milestone_lv20",
		"description": "恭喜您的等级升级到20级，江湖段位达到[崭露头角]！",
		"conditions": ["player_eq_20"],
		"is_repeatable": false,
		"trigger_type": "level_up",
		"actions": [
			{"type": ActionType.UNLOCK_MILESTONES_TASK, "milestones_id": "level_20", "milestones_name": "lv"},
		],
	},
	{
		"id": "milestone_lv30",
		"description": "恭喜您的等级升级到30级，江湖段位达到[锋芒毕露]！",
		"conditions": ["player_eq_30"],
		"is_repeatable": false,
		"trigger_type": "level_up",
		"actions": [
			{"type": ActionType.UNLOCK_MILESTONES_TASK, "milestones_id": "level_30", "milestones_name": "lv"},
		],
	},
	{
		"id": "milestone_lv40",
		"description": "恭喜您的等级升级到40级，江湖段位达到[名扬四海]！",
		"conditions": ["player_eq_40"],
		"is_repeatable": false,
		"trigger_type": "level_up",
		"actions": [
			{"type": ActionType.UNLOCK_MILESTONES_TASK, "milestones_id": "level_40", "milestones_name": "lv"},
		],
	},
	{
		"id": "milestone_lv50",
		"description": "恭喜您的等级升级到50级，江湖段位达到[独步天下]！",
		"conditions": ["player_eq_50"],
		"is_repeatable": false,
		"trigger_type": "level_up",
		"actions": [
			{"type": ActionType.UNLOCK_MILESTONES_TASK, "milestones_id": "level_50", "milestones_name": "lv"},
		],
	},
	{
		"id": "milestone_lv60",
		"description": "恭喜您的等级升级到60级，江湖段位达到[一代宗师]！",
		"conditions": ["player_eq_60"],
		"is_repeatable": false,
		"trigger_type": "level_up",
		"actions": [
			{"type": ActionType.UNLOCK_MILESTONES_TASK, "milestones_id": "level_60", "milestones_name": "lv"},
		],
	},
	{
		"id": "milestone_lv70",
		"description": "恭喜您的等级升级到70级，江湖段位达到[剑气长虹]！",
		"conditions": ["player_eq_70"],
		"is_repeatable": false,
		"trigger_type": "level_up",
		"actions": [
			{"type": ActionType.UNLOCK_MILESTONES_TASK, "milestones_id": "level_70", "milestones_name": "lv"},
		],
	},
	{
		"id": "milestone_lv80",
		"description": "恭喜您的等级升级到80级，江湖段位达到[无敌于世]！",
		"conditions": ["player_eq_80"],
		"is_repeatable": false,
		"trigger_type": "level_up",
		"actions": [
			{"type": ActionType.UNLOCK_MILESTONES_TASK, "milestones_id": "level_80", "milestones_name": "lv"},
		],
	},
	{
		"id": "milestone_lv90",
		"description": "恭喜您的等级升级到90级，江湖段位达到[武林霸主]！",
		"conditions": ["player_eq_90"],
		"is_repeatable": false,
		"trigger_type": "level_up",
		"actions": [
			{"type": ActionType.UNLOCK_MILESTONES_TASK, "milestones_id": "level_90", "milestones_name": "lv"},
		],
	},
	{
		"id": "milestone_lv100",
		"description": "恭喜您的等级升级到100级，江湖段位达到[天外飞仙]！",
		"conditions": ["player_eq_100"],
		"is_repeatable": false,
		"trigger_type": "level_up",
		"actions": [
			{"type": ActionType.UNLOCK_MILESTONES_TASK, "milestones_id": "level_100", "milestones_name": "lv"},
		],
	},
	
	# ====================
	# 热点风向任务
	# ====================
	
	{
		"id": "trend_change",
		"description": "每年两次的热点切换",
		"conditions": ["time_trend_change"],
		"is_repeatable": true,
		"trigger_type": "time_check",
		"duration_days": true,
		"actions": [
			{"type": ActionType.REPLACE_POST_TREND},
		],
	},
]

## ============================================================
## 辅助方法
## ============================================================

## 获取技能进度配置
static func get_skill_progress(skill_name: String) -> Dictionary:
	return SKILL_PROGRESS_CONFIG.get(skill_name, {})

## 获取条件配置
static func get_condition(cond_id: String) -> Dictionary:
	return CONDITIONS.get(cond_id, {})