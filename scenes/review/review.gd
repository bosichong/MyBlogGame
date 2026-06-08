extends Node2D

const MAIN_SCENE_PATH = "res://scenes/main.tscn"

var review_events: Array[Dictionary] = []
var review_title: String = ""
var from_year: int = 0
var to_year: int = 0

@onready var scroll_label: RichTextLabel = $Panel/RichTextLabel
@onready var back_button: Button = $Panel/BackButton

func _ready() -> void:
    scroll_label.scroll_active = false
    if TaskManager:
        var params = TaskManager.pending_scene_params
        from_year = params.get("from_year", 0)
        to_year = params.get("to_year", 0)
        review_title = params.get("title", "回忆录")
        TaskManager.pending_scene_params = {}

    if GDManager and from_year > 0 and to_year > 0:
        review_events = GDManager.get_blog_archive().get_events_by_year_range(from_year, to_year)

    if review_events.is_empty():
        review_events = _make_test_events()

    _build_scroll_text()
    _start_scroll()

func _make_test_events() -> Array[Dictionary]:
    return [
        {"time": "2003-06", "title": "第一篇博文发布", "description": "写下《你好，世界》"},
        {"time": "2003-08", "title": "博客被搜索引擎收录", "description": "博客第一次出现在搜索结果中"},
        {"time": "2003-12", "title": "RSS订阅开通", "description": "获得第一批订阅者"},
        {"time": "2004-03", "title": "加入博客联盟", "description": "认识第一个博友星光博客"},
        {"time": "2004-05", "title": "第一次文章收藏", "description": "获得第一篇文章收藏"},
        {"time": "2004-09", "title": "第一笔广告收入", "description": "收到第一笔广告收益12.5元"},
        {"time": "2005-01", "title": "友链交换", "description": "与星光博客交换友链"},
        {"time": "2005-08", "title": "网站备案完成", "description": "响应国家备案制度"},
        {"time": "2005-11", "title": "博客优秀大奖提名", "description": "获得提名，称号[博客新星]"},
    ]

func _build_scroll_text() -> void:
    scroll_label.clear()

    scroll_label.push_center()
    scroll_label.push_bold()
    scroll_label.push_font_size(24)
    scroll_label.add_text(review_title)
    scroll_label.pop()
    scroll_label.pop()
    scroll_label.pop()
    scroll_label.add_text("\n")
    scroll_label.push_center()
    scroll_label.add_text("%d - %d" % [from_year, to_year])
    scroll_label.pop()

    scroll_label.add_text("\n\n")

    for e in review_events:
        var time = e.get("time", "")
        var title = e.get("title", "")
        var desc = e.get("description", "")

        scroll_label.push_bold()
        scroll_label.add_text("%s  %s" % [time, title])
        scroll_label.pop()
        scroll_label.add_text("\n")

        if not desc.is_empty():
            scroll_label.add_text("  %s\n" % desc)

        scroll_label.add_text("\n")

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

func back_to_main() -> void:
    #Utils.goto_scene(MAIN_SCENE_PATH)
    
    pass 

func get_review_events() -> Array[Dictionary]:
    return review_events

func get_review_title() -> String:
    return review_title

func get_year_range_text() -> String:
    if from_year > 0 and to_year > 0:
        return "%d - %d" % [from_year, to_year]
    return ""
