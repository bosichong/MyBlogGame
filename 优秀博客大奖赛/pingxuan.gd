extends Node2D

const SCENE_PATH = "res://scenes/main.tscn"

const SUBTITLES = {
    1: [
        "评选开始了。",
        "评审团收到了来自中文博客圈数百份提名。",
        "这是博客联盟第一次举办这样的评选。三年来，无数博主在网络上坚持记录。",
        "评审团在 200+ 提名中，将遴选出最终的获奖者。",
        "最终结果将于 12 月颁奖典礼上正式公布。",
    ],
    2: [
        "评选开始了。",
        "评审团收到了来自中文博客圈数百份提名。",
        "八年间，博客圈从论坛时代走入社交媒体时代，坚持下来的博主越来越少。",
        "评审团从 200+ 提名中，将评选出优秀的入围者。",
        "最终结果将于 12 月颁奖典礼上正式公布。",
    ],
    3: [
        "评选开始了。",
        "评审团收到了来自中文博客圈数百份提名。",
        "微博、微信、短视频轮番冲击，但独立博客依然有自己的阵地。",
        "评审团从 200+ 提名中，选出 10 位入围者，并从中评选出 6 位本届优秀博客大奖得主。",
        "最终结果将于 12 月颁奖典礼上正式公布。",
    ],
    4: [
        "评选开始了。",
        "评审团收到了来自中文博客圈数百份提名。",
        "今年的竞争格外激烈，评审团在认真审阅每一份博客。",
        "每一位参赛者都在用内容证明自己的价值。",
        "最终结果将于 12 月颁奖典礼上正式公布。",
    ],
    5: [
        "评选开始了。",
        "评审团收到了来自中文博客圈数百份提名。",
        "评审团内部在激烈讨论：什么样的博客才能代表这个时代的独立精神？",
        "最终的获奖名单即将揭晓。",
        "最终结果将于 12 月颁奖典礼上正式公布。",
    ],
}


func _ready() -> void:
    var ordinal = 1
    if TaskManager and TaskManager.pending_scene_params.has("notification_ordinal"):
        ordinal = TaskManager.pending_scene_params.notification_ordinal
        TaskManager.pending_scene_params.erase("notification_ordinal")

    var lines = SUBTITLES.get(ordinal, SUBTITLES[1])
    for i in range(5):
        var label: RichTextLabel = get_node(str("%02d" % (i + 1)))
        if label:
            label.text = lines[i]


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
    if anim_name == "main":
        TimerManager.start_timer()
        Utils.goto_scene(SCENE_PATH)
