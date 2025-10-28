# TaskConfig.gd
# 任务配置文件，使用数组+字典组合定义所有任务

# 任务类型枚举
enum TaskType {
    SKILL_BASED,   #基于DRAW技能属性值的任务
    TIME_BASED,    # 基于时间的任务
    LV_BASED,      #基于任务等级的任务
    NEW_BLOG_POST, # 基于博文发布的类型任务
    ATTRIBUTE_BASED,  # 基于属性的任务
    CONDITION_BASED,   # 基于复合条件的任务
    CUSTOM_TYPE #自定义条件
}

# 任务动作类型枚举
enum ActionType {
    SKILL_LEVEL_UNLOCK,    # 技能技能解锁
    SKILL_LEVEL_LOCK,     # 技能锁定
    UNLOCK_POST_TASK,  # 解锁可以发布类型博文的任务
    UNLOCK_MILESTONES_TASK,  # 解锁lv成就
    LOCK_POST_TASK,    # 锁定可以发布类型博文的任务
    HIDE_POST_TASK,    # 锁定可以发布类型博文的任务
    REPLACE_POST_TREND,# 更换博文热点属性
    MODIFY_ATTRIBUTE,  # 修改属性
    CHANGE_SCENE,      # 切换场景
    SHOW_NOTIFICATION, # 显示通知
    CUSTOM_ACTION      # 自定义动作
}

