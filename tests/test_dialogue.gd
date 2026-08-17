extends SceneTree

# 独立测试脚本：对话系统数据与逻辑
 # 验证：数据加载、分支跳转、标签查找、角色解析

var failures := 0

func _init():
    print("\n" + "=".repeat(50))
    print("💬 对话系统测试")
    print("=".repeat(50))

    _test_character_data()
    _test_source_resolution()
    _test_dialogue_load()
    _test_line_structure()
    _test_branch_jump()
    _test_branch_termination()
    _test_choice_blocking()

    print("\n" + "=".repeat(50))
    if failures == 0:
        print("✅ 所有测试通过！对话系统数据正常。")
    else:
        print("❌ %d 项测试失败！" % failures)
    print("=".repeat(50) + "\n")
    quit(failures)

func _check(cond: bool, msg: String):
    if cond:
        print("  ✓ %s" % msg)
    else:
        failures += 1
        print("  ✗ %s" % msg)

# 测试1：角色表加载
func _test_character_data():
    print("\n【测试1】角色表")
    var chars = load("res://data/dialogue_characters.gd").new()
    _check(chars.characters.size() >= 3, "角色表含 player/莫比乌斯/黑客O")
    _check(chars.get_character("player").get("display", "") == "我", "player 显示名正确")
    _check(chars.get_character("莫比乌斯").has("color"), "莫比乌斯 有色块颜色")
    _check(chars.get_character("nobody").is_empty(), "未知名返回空字典")

# 测试2：来源解析（有则取，无则保留色块）
func _test_source_resolution():
    print("\n【测试2】来源解析")
    var chars = load("res://data/dialogue_characters.gd").new()
    var lm_members = load("res://data/lm_members.gd").new().lm_list

    # lm_members#1 = 莫比乌斯（有头像）
    var mobius = chars.resolve_character("莫比乌斯", "", lm_members)
    _check(mobius.get("display", "") == "莫比乌斯", "莫比乌斯 → 联盟成员 blog_author")
    _check(str(mobius.get("avatar", "")) != "", "莫比乌斯 → 联盟成员 avatar 有值")
    _check(mobius.has("color"), "莫比乌斯 → 保留色块颜色")

    # lm_members#2 = 黑客O（有头像）
    var obaby = chars.resolve_character("黑客O", "", lm_members)
    _check(obaby.get("display", "") == "黑客O", "黑客O → 联盟成员 blog_author")
    _check(str(obaby.get("avatar", "")) != "", "黑客O → 联盟成员 avatar 有值")

    # blogger → 用玩家 blog_author
    var player = chars.resolve_character("player", "J.sky", lm_members)
    _check(player.get("display", "") == "J.sky", "player → 玩家 blog_author")
    _check(player.get("side", "") == "right", "player → 右侧布局")

    # 未知名 → 空字典
    _check(chars.resolve_character("nobody", "", lm_members).is_empty(), "未知名 → 空字典")

# 测试3：对白数据加载
func _test_dialogue_load():
    print("\n【测试2】对白数据")
    var data = load("res://data/dialogue/example.gd").new()
    _check(data.dialogue.get("id", "") == "example", "对白 id 正确")
    _check(data.dialogue.get("auto_interval", 0) == 3.0, "默认自动间隔 3s")
    _check(data.dialogue["lines"].size() == 9, "示例含 9 行")
    _check(data.dialogue["lines"][0].get("speaker", "") == "莫比乌斯", "首行说话人正确")

# 测试3：行结构与 choices
func _test_line_structure():
    print("\n【测试3】行结构与选项")
    var data = load("res://data/dialogue/example.gd").new()
    var lines = data.dialogue["lines"]
    var choice_line = {}
    var labels := []
    for line in lines:
        if line.has("choices"):
            choice_line = line
        if line.has("label"):
            labels.append(line["label"])
    _check(not choice_line.is_empty(), "存在带选项的行")
    _check(choice_line["choices"].size() == 2, "选项数 = 2")
    _check(("join" in labels) and ("decline" in labels), "存在 join/decline 标签")

# 测试4：分支跳转（通过 next 标签找到目标行）
func _test_branch_jump():
    print("\n【测试4】分支跳转")
    var data = load("res://data/dialogue/example.gd").new()
    var lines = data.dialogue["lines"]
    var next = ""
    for line in lines:
        if line.has("choices"):
            next = str(line["choices"][0]["next"])
    var join_index = -1
    for i in lines.size():
        if str(lines[i].get("label", "")) == next:
            join_index = i
    _check(join_index >= 0, "join 标签目标行存在")
    _check(join_index > 2, "join 在选项行之后（向前跳转）")

# 测试5：分支终止（选择一项后不会掉进另一分支）
func _test_branch_termination():
    print("\n【测试5】分支终止")
    var data = load("res://data/dialogue/example.gd").new()
    var lines = data.dialogue["lines"]

    # 模拟从 join 分支起点顺序推进，检查是否会进入 decline 分支
    var joined_texts := []
    var idx := -1
    for i in lines.size():
        if str(lines[i].get("label", "")) == "join":
            idx = i
            break
    var reached_end := false
    while idx >= 0 and idx < lines.size():
        var line = lines[idx]
        joined_texts.append(str(line.get("text", "")))
        if line.has("end"):
            reached_end = true
            break
        if line.has("goto"):
            idx = _find_index_by_label(lines, str(line["goto"]))
            continue
        idx += 1
    _check(reached_end, "join 分支以 end 终止")
    var leaked := false
    for t in joined_texts:
        if "再考虑" in t:
            leaked = true
    _check(not leaked, "join 分支未泄漏 decline 对白")

    # decline 分支同理
    var declined_texts := []
    idx = -1
    for i in lines.size():
        if str(lines[i].get("label", "")) == "decline":
            idx = i
            break
    reached_end = false
    while idx >= 0 and idx < lines.size():
        var line = lines[idx]
        declined_texts.append(str(line.get("text", "")))
        if line.has("end"):
            reached_end = true
            break
        if line.has("goto"):
            idx = _find_index_by_label(lines, str(line["goto"]))
            continue
        idx += 1
    _check(reached_end, "decline 分支以 end 终止")
    leaked = false
    for t in declined_texts:
        if "求之不得" in t:
            leaked = true
    _check(not leaked, "decline 分支未泄漏 join 对白")

func _find_index_by_label(lines: Array, label: String) -> int:
    for i in lines.size():
        if str(lines[i].get("label", "")) == label:
            return i
    return -1

# 测试6：选项行不应自动跳转（无 duration/auto 字段可触发；逻辑上由场景控制）
func _test_choice_blocking():
    print("\n【测试6】选项行不自动跳转标记")
    var data = load("res://data/dialogue/example.gd").new()
    for line in data.dialogue["lines"]:
        if line.has("choices"):
            _check(line.has("label") == false, "选项行自身无 label（避免冲突）")
            _check(not line.has("duration"), "选项行无 duration（强制手动选择）")
            break
