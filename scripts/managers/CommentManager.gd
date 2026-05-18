## 评论管理器
## 负责评论的生成和管理
class_name CommentManager
extends Node

var _data: CommentData:
    get: return _get_comment_data()

var _templates: Dictionary = {}
var _league_templates_by_type: Dictionary = {}

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

func get_comments(post_id: int = -1) -> Array:
    if not _data:
        return []
    if post_id < 0:
        return _data.comments
    return _data.comments.filter(func(c): return c.get("post_id") == post_id)

func get_comment_count(post_id: int = -1) -> int:
    return get_comments(post_id).size()

func should_generate_comment(post_id: int, article_views: int) -> bool:
    if not _data:
        return false
    var threshold = floor(article_views / 500.0)
    var current = get_comment_count(post_id)
    return current < threshold

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

func get_comment_quality(comment_id: int) -> int:
    for comment in _data.comments:
        if comment.get("id") == comment_id:
            return comment.get("quality", 1)
    return 1

func generate_league_comment(post_id: int, article_quality: int, article_type: String = "") -> Dictionary:
    var templates = _league_templates_by_type.get(article_type, _league_templates_by_type.get("综合类", []))
    if templates.is_empty():
        return {}
    var template = templates[randi() % templates.size()]
    var content = _fill_template(template, article_quality)
    return {
        "id": _generate_comment_id(),
        "source": "league",
        "content": content,
        "post_id": post_id,
        "article_type": article_type,
        "quality": 2,
        "status": "pending",
        "date": Time.get_date_string_from_system(),
    }

func generate_friendlink_comment(post_id: int, article_type: String = "") -> Dictionary:
    var templates = Strs.comment_templates.get("friendlink", [])
    if templates.is_empty():
        templates = ["老朋友的文章一如既往精彩！", "恭喜完成这个系列，写得很好。", "内容越来越丰富了，加油！"]
    var template = templates[randi() % templates.size()]
    return {
        "id": _generate_comment_id(),
        "source": "friendlink",
        "content": template,
        "post_id": post_id,
        "article_type": article_type,
        "quality": 3,
        "status": "pending",
        "date": Time.get_date_string_from_system(),
    }

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
    if not _data:
        return randi()
    var max_id = 0
    for comment in _data.comments:
        var cid = comment.get("id", 0)
        if cid > max_id:
            max_id = cid
    return max_id + 1

func do_maintenance() -> Dictionary:
    var result = {
        "success": true,
        "auto_approved": 0,
        "deleted_spam": 0,
        "special_events": 0,
        "messages": [],
    }
    
    if not _data:
        result["success"] = false
        result["messages"].append("评论数据不存在")
        return result
    
    result["auto_approved"] = auto_approve_comments()
    result["deleted_spam"] = auto_delete_spam()
    result["special_events"] = process_special_events()
    
    emit_signal("maintenance_completed", result)
    return result

func auto_approve_comments() -> int:
    var approved_count = 0
    for comment in _data.comments:
        if comment.get("status") == "pending":
            comment["status"] = "normal"
            approved_count += 1
    return approved_count

func auto_delete_spam() -> int:
    var deleted_count = 0
    var to_remove = []
    
    for comment in _data.comments:
        if comment.get("status") == "spam":
            to_remove.append(comment.get("id"))
    
    for comment_id in to_remove:
        _data.remove_comment(comment_id)
        deleted_count += 1
    
    if deleted_count > 0 and GDManager:
        var blogger = GDManager.get_blogger()
        if blogger:
            blogger.seo_value = mini(blogger.seo_value + 5, 100)
    
    return deleted_count

func process_special_events() -> int:
    return 0

func check_article_comments(post_id: int, article_views: int, article_quality: int, article_type: String = "") -> int:
    if not _data:
        return 0
    
    var generated_count = 0
    var threshold = floor(article_views / 500.0)
    var current = get_comment_count(post_id)
    var max_allowed = get_max_comments(article_views)
    
    while current < threshold and current < max_allowed:
        var comment = generate_league_comment(post_id, article_quality, article_type)
        if not comment.is_empty():
            add_comment(comment)
            generated_count += 1
            current += 1
        else:
            break
    
    if article_quality >= 95 and current < max_allowed:
        var friendlink_comment = generate_friendlink_comment(post_id, article_type)
        if not friendlink_comment.is_empty():
            add_comment(friendlink_comment)
            generated_count += 1
    
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
        var post_id = int(post.get("id", 0))
        var views = post.get("views", 0)
        var quality = post.get("quality", 0)
        var article_type = post.get("type", "综合类")
        
        result["articles_checked"] += 1
        var generated = check_article_comments(post_id, views, quality, article_type)
        result["comments_generated"] += generated
        
        if generated > 0:
            result["messages"].append("文章 %s 生成了 %d 条评论" % [post_id, generated])
    
    return result

func select_league_member(article_type: String = "") -> Dictionary:
    var members = GDManager.get_lm_members() if GDManager else []
    if members.is_empty():
        return {}
    
    var candidates = members.filter(func(m):
        var level = m.get("lv", 0)
        return level >= 10
    )
    
    if candidates.is_empty():
        return candidates[randi() % candidates.size()] if candidates.size() > 0 else {}
    
    return candidates[randi() % candidates.size()]

func get_auto_settings() -> Dictionary:
    if not _data:
        return {}
    return _data.get_auto_settings()

func set_auto_settings(settings: Dictionary) -> void:
    if _data:
        _data.set_auto_settings(settings)

func get_traffic_bonus() -> int:
    if not _data:
        return 0
    return _data.get_traffic_bonus()

func sync_to_post(post_id: int, comment_count: int) -> bool:
    if not GDManager:
        return false
    
    var blogger = GDManager.get_blogger()
    if not blogger:
        return false
    
    for post in blogger.posts:
        if int(post.get("id", 0)) == post_id:
            post["comments"] = comment_count
            return true
    
    return false

func sync_all_posts() -> int:
    var synced_count = 0
    var all_comments = get_comments()
    
    var post_comment_counts: Dictionary = {}
    for comment in all_comments:
        var post_id = comment.get("post_id")
        if not post_comment_counts.has(post_id):
            post_comment_counts[post_id] = 0
        post_comment_counts[post_id] += 1
    
    for post_id in post_comment_counts:
        if sync_to_post(post_id, post_comment_counts[post_id]):
            synced_count += 1
    
    return synced_count