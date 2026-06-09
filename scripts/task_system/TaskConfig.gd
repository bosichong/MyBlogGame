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
    POST_COUNT,      # 发布次数（按类型）
    ARTICLE_COUNT,   # 文章总数（所有文章）
    SEO_VALUE,       # SEO值
    TIME_MATCH,      # 时间匹配
    MILESTONE_COMPLETED,  # 里程碑已完成（用于跳过剧情）
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
    UNLOCK_INITIAL_TASKS,    # 解锁初始16个任务选项（日常创作、网站维护、休闲娱乐、自律学习）
    START_GAME_TIME,         # 启动游戏时间（从暂停状态恢复）
    SET_STORY_MILESTONE,    # 设置剧情里程碑（chapter: int, milestone: String）
    SHOW_NOTIFICATION,       # 显示信息通知（显示在信息区域）
    UNLOCK_WEBSITE_MAINTENANCE,  # 解锁网站维护任务
    SET_ICP_FILING_NUMBER,   # 设置ICP备案号
    SHOW_POPUP_NOTIFICATION, # 显示弹窗通知（弹出窗口）
    SEO_NOTIFICATION,        # SEO提示弹窗+升级奖励
    UPDATE_BLOG_UNION_BUTTON, # 更新博客联盟按钮状态
    ADD_ARCHIVE_EVENT,        # 添加博客历史事件（event_id, title, description）
}

## ============================================================
## 可复用条件定义
## ============================================================

