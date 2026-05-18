## 评论模板数据
## 提供友链博主的评论模板
class_name CommentTemplatesData

var league_templates_by_type: Dictionary = {
    "技术类": [
        "这篇文章对 {topic} 的讲解很透彻，受益匪浅",
        "技术分析很到位，学到了",
        "原理讲得很清晰",
    ],
    "教程类": [
        "跟着步骤操作成功，感谢分享",
        "讲得很细，新手也能看懂",
        "按教程做了一遍，效果很好",
    ],
    "文学类": [
        "文字优美，读完内心平静了许多",
        "意境很好，有收获",
        "写得真有感觉",
    ],
    "综合类": [
        "内容丰富，干货满满",
        "观点独到，学到了很多",
        "写得真好，期待更多",
    ],
}

var friendlink_templates: Array = [
    "老朋友的文章一如既往精彩！",
    "恭喜完成这个系列，写得很好。",
    "我们已经是友链了，继续合作吧。",
    "最近在关注你的更新，都很不错。",
    "内容越来越丰富了，加油！",
]

func get_templates() -> Dictionary:
    return {
        "league_by_type": league_templates_by_type,
        "friendlink": friendlink_templates,
    }

func get_league_templates_by_type(article_type: String) -> Array:
    return league_templates_by_type.get(article_type, league_templates_by_type.get("综合类", []))

func get_friendlink_templates() -> Array:
    return friendlink_templates

func get_random_league_template(article_type: String) -> String:
    var templates = get_league_templates_by_type(article_type)
    if templates.is_empty():
        return ""
    return templates[randi() % templates.size()]

func get_random_friendlink_template() -> String:
    if friendlink_templates.is_empty():
        return ""
    return friendlink_templates[randi() % friendlink_templates.size()]