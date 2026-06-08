extends Node2D

const MAIN_SCENE_PATH = "res://scenes/main.tscn"

var review_events: Array[Dictionary] = []
var review_title: String = ""
var from_year: int = 0
var to_year: int = 0

@onready var scroll_label: RichTextLabel = $Clipper/ScrollLabel
@onready var back_button: Button = $BackButton

func _ready() -> void:
    if TaskManager:
        var params = TaskManager.pending_scene_params
        from_year = params.get("from_year", 0)
        to_year = params.get("to_year", 0)
        review_title = params.get("title", "回忆录")
        TaskManager.pending_scene_params = {}

    if GDManager and from_year > 0 and to_year > 0:
        review_events = GDManager.get_blog_archive().get_events_by_year_range(from_year, to_year)

    _build_scroll_text()
    _start_scroll()

func _build_scroll_text() -> void:
    var text = "[center][b]%s[/b]\n%d - %d[/center]\n\n" % [review_title, from_year, to_year]

    if review_events.is_empty():
        text += "[center]暂无记录[/center]"
    else:
        for e in review_events:
            var time = e.get("time", "")
            var title = e.get("title", "")
            var desc = e.get("description", "")
            text += "[b]%s[/b]  %s\n" % [time, title]
            if not desc.is_empty():
                text += "  %s\n" % desc
            text += "\n"

    scroll_label.text = text

func _start_scroll() -> void:
    await get_tree().process_frame
    await get_tree().process_frame

    var viewport_h = get_viewport_rect().size.y
    var text_h = scroll_label.get_content_height()
    if text_h <= 0:
        text_h = 500
    var start_y = viewport_h + 50
    var end_y = -text_h - 50
    var duration = (start_y - end_y) / 35.0

    scroll_label.position.y = start_y
    var tween = create_tween()
    tween.tween_property(scroll_label, "position:y", end_y, duration)
    tween.set_ease(Tween.EASE_LINEAR)
    tween.set_trans(Tween.TRANS_LINEAR)

func back_to_main() -> void:
    Utils.goto_scene(MAIN_SCENE_PATH)

func get_review_events() -> Array[Dictionary]:
    return review_events

func get_review_title() -> String:
    return review_title

func get_year_range_text() -> String:
    if from_year > 0 and to_year > 0:
        return "%d - %d" % [from_year, to_year]
    return ""
