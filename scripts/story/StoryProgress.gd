class_name StoryProgress
## 剧情进度追踪系统
## 用于管理游戏五个章节的剧情里程碑完成状态

## 第一章：博客启蒙期（2001-2005）
var chapter1 = {
    "prologue_completed": false,      # [已实现] 开场动画完成：2001年12月冬夜，收到云起网络邮件
    "blog_online": false,              # [已实现] 博客正式上线：获得域名suiyan.cc和免费主机
    "first_article_posted": false,    # [已实现] 第一篇博文发布：写下《你好，世界》
    "sousuo_indexed": false,          # [已实现] 搜索引擎首次收录：博客被搜索引擎发现
    "blog_union_joined": true,       # [已实现] 加入博客联盟
    "first_friend_link": false,       # [已实现]第一个友链
    "rss_enabled": false,             # [已实现] 开通RSS订阅：获得第一批订阅者
    "first_article_favorited": false,  # [已实现] 第一次文章收藏：获得第一篇文章收藏
    "first_income": false,            # [已实现]加入广告联盟并收到第一笔广告收益
    "icp_filing_done": false,        # [已实现]网站备案完成：响应国家备案制度
    "award_2005": false,              # 博客优秀大奖（2005）：获得提名，称号"博客新星"
    "year_summary_2005": false,       # 2005年度总结：三年回顾
}

## 第二章：博客黄金期（2005-2010）
var chapter2 = {
    "literature_weekly": false,       # [已实现] 文学周刊发布：分享文学作品，解锁3级文章
    "code_weekly": false,              # [已实现] 程序员周刊发布：分享技术内容，解锁3级文章
    "rss_100": false,                 # RSS订阅突破100人：获得稳定读者群
    "weibo_joined": false,             # 微博账号开通：多平台同步内容
    "weibo_content_50": false,        # 微博同步发布50篇：称号"多平台博主"
    "income_1000": false,              # 累计收益达到1000元：商业化里程碑
    "year_summary_2010": false,        # 2010年度总结：五年回顾
    "award_2010": false,               # 博客优秀大奖（2010）：获得入围，称号"博客新锐"
}

## 第三章：博客转型期（2010-2015）
var chapter3 = {
    "viral_article": false,            # 爆款网文发布：热门文章达到4级写作
    "advanced_tutorial": false,        # 高级编程教程发布：深度技术内容达到4级
    "wechat_public": false,            # 微信公众号开通：自媒体布局
    "mobile_adapted": false,           # 网站移动端适配：响应式改造
    "https_upgraded": false,           # HTTPS升级：安装SSL证书保障安全
    "cloud_server": false,             # 云服务器迁移：从免费套餐升级到VPS
    "novel_planning": false,           # [已实现] 小说连载规划：开始出书前的长篇创作准备
    "open_source_planning": false,    # [已实现] 开源项目规划：开始开源前的项目规划
    "year_summary_2015": false,        # 2015年度总结：十年回顾
    "award_2015": false,               # 博客优秀大奖（2015）：获得第一名，称号"博客之星"
}

## 第四章：博客挑战期（2015-2020）
var chapter4 = {
    "novel_serial_start": false,      # [已实现] 小说连载开始：创作长篇故事
    "paid_hacking": false,             # [已实现] 付费黑客攻防发布：高级安全技术分享
    "book_invitation": false,          # [已实现] 出版邀请：收到出版商邀请，进入出书流程
    "book_writing": false,             # 书籍撰写中：记录写作进度
    "book_published": false,           # 书籍出版完成：里程碑①，称号"作家"
    "open_source_start": false,         # [已实现] 开源项目发布：贡献开源代码
    "open_source_recognized": false,   # [已实现] 开源获得认可：社区赞助商关注，称号"开发者"
    "cdn_enabled": false,              # CDN加速部署：提升网站访问速度
    "short_video": false,             # 短视频账号开通：抖音/短视频布局
    "ai_preview": false,               # AI辅助预告：ChatGPT即将发布
    "year_summary_2020": false,        # 2020年度总结：十五年回顾
    "award_2020": false,               # 博客优秀大奖（2020）：蝉联第一名，称号"博客传奇"
}

## 第五章：博客重塑期（2020-2025）
var chapter5 = {
    "ai_unlocked": false,              # AI辅助解锁：ChatGPT发布，解锁AI创作
    "ai_article_50": false,            # AI辅助创作50篇：称号"AI创作先锋"
    "game_dev_start": false,           # 游戏开发开始：文学+编程双满级后解锁
    "game_dev_complete": false,        # 游戏制作完成：游戏主体开发完成
    "game_test": false,                # 游戏测试优化：测试与优化阶段
    "video_account": false,            # 视频号开通：宣传游戏
    "game_trailer": false,             # 游戏预告发布：发布预告视频
    "personal_brand": false,           # 个人IP品牌：建立"游戏开发者"品牌
    "game_released": false,            # 游戏正式发布：上架发布，玩家涌入
    "game_award": false,              # 游戏大奖获得：站在领奖台上，称号"游戏大奖传奇"
    "fame_let_go": false,              # 看淡名利：站在巅峰回望，发现最重要的是成长
    "decline_award_2025": false,        # 拒绝博客大奖：选择不参加2025年博客大奖评比
    "return_to_roots": false,          # 回归博客本质：卸载数据分析工具，不再查看访问量
    "free_writing": false,             # 自由写作：想写什么就写什么，不考虑SEO流量收益
    "ending_achieved": false,          # 结局达成：从这里开始，不再有任务，只有表达
}

