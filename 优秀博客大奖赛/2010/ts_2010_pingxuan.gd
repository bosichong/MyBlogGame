extends Node2D
const SCENE_PATH = "res://scenes/main.tscn"

## 江湖榜取前 N 名 + 玩家博客名（玩家已在前 N 时自动去重）
const TOP_N := 19
## 每行显示的入围者数
const COLS_PER_ROW := 4


func _ready() -> void:
    _update_shortlist_label()


func _update_shortlist_label() -> void:
    var label: RichTextLabel = get_node_or_null("入围名单")
    if not label:
        return

    var player_name: String = str(Blogger.blog_data.get("blog_name", "我的博客"))

    # 抽取江湖榜前 19 名
    var entries: Array = []
    if Lm != null and not Lm.jhph.is_empty():
        var top_n: int = min(TOP_N, Lm.jhph.size())
        for i in range(top_n):
            var name: String = str(Lm.jhph[i].get("blog_name", "未知博主"))
            if name != "" and not entries.has(name):
                entries.append(name)

    # 玩家补充进名单
    if not entries.has(player_name):
        entries.append(player_name)

    # 构建 BBCode 文本（每行 4 个）
    var lines: PackedStringArray = []
    lines.append("[b]「第 2 届中文优秀博客大奖」参赛博客（部分）[/b]")
    lines.append("")

    var row_parts: PackedStringArray = []
    for i in range(entries.size()):
        var rank: int = i + 1
        var entry: String = entries[i]
        var cell: String = "%02d. %s" % [rank, entry]
        row_parts.append(cell)

        if row_parts.size() == COLS_PER_ROW or i == entries.size() - 1:
            lines.append("    ".join(row_parts))
            row_parts = []

    label.text = "\n".join(lines)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
    if anim_name == "main":
        TimerManager.start_timer()
        Utils.goto_scene(SCENE_PATH)
