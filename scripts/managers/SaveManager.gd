class_name SaveManager extends Node

const SAVE_VERSION = "1.0"
const MAX_SAVE_SLOTS = 10
const SAVE_DIR = "user://saves/"
const AUTO_SAVE_INTERVAL = 300  # 5分钟自动保存一次

var auto_save_timer: Timer = null

signal save_completed(slot: int, success: bool)
signal load_completed(slot: int, success: bool)
signal auto_save_triggered

func _ready():
    # 创建保存目录
    var dir = DirAccess.open("user://")
    if not dir.dir_exists("saves"):
        dir.make_dir("saves")

    # 设置自动保存
    setup_auto_save()

func setup_auto_save():
    auto_save_timer = Timer.new()
    auto_save_timer.wait_time = AUTO_SAVE_INTERVAL
    auto_save_timer.autostart = true
    auto_save_timer.timeout.connect(_on_auto_save_timeout)
    add_child(auto_save_timer)

func _on_auto_save_timeout():
    emit_signal("auto_save_triggered")

# ===== 存档管理 =====

func save_game(slot: int, data_container: DataContainer) -> Dictionary:
    if slot < 0 or slot >= MAX_SAVE_SLOTS:
        return {"success": false, "error": "Invalid slot"}

    var save_data = {
        "version": SAVE_VERSION,
        "timestamp": Time.get_unix_time_from_system(),
        "runtime_data": serialize_runtime_data(data_container.runtime_data),
        "metadata": create_metadata(data_container)
    }

    var file_path = SAVE_DIR + "save_%d.save" % slot
    var file = FileAccess.open(file_path, FileAccess.WRITE)

    if file == null:
        var error_str = FileAccess.get_open_error()
        return {"success": false, "error": "Failed to open save file: %s" % error_str}

    var json_string = JSON.stringify(save_data)
    file.store_string(json_string)
    file.close()

    emit_signal("save_completed", slot, true)
    return {"success": true, "path": file_path}

func load_game(slot: int) -> Dictionary:
    if slot < 0 or slot >= MAX_SAVE_SLOTS:
        return {"success": false, "error": "Invalid slot"}

    var file_path = SAVE_DIR + "save_%d.save" % slot
    if not FileAccess.file_exists(file_path):
        return {"success": false, "error": "Save file not found"}

    var file = FileAccess.open(file_path, FileAccess.READ)
    if file == null:
        return {"success": false, "error": "Failed to open save file"}

    var json_string = file.get_as_text()
    file.close()

    var json = JSON.new()
    var parse_result = json.parse(json_string)

    if parse_result != OK:
        return {"success": false, "error": "Failed to parse save file"}

    var save_data = json.data

    # 验证存档版本
    if not save_data.has("version") or save_data["version"] != SAVE_VERSION:
        return {"success": false, "error": "Incompatible save version"}

    emit_signal("load_completed", slot, true)
    return {"success": true, "data": save_data}

func delete_save(slot: int) -> bool:
    if slot < 0 or slot >= MAX_SAVE_SLOTS:
        return false

    var file_path = SAVE_DIR + "save_%d.save" % slot
    if not FileAccess.file_exists(file_path):
        return false

    var dir = DirAccess.open(SAVE_DIR)
    if dir.remove(file_path) != OK:
        return false

    return true

func list_saves() -> Array:
    var saves = []

    for slot in range(MAX_SAVE_SLOTS):
        var file_path = SAVE_DIR + "save_%d.save" % slot
        if FileAccess.file_exists(file_path):
            var file = FileAccess.open(file_path, FileAccess.READ)
            if file:
                var json_string = file.get_as_text()
                file.close()

                var json = JSON.new()
                if json.parse(json_string) == OK:
                    var save_data = json.data
                    if save_data.has("metadata"):
                        saves.append({
                            "slot": slot,
                            "timestamp": save_data.get("timestamp", 0),
                            "metadata": save_data["metadata"]
                        })

    return saves

func auto_save(data_container: DataContainer) -> Dictionary:
    # 自动保存到槽位 0
    return save_game(0, data_container)

# ===== 数据序列化 =====

func serialize_runtime_data(runtime_data: RuntimeData) -> Dictionary:
    return {
        "blogger": serialize_blogger_data(runtime_data.blogger),
        "time": serialize_time_data(runtime_data.time),
        "bank": serialize_bank_data(runtime_data.bank),
        "ad": serialize_ad_data(runtime_data.ad),
        "statistics": serialize_statistics_data(runtime_data.statistics),
        "task": serialize_task_data(runtime_data.task),
        "league": serialize_league_data(runtime_data.league)
    }

