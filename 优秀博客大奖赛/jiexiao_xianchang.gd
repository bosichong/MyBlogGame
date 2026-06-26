extends Node2D

const WINNER_COUNT_MIN := 3
const WINNER_COUNT_MAX := 5
const HIGHLIGHT_COLOR := "#FFD700"
const PLAYER_COLOR := "#FF6B35"

const EDITION_DATA = {
    1: { "year": 2005, "theme": "内容更新频率", "criteria": "三年持续更新" },
    2: { "year": 2010, "theme": "内容质量 + 访问量", "criteria": "文章深度与影响力" },
    3: { "year": 2015, "theme": "创新能力 + 影响力", "criteria": "原创内容与社区贡献" },
    4: { "year": 2020, "theme": "十年如一日的坚持", "criteria": "长期主义与内容沉淀" },
    5: { "year": 2025, "theme": "回归表达的本质", "criteria": "内容真诚度" },
}

@onready var tit: Label = $开场白/tit
@onready var con: RichTextLabel = $开场白/con
@onready var end_tit: Label = $结尾/tit
@onready var end_con: Label = $结尾/con


func _ready() -> void:
    var ordinal = 1
    if TaskManager and TaskManager.pending_scene_params.has("notification_ordinal"):
        ordinal = TaskManager.pending_scene_params.notification_ordinal
        TaskManager.pending_scene_params.erase("notification_ordinal")

    var data = EDITION_DATA.get(ordinal, EDITION_DATA[1])
    var player_name: String = str(Blogger.blog_data.get("blog_name", "我的博客"))
    var player_level: int = Blogger.level

    var is_repeat: bool = false
    var player_won: bool = false

    if TaskManager and TaskManager.pending_scene_params.has("award_result_data"):
        var award_data = TaskManager.pending_scene_params.award_result_data
        player_won = award_data.get("result") == AwardManager.AwardResult.WIN
        is_repeat = award_data.get("is_repeat", false)
        TaskManager.pending_scene_params.erase("award_result_data")
    elif TaskManager and TaskManager.pending_scene_params.has("test_award_result"):
        var test_result = TaskManager.pending_scene_params.test_award_result
        player_won = test_result == AwardManager.AwardResult.WIN
        is_repeat = TaskManager.pending_scene_params.get("test_is_repeat", false)
        TaskManager.pending_scene_params.erase("test_award_result")
        TaskManager.pending_scene_params.erase("test_is_repeat")
    else:
        var award_result = AwardManager.process_award(ordinal, data["year"], player_level, player_name)
        is_repeat = award_result.get("is_repeat", false)
        player_won = award_result.get("result") == AwardManager.AwardResult.WIN

    tit.text = "第 %d 届优秀博客大赛 — 颁奖典礼" % ordinal
    con.text = _build_body(ordinal, data["year"], data["theme"], data["criteria"], data, player_name, player_won, is_repeat)
    end_tit.text = "第 %d 届优秀博客大赛圆满落幕" % ordinal
    end_con.text = _build_ending(ordinal, data["year"], is_repeat)


func _pick_winners(player_name: String, player_won: bool) -> Array[Dictionary]:
    var winners: Array[Dictionary] = []

    if Lm and Lm.jhph.size() > 0:
        var top10: Array = Lm.jhph.slice(0, 10)
        var candidates: Array[Dictionary] = []
        for m in top10:
            if m.get("id", 0) == 888:
                continue
            if not m.get("blog_name", "").is_empty():
                candidates.append(m)

        if candidates.size() > 0:
            candidates.shuffle()
            var count = randi_range(WINNER_COUNT_MIN, min(WINNER_COUNT_MAX, candidates.size() + (1 if player_won else 0)))
            for i in range(min(count - (1 if player_won else 0), candidates.size())):
                winners.append(candidates[i])

    if player_won:
        winners.append({ "blog_name": player_name, "is_player": true })

    winners.shuffle()
    return winners


func _build_body(ordinal: int, year: int, theme: String, criteria: String, data: Dictionary, player_name: String, player_won: bool, is_repeat: bool) -> String:
    var lines: Array[String] = []

    if is_repeat:
        lines.push_back("[center]蝉联优秀博客大奖！传奇仍在继续！[/center]")
        lines.push_back("")

    lines.push_back("[center]经过一整年的激烈角逐与精彩创作，第 %d 届优秀博客大赛的各大奖项已尘埃落定。[/center]" % ordinal)
    lines.push_back("")
    lines.push_back("[center]本届大赛主题为「%s」，评审团以「%s」为标准，[/center]" % [theme, criteria])
    lines.push_back("[center]从众多优秀独立博客中评选出了本届获奖者。[/center]")
    lines.push_back("")

    lines.push_back("[center]━━━ 获奖博客名单（排名不分先后）━━━[/center]")
    lines.push_back("")
    var winners = _pick_winners(player_name, player_won)
    for w in winners:
        if w.get("is_player", false):
            lines.push_back("[center][color=%s]★ %s[/color][/center]" % [PLAYER_COLOR, w["blog_name"]])
        else:
            lines.push_back("[center][color=%s]★ %s[/color][/center]" % [HIGHLIGHT_COLOR, w["blog_name"]])
    lines.push_back("")

    lines.push_back("[center]让我们将镜头切换到 %d 年颁奖典礼现场，[/center]" % year)
    if player_won:
        lines.push_back("[center]共同见证 [color=%s]%s[/color] 获奖这一荣耀时刻！[/center]" % [PLAYER_COLOR, player_name])
    else:
        lines.push_back("[center]共同见证这一荣耀时刻！[/center]")

    return "\n".join(lines)


func _build_ending(ordinal: int, year: int, is_repeat: bool) -> String:
    var next_year = year + 5
    var lines: Array[String] = []

    lines.append("至此，第 %d 届优秀博客大赛颁奖典礼圆满结束。" % ordinal)
    lines.append("")
    lines.append("感谢所有参赛博主的精彩创作，也感谢各位嘉宾与观众的陪伴。")
    lines.append("每一篇用心写下的文字，都是这个时代最珍贵的声音。")

    if is_repeat:
        lines.append("")
        lines.append("连续获奖，实力斐然！您的博客已是中文独立博客的一面旗帜。")

    lines.append("")
    lines.append("博客不死，表达不止。期待 %d 年再相聚，五年后再见！" % next_year)
    lines.append("")
    lines.append("祝大家写作愉快，天天开心！")

    return "\n".join(lines)

func _on_return_button_pressed() -> void:
    if TimerManager:
        TimerManager.start_timer()
    if Utils:
        Utils.goto_scene("res://scenes/main.tscn")
