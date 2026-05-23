extends Node2D
const SCENE_PATH = "res://scenes/s003/s_003.tscn"
@onready var blogname = $Control/VBoxContainer/HBoxContainer/bname
@onready var username = $Control/VBoxContainer/HBoxContainer2/uname
@onready var url: LineEdit = $Control/VBoxContainer/HBoxContainer3/url

var current_button_group: ButtonGroup

func _ready() -> void:
    pass

func _on_startgame_pressed() -> void:
    var blogger = GDManager.get_blogger()
    if blogger:
        blogger.blog_name = blogname.text if blogname.text != "" else "我的博客"
        blogger.blog_author = username.text if username.text != "" else "匿名"
        blogger.blog_url = url.text if url.text != "" else "suiyan.cc"
    Utils.goto_scene(SCENE_PATH)
    
    
