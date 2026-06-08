extends Node2D

const MAIN_SCENE_PATH = "res://scenes/main.tscn"

var review_events: Array[Dictionary] = []
var review_title: String = ""
var from_year: int = 0
var to_year: int = 0

func _ready() -> void:
    if TaskManager:
        var params = TaskManager.pending_scene_params
        from_year = params.get("from_year", 0)
        to_year = params.get("to_year", 0)
        review_title = params.get("title", "回忆录")
        TaskManager.pending_scene_params = {}

    if GDManager and from_year > 0 and to_year > 0:
        review_events = GDManager.get_blog_archive().get_events_by_year_range(from_year, to_year)

func get_review_events() -> Array[Dictionary]:
    return review_events

func get_review_title() -> String:
    return review_title

func get_year_range_text() -> String:
    if from_year > 0 and to_year > 0:
        return "%d - %d" % [from_year, to_year]
    return ""

func back_to_main() -> void:
    Utils.goto_scene(MAIN_SCENE_PATH)