## 设置里程碑完成状态
## 根据章节号和里程碑名称标记任务完成
## @param chapter: 章节号（1-5）
## @param milestone: 里程碑名称（如"first_article_posted"）
func set_completed(chapter: int, milestone: String) -> void:
    var ch = _get_chapter_dict(chapter)
    if ch.is_empty():
        push_error("[StoryProgress] Unknown chapter: %d" % chapter)
        return
    if not ch.has(milestone):
        push_error("[StoryProgress] Unknown milestone '%s' in chapter %d" % [milestone, chapter])
        return
    ch[milestone] = true

## 检查里程碑是否已完成
## @param chapter: 章节号（1-5）
## @param milestone: 里程碑名称
## @return: 是否已完成，未知章节或里程碑返回false
func is_completed(chapter: int, milestone: String) -> bool:
    var ch = _get_chapter_dict(chapter)
    if ch.is_empty():
        return false
    return ch.get(milestone, false)

## 检查章节是否全部完成
## 当章节内所有里程碑都为true时返回true
## @param chapter: 章节号（1-5）
## @return: 章节是否完成
func chapter_completed(chapter: int) -> bool:
    var ch = _get_chapter_dict(chapter)
    if ch.is_empty():
        return false
    for key in ch:
        if ch[key] == false:
            return false
    return true

## 获取章节进度详情
## 计算章节内已完成和未完成的里程碑数量
## @param chapter: 章节号（1-5）
## @return: 包含completed、total、progress的字典
func get_chapter_progress(chapter: int) -> Dictionary:
    var ch = _get_chapter_dict(chapter)
    var completed = 0
    var total = ch.size()
    for key in ch:
        if ch[key]:
            completed += 1
    return {"completed": completed, "total": total, "progress": float(completed) / float(total) if total > 0 else 0.0}

## 重置章节进度
## 将章节内所有里程碑重置为false，用于新游戏或重新开始
## @param chapter: 章节号（1-5）
func reset_chapter(chapter: int) -> void:
    var ch = _get_chapter_dict(chapter)
    if ch.is_empty():
        return
    for key in ch:
        ch[key] = false

## 获取所有章节的进度
## 方便在UI上显示整体游戏进度
## @return: 包含五个章节进度的字典
func get_all_progress() -> Dictionary:
    return {
        "chapter1": get_chapter_progress(1),
        "chapter2": get_chapter_progress(2),
        "chapter3": get_chapter_progress(3),
        "chapter4": get_chapter_progress(4),
        "chapter5": get_chapter_progress(5),
    }

## 导出为存档字典
## 用于保存游戏进度，将所有章节数据复制为字典
## @return: 包含所有章节里程碑状态的字典
func to_dict() -> Dictionary:
    return {
        "chapter1": chapter1.duplicate(true),
        "chapter2": chapter2.duplicate(true),
        "chapter3": chapter3.duplicate(true),
        "chapter4": chapter4.duplicate(true),
        "chapter5": chapter5.duplicate(true),
    }

## 从存档字典恢复进度
## 加载游戏时使用，只更新已存在的键值
## @param data: 存档字典，包含章节里程碑状态
func from_dict(data: Dictionary) -> void:
    if data.has("chapter1"):
        _merge_dict(chapter1, data.chapter1)
    if data.has("chapter2"):
        _merge_dict(chapter2, data.chapter2)
    if data.has("chapter3"):
        _merge_dict(chapter3, data.chapter3)
    if data.has("chapter4"):
        _merge_dict(chapter4, data.chapter4)
    if data.has("chapter5"):
        _merge_dict(chapter5, data.chapter5)

## 合并字典数据
## 用于from_dict中，只更新target中已存在的键
## @param target: 目标字典（章节数据）
## @param source: 源字典（存档数据）
func _merge_dict(target: Dictionary, source: Dictionary) -> void:
    for key in source:
        if target.has(key):
            target[key] = source[key]

## 根据章节号获取对应的字典引用
## @param chapter: 章节号（1-5）
## @return: 对应章节的里程碑字典，无效章节返回空字典
func _get_chapter_dict(chapter: int) -> Dictionary:
    match chapter:
        1: return chapter1
        2: return chapter2
        3: return chapter3
        4: return chapter4
        5: return chapter5
        _:
            return {}

## 获取章节名称
## @param chapter: 章节号（1-5）
## @return: 章节名称
func get_chapter_name(chapter: int) -> String:
    match chapter:
        1: return "第一章：博客启蒙期（2001-2005）"
        2: return "第二章：博客黄金期（2005-2010）"
        3: return "第三章：博客转型期（2010-2015）"
        4: return "第四章：博客挑战期（2015-2020）"
        5: return "第五章：博客重塑期（2020-2025）"
        _: return "未知章节"