const CONDITIONS: Dictionary = {
    # 文章总数条件
    "article_count_ge_10": {"type": ConditionType.ARTICLE_COUNT, "op": CompareOp.GE, "value": 10},
    
    # SEO值条件
    "seo_value_eq_100": {"type": ConditionType.SEO_VALUE, "op": CompareOp.EQ, "value": 100},
    
    # 博客联盟状态条件
    "blog_union_not_joined": {"type": ConditionType.CUSTOM, "check_func": "check_blog_union_not_joined"},
    
    # SEO收录状态条件（未收录时触发）
    "sousuo_not_indexed": {"type": ConditionType.CUSTOM, "check_func": "check_sousuo_not_indexed"},
    
    # 友链相关条件
    "first_friend_link_not_done": {"type": ConditionType.MILESTONE_COMPLETED, "chapter": 1, "milestone": "first_friend_link", "completed": false},
    "friend_link_added": {"type": ConditionType.CUSTOM, "check_func": "check_friend_link_added"},
    
    # 里程碑已完成条件（用于跳过剧情）
    "first_article_not_done": {"type": ConditionType.MILESTONE_COMPLETED, "chapter": 1, "milestone": "first_article_posted", "completed": false},
    "first_article_completed": {"type": ConditionType.MILESTONE_COMPLETED, "chapter": 1, "milestone": "first_article_posted", "completed": true},

    # 技能数值条件 - 文学（每20能力值一个等级）
    "literature_value_ge_20": {"type": 0, "skill": "LITERATURE", "op": 3, "value": 20},
    "literature_value_ge_40": {"type": 0, "skill": "LITERATURE", "op": 3, "value": 40},
    "literature_value_ge_60": {"type": 0, "skill": "LITERATURE", "op": 3, "value": 60},
    "literature_value_ge_80": {"type": 0, "skill": "LITERATURE", "op": 3, "value": 80},
    "literature_value_ge_90": {"type": 0, "skill": "LITERATURE", "op": 3, "value": 90},
    "literature_value_ge_100": {"type": 0, "skill": "LITERATURE", "op": 3, "value": 100},
    
    # 技能数值条件 - 编程（每20能力值一个等级）
    "code_value_ge_20": {"type": 0, "skill": "CODE", "op": 3, "value": 20},
    "code_value_ge_40": {"type": 0, "skill": "CODE", "op": 3, "value": 40},
    "code_value_ge_60": {"type": 0, "skill": "CODE", "op": 3, "value": 60},
    "code_value_ge_80": {"type": 0, "skill": "CODE", "op": 3, "value": 80},
    "code_value_ge_90": {"type": 0, "skill": "CODE", "op": 3, "value": 90},
    "code_value_ge_100": {"type": 0, "skill": "CODE", "op": 3, "value": 100},
    
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
    "spring_festival_eq_6": {"type": ConditionType.POST_COUNT, "post_type": "春节特辑", "op": CompareOp.GE, "value": 6},
    "labor_day_eq_3": {"type": ConditionType.POST_COUNT, "post_type": "五一特辑", "op": CompareOp.GE, "value": 3},
    "national_day_eq_7": {"type": ConditionType.POST_COUNT, "post_type": "国庆特辑", "op": CompareOp.GE, "value": 7},
    "novel_serial_ge_50": {"type": ConditionType.POST_COUNT, "post_type": "小说连载(付费)", "op": CompareOp.GE, "value": 50},
    
    # 写书状态条件
    "book_writing_started": {"type": ConditionType.CUSTOM, "check_func": "check_book_writing"},

    # 2005年度总结条件（仅2005年发布的年度总结）
    "year_summary_2005_posted": {"type": ConditionType.CUSTOM, "check_func": "check_year_summary_2005"},
    
    # 开源项目状态条件
    "open_source_project_started": {"type": ConditionType.CUSTOM, "check_func": "check_open_source_project"},
    
    # 时间条件（配合 event_date 使用）
    # 注意：游戏起始年份为 2001 年（可通过 TimeData.GAME_START_YEAR 获取）
    # 第一篇博文：游戏开始即可解锁（2001年12月第4周第7天，周日）
    "time_first_post_unlock": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [TimeData.GAME_START_YEAR], "m": [12], "w": [4], "d": [7]}},
    "time_year_summary_unlock": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [0], "m": [12], "w": [2], "d": [1]}},
    "time_year_summary_lock": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [0], "m": [12], "w": [4], "d": [7]}},
    "time_trend_change": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [0], "m": [1, 6], "w": [2], "d": [1]}},
    
    # 春节特辑时间条件（每年2月）
    "time_spring_festival_unlock": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [0], "m": [2], "w": [3], "d": [1]}},
    "time_spring_festival_lock": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [0], "m": [2], "w": [4], "d": [7]}},
    
    # 五一特辑时间条件（每年5月）
    "time_labor_day_unlock": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [0], "m": [5], "w": [1], "d": [1]}},
    "time_labor_day_lock": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [0], "m": [5], "w": [2], "d": [7]}},
    
    # 国庆特辑时间条件（每年10月）
    "time_national_day_unlock": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [0], "m": [10], "w": [1], "d": [1]}},
    "time_national_day_lock": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [0], "m": [10], "w": [2], "d": [7]}},
    
    # ICP备案时间条件（2002年1月第三周第一天）
    "time_icp_filing": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [2004], "m": [1], "w": [3], "d": [1]}},
    
    # 第一届优秀博客大赛通知（2005年11月第1周第1天）
    "time_blog_competition_2005": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [2005], "m": [11], "w": [1], "d": [1]}},
    
    # 第一届优秀博客大赛评选（2005年11月第2周第1天）
    "time_blog_competition_2005_pingxuan": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [2005], "m": [11], "w": [2], "d": [1]}},
    
    # ICP备案进行中条件
    "icp_filing_in_progress": {"type": ConditionType.CUSTOM, "check_func": "check_icp_filing_in_progress"},
    
    # 广告联盟第一笔收益条件
    "first_ad_income_not_done": {"type": ConditionType.MILESTONE_COMPLETED, "chapter": 1, "milestone": "first_income", "completed": false},
    
    # RSS订阅条件
    "rss_enabled_not_done": {"type": ConditionType.MILESTONE_COMPLETED, "chapter": 1, "milestone": "rss_enabled", "completed": false},
    
    # 第一次文章收藏条件
    "first_article_favorited_not_done": {"type": ConditionType.MILESTONE_COMPLETED, "chapter": 1, "milestone": "first_article_favorited", "completed": false},
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
            80: {"lock": "人气作家", "unlock": "哲辩大师"},
            100: {"lock": "哲辩大师", "unlock": null},
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
            {"type": ActionType.SKILL_LEVEL_UNLOCK, "skill_name": "哲辩大师"},
        ],
    },
    {
        "id": "literature_unlock_90",
        "description": "文学能力值达到90，可开始创作畅销书（测试版）",
        "conditions": ["literature_value_ge_90"],
        "trigger_type": "skill_up",
        "is_repeatable": false,
        "actions": [
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
        "post_type_filter": "出版畅销书",  # 只在发布出版畅销书时触发
        "is_repeatable": true,
        "actions": [
            {"type": ActionType.BOOK_PROGRESS, "progress": 1},
        ],
    },
    
    # ====================
    # 开源项目进度任务（发布文章时自动累计进度）
    # ====================
    {
        "id": "open_source_progress",
        "description": "发布开源项目文章，累计进度",
        "conditions": [],
        "trigger_type": "post_event",
        "post_type_filter": "开源项目",  # 只在发布开源项目时触发
        "is_repeatable": true,
        "actions": [
            {"type": ActionType.OPEN_SOURCE_PROGRESS, "progress": 1},
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
        "id": "code_unlock_90",
        "description": "编程能力值达到90，可开始创建开源项目",
        "conditions": ["code_value_ge_90"],
        "trigger_type": "skill_up",
        "is_repeatable": false,
        "actions": [
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
        "description": "编程能力值达到60，解锁极客前沿文章类型",
        "conditions": ["code_value_ge_60"],
        "trigger_type": "skill_up",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.UNLOCK_POST_TASK, "post_type": "极客前沿"},
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
    
    # ====================
    # 博文发布任务
    # ====================
    
    {
        "id": "unlock_first_post",
        "description": "经过一阵子的折腾，博客终于正式上线了！当你准备好就可以发表博客的第一篇博文了！",
        "conditions": ["time_first_post_unlock"],
        "is_repeatable": false,
        "trigger_type": "time_check",
        "actions": [
            {"type": ActionType.UNLOCK_POST_TASK, "post_type": "第一篇博文"},
        ],
    },
    {
        "id": "lock_first_post",
        "description": "你已经发布了博客第一篇博文，博客第一篇博文类型发布已锁定。",
        "conditions": ["first_post_eq_1"],
        "is_repeatable": false,
        "trigger_type": "post_event",
        "actions": [
            {"type": ActionType.HIDE_POST_TASK, "post_type": "第一篇博文"},
        ],
    },
    {
        "id": "unlock_blogging_start",
        "description": "第一篇博文发布成功，博客运营正式开始！",
        "conditions": ["first_post_eq_1", "first_article_not_done"],
        "is_repeatable": false,
        "trigger_type": "post_event",
        "actions": [
            {"type": ActionType.SET_STORY_MILESTONE, "chapter": 1, "milestone": "first_article_posted"},
            {"type": ActionType.UNLOCK_INITIAL_TASKS},
            {"type": ActionType.SHOW_POPUP_NOTIFICATION, "title": "🎉 博客的运营，正式开始！", "content": "========================================\n📝 日常创作已解锁：生活日记、网站运维、观影读书、Coding笔记\n🔧 网站维护已解锁：安全维护、SEO优化、页面美化、友链维护、评论管理\n🎮 休闲娱乐已解锁：打游戏、吃烧烤，和宠物玩、城市周边自驾游，开Party\n📚 自律学习已解锁：文学入门、自学编程\n========================================"},
            {"type": ActionType.START_GAME_TIME},
        ],
    },
    
    # ====================
    # 跳过第一篇博文时解锁日常任务（调试用）
    # ====================
    {
        "id": "unlock_initial_tasks_debug",
        "description": "调试跳过：first_article_posted=true 时直接解锁16个日常任务",
        "conditions": ["first_article_completed"],
        "is_repeatable": false,
        "trigger_type": "time_check",
        "actions": [
            {"type": ActionType.UNLOCK_INITIAL_TASKS},
            {"type": ActionType.START_GAME_TIME},
        ],
    },
    
    # ====================
    # 博客联盟解锁任务
    # ====================
    {
        "id": "blog_union_unlock",
        "description": "SEO值达到100，解锁博客联盟",
        "conditions": ["seo_value_eq_100", "blog_union_not_joined"],
        "is_repeatable": false,
        "trigger_type": "time_check",
        "actions": [
            {"type": ActionType.SHOW_POPUP_NOTIFICATION, "title": "博客江湖邀请", "content": "恭喜！您的博客SEO值已达到100！\n\n博客江湖是全球最大的中文独立博客联盟，致力于汇聚天下独立博客。\n\n【加入好处】\n• 认识志同道合的博友\n• 获得友链推荐\n• 参与联盟活动\n• 提升博客影响力\n\n点击确定加入博客江湖！"},
            {"type": ActionType.SET_STORY_MILESTONE, "chapter": 1, "milestone": "blog_union_joined"},
        ],
    },
    {
        "id": "first_friend_link",
        "description": "获得第一个友情链接",
        "conditions": ["first_friend_link_not_done", "friend_link_added"],
        "is_repeatable": false,
        "trigger_type": "friendlink_added",
        "actions": [
            {"type": ActionType.SHOW_POPUP_NOTIFICATION, 
             "title": "第一个友链！🎉", 
             "content": "{link_blog_name} 已成为您的第一个友链！\n\n📌 友情链接的好处：\n• 提升博客SEO值\n• 增加网站访问流量\n• 结识志同道合的博友\n\n好好维护这份友谊吧！"},
            {"type": ActionType.SET_STORY_MILESTONE, "chapter": 1, "milestone": "first_friend_link"},
        ],
    },
    {
        "id": "first_ad_income",
        "description": "加入广告联盟并收到第一笔广告收益",
        "conditions": ["first_ad_income_not_done"],
        "is_repeatable": false,
        "trigger_type": "ad_income_paid",
        "actions": [
            {"type": ActionType.SHOW_POPUP_NOTIFICATION, 
             "title": "广告联盟第一笔收益", 
             "content": "恭喜您收到广告联盟的第一笔佣金 {income_amount} 元！\n\n🎉 这是博客商业化的重要一步！\n\n💡 如何提高广告收益：\n您的广告收入与访问量挂钩，访问量越高，点击率和佣金收益就越高。\n\n📊 收益加成参考：\n• 周访问量 ≤ 1000：基础收益\n• 周访问量 1000-3000：额外 +5%\n• 周访问量 3000-5000：额外 +10%\n• 周访问量 5000-10000：额外 +15%\n• 周访问量 > 10000：额外 +20% 以上\n\n建议：坚持创作优质内容，提升访问量！"},
            {"type": ActionType.SET_STORY_MILESTONE, "chapter": 1, "milestone": "first_income"},
        ],
    },
    {
        "id": "rss_enabled",
        "description": "开通RSS订阅：获得第一批订阅者",
        "conditions": ["rss_enabled_not_done"],
        "is_repeatable": false,
        "trigger_type": "rss_subscribe",
        "actions": [
            {"type": ActionType.SHOW_POPUP_NOTIFICATION, 
             "title": "第一批订阅者来了！", 
             "content": "🎉 恭喜您获得了第一批 RSS 订阅者！\n\n📖 RSS 订阅是什么？\nRSS（简易信息聚合）是一种让读者自动收到博客更新的服务。订阅后，您的文章会自动推送到读者的阅读器。\n\n📈 RSS 订阅有什么好处？\n• 稳定订阅者：订阅者可以定期收到您的文章更新\n• 增加访问量：每次更新都可能带来访问\n• 提高忠诚度：订阅用户更容易持续关注\n\n💡 如何获得更多订阅？\n访问量越高，主动订阅 RSS 的读者就越多。坚持创作优质内容是获得订阅的最佳方式！"},
            {"type": ActionType.SET_STORY_MILESTONE, "chapter": 1, "milestone": "rss_enabled"},
        ],
    },
    {
        "id": "first_article_favorited",
        "description": "第一次文章收藏：获得第一篇文章收藏",
        "conditions": ["first_article_favorited_not_done"],
        "is_repeatable": false,
        "trigger_type": "article_favorited",
        "actions": [
            {"type": ActionType.SHOW_POPUP_NOTIFICATION, 
             "title": "博客有文章被收藏了！🎉", 
             "content": "📌 文章收藏是什么？\n当读者觉得您的文章有价值时，会点击收藏按钮保存文章，方便日后再次阅读。\n\n📈 收藏有什么好处？\n• 增加访问量：收藏者会定期回访查看您的文章\n• 提升文章权重：收藏数多的文章更容易获得搜索引擎推荐\n• 增强用户粘性：收藏者更容易成为您的忠实读者\n\n💡 如何提高文章收藏量？\n• 创作优质内容：内容有价值，读者才愿意收藏\n• 保持更新频率：定期更新让读者期待\n• 写系列文章：完整的系列更容易被收藏\n• 标题吸引人：好标题能提高点击率和收藏率\n\n继续加油，您的博客越来越受欢迎了！"},
            {"type": ActionType.SET_STORY_MILESTONE, "chapter": 1, "milestone": "first_article_favorited"},
        ],
    },
    {
        "id": "icp_filing_notification",
        "description": "ICP备案通知：2002年管局要求个人网站备案",
        "conditions": ["time_icp_filing"],
        "is_repeatable": false,
        "trigger_type": "time_check",
        "actions": [
            {"type": ActionType.SHOW_POPUP_NOTIFICATION, 
             "title": "📋 ICP备案通知", 
             "content": "📢 重要通知：互联网安全整治行动\n\n根据国家互联网信息办公室的统一部署，各省市通信管理局开始对个人网站实施ICP备案制度。\n\n📌 备案要求：\n• 所有个人独立博客网站必须进行ICP备案\n• 未备案的网站将被强制关闭\n\n⚠️ 重要提醒：\n如果不完成备案，您的博客网站将被关闭，游戏将无法继续！\n\n💡 请在日常管理中尽快进行网站备案操作，备案只需进行一次。"},
            {"type": ActionType.UNLOCK_WEBSITE_MAINTENANCE, "task_name": "网站备案"},
        ],
    },
    {
        "id": "icp_filing_complete",
        "description": "ICP备案完成：获得备案号",
        "conditions": ["icp_filing_in_progress"],
        "is_repeatable": false,
        "trigger_type": "icp_filing_complete",
        "actions": [
            {"type": ActionType.SHOW_POPUP_NOTIFICATION, 
             "title": "✅ ICP备案成功！", 
             "content": "🎉 恭喜！您的博客网站ICP备案已通过审核！\n\n📋 备案号：ICP备88888888号\n\n📌 备案信息：\n• 个人博客网站已获得合法运营资质\n• 网站可以正常对外提供服务\n• 备案信息可在工信部网站查询\n\n💡 备案成功后，请妥善保管备案号，以备后续查验。"},
            {"type": ActionType.SET_ICP_FILING_NUMBER},
            {"type": ActionType.SET_STORY_MILESTONE, "chapter": 1, "milestone": "icp_filing_done"},
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
        "post_type_filter": "年度总结",
        "duration_days": true,
        "actions": [
            {"type": ActionType.SHOW_POPUP_NOTIFICATION, "template": "yearly_summary", "title": "🎉 {year}年度总结已发布！"},
            {"type": ActionType.LOCK_POST_TASK, "post_type": "年度总结"},
        ],
    },
    {
        "id": "chapter1_end_2005_review",
        "description": "2005年度总结发布，完成三年回顾，第一章结束",
        "conditions": ["year_summary_2005_posted"],
        "trigger_type": "post_event",
        "post_type_filter": "年度总结",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.SET_STORY_MILESTONE, "chapter": 1, "milestone": "year_summary_2005"},
            {"type": ActionType.SHOW_POPUP_NOTIFICATION, "title": "📖 三年回顾", "content": "从2001年冬夜那封邮件开始，你的博客已经走过了三年时光。\n\n是时候回头看看这段旅程了。", "follow_up_scene": "res://scenes/review/review.tscn", "review_from_year": 2003, "review_to_year": 2005, "review_title": "三年回顾"},
        ],
    },
    
    # ====================
    # 春节特辑任务（每年2月）
    # ====================
    {
        "id": "unlock_spring_festival",
        "description": "每年2月份春节特辑可以发布了！",
        "conditions": ["time_spring_festival_unlock"],
        "is_repeatable": true,
        "trigger_type": "time_check",
        "duration_days": true,
        "actions": [
            {"type": ActionType.UNLOCK_POST_TASK, "post_type": "春节特辑"},
        ],
    },
    {
        "id": "lock_spring_festival_by_time",
        "description": "春节特辑最佳发布时间已过，锁定。",
        "conditions": ["time_spring_festival_lock"],
        "is_repeatable": true,
        "trigger_type": "time_check",
        "duration_days": true,
        "actions": [
            {"type": ActionType.LOCK_POST_TASK, "post_type": "春节特辑"},
        ],
    },
    {
        "id": "lock_spring_festival_by_post",
        "description": "你已经发布了春节特辑，春节特辑博文类型发布已锁定。",
        "conditions": ["spring_festival_eq_6"],
        "is_repeatable": true,
        "trigger_type": "post_event",
        "duration_days": true,
        "actions": [
            {"type": ActionType.LOCK_POST_TASK, "post_type": "春节特辑"},
        ],
    },
    
    # ====================
    # 五一特辑任务（每年5月）
    # ====================
    {
        "id": "unlock_labor_day",
        "description": "每年5月份五一特辑可以发布了！",
        "conditions": ["time_labor_day_unlock"],
        "is_repeatable": true,
        "trigger_type": "time_check",
        "duration_days": true,
        "actions": [
            {"type": ActionType.UNLOCK_POST_TASK, "post_type": "五一特辑"},
        ],
    },
    {
        "id": "lock_labor_day_by_time",
        "description": "五一特辑最佳发布时间已过，锁定。",
        "conditions": ["time_labor_day_lock"],
        "is_repeatable": true,
        "trigger_type": "time_check",
        "duration_days": true,
        "actions": [
            {"type": ActionType.LOCK_POST_TASK, "post_type": "五一特辑"},
        ],
    },
    {
        "id": "lock_labor_day_by_post",
        "description": "你已经发布了五一特辑，五一特辑博文类型发布已锁定。",
        "conditions": ["labor_day_eq_3"],
        "is_repeatable": true,
        "trigger_type": "post_event",
        "duration_days": true,
        "actions": [
            {"type": ActionType.LOCK_POST_TASK, "post_type": "五一特辑"},
        ],
    },
    
    # ====================
    # 国庆特辑任务（每年10月）
    # ====================
    {
        "id": "unlock_national_day",
        "description": "每年10月份国庆特辑可以发布了！",
        "conditions": ["time_national_day_unlock"],
        "is_repeatable": true,
        "trigger_type": "time_check",
        "duration_days": true,
        "actions": [
            {"type": ActionType.UNLOCK_POST_TASK, "post_type": "国庆特辑"},
        ],
    },
    {
        "id": "lock_national_day_by_time",
        "description": "国庆特辑最佳发布时间已过，锁定。",
        "conditions": ["time_national_day_lock"],
        "is_repeatable": true,
        "trigger_type": "time_check",
        "duration_days": true,
        "actions": [
            {"type": ActionType.LOCK_POST_TASK, "post_type": "国庆特辑"},
        ],
    },
    {
        "id": "lock_national_day_by_post",
        "description": "你已经发布了国庆特辑，国庆特辑博文类型发布已锁定。",
        "conditions": ["national_day_eq_7"],
        "is_repeatable": true,
        "trigger_type": "post_event",
        "duration_days": true,
        "actions": [
            {"type": ActionType.LOCK_POST_TASK, "post_type": "国庆特辑"},
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

    # ====================
    # SEO收录任务（文章数量达到10时触发，且未被收录）
    # ====================
    {
        "id": "seo_indexed_notification",
        "description": "博客文章被搜索引擎收录，提醒玩家SEO的重要性",
        "conditions": ["article_count_ge_10", "sousuo_not_indexed"],
        "trigger_type": "post_event",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.SEO_NOTIFICATION},
            {"type": ActionType.SET_STORY_MILESTONE, "chapter": 1, "milestone": "sousuo_indexed"},
        ],
    },

    # ====================
    # 优秀博客大赛（2005年11月）
    # ====================
    {
        "id": "blog_competition_2005_notification",
        "description": "第一届优秀博客大赛通知",
        "conditions": ["time_blog_competition_2005"],
        "is_repeatable": false,
        "trigger_type": "time_check",
        "actions": [
            {"type": ActionType.SHOW_POPUP_NOTIFICATION,
             "title": "第一届优秀博客大赛开始",
             "content": "您好！\n\n第 1 届「中文优秀博客大奖」评选活动现已启动。\n\n您的博客已获得提名，请查看邮件了解详情。",
             "follow_up_scene": "res://优秀博客大奖赛/2005/ts2005tongzhi.tscn"},
        ],
    },

    # ====================
    # 优秀博客大赛评选（2005年11月）
    # ====================
    {
        "id": "blog_competition_2005_pingxuan",
        "description": "第一届优秀博客大赛评选",
        "conditions": ["time_blog_competition_2005_pingxuan"],
        "is_repeatable": false,
        "trigger_type": "time_check",
        "actions": [
            {"type": ActionType.SHOW_POPUP_NOTIFICATION,
             "title": "第一届优秀博客大赛评选开始",
             "content": "您好！\n\n第 1 届「中文优秀博客大奖」评选阶段现已开始。\n\n评审团正在对提名博客进行评议，请静候佳音。",
             "follow_up_scene": "res://优秀博客大奖赛/2005/ts2005pingxuan.tscn"},
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
