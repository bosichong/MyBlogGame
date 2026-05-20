## 负面评论惩罚修饰器
## 如果文章有未处理的负面评论，访问量降低5%（最多50%）
class_name SpamPenaltyModifier
extends ViewsModifier

const MAX_PENALTY_SPAM_COUNT = 10

func _init():
    modifier_name = "spam_penalty"
    display_name = "负面评论惩罚"
    description = "有未处理的负面评论时，访问量降低5%（最多50%）"
    priority = 50
    type = Type.DECAY

func apply(views: int, post: Dictionary, blogger: Dictionary) -> int:
    var post_id = post.get("id")
    if not post_id:
        return views
    
    var comment_manager = GDManager.get_comment_manager() if GDManager else null
    if not comment_manager:
        return views
    
    var comments = comment_manager.get_comments(post_id)
    var spam_count = 0
    
    for comment in comments:
        if comment.get("is_spam", false) and comment.get("status") == "spam":
            spam_count += 1
    
    if spam_count > 0:
        var effective_count = mini(spam_count, MAX_PENALTY_SPAM_COUNT)
        var penalty = 1.0 - (effective_count * 0.05)
        var final_views = int(float(views) * penalty)
        #print("[垃圾惩罚] 文章ID=%s | 垃圾数=%d | 原访问=%d | 惩罚=%d | 结果=%d" % [str(post_id), spam_count, views, views - final_views, final_views])
        return final_views
    
    return views