## 获取里程碑描述
## @param chapter: 章节号（1-5）
## @param milestone: 里程碑名称
## @return: 里程碑描述（如"第一篇博文发布：写下《你好，世界》"）
func get_milestone_description(chapter: int, milestone: String) -> String:
    var descriptions = {
        # 第一章
        "prologue_completed": "开场动画完成：2001年12月冬夜，收到云起网络邮件",
        "blog_online": "博客正式上线：获得域名suiyan.cc和免费主机",
        "first_article_posted": "第一篇博文发布：写下《你好，世界》",
        "baidu_indexed": "百度首次收录：博客被搜索引擎发现",
        "icp_filing_done": "网站备案完成：响应国家备案制度",
        "rss_enabled": "开通RSS订阅：获得第一批订阅者",
        "blog_union_joined": "加入博客联盟：认识第一个博友星光博客",
        "first_friend_link": "第一个友链：与星光博客交换链接",
        "ad_union_joined": "加入广告联盟：开始博客商业化尝试",
        "first_income": "第一笔广告收益：收到12.5元",
        "year_summary_2005": "2005年度总结：三年回顾",
        "award_2005": '博客优秀大奖（2005）：获得提名，称号"博客新星"',
        # 第二章
        "literature_weekly": "文学周刊发布：分享文学作品，解锁3级文章",
        "code_weekly": "程序员周刊发布：分享技术内容，解锁3级文章",
        "rss_100": "RSS订阅突破100人：获得稳定读者群",
        "weibo_joined": "微博账号开通：多平台同步内容",
        "weibo_content_50": '微博同步发布50篇：称号"多平台博主"',
        "income_1000": "累计收益达到1000元：商业化里程碑",
        "year_summary_2010": "2010年度总结：五年回顾",
        "award_2010": '博客优秀大奖（2010）：获得入围，称号"博客新锐"',
        # 第三章
        "viral_article": "爆款网文发布：热门文章达到4级写作",
        "advanced_tutorial": "高级编程教程发布：深度技术内容达到4级",
        "wechat_public": "微信公众号开通：自媒体布局",
        "mobile_adapted": "网站移动端适配：响应式改造",
        "https_upgraded": "HTTPS升级：安装SSL证书保障安全",
        "cloud_server": "云服务器迁移：从免费套餐升级到VPS",
        "novel_planning": "小说连载规划：开始出书前的长篇创作准备",
        "open_source_planning": "开源项目规划：开始开源前的项目规划",
        "year_summary_2015": "2015年度总结：十年回顾",
        "award_2015": '博客优秀大奖（2015）：获得第一名，称号"博客之星"',
        # 第四章
        "novel_serial_start": "小说连载开始：创作长篇故事",
        "paid_hacking": "付费黑客攻防发布：高级安全技术分享",
        "book_invitation": "出版邀请：收到出版商邀请，进入出书流程",
        "book_writing": "书籍撰写中：记录写作进度",
        "book_published": '书籍出版完成：里程碑①，称号"作家"',
        "open_source_start": "开源项目发布：贡献开源代码",
        "open_source_recognized": '开源获得认可：社区赞助商关注，称号"开发者"',
        "cdn_enabled": "CDN加速部署：提升网站访问速度",
        "short_video": "短视频账号开通：抖音/短视频布局",
        "ai_preview": "AI辅助预告：ChatGPT即将发布",
        "year_summary_2020": "2020年度总结：十五年回顾",
        "award_2020": '博客优秀大奖（2020）：蝉联第一名，称号"博客传奇"',
        # 第五章
        "ai_unlocked": "AI辅助解锁：ChatGPT发布，解锁AI创作",
        "ai_article_50": 'AI辅助创作50篇：称号"AI创作先锋"',
        "game_dev_start": "游戏开发开始：文学+编程双满级后解锁",
        "game_dev_complete": "游戏制作完成：游戏主体开发完成",
        "game_test": "游戏测试优化：测试与优化阶段",
        "video_account": "视频号开通：宣传游戏",
        "game_trailer": "游戏预告发布：发布预告视频",
        "personal_brand": '个人IP品牌：建立"游戏开发者"品牌',
        "game_released": "游戏正式发布：上架发布，玩家涌入",
        "game_award": '游戏大奖获得：站在领奖台上，称号"游戏大奖传奇"',
        "fame_let_go": "看淡名利：站在巅峰回望，发现最重要的是成长",
        "decline_award_2025": "拒绝博客大奖：选择不参加2025年博客大奖评比",
        "return_to_roots": "回归博客本质：卸载数据分析工具，不再查看访问量",
        "free_writing": "自由写作：想写什么就写什么，不考虑SEO流量收益",
        "ending_achieved": "结局达成：从这里开始，不再有任务，只有表达",
    }
    return descriptions.get(milestone, "未知里程碑: " + milestone)