# 所有任务定义
const TASKS = [
    
    ####################
    # 技能学习任务
    ####################
    
{
        "id": "literature_level_25",
        "type": TaskType.SKILL_BASED,
        "description": "能力达到25级，解锁下一级技能学习，隐藏锁定上一级技能学习。",
        "is_active": true, #是否激活
        "is_repeatable": false, #是否可重复的任务 false 不可重复
        "is_in_progress": false,  # 任务是否进行中
        "duration_days":false,#是否是长期任务
        "is_completed": false, #是否已完成
        #"times":1,#事件次数
        #"post_times":1,#年度总结发布次数。
        "level":25,
        "skill_type": Blogger.Skills.LITERATURE,
        "actions": [
            {
                "type": ActionType.SKILL_LEVEL_LOCK,
                "skill_name": "阅读名著",
            },
            {
                "type": ActionType.SKILL_LEVEL_UNLOCK,
                "skill_name":"写作基础理论",
            },
        ],
    },
    
    {
        "id": "literature_level_50",
        "type": TaskType.SKILL_BASED,
        "description": "能力达到25级，解锁下一级技能学习，隐藏锁定上一级技能学习。",
        "is_active": true, #是否激活
        "is_repeatable": false, #是否可重复的任务 false 不可重复
        "is_in_progress": false,  # 任务是否进行中
        "duration_days":false,#是否是长期任务
        "is_completed": false, #是否已完成
        #"times":1,#事件次数
        #"post_times":1,#年度总结发布次数。
        "level":50,
        "skill_type": Blogger.Skills.LITERATURE,
        "actions": [
            {
                "type": ActionType.SKILL_LEVEL_LOCK,
                "skill_name": "写作基础理论",
            },
            {
                "type": ActionType.SKILL_LEVEL_UNLOCK,
                "skill_name":"高级文学",
            },
        ],
    },
    
    {
        "id": "literature_level_75",
        "type": TaskType.SKILL_BASED,
        "description": "能力达到25级，解锁下一级技能学习，隐藏锁定上一级技能学习。",
        "is_active": true, #是否激活
        "is_repeatable": false, #是否可重复的任务 false 不可重复
        "is_in_progress": false,  # 任务是否进行中
        "duration_days":false,#是否是长期任务
        "is_completed": false, #是否已完成
        #"times":1,#事件次数
        #"post_times":1,#年度总结发布次数。
        "level":75,
        "skill_type": Blogger.Skills.LITERATURE,
        "actions": [
            {
                "type": ActionType.SKILL_LEVEL_LOCK,
                "skill_name": "高级文学",
            },
            {
                "type": ActionType.SKILL_LEVEL_UNLOCK,
                "skill_name":"小说家",
            },
        ],
    },
    
    {
        "id": "literature_level_100",
        "type": TaskType.SKILL_BASED,
        "description": "能力达到25级，解锁下一级技能学习，隐藏锁定上一级技能学习。",
        "is_active": true, #是否激活
        "is_repeatable": false, #是否可重复的任务 false 不可重复
        "is_in_progress": false,  # 任务是否进行中
        "duration_days":false,#是否是长期任务
        "is_completed": false, #是否已完成
        #"times":1,#事件次数
        #"post_times":1,#年度总结发布次数。
        "level":100,
        "skill_type": Blogger.Skills.LITERATURE,
        "actions": [
            {
                "type": ActionType.SKILL_LEVEL_LOCK,
                "skill_name": "小说家",
            },
            #{
                #"type": ActionType.SKILL_LEVEL_UNLOCK,
                #"skill_name":"成为黑客",
            #},
        ],
    },
    

    
    
    
{
        "id": "code_level_25",
        "type": TaskType.SKILL_BASED,
        "description": "能力达到25级，解锁下一级技能学习，隐藏锁定上一级技能学习。",
        "is_active": true, #是否激活
        "is_repeatable": false, #是否可重复的任务 false 不可重复
        "is_in_progress": false,  # 任务是否进行中
        "duration_days":false,#是否是长期任务
        "is_completed": false, #是否已完成
        #"times":1,#事件次数
        #"post_times":1,#年度总结发布次数。
        "level":25,
        "skill_type": Blogger.Skills.CODE,
        "actions": [
            {
                "type": ActionType.SKILL_LEVEL_LOCK,
                "skill_name": "自学编程",
            },
            {
                "type": ActionType.SKILL_LEVEL_UNLOCK,
                "skill_name":"学习前端",
            },
        ],
    },
    
    {
        "id": "code_level_50",
        "type": TaskType.SKILL_BASED,
        "description": "能力达到25级，解锁下一级技能学习，隐藏锁定上一级技能学习。",
        "is_active": true, #是否激活
        "is_repeatable": false, #是否可重复的任务 false 不可重复
        "is_in_progress": false,  # 任务是否进行中
        "duration_days":false,#是否是长期任务
        "is_completed": false, #是否已完成
        #"times":1,#事件次数
        #"post_times":1,#年度总结发布次数。
        "level":50,
        "skill_type": Blogger.Skills.CODE,
        "actions": [
            {
                "type": ActionType.SKILL_LEVEL_LOCK,
                "skill_name": "学习前端",
            },
            {
                "type": ActionType.SKILL_LEVEL_UNLOCK,
                "skill_name":"高级编程",
            },
        ],
    },
    
    {
        "id": "code_level_75",
        "type": TaskType.SKILL_BASED,
        "description": "能力达到25级，解锁下一级技能学习，隐藏锁定上一级技能学习。",
        "is_active": true, #是否激活
        "is_repeatable": false, #是否可重复的任务 false 不可重复
        "is_in_progress": false,  # 任务是否进行中
        "duration_days":false,#是否是长期任务
        "is_completed": false, #是否已完成
        #"times":1,#事件次数
        #"post_times":1,#年度总结发布次数。
        "level":75,
        "skill_type": Blogger.Skills.CODE,
        "actions": [
            {
                "type": ActionType.SKILL_LEVEL_LOCK,
                "skill_name": "高级编程",
            },
            {
                "type": ActionType.SKILL_LEVEL_UNLOCK,
                "skill_name":"成为黑客",
            },
        ],
    },
    
    {
        "id": "code_level_100",
        "type": TaskType.SKILL_BASED,
        "description": "能力达到25级，解锁下一级技能学习，隐藏锁定上一级技能学习。",
        "is_active": true, #是否激活
        "is_repeatable": false, #是否可重复的任务 false 不可重复
        "is_in_progress": false,  # 任务是否进行中
        "duration_days":false,#是否是长期任务
        "is_completed": false, #是否已完成
        #"times":1,#事件次数
        #"post_times":1,#年度总结发布次数。
        "level":100,
        "skill_type": Blogger.Skills.CODE,
        "actions": [
            {
                "type": ActionType.SKILL_LEVEL_LOCK,
                "skill_name": "成为黑客",
            },
            #{
                #"type": ActionType.SKILL_LEVEL_UNLOCK,
                #"skill_name":"成为黑客",
            #},
        ],
    },
    
    
    
    
    
{
        "id": "darw_level_25",
        "type": TaskType.SKILL_BASED,
        "description": "能能达到25级，解锁下一级技能学习，隐藏锁定上一级技能学习。",
        "is_active": true, #是否激活
        "is_repeatable": false, #是否可重复的任务 false 不可重复
        "is_in_progress": false,  # 任务是否进行中
        "duration_days":false,#是否是长期任务
        "is_completed": false, #是否已完成
        #"times":1,#事件次数
        #"post_times":1,#年度总结发布次数。
        "level":25,
        "skill_type": Blogger.Skills.DRAW,
        "actions": [
            {
                "type": ActionType.SKILL_LEVEL_LOCK,
                "skill_name": "自学画画",
            },
            {
                "type": ActionType.SKILL_LEVEL_UNLOCK,
                "skill_name":"素描和色彩",
            },
        ],
    },
    
    {
        "id": "darw_level_50",
        "type": TaskType.SKILL_BASED,
        "description": "能能达到50级，解锁下一级技能学习，隐藏锁定上一级技能学习。",
        "is_active": true, #是否激活
        "is_repeatable": false, #是否可重复的任务 false 不可重复
        "is_in_progress": false,  # 任务是否进行中
        "duration_days":false,#是否是长期任务
        "is_completed": false, #是否已完成
        #"times":1,#事件次数
        #"post_times":1,#年度总结发布次数。
        "level":50,
        "skill_type": Blogger.Skills.DRAW,
        "actions": [
            {
                "type": ActionType.SKILL_LEVEL_LOCK,
                "skill_name": "素描和色彩",
            },
            {
                "type": ActionType.SKILL_LEVEL_UNLOCK,
                "skill_name":"原画师之路",
            },
        ],
    },
    
    {
        "id": "darw_level_75",
        "type": TaskType.SKILL_BASED,
        "description": "能能达到75级，解锁下一级技能学习，隐藏锁定上一级技能学习。",
        "is_active": true, #是否激活
        "is_repeatable": false, #是否可重复的任务 false 不可重复
        "is_in_progress": false,  # 任务是否进行中
        "duration_days":false,#是否是长期任务
        "is_completed": false, #是否已完成
        #"times":1,#事件次数
        #"post_times":1,#年度总结发布次数。
        "level":75,
        "skill_type": Blogger.Skills.DRAW,
        "actions": [
            {
                "type": ActionType.SKILL_LEVEL_LOCK,
                "skill_name": "原画师之路",
            },
            {
                "type": ActionType.SKILL_LEVEL_UNLOCK,
                "skill_name":"大画家",
            },
        ],
    },
    
    {
        "id": "darw_level_100",
        "type": TaskType.SKILL_BASED,
        "description": "能能达到75级，解锁下一级技能学习，隐藏锁定上一级技能学习。",
        "is_active": true, #是否激活
        "is_repeatable": false, #是否可重复的任务 false 不可重复
        "is_in_progress": false,  # 任务是否进行中
        "duration_days":false,#是否是长期任务
        "is_completed": false, #是否已完成
        #"times":1,#事件次数
        #"post_times":1,#年度总结发布次数。
        "level":100,
        "skill_type": Blogger.Skills.DRAW,
        "actions": [
            {
                "type": ActionType.SKILL_LEVEL_LOCK,
                "skill_name": "大画家",
            },
            #{
                #"type": ActionType.SKILL_LEVEL_UNLOCK,
                #"skill_name":"大画家",
            #},
        ],
    },
    
    
    ####################
    # 解锁或锁定可发布博文任务
    ####################
{
        "id": "111_解锁博客第一篇博文",
        "type": TaskType.TIME_BASED,
        "description": "经过一阵子的折腾，博客终于整式上线了！当你准备好就可以发表博客的第一篇博文了！",
        "is_active": true, #是否激活
        "is_repeatable": false, #是否可重复的任务 false 不可重复
        "is_in_progress": false,  # 任务是否进行中
        "duration_days":false,#是否是长期任务
        "is_completed": false, #是否已完成
        "times":1,#事件次数
        "post_times":1,#发布次数。
        "is_currently_valid": true, #当前日期是否有效
        "post_type": "第一篇博文",
        "event_date":{        #事件启用结束时间，
            "y":[2000],
            "m":[1],
            "w":[1],
            "d":[3]
        },
        "actions": [
            {
                "type": ActionType.UNLOCK_POST_TASK,
                "post_type": "第一篇博文",
            },
        ],
    },
    {
        "id": "112_锁定博客第一篇博文",
        "type": TaskType.NEW_BLOG_POST,
        "description": "你已经发布了博客第一篇博文，博客第一篇博文类型发布已锁定。",
        "is_active": true, #是否激活
        "is_repeatable": false, #是否可重复的任务 false 不可重复
        "is_in_progress": false,  # 任务是否进行中
        "duration_days":false,#是否是长期任务
        "is_completed": false, #是否已完成
        #"times":1,#事件次数
        "post_times":1,#年度总结发布次数。
        "post_type": "第一篇博文",
        #事件启用结束时间，
        #"is_currently_valid": false, #当前日期是否有效
        #"event_date":{
            #"y":[0],
            #"m":[1],
            #"w":[2],
            #"d":[0]
        #},
        "actions": [
            {
                "type": ActionType.HIDE_POST_TASK,
                "post_type": "第一篇博文",
            },
        ],
    },
    
    {
        "id": "101_解锁年度总结",
        "type": TaskType.TIME_BASED,
        "description": "每年12月份发布一次年度总结博文",
        "is_active": true, #是否激活
        "is_repeatable": true, #是否可重复的任务 false 不可重复
        "is_in_progress": false,  # 任务是否进行中
        "duration_days":true,#是否是长期任务
        "is_completed": false, #是否已完成
        "times":1,#事件次数
        "post_times":1,#年度总结发布次数。
        "is_currently_valid": true, #当前日期是否有效
        "post_type": "年度总结",
        "event_date":{        #事件启用结束时间，
            "y":[0],
            "m":[12],
            "w":[2],
            "d":[1]
        },
        "actions": [
            {
                "type": ActionType.UNLOCK_POST_TASK,
                "post_type": "年度总结",
            },
        ],
    },
    {
        "id": "102_锁定年度总结",
        "type": TaskType.TIME_BASED,
        "description": "发布年度总结最佳时间已过，年度总结博文类型发布已锁定。",
        "is_active": true, #是否激活
        "is_repeatable": true, #是否可重复的任务 false 不可重复
        "is_in_progress": false,  # 任务是否进行中
        "duration_days":true,#是否是长期任务
        "is_completed": false, #是否已完成
        #"times":1,#事件次数
        "post_times":1,#年度总结发布次数。
        "post_type": "年度总结",
        #事件启用结束时间，
        "is_currently_valid": true, #当前日期是否有效
        "event_date":{
            "y":[0],
            "m":[12],
            "w":[4],
            "d":[7]
        },
        "actions": [
            {
                "type": ActionType.LOCK_POST_TASK,
                "post_type": "年度总结",
            },
        ],
    },
    
    {
        "id": "103_锁定年度总结",
        "type": TaskType.NEW_BLOG_POST,
        "description": "你已经发布了年度总结，年度总结博文类型发布已锁定。",
        "is_active": true, #是否激活
        "is_repeatable": true, #是否可重复的任务 false 不可重复
        "is_in_progress": false,  # 任务是否进行中
        "duration_days":true,#是否是长期任务
        "is_completed": false, #是否已完成
        #"times":1,#事件次数
        "post_times":1,#年度总结发布次数。
        #事件启用结束时间，
        #"is_currently_valid": false, #当前日期是否有效
        #"event_date":{
            #"y":[0],
            #"m":[1],
            #"w":[2],
            #"d":[0]
        #},
        "post_type": "年度总结",
        "actions": [
            {
                "type": ActionType.LOCK_POST_TASK,
                "post_type": "年度总结",
            },
        ],
    },
    
    ####################
    # 成就任务
    ####################
{
        "id": "004_解锁江湖段位成就lv10",
        "type": TaskType.LV_BASED,
        "description": "恭喜您的等级升级到10级，江湖段位达到[出入江湖]！",
        "is_active": true, #是否激活
        "is_repeatable": false, #是否可重复的任务 false 不可重复
        "is_in_progress": false,  # 任务是否进行中
        "duration_days":false,#是否是长期任务
        "is_completed": false, #是否已完成
        "times":1,#事件次数
        "lv": 10, #触发等级
        "actions": [
            {
                "type": ActionType.UNLOCK_MILESTONES_TASK,
                "milestones_id": "level_10",
                "milestones_name": "lv",
            },
        ],
    },
    {
        "id": "005_解锁江湖段位成就lv20",
        "type": TaskType.LV_BASED,
        "description": "恭喜您的等级升级到20级，江湖段位达到[崭露头角]！",
        "is_active": true, #是否激活
        "is_repeatable": false, #是否可重复的任务 false 不可重复
        "is_in_progress": false,  # 任务是否进行中
        "duration_days":false,#是否是长期任务
        "is_completed": false, #是否已完成
        "times":1,#事件次数
        "lv": 20, #触发等级
        "actions": [
            {
                "type": ActionType.UNLOCK_MILESTONES_TASK,
                "milestones_id": "level_20",
                "milestones_name": "lv",
            },
        ],
    },
    {
        "id": "006_解锁江湖段位成就lv30",
        "type": TaskType.LV_BASED,
        "description": "恭喜您的等级升级到30级，江湖段位达到[锋芒毕露]！",
        "is_active": true, #是否激活
        "is_repeatable": false, #是否可重复的任务 false 不可重复
        "is_in_progress": false,  # 任务是否进行中
        "duration_days":false,#是否是长期任务
        "is_completed": false, #是否已完成
        "times":1,#事件次数
        "lv": 30, #触发等级
        "actions": [
            {
                "type": ActionType.UNLOCK_MILESTONES_TASK,
                "milestones_id": "level_30",
                "milestones_name": "lv",
            },
        ],
    },
    {
        "id": "007_解锁江湖段位成就lv40",
        "type": TaskType.LV_BASED,
        "description": "恭喜您的等级升级到40级，江湖段位达到[名扬四海]！",
        "is_active": true, #是否激活
        "is_repeatable": false, #是否可重复的任务 false 不可重复
        "is_in_progress": false,  # 任务是否进行中
        "duration_days":false,#是否是长期任务
        "is_completed": false, #是否已完成
        "times":1,#事件次数
        "lv": 40, #触发等级
        "actions": [
            {
                "type": ActionType.UNLOCK_MILESTONES_TASK,
                "milestones_id": "level_40",
                "milestones_name": "lv",
            },
        ],
    },  
    {
        "id": "008_解锁江湖段位成就lv50",
        "type": TaskType.LV_BASED,
        "description": "恭喜您的等级升级到50级，江湖段位达到[独步天下]！",
        "is_active": true, #是否激活
        "is_repeatable": false, #是否可重复的任务 false 不可重复
        "is_in_progress": false,  # 任务是否进行中
        "duration_days":false,#是否是长期任务
        "is_completed": false, #是否已完成
        "times":1,#事件次数
        "lv": 50, #触发等级
        "actions": [
            {
                "type": ActionType.UNLOCK_MILESTONES_TASK,
                "milestones_id": "level_50",
                "milestones_name": "lv",
            },
        ],
    },  

    {
        "id": "009_解锁江湖段位成就lv60",
        "type": TaskType.LV_BASED,
        "description": "恭喜您的等级升级到60级，江湖段位达到[一代宗师]！",
        "is_active": true, #是否激活
        "is_repeatable": false, #是否可重复的任务 false 不可重复
        "is_in_progress": false,  # 任务是否进行中
        "duration_days":false,#是否是长期任务
        "is_completed": false, #是否已完成
        "times":1,#事件次数
        "lv": 60, #触发等级
        "actions": [
            {
                "type": ActionType.UNLOCK_MILESTONES_TASK,
                "milestones_id": "level_60",
                "milestones_name": "lv",
            },
        ],
    }, 
    
    {
        "id": "010_解锁江湖段位成就lv70",
        "type": TaskType.LV_BASED,
        "description": "恭喜您的等级升级到70级，江湖段位达到[剑气长虹]！",
        "is_active": true, #是否激活
        "is_repeatable": false, #是否可重复的任务 false 不可重复
        "is_in_progress": false,  # 任务是否进行中
        "duration_days":false,#是否是长期任务
        "is_completed": false, #是否已完成
        "times":1,#事件次数
        "lv": 70, #触发等级
        "actions": [
            {
                "type": ActionType.UNLOCK_MILESTONES_TASK,
                "milestones_id": "level_70",
                "milestones_name": "lv",
            },
        ],
    }, 
    
    {
        "id": "011_解锁江湖段位成就lv80",
        "type": TaskType.LV_BASED,
        "description": "恭喜您的等级升级到80级，江湖段位达到[无敌于世]！",
        "is_active": true, #是否激活
        "is_repeatable": false, #是否可重复的任务 false 不可重复
        "is_in_progress": false,  # 任务是否进行中
        "duration_days":false,#是否是长期任务
        "is_completed": false, #是否已完成
        "times":1,#事件次数
        "lv": 80, #触发等级
        "actions": [
            {
                "type": ActionType.UNLOCK_MILESTONES_TASK,
                "milestones_id": "level_80",
                "milestones_name": "lv",
            },
        ],
    }, 
    
    {
        "id": "012_解锁江湖段位成就lv90",
        "type": TaskType.LV_BASED,
        "description": "恭喜您的等级升级到90级，江湖段位达到[武林霸主]！",
        "is_active": true, #是否激活
        "is_repeatable": false, #是否可重复的任务 false 不可重复
        "is_in_progress": false,  # 任务是否进行中
        "duration_days":false,#是否是长期任务
        "is_completed": false, #是否已完成
        "times":1,#事件次数
        "lv": 90, #触发等级
        "actions": [
            {
                "type": ActionType.UNLOCK_MILESTONES_TASK,
                "milestones_id": "level_90",
                "milestones_name": "lv",
            },
        ],
    }, 
    
    {
        "id": "013_解锁江湖段位成就lv100",
        "type": TaskType.LV_BASED,
        "description": "恭喜您的等级升级到100级，江湖段位达到[天外飞仙]！",
        "is_active": true, #是否激活
        "is_repeatable": false, #是否可重复的任务 false 不可重复
        "is_in_progress": false,  # 任务是否进行中
        "duration_days":false,#是否是长期任务
        "is_completed": false, #是否已完成
        "times":1,#事件次数
        "lv": 100, #触发等级
        "actions": [
            {
                "type": ActionType.UNLOCK_MILESTONES_TASK,
                "milestones_id": "level_100",
                "milestones_name": "lv",
            },
        ],
    }, 
    
   ################################### 
    
    
    
    {
        "id": "099_热点风向",
        "type": TaskType.TIME_BASED,
        "name":"热点风向",
        "description": "每年两次的热点切换",
        "is_active": true, #是否激活
        "is_repeatable": true, #是否可重复的任务 false 不可重复
        "is_in_progress": false,  # 任务是否进行中
        "duration_days":true,#是否是长期任务
        "is_completed": false, #是否已完成
        "is_currently_valid": true, #当前日期是否有效
        "event_date":{
            "y":[0],
            "m":[1,6],
            "w":[2],
            "d":[1]
        },
        "actions": [
            {
                "type": ActionType.REPLACE_POST_TREND,
            },
        ]
    },
]
