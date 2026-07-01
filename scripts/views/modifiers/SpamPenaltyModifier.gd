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
    
    var spam_count = comment_manager.get_spam_count(post_id)
    
    if spam_count > 0:
        var effective_count = mini(spam_count, MAX_PENALTY_SPAM_COUNT)
        var penalty = 1.0 - (effective_count * 0.05)
        var final_views = int(float(views) * penalty)
        return final_views
    
    return views