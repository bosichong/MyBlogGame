extends Node2D

const SCENE_PATH = "res://scenes/main.tscn"

const EDITION_DATA = {
    1: { "year": 2005, "theme": "内容更新频率", "criteria": "三年持续更新", "venue": "线上公告（无现场）" },
    2: { "year": 2010, "theme": "内容质量 + 访问量", "criteria": "文章深度与影响力", "venue": "线上公告 + 联盟年会" },
    3: { "year": 2015, "theme": "创新能力 + 影响力", "criteria": "原创内容与社区贡献", "venue": "北京 · 博客联盟年会现场" },
    4: { "year": 2020, "theme": "十年如一日的坚持", "criteria": "长期主义与内容沉淀", "venue": "上海 · 中文独立博客大会" },
    5: { "year": 2025, "theme": "回归表达的本质", "criteria": "内容真诚度", "venue": "杭州 · 中文博客大会" },
}

@onready var tit: Label = $emailui/tit
@onready var con2: Label = $emailui/con2


func _ready() -> void:
    var ordinal = 1
    if TaskManager and TaskManager.pending_scene_params.has("notification_ordinal"):
        ordinal = TaskManager.pending_scene_params.notification_ordinal
        TaskManager.pending_scene_params.erase("notification_ordinal")

    var data = EDITION_DATA.get(ordinal, EDITION_DATA[1])
    tit.text = "中文博客联盟【第 %d 届中文优秀博客大奖】评选通知" % ordinal
    con2.text = _build_body(ordinal, data["year"], data["theme"], data["criteria"], data["venue"])


func _build_body(ordinal: int, year: int, theme: String, criteria: String, venue: String) -> String:
    return """亲爱的博主朋友：

您好！
第 %d 届「中文优秀博客大奖」评选活动现已启动。本届主题为「%s」，评选标准为「%s」。
本届评选面向全体中文独立博客，评审团将对参赛博客进行综合评议。
如您有意参加，无需任何操作，评审团将根据博客内容质量进行评选。
颁奖时间：%d 年 12 月
颁奖地点：%s
中文博客联盟  %d 年 11 月""" % [ordinal, theme, criteria, year, venue, year]


func _on_button_pressed() -> void:
    TimerManager.start_timer()
    Utils.goto_scene(SCENE_PATH)
