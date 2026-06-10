extends Node2D

const MAIN_SCENE_PATH = "res://scenes/main.tscn"

var review_events: Array[Dictionary] = []
var review_title: String = ""
var from_year: int = 0
var to_year: int = 0
var review_chapter: int = 1

@onready var scroll_label: RichTextLabel = $Panel/RichTextLabel
@onready var back_button: Button = $Panel/BackButton

func _ready() -> void:
    scroll_label.scroll_active = false
    if TaskManager:
        var params = TaskManager.pending_scene_params
        from_year = params.get("from_year", 0)
        to_year = params.get("to_year", 0)
        review_title = params.get("title", "回忆录")
        review_chapter = params.get("chapter", 1)
        TaskManager.pending_scene_params = {}

    _build_review_events()
    _build_scroll_text()
    _start_scroll()

func _build_review_events() -> void:
    review_events.clear()

    if not GDManager:
        review_events = _make_test_events()
        return

    var story = GDManager.get_story_progress()
    if not story:
        review_events = _make_test_events()
        return

    var ch: Dictionary = {}
    match review_chapter:
        2: ch = story.chapter2
        3: ch = story.chapter3
        4: ch = story.chapter4
        5: ch = story.chapter5
        _: ch = story.chapter1

    var archive_map: Dictionary = {}
    if from_year > 0 and to_year > 0:
        var archive_events = GDManager.get_blog_archive().get_events_by_year_range(from_year, to_year)
        for ae in archive_events:
            archive_map[ae.get("id", "")] = ae.get("time", "")

    for milestone in ch:
        if not ch[milestone]:
            continue

        var full_desc = story.get_milestone_description(review_chapter, milestone)
        if full_desc.begins_with("未知里程碑"):
            continue

        var parts = full_desc.split("：")
        var title = parts[0] if parts.size() > 0 else milestone
        var detail = parts[1] if parts.size() > 1 else ""

        review_events.append({
            "time": archive_map.get(milestone, ""),
            "title": title,
            "description": detail,
        })

    var dated: Array[Dictionary] = []
    var undated: Array[Dictionary] = []
    for e in review_events:
        if e.time.is_empty():
            undated.append(e)
        else:
            dated.append(e)

    dated.sort_custom(func(a, b): return a.time < b.time)
    review_events = dated + undated

    if review_events.is_empty():
        review_events = _make_test_events()

func _make_test_events() -> Array[Dictionary]:
    return [
        {"time": "", "title": "博客开启", "description": "开始撰写博客"},
        {"time": "", "title": "第一篇文章", "description": ""},
    ]

func _build_scroll_text() -> void:
    scroll_label.clear()

    scroll_label.push_paragraph(HORIZONTAL_ALIGNMENT_CENTER)
    scroll_label.push_bold()
    scroll_label.push_font_size(24)
    scroll_label.add_text(review_title)
    scroll_label.pop()
    scroll_label.pop()
    scroll_label.pop()
    scroll_label.add_text("\n")
    scroll_label.push_paragraph(HORIZONTAL_ALIGNMENT_CENTER)
    scroll_label.add_text("%d - %d" % [from_year, to_year])
    scroll_label.pop()

    scroll_label.add_text("\n\n")

    for e in review_events:
        var time = e.get("time", "")
        var title = e.get("title", "")
        var desc = e.get("description", "")

        scroll_label.push_paragraph(HORIZONTAL_ALIGNMENT_CENTER)
        scroll_label.push_bold()
        scroll_label.add_text("%s  %s" % [time, title])
        scroll_label.pop()
        scroll_label.add_text("\n")

        if not desc.is_empty():
            scroll_label.add_text("  %s\n" % desc)

        scroll_label.add_text("\n")
        scroll_label.pop()

func _start_scroll() -> void:
    await get_tree().process_frame
    await get_tree().process_frame

    var viewport_h = get_viewport_rect().size.y
    var text_h = scroll_label.get_content_height()
    if text_h <= 0:
        text_h = 800
    var start_y = viewport_h + 50
    var end_y = -text_h - 50
    var duration = (start_y - end_y) / 35.0

    scroll_label.position.y = start_y
    var tween = create_tween()
    tween.tween_property(scroll_label, "position:y", end_y, duration)
    tween.finished.connect(back_to_main)

func back_to_main() -> void:
    TimerManager.start_timer()
    Utils.goto_scene(MAIN_SCENE_PATH)

func get_review_events() -> Array[Dictionary]:
    return review_events

func get_review_title() -> String:
    return review_title

func get_year_range_text() -> String:
    if from_year > 0 and to_year > 0:
        return "%d - %d" % [from_year, to_year]
    return ""
