extends Node

## 休闲娱乐汇总（从独立文件加载）

var items: Array = []

func _init():
    _load_all_recreation()

func _load_all_recreation():
    var dir = DirAccess.open("res://data/recreation/")
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if file_name.ends_with(".gd") and file_name != "recreation.gd":
                var full_path = "res://data/recreation/" + file_name
                var script = load(full_path)
                if script:
                    var instance = script.new()
                    if "item" in instance:
                        items.append(instance.get("item"))
            file_name = dir.get_next()
        dir.list_dir_end()
    
    print("[Recreation] 加载了 ", items.size(), " 个活动")