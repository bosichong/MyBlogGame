## 友链管理器
## 负责友链的日常管理和维护日程执行
class_name FriendLinkManager
extends Node

var _data: FriendLinkData:
    get: return GDManager.get_friend_link()

signal link_added(link_data: Dictionary)
signal link_removed(member_id: int)
signal request_processed(member_id: int, approved: bool)
signal maintenance_completed(result: Dictionary)
signal request_received(request_data: Dictionary)
signal apply_result_received(result: Dictionary)

func _get_league_data():
    return GDManager.get_league() if GDManager else null

func get_links() -> Array[Dictionary]:
    var league = _get_league_data()
    if league:
        return league.get_friend_links()
    return []

func get_active_links() -> Array[Dictionary]:
    return get_links()

func get_pending_requests() -> Array[Dictionary]:
    return _data.pending_requests

func get_pending_count() -> int:
    return _data.get_pending_count()

func delete_link(member_id: int) -> bool:
    var league = _get_league_data()
    if league:
        league.mark_friend_link(member_id, false)
        emit_signal("link_removed", member_id)
        return true
    return false

func apply_for_link(member_id: int) -> Dictionary:
    var blogger = GDManager.get_blogger()

    if blogger.stamina < 5:
        return {"success": false, "reason": "体力不足，需要5点体力"}

    if _data.has_link(member_id):
        return {"success": false, "reason": "已经是友链"}

    for req in _data.pending_requests:
        if req.get("member_id") == member_id:
            return {"success": false, "reason": "已有待处理申请"}

    blogger.stamina -= 5

    var wait_days = randi_range(3, 7)
    var game_time = GDManager.get_time()
    var league = _get_league_data()
    var level = 1
    if league:
        level = league.get_member_level(member_id)

    var request_data = {
        "member_id": member_id,
        "request_date": game_time.current_date_str if game_time else Time.get_date_string_from_system(),
        "level": level,
        "wait_days": wait_days,
        "apply_date": game_time.current_date_str if game_time else Time.get_date_string_from_system(),
        "apply_game_year": game_time.current_year if game_time else 0,
        "apply_game_month": game_time.current_month if game_time else 0,
        "apply_game_week": game_time.current_week if game_time else 1,
        "apply_game_day": game_time.current_day if game_time else 0,
    }
    _data.add_pending_request(request_data)

    return {"success": true, "message": "申请已发送，预计%s天后获得结果" % wait_days}

func get_auto_settings() -> Dictionary:
    return _data.get_auto_settings()

func set_auto_settings(settings: Dictionary) -> void:
    _data.set_auto_settings(settings)

func do_maintenance() -> Dictionary:
    var blogger = GDManager.get_blogger()

    if blogger.stamina < 5:
        return {"success": false, "reason": "体力不足"}

    blogger.stamina -= 5

    var result = {
        "success": true,
        "processed_requests": 0,
        "approved_requests": 0,
        "rejected_requests": 0,
        "checked_links": 0,
        "removed_invalid": 0,
        "removed_spam": 0,
        "messages": [],
    }

    var settings = _data.get_auto_settings()
    var league = _get_league_data()

    var pending = _data.pending_requests.duplicate()
    for req in pending:
        var member_id = req.get("member_id")
        var request_level = req.get("level", 1)
        var is_passive = req.get("is_passive", false)

        var should_approve = true
        var min_level_threshold = settings.get("min_level_diff", 5)
        print("[友链审核] request_level=%d, min_level_threshold=%d" % [request_level, min_level_threshold])
        if request_level < min_level_threshold:
            should_approve = false

        if should_approve and league:
            league.mark_friend_link(member_id, true)
            result["approved_requests"] += 1
            if is_passive:
                result["messages"].append("通过了被动申请：等级%d" % request_level)
            else:
                result["messages"].append("通过了等级%d的友链申请" % request_level)
        else:
            result["rejected_requests"] += 1
            if is_passive:
                result["messages"].append("拒绝了被动申请：等级%d（等级不足）" % request_level)
            else:
                result["messages"].append("拒绝了等级%d的友链申请" % request_level)

        _data.remove_pending_request(member_id)
        result["processed_requests"] += 1
        emit_signal("request_processed", member_id, should_approve)

    _data.update_maintenance_date()

    emit_signal("maintenance_completed", result)
    return result

func get_total_bonus() -> Dictionary:
    return {
        "views_bonus": _data.get_views_bonus(),
        "seo_bonus": _data.get_seo_bonus(),
    }

func get_maintenance_debt() -> Dictionary:
    var days = _data.get_days_since_maintenance()
    var pending = _data.get_pending_count()

    var status = "normal"
    if days >= 21:
        status = "critical"
    elif days >= 14:
        status = "severe"
    elif days >= 7:
        status = "warning"

    return {
        "days_since_maintenance": days,
        "pending_count": pending,
        "status": status,
    }

func on_league_joined() -> void:
    _data.is_league_member = true

func get_available_members() -> Array[Dictionary]:
    var league = _get_league_data()
    if not league:
        return []

    var available: Array[Dictionary] = []
    var active_ids: Array = []
    var pending_ids: Array = []

    for link in get_links():
        active_ids.append(int(link.get("id")))

    for req in _data.pending_requests:
        pending_ids.append(int(req.get("member_id")))

    for member in league.lm_members:
        var id = int(member.get("id"))
        if id not in active_ids and id not in pending_ids:
            available.append(member)

    return available

