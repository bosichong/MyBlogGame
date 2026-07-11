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

    # 各章节年度总结条件（仅对应年份发布的年度总结）
    "year_summary_2010_posted": {"type": ConditionType.CUSTOM, "check_func": "check_year_summary_2010"},
    "year_summary_2015_posted": {"type": ConditionType.CUSTOM, "check_func": "check_year_summary_2015"},
    "year_summary_2020_posted": {"type": ConditionType.CUSTOM, "check_func": "check_year_summary_2020"},
    
    # 开源项目状态条件
    "open_source_project_started": {"type": ConditionType.CUSTOM, "check_func": "check_open_source_project"},
    
    # 时间条件（配合 event_date 使用）
    # 注意：游戏起始年份为 2001 年（可通过 TimeData.GAME_START_YEAR 获取）
    # 第一篇博文：游戏开始即可解锁（2001年12月第4周第7天，周日）
    "time_first_post_unlock": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [TimeData.GAME_START_YEAR], "m": [12], "w": [4], "d": [7]}},
    "time_year_summary_unlock": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [0], "m": [12], "w": [2], "d": [1]}},
    "time_year_summary_lock": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [0], "m": [12], "w": [4], "d": [7]}},
    "time_trend_change": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [0], "m": [1, 6], "w": [2], "d": [1]}},

    # 2005年末（12月第4周第7天）：防遗漏四年回顾触发
    "time_2005_end": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [2005], "m": [12], "w": [4], "d": [7]}},

    # 各章节年末防遗漏回顾触发时间
    "time_2010_end": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [2010], "m": [12], "w": [4], "d": [7]}},
    "time_2015_end": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [2015], "m": [12], "w": [4], "d": [7]}},
    "time_2020_end": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [2020], "m": [12], "w": [4], "d": [7]}},
    
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
    
    # 公众号开通时间（2012年1月第1周第1天）
    "time_wechat_open": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [2012], "m": [1], "w": [3], "d": [1]}},

    # 第一届优秀博客大赛通知（2005年11月第1周第1天）
    "time_blog_competition_2005": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [2005], "m": [11], "w": [1], "d": [1]}},
    
    # 第一届优秀博客大赛评选（2005年11月第2周第1天）
    "time_blog_competition_2005_pingxuan": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [2005], "m": [11], "w": [2], "d": [1]}},
    
    # 第一届优秀博客大赛揭晓（2005年12月第1周第5天）
    "time_blog_competition_2005_jiexiao": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [2005], "m": [12], "w": [1], "d": [5]}},
    
    # 第二届优秀博客大赛通知（2010年11月第1周第1天）
    "time_blog_competition_2010": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [2010], "m": [11], "w": [1], "d": [1]}},
    # 第二届优秀博客大赛评选（2010年11月第2周第1天）
    "time_blog_competition_2010_pingxuan": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [2010], "m": [11], "w": [2], "d": [1]}},
    # 第二届优秀博客大赛揭晓（2010年12月第1周第5天）
    "time_blog_competition_2010_jiexiao": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [2010], "m": [12], "w": [1], "d": [5]}},
    
    # 第三届优秀博客大赛通知（2015年11月第1周第1天）
    "time_blog_competition_2015": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [2015], "m": [11], "w": [1], "d": [1]}},
    # 第三届优秀博客大赛评选（2015年11月第2周第1天）
    "time_blog_competition_2015_pingxuan": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [2015], "m": [11], "w": [2], "d": [1]}},
    # 第三届优秀博客大赛揭晓（2015年12月第1周第5天）
    "time_blog_competition_2015_jiexiao": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [2015], "m": [12], "w": [1], "d": [5]}},
    
    # 第四届优秀博客大赛通知（2020年11月第1周第1天）
    "time_blog_competition_2020": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [2020], "m": [11], "w": [1], "d": [1]}},
    # 第四届优秀博客大赛评选（2020年11月第2周第1天）
    "time_blog_competition_2020_pingxuan": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [2020], "m": [11], "w": [2], "d": [1]}},
    # 第四届优秀博客大赛揭晓（2020年12月第1周第5天）
    "time_blog_competition_2020_jiexiao": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [2020], "m": [12], "w": [1], "d": [5]}},
    
    # 第五届优秀博客大赛通知（2025年11月第1周第1天）
    "time_blog_competition_2025": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [2025], "m": [11], "w": [1], "d": [1]}},
    # 第五届优秀博客大赛评选（2025年11月第2周第1天）
    "time_blog_competition_2025_pingxuan": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [2025], "m": [11], "w": [2], "d": [1]}},
    # 第五届优秀博客大赛揭晓（2025年12月第1周第5天）
    "time_blog_competition_2025_jiexiao": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [2025], "m": [12], "w": [1], "d": [5]}},
    
    # ICP备案进行中条件
    "icp_filing_in_progress": {"type": ConditionType.CUSTOM, "check_func": "check_icp_filing_in_progress"},
    
    # 移动端适配时间条件（2011年7月第1周第1天）
    "time_mobile_adapt": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [2011], "m": [7], "w": [1], "d": [1]}},
    
    # 移动端适配未完成
    "mobile_adapt_not_completed": {"type": ConditionType.MILESTONE_COMPLETED, "chapter": 3, "milestone": "mobile_adapted", "completed": false},
    
    # 移动端适配进行中
    "mobile_adapt_in_progress": {"type": ConditionType.CUSTOM, "check_func": "check_mobile_adapt_in_progress"},
    
    # HTTPS升级时间条件（2014年8月第1周第1天）
    "time_https_upgrade": {"type": ConditionType.TIME_MATCH, "event_date": {"y": [2014], "m": [8], "w": [1], "d": [1]}},
    
    # HTTPS升级未完成
    "https_upgrade_not_completed": {"type": ConditionType.MILESTONE_COMPLETED, "chapter": 3, "milestone": "https_upgraded", "completed": false},
    
    # HTTPS升级进行中
    "https_upgrade_in_progress": {"type": ConditionType.CUSTOM, "check_func": "check_https_upgrade_in_progress"},
    
    # ICP备案已完成（前置条件）
    "icp_filing_completed": {"type": ConditionType.MILESTONE_COMPLETED, "chapter": 1, "milestone": "icp_filing_done", "completed": true},
    
    # 广告联盟第一笔收益条件
    "first_ad_income_not_done": {"type": ConditionType.MILESTONE_COMPLETED, "chapter": 1, "milestone": "first_income", "completed": false},
    
    # RSS订阅条件
    "rss_enabled_not_done": {"type": ConditionType.MILESTONE_COMPLETED, "chapter": 1, "milestone": "rss_enabled", "completed": false},
    
    # 第一次文章收藏条件
    "first_article_favorited_not_done": {"type": ConditionType.MILESTONE_COMPLETED, "chapter": 1, "milestone": "first_article_favorited", "completed": false},

    # 2005四年回顾未完成（用于防遗漏任务）
    "year_summary_2005_not_completed": {"type": ConditionType.MILESTONE_COMPLETED, "chapter": 1, "milestone": "year_summary_2005", "completed": false},

    # 各章节回顾未完成（用于防遗漏任务）
    "year_summary_2010_not_completed": {"type": ConditionType.MILESTONE_COMPLETED, "chapter": 2, "milestone": "year_summary_2010", "completed": false},
    "year_summary_2015_not_completed": {"type": ConditionType.MILESTONE_COMPLETED, "chapter": 3, "milestone": "year_summary_2015", "completed": false},
    "year_summary_2020_not_completed": {"type": ConditionType.MILESTONE_COMPLETED, "chapter": 4, "milestone": "year_summary_2020", "completed": false},

    # 文学周刊里程碑未完成
    "literature_weekly_not_completed": {"type": ConditionType.MILESTONE_COMPLETED, "chapter": 2, "milestone": "literature_weekly", "completed": false},

    "code_weekly_not_completed": {"type": ConditionType.MILESTONE_COMPLETED, "chapter": 2, "milestone": "code_weekly", "completed": false},

    # RSS订阅里程碑未完成
    "rss_100_not_completed": {"type": ConditionType.MILESTONE_COMPLETED, "chapter": 2, "milestone": "rss_100", "completed": false},

    # RSS订阅达到100
    "rss_ge_100": {"type": ConditionType.CUSTOM, "check_func": "check_rss_ge_100"},

    # 累计收益里程碑未完成
    "income_1000_not_completed": {"type": ConditionType.MILESTONE_COMPLETED, "chapter": 2, "milestone": "income_1000", "completed": false},

    # 累计收益达到1000
    "income_ge_1000": {"type": ConditionType.CUSTOM, "check_func": "check_income_ge_1000"},

    # 第3章 爆款文章里程碑未完成
    "viral_article_not_completed": {"type": ConditionType.MILESTONE_COMPLETED, "chapter": 3, "milestone": "viral_article", "completed": false},

    # 第3章 高级教程里程碑未完成
    "advanced_tutorial_not_completed": {"type": ConditionType.MILESTONE_COMPLETED, "chapter": 3, "milestone": "advanced_tutorial", "completed": false},

    # 第3章 哲学批判里程碑未完成
    "philosophy_critique_not_completed": {"type": ConditionType.MILESTONE_COMPLETED, "chapter": 3, "milestone": "philosophy_critique", "completed": false},

    # 第3章 极客前沿里程碑未完成
    "geek_frontier_not_completed": {"type": ConditionType.MILESTONE_COMPLETED, "chapter": 3, "milestone": "geek_frontier", "completed": false},

    # 第3章 小说连载里程碑未完成
    "novel_first_post_not_completed": {"type": ConditionType.MILESTONE_COMPLETED, "chapter": 3, "milestone": "novel_first_post", "completed": false},

    # 公众号
    "wechat_not_opened": {"type": ConditionType.MILESTONE_COMPLETED, "chapter": 3, "milestone": "wechat_public", "completed": false},
    "followers_1000_not_completed": {"type": ConditionType.MILESTONE_COMPLETED, "chapter": 3, "milestone": "followers_1000", "completed": false},
    "followers_ge_1000": {"type": ConditionType.CUSTOM, "check_func": "check_followers_ge_1000"},
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
        "id": "literature_weekly_milestone",
        "description": "发布文学周刊，获得奖励并标记第二章里程碑",
        "conditions": ["literature_weekly_not_completed"],
        "trigger_type": "post_event",
        "post_type_filter": "文学周刊",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.SET_STORY_MILESTONE, "chapter": 2, "milestone": "literature_weekly"},
            {"type": ActionType.MODIFY_ATTRIBUTE, "attr_name": "writing", "value": 5},
            {"type": ActionType.SHOW_POPUP_NOTIFICATION, "title": "📰 文学周刊发布！", "content": "你伏案写下最新一期的文学周刊，字里行间藏着这几年的沉淀与思索。\n\n发布后读者的留言如潮水般涌来——有人说读你的文字像和老朋友聊天，有人说每周都在等着这一期。\n\n你意识到，写作的意义不只是记录，更是与这个世界温柔地连接。\n\n写作能力 +5 🎉"},
        ],
    },
    {
        "id": "literature_post_unlock_60",
        "description": "文学能力值达到60，解锁爆款网文、哲学批判文章类型",
        "conditions": ["literature_value_ge_60"],
        "trigger_type": "skill_up",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.UNLOCK_POST_TASK, "post_type": "爆款网文"},
            {"type": ActionType.UNLOCK_POST_TASK, "post_type": "哲学批判"},
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
        "id": "code_weekly_milestone",
        "description": "发布程序员周刊，获得奖励并标记第二章里程碑",
        "conditions": ["code_weekly_not_completed"],
        "trigger_type": "post_event",
        "post_type_filter": "程序员周刊",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.SET_STORY_MILESTONE, "chapter": 2, "milestone": "code_weekly"},
            {"type": ActionType.MODIFY_ATTRIBUTE, "attr_name": "technical", "value": 5},
            {"type": ActionType.SHOW_POPUP_NOTIFICATION, "title": "💻 程序员周刊发布！", "content": "你泡了杯咖啡，敲完最后一段代码示例，新一期程序员周刊终于定稿了。\n\n发布后技术社区反响热烈——有读者说你把复杂的概念讲得通透易懂，还有人专门转给了团队里的新人看。\n\n这一刻你感到，技术分享的意义不止于输出知识，更是点燃他人的好奇。\n\n技术能力 +5 🎉"},
        ],
    },
    {
        "id": "rss_100_milestone",
        "description": "RSS订阅突破百人，标记第二章里程碑",
        "conditions": ["rss_ge_100", "rss_100_not_completed"],
        "trigger_type": "time_check",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.SET_STORY_MILESTONE, "chapter": 2, "milestone": "rss_100"},
            {"type": ActionType.SHOW_POPUP_NOTIFICATION, "title": "📨 RSS 订阅突破 100 人！", "content": "打开后台，你发现 RSS 订阅数悄然突破了 100。\n\n从第一个订阅者小心翼翼按下按钮，到今天满百——每一个数字背后都是一个真实的读者，他们在阅读器里等待你的每一次更新。\n\n这份信任，比任何数据都更温暖。\n\n继续写下去吧，有人在读。\n\n🎉"},
        ],
    },
    {
        "id": "income_1000_milestone",
        "description": "累计收益突破千元，标记第二章里程碑",
        "conditions": ["income_ge_1000", "income_1000_not_completed"],
        "trigger_type": "time_check",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.SET_STORY_MILESTONE, "chapter": 2, "milestone": "income_1000"},
            {"type": ActionType.SHOW_POPUP_NOTIFICATION, "title": "💰 累计收益突破千元！", "content": "你查看了后台的收益统计，累计广告收入已经突破 1000 元。\n\n从最初一个月几块钱的零碎收入，到如今稳定进账——每一分钱都是读者用注意力投下的信任票。\n\n虽然离财务自由还差得远，但对一个独立博客来说，这是值得纪念的一小步。\n\n继续坚持下去，路还长。\n\n🎉"},
        ],
    },
    # ====================
    # 第3章里程碑：爆款文章
    # ====================
    {
        "id": "viral_article_milestone",
        "description": "发布爆款网文，标记第3章里程碑",
        "conditions": ["viral_article_not_completed"],
        "trigger_type": "post_event",
        "post_type_filter": "爆款网文",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.SET_STORY_MILESTONE, "chapter": 3, "milestone": "viral_article"},
            {"type": ActionType.SHOW_POPUP_NOTIFICATION, "title": "🔥 爆款文章诞生！", "content": "你刷新后台数据，发现访问量在飙升——评论区炸了，各路读者争相转发讨论。\n\n这篇文章击中了时代的情绪，引发了广泛的共鸣。你意识到，好的内容真的可以跨越圈层，触达那些素未谋面的人。\n\n这一刻，你真正体会到了文字的力量。\n\n🎉"},
        ],
    },
    # ====================
    # 第3章里程碑：高级教程
    # ====================
    {
        "id": "advanced_tutorial_milestone",
        "description": "发布深度技术文章，标记第3章里程碑",
        "conditions": ["advanced_tutorial_not_completed"],
        "trigger_type": "post_event",
        "post_type_filter": "深度技术",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.SET_STORY_MILESTONE, "chapter": 3, "milestone": "advanced_tutorial"},
            {"type": ActionType.SHOW_POPUP_NOTIFICATION, "title": "📘 高级教程发布！", "content": "你花了大量时间打磨这篇深度技术文章，从原理到实践，层层递进。\n\n发布后收到了不少资深开发者的好评——有人说终于有人把这个讲透了，还有人私信向你请教细节。\n\n技术分享的快乐，莫过于此。\n\n🎉"},
        ],
    },
    # ====================
    # 第3章里程碑：哲学批判
    # ====================
    {
        "id": "philosophy_critique_milestone",
        "description": "发布哲学批判文章，标记第3章里程碑",
        "conditions": ["philosophy_critique_not_completed"],
        "trigger_type": "post_event",
        "post_type_filter": "哲学批判",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.SET_STORY_MILESTONE, "chapter": 3, "milestone": "philosophy_critique"},
            {"type": ActionType.SHOW_POPUP_NOTIFICATION, "title": "🤔 哲学批判发布！", "content": "你写下了一篇哲学批判，用思辨的笔触审视技术与时代的关系。\n\n文章发出后引发了深度讨论——有人在评论区展开了激烈的辩论，有人表示读了你的分析后重新审视了自己的技术观。\n\n不只是写代码，不只是写文字，你在用思考连接这个世界。\n\n🎉"},
        ],
    },
    # ====================
    # 第3章里程碑：极客前沿
    # ====================
    {
        "id": "geek_frontier_milestone",
        "description": "发布极客前沿文章，标记第3章里程碑",
        "conditions": ["geek_frontier_not_completed"],
        "trigger_type": "post_event",
        "post_type_filter": "极客前沿",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.SET_STORY_MILESTONE, "chapter": 3, "milestone": "geek_frontier"},
            {"type": ActionType.SHOW_POPUP_NOTIFICATION, "title": "🚀 极客前沿发布！", "content": "你搜罗了国内外最新的技术动态，整理成一篇干货满满的极客前沿。\n\n发布后被疯狂转发——有人说这是本周读过最有价值的文章，有人收藏了慢慢消化。\n\n保持对前沿技术的敏锐，是一个技术人最宝贵的习惯。\n\n🎉"},
        ],
    },
    # ====================
    # 第3章里程碑：第一篇小说连载
    # ====================
    {
        "id": "novel_first_post_milestone",
        "description": "发布第一篇小说连载，标记第三章里程碑",
        "conditions": ["novel_first_post_not_completed"],
        "trigger_type": "post_event",
        "post_type_filter": "小说连载(付费)",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.SET_STORY_MILESTONE, "chapter": 3, "milestone": "novel_first_post"},
            {"type": ActionType.SHOW_POPUP_NOTIFICATION, "title": "✍️ 第一篇小说连载发布！",
             "content": "你深吸一口气，敲下了小说的第一个段落。\n\n从博客短文到长篇创作，这一步迈得不容易。但当你看到第一章发布后读者们迫不及待地点下「订阅」按钮时，你知道——\n\n故事一旦开始，就有人愿意陪你走到最后。\n\n这是你创作生涯的一个新起点。\n\n🎉 恭喜开启小说连载之路！"},
        ],
    },
    {
        "id": "code_post_unlock_60",
        "description": "编程能力值达到60，解锁极客前沿、深度技术文章类型",
        "conditions": ["code_value_ge_60"],
        "trigger_type": "skill_up",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.UNLOCK_POST_TASK, "post_type": "极客前沿"},
            {"type": ActionType.UNLOCK_POST_TASK, "post_type": "深度技术"},
        ],
    },
    {
        "id": "code_post_unlock_80",
        "description": "编程能力值达到80，解锁黑客攻防(付费)文章类型",
        "conditions": ["code_value_ge_80"],
        "trigger_type": "skill_up",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.UNLOCK_POST_TASK, "post_type": "黑客攻防(付费)"},
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
        "description": "2005年度总结发布，完成四年回顾，第一章结束",
        "conditions": ["year_summary_2005_posted"],
        "trigger_type": "post_event",
        "post_type_filter": "年度总结",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.SET_STORY_MILESTONE, "chapter": 1, "milestone": "year_summary_2005"},
            {"type": ActionType.SHOW_POPUP_NOTIFICATION, "title": "📖 四年回顾", "content": "从博客上线到现在，眨眼间已经走过了四个年头。\n\n是时候回头看看这段旅程了。", "follow_up_scene": "res://scenes/review/review.tscn", "review_from_year": 2002, "review_to_year": 2005, "review_title": "四年回顾"},
        ],
    },

    # ====================
    # 2005年末四年回顾防遗漏（时间触发）
    # ====================
    {
        "id": "chapter1_end_2005_review_fallback",
        "description": "2005年末自动触发四年回顾（防遗漏）",
        "conditions": ["time_2005_end", "year_summary_2005_not_completed"],
        "trigger_type": "time_check",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.SET_STORY_MILESTONE, "chapter": 1, "milestone": "year_summary_2005"},
            {"type": ActionType.SHOW_POPUP_NOTIFICATION, "title": "📖 四年回顾", "content": "忙碌了一年，是时候回头看看这四年的博客旅程了。\n\n虽然错过了发布年度总结博文，但回顾依然值得。", "follow_up_scene": "res://scenes/review/review.tscn", "review_from_year": 2002, "review_to_year": 2005, "review_title": "四年回顾"},
        ],
    },

    # ====================
    # 2010年五年回顾（年度总结发布触发）
    # ====================
    {
        "id": "chapter2_end_2010_review",
        "description": "2010年度总结发布，完成五年回顾，第二章结束",
        "conditions": ["year_summary_2010_posted"],
        "trigger_type": "post_event",
        "post_type_filter": "年度总结",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.SET_STORY_MILESTONE, "chapter": 2, "milestone": "year_summary_2010"},
            {"type": ActionType.SHOW_POPUP_NOTIFICATION, "title": "📖 五年回顾", "content": "从2006年到2010年，这五年你的博客在成长。\n\n是时候回头看看这段旅程了。", "follow_up_scene": "res://scenes/review/review.tscn", "review_chapter": 2, "review_from_year": 2006, "review_to_year": 2010, "review_title": "五年回顾"},
        ],
    },

    # ====================
    # 2010年末五年回顾防遗漏（时间触发）
    # ====================
    {
        "id": "chapter2_end_2010_review_fallback",
        "description": "2010年末自动触发五年回顾（防遗漏）",
        "conditions": ["time_2010_end", "year_summary_2010_not_completed"],
        "trigger_type": "time_check",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.SET_STORY_MILESTONE, "chapter": 2, "milestone": "year_summary_2010"},
            {"type": ActionType.SHOW_POPUP_NOTIFICATION, "title": "📖 五年回顾", "content": "忙碌了一年，是时候回头看看这五年的博客旅程了。\n\n虽然错过了发布年度总结博文，但回顾依然值得。", "follow_up_scene": "res://scenes/review/review.tscn", "review_chapter": 2, "review_from_year": 2006, "review_to_year": 2010, "review_title": "五年回顾"},
        ],
    },

    # ====================
    # 2015年五年回顾（年度总结发布触发）
    # ====================
    {
        "id": "chapter3_end_2015_review",
        "description": "2015年度总结发布，完成五年回顾，第三章结束",
        "conditions": ["year_summary_2015_posted"],
        "trigger_type": "post_event",
        "post_type_filter": "年度总结",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.SET_STORY_MILESTONE, "chapter": 3, "milestone": "year_summary_2015"},
            {"type": ActionType.SHOW_POPUP_NOTIFICATION, "title": "📖 五年回顾", "content": "从2011年到2015年，这五年你的博客经历了许多转变。\n\n是时候回头看看这段旅程了。", "follow_up_scene": "res://scenes/review/review.tscn", "review_chapter": 3, "review_from_year": 2011, "review_to_year": 2015, "review_title": "五年回顾"},
        ],
    },

    # ====================
    # 2015年末五年回顾防遗漏（时间触发）
    # ====================
    {
        "id": "chapter3_end_2015_review_fallback",
        "description": "2015年末自动触发五年回顾（防遗漏）",
        "conditions": ["time_2015_end", "year_summary_2015_not_completed"],
        "trigger_type": "time_check",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.SET_STORY_MILESTONE, "chapter": 3, "milestone": "year_summary_2015"},
            {"type": ActionType.SHOW_POPUP_NOTIFICATION, "title": "📖 五年回顾", "content": "忙碌了一年，是时候回头看看这五年的博客旅程了。\n\n虽然错过了发布年度总结博文，但回顾依然值得。", "follow_up_scene": "res://scenes/review/review.tscn", "review_chapter": 3, "review_from_year": 2011, "review_to_year": 2015, "review_title": "五年回顾"},
        ],
    },

    # ====================
    # 2020年五年回顾（年度总结发布触发）
    # ====================
    {
        "id": "chapter4_end_2020_review",
        "description": "2020年度总结发布，完成五年回顾，第四章结束",
        "conditions": ["year_summary_2020_posted"],
        "trigger_type": "post_event",
        "post_type_filter": "年度总结",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.SET_STORY_MILESTONE, "chapter": 4, "milestone": "year_summary_2020"},
            {"type": ActionType.SHOW_POPUP_NOTIFICATION, "title": "📖 五年回顾", "content": "从2016年到2020年，这五年你的博客面临了许多挑战。\n\n是时候回头看看这段旅程了。", "follow_up_scene": "res://scenes/review/review.tscn", "review_chapter": 4, "review_from_year": 2016, "review_to_year": 2020, "review_title": "五年回顾"},
        ],
    },

    # ====================
    # 2020年末五年回顾防遗漏（时间触发）
    # ====================
    {
        "id": "chapter4_end_2020_review_fallback",
        "description": "2020年末自动触发五年回顾（防遗漏）",
        "conditions": ["time_2020_end", "year_summary_2020_not_completed"],
        "trigger_type": "time_check",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.SET_STORY_MILESTONE, "chapter": 4, "milestone": "year_summary_2020"},
            {"type": ActionType.SHOW_POPUP_NOTIFICATION, "title": "📖 五年回顾", "content": "忙碌了一年，是时候回头看看这五年的博客旅程了。\n\n虽然错过了发布年度总结博文，但回顾依然值得。", "follow_up_scene": "res://scenes/review/review.tscn", "review_chapter": 4, "review_from_year": 2016, "review_to_year": 2020, "review_title": "五年回顾"},
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
             "content": "您好！\n\n第 1 届「中文优秀博客大奖」评选活动现已启动。\n\n本届评选面向全体中文独立博客，请查看邮件了解详情。",
             "follow_up_scene": "res://优秀博客大奖赛/tongzhi.tscn",
             "notification_ordinal": 1},
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
             "content": "您好！\n\n第 1 届「中文优秀博客大奖」评选阶段现已开始。\n\n评审团正在对参赛博客进行综合评议，结果将于 12 月揭晓。",
             "follow_up_scene": "res://优秀博客大奖赛/pingxuan.tscn",
             "notification_ordinal": 1},
        ],
    },

    # ====================
    # 优秀博客大赛揭晓（2005年12月）
    # ====================
    {
        "id": "blog_competition_2005_jiexiao",
        "description": "第一届优秀博客大赛结果揭晓",
        "conditions": ["time_blog_competition_2005_jiexiao"],
        "is_repeatable": false,
        "trigger_type": "time_check",
        "actions": [
            {"type": ActionType.SHOW_POPUP_NOTIFICATION,
             "title": "第一届优秀博客大赛结果揭晓",
             "content": "您好！\n\n第 1 届「中文优秀博客大奖」结果已公布。\n\n请查看获奖详情。",
             "follow_up_scene": "res://优秀博客大奖赛/jiexiao_dispatch.tscn",
             "notification_ordinal": 1},
        ],
    },

    # ====================
    # 优秀博客大赛（2010年）
    # ====================
    {
        "id": "blog_competition_2010_notification",
        "description": "第二届优秀博客大赛通知",
        "conditions": ["time_blog_competition_2010"],
        "is_repeatable": false,
        "trigger_type": "time_check",
        "actions": [
             {"type": ActionType.SHOW_POPUP_NOTIFICATION,
             "title": "第二届优秀博客大赛开始",
             "content": "您好！\n\n第 2 届「中文优秀博客大奖」评选活动现已启动。\n\n本届评选面向全体中文独立博客，请查看邮件了解详情。",
             "follow_up_scene": "res://优秀博客大奖赛/tongzhi.tscn",
             "notification_ordinal": 2},
        ],
    },
    {
        "id": "blog_competition_2010_pingxuan",
        "description": "第二届优秀博客大赛评选",
        "conditions": ["time_blog_competition_2010_pingxuan"],
        "is_repeatable": false,
        "trigger_type": "time_check",
        "actions": [
             {"type": ActionType.SHOW_POPUP_NOTIFICATION,
             "title": "第二届优秀博客大赛评选开始",
             "content": "您好！\n\n第 2 届「中文优秀博客大奖」评选阶段现已开始。\n\n评审团正在对参赛博客进行综合评议，结果将于 12 月揭晓。",
             "follow_up_scene": "res://优秀博客大奖赛/pingxuan.tscn",
             "notification_ordinal": 2},
        ],
    },
    {
        "id": "blog_competition_2010_jiexiao",
        "description": "第二届优秀博客大赛结果揭晓",
        "conditions": ["time_blog_competition_2010_jiexiao"],
        "is_repeatable": false,
        "trigger_type": "time_check",
        "actions": [
            {"type": ActionType.SHOW_POPUP_NOTIFICATION,
             "title": "第二届优秀博客大赛结果揭晓",
             "content": "您好！\n\n第 2 届「中文优秀博客大奖」结果已公布。\n\n请查看获奖详情。",
             "follow_up_scene": "res://优秀博客大奖赛/jiexiao_dispatch.tscn",
             "notification_ordinal": 2},
        ],
    },

    # ====================
    # 优秀博客大赛（2015年）
    # ====================
    {
        "id": "blog_competition_2015_notification",
        "description": "第三届优秀博客大赛通知",
        "conditions": ["time_blog_competition_2015"],
        "is_repeatable": false,
        "trigger_type": "time_check",
        "actions": [
             {"type": ActionType.SHOW_POPUP_NOTIFICATION,
             "title": "第三届优秀博客大赛开始",
             "content": "您好！\n\n第 3 届「中文优秀博客大奖」评选活动现已启动。\n\n本届评选面向全体中文独立博客，请查看邮件了解详情。",
             "follow_up_scene": "res://优秀博客大奖赛/tongzhi.tscn",
             "notification_ordinal": 3},
        ],
    },
    {
        "id": "blog_competition_2015_pingxuan",
        "description": "第三届优秀博客大赛评选",
        "conditions": ["time_blog_competition_2015_pingxuan"],
        "is_repeatable": false,
        "trigger_type": "time_check",
        "actions": [
             {"type": ActionType.SHOW_POPUP_NOTIFICATION,
             "title": "第三届优秀博客大赛评选开始",
             "content": "您好！\n\n第 3 届「中文优秀博客大奖」评选阶段现已开始。\n\n评审团正在对参赛博客进行综合评议，结果将于 12 月揭晓。",
             "follow_up_scene": "res://优秀博客大奖赛/pingxuan.tscn",
             "notification_ordinal": 3},
        ],
    },
    {
        "id": "blog_competition_2015_jiexiao",
        "description": "第三届优秀博客大赛结果揭晓",
        "conditions": ["time_blog_competition_2015_jiexiao"],
        "is_repeatable": false,
        "trigger_type": "time_check",
        "actions": [
            {"type": ActionType.SHOW_POPUP_NOTIFICATION,
             "title": "第三届优秀博客大赛结果揭晓",
             "content": "您好！\n\n第 3 届「中文优秀博客大奖」结果已公布。\n\n请查看获奖详情。",
             "follow_up_scene": "res://优秀博客大奖赛/jiexiao_dispatch.tscn",
             "notification_ordinal": 3},
        ],
    },

    # ====================
    # 优秀博客大赛（2020年）
    # ====================
    {
        "id": "blog_competition_2020_notification",
        "description": "第四届优秀博客大赛通知",
        "conditions": ["time_blog_competition_2020"],
        "is_repeatable": false,
        "trigger_type": "time_check",
        "actions": [
             {"type": ActionType.SHOW_POPUP_NOTIFICATION,
             "title": "第四届优秀博客大赛开始",
             "content": "您好！\n\n第 4 届「中文优秀博客大奖」评选活动现已启动。\n\n本届评选面向全体中文独立博客，请查看邮件了解详情。",
             "follow_up_scene": "res://优秀博客大奖赛/tongzhi.tscn",
             "notification_ordinal": 4},
        ],
    },
    {
        "id": "blog_competition_2020_pingxuan",
        "description": "第四届优秀博客大赛评选",
        "conditions": ["time_blog_competition_2020_pingxuan"],
        "is_repeatable": false,
        "trigger_type": "time_check",
        "actions": [
             {"type": ActionType.SHOW_POPUP_NOTIFICATION,
             "title": "第四届优秀博客大赛评选开始",
             "content": "您好！\n\n第 4 届「中文优秀博客大奖」评选阶段现已开始。\n\n评审团正在对参赛博客进行综合评议，结果将于 12 月揭晓。",
             "follow_up_scene": "res://优秀博客大奖赛/pingxuan.tscn",
             "notification_ordinal": 4},
        ],
    },
    {
        "id": "blog_competition_2020_jiexiao",
        "description": "第四届优秀博客大赛结果揭晓",
        "conditions": ["time_blog_competition_2020_jiexiao"],
        "is_repeatable": false,
        "trigger_type": "time_check",
        "actions": [
            {"type": ActionType.SHOW_POPUP_NOTIFICATION,
             "title": "第四届优秀博客大赛结果揭晓",
             "content": "您好！\n\n第 4 届「中文优秀博客大奖」结果已公布。\n\n请查看获奖详情。",
             "follow_up_scene": "res://优秀博客大奖赛/jiexiao_dispatch.tscn",
             "notification_ordinal": 4},
        ],
    },

    # ====================
    # 优秀博客大赛（2025年）
    # ====================
    {
        "id": "blog_competition_2025_notification",
        "description": "第五届优秀博客大赛通知",
        "conditions": ["time_blog_competition_2025"],
        "is_repeatable": false,
        "trigger_type": "time_check",
        "actions": [
             {"type": ActionType.SHOW_POPUP_NOTIFICATION,
             "title": "第五届优秀博客大赛开始",
             "content": "您好！\n\n第 5 届「中文优秀博客大奖」评选活动现已启动。\n\n本届评选面向全体中文独立博客，请查看邮件了解详情。",
             "follow_up_scene": "res://优秀博客大奖赛/tongzhi.tscn",
             "notification_ordinal": 5},
        ],
    },
    {
        "id": "blog_competition_2025_pingxuan",
        "description": "第五届优秀博客大赛评选",
        "conditions": ["time_blog_competition_2025_pingxuan"],
        "is_repeatable": false,
        "trigger_type": "time_check",
        "actions": [
             {"type": ActionType.SHOW_POPUP_NOTIFICATION,
             "title": "第五届优秀博客大赛评选开始",
             "content": "您好！\n\n第 5 届「中文优秀博客大奖」评选阶段现已开始。\n\n评审团正在对参赛博客进行综合评议，结果将于 12 月揭晓。",
             "follow_up_scene": "res://优秀博客大奖赛/pingxuan.tscn",
             "notification_ordinal": 5},
        ],
    },
    {
        "id": "blog_competition_2025_jiexiao",
        "description": "第五届优秀博客大赛结果揭晓",
        "conditions": ["time_blog_competition_2025_jiexiao"],
        "is_repeatable": false,
        "trigger_type": "time_check",
        "actions": [
            {"type": ActionType.SHOW_POPUP_NOTIFICATION,
             "title": "第五届优秀博客大赛结果揭晓",
             "content": "您好！\n\n第 5 届「中文优秀博客大奖」结果已公布。\n\n请查看获奖详情。",
             "follow_up_scene": "res://优秀博客大奖赛/jiexiao_dispatch.tscn",
             "notification_ordinal": 5},
        ],
    },
    # ====================
    # 公众号
    # ====================
    {
        "id": "followers_1000_milestone",
        "description": "公众号粉丝突破1000，标记第三章里程碑",
        "conditions": ["followers_ge_1000", "followers_1000_not_completed"],
        "trigger_type": "time_check",
        "is_repeatable": false,
        "actions": [
            {"type": ActionType.SET_STORY_MILESTONE, "chapter": 3, "milestone": "followers_1000"},
            {"type": ActionType.SHOW_POPUP_NOTIFICATION,
             "title": "🎉 公众号粉丝突破1000！",
             "content": "在你的坚持更新下，公众号粉丝终于突破了 1000 人大关！\n\n这是一个重要的分水岭——现在你有资格开启流量主收入模式了。以后每月阅读量将为你带来广告分成收入。\n\n虽然比不上博客广告，但这也是对坚持的一种回报。继续加油！"},
        ],
    },
    {
        "id": "wechat_open",
        "description": "公众号开通：2012年公众号平台上线，开通属于你的公众号",
        "conditions": ["time_wechat_open", "wechat_not_opened"],
        "is_repeatable": false,
        "trigger_type": "time_check",
        "actions": [
            {"type": ActionType.SHOW_POPUP_NOTIFICATION,
             "title": "📱 公众号平台上线了！",
             "content": "2012年，公众号平台正式上线。\n\n这是一个全新的内容阵地——和独立博客不同，公众号是一个封闭的生态系统，读者通过订阅获取内容。\n\n要不要开通一个公众号试试？\"运营公众号\"已经添加到日程中的网站维护里了。\n\n（提示：公众号涨粉慢、收入低，需要投入大量体力，请谨慎分配精力。）"},
            {"type": ActionType.UNLOCK_WEBSITE_MAINTENANCE, "task_name": "运营公众号"},
            {"type": ActionType.SET_STORY_MILESTONE, "chapter": 3, "milestone": "wechat_public"},
        ],
    },
    # ====================
    # 移动端适配
    # ====================
    {
        "id": "mobile_adapt_notification",
        "description": "移动端适配通知：2011年智能手机浪潮来袭，博客需要适配移动端",
        "conditions": ["time_mobile_adapt", "mobile_adapt_not_completed"],
        "is_repeatable": false,
        "trigger_type": "time_check",
        "actions": [
            {"type": ActionType.SHOW_POPUP_NOTIFICATION,
             "title": "📱 移动互联网时代来了！",
             "content": "2011年，智能手机开始普及，越来越多的人用手机浏览网页。\n\n你发现博客在手机上的显示效果惨不忍睹——文字太小、排版错乱、图片溢出。\n\n再不进行移动端适配，读者体验会越来越差。\n\n💡 \"移动端适配\"已经添加到日程的网站维护中，完成适配大约需要7天。"},
            {"type": ActionType.UNLOCK_WEBSITE_MAINTENANCE, "task_name": "移动端适配"},
        ],
    },
    {
        "id": "mobile_adapt_complete",
        "description": "移动端适配完成：博客完美适配移动端",
        "conditions": ["mobile_adapt_in_progress"],
        "is_repeatable": false,
        "trigger_type": "mobile_adapt_complete",
        "actions": [
            {"type": ActionType.SHOW_POPUP_NOTIFICATION,
             "title": "✅ 移动端适配完成！",
             "content": "🎉 经过几天的开发调试，你的博客终于完美适配了移动端！\n\n📱 现在无论读者使用手机、平板还是电脑访问，都能获得良好的阅读体验。\n\n移动流量的占比开始逐年提升，这次适配为博客的未来发展打下了坚实基础。"},
            {"type": ActionType.SET_STORY_MILESTONE, "chapter": 3, "milestone": "mobile_adapted"},
        ],
    },
    # ====================
    # HTTPS升级
    # ====================
    {
        "id": "https_upgrade_notification",
        "description": "HTTPS升级通知：2014年Google宣布HTTPS为排名信号",
        "conditions": ["time_https_upgrade", "https_upgrade_not_completed"],
        "is_repeatable": false,
        "trigger_type": "time_check",
        "actions": [
            {"type": ActionType.SHOW_POPUP_NOTIFICATION,
             "title": "🔒 HTTPS时代来了！",
             "content": "2014年，Google正式宣布将HTTPS作为搜索排名信号。\n\n这意味着——没有HTTPS的网站在搜索结果中会逐渐处于劣势。你的读者也开始更在意地址栏上那个\"安全锁\"图标。\n\n💡 是时候升级HTTPS了！这需要购买SSL证书（80元），配置完成后大约需要5天生效。"},
            {"type": ActionType.UNLOCK_WEBSITE_MAINTENANCE, "task_name": "HTTPS升级"},
        ],
    },
    {
        "id": "https_upgrade_complete",
        "description": "HTTPS升级完成：博客全站支持HTTPS安全访问",
        "conditions": ["https_upgrade_in_progress"],
        "is_repeatable": false,
        "trigger_type": "https_upgrade_complete",
        "actions": [
            {"type": ActionType.SHOW_POPUP_NOTIFICATION,
             "title": "✅ HTTPS升级完成！",
             "content": "🎉 你的博客已成功升级到HTTPS！\n\n🔒 现在所有访问都经过SSL加密，读者可以看到地址栏上的安全锁图标。\n\n📈 HTTPS不仅能提升读者信任感，还能让博客在搜索引擎中获得更好的排名。在互联网安全日益重要的今天，这一步走得非常及时。"},
            {"type": ActionType.SET_STORY_MILESTONE, "chapter": 3, "milestone": "https_upgraded"},
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
