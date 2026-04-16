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
    SKILL_VALUE,     # 技能数值（能力值 0-100）
    SKILL_LEVEL,     # 技能等级（学习阶段 1-4）
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
    START_BOOK_WRITE,        # 开始写书（出版畅销书）
    BOOK_PROGRESS,           # 写书进度更新
    BOOK_PHASE_CHANGE,       # 书籍阶段变化
    TRIGGER_IP_AUTH,         # 触发IP授权
    TRIGGER_ANIME_IP_AUTH,   # 触发动漫IP授权
    IP_MONTHLY_INCOME,       # IP月收益结算
    START_OPEN_SOURCE_PROJECT,  # 开始开源项目
    OPEN_SOURCE_PROGRESS,    # 开源项目进度
    OPEN_SOURCE_ACQUISITION, # 开源项目被收购
}

## ============================================================
## 可复用条件定义
## ============================================================

const CONDITIONS: Dictionary = {
    # 技能数值条件 - 文学（每20能力值一个等级）
    "literature_value_ge_20": {"type": ConditionType.SKILL_VALUE, "skill": "LITERATURE", "op": CompareOp.GE, "value": 20},
    "literature_value_ge_40": {"type": ConditionType.SKILL_VALUE, "skill": "LITERATURE", "op": CompareOp.GE, "value": 40},
    "literature_value_ge_60": {"type": ConditionType.SKILL_VALUE, "skill": "LITERATURE", "op": CompareOp.GE, "value": 60},
    "literature_value_ge_80": {"type": ConditionType.SKILL_VALUE, "skill": "LITERATURE", "op": CompareOp.GE, "value": 80},
    "literature_value_ge_90": {"type": ConditionType.SKILL_VALUE, "skill": "LITERATURE", "op": CompareOp.GE, "value": 90},
    "literature_value_ge_100": {"type": ConditionType.SKILL_VALUE, "skill": "LITERATURE", "op": CompareOp.GE, "value": 100},
    
    # 技能数值条件 - 编程（每20能力值一个等级）
    "code_value_ge_20": {"type": ConditionType.SKILL_VALUE, "skill": "CODE", "op": CompareOp.GE, "value": 20},
    "code_value_ge_40": {"type": ConditionType.SKILL_VALUE, "skill": "CODE", "op": CompareOp.GE, "value": 40},
    "code_value_ge_60": {"type": ConditionType.SKILL_VALUE, "skill": "CODE", "op": CompareOp.GE, "value": 60},
    "code_value_ge_80": {"type": ConditionType.SKILL_VALUE, "skill": "CODE", "op": CompareOp.GE, "value": 80},
    "code_value_ge_100": {"type": ConditionType.SKILL_VALUE, "skill": "CODE", "op": CompareOp.GE, "value": 100},
    
    # 技能数值条件 - 绘画（每20能力值一个等级）
    "draw_value_ge_20": {"type": ConditionType.SKILL_VALUE, "skill": "DRAW", "op": CompareOp.GE, "value": 20},
    "draw_value_ge_40": {"type": ConditionType.SKILL_VALUE, "skill": "DRAW", "op": CompareOp.GE, "value": 40},
    "draw_value_ge_60": {"type": ConditionType.SKILL_VALUE, "skill": "DRAW", "op": CompareOp.GE, "value": 60},
    "draw_value_ge_80": {"type": ConditionType.SKILL_VALUE, "skill": "DRAW", "op": CompareOp.GE, "value": 80},
    "draw_value_ge_100": {"type": ConditionType.SKILL_VALUE, "skill": "DRAW", "op": CompareOp.GE, "value": 100},
    
    # 复合条件 - IP授权（需要两项都满足）
    "literature_value_ge_100_and_novel_50": {"type": ConditionType.CUSTOM, "check_func": "check_literature_ip_auth"},
    "draw_value_ge_100_and_anime_50": {"type": ConditionType.CUSTOM, "check_func": "check_draw_ip_auth"},
    
    # 玩家等级条件（使用GE避免跳级漏触发）
    "player_ge_10": {"type": ConditionType.PLAYER_LEVEL, "op": CompareOp.GE, "value": 10},
    "player_ge_20": {"type": ConditionType.PLAYER_LEVEL, "op": CompareOp.GE, "value": 20},
    "player_ge_30": {"type": ConditionType.PLAYER_LEVEL, "op": CompareOp.GE, "value": 30},
    "player_ge_40": {"type": ConditionType.PLAYER_LEVEL, "op": CompareOp.GE, "value": 40},
    "player_ge_50": {"type": ConditionType.PLAYER_LEVEL, "op": CompareOp.GE, "value": 50},
    "player_ge_60": {"type": ConditionType.PLAYER_LEVEL, "op": CompareOp.GE, "value": 60},
    "player_ge_70": {"type": ConditionType.PLAYER_LEVEL, "op": CompareOp.GE, "value": 70},
    "player_ge_80": {"type": ConditionType.PLAYER_LEVEL, "op": CompareOp.GE, "value": 80},
    "player_ge_90": {"type": ConditionType.PLAYER_LEVEL, "op": CompareOp.GE, "value": 90},
    "player_ge_100": {"type": ConditionType.PLAYER_LEVEL, "op": CompareOp.GE, "value": 100},
    
    # 发布次数条件
    "first_post_eq_1": {"type": ConditionType.POST_COUNT, "post_type": "第一篇博文", "op": CompareOp.GE, "value": 1},
    "year_summary_eq_1": {"type": ConditionType.POST_COUNT, "post_type": "年度总结", "op": CompareOp.GE, "value": 1},
    "novel_serial_ge_50": {"type": ConditionType.POST_COUNT, "post_type": "小说连载(付费)", "op": CompareOp.GE, "value": 50},
    "anime_serial_ge_50": {"type": ConditionType.POST_COUNT, "post_type": "动漫连载(收费)", "op": CompareOp.GE, "value": 50},
    "anime_serial_ge_60": {"type": ConditionType.POST_COUNT, "post_type": "动漫连载(收费)", "op": CompareOp.GE, "value": 60},
    "anime_serial_ge_70": {"type": ConditionType.POST_COUNT, "post_type": "动漫连载(收费)", "op": CompareOp.GE, "value": 70},
    
    # 写书状态条件
    "book_writing_started": {"type": ConditionType.CUSTOM, "check_func": "check_book_writing"},
    
    # 开源项目状态条件
    "open_source_project_started": {"type": ConditionType.CUSTOM, "check_func": "check_open_source_project"},
    
    # 时间条件（配合 event_date 使用）
    # 注意：游戏起始年份为 2005 年
    # 第一篇博文：游戏开始即可解锁（2005年1月第1周第1天）
    "time_first_post_unlock": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [2005], "m": [1], "w": [1], "d": [3]}},
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
            20: {"lock": "文学入门", "unlock": "写作新手"},
            40: {"lock": "写作新手", "unlock": "创作达人"},
            60: {"lock": "创作达人", "unlock": "人气作家"},
            80: {"lock": "人气作家", "unlock": "文学大师"},
            100: {"lock": "文学大师", "unlock": null},
        }
    },
    "CODE": {
        "skill_enum": "CODE",
        "progress": {
            20: {"lock": "自学编程", "unlock": "学习前端"},
            40: {"lock": "学习前端", "unlock": "高级编程"},
            60: {"lock": "高级编程", "unlock": "网络安全"},
            80: {"lock": "网络安全", "unlock": "成为黑客"},
            100: {"lock": "成为黑客", "unlock": null},
        }
    },
    "DRAW": {
        "skill_enum": "DRAW",
        "progress": {
            20: {"lock": "画渣上路", "unlock": "手绘基础"},
            40: {"lock": "手绘基础", "unlock": "板绘达人"},
            60: {"lock": "板绘达人", "unlock": "游戏原画"},
            80: {"lock": "游戏原画", "unlock": "美术总监"},
            100: {"lock": "美术总监", "unlock": null},
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
        "id": "literature_unlock_20",
        "description": "文学能力值达到20，解锁文学2级技能",
        "conditions": ["literature_value_ge_20"],
        "trigger_type": "skill_up",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.SKILL_LEVEL_LOCK, "skill_name": "文学入门"},
            {"type": ActionType.SKILL_LEVEL_UNLOCK, "skill_name": "写作新手"},
        ],
    },
    {
        "id": "literature_unlock_40",
        "description": "文学能力值达到40，解锁文学3级技能",
        "conditions": ["literature_value_ge_40"],
        "trigger_type": "skill_up",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.SKILL_LEVEL_LOCK, "skill_name": "写作新手"},
            {"type": ActionType.SKILL_LEVEL_UNLOCK, "skill_name": "创作达人"},
        ],
    },
    {
        "id": "literature_unlock_60",
        "description": "文学能力值达到60，解锁文学4级技能",
        "conditions": ["literature_value_ge_60"],
        "trigger_type": "skill_up",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.SKILL_LEVEL_LOCK, "skill_name": "创作达人"},
            {"type": ActionType.SKILL_LEVEL_UNLOCK, "skill_name": "人气作家"},
        ],
    },
    {
        "id": "literature_unlock_80",
        "description": "文学能力值达到80，解锁文学5级技能（最高级）",
        "conditions": ["literature_value_ge_80"],
        "trigger_type": "skill_up",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.SKILL_LEVEL_LOCK, "skill_name": "人气作家"},
            {"type": ActionType.SKILL_LEVEL_UNLOCK, "skill_name": "文学大师"},
        ],
    },
    {
        "id": "literature_unlock_90",
        "description": "文学能力值达到90，可开始创作畅销书（测试版）",
        "conditions": ["literature_value_ge_90"],
        "trigger_type": "skill_up",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.SKILL_LEVEL_LOCK, "skill_name": "文学大师"},
            {"type": ActionType.START_BOOK_WRITE},
        ],
    },
    
    # ====================
    # 文学文章解锁任务（按技能等级触发）
    # ====================
    {
        "id": "literature_post_unlock_20",
        "description": "文学能力值达到20，解锁散文随笔文章类型",
        "conditions": ["literature_value_ge_20"],
        "trigger_type": "skill_up",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.UNLOCK_POST_TASK, "post_type": "散文随笔"},
        ],
    },
    {
        "id": "literature_post_unlock_40",
        "description": "文学能力值达到40，解锁文学周刊文章类型",
        "conditions": ["literature_value_ge_40"],
        "trigger_type": "skill_up",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.UNLOCK_POST_TASK, "post_type": "文学周刊"},
        ],
    },
    {
        "id": "literature_post_unlock_60",
        "description": "文学能力值达到60，解锁爆款网文文章类型",
        "conditions": ["literature_value_ge_60"],
        "trigger_type": "skill_up",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.UNLOCK_POST_TASK, "post_type": "爆款网文"},
        ],
    },
    {
        "id": "literature_post_unlock_80",
        "description": "文学能力值达到80，解锁小说连载(付费)文章类型",
        "conditions": ["literature_value_ge_80"],
        "trigger_type": "skill_up",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.UNLOCK_POST_TASK, "post_type": "小说连载(付费)"},
        ],
    },
    {
        "id": "literature_post_unlock_90",
        "description": "文学能力值达到90，解锁出版畅销书写作（测试版）",
        "conditions": ["literature_value_ge_90"],
        "trigger_type": "skill_up",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.UNLOCK_POST_TASK, "post_type": "出版畅销书"},
        ],
    },
    
    # ====================
    # 出版畅销书进度任务（发布文章时自动累计进度）
    # ====================
    {
        "id": "book_publish_progress",
        "description": "发布出版畅销书文章，累计进度",
        "conditions": [],
        "trigger_type": "post_event",
        "is_repeatable": true,
        "actions": [
            {"type": ActionType.BOOK_PROGRESS, "progress": 1},
        ],
    },
    
    # ====================
    # IP授权解锁任务（简化版 - 逻辑已在 blogger.gd 中处理）
    # ====================
    {
        "id": "ip_authorization_unlock",
        "description": "小说连载每批次≥50篇后，有机会触发IP授权！",
        "conditions": ["novel_serial_ge_50"],
        "trigger_type": "post_event",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.SHOW_NOTIFICATION, "message": "IP授权触发检查已在新小说发布时自动处理"},
        ],
    },

    # ====================
    # 绘画文章解锁任务
    # ====================
    {
        "id": "draw_post_unlock_20",
        "description": "绘画能力值达到20，解锁绘画基础教程文章类型",
        "conditions": ["draw_value_ge_20"],
        "trigger_type": "skill_up",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.UNLOCK_POST_TASK, "post_type": "绘画基础教程"},
        ],
    },
    {
        "id": "draw_post_unlock_40",
        "description": "绘画能力值达到40，解锁商业插画高级教程文章类型",
        "conditions": ["draw_value_ge_40"],
        "trigger_type": "skill_up",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.UNLOCK_POST_TASK, "post_type": "商业插画高级教程"},
        ],
    },
    {
        "id": "draw_post_unlock_60",
        "description": "绘画能力值达到60，解锁艺术周刊文章类型",
        "conditions": ["draw_value_ge_60"],
        "trigger_type": "skill_up",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.UNLOCK_POST_TASK, "post_type": "艺术周刊"},
        ],
    },
    {
        "id": "draw_post_unlock_80",
        "description": "绘画能力值达到80，解锁动漫连载(收费)文章类型",
        "conditions": ["draw_value_ge_80"],
        "trigger_type": "skill_up",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.UNLOCK_POST_TASK, "post_type": "动漫连载(收费)"},
        ],
    },

    # ====================
    # 动画影视创作解锁任务
    # ====================
    {
        "id": "animation_movie_unlock",
        "description": "绘画能力达到100级且动漫连载发布超过50篇，解锁动画影视创作！",
        "conditions": ["draw_value_ge_100", "anime_serial_ge_50"],
        "trigger_type": "post_event",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.UNLOCK_POST_TASK, "post_type": "动画影视创作"},
        ],
    },
    
    # ====================
    # 动漫IP授权解锁任务
    # ====================
    {
        "id": "anime_ip_authorization_unlock",
        "description": "绘画能力达到100级且动漫连载发布超过50篇，触发动漫IP授权事件！",
        "conditions": ["draw_value_ge_100", "anime_serial_ge_50"],
        "trigger_type": "post_event",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.TRIGGER_ANIME_IP_AUTH},
        ],
    },
    
    # ====================
    # 出书笔记解锁任务
    # ====================
    {
        "id": "unlock_book_notes",
        "description": "开始写书后，解锁出书笔记文章类型",
        "conditions": ["book_writing_started"],
        "trigger_type": "book_event",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.UNLOCK_POST_TASK, "post_type": "出书笔记"},
        ],
    },
    
    # 编程技能线
    {
        "id": "code_unlock_20",
        "description": "编程能力值达到20，解锁编程2级技能",
        "conditions": ["code_value_ge_20"],
        "trigger_type": "skill_up",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.SKILL_LEVEL_LOCK, "skill_name": "自学编程"},
            {"type": ActionType.SKILL_LEVEL_UNLOCK, "skill_name": "学习前端"},
        ],
    },
    {
        "id": "code_unlock_40",
        "description": "编程能力值达到40，解锁编程3级技能",
        "conditions": ["code_value_ge_40"],
        "trigger_type": "skill_up",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.SKILL_LEVEL_LOCK, "skill_name": "学习前端"},
            {"type": ActionType.SKILL_LEVEL_UNLOCK, "skill_name": "高级编程"},
        ],
    },
    {
        "id": "code_unlock_60",
        "description": "编程能力值达到60，解锁编程4级技能",
        "conditions": ["code_value_ge_60"],
        "trigger_type": "skill_up",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.SKILL_LEVEL_LOCK, "skill_name": "高级编程"},
            {"type": ActionType.SKILL_LEVEL_UNLOCK, "skill_name": "网络安全"},
        ],
    },
    {
        "id": "code_unlock_80",
        "description": "编程能力值达到80，解锁编程5级技能（最高级）",
        "conditions": ["code_value_ge_80"],
        "trigger_type": "skill_up",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.SKILL_LEVEL_LOCK, "skill_name": "网络安全"},
            {"type": ActionType.SKILL_LEVEL_UNLOCK, "skill_name": "成为黑客"},
        ],
    },
    {
        "id": "code_unlock_100",
        "description": "编程能力值达到100，已达到最高境界",
        "conditions": ["code_value_ge_100"],
        "trigger_type": "skill_up",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.SKILL_LEVEL_LOCK, "skill_name": "成为黑客"},
            {"type": ActionType.START_OPEN_SOURCE_PROJECT},
        ],
    },
    
    # ====================
    # 编程文章解锁任务（按技能等级触发）
    # ====================
    {
        "id": "code_post_unlock_20",
        "description": "编程能力值达到20，解锁编程教程文章类型",
        "conditions": ["code_value_ge_20"],
        "trigger_type": "skill_up",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.UNLOCK_POST_TASK, "post_type": "编程教程"},
        ],
    },
    {
        "id": "code_post_unlock_40",
        "description": "编程能力值达到40，解锁程序员周刊文章类型",
        "conditions": ["code_value_ge_40"],
        "trigger_type": "skill_up",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.UNLOCK_POST_TASK, "post_type": "程序员周刊"},
        ],
    },
    {
        "id": "code_post_unlock_60",
        "description": "编程能力值达到60，解锁高级编程教程文章类型",
        "conditions": ["code_value_ge_60"],
        "trigger_type": "skill_up",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.UNLOCK_POST_TASK, "post_type": "高级编程教程"},
        ],
    },
    {
        "id": "code_post_unlock_80",
        "description": "编程能力值达到80，解锁付费黑客攻防文章类型",
        "conditions": ["code_value_ge_80"],
        "trigger_type": "skill_up",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.UNLOCK_POST_TASK, "post_type": "付费黑客攻防"},
        ],
    },
    {
        "id": "code_post_unlock_100",
        "description": "编程能力值达到100，解锁开源项目",
        "conditions": ["code_value_ge_100"],
        "trigger_type": "skill_up",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.UNLOCK_POST_TASK, "post_type": "开源项目"},
        ],
    },
    
    # ====================
    # 开源维护笔记解锁任务
    # ====================
    {
        "id": "unlock_open_source_notes",
        "description": "开始创建开源项目后，解锁开源维护笔记文章类型",
        "conditions": ["open_source_project_started"],
        "trigger_type": "open_source_event",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.UNLOCK_POST_TASK, "post_type": "开源维护笔记"},
        ],
    },
    
    # 绘画技能线
    {
        "id": "draw_unlock_20",
        "description": "绘画能力值达到20，解锁绘画2级技能",
        "conditions": ["draw_value_ge_20"],
        "trigger_type": "skill_up",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.SKILL_LEVEL_LOCK, "skill_name": "画渣上路"},
            {"type": ActionType.SKILL_LEVEL_UNLOCK, "skill_name": "手绘基础"},
        ],
    },
    {
        "id": "draw_unlock_40",
        "description": "绘画能力值达到40，解锁绘画3级技能",
        "conditions": ["draw_value_ge_40"],
        "trigger_type": "skill_up",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.SKILL_LEVEL_LOCK, "skill_name": "手绘基础"},
            {"type": ActionType.SKILL_LEVEL_UNLOCK, "skill_name": "板绘达人"},
        ],
    },
    {
        "id": "draw_unlock_60",
        "description": "绘画能力值达到60，解锁绘画4级技能",
        "conditions": ["draw_value_ge_60"],
        "trigger_type": "skill_up",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.SKILL_LEVEL_LOCK, "skill_name": "板绘达人"},
            {"type": ActionType.SKILL_LEVEL_UNLOCK, "skill_name": "游戏原画"},
        ],
    },
    {
        "id": "draw_unlock_80",
        "description": "绘画能力值达到80，解锁绘画5级技能（最高级）",
        "conditions": ["draw_value_ge_80"],
        "trigger_type": "skill_up",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.SKILL_LEVEL_LOCK, "skill_name": "游戏原画"},
            {"type": ActionType.SKILL_LEVEL_UNLOCK, "skill_name": "美术总监"},
        ],
    },
    {
        "id": "draw_unlock_100",
        "description": "绘画能力值达到100，已达到最高境界",
        "conditions": ["draw_value_ge_100"],
        "trigger_type": "skill_up",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.SKILL_LEVEL_LOCK, "skill_name": "美术总监"},
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
        "description": "恭喜您的等级升级到10级，江湖段位达到[崭露头角]！",
        "conditions": ["player_ge_10"],
        "is_repeatable": false,
        "trigger_type": "level_up",
        "actions": [
            {"type": ActionType.UNLOCK_MILESTONES_TASK, "milestones_id": "level_10", "milestones_name": "lv"},
        ],
    },
    {
        "id": "milestone_lv20",
        "description": "恭喜您的等级升级到20级，江湖段位达到[锋芒毕露]！",
        "conditions": ["player_ge_20"],
        "is_repeatable": false,
        "trigger_type": "level_up",
        "actions": [
            {"type": ActionType.UNLOCK_MILESTONES_TASK, "milestones_id": "level_20", "milestones_name": "lv"},
        ],
    },
    {
        "id": "milestone_lv30",
        "description": "恭喜您的等级升级到30级，江湖段位达到[锋芒毕露]！",
        "conditions": ["player_ge_30"],
        "is_repeatable": false,
        "trigger_type": "level_up",
        "actions": [
            {"type": ActionType.UNLOCK_MILESTONES_TASK, "milestones_id": "level_30", "milestones_name": "lv"},
        ],
    },
    {
        "id": "milestone_lv40",
        "description": "恭喜您的等级升级到40级，江湖段位达到[名扬四海]！",
        "conditions": ["player_ge_40"],
        "is_repeatable": false,
        "trigger_type": "level_up",
        "actions": [
            {"type": ActionType.UNLOCK_MILESTONES_TASK, "milestones_id": "level_40", "milestones_name": "lv"},
        ],
    },
    {
        "id": "milestone_lv50",
        "description": "恭喜您的等级升级到50级，江湖段位达到[独步天下]！",
        "conditions": ["player_ge_50"],
        "is_repeatable": false,
        "trigger_type": "level_up",
        "actions": [
            {"type": ActionType.UNLOCK_MILESTONES_TASK, "milestones_id": "level_50", "milestones_name": "lv"},
        ],
    },
    {
        "id": "milestone_lv60",
        "description": "恭喜您的等级升级到60级，江湖段位达到[一代宗师]！",
        "conditions": ["player_ge_60"],
        "is_repeatable": false,
        "trigger_type": "level_up",
        "actions": [
            {"type": ActionType.UNLOCK_MILESTONES_TASK, "milestones_id": "level_60", "milestones_name": "lv"},
        ],
    },
    {
        "id": "milestone_lv70",
        "description": "恭喜您的等级升级到70级，江湖段位达到[剑气长虹]！",
        "conditions": ["player_ge_70"],
        "is_repeatable": false,
        "trigger_type": "level_up",
        "actions": [
            {"type": ActionType.UNLOCK_MILESTONES_TASK, "milestones_id": "level_70", "milestones_name": "lv"},
        ],
    },
    {
        "id": "milestone_lv80",
        "description": "恭喜您的等级升级到80级，江湖段位达到[无敌于世]！",
        "conditions": ["player_ge_80"],
        "is_repeatable": false,
        "trigger_type": "level_up",
        "actions": [
            {"type": ActionType.UNLOCK_MILESTONES_TASK, "milestones_id": "level_80", "milestones_name": "lv"},
        ],
    },
    {
        "id": "milestone_lv90",
        "description": "恭喜您的等级升级到90级，江湖段位达到[武林霸主]！",
        "conditions": ["player_ge_90"],
        "is_repeatable": false,
        "trigger_type": "level_up",
        "actions": [
            {"type": ActionType.UNLOCK_MILESTONES_TASK, "milestones_id": "level_90", "milestones_name": "lv"},
        ],
    },
    {
        "id": "milestone_lv100",
        "description": "恭喜您的等级升级到100级，江湖段位达到[天外飞仙]！",
        "conditions": ["player_ge_100"],
        "is_repeatable": false,
        "trigger_type": "level_up",
        "actions": [
            {"type": ActionType.UNLOCK_MILESTONES_TASK, "milestones_id": "level_90", "milestones_name": "lv"},
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
