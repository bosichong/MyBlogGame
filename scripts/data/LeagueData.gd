class_name LeagueData

var is_joined: bool = false
var donation_total: float = 0.0
var donation_history: Array[Dictionary] = []

var rank_overall: Array[Dictionary] = []
var rank_literature: Array[Dictionary] = []
var rank_tech: Array[Dictionary] = []
var rank_art: Array[Dictionary] = []

var donation_ranking: Array[Array] = []

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