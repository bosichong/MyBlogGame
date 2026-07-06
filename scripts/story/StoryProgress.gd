class_name StoryProgress
## 剧情进度追踪系统
## 用于管理游戏五个章节的剧情里程碑完成状态

signal chapter_reward_popup(chapter: int, chapter_name: String)

var _emitted_chapters: Array[int] = []

## 第一章：博客启蒙期（2001-2005）
var chapter1 = {
    "blog_online": true,              # 博客正式上线
    "first_article_posted": true,     # 第一篇博文发布
    "sousuo_indexed": true,           # 搜索引擎首次收录
    "blog_union_joined": true,        # 加入博客联盟
    "first_friend_link": true,        # 第一个友链
    "rss_enabled": true,              # 开通RSS订阅
    "first_article_favorited": true,  # 第一次文章收藏
    "first_income": true,             # 第一笔广告收益
    "icp_filing_done": true,          # 网站备案完成
    "award_2005": true,              # 优秀博客奖项（结果动态判定）
    "year_summary_2005": true,       # 2005年度总结
}

## 第二章：博客黄金期（2005-2010）
var chapter2 = {
    "literature_weekly": false,       # 文学周刊发布
    "code_weekly": false,             # 程序员周刊发布
    "rss_100": false,                 # RSS订阅突破百人
    "income_1000": false,             # 累计收益突破千元
    "award_2010": false,              # 优秀博客奖项（2010）
    "year_summary_2010": false,       # 2010年度总结
}

## 第三章：博客转型期（2010-2015）
var chapter3 = {
    "viral_article": false,           # 爆款文章诞生
    "advanced_tutorial": false,       # 高级教程发布
    "philosophy_critique": false,     # 哲学批判
    "geek_frontier": false,           # 极客前沿
    "wechat_public": false,           # 公众号开通
    "wechat_articles_200": false,     # 公众号累计发布200篇文章
    "mobile_adapted": false,          # 网站移动端适配
    "https_upgraded": false,          # HTTPS升级
    "novel_planning": false,          # 小说连载规划
    "open_source_planning": false,    # 开源项目规划
    "year_summary_2015": false,       # 2015年度总结
    "award_2015": false,              # 优秀博客奖项（2015）
}

## 第四章：博客挑战期（2015-2020）
var chapter4 = {
    "novel_serial_start": false,      # 小说连载开启
    "paid_hacking": false,            # 付费安全课程发布
    "book_invitation": false,         # 出版邀请
    "book_writing": false,            # 书籍撰写中
    "book_published": false,          # 书籍正式出版
    "open_source_start": false,       # 开源项目发布
    "open_source_recognized": false,  # 开源获得认可
    "cdn_enabled": false,             # CDN加速部署
    "ai_preview": false,              # AI时代预告
    "award_2020": false,              # 优秀博客奖项（2020）
    "year_summary_2020": false,       # 2020年度总结
}

