class_name LeagueData

var is_joined: bool = false
var donation_total: float = 0.0
var donation_history: Array[Dictionary] = []

var rank_overall: Array[Dictionary] = []
var rank_literature: Array[Dictionary] = []
var rank_tech: Array[Dictionary] = []
var rank_art: Array[Dictionary] = []

var donation_ranking: Array[Array] = []

var lm_members: Array[Dictionary] = []

signal league_joined
signal donation_made(amount: float)
signal rank_updated

# ===== 辅助方法 =====

func join_league():
    if not is_joined:
        is_joined = true
        emit_signal("league_joined")

func donate(amount: float, message: String = ""):
    if is_joined and amount > 0:
        donation_total += amount
        donation_history.append({
            "amount": amount,
            "message": message,
            "timestamp": Time.get_unix_time_from_system(),
            "date": Time.get_date_string_from_system()
        })
        emit_signal("donation_made", amount)

func get_rank_overall() -> Array[Dictionary]:
    return rank_overall

func get_rank_literature() -> Array[Dictionary]:
    return rank_literature

func get_rank_tech() -> Array[Dictionary]:
    return rank_tech

func get_rank_art() -> Array[Dictionary]:
    return rank_art

func set_rank_overall(ranks: Array[Dictionary]):
    rank_overall = ranks
    emit_signal("rank_updated")

func set_rank_literature(ranks: Array[Dictionary]):
    rank_literature = ranks
    emit_signal("rank_updated")

func set_rank_tech(ranks: Array[Dictionary]):
    rank_tech = ranks
    emit_signal("rank_updated")

func set_rank_art(ranks: Array[Dictionary]):
    rank_art = ranks
    emit_signal("rank_updated")

func set_donation_ranking(ranking: Array[Array]):
    donation_ranking = ranking

func get_player_rank() -> int:
    for i in range(rank_overall.size()):
        if rank_overall[i].has("is_player") and rank_overall[i]["is_player"]:
            return i + 1
    return 0

func get_top_players(count: int = 10) -> Array[Dictionary]:
    var top_players = []
    for i in range(min(count, rank_overall.size())):
        top_players.append(rank_overall[i])
    return top_players

func get_recent_donations(days: int = 30) -> Array[Dictionary]:
    var recent_donations = []
    var cutoff_time = Time.get_unix_time_from_system() - (days * 24 * 3600)

    for donation in donation_history:
        if donation["timestamp"] >= cutoff_time:
            recent_donations.append(donation)

    return recent_donations

func get_total_donations_this_month() -> float:
    var current_date = Time.get_date_dict_from_system()
    var total = 0.0

    for donation in donation_history:
        var donation_date = Time.get_datetime_dict_from_unix_time(donation["timestamp"])
        if donation_date["month"] == current_date["month"] and \
           donation_date["year"] == current_date["year"]:
            total += donation["amount"]

    return total

func init_lm_members():
    var static_members = GDManager.get_lm_members() if GDManager else []
    lm_members = []
    for m in static_members:
        lm_members.append({
            "id": m.get("id"),
            "blog_name": m.get("blog_name"),
            "blog_author": m.get("blog_author"),
            "lv": m.get("lv"),
            "type": m.get("type"),
            "quality": m.get("quality"),
            "url": m.get("url"),
            "connectivity": true,
            "is_friend_link": false,
            "add_date": "",
            "last_check": ""
        })

func get_friend_links() -> Array[Dictionary]:
    return lm_members.filter(func(m): return m.get("is_friend_link", false))

func get_member(id: int) -> Dictionary:
    for m in lm_members:
        if m.get("id") == id:
            return m
    return {}

func update_member(id: int, data: Dictionary):
    for i in range(lm_members.size()):
        if lm_members[i].get("id") == id:
            for key in data:
                lm_members[i][key] = data[key]
            return
    lm_members.append(data)

func remove_member_by_id(target_id: int) -> bool:
    for i in range(lm_members.size()):
        if lm_members[i].get("id") == target_id:
            lm_members.remove_at(i)
            return true
    return false

func mark_friend_link(id: int, is_link: bool):
    var member = get_member(id)
    if member.size() > 0:
        member["is_friend_link"] = is_link
        if is_link:
            member["add_date"] = Time.get_date_string_from_system()
        else:
            member["add_date"] = ""

func get_member_level(id: int) -> int:
    var member = get_member(id)
    if member.size() > 0:
        return member.get("lv", 1)
    return 1
