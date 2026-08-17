extends Control
## 提示系统预览场景
## F6 运行本场景即可预览横幅提示效果，不跳转主菜单。
## 左侧按钮可分别触发各类事件；"自动演示"按真实时序依次弹出。

var _auto_idx := 0
var _auto_seq: Array[Dictionary] = []


func _ready() -> void:
    for i in range(1, 6):
        _add_mock_skill(i)


func _add_mock_skill(i: int) -> void:
    var pb: ProgressBar = get_node_or_null("SkillPanel/Grid/Skill%d/Bar" % i)
    if pb == null:
        return
    var vals: Array = [35.0, 58.0, 62.4, 80.0, 12.0]
    var val: float = vals[i - 1]
    pb.max_value = 100
    pb.value = val
    var lb: Label = pb.get_node_or_null("Num")
    if lb:
        lb.text = _fmt(val)


func _fmt(v: float) -> String:
    var s := "%.1f" % v
    return s.substr(0, s.length() - 2) if s.ends_with(".0") else s


func _on_level_btn() -> void:
    $Toast.add_toast("等级提升", "恭喜你升级到 Lv.57！", $Toast.Tone.LEVELUP)


func _on_title_btn() -> void:
    $Toast.add_toast("✨ 头衔晋升", "段位提升到 [名扬四海]", $Toast.Tone.TITLE)


func _on_skill_item_btn() -> void:
    $Toast.add_toast("🎉 技能进阶", "写作新手 → 创作达人", $Toast.Tone.SUCCESS)


func _on_skill_value_btn() -> void:
    $Toast.add_toast("成长", "编程能力提升至 62.4", $Toast.Tone.SUCCESS)


func _on_no_stamina_btn() -> void:
    $Toast.add_toast("体力不足", "无法进行学习！需要 10 体力", $Toast.Tone.DANGER)


func _on_info_btn() -> void:
    $Toast.add_toast("系统通知", "本月广告收入已结算：¥1,280.00", $Toast.Tone.INFO)


func _on_burst_btn() -> void:
    $Toast.add_toast("等级提升", "恭喜你升级到 Lv.61！", $Toast.Tone.LEVELUP)
    $Toast.add_toast("✨ 头衔晋升", "段位提升到 [名扬四海]", $Toast.Tone.TITLE)
    $Toast.add_toast("🎉 技能进阶", "文学入门 → 写作新手", $Toast.Tone.SUCCESS)
    # 以下两条同 key（"merge"）：不会新增横幅，而是把上一条改写成"技能成长 62.4"
    $Toast.add_toast("技能成长", "写作能力提升至 62.2", $Toast.Tone.SUCCESS, "merge")
    $Toast.add_toast("技能成长", "写作能力提升至 62.4", $Toast.Tone.SUCCESS, "merge")
    $Toast.add_toast("体力不足", "无法进行安全排险！需要 12 体力", $Toast.Tone.DANGER)


func _on_auto_btn() -> void:
    if not _auto_seq.is_empty():
        return
    _auto_seq = [
        {"t": $Toast.Tone.INFO, "title": "系统通知", "content": "新的一天开始了……", "delay": 0.2},
        {"t": $Toast.Tone.SUCCESS, "title": "成长", "content": "写作能力提升至 61.5", "delay": 1.0},
        {"t": $Toast.Tone.LEVELUP, "title": "等级提升", "content": "恭喜你升级到 Lv.58！", "delay": 1.4},
        {"t": $Toast.Tone.TITLE, "title": "✨ 头衔晋升", "content": "段位提升到 [锋芒毕露]", "delay": 1.6},
        {"t": $Toast.Tone.SUCCESS, "title": "🎉 技能进阶", "content": "写作新手 → 创作达人", "delay": 1.8},
        {"t": $Toast.Tone.DANGER, "title": "体力不足", "content": "无法进行学习！需要 10 体力", "delay": 2.2},
    ]
    _price_next()


func _price_next() -> void:
    if _auto_idx >= _auto_seq.size():
        _auto_idx = 0
        _auto_seq = []
        return
    var data: Dictionary = _auto_seq[_auto_idx]
    _auto_idx += 1
    $Toast.add_toast(data.title, data.content, data.t)
    if _auto_idx < _auto_seq.size():
        var wait := create_tween()
        wait.tween_interval(data.delay)
        wait.tween_callback(_price_next)


func _on_reset_btn() -> void:
    for child in $Toast/Box.get_children():
        child.queue_free()
