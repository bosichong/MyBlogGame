## 评论数据
## 存储玩家的所有评论数据
class_name CommentData

var comments: Array[Dictionary] = []
var auto_settings: Dictionary = {
    "auto_approve": false,
    "auto_delete_spam": true,
}

signal comment_added(comment: Dictionary)
signal comment_removed(comment_id: int)
signal status_changed(comment_id: int, new_status: String)

func add_comment(comment: Dictionary) -> void:
    comments.append(comment)
    emit_signal("comment_added", comment)

func remove_comment(comment_id: int) -> bool:
    for i in range(comments.size()):
        if comments[i].get("id") == comment_id:
            comments.remove_at(i)
            emit_signal("comment_removed", comment_id)
            return true
    return false

func get_comment(comment_id: int) -> Dictionary:
    for comment in comments:
        if comment.get("id") == comment_id:
            return comment
    return {}

func update_comment_status(comment_id: int, status: String) -> bool:
    for comment in comments:
        if comment.get("id") == comment_id:
            comment["status"] = status
            emit_signal("status_changed", comment_id, status)
            return true
    return false

func get_comments_by_post(post_id: int) -> Array:
    return comments.filter(func(c): return c.get("post_id") == post_id)

func get_comments_by_source(source: String) -> Array:
    return comments.filter(func(c): return c.get("source") == source)

func get_comments_by_status(status: String) -> Array:
    return comments.filter(func(c): return c.get("status") == status)

func get_pending_count() -> int:
    return get_comments_by_status("pending").size()

func get_spam_count() -> int:
    return get_comments_by_status("spam").size()

func get_total_count() -> int:
    return comments.size()

func set_auto_settings(settings: Dictionary) -> void:
    auto_settings = settings

func get_auto_settings() -> Dictionary:
    return auto_settings

func get_traffic_bonus(post_id: int = -1) -> int:
    var count: int
    if post_id >= 0:
        count = get_comments_by_post(post_id).size()
    else:
        count = get_total_count()
    if count >= 100:
        return 1000
    elif count >= 50:
        return 500
    elif count >= 10:
        return 50
    return 0

func get_all_source_types() -> Array:
    var types: Array = []
    for comment in comments:
        var source = comment.get("source", "")
        if source and source not in types:
            types.append(source)
    return types