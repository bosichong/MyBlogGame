extends Node

enum AwardResult { NONE, NOMINATE, SHORTLIST, WIN }

const AWARD_YEARS = [
    { "ordinal": 1, "year": 2005, "chapter": 1, "milestone": "award_2005" },
    { "ordinal": 2, "year": 2010, "chapter": 2, "milestone": "award_2010" },
    { "ordinal": 3, "year": 2015, "chapter": 3, "milestone": "award_2015" },
    { "ordinal": 4, "year": 2020, "chapter": 4, "milestone": "award_2020" },
    { "ordinal": 5, "year": 2025, "chapter": 5, "milestone": "fame_let_go" },
]

func determine_result(_player_level: int = 0) -> AwardResult:
    var rank = _get_player_rank()
    if rank <= 0:
        return AwardResult.NONE
    elif rank <= 10:
        return AwardResult.WIN
    elif rank <= 25:
        return AwardResult.SHORTLIST
    elif rank <= 50:
        return AwardResult.NOMINATE
    else:
        return AwardResult.NONE

func _get_player_rank() -> int:
    if not Lm:
        return -1
    Lm.sync_player_data()
    if Lm.jhph.is_empty():
        return -1
    for i in Lm.jhph.size():
        if Lm.jhph[i].get("id", 0) == 888:
            return i + 1
    return -1

func get_result_label(result: AwardResult) -> String:
    match result:
        AwardResult.NONE: return "无奖项"
        AwardResult.NOMINATE: return "提名"
        AwardResult.SHORTLIST: return "入围"
        AwardResult.WIN: return "优秀博客大奖"
        _: return ""

func get_title_name(result: AwardResult) -> String:
    match result:
        AwardResult.NOMINATE: return "博客新星"
        AwardResult.SHORTLIST: return "博客新锐"
        AwardResult.WIN: return "博客之星"
        _: return ""

func get_title_for_year(result: AwardResult, year: int) -> String:
    var title = get_title_name(result)
    if title.is_empty():
        return ""
    return "%s（%d）" % [title, year]

func get_repeat_tip(result: AwardResult, is_repeat: bool) -> String:
    if not is_repeat:
        return ""
    match result:
        AwardResult.NOMINATE: return "再次获得提名，继续精进，未来可期！"
        AwardResult.SHORTLIST: return "再次入围，实力稳健，距大奖仅一步之遥！"
        AwardResult.WIN: return "蝉联优秀博客大奖！传奇仍在继续！"
        _: return ""

func get_award_content(ordinal: int, year: int, player_name: String, result: AwardResult, is_repeat: bool) -> String:
    var repeat_tip = get_repeat_tip(result, is_repeat)
    var title_name = get_title_for_year(result, year)
    var parts = []

    match result:
        AwardResult.NONE:
            parts.push_back("第 %d 届「中文优秀博客大奖」获奖名单正式公布——" % ordinal)
            parts.push_back("很遗憾，您的博客「%s」未获得本届任何奖项。" % player_name)
            parts.push_back("继续努力提升博客质量，下一届期待您的参与！")
            parts.push_back("评语：「坚持写作，时间会给你答案。」")

        AwardResult.NOMINATE:
            parts.push_back("恭喜您的博客「%s」获得第 %d 届「中文优秀博客大奖」提名！" % [player_name, ordinal])
            if not title_name.is_empty():
                parts.push_back("您获得称号「%s」！" % title_name)
            if not repeat_tip.is_empty():
                parts.push_back("[蝉联] %s" % repeat_tip)
            parts.push_back("继续加油，每一篇认真的文字都值得被看见。")

        AwardResult.SHORTLIST:
            parts.push_back("恭喜您的博客「%s」入围第 %d 届「中文优秀博客大奖」！" % [player_name, ordinal])
            if not title_name.is_empty():
                parts.push_back("您获得称号「%s」！" % title_name)
            if not repeat_tip.is_empty():
                parts.push_back("[蝉联] %s" % repeat_tip)
            parts.push_back("再接再厉，您的博客正在被更多人看见。")

        AwardResult.WIN:
            parts.push_back("第 %d 届「中文优秀博客大奖」获奖名单正式公布——" % ordinal)
            parts.push_back("本届联盟排名前十的博主荣获优秀博客大奖，「%s」是其中之一！" % player_name)
            if not title_name.is_empty():
                parts.push_back("您获得称号「%s」！" % title_name)
            if not repeat_tip.is_empty():
                parts.push_back("[蝉联] %s" % repeat_tip)
            parts.push_back("评语：「您的博客是中文独立博客的标杆与灯塔。」")

    return "\n\n".join(parts)

func get_award_title(ordinal: int) -> String:
    return "第 %d 届优秀博客大奖评选结果揭晓" % ordinal

func get_last_result() -> AwardResult:
    var history = _get_history()
    if history.is_empty():
        return AwardResult.NONE
    return history[-1].get("result", AwardResult.NONE)

func record_result(year: int, result: AwardResult):
    var history = _get_history()
    history.append({"year": year, "result": result})

func _get_history() -> Array:
    if not GDManager or not GDManager.data_container or not GDManager.data_container.runtime_data:
        return []
    return GDManager.data_container.runtime_data.award_history

func try_mark_milestone(ordinal: int, year: int, result: AwardResult):
    if result == AwardResult.NONE:
        return
    for entry in AWARD_YEARS:
        if entry.ordinal == ordinal and entry.year == year:
            var sp = GDManager.get_story_progress()
            if sp:
                sp.set_completed(entry.chapter, entry.milestone)
            return

func process_award(ordinal: int, year: int, player_level: int, player_name: String) -> Dictionary:
    var result = determine_result(player_level)
    var last_result = get_last_result()
    var is_repeat = (result == last_result) and (result != AwardResult.NONE)
    var content = get_award_content(ordinal, year, player_name, result, is_repeat)
    var title = get_award_title(ordinal)

    record_result(year, result)
    try_mark_milestone(ordinal, year, result)

    return {
        "result": result,
        "is_repeat": is_repeat,
        "title": title,
        "content": content,
        "label": get_result_label(result),
        "title_name": get_title_for_year(result, year),
    }
