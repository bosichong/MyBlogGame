extends Node

var jhph = []
var jhph_js = []
var jhph_wx = []
var jhph_ys = []
var jhph_jz = []

var is_join = false

var donate_data = []
var donate_max = 100
var donate_min = 50
var player_donate = 0.0

var donate_ids = [1,2,3,4]

func _get_league_data():
    return GDManager.get_league() if GDManager else null

func _ready() -> void:
    _init_league_members()
    up_jhph()

func _init_league_members():
    var league = _get_league_data()
    if league:
        if league.lm_members.is_empty():
            league.init_lm_members()
        _update_rankings()

func _update_rankings():
    var league = _get_league_data()
    if league:
        jhph = sort_by_lv(0)
        jhph_wx = sort_by_lv(2)
        jhph_js = sort_by_lv(3)
        jhph_ys = sort_by_lv(4)

func up_jhph():
    _update_rankings()
    donate_lm()
    jhph_jz = process_donation_data(donate_data)

func join_lm():
    var league = _get_league_data()
    if not league:
        return

    var lm_player = {
        "id": 888,
        "blog_name": Blogger.blog_data.blog_name,
        "blog_author": Blogger.blog_data.blog_author,
        "lv": Blogger.level,
        "type": convert_blog_type_to_lm_type(Blogger.myblog_type),
        "quality": GDManager.get_blogger().last_post_quality if GDManager else 0,
        "connectivity": true,
        "is_friend_link": false,
        "add_date": "",
        "last_check": ""
    }

    var existing = league.get_member(888)
    if existing.is_empty():
        league.lm_members.append(lm_player)
    else:
        for key in lm_player:
            existing[key] = lm_player[key]

    is_join = true

    var fl_manager = GDManager.get_friend_link_manager() if GDManager else null
    if fl_manager:
        fl_manager.on_league_joined()

func exit_lm():
    var league = _get_league_data()
    if league:
        league.remove_member_by_id(888)
    is_join = false
    
    var fl_manager = GDManager.get_friend_link_manager() if GDManager else null
    if fl_manager:
        fl_manager._data.is_league_member = false

func donate_lm():
    for id in donate_ids:
        var m = randi_range(10, donate_max)
        donate_data.insert(0, [id, m])

    var tm_ids = []
    for i in range(10):
        tm_ids.insert(0, randi_range(4, 99))
    for id in tm_ids:
        var m = randi_range(10, donate_min)
        donate_data.insert(0, [id, m])

func quarter_activities():
    var league = _get_league_data()
    if not league:
        return

    for blog in league.lm_members:
        if blog.get("id", 0) <= 4:
            blog["lv"] = blog.get("lv", 1) + 1
            blog["quality"] = blog.get("quality", 1) + 1
        elif blog.get("id", 0) == 888:
            pass
        else:
            blog["lv"] = increase_level(blog.get("lv", 1), 1)
            blog["quality"] = increase_level(blog.get("quality", 1), 1)

func increase_level(lv: int, k: int) -> int:
    if k < 1:
        return lv
    var boost: int = randi_range(0, 1)
    return lv + boost

func add_level(lv: int, k: int) -> int:
    if k < 1:
        return lv
    return lv + k

func sort_by_lv(type: int = 0) -> Array:
    var league = _get_league_data()
    if not league:
        return []

    var filtered_list = []
    for item in league.lm_members:
        if type == 0 or item.get("type", 0) == type:
            var copy = {}
            for key in item:
                copy[key] = item[key]
            filtered_list.append(copy)

    filtered_list.sort_custom(compare_by_lv)
    return filtered_list

func compare_by_lv(a: Dictionary, b: Dictionary) -> bool:
    return a.get("lv", 0) > b.get("lv", 0)

func sort_by_quality(type: int = 0) -> Array:
    var league = _get_league_data()
    if not league:
        return []

    var filtered_list = []
    for item in league.lm_members:
        if type == 0 or item.get("type", 0) == type:
            var copy = {}
            for key in item:
                copy[key] = item[key]
            filtered_list.append(copy)

    filtered_list.sort_custom(compare_by_quality)
    return filtered_list

func compare_by_quality(a: Dictionary, b: Dictionary) -> bool:
    return a.get("quality", 0) > b.get("quality", 0)

func find_by_id(target_id):
    var league = _get_league_data()
    if league:
        return league.get_member(target_id)
    return null

func remove_by_id(target_id):
    var league = _get_league_data()
    if league:
        return league.remove_member_by_id(target_id)
    return false

func process_donation_data(donate_data: Array) -> Array:
    var sum_dict = {}

    for item in donate_data:
        sum_dict[item[0]] = sum_dict.get(item[0], 0) + item[1]

    var result = []
    for id in sum_dict.keys():
        result.append([id, sum_dict[id]])

    result.sort_custom(func(a, b): return a[1] > b[1])
    return result

func get_index_by_id(target_id):
    var league = _get_league_data()
    if league:
        for i in range(league.lm_members.size()):
            if league.lm_members[i].get("id", 0) == target_id:
                return i
    return -1

func player_donation_data(m: float) -> Dictionary:
    if m > 0:
        player_donate += m
        donate_data.insert(0, [888, m])
        jhph_jz = process_donation_data(donate_data)
        return {
            "success": true,
            "message": "捐赠成功！捐赠金额: %.2f，累计捐赠: %.2f" % [m, player_donate],
            "amount": m,
            "total": player_donate
        }
    else:
        return {
            "success": false,
            "message": "捐赠失败！捐赠金额必须大于0",
            "amount": m,
            "total": player_donate
        }

func convert_blog_type_to_lm_type(blog_type: int) -> int:
    match blog_type:
        0: return 2
        1: return 3
        2: return 1
        _: return 1