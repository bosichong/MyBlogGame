# TaskConfig.gd
# 任务配置文件，使用数组+字典组合定义所有任务

# 任务类型枚举
enum TaskType {
    TIME_BASED,    # 基于时间的任务
    NEW_BLOG_PLST, # 基于博文发布的类型任务
    ATTRIBUTE_BASED,  # 基于属性的任务
    CONDITION_BASED,   # 基于复合条件的任务
    CUSTOM_TYPE #自定义条件
}

# 任务动作类型枚举
enum ActionType {
    UNLOCK_POST_TASK,  # 解锁可以发布类型博文的任务
    LOCK_POST_TASK,    # 锁定可以发布类型博文的任务
    REPLACE_POST_TREND,# 更换博文热点属性
    MODIFY_ATTRIBUTE,  # 修改属性
    CHANGE_SCENE,      # 切换场景
    SHOW_NOTIFICATION, # 显示通知
    CUSTOM_ACTION      # 自定义动作
}

# 所有任务定义
const TASKS = [
    {
        "id": "001_解锁年度总结",
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
        "event_date":{        #事件启用结束时间，
            "y":[0],
            "m":[12],
            "w":[2],
            "d":[1]
        },
        "actions": [
            {
                "type": ActionType.UNLOCK_POST_TASK,
                "post_type": ["年度总结"],
            },
        ],
    },
        {
        "id": "002_锁定年度总结",
        "type": TaskType.TIME_BASED,
        "description": "发布年度总结最佳时间已过，年度总结博文类型发布已锁定。",
        "is_active": true, #是否激活
        "is_repeatable": true, #是否可重复的任务 false 不可重复
        "is_in_progress": false,  # 任务是否进行中
        "duration_days":true,#是否是长期任务
        "is_completed": false, #是否已完成
        #"times":1,#事件次数
        "post_times":1,#年度总结发布次数。
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
                "post_type": ["年度总结"],
            },
        ],
    },
    
            {
        "id": "003_锁定年度总结",
        "type": TaskType.NEW_BLOG_PLST,
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
        "post_type": ["年度总结"],
        "actions": [
            {
                "type": ActionType.LOCK_POST_TASK,
                "post_type": ["年度总结"],
            },
        ],
    },
    {
        "id": "004_热点风向",
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
