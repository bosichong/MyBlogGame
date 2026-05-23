extends Node
## 剧情进度追踪系统
## 用于管理游戏五个章节的剧情里程碑完成状态

## 第一章：博客启蒙期（2002-2005）
var chapter1 = {
    "prologue_completed": false,
    "blog_online": false,
    "first_article_posted": false,
    "baidu_indexed": false,
    "icp_filing_done": false,
    "rss_enabled": false,
    "blog_union_joined": false,
    "first_friend_link": false,
    "ad_union_joined": false,
    "first_income": false,
    "year_summary_2005": false,
    "award_2005": false,
}

## 第二章：博客黄金期（2005-2010）
var chapter2 = {
    "literature_weekly": false,
    "code_weekly": false,
    "rss_100": false,
    "weibo_joined": false,
    "weibo_content_50": false,
    "income_1000": false,
    "year_summary_2010": false,
    "award_2010": false,
}

## 第三章：博客转型期（2010-2015）
var chapter3 = {
    "viral_article": false,
    "advanced_tutorial": false,
    "wechat_public": false,
    "mobile_adapted": false,
    "https_upgraded": false,
    "cloud_server": false,
    "novel_planning": false,
    "open_source_planning": false,
    "year_summary_2015": false,
    "award_2015": false,
}

## 第四章：博客挑战期（2015-2020）
var chapter4 = {
    "novel_serial_start": false,
    "paid_hacking": false,
    "book_invitation": false,
    "book_writing": false,
    "book_published": false,
    "open_source_start": false,
    "open_source_recognized": false,
    "cdn_enabled": false,
    "short_video": false,
    "ai_preview": false,
    "year_summary_2020": false,
    "award_2020": false,
}

## 第五章：博客重塑期（2020-2025）
var chapter5 = {
    "ai_unlocked": false,
    "ai_article_50": false,
    "game_dev_start": false,
    "game_dev_complete": false,
    "game_test": false,
    "video_account": false,
    "game_trailer": false,
    "personal_brand": false,
    "game_released": false,
    "game_award": false,
    "fame_let_go": false,
    "decline_award_2025": false,
    "return_to_roots": false,
    "free_writing": false,
    "ending_achieved": false,
}

func _init():
    pass

func set_completed(chapter: int, milestone: String) -> void:
    var ch = _get_chapter_dict(chapter)
    if ch.is_empty():
        push_error("[StoryProgress] Unknown chapter: %d" % chapter)
        return
    if not ch.has(milestone):
        push_error("[StoryProgress] Unknown milestone '%s' in chapter %d" % [milestone, chapter])
        return
    ch[milestone] = true

func is_completed(chapter: int, milestone: String) -> bool:
    var ch = _get_chapter_dict(chapter)
    if ch.is_empty():
        return false
    return ch.get(milestone, false)

func chapter_completed(chapter: int) -> bool:
    var ch = _get_chapter_dict(chapter)
    if ch.is_empty():
        return false
    for key in ch:
        if ch[key] == false:
            return false
    return true

func get_chapter_progress(chapter: int) -> Dictionary:
    var ch = _get_chapter_dict(chapter)
    var completed = 0
    var total = ch.size()
    for key in ch:
        if ch[key]:
            completed += 1
    return {"completed": completed, "total": total, "progress": float(completed) / float(total) if total > 0 else 0.0}

func reset_chapter(chapter: int) -> void:
    var ch = _get_chapter_dict(chapter)
    if ch.is_empty():
        return
    for key in ch:
        ch[key] = false

func get_all_progress() -> Dictionary:
    return {
        "chapter1": get_chapter_progress(1),
        "chapter2": get_chapter_progress(2),
        "chapter3": get_chapter_progress(3),
        "chapter4": get_chapter_progress(4),
        "chapter5": get_chapter_progress(5),
    }

func to_dict() -> Dictionary:
    return {
        "chapter1": chapter1.duplicate(true),
        "chapter2": chapter2.duplicate(true),
        "chapter3": chapter3.duplicate(true),
        "chapter4": chapter4.duplicate(true),
        "chapter5": chapter5.duplicate(true),
    }

func from_dict(data: Dictionary) -> void:
    if data.has("chapter1"):
        _merge_dict(chapter1, data.chapter1)
    if data.has("chapter2"):
        _merge_dict(chapter2, data.chapter2)
    if data.has("chapter3"):
        _merge_dict(chapter3, data.chapter3)
    if data.has("chapter4"):
        _merge_dict(chapter4, data.chapter4)
    if data.has("chapter5"):
        _merge_dict(chapter5, data.chapter5)

func _merge_dict(target: Dictionary, source: Dictionary) -> void:
    for key in source:
        if target.has(key):
            target[key] = source[key]

func _get_chapter_dict(chapter: int) -> Dictionary:
    match chapter:
        1: return chapter1
        2: return chapter2
        3: return chapter3
        4: return chapter4
        5: return chapter5
        _:
            return {}