## 第五章：博客重塑期（2020-2025）
var chapter5 = {
    "ai_unlocked": false,              # AI创作解锁
    "game_dev_start": false,           # 游戏开发启动
    "game_dev_complete": false,        # 游戏主体完成
    "game_test": false,                # 游戏测试优化
    "video_account": false,            # 视频号开通
    "game_trailer": false,             # 游戏预告发布
    "personal_brand": false,           # 个人品牌建立
    "game_released": false,            # 游戏正式发布
    "game_award": false,               # 游戏获奖
    "fame_let_go": false,              # 看淡名利（合并奖项与放弃参评）
    "return_to_roots": false,          # 回归初心（合并自由写作）
    "ending_achieved": false,          # 结局达成
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

    if chapter_completed(chapter):
        # 确保只触发一次（确认不是之前已经完成的章节）
        if not _emitted_chapters.has(chapter):
            _emitted_chapters.append(chapter)
            chapter_reward_popup.emit(chapter, get_chapter_name(chapter))

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
    _emitted_chapters.erase(chapter)

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

## 获取章节的所有里程碑（key -> 是否完成）
## @param chapter: 章节号（1-5）
## @return: 里程碑字典副本
func get_chapter_milestones(chapter: int) -> Dictionary:
    return _get_chapter_dict(chapter).duplicate()

## 获取章节名称
## @param chapter: 章节号（1-5）
## @return: 章节名称
func get_chapter_name(chapter: int) -> String:
    match chapter:
        1: return "第一章：博客启蒙期（2002-2005）"
        2: return "第二章：博客黄金期（2005-2010）"
        3: return "第三章：博客转型期（2010-2015）"
        4: return "第四章：博客挑战期（2015-2020）"
        5: return "第五章：博客重塑期（2020-2025）"
        _: return "未知章节"

## 获取里程碑描述
## @param chapter: 章节号（1-5）
## @param milestone: 里程碑名称
## @return: 里程碑描述
func get_milestone_description(chapter: int, milestone: String) -> String:
    # 奖项里程碑动态生成——读取 AwardManager 的实际结果
    var award_desc = _get_award_description(milestone)
    if award_desc:
        return award_desc

    var descriptions = {
        # 第一章
        "blog_online": "博客正式上线了，成功开启了博客生涯",
        "first_article_posted": "第一篇博文发布：记录下属于自己的第一段文字",
        "sousuo_indexed": "搜索引擎首次收录：博客开始被更多人看见",
        "blog_union_joined": "加入博客联盟：结识了第一批志同道合的博友",
        "first_friend_link": "第一个友链：与志同道合的博客交换了友情链接",
        "rss_enabled": "开通RSS订阅：迎来了第一批忠实订阅者",
        "first_article_favorited": "获得第一次文章收藏：文字得到了读者的认可",
        "first_income": "第一笔广告收益：收到了博客的第一笔收入",
        "icp_filing_done": "网站备案完成：迈出了合规运营的一步",
        "year_summary_2005": "2005年度总结：回望这四年，写下成长的足迹",
        # 第二章
        "literature_weekly": "文学周刊发布：用文字书写内心世界",
        "code_weekly": "程序员周刊发布：分享技术路上的思考",
        "rss_100": "RSS订阅突破百人：拥有了稳定的读者群",
        "income_1000": "累计收益突破千元：商业化迈上新台阶",
        "year_summary_2010": "2010年度总结：黄金五年，收获满满",
        # 第三章
        "viral_article": "爆款文章诞生：一篇好文让博客声名远扬",
        "advanced_tutorial": "高级教程发布：技术深度获得了读者认可",
        "philosophy_critique": "哲学批判发布：用思辨的视角审视技术与世界",
        "geek_frontier": "极客前沿发布：带你站在技术浪潮的最前端",
        "wechat_public": "公众号开通：开拓新的内容阵地",
        "wechat_articles_200": "公众号累计发布200篇文章：坚持不懈终有回响",
        "mobile_adapted": "网站移动端适配：让阅读不再受设备限制",
        "https_upgraded": "HTTPS升级：为读者提供更安全的访问",
        "novel_planning": "小说连载规划：开始筹备长篇创作",
        "open_source_planning": "开源项目规划：为社区贡献代码做准备",
        "year_summary_2015": "2015年度总结：转型路上，初心不改",
        # 第四章
        "novel_serial_start": "小说连载开启：用故事构建另一个世界",
        "paid_hacking": "付费安全课程发布：高级技术分享获得认可",
        "book_invitation": "出版邀请：收到出版社的合作邀约",
        "book_writing": "书籍撰写中：将积累化为文字",
        "book_published": "书籍正式出版：多年的博客精华凝聚成书",
        "open_source_start": "开源项目发布：代码贡献获得社区关注",
        "open_source_recognized": "开源获得认可：社区开始关注你的项目",
        "cdn_enabled": "CDN加速部署：网站访问速度大幅提升",
        "ai_preview": "AI时代预告：新一轮技术变革即将到来",
        "year_summary_2020": "2020年度总结：挑战与突破的五年",
        # 第五章
        "ai_unlocked": "AI创作解锁：借助AI开启全新的创作模式",
        "game_dev_start": "游戏开发启动：用代码构建心中的世界",
        "game_dev_complete": "游戏主体完成：从零到一，梦想成形",
        "game_test": "游戏测试优化：打磨每一处细节",
        "video_account": "视频号开通：用影像讲述创作故事",
        "game_trailer": "游戏预告发布：向世界展示你的作品",
        "personal_brand": "个人品牌建立：从博主到创作者的蜕变",
        "game_released": "游戏正式发布：作品终于与玩家见面",
        "game_award": "游戏获奖：站上领奖台，梦想照进现实",
        "fame_let_go": "看淡名利：奖项也好，排名也罢，唯有成长最珍贵",
        "return_to_roots": "回归初心：卸下数据焦虑，不为流量，只为表达",
        "ending_achieved": "结局达成：从今往后，不再有任务，只有热爱",
    }
    return descriptions.get(milestone, "未知里程碑: " + milestone)

## 奖项描述动态生成——通过 AwardManager 查询实际结果
func _get_award_description(milestone: String) -> String:
    var award_map = {
        "award_2005": {"ordinal": 1, "year": 2005},
        "award_2010": {"ordinal": 2, "year": 2010},
        "award_2015": {"ordinal": 3, "year": 2015},
        "award_2020": {"ordinal": 4, "year": 2020},
        "award_2025": {"ordinal": 5, "year": 2025, "milestone": "fame_let_go"},
    }
    if not award_map.has(milestone):
        return ""

    var info = award_map[milestone]
    var history = AwardManager._get_history()
    var result = AwardManager.AwardResult.NONE
    for entry in history:
        if entry.year == info.year:
            result = entry.result
            break

    var label = AwardManager.get_result_label(result)
    if label.is_empty():
        return "优秀博客奖项（%d）：奖项结果已揭晓" % info.year
    return "优秀博客奖项（%d）：%s" % [info.year, label]
