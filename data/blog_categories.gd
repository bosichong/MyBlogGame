extends Node

## 博客分类汇总（从独立文件加载）
## 这个文件汇总所有独立配置的文件

var categories: Array = []

func _init():
    _load_all_categories()

func _load_all_categories():
    var dir = DirAccess.open("res://data/blog_categories/")
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if file_name.ends_with(".gd") and file_name != "blog_categories.gd":
                var full_path = "res://data/blog_categories/" + file_name
                var script = load(full_path)
                if script:
                    var instance = script.new()
                    if "item" in instance:
                        categories.append(instance.get("item"))
            file_name = dir.get_next()
        dir.list_dir_end()
    
    print("[BlogCategories] 加载了 ", categories.size(), " 个分类")