func deserialize_runtime_data(data: Dictionary) -> RuntimeData:
    var runtime_data = RuntimeData.new()

    if data.has("blogger"):
        deserialize_blogger_data(runtime_data.blogger, data["blogger"])
    if data.has("time"):
        deserialize_time_data(runtime_data.time, data["time"])
    if data.has("bank"):
        deserialize_bank_data(runtime_data.bank, data["bank"])
    if data.has("ad"):
        deserialize_ad_data(runtime_data.ad, data["ad"])
    if data.has("statistics"):
        deserialize_statistics_data(runtime_data.statistics, data["statistics"])
    if data.has("task"):
        deserialize_task_data(runtime_data.task, data["task"])
    if data.has("league"):
        deserialize_league_data(runtime_data.league, data["league"])

    return runtime_data

func serialize_blogger_data(data: BloggerData) -> Dictionary:
    return {
        "level": data.level,
        "exp": data.exp,
        "rank_tier": data.rank_tier,
        "attribute_points": data.attribute_points,
        "writing_ability": data.writing_ability,
        "technical_ability": data.technical_ability,
        "code_ability": data.code_ability,
        "literature_ability": data.literature_ability,
        "drawing_ability": data.drawing_ability,
        "stamina": data.stamina,
        "money": data.money,
        "social_ability": data.social_ability,
        "blog_name": data.blog_name,
        "blog_author": data.blog_author,
        "blog_type": data.blog_type,
        "safety_value": data.safety_value,
        "seo_value": data.seo_value,
        "design_value": data.design_value,
        "ui_value": data.ui_value,
        "views": data.views,
        "rss": data.rss,
        "favorites": data.favorites,
        "today_views": data.today_views,
        "week_views": data.week_views,
        "month_views": data.month_views,
        "year_views": data.year_views,
        "posts": data.posts,
        "calendar": data.calendar,
        "tmp_week": data.tmp_week,
        "tmp_month": data.tmp_month,
        "tmp_year": data.tmp_year,
        "last_post_quality": data.last_post_quality
    }

func deserialize_blogger_data(data: BloggerData, dict: Dictionary):
    data.level = dict.get("level", 1)
    data.exp = dict.get("exp", 0)
    data.rank_tier = dict.get("rank_tier", 0)
    data.attribute_points = dict.get("attribute_points", 0)
    data.writing_ability = dict.get("writing_ability", 23)
    data.technical_ability = dict.get("technical_ability", 23)
    data.code_ability = dict.get("code_ability", 23)
    data.literature_ability = dict.get("literature_ability", 23)
    data.drawing_ability = dict.get("drawing_ability", 23)
    data.stamina = dict.get("stamina", 100)
    data.money = dict.get("money", 100000.0)
    data.social_ability = dict.get("social_ability", 5)
    data.blog_name = dict.get("blog_name", "我的博客")
    data.blog_author = dict.get("blog_author", "J.sky")
    data.blog_type = dict.get("blog_type", 1)
    data.safety_value = dict.get("safety_value", 100)
    data.seo_value = dict.get("seo_value", 100)
    data.design_value = dict.get("design_value", 100)
    data.ui_value = dict.get("ui_value", 0)
    data.views = dict.get("views", 0)
    data.rss = dict.get("rss", 0)
    data.favorites = dict.get("favorites", 0)
    data.today_views = dict.get("today_views", 0)
    data.week_views = dict.get("week_views", 0)
    data.month_views = dict.get("month_views", 0)
    data.year_views = dict.get("year_views", 0)
    data.posts = dict.get("posts", [])
    data.calendar = dict.get("calendar", [])
    data.tmp_week = dict.get("tmp_week", 1)
    data.tmp_month = dict.get("tmp_month", 1)
    data.tmp_year = dict.get("tmp_year", 2000)
    data.last_post_quality = dict.get("last_post_quality", 0)

func serialize_time_data(data: TimeData) -> Dictionary:
    return {
        "current_year": data.current_year,
        "current_month": data.current_month,
        "current_week": data.current_week,
        "current_day": data.current_day,
        "current_quarter": data.current_quarter,
        "time_scale": data.time_scale,
        "is_paused": data.is_paused,
        "game_start_date": data.game_start_date,
        "current_date_str": data.current_date_str
    }

func deserialize_time_data(data: TimeData, dict: Dictionary):
    data.current_year = dict.get("current_year", 2000)
    data.current_month = dict.get("current_month", 1)
    data.current_week = dict.get("current_week", 1)
    data.current_day = dict.get("current_day", 1)
    data.current_quarter = dict.get("current_quarter", 1)
    data.time_scale = dict.get("time_scale", 1.0)
    data.is_paused = dict.get("is_paused", false)
    data.game_start_date = dict.get("game_start_date", "2000-1-1-1")
    data.current_date_str = dict.get("current_date_str", "2000-1-1-1")

func serialize_bank_data(data: BankData) -> Dictionary:
    return {
        "savings_balance": data.savings_balance,
        "savings_interest": data.savings_interest,
        "fixed_deposits": data.fixed_deposits,
        "next_deposit_id": data.next_deposit_id,
        "deposit_history": data.deposit_history,
        "withdraw_history": data.withdraw_history
    }

