## 友链数据结构
## 存储玩家的所有友链相关数据
class_name FriendLinkData

var pending_requests: Array[Dictionary] = []

var last_maintenance_date: String = ""

var auto_settings: Dictionary = {
    "min_level_diff": 5,
    "auto_delete_invalid": true,
    "auto_delete_spam": true,
}

var is_league_member: bool = false

signal link_added(link_data: Dictionary)
signal link_removed(member_id: int)
signal link_status_changed(member_id: int, status: String)
signal request_received(request_data: Dictionary)
signal request_processed(member_id: int, approved: bool)
signal maintenance_performed(result: Dictionary)

const LINK_STATUS_ACTIVE = "active"
const LINK_STATUS_INVALID = "invalid"

enum LinkStatus {
    ACTIVE = 0,
    INVALID = 1,
}

static func get_status_string(status: int) -> String:
    match status:
        LinkStatus.ACTIVE:
            return LINK_STATUS_ACTIVE
        LinkStatus.INVALID:
            return LINK_STATUS_INVALID
        _:
            return LINK_STATUS_ACTIVE

static func parse_status_string(str: String) -> int:
    match str:
        LINK_STATUS_INVALID:
            return LinkStatus.INVALID
        _:
            return LinkStatus.ACTIVE

func get_active_links() -> Array[Dictionary]:
    if GDManager and GDManager.get_league():
        return GDManager.get_league().get_friend_links()
    return []

func get_pending_count() -> int:
    return pending_requests.size()

func get_active_link_count() -> int:
    return get_active_links().size()

func has_link(member_id: int) -> bool:
    if GDManager and GDManager.get_league():
        var member = GDManager.get_league().get_member(member_id)
        return member.get("is_friend_link", false)
    return false

func remove_link(member_id: int) -> bool:
    if GDManager and GDManager.get_league():
        GDManager.get_league().mark_friend_link(member_id, false)
        emit_signal("link_removed", member_id)
        return true
    return false

func has_pending_request(member_id: int) -> bool:
    for req in pending_requests:
        if req.get("member_id") == member_id:
            return true
    return false

func add_pending_request(request_data: Dictionary) -> void:
    pending_requests.append(request_data)
    emit_signal("request_received", request_data)

func remove_pending_request(member_id: int) -> bool:
    for i in range(pending_requests.size()):
        if pending_requests[i].get("member_id") == member_id:
            pending_requests.remove_at(i)
            return true
    return false

func set_auto_settings(settings: Dictionary) -> void:
    auto_settings = settings

func get_auto_settings() -> Dictionary:
    return auto_settings

func update_maintenance_date() -> void:
    last_maintenance_date = Time.get_date_string_from_system()

func get_days_since_maintenance() -> int:
    if last_maintenance_date.is_empty():
        return 999

    var parts = last_maintenance_date.split("-")
    if parts.size() != 3:
        return 999

    var last_date = {
        "year": parts[0].to_int(),
        "month": parts[1].to_int(),
        "day": parts[2].to_int()
    }

    var current = Time.get_date_dict_from_system()

    var last_days = last_date["year"] * 365 + last_date["month"] * 30 + last_date["day"]
    var current_days = current["year"] * 365 + current["month"] * 30 + current["day"]

    return current_days - last_days

func get_views_bonus() -> int:
    var bonus = 0
    for link in get_active_links():
        var level = link.get("lv", 1)
        if level >= 40:
            bonus += 100
        elif level >= 30:
            bonus += 50
        elif level >= 20:
            bonus += 30
        else:
            bonus += 10
    return bonus

func get_seo_bonus() -> int:
    var count = get_active_link_count()
    if count >= 20:
        return 20
    elif count >= 16:
        return 15
    elif count >= 11:
        return 10
    elif count >= 6:
        return 5
    elif count >= 1:
        return 2
    return 0