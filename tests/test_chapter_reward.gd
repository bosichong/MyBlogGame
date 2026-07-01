extends Control

func _ready():
    for btn in $VBoxContainer/Buttons.get_children():
        btn.pressed.connect(_on_chapter_btn.bind(int(btn.name)))

func _on_chapter_btn(chapter: int):
    var names = {
        1: "第一章：博客启蒙期（2002-2005）",
        2: "第二章：博客黄金期（2005-2010）",
        3: "第三章：博客转型期（2010-2015）",
        4: "第四章：博客挑战期（2015-2020）",
        5: "第五章：博客重塑期（2020-2025）",
    }
    var rewards = ["写作 +5", "技术 +5", "等级 +5", "金钱 +1000"]
    var popup = preload("res://milestones/chapter_reward.tscn").instantiate()
    popup.setup(names[chapter], rewards)
    add_child(popup)
