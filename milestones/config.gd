extends Node



# 江湖段位成就配置
# 等级范围：0-9级=初入江湖，10-19级=崭露头角，...，90-100级=天外飞仙
var lv = [
    {
        "id": "level_0",
        "name": "初入江湖",
        "description": "0-9级",
        "icon": preload("res://assets/milestones/lv10.png"),
        "locked_icon": preload("res://assets/milestones/locked.png"),
        "unlocked": true  # 默认解锁，因为1级就属于初入江湖段位
    },
    {
        "id": "level_10",
        "name": "崭露头角",
        "description": "10-19级",
        "icon": preload("res://assets/milestones/lv20.png"),
        "locked_icon": preload("res://assets/milestones/locked.png"),
        "unlocked": false
    },
    {
        "id": "level_20",
        "name": "锋芒毕露",
        "description": "20-29级",
        "icon": preload("res://assets/milestones/lv30.png"),
        "locked_icon": preload("res://assets/milestones/locked.png"),
        "unlocked": false
    },
    {
        "id": "level_30",
        "name": "名扬四海",
        "description": "30-39级",
        "icon": preload("res://assets/milestones/lv40.png"),
        "locked_icon": preload("res://assets/milestones/locked.png"),
        "unlocked": false
    },
    {
        "id": "level_40",
        "name": "独步天下",
        "description": "40-49级",
        "icon": preload("res://assets/milestones/lv50.png"),
        "locked_icon": preload("res://assets/milestones/locked.png"),
        "unlocked": false
    },
    {
        "id": "level_50",
        "name": "一代宗师",
        "description": "50-59级",
        "icon": preload("res://assets/milestones/lv60.png"),
        "locked_icon": preload("res://assets/milestones/locked.png"),
        "unlocked": false
    },
    {
        "id": "level_60",
        "name": "剑气长虹",
        "description": "60-69级",
        "icon": preload("res://assets/milestones/lv70.png"),
        "locked_icon": preload("res://assets/milestones/locked.png"),
        "unlocked": false
    },
    {
        "id": "level_70",
        "name": "无敌于世",
        "description": "70-79级",
        "icon": preload("res://assets/milestones/lv80.png"),
        "locked_icon": preload("res://assets/milestones/locked.png"),
        "unlocked": false
    },
    {
        "id": "level_80",
        "name": "武林霸主",
        "description": "80-89级",
        "icon": preload("res://assets/milestones/lv90.png"),
        "locked_icon": preload("res://assets/milestones/locked.png"),
        "unlocked": false
    },
    {
        "id": "level_90",
        "name": "天外飞仙",
        "description": "90-100级",
        "icon": preload("res://assets/milestones/lv100.png"),
        "locked_icon": preload("res://assets/milestones/locked.png"),
        "unlocked": false
    },
]

func _ready() -> void:
    pass