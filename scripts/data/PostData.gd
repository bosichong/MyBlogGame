## 文章数据结构
class_name PostData

## 唯一标识
var id: String = ""

## 文章标题
var title: String = ""

## 文章分类名（如：生活日记、小说连载）
var category: String = ""

## 任务类型（普通/节日/活动等）
var task_type: String = ""

## 文章大类（文学/技术/艺术）
var article_category: String = ""

## 内容形式（免费/付费/周刊等）
var content_type: String = ""

## 质量分
var quality: int = 100

## 总访问量
var views: int = 0

## 收藏数
var favorites: int = 0

## 评论数
var comments: int = 0

## 发布日期
var date: String = ""

## 是否收费
var is_money: bool = false

## 初始化
func _init(p_title: String = "", p_category: String = "", p_article_category: String = "", p_content_type: String = ""):
    id = _generate_id()
    title = p_title
    category = p_category
    article_category = p_article_category
    content_type = p_content_type
    date = Utils.format_date()

## 生成唯一ID
func _generate_id() -> String:
    return "post_" + str(Time.get_ticks_msec()) + "_" + str(randi() % 10000)

## 转换为字典（用于保存）
func to_dict() -> Dictionary:
    return {
        "id": id,
        "title": title,
        "category": category,
        "task_type": task_type,
        "article_category": article_category,
        "content_type": content_type,
        "quality": quality,
        "views": views,
        "favorites": favorites,
        "comments": comments,
        "date": date,
        "is_money": is_money
    }

## 从字典加载
static func from_dict(data: Dictionary) -> PostData:
    var post = PostData.new()
    post.id = data.get("id", 0)
    post.title = data.get("title", "")
    post.category = data.get("category", "")
    post.task_type = data.get("task_type", "")
    post.article_category = data.get("article_category", "")
    post.content_type = data.get("content_type", "")
    post.quality = data.get("quality", 100)
    post.views = data.get("views", 0)
    post.favorites = data.get("favorites", 0)
    post.comments = data.get("comments", 0)
    post.date = data.get("date", "")
    post.is_money = data.get("is_money", false)
    return post