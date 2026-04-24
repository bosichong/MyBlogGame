extends Node

## 学习技能汇总（从独立文件加载）

var items: Array = []

func _init():
    _load_all_skills()

func _load_all_skills():
    var dir = DirAccess.open("res://data/skills/")
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if file_name.ends_with(".gd") and file_name != "learning_skills.gd":
                var full_path = "res://data/skills/" + file_name
                var script = load(full_path)
                if script:
                    var instance = script.new()
                    if "item" in instance:
                        items.append(instance.get("item"))
            file_name = dir.get_next()
        dir.list_dir_end()
    
    print("[LearningSkills] 加载了 ", items.size(), " 个技能")