func get_member_by_id(member_id: int) -> Dictionary:
    var league = _get_league_data()
    if league:
        return league.get_member(member_id)
    return {"id": member_id, "blog_name": "未知", "url": "", "lv": 1}

func get_all_members() -> Array[Dictionary]:
    var league = _get_league_data()
    if league:
        return league.lm_members
    return []

func is_league_member() -> bool:
    return _data.is_league_member

func calculate_success_rate(target_level: int) -> float:
    var blogger = GDManager.get_blogger()
    if not blogger:
        return 0.5

    var player_level = blogger.level
    var level_diff = target_level - player_level

    if level_diff <= -10:
        return 0.95
    elif level_diff <= -5:
        return 0.85
    elif level_diff <= 0:
        return 0.75
    elif level_diff <= 5:
        return 0.55
    elif level_diff <= 10:
        return 0.35
    else:
        return 0.20

func get_success_rate_description(target_level: int) -> String:
    var rate = calculate_success_rate(target_level)
    var percent = int(rate * 100)

    if rate >= 0.9:
        return "极高 (%d%%)" % percent
    elif rate >= 0.7:
        return "较高 (%d%%)" % percent
    elif rate >= 0.5:
        return "中等 (%d%%)" % percent
    elif rate >= 0.3:
        return "较低 (%d%%)" % percent
    else:
        return "困难 (%d%%)" % percent

func process_pending_apply_result(request_data: Dictionary) -> Dictionary:
    var member_id = request_data.get("member_id")
    var target_level = request_data.get("level", 1)
    var league = _get_league_data()

    if league and league.get_member(member_id).get("is_friend_link", false):
        return {"success": false, "member_id": member_id, "result": "failed", "reason": "已是友链"}

    var success_rate = calculate_success_rate(target_level)
    var roll = randf()
    var success = roll <= success_rate

    if success and league:
        league.mark_friend_link(member_id, true)
        return {"success": true, "member_id": member_id, "result": "approved", "level": target_level}
    else:
        return {"success": false, "member_id": member_id, "result": "rejected", "level": target_level, "reason": "对方拒绝了你的申请"}

func check_pending_requests() -> Array[Dictionary]:
    if _data.pending_requests.is_empty():
        return []

    var results: Array[Dictionary] = []
    var time_data = GDManager.get_time() if GDManager else null

    var to_remove: Array = []
    for req in _data.pending_requests:
        if req.get("is_passive", false):
            continue

        var member_id = req.get("member_id")
        var wait_days = req.get("wait_days", 0)

        var elapsed = _calculate_elapsed_days(req, time_data)

        if elapsed >= wait_days:
            var result = process_pending_apply_result(req)
            results.append(result)
            emit_signal("apply_result_received", result)
            to_remove.append(member_id)

    for member_id in to_remove:
        _data.remove_pending_request(member_id)

    return results

func add_passive_requests() -> Array[Dictionary]:
    if not _data.is_league_member:
        print("[友链] 未加入联盟，跳过被动申请")
        return []

    var league = _get_league_data()
    if not league or league.lm_members.is_empty():
        print("[友链] 联盟成员为空，跳过被动申请")
        return []

    var eligible_members: Array[Dictionary] = []
    for member in league.lm_members:
        var member_id = member.get("id")
        if _data.has_link(member_id):
            continue
        if _data.has_pending_request(member_id):
            continue
        eligible_members.append(member)

    if eligible_members.size() == 0:
        return []

    eligible_members.shuffle()

    var requests_count = randi_range(1, 3)
    var actual_count = mini(requests_count, eligible_members.size())
    var new_requests: Array[Dictionary] = []
    var game_time = GDManager.get_time()

    for i in range(actual_count):
        var member = eligible_members[i]
        var member_id = member.get("id")
        var member_level = member.get("lv", 1)

        var request_data = {
            "member_id": member_id,
            "request_date": game_time.current_date_str if game_time else Time.get_date_string_from_system(),
            "level": member_level,
            "is_passive": true,
            "wait_days": 0,
            "apply_date": game_time.current_date_str if game_time else Time.get_date_string_from_system(),
            "apply_game_year": game_time.current_year if game_time else 0,
            "apply_game_month": game_time.current_month if game_time else 0,
            "apply_game_week": game_time.current_week if game_time else 1,
            "apply_game_day": game_time.current_day if game_time else 0,
        }

        _data.add_pending_request(request_data)
        new_requests.append(request_data)
        emit_signal("request_received", request_data)

    print("[友链] 生成了 %d 个被动申请" % new_requests.size())
    return new_requests

func _calculate_elapsed_days(request_data: Dictionary, time_data) -> int:
    var apply_game_year = request_data.get("apply_game_year", 0)
    var apply_game_month = request_data.get("apply_game_month", 0)
    var apply_game_week = request_data.get("apply_game_week", 1)
    var apply_game_day = request_data.get("apply_game_day", 0)

    if not time_data:
        return 999

    if apply_game_year <= 0:
        return 999

    var current_year = time_data.current_year
    var current_month = time_data.current_month
    var current_week = time_data.current_week
    var current_day = time_data.current_day

    var apply_total_days = (apply_game_year - TimeData.GAME_START_YEAR) * 12 * 4 * 7 + \
                           (apply_game_month - 1) * 4 * 7 + \
                           (apply_game_week - 1) * 7 + \
                           apply_game_day
    var current_total_days = (current_year - TimeData.GAME_START_YEAR) * 12 * 4 * 7 + \
                             (current_month - 1) * 4 * 7 + \
                             (current_week - 1) * 7 + \
                             current_day

    return current_total_days - apply_total_days