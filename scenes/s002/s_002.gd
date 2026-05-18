extends Node2D
const SCENE_PATH = "res://scenes/s003/s_003.tscn"
@onready var blogname = $Control/VBoxContainer/HBoxContainer/bname
@onready var username = $Control/VBoxContainer/HBoxContainer2/uname
@onready var url: LineEdit = $Control/VBoxContainer/HBoxContainer3/url

var current_button_group: ButtonGroup

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass

func _on_startgame_pressed() -> void:
    Blogger.blog_data.blog_author = username
    Blogger.blog_data.blog_name = username
    Blogger.blog_data.blog_url = url
    Utils.goto_scene(SCENE_PATH)
    
    
