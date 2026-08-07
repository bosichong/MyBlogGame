extends Node

## 对话角色表
## 定义所有可在多人对话中出现的角色；当前无头像，用色块兜底

var characters = [
    {
        "name": "player",
        "display": "我",
        "color": Color(0.43, 0.86, 0.54),
        "side": "right",
        "avatar": "res://assets/npc_tm/element_18.png",
        "source": "blogger",      # 取用玩家（Blogger）数据
    },
    {
        "name": "莫比乌斯",
        "display": "莫比乌斯",
        "color": Color(0.49, 0.61, 1.0),
        "source": "lm_members#1", # 莫比乌斯（有头像）
    },
    {
        "name": "黑客O",
        "display": "Obaby",
        "color": Color(1.0, 0.61, 0.42),
        "source": "lm_members#2",
    },
    {
        "name": "孤斗",
        "display": "孤斗",
        "color": Color(0.9, 0.75, 0.3),
        "source": "lm_members#3",
    },
]

## 按名字查找角色，未找到返回空字典
func get_character(char_name: String) -> Dictionary:
    for c in characters:
        if c.get("name", "") == char_name:
            return c
    return {}

## 解析角色来源（有则取，无则保持色块配置）
## - source == "blogger"         → 用玩家 Blogger 的 blog_author 作显示名
## - source == "lm_members#N"    → 取联盟成员列表 id==N 的 blog_author / avatar
func resolve_character(char_name: String, blogger_author: String = "", lm_members: Array = []) -> Dictionary:
    var data := get_character(char_name).duplicate()
    var source := str(data.get("source", ""))
    if source == "blogger":
        if blogger_author != "":
            data["display"] = blogger_author
    elif source.begins_with("lm_members#"):
        var idx := int(source.get_slice("#", 1))
        for m in lm_members:
            if int(m.get("id", 0)) == idx:
                if m.has("blog_author") and str(m["blog_author"]) != "":
                    data["display"] = str(m["blog_author"])
                if m.has("avatar") and str(m["avatar"]) != "":
                    data["avatar"] = str(m["avatar"])
                break
    return data
