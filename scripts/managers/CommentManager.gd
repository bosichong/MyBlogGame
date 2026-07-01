## 评论管理器
## 负责评论的生成和管理
class_name CommentManager
extends Node

var _data: CommentData:
    get: return _get_comment_data()

var _templates: Dictionary = {}
var _league_templates_by_type: Dictionary = {}

## 每篇文章的垃圾评论数缓存（每日刷新）
var _post_spam_counts: Dictionary = {}
## 每篇文章的评论总数缓存（每日刷新，避免全量 filter）
var _post_comment_counts: Dictionary = {}
var _comment_cache_valid: bool = false

signal comment_generated(comment_data: Dictionary)
signal comment_removed(comment_id: int)
signal maintenance_completed(result: Dictionary)
signal article_comment_generated(post_id: int, comment: Dictionary)

func _init():
    pass

func _ready():
    _load_templates()

func _load_templates():
    var templates_data = GDManager.get_data("comment_templates") if GDManager else null
    if templates_data:
        _templates = templates_data.get_templates()
        _init_league_templates_by_type()

func _init_league_templates_by_type():
    _league_templates_by_type = Strs.comment_templates.get("league", {})

func _get_comment_data() -> CommentData:
    if GDManager and GDManager.data_container:
        return GDManager.data_container.get_comment()
    return null

## 刷新每篇文章的评论缓存（每日调用一次，避免每篇文章都 filter 全部评论）
func refresh_post_cache() -> void:
    _post_spam_counts.clear()
    _post_comment_counts.clear()
    if not _data:
        _comment_cache_valid = true
        return
    for comment in _data.comments:
        var pid = comment.get("post_id", 0)
        _post_comment_counts[pid] = _post_comment_counts.get(pid, 0) + 1
        if comment.get("is_spam", false) and comment.get("status") == "spam":
            _post_spam_counts[pid] = _post_spam_counts.get(pid, 0) + 1
    _comment_cache_valid = true

func get_spam_count(post_id: int) -> int:
    return _post_spam_counts.get(post_id, 0)

func get_comment_count_cached(post_id: int) -> int:
    return _post_comment_counts.get(post_id, 0)

func get_comments(post_id = -1) -> Array:
    if not _data:
        return []
    if post_id == -1:
        return _data.comments
    return _data.comments.filter(func(c): return c.get("post_id") == post_id)

func get_max_comments(article_views: int) -> int:
    var calculated = floor(article_views * 0.2)
    return mini(calculated, 50)

func add_comment(comment: Dictionary) -> bool:
    if not _data:
        return false
    _data.add_comment(comment)
    emit_signal("comment_generated", comment)
    emit_signal("article_comment_generated", comment.get("post_id"), comment)
    return true

func remove_comment(comment_id: int) -> bool:
    if not _data:
        return false
    var result = _data.remove_comment(comment_id)
    if result:
        emit_signal("comment_removed", comment_id)
    return result

func get_league_comments() -> Array:
    if not _data:
        return []
    return _data.comments.filter(func(c): return c.get("source") == "league")

func get_friendlink_comments() -> Array:
    if not _data:
        return []
    return _data.comments.filter(func(c): return c.get("source") == "friendlink")

func get_pending_comments() -> Array:
    if not _data:
        return []
    return _data.comments.filter(func(c): return c.get("status") == "pending")

func get_spam_comments() -> Array:
    if not _data:
        return []
    return _data.comments.filter(func(c): return c.get("status") == "spam")

func generate_league_comment(post_id: int, article_quality: int, article_type: String = "") -> Dictionary:
    var templates = _league_templates_by_type.get(article_type, _league_templates_by_type.get("综合类", []))
    if templates.is_empty():
        return {}
    var template = templates[randi() % templates.size()]
    var content = _fill_template(template, article_quality)
    
    var member = select_league_member(article_type)
    
    var comment: Dictionary = {
        "id": _generate_comment_id(),
        "source": "league",
        "content": content,
        "post_id": post_id,
        "article_type": article_type,
        "quality": 2,
        "status": "normal",
        "date": Time.get_date_string_from_system(),
    }
    
    if not member.is_empty():
        comment["author_name"] = member.get("blog_author", "匿名用户")
        comment["author_level"] = member.get("lv", 1)
        comment["author_type"] = member.get("type", "")
    
    return comment

func generate_negative_comment(post_id: int, article_type: String = "") -> Dictionary:
    var templates_data = GDManager.get_data("comment_templates") if GDManager else null
    var content = "内容太水了，没有一点深度"
    if templates_data and templates_data.has_method("get_random_negative_template"):
        content = templates_data.get_random_negative_template()
    
    var member = select_league_member(article_type)
    
    var comment: Dictionary = {
        "id": _generate_comment_id(),
        "source": "league",
        "content": content,
        "post_id": post_id,
        "article_type": article_type,
        "quality": 1,
        "status": "spam",
        "is_spam": true,
        "date": Time.get_date_string_from_system(),
    }
    
    if not member.is_empty():
        comment["author_name"] = member.get("blog_author", "匿名用户")
        comment["author_level"] = member.get("lv", 1)
        comment["author_type"] = member.get("type", "")
    
    return comment

