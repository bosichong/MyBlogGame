## 书籍销售加成修饰器
## 当书籍出版后，在销售期间（3年）给所有博客文章访问量带来加成
## 加成曲线：0-18月上升至100%，18-36月下降至0%
class_name BookSalesBoostModifier
extends ViewsModifier

func _init():
    modifier_name = "book_sales_boost"
    display_name = "畅销书加成"
    description = "出版畅销书后，博客文章访问量获得加成"
    priority = 270
    type = Type.BOOST

func apply(views: int, post: Dictionary, blogger: Dictionary) -> int:
    # 获取当前有效的书籍加成
    var total_bonus_ratio = _get_total_book_bonus_ratio()
    
    if total_bonus_ratio <= 0:
        return views
    
    # 应用加成
    var bonus = int(views * total_bonus_ratio)
    return views + bonus

## 获取所有出版书籍的总加成比例
func _get_total_book_bonus_ratio() -> float:
    var BookPublishData = load("res://data/book_publish.gd").new()
    if not BookPublishData:
        return 0.0
    
    var published_books = BookPublishData.published_books
    if published_books.is_empty():
        return 0.0
    
    var total_ratio = 0.0
    
    for book in published_books:
        if not book.get("published", false):
            continue
        
        var sales_months = book.get("sales_months", 0)
        if sales_months >= 36:  # 超过3年
            continue
        
        # 计算单本书的加成比例
        var book_ratio = _calculate_book_boost_ratio(sales_months)
        total_ratio += book_ratio
    
    # 多本书可以叠加，但上限200%
    return min(total_ratio, 2.0)

## 计算单本书的加成比例
## 曲线：0-18月上升至100%，18-36月下降至0%
func _calculate_book_boost_ratio(sales_months: int) -> float:
    if sales_months >= 36:
        return 0.0
    
    if sales_months <= 18:
        # 0-18月：线性上升 0% -> 100%
        return float(sales_months) / 18.0
    else:
        # 18-36月：线性下降 100% -> 0%
        return (36.0 - float(sales_months)) / 18.0

## 获取书籍加成信息（用于UI显示）
func get_book_boost_info() -> Dictionary:
    var BookPublishData = load("res://data/book_publish.gd").new()
    if not BookPublishData:
        return {"active": false, "total_ratio": 0.0, "books": []}
    
    var published_books = BookPublishData.published_books
    var active_books = []
    var total_ratio = 0.0
    
    for book in published_books:
        if not book.get("published", false):
            continue
        
        var sales_months = book.get("sales_months", 0)
        if sales_months >= 36:
            continue
        
        var ratio = _calculate_book_boost_ratio(sales_months)
        total_ratio += ratio
        
        active_books.append({
            "book_name": book.get("book_name", "未知"),
            "sales_months": sales_months,
            "boost_ratio": ratio,
            "boost_percent": int(ratio * 100)
        })
    
    return {
        "active": total_ratio > 0,
        "total_ratio": min(total_ratio, 2.0),
        "total_percent": int(min(total_ratio, 2.0) * 100),
        "books": active_books
    }