func deserialize_bank_data(data: BankData, dict: Dictionary):
    data.savings_balance = dict.get("savings_balance", 0.0)
    data.savings_interest = dict.get("savings_interest", 0.0)
    data.fixed_deposits = dict.get("fixed_deposits", {})
    data.next_deposit_id = dict.get("next_deposit_id", 1)
    data.deposit_history = dict.get("deposit_history", [])
    data.withdraw_history = dict.get("withdraw_history", [])

func serialize_ad_data(data: AdData) -> Dictionary:
    return {
        "current_ad_type": data.current_ad_type,
        "is_registered": data.is_registered,
        "is_under_review": data.is_under_review,
        "is_approved": data.is_approved,
        "review_days": data.review_days,
        "pending_commission": data.pending_commission,
        "settled_commission": data.settled_commission,
        "total_commission": data.total_commission,
        "ad_statistics": data.ad_statistics
    }

func deserialize_ad_data(data: AdData, dict: Dictionary):
    data.current_ad_type = dict.get("current_ad_type", "文字广告")
    data.is_registered = dict.get("is_registered", true)
    data.is_under_review = dict.get("is_under_review", false)
    data.is_approved = dict.get("is_approved", false)
    data.review_days = dict.get("review_days", 0)
    data.pending_commission = dict.get("pending_commission", 0.0)
    data.settled_commission = dict.get("settled_commission", 0.0)
    data.total_commission = dict.get("total_commission", 0.0)
    data.ad_statistics = dict.get("ad_statistics", [])

func serialize_statistics_data(data: StatisticsData) -> Dictionary:
    return {
        "daily_stats": data.daily_stats,
        "weekly_stats": data.weekly_stats,
        "monthly_stats": data.monthly_stats,
        "yearly_stats": data.yearly_stats,
        "total_posts": data.total_posts,
        "paid_posts": data.paid_posts,
        "free_posts": data.free_posts,
        "total_income": data.total_income,
        "ad_income": data.ad_income,
        "post_income": data.post_income,
        "bank_income": data.bank_income
    }

func deserialize_statistics_data(data: StatisticsData, dict: Dictionary):
    data.daily_stats = dict.get("daily_stats", [])
    data.weekly_stats = dict.get("weekly_stats", [])
    data.monthly_stats = dict.get("monthly_stats", [])
    data.yearly_stats = dict.get("yearly_stats", [])
    data.total_posts = dict.get("total_posts", 0)
    data.paid_posts = dict.get("paid_posts", 0)
    data.free_posts = dict.get("free_posts", 0)
    data.total_income = dict.get("total_income", 0.0)
    data.ad_income = dict.get("ad_income", 0.0)
    data.post_income = dict.get("post_income", 0.0)
    data.bank_income = dict.get("bank_income", 0.0)

func serialize_task_data(data: TaskData) -> Dictionary:
    return {
        "task_states": data.task_states,
        "completed_tasks": data.completed_tasks,
        "active_tasks": data.active_tasks,
        "total_rewards": data.total_rewards
    }

func deserialize_task_data(data: TaskData, dict: Dictionary):
    data.task_states = dict.get("task_states", [])
    data.completed_tasks = dict.get("completed_tasks", 0)
    data.active_tasks = dict.get("active_tasks", 0)
    data.total_rewards = dict.get("total_rewards", {"money": 0.0, "exp": 0})

func serialize_league_data(data: LeagueData) -> Dictionary:
    return {
        "is_joined": data.is_joined,
        "donation_total": data.donation_total,
        "donation_history": data.donation_history,
        "rank_overall": data.rank_overall,
        "rank_literature": data.rank_literature,
        "rank_tech": data.rank_tech,
        "rank_art": data.rank_art,
        "donation_ranking": data.donation_ranking
    }

func deserialize_league_data(data: LeagueData, dict: Dictionary):
    data.is_joined = dict.get("is_joined", false)
    data.donation_total = dict.get("donation_total", 0.0)
    data.donation_history = dict.get("donation_history", [])
    data.rank_overall = dict.get("rank_overall", [])
    data.rank_literature = dict.get("rank_literature", [])
    data.rank_tech = dict.get("rank_tech", [])
    data.rank_art = dict.get("rank_art", [])
    data.donation_ranking = dict.get("donation_ranking", [])

# ===== 元数据 =====

func create_metadata(data_container: DataContainer) -> Dictionary:
    var blogger = data_container.get_blogger()
    var time = data_container.get_time()

    return {
        "blog_name": blogger.blog_name,
        "level": blogger.level,
        "money": blogger.money,
        "current_date": time.current_date_str,
        "play_time": Time.get_unix_time_from_system()
    }