func generate_friendlink_comment(post_id: int, article_type: String = "") -> Dictionary:
    var templates = Strs.comment_templates.get("friendlink", [])
    if templates.is_empty():
        templates = ["老朋友的文章一如既往精彩！", "恭喜完成这个系列，写得很好。", "内容越来越丰富了，加油！"]
    var template = templates[randi() % templates.size()]
    
    var member = select_league_member(article_type)
    
    var comment: Dictionary = {
        "id": _generate_comment_id(),
        "source": "friendlink",
        "content": template,
        "post_id": post_id,
        "article_type": article_type,
        "quality": 3,
        "status": "pending",
        "date": Time.get_date_string_from_system(),
    }
    
    if not member.is_empty():
        comment["author_name"] = member.get("blog_author", "匿名用户")
        comment["author_level"] = member.get("lv", 1)
        comment["author_type"] = member.get("type", "")
    
    return comment

func generate_task_comment(post_id: int, content: String, source: String = "league") -> Dictionary:
    return {
        "id": _generate_comment_id(),
        "source": source,
        "content": content,
        "post_id": post_id,
        "quality": 3,
        "status": "pending",
        "is_task_comment": true,
        "date": Time.get_date_string_from_system(),
    }

func _fill_template(template: String, article_quality: int) -> String:
    var result = template
    if "{topic}" in result:
        var topics = ["这个问题", "这个功能", "这个思路", "这个方案", "这个技巧"]
        result = result.replace("{topic}", topics[randi() % topics.size()])
    return result

func _generate_comment_id() -> int:
    return Time.get_ticks_msec() + (randi() % 10000)

func do_maintenance() -> Dictionary:
    var result = {
        "success": true,
        "deleted_spam": 0,
        "special_events": 0,
        "messages": [],
    }
    
    if not _data:
        result["success"] = false
        result["messages"].append("评论数据不存在")
        return result
    
    result["deleted_spam"] = auto_delete_spam()
    result["special_events"] = process_special_events()
    
    emit_signal("maintenance_completed", result)
    return result

func auto_delete_spam() -> int:
    var hidden_count = 0
    
    for comment in _data.comments:
        if comment.get("is_spam", false) and comment.get("status") != "hidden":
            comment["status"] = "hidden"
            hidden_count += 1
    
    return hidden_count

func process_special_events() -> int:
    return 0

func check_article_comments(post_id, article_views: int, article_quality: int, article_type: String = "") -> int:
    if not _data:
        return 0
    
    var generated_count = 0
    var threshold = floor(article_views / 500.0)
    var current = get_comment_count_cached(post_id)
    var max_allowed = get_max_comments(article_views)
    
    var members = GDManager.get_lm_members() if GDManager else []
    if members.is_empty():
        return 0
    
    var raw_prob = float(article_quality) / 200.0
    var generate_prob = max(min(raw_prob, 0.5), 0.25)
    
    while current < threshold and current < max_allowed:
        if randf() > generate_prob:
            current += 1
            continue
        
        if randf() <= 0.9:
            var comment = generate_league_comment(post_id, article_quality, article_type)
            if not comment.is_empty():
                add_comment(comment)
                generated_count += 1
        else:
            var negative_comment = generate_negative_comment(post_id, article_type)
            if not negative_comment.is_empty():
                add_comment(negative_comment)
                generated_count += 1
                #print("[垃圾评论] ID=%d | 作者=%s | 文章=%d | 内容=%s" % [c_id, author, post_id, negative_comment.get("content", "")])
        
        current += 1
    
    return generated_count

func check_all_articles() -> Dictionary:
    var result = {
        "articles_checked": 0,
        "comments_generated": 0,
        "messages": [],
    }
    
    if not GDManager:
        return result
    
    var blogger = GDManager.get_blogger()
    if not blogger:
        return result
    
    for post in blogger.posts:
        var post_id = post.get("id", 0)
        var views = post.get("views", 0)
        var quality = post.get("quality", 0)
        var article_type = post.get("article_category", "综合类")
        
        result["articles_checked"] += 1
        var generated = check_article_comments(post_id, views, quality, article_type)
        result["comments_generated"] += generated
        
        if generated > 0 and post_id != 0:
            post["comments"] = post.get("comments", 0) + generated
            result["messages"].append("文章 %s 生成了 %d 条评论" % [post_id, generated])
    
    return result

func select_league_member(article_type: String = "") -> Dictionary:
    var members = GDManager.get_lm_members() if GDManager else []
    if members.is_empty():
        return {}
    
    var candidates = members
    
    if candidates.is_empty():
        return {}
    
    return candidates[randi() % candidates.size()]

func get_auto_settings() -> Dictionary:
    if not _data:
        return {}
    return _data.get_auto_settings()

func set_auto_settings(settings: Dictionary) -> void:
    if _data:
        _data.set_auto_settings(settings)

func get_traffic_bonus(post_id: int = -1) -> int:
    if not _data:
        return 0
    return _data.get_traffic_bonus(post_id)

func sync_to_post(post_id: int, comment_count: int) -> bool:
    if not GDManager:
        return false
    
    var blogger = GDManager.get_blogger()
    if not blogger:
        return false
    
    for post in blogger.posts + blogger.archived_posts:
        if post.get("id") == post_id:
            post["comments"] = comment_count
            return true
    
    return false

