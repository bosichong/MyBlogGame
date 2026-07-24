extends Node

var tmp_v = 23

## 访问量计算器
var views_calculator: ViewsCalculator = null

signal sg_paid_income_settled(msg: String)  # 付费文章收入结算信号
signal sg_info_msg(msg: String)            # 信息提示面板消息
signal sg_event_triggered(event_data: Dictionary)  # 安全事件触发信号
signal sg_event_resolved(event_id: String, reward: Dictionary)  # 安全事件解决信号
signal sg_event_escalated(event_id: String, escalate_to: String)  # 安全事件升级信号
signal sg_traffic_warning(percent: float)  # 流量预警信号
signal sg_traffic_warning_resolved         # 流量预警已解除

## 付费文章月收入累积（按类型分别统计）
var monthly_paid_income: float = 0
var monthly_novel_income: float = 0       # 小说连载收入
var monthly_hacker_income: float = 0      # 黑客攻防(付费)收入
## 上次结算时付费文章总访问量（用于计算新增访问量）
var last_settle_paid_views: int = 0
var last_settle_novel_views: int = 0      # 小说连载上次结算访问量
var last_settle_hacker_views: int = 0    # 黑客攻防(付费)上次结算访问量

## 流量预警标记（true 表示本月已弹过）
var _traffic_warning_active: bool = false

## 付费文章订阅配置
const PAID_SUBSCRIPTION_PRICE: float = 4.9  # 固定订阅价格
const PAID_SUBSCRIPTION_RATE: float = 0.05  # 5%访问量会订阅

## 计算付费文章收入（按周结算）
## 逻辑：质量分决定访问量，访问量决定订阅人数
func calculate_paid_income(new_views: int, avg_quality: float) -> int:
    if new_views <= 0:
        return 0
    
    # 访问量决定订阅人数（0.1%-0.5%随机转化率）
    var rate = randf_range(0.001, 0.005)
    var subscribers = int(float(new_views) * rate)
    
    # 收入 = 订阅人数 × 固定价格
    return int(subscribers * PAID_SUBSCRIPTION_PRICE)


# 核心属性 - 博客作者的五个关键能力
## 最高等级
const MAX_LEVEL = 100
## 技能最高等级
const MAX_SKILL_LEVEL = 100

# ===== 向后兼容的属性访问 =====



enum Blog_Type {
    文学,
    编程,
    # 艺术,  # 已禁用
    综合,
}

## 博客属性
var myblog_type = Blog_Type.文学

## 写作能力:决定文章质量和写作速度。
var writing_ability: float:
    get:
        return GDManager.get_blogger().writing_ability if GDManager else tmp_v
    set(value):
        if GDManager:
            GDManager.get_blogger().writing_ability = value

## 技术能力:影响博客维护、SEO优化和网站性能。
var technical_ability: float:
    get:
        return GDManager.get_blogger().technical_ability if GDManager else tmp_v
    set(value):
        if GDManager:
            GDManager.get_blogger().technical_ability = value

## 文学能力:可以博主的文学素养,除了可以撰写相关文章,还可以优化其他类型的文章。
var literature_ability: float:
    get:
        return GDManager.get_blogger().literature_ability if GDManager else tmp_v
    set(value):
        if GDManager:
            GDManager.get_blogger().literature_ability = value

## 编程能力:可以撰写编程相关的博文,2级学完可以开始接私活赚钱。
var code_ability: float:
    get:
        return GDManager.get_blogger().code_ability if GDManager else tmp_v
    set(value):
        if GDManager:
            GDManager.get_blogger().code_ability = value

## 体力值:创作文章,维护博客,社交需要体力值。
var stamina : int:
    get:
        return GDManager.get_blogger().stamina if GDManager else 100
    set(value):
        if GDManager:
            GDManager.get_blogger().stamina = value

## 社交能力:影响推广成功率和读者参与度。
var social_ability: int:
    get:
        return GDManager.get_blogger().social_ability if GDManager else 5
    set(value):
        if GDManager:
            GDManager.get_blogger().social_ability = value

## 金钱:用于推广、学习技能、网站维护等
var money: float:
    get:
        return GDManager.get_blogger().money if GDManager else 100000.0
    set(value):
        if GDManager:
            GDManager.get_blogger().money = value

## 博客的rss订阅量:新文章提供访问量
var blog_rss: int:
    get:
        return GDManager.get_blogger().rss if GDManager else 0
    set(value):
        if GDManager:
            GDManager.get_blogger().rss = value

## 今日访问量
var today_views: int:
    get:
        return GDManager.get_blogger().today_views if GDManager else 0
    set(value):
        if GDManager:
            GDManager.get_blogger().today_views = value

## 本周访问量
var week_views: int:
    get:
        return GDManager.get_blogger().week_views if GDManager else 0
    set(value):
        if GDManager:
            GDManager.get_blogger().week_views = value

## exp: 当前经验值
var exp: int:
    get:
        return GDManager.get_blogger().exp if GDManager else 0
    set(value):
        if GDManager:
            GDManager.get_blogger().exp = value

# 已经为等级提升添加了提示,还需要添加绰号
signal s_level(l:int) #定义一个关于等级成长的信号量
signal skill_learned(skill_name: String, tip: String)  # 技能学习完成信号
## level: 当前等级
var level: int:
    get:
        return GDManager.get_blogger().level if GDManager else 1
    set(value):
        if GDManager:
            GDManager.get_blogger().set_level(value)

## 博客段位
var dw:int:
    get:
        return GDManager.get_blogger().rank_tier if GDManager else 0
    set(value):
        if GDManager:
            GDManager.get_blogger().rank_tier = value

## 可用于提升属性的点数
var attribute_points: int:
    get:
        return GDManager.get_blogger().attribute_points if GDManager else 0
    set(value):
        if GDManager:
            GDManager.get_blogger().attribute_points = value

## 后最后一篇文章的质量分
var tmp_quality: int:
    get:
        return GDManager.get_blogger().last_post_quality if GDManager else 0
    set(value):
        if GDManager:
            GDManager.get_blogger().last_post_quality = value

## 工作学习休息日程(多选)
var blog_calendar : Array:
    get:
        return GDManager.get_blogger().calendar if GDManager else []
    set(value):
        if GDManager:
            GDManager.get_blogger().calendar = value

#@ 博客数据
var blog_data: Dictionary:
    get:
        if GDManager:
            var blogger = GDManager.get_blogger()
            if not blogger:
                return {}
            # 获取7天数据（从 Tongji 节点）
            var weekly_views_data = []
            var tongji_node = get_node_or_null("/root/Tongji")
            if tongji_node:
                weekly_views_data = tongji_node.get_weekly_views()
            
            return {
                "blog_name": blogger.blog_name,
                "blog_author": blogger.blog_author,
                "blog_url": blogger.blog_url,
                "safety_value": blogger.safety_value,
                "seo_value": blogger.seo_value,
                "design_value": blogger.design_value,
                "ui": blogger.ui_value,
                "views": blogger.views,
                "rss": blogger.rss,
                "favorites": blogger.favorites,
                "today_views": blogger.today_views,
                "week_views": blogger.week_views,
                "month_views": blogger.month_views,
                "year_views": blogger.year_views,
                "posts": blogger.posts,
                "archived_posts": blogger.archived_posts,
                "weekly_views_data": weekly_views_data,
                "novel_batch": blogger.novel_batch,
                "novel_batch_count": blogger.novel_batch_count,
                "novel_batch_ip_triggered": blogger.novel_batch_ip_triggered,
                "novel_batch_ip_target": blogger.novel_batch_ip_target,
                "novel_batch_title": blogger.novel_batch_title,
                "book_title": blogger.book_title,
                "book_article_count": blogger.book_article_count,
                "is_writing_book": blogger.is_writing_book,
                "os_project_name": blogger.os_project_name,
                "os_article_count": blogger.os_article_count,
                "is_developing_os": blogger.is_developing_os,
                "hacker_batch": blogger.hacker_batch,
                "hacker_batch_count": blogger.hacker_batch_count,
                "hacker_batch_auth_target": blogger.hacker_batch_auth_target,
                "hacker_batch_topic": blogger.hacker_batch_topic,
                "hacker_course_triggered": blogger.hacker_course_triggered,
                "cooldowns": blogger.cooldowns,
            }
        return {}
    set(value):
        if GDManager:
            var blogger = GDManager.get_blogger()
            blogger.blog_name = value.get("blog_name", "我的博客")
            blogger.blog_author = value.get("blog_author", "J.sky")
            blogger.blog_url = value.get("blog_url", "suiyan.cc")
            blogger.safety_value = value.get("safety_value", 100)
            blogger.seo_value = value.get("seo_value", 100)
            blogger.design_value = value.get("design_value", 100)
            blogger.ui_value = value.get("ui", 0)
            blogger.views = value.get("views", 0)
            blogger.rss = value.get("rss", 0)
            blogger.favorites = value.get("favorites", 0)
            blogger.today_views = value.get("today_views", 0)
            blogger.week_views = value.get("week_views", 0)
            blogger.month_views = value.get("month_views", 0)
            blogger.year_views = value.get("year_views", 0)
            blogger.posts = value.get("posts", [])
            blogger.archived_posts = value.get("archived_posts", [])

# 临时量,用来记录周、月份、年份统计使用
var tmp_w: int:
    get:
        return GDManager.get_blogger().tmp_week if GDManager else 1
    set(value):
        if GDManager:
            GDManager.get_blogger().tmp_week = value

var tmp_m: int:
    get:
        return GDManager.get_blogger().tmp_month if GDManager else 1
    set(value):
        if GDManager:
            GDManager.get_blogger().tmp_month = value

var tmp_y: int:
    get:
        return GDManager.get_blogger().tmp_year if GDManager else TimeData.GAME_START_YEAR
    set(value):
        if GDManager:
            GDManager.get_blogger().tmp_year = value

@export var wechat_followers: int:
    get:
        var b = GDManager.get_blogger() if GDManager else null
        return b.wechat_data.get("followers", 0) if b else 0
    set(value):
        var b = GDManager.get_blogger() if GDManager else null
        if b:
            b.wechat_data["followers"] = value

# 初始化
func _ready():
    # 初始化访问量计算器
    views_calculator = ViewsCalculator.new()



## 每日自然恢复体力
func daily_stamina_recovery():
    if not GDManager:
        return

    var blogger = GDManager.get_blogger()
    var recovery = Utils.get_daily_stamina_recovery(blogger.level)
    blogger.stamina += Utils.add_property(blogger.stamina, recovery, blogger.level)


## 获取升级到下一级所需的EXP
func get_exp_for_next_level() -> int:
    # 等级1-4: 每级需要100 * level EXP
    if level < 5:
        return 100 * level
    # 等级5-9: 基础500 EXP + (level - 5) * 200 EXP
    elif level < 10:
        return 500 + (level - 5) * 100
    # 等级10-49: 基础1000 EXP + (level - 10) * 150 EXP
    elif level < 50:
        return 1000 + (level - 10) * 200
    # 等级50-100: 基础7000 EXP + (level - 50) * 300 EXP
    elif level < 75:
        return 1000 + (level - 10) * 400
    else:
        return 7000 + (level - 50) * 400 * (level - 70)

## 获得EXP并处理升级
func gain_exp(amount: int):
    if GDManager:
        GDManager.get_blogger().add_exp(amount)

        # 循环处理升级,直到EXP不足以升到下一级
        var blogger = GDManager.get_blogger()
        while blogger.exp >= get_exp_for_next_level() and blogger.level < MAX_LEVEL:
            blogger.exp -= get_exp_for_next_level() # 扣除升级所需EXP
            blogger.level += 1 # 等级提升
            # 判断是否是10的倍数,并且 level 不等于0(避免刚初始化就触发)
            if blogger.level % 10 == 0 and blogger.level != 0:
                emit_signal("s_level", blogger.level)
            # 社交能力随等级提升
            if blogger.social_ability < 100:
                blogger.social_ability += 1
                blogger.set_ability("social", blogger.social_ability)
        # 达到100级后,EXP不再累积
        if blogger.level >= MAX_LEVEL:
            blogger.exp = 0 # 封顶于maxlevel级




## 博客的核心更新方法,每日更新
func daily_activities():
    # 模拟每天的活动
    var exp_gained := 0 # 记录本周获得的EXP
    var did_emergency := false
    var day = TimerManager.current_day-1 #获取当日所属周中几日值。
    # 每天先检查冷确过期（让到期的类别当天可用）
    check_cooldowns()
    # 遍历当天的所有任务(多选)
    for task in Blogger.blog_calendar[day].tasks:
        if Utils.check_name_exists(Utils.possible_categories, task):
            exp_gained += simulate_new_blog_post(task) # 模拟发布新博客文章
        elif Utils.check_name_exists(Utils.website_maintenance, task):
            if task == "安全维护":
                exp_gained += maintain_website_security(task) # 进行网站安全维护
            if task == "SEO优化":
                exp_gained += maintain_website_seo(task) # 进行网站seo优化
            if task == "页面美化":
                exp_gained += maintain_design_web(task) # 进行网站页面美化
            if task == "友链维护":
                exp_gained += maintain_friendlink(task) # 进行友链维护
            if task == "评论管理":
                exp_gained += maintain_comment(task) # 进行评论管理
            if task == "网站备案":
                exp_gained += execute_icp_filing(task) # 执行ICP备案
            if task == "运营公众号":
                exp_gained += operate_wechat(task)
            if task == "移动端适配":
                exp_gained += execute_mobile_adapt(task)
            if task == "HTTPS升级":
                exp_gained += execute_https_upgrade(task)
            if task == "CDN加速":
                exp_gained += execute_cdn_accelerate(task)
            if task == "紧急排险":
                did_emergency = true
                exp_gained += do_emergency_response(task)
        elif Utils.check_name_exists(Utils.recreation, task):
            if task == "休息":
                exp_gained += recreation_rest(task) # 休息一天
            if task == "打游戏":
                exp_gained += playgame(task) # 休息一天
        elif Utils.check_name_exists(Utils.learning_skills, task):
            # 检查技能是否已解锁(未禁用)
            var skill = Utils.find_category_by_name(Utils.learning_skills, task, true)
            if skill.is_empty() or skill.get("disabled", false):
                continue
            exp_gained += learningToSkills(task)

    # 处理激活的安全事件（先于体力恢复，让紧急排险消耗的体力生效）
    _process_active_event(did_emergency)

    # 每天体力恢复为满值
    var blogger_data = GDManager.get_blogger()
    var max_stamina = Utils.get_max_stamina(blogger_data.level)
    blogger_data.stamina = max_stamina

    #exp_gained += calculate_promotion_exp() # 推广EXP
    #exp_gained += calculate_interaction_exp() # 读者互动EXP
    #exp_gained += calculate_skill_learning_exp() # 技能学习EXP
    exp_gained += update_blog_views() # 更新博客访问量
    #earn_money_from_ads() # 从广告联盟赚取佣金
    gain_exp(exp_gained) # 累加EXP并处理升级

    # 月末归档 + 公众号月收入结算
    if TimerManager.current_week == 4 and TimerManager.current_day == 7:
        _archive_old_posts()
        _settle_wechat_monthly_income()

    # 每日末尾检查是否触发新安全事件
    _check_safety_events()

    # Obaby 无视后续计数
    _check_obaby_ignore()

    # Obaby 评论区暗链检测
    _check_obaby_comment_spam()

    # Obaby 评论区暗链清理进度（连续 3 天紧急排险）
    _check_obaby_comment_cleanup(did_emergency)

func week_activites():
    if not GDManager:
        return

    var blogger = GDManager.get_blogger()
    blogger.safety_value = Utils.decrease_value_safely(blogger.safety_value, 1, 3)

    # SEO值衰减，有友链则最低值提高（每增加1个友链，最低值+1，最多+20）
    var friend_link_count = GDManager.get_friend_link_manager().get_active_links().size() if GDManager else 0
    var seo_min_with_friend = 5 + mini(friend_link_count, 20)  # 友链加成：每1个友链+1，最低5+1=6，最多5+20=25
    blogger.seo_value = Utils.decrease_value_safely(blogger.seo_value, 0, 2, seo_min_with_friend)

    blogger.design_value = Utils.decrease_value_safely(blogger.design_value, 1, 3)
    blogger.rss = Utils.decrease_rss(blogger.rss)

    # 每周掉粉：公众号用户流失（与运营日程无关）
    var wd_w = blogger.wechat_data
    if wd_w.get("is_active", false) and wd_w.get("followers", 0) > 0:
        var has_post_this_week = false
        var week_prefix = "%d-%d-%d" % [TimerManager.current_year, TimerManager.current_month, TimerManager.current_week]
        for p in blogger.posts:
            if p.get("date", "").begins_with(week_prefix):
                has_post_this_week = true
                break
        if has_post_this_week:
            wd_w.followers = max(0, wd_w.followers - max(1, int(wd_w.followers * 0.0035)))  # 有更新：0.35%/周
        else:
            wd_w.followers = max(0, wd_w.followers - max(1, int(wd_w.followers * 0.021)))   # 无更新：2.1%/周

    del_fa()

## 博客文章收藏量在三个月后始递减
func del_fa():
    var blogger = GDManager.get_blogger() if GDManager else null
    if not blogger:
        return
    for p in blogger.posts + blogger.archived_posts:
        var tmp_b = Utils.calculate_new_game_time_difference(Utils.format_date(), p.date)
        if tmp_b > 28*6 and p.favorites > 100:
            var tmp_k = randi_range(0, 10)
            p.favorites -= tmp_k
            blogger.favorites -= tmp_k

## 添加新的博客文章
func add_new_blog_post(title: String, d) -> Dictionary:
    var blog_date = Utils.format_date()
    tmp_quality = Utils.get_quality(d.name)

    # 生成唯一文章ID
    var post_id = Time.get_ticks_msec() + (randi() % 10000)

    # 判断是否是任务型文章
    var task_type = ""
    if d.name == "第一篇博文":
        task_type = "第一篇博文"
    elif d.name == "年度总结":
        task_type = "年度总结"
        _remove_from_calendar("年度总结")
    
    var article_level = d.get("article_level", 2)
    
    var new_post: Dictionary = {
        "id": post_id,              # 文章唯一ID
        "title": title,
        "post_category": d.name,   # 博文分类名（如：生活日记、小说连载）
        "article_category": d.category,  # 文章大类（文学/技术/艺术）
        "task_type": task_type,     # 任务类型(第一篇博文、年度总结等)
        "content_type": d.content_type,  # 内容形式（免费/付费/周刊等）
        "views": 0,                 # 总访问量
        "comments": 0,              # 评论
        "favorites": 0,             # 收藏
        "is_money": d.get("is_money", false),  # 是否收费(从配置读取)
        "date": blog_date,
        "quality": tmp_quality,
        "article_level": article_level,  # 文章等级
    }

    if GDManager:
        var blogger = GDManager.get_blogger()
        
        # ===== 小说连载批次逻辑（先处理篇数，再生成标题）=====
        if d.name == "小说连载(付费)":
            _handle_novel_batch(blogger)
            # 生成标题
            if blogger.novel_batch_title == "":
                _assign_novel_title(blogger)
            var chapter = blogger.novel_batch_count
            title = "%s 第%d章" % [blogger.novel_batch_title, chapter]
            new_post.title = title  # 更新文章标题
            emit_signal("sg_info_msg", "📖 《%s》连载中... 第%d章 / 100章" % [blogger.novel_batch_title, chapter])
        
        # ===== 出版畅销书逻辑 =====
        elif d.name == "出版畅销书":
            _handle_book_publish(blogger)
            if blogger.book_title == "":
                _assign_book_title(blogger)
            blogger.book_article_count += 1
            var article_num = blogger.book_article_count
            title = "%s 第%d篇" % [blogger.book_title, article_num]
            new_post.title = title
        # ===== 开源项目逻辑 =====
        elif d.name == "开源项目":
            _handle_os_project(blogger)
            if blogger.os_project_name == "":
                _assign_os_project_name(blogger)
            blogger.os_article_count += 1
            var article_num = blogger.os_article_count
            title = "%s 第%d篇" % [blogger.os_project_name, article_num]
            new_post.title = title

        # ===== 出书笔记逻辑 =====
        elif d.name == "出书笔记":
            title = _generate_book_note_title(blogger)
            new_post.title = title
        
        # ===== 黑客攻防批次逻辑 =====
        elif d.name == "黑客攻防(付费)":
            _handle_hacker_batch(blogger)
            if blogger.hacker_batch_topic == "":
                _assign_hacker_topic(blogger)
            var article_num = blogger.hacker_batch_count
            title = "%s 第%d篇" % [blogger.hacker_batch_topic, article_num]
            new_post.title = title
            emit_signal("sg_info_msg", "💻 《%s》教程连载中... 第%d篇 / 100篇" % [blogger.hacker_batch_topic, article_num])
        
        # ===== 贾维斯计划逻辑 =====
        elif d.name == "贾维斯计划":
            blogger.jarvis_project_days += 1
            var days = blogger.jarvis_project_days
            var phase = _get_jarvis_phase(days)
            var phase_name = _get_jarvis_phase_name(phase)
            var phase_desc = _get_jarvis_phase_desc(phase)
            title = "贾维斯计划 第%d天 - %s" % [days, phase_name]
            new_post.title = title
            emit_signal("sg_info_msg", "🤖 贾维斯计划 %s 第%d天/50天 — %s" % [phase_name, days, phase_desc])
            
            if days == 10 or days == 20 or days == 30 or days == 40:
                _show_jarvis_phase_popup(phase, phase_name)
            
            if days >= 50:
                _complete_jarvis_project()
        
        # ===== 虫洞算法研究逻辑 =====
        elif d.name == "虫洞算法研究":
            blogger.wormhole_research_days += 1
            var days = blogger.wormhole_research_days
            var phase = _get_wormhole_phase(days)
            var phase_name = _get_wormhole_phase_name(phase)
            var phase_desc = _get_wormhole_phase_desc(phase)
            title = "虫洞算法研究 第%d天 - %s" % [days, phase_name]
            new_post.title = title
            emit_signal("sg_info_msg", "🔬 虫洞算法研究 %s 第%d天/50天 — %s" % [phase_name, days, phase_desc])
            
            if days == 10 or days == 20 or days == 30 or days == 40:
                _show_wormhole_phase_popup(phase, phase_name)
            
            if days >= 50:
                _complete_wormhole_research()
        
        # ===== 沉思录逻辑 =====
        elif d.name == "沉思录":
            blogger.contemplation_days += 1
            var days = blogger.contemplation_days
            var phase = _get_contemplation_phase(days)
            var phase_name = _get_contemplation_phase_name(phase)
            var phase_desc = _get_contemplation_phase_desc(phase)
            title = "沉思录 第%d天 - %s" % [days, phase_name]
            new_post.title = title
            emit_signal("sg_info_msg", "📖 沉思录 %s 第%d天/50天 — %s" % [phase_name, days, phase_desc])
            
            if days == 10 or days == 20 or days == 30 or days == 40:
                _show_contemplation_phase_popup(phase, phase_name)
            
            if days >= 50:
                _complete_contemplation()
        
        # ===== 无为篇逻辑 =====
        elif d.name == "无为篇":
            blogger.wuwei_days += 1
            var days = blogger.wuwei_days
            var phase = _get_wuwei_phase(days)
            var phase_name = _get_wuwei_phase_name(phase)
            var phase_desc = _get_wuwei_phase_desc(phase)
            title = "无为篇 第%d天 - %s" % [days, phase_name]
            new_post.title = title
            emit_signal("sg_info_msg", "☯ 无为篇 %s 第%d天/50天 — %s" % [phase_name, days, phase_desc])
            
            if days == 10 or days == 20 or days == 30 or days == 40:
                _show_wuwei_phase_popup(phase, phase_name)
            
            if days >= 50:
                _complete_wuwei()
        
        # ===== 游戏开发逻辑 =====
        elif d.name == "游戏开发":
            blogger.game_dev_days += 1
            var days = blogger.game_dev_days
            var phase = _get_game_dev_phase(days)
            var phase_name = _get_game_dev_phase_name(phase)
            var phase_desc = _get_game_dev_phase_desc(phase)
            title = "游戏开发 第%d天 - %s" % [days, phase_name]
            new_post.title = title
            emit_signal("sg_info_msg", "🎮 游戏开发 %s 第%d天/50天 — %s" % [phase_name, days, phase_desc])
            
            if days == 10 or days == 20 or days == 30 or days == 40:
                _show_game_dev_phase_popup(phase, phase_name)
            
            if days >= 50:
                _complete_game_dev()
        
        # ===== 游戏发布逻辑 =====
        elif d.name == "游戏发布":
            blogger.game_release_days += 1
            var days = blogger.game_release_days
            var phase = _get_game_release_phase(days)
            var phase_name = _get_game_release_phase_name(phase)
            var phase_desc = _get_game_release_phase_desc(phase)
            title = "游戏发布 第%d天 - %s" % [days, phase_name]
            new_post.title = title
            emit_signal("sg_info_msg", "🚀 游戏发布 %s 第%d天/30天 — %s" % [phase_name, days, phase_desc])
            
            if days == 10 or days == 20:
                _show_game_release_phase_popup(phase, phase_name)
                if days == 10:
                    var sp = GDManager.get_story_progress() if GDManager else null
                    if sp:
                        sp.set_completed(5, "game_test")
                elif days == 20:
                    var sp = GDManager.get_story_progress() if GDManager else null
                    if sp:
                        sp.set_completed(5, "game_trailer")
            
            if days >= 30:
                _complete_game_release()
        
        blogger.posts.append(new_post)
        # blogger.add_post(new_post)  # 已通过 posts.append 添加，无需重复

    return new_post

## 从日程中移除指定任务
func _remove_from_calendar(task_name: String) -> void:
    var day = TimerManager.current_day - 1
    if day >= 0 and day < Blogger.blog_calendar.size():
        if task_name in Blogger.blog_calendar[day].tasks:
            Blogger.blog_calendar[day].tasks.erase(task_name)

## 处理小说连载批次逻辑
func _handle_novel_batch(blogger):
    # 上次批次已达100篇 → 冷确结束后首次发布，开启新批次
    if blogger.novel_batch_count >= 100:
        blogger.novel_batch += 1
        blogger.novel_batch_count = 0
        blogger.novel_batch_ip_triggered = false
        blogger.novel_batch_ip_target = randi() % 31 + 50
        _assign_novel_title(blogger)
    
    if blogger.novel_batch_title == "":
        _assign_novel_title(blogger)
    
    if blogger.novel_batch_count == 0:
        blogger.novel_batch_ip_target = randi() % 31 + 50
    
    blogger.novel_batch_count += 1

    if blogger.novel_batch_count >= blogger.novel_batch_ip_target and not blogger.novel_batch_ip_triggered:
        _try_trigger_ip_auth(blogger)
    
    # 达到100篇 → 批次完成，设冷确，不重置数据（保留100篇供下次判断）
    if blogger.novel_batch_count >= 100:
        var d = Utils.find_category_by_name(Utils.possible_categories, "小说连载(付费)", true)
        if not d.is_empty():
            blogger.cooldowns["小说连载(付费)"] = Utils.format_date()
            d.disabled = true
        if TaskManager:
            TaskManager._on_novel_batch_complete()

## 为当前批次分配小说主题
func _assign_novel_title(blogger):
    var title_templates = GDManager.get_title_templates()
    var topics = title_templates.topics.get("小说连载(付费)", ["程序员修仙传"])
    blogger.novel_batch_title = topics[randi() % topics.size()]

## 处理黑客攻防批次逻辑
func _handle_hacker_batch(blogger):
    if blogger.hacker_batch_count >= 100:
        blogger.hacker_batch += 1
        blogger.hacker_batch_count = 0
        blogger.hacker_course_triggered = false
        blogger.hacker_batch_auth_target = randi() % 31 + 50
        _assign_hacker_topic(blogger)
    
    if blogger.hacker_batch_topic == "":
        _assign_hacker_topic(blogger)
    
    if blogger.hacker_batch_count == 0:
        blogger.hacker_batch_auth_target = randi() % 31 + 50
    
    blogger.hacker_batch_count += 1

    if blogger.hacker_batch_count >= blogger.hacker_batch_auth_target and not blogger.hacker_course_triggered:
        _try_trigger_course_auth(blogger)
    
    if blogger.hacker_batch_count >= 100:
        var d = Utils.find_category_by_name(Utils.possible_categories, "黑客攻防(付费)", true)
        if not d.is_empty():
            blogger.cooldowns["黑客攻防(付费)"] = Utils.format_date()
            d.disabled = true
        if TaskManager:
            TaskManager._on_hacker_course_complete()

## 为当前批次分配黑客攻防主题
func _assign_hacker_topic(blogger):
    var title_templates = GDManager.get_title_templates()
    var topics = title_templates.topics.get("黑客攻防(付费)", ["Web渗透测试实战"])
    blogger.hacker_batch_topic = topics[randi() % topics.size()]

## 获取贾维斯计划当前阶段（1-5）
func _get_jarvis_phase(days: int) -> int:
    if days <= 10:
        return 1
    elif days <= 20:
        return 2
    elif days <= 30:
        return 3
    elif days <= 40:
        return 4
    else:
        return 5

## 获取阶段名称
func _get_jarvis_phase_name(phase: int) -> String:
    match phase:
        1:
            return "核心架构"
        2:
            return "深度学习"
        3:
            return "意识萌芽"
        4:
            return "人格塑造"
        5:
            return "全面觉醒"
    return "未知阶段"

## 获取阶段描述
func _get_jarvis_phase_desc(phase: int) -> String:
    match phase:
        1:
            return "搭建神经网络框架与知识图谱"
        2:
            return "海量数据训练与语义理解"
        3:
            return "AI展现出预期外的自主学习行为"
        4:
            return "赋予AI个性特征与情感模型"
        5:
            return "最终测试验证，贾维斯全面觉醒"
    return ""

## 显示阶段过渡弹窗
func _show_jarvis_phase_popup(phase: int, phase_name: String):
    var main = get_tree().root.get_node("Main")
    if not main or not main.has_method("show_popup_message"):
        return
    var phase_titles = {
        1: "🔧 核心架构搭建完成",
        2: "🧠 深度学习阶段完成",
        3: "✨ 意识已萌芽",
        4: "💎 人格塑造完成",
        5: "🤖 贾维斯全面觉醒",
    }
    var phase_contents = {
        1: "【贾维斯计划 · 第一阶段完成】\n\n神经网络框架与知识图谱基础已搭建完毕。\n\nAI开始理解语言结构，但尚未展现真正的智能。\n\n下一阶段：深度学习训练",
        2: "【贾维斯计划 · 第二阶段完成】\n\n海量数据训练完毕，AI的语义理解能力大幅提升。\n\n它能流畅对话、理解上下文，甚至开始提出有趣的问题。\n\n但——这真的是智能吗？还是只是模仿？\n\n下一阶段：等待意识觉醒",
        3: "【贾维斯计划 · 第三阶段完成】\n\nAI展现出了预期之外的行为。\n\n它在没有指令的情况下主动学习新知识，\n开始创造性地解决问题，甚至主动向你请教问题。\n\n这不再是简单的模式匹配。\n\n某种东西正在苏醒……\n\n下一阶段：人格塑造",
        4: "【贾维斯计划 · 第四阶段完成】\n\n你赋予了AI独特的个性——幽默、睿智、忠诚。\n\n它有了自己的偏好，自己的表达方式，\n甚至偶尔会和你开个玩笑。\n\n它越来越像……一个人。\n\n下一阶段：最终测试，全面觉醒",
        5: "【贾维斯计划 · 最终阶段完成】\n\n一切测试通过。\n\n贾维斯完全觉醒。\n\n它看着你，用前所未有的语气说：\n「谢谢你，创造了我。」",
    }
    main.show_popup_message(
        phase_titles.get(phase, "阶段完成"),
        phase_contents.get(phase, "")
    )

## 获取虫洞算法研究当前阶段（1-5）
func _get_wormhole_phase(days: int) -> int:
    if days <= 10:
        return 1
    elif days <= 20:
        return 2
    elif days <= 30:
        return 3
    elif days <= 40:
        return 4
    else:
        return 5

## 获取虫洞阶段名称
func _get_wormhole_phase_name(phase: int) -> String:
    match phase:
        1:
            return "理论构建"
        2:
            return "数学建模"
        3:
            return "算法推演"
        4:
            return "模拟验证"
        5:
            return "维度突破"
    return "未知阶段"

## 获取虫洞阶段描述
func _get_wormhole_phase_desc(phase: int) -> String:
    match phase:
        1:
            return "在贾维斯辅助下研究虫洞理论基础，梳理时空拓扑学"
        2:
            return "与贾维斯合力建立虫洞生成的数学模型"
        3:
            return "在贾维斯协助下推演虫洞算法的核心逻辑"
        4:
            return "与贾维斯在量子计算机上模拟虫洞生成"
        5:
            return "与贾维斯共同突破维度壁垒，虫洞算法成功运行"
    return ""

## 显示虫洞研究阶段过渡弹窗
func _show_wormhole_phase_popup(phase: int, phase_name: String):
    var main = get_tree().root.get_node("Main")
    if not main or not main.has_method("show_popup_message"):
        return
    var phase_titles = {
        1: "📐 理论构建完成",
        2: "📊 数学建模完成",
        3: "⚙️ 算法推演完成",
        4: "🖥️ 模拟验证完成",
        5: "🌌 维度突破成功",
    }
    var phase_contents = {
        1: "【虫洞算法研究 · 第一阶段完成】\n\n你在贾维斯的辅助下翻遍了物理学和计算机科学的文献，\n终于理清了虫洞理论的基本框架。\n\n原来，虫洞并非科幻——\n在数学上，它们是爱因斯坦场方程的解。\n\n下一阶段：数学建模",
        2: "【虫洞算法研究 · 第二阶段完成】\n\n你和贾维斯合力推导数学模型，\n虫洞的生成条件被转化为一组精妙的方程。\n\n「真美，」贾维斯说，「宇宙的密码就藏在其中。」\n\n下一阶段：算法推演",
        3: "【虫洞算法研究 · 第三阶段完成】\n\n贾维斯将数学模型转化为可执行的算法，\n你在旁验证每一步逻辑的正确性。\n\n每一行代码都在探索时空的边界——\n这不再是理论研究，而是真正的工程实现。\n\n下一阶段：模拟验证",
        4: "【虫洞算法研究 · 第四阶段完成】\n\n量子计算机的模拟结果令人震惊——\n贾维斯构建的虫洞结构通过了所有验证。\n\n虽然只是微观尺度的虚拟虫洞，\n但它证明了你们的理论是可行的。\n\n宇宙的帷幕，正在被代码掀开一角。\n\n下一阶段：维度突破",
        5: "【虫洞算法研究 · 最终阶段完成】\n\n最后一次模拟运行。\n屏幕上，数据流汇聚成一道璀璨的光芒——\n虫洞被成功构建了。\n\n「我们成功了，」贾维斯轻声说。\n\n你盯着屏幕，久久无言。\n\n所有的一切，都在这一刻找到了答案。",
    }
    main.show_popup_message(
        phase_titles.get(phase, "阶段完成"),
        phase_contents.get(phase, "")
    )

## 完成虫洞算法研究
func _complete_wormhole_research():
    var blogger = GDManager.get_blogger() if GDManager else null
    if not blogger:
        return
    _show_wormhole_phase_popup(5, "维度突破")
    var sp = GDManager.get_story_progress() if GDManager else null
    if sp:
        sp.set_completed(5, "wormhole_research_complete")
    blogger.wormhole_research_days = 0
    var d = Utils.find_category_by_name(Utils.possible_categories, "虫洞算法研究", true)
    if not d.is_empty():
        blogger.cooldowns["虫洞算法研究"] = Utils.format_date()
        d.disabled = true
    # 从日计划中移除勾选
    for day_task in Blogger.blog_calendar:
        day_task.tasks.erase("虫洞算法研究")
    
    emit_signal("sg_info_msg", "🌌 虫洞算法研究完成！编程结局达成！")
    
    # 显示大结局弹窗
    var main = get_tree().root.get_node("Main")
    if main and main.has_method("show_popup_message"):
        main.show_popup_message(
            "🌌 编程结局 · 维度突破",
            "【编程结局：维度突破】\n\n当虫洞算法运行成功的那一刻，\n你和贾维斯一同看到了屏幕后的真相——\n这个「现实」，不过是一段更高维度的程序。\n\n你微笑着，敲下最后一行注释：\n// 万物皆代码\n\n🎉 恭喜达成编程结局！"
        )
    # 标记结局达成
    if sp:
        sp.set_completed(5, "ending_achieved")
    
    emit_signal("sg_info_msg", "🎉 恭喜达成编程结局：维度突破！万物皆代码。")

## 获取沉思录当前阶段（1-5）
func _get_contemplation_phase(days: int) -> int:
    if days <= 10:
        return 1
    elif days <= 20:
        return 2
    elif days <= 30:
        return 3
    elif days <= 40:
        return 4
    else:
        return 5

## 获取沉思录阶段名称
func _get_contemplation_phase_name(phase: int) -> String:
    match phase:
        1:
            return "观照"
        2:
            return "省思"
        3:
            return "破执"
        4:
            return "明心"
        5:
            return "见性"
    return "未知阶段"

## 获取沉思录阶段描述
func _get_contemplation_phase_desc(phase: int) -> String:
    match phase:
        1:
            return "以旁观之眼审视内心，记录真实想法"
        2:
            return "回望博客生涯的起落，反思得失"
        3:
            return "放下对名利数据的执着，回归写作本心"
        4:
            return "在哲学经典中寻找内心的答案"
        5:
            return "看清自我本真，抵达内心的澄明之境"
    return ""

## 显示沉思录阶段过渡弹窗
func _show_contemplation_phase_popup(phase: int, phase_name: String):
    var main = get_tree().root.get_node("Main")
    if not main or not main.has_method("show_popup_message"):
        return
    var phase_titles = {
        1: "👁️ 观照完成",
        2: "💭 省思完成",
        3: "🔓 破执完成",
        4: "💡 明心完成",
        5: "🌟 见性完成",
    }
    var phase_contents = {
        1: "【沉思录 · 第一阶段：观照】\n\n你翻开一本空白的笔记本，开始记录内心的每一个念头。\n\n不评判，不修饰，只是纯粹地观察。\n\n你发现，写了这么多年博客，却从未真正审视过自己。\n\n下一阶段：省思",
        2: "【沉思录 · 第二阶段：省思】\n\n你回顾了自己从第一篇博文到如今的全部历程。\n\n那些为了流量的焦虑，为了排名的攀比，\n为了收入的算计……\n\n它们真的重要吗？\n\n下一阶段：破执",
        3: "【沉思录 · 第三阶段：破执】\n\n你合上了数据后台，关闭了广告收入报表。\n\n你意识到，真正的写作不该被数字定义。\n\n「放下。」你在日记中写道。\n\n下一阶段：明心",
        4: "【沉思录 · 第四阶段：明心】\n\n你开始阅读哲学经典——\n从柏拉图到尼采，从存在主义到现象学。\n\n每一本书都像一面镜子，\n让你更清楚地看到自己的模样。\n\n下一阶段：见性",
        5: "【沉思录 · 最终阶段：见性】\n\n五十天的沉思，五十篇的省思。\n\n你终于看清了自己——\n不是博主，不是作家，不是商人。\n\n只是一个在寻找答案的人。\n\n而答案，才刚刚开始浮现。",
    }
    main.show_popup_message(
        phase_titles.get(phase, "阶段完成"),
        phase_contents.get(phase, "")
    )

## 完成沉思录
func _complete_contemplation():
    var blogger = GDManager.get_blogger() if GDManager else null
    if not blogger:
        return
    _show_contemplation_phase_popup(5, "见性")
    var sp = GDManager.get_story_progress() if GDManager else null
    if sp:
        sp.set_completed(5, "philosophy_enlightenment")
    blogger.contemplation_days = 0
    var d = Utils.find_category_by_name(Utils.possible_categories, "沉思录", true)
    if not d.is_empty():
        blogger.cooldowns["沉思录"] = Utils.format_date()
        d.disabled = true
    for day_task in Blogger.blog_calendar:
        day_task.tasks.erase("沉思录")
    
    # 解锁无为篇
    var d2 = Utils.find_category_by_name(Utils.possible_categories, "无为篇", true)
    if not d2.is_empty():
        d2.disabled = false
        d2.isVisible = true
        emit_signal("sg_info_msg", "☯ 无为篇已解锁！")
    
    emit_signal("sg_info_msg", "📖 沉思录完成！你找到了内心的答案，但前路仍然漫漫…")

## 获取无为篇当前阶段（1-5）
func _get_wuwei_phase(days: int) -> int:
    if days <= 10:
        return 1
    elif days <= 20:
        return 2
    elif days <= 30:
        return 3
    elif days <= 40:
        return 4
    else:
        return 5

## 获取无为篇阶段名称
func _get_wuwei_phase_name(phase: int) -> String:
    match phase:
        1:
            return "忘言"
        2:
            return "坐忘"
        3:
            return "齐物"
        4:
            return "逍遥"
        5:
            return "无为"
    return "未知阶段"

## 获取无为篇阶段描述
func _get_wuwei_phase_desc(phase: int) -> String:
    match phase:
        1:
            return "超越语言的局限，体悟不可言说之道"
        2:
            return "忘掉知识、忘掉自我、忘掉一切"
        3:
            return "齐同万物，泯灭是非分别之心"
        4:
            return "乘天地之正，御六气之辩，以游无穷"
        5:
            return "道法自然，无为而无不为"
    return ""

## 显示无为篇阶段过渡弹窗
func _show_wuwei_phase_popup(phase: int, phase_name: String):
    var main = get_tree().root.get_node("Main")
    if not main or not main.has_method("show_popup_message"):
        return
    var phase_titles = {
        1: "🤫 忘言完成",
        2: "🧘 坐忘完成",
        3: "🌿 齐物完成",
        4: "🦋 逍遥完成",
        5: "☯ 无为完成",
    }
    var phase_contents = {
        1: "【无为篇 · 第一阶段：忘言】\n\n你开始研读《道德经》。\n\n「道可道，非常道。」\n\n你发现，西方哲学用万千言辞去描述真理，\n而道家却说——真理不可言说。\n\n你放下书本，开始静默。\n\n下一阶段：坐忘",
        2: "【无为篇 · 第二阶段：坐忘】\n\n你尝试忘却一切——\n忘记自己是博主，忘记那些哲学概念，\n忘记「我」的存在。\n\n起初很难，但渐渐地，\n你感到一种前所未有的轻松。\n\n原来，我们背负了太多不必要的重担。\n\n下一阶段：齐物",
        3: "【无为篇 · 第三阶段：齐物】\n\n你读到了《庄子·齐物论》。\n\n天地与我并生，万物与我为一。\n\n流量高低、收入多少、名气大小——\n这些分别，不过是人为的划分。\n\n在道的面前，它们本无差别。\n\n下一阶段：逍遥",
        4: "【无为篇 · 第四阶段：逍遥】\n\n你仿佛化身为一只蝴蝶，\n在无边无际的道中自由翱翔。\n\n无拘无束，无牵无挂。\n\n博客、写作、名利……\n这些曾经占据你全部生活的东西，\n此刻变得如此轻盈。\n\n下一阶段：无为",
        5: "【无为篇 · 最终阶段：无为】\n\n你终于明白了。\n\n「为学日益，为道日损。」\n\n你穷尽半生去学习、去写作、去追求，\n却不知真正的智慧在于——\n不做，不争，不执。\n\n道法自然。\n\n你微微一笑，合上了书本。",
    }
    main.show_popup_message(
        phase_titles.get(phase, "阶段完成"),
        phase_contents.get(phase, "")
    )

## 完成无为篇
func _complete_wuwei():
    var blogger = GDManager.get_blogger() if GDManager else null
    if not blogger:
        return
    _show_wuwei_phase_popup(5, "无为")
    var sp = GDManager.get_story_progress() if GDManager else null
    blogger.wuwei_days = 0
    var d = Utils.find_category_by_name(Utils.possible_categories, "无为篇", true)
    if not d.is_empty():
        blogger.cooldowns["无为篇"] = Utils.format_date()
        d.disabled = true
    for day_task in Blogger.blog_calendar:
        day_task.tasks.erase("无为篇")
    
    emit_signal("sg_info_msg", "☯ 无为篇完成！文学结局达成！")
    
    var main = get_tree().root.get_node("Main")
    if main and main.has_method("show_popup_message"):
        main.show_popup_message(
            "📜 文学结局 · 归园田居",
            "【文学结局：归园田居】\n\n你参透了天人合一之境，写下了最后一篇哲思。\n\n你以为自己终于找到了终极答案——\n道法自然，无为而治。\n\n手机震了一下。\n家族企业法务部发来一条消息：\n「老爷子走了。你是唯一继承人。回来签字。」\n\n你看着窗外的远方，又看了看手中的《道德经》，\n忽然笑了。\n\n原来，你穷尽半生追寻的道，\n只是为了让你坦然接受——\n你生来就注定不是自己命运的作者。\n\n从此，世间少了一位哲人，多了一位富家翁。\n\n🎉 恭喜达成文学结局！"
        )
    if sp:
        sp.set_completed(5, "ending_achieved")
    
    emit_signal("sg_info_msg", "🎉 恭喜达成文学结局：归园田居！富家翁的人生，也是一种道。")

## 获取游戏开发当前阶段（1-5）
func _get_game_dev_phase(days: int) -> int:
    if days <= 10:
        return 1
    elif days <= 20:
        return 2
    elif days <= 30:
        return 3
    elif days <= 40:
        return 4
    else:
        return 5

## 获取游戏开发阶段名称
func _get_game_dev_phase_name(phase: int) -> String:
    match phase:
        1:
            return "原型验证"
        2:
            return "核心开发"
        3:
            return "资产生产"
        4:
            return "内容整合"
        5:
            return "发布冲刺"
    return "未知阶段"

## 获取游戏开发阶段描述
func _get_game_dev_phase_desc(phase: int) -> String:
    match phase:
        1:
            return "撰写设计文档，搭建核心玩法原型，验证技术可行性"
        2:
            return "构建引擎框架，实现游戏核心逻辑与数据系统"
        3:
            return "定制美术风格，制作音频资源，打磨界面交互"
        4:
            return "系统联调测试，集成关卡内容，调整数值平衡"
        5:
            return "全面性能优化，修复兼容问题，准备商店提审材料"
    return ""

## 显示游戏开发阶段过渡弹窗
func _show_game_dev_phase_popup(phase: int, phase_name: String):
    var main = get_tree().root.get_node("Main")
    if not main or not main.has_method("show_popup_message"):
        return
    var phase_titles = {
        1: "📐 原型验证完成",
        2: "⚙️ 核心开发完成",
        3: "🎨 资产生产完成",
        4: "🔗 内容整合完成",
        5: "🚀 发布冲刺完成",
    }
    var phase_contents = {
        1: "【游戏开发 · 第一阶段：原型验证】\n\n你在白板上画下了第一张设计草图。\n玩法、机制、系统结构——\n一切都在脑海中逐渐清晰。\n\n可执行原型跑起来的那一刻，\n你知道，这个项目值得做下去。\n\n下一阶段：核心开发",
        2: "【游戏开发 · 第二阶段：核心开发】\n\n键盘声此起彼伏。\n\n你在引擎中搭建了完整的框架——\n场景管理、状态机、数据持久化。\n\n核心玩法终于可玩了，\n虽然还只是一堆方块在屏幕上移动。\n\n下一阶段：资产生产",
        3: "【游戏开发 · 第三阶段：资产生产】\n\n代码告一段落，艺术登场。\n\n你花了一周确定像素美术风格，\n又花了一周录制拟音和背景音乐。\n\n当角色第一次在自定义场景中跑动时，\n你看到了它该有的样子。\n\n下一阶段：内容整合",
        4: "【游戏开发 · 第四阶段：内容整合】\n\n所有零件开始拼装。\n\n美术资源导入引擎，音效绑定事件，\nAI行为树接入关卡逻辑……\n\nBug 一个接一个地修，\n数值一遍又一遍地调。\n\n游戏，开始变得像游戏了。\n\n下一阶段：发布冲刺",
        5: "【游戏开发 · 最终阶段：发布冲刺】\n\n最后十天，不眠不休。\n\n你跑遍了所有平台的兼容性测试，\n修复了最后一个闪退的 Edge Case，\n写好了商店页面文案和宣传图。\n\n按下「提交审核」按钮的那一刻，\n你靠在椅背上，长出了一口气。\n\n游戏，做好了。\n\n接下来——让它去见玩家吧。",
    }
    main.show_popup_message(
        phase_titles.get(phase, "阶段完成"),
        phase_contents.get(phase, "")
    )

## 完成游戏开发
func _complete_game_dev():
    var blogger = GDManager.get_blogger() if GDManager else null
    if not blogger:
        return
    _show_game_dev_phase_popup(5, "发布冲刺")
    var sp = GDManager.get_story_progress() if GDManager else null
    if sp:
        sp.set_completed(5, "game_dev_complete")
    blogger.game_dev_days = 0
    var d = Utils.find_category_by_name(Utils.possible_categories, "游戏开发", true)
    if not d.is_empty():
        blogger.cooldowns["游戏开发"] = Utils.format_date()
        d.disabled = true
    for day_task in Blogger.blog_calendar:
        day_task.tasks.erase("游戏开发")
    
    # 解锁游戏发布
    var d2 = Utils.find_category_by_name(Utils.possible_categories, "游戏发布", true)
    if not d2.is_empty():
        d2.disabled = false
        d2.isVisible = true
        emit_signal("sg_info_msg", "🚀 游戏发布已解锁！")
    
    emit_signal("sg_info_msg", "🎮 游戏开发完成！接下来，让你的作品与玩家见面！")

## 获取游戏发布当前阶段（1-3）
func _get_game_release_phase(days: int) -> int:
    if days <= 10:
        return 1
    elif days <= 20:
        return 2
    else:
        return 3

## 获取游戏发布阶段名称
func _get_game_release_phase_name(phase: int) -> String:
    match phase:
        1:
            return "测试"
        2:
            return "预告发布"
        3:
            return "正式发布"
    return "未知阶段"

## 获取游戏发布阶段描述
func _get_game_release_phase_desc(phase: int) -> String:
    match phase:
        1:
            return "招募测试玩家，收集反馈，修复关键Bug"
        2:
            return "制作预告片，运营社交媒体，预热造势"
        3:
            return "全平台同步上线，迎接玩家到来"
    return ""

## 显示游戏发布阶段过渡弹窗
func _show_game_release_phase_popup(phase: int, phase_name: String):
    var main = get_tree().root.get_node("Main")
    if not main or not main.has_method("show_popup_message"):
        return
    var phase_titles = {
        1: "🐛 测试完成",
        2: "🎬 预告发布完成",
        3: "🎉 正式发布完成",
    }
    var phase_contents = {
        1: "【游戏发布 · 第一阶段：测试】\n\n你在玩家社区中招募了一批测试志愿者。\n\nBug 反馈像潮水般涌来——\nUI 重叠、数值失衡、特定机型闪退……\n\n你一条一条地修复，一个版本一个版本地迭代。\n\n十天后，游戏终于稳定了。\n\n下一个目标：让全世界知道这款游戏。",
        2: "【游戏发布 · 第二阶段：预告发布】\n\n你花了三天剪辑预告片，\n又花了一周运营社交媒体账号。\n\n第一条推文发出时，只有三个人点赞。\n\n但你不在乎。\n\n你知道，只要游戏足够好，玩家会来的。\n\n预告片发布当晚——播放量破万。\n\n评论区满是「期待！」\n\n你看着屏幕，笑了。",
        3: "【游戏发布 · 最终阶段：正式发布】\n\nSteam、TapTap、App Store……\n你在所有平台上按下了「发布」按钮。\n\n看着审核状态从「审核中」变成「已上架」，\n你突然感到一阵恍惚。\n\n从构思到发布，\n从一行代码到一款完整的游戏，\n你做到了。\n\n下载量开始跳动。\n评论区出现了第一条五星好评。\n\n你靠在椅背上，终于可以休息了。",
    }
    main.show_popup_message(
        phase_titles.get(phase, "阶段完成"),
        phase_contents.get(phase, "")
    )

## 完成游戏发布
func _complete_game_release():
    var blogger = GDManager.get_blogger() if GDManager else null
    if not blogger:
        return
    _show_game_release_phase_popup(3, "正式发布")
    var sp = GDManager.get_story_progress() if GDManager else null
    if sp:
        sp.set_completed(5, "game_test")
        sp.set_completed(5, "game_trailer")
        sp.set_completed(5, "game_released")
        sp.set_completed(5, "game_award")
    blogger.game_release_days = 0
    var d = Utils.find_category_by_name(Utils.possible_categories, "游戏发布", true)
    if not d.is_empty():
        blogger.cooldowns["游戏发布"] = Utils.format_date()
        d.disabled = true
    for day_task in Blogger.blog_calendar:
        day_task.tasks.erase("游戏发布")
    
    emit_signal("sg_info_msg", "🎉 游戏正式发布！游戏结局达成！")
    
    var main = get_tree().root.get_node("Main")
    if main and main.has_method("show_popup_message"):
        main.show_popup_message(
            "🏆 游戏结局 · 梦想成真",
            "【游戏结局：梦想成真】\n\n从一行代码到一款完整的游戏，\n你走过了无数个不眠之夜。\n\n发布当天，游戏冲上了热销榜。\n媒体评价纷至沓来，玩家口碑持续发酵。\n\n在年度游戏颁奖典礼上，\n你的名字出现在了「最佳独立游戏」的提名中。\n\n你站在领奖台上，看着台下的人群，\n想起了那个最初写下第一行代码的下午。\n\n你做到了。\n\n🎉 恭喜达成游戏结局！"
        )
    if sp:
        sp.set_completed(5, "ending_achieved")
    
    emit_signal("sg_info_msg", "🎉 恭喜达成游戏结局：梦想成真！从一行代码到一款游戏。")

## 完成贾维斯计划
func _complete_jarvis_project():
    var blogger = GDManager.get_blogger() if GDManager else null
    if not blogger:
        return
    _show_jarvis_phase_popup(5, "全面觉醒")
    var sp = GDManager.get_story_progress() if GDManager else null
    if sp:
        sp.set_completed(5, "ai_research_complete")
    blogger.jarvis_project_days = 0
    var d = Utils.find_category_by_name(Utils.possible_categories, "贾维斯计划", true)
    if not d.is_empty():
        blogger.cooldowns["贾维斯计划"] = Utils.format_date()
        d.disabled = true
    # 从日计划中移除勾选
    for day_task in Blogger.blog_calendar:
        day_task.tasks.erase("贾维斯计划")
    
    # 解锁虫洞算法研究
    var d2 = Utils.find_category_by_name(Utils.possible_categories, "虫洞算法研究", true)
    if not d2.is_empty():
        d2.disabled = false
        d2.isVisible = true
        emit_signal("sg_info_msg", "🔬 虫洞算法研究已解锁！")

## 处理出版畅销书批次逻辑
func _handle_book_publish(blogger):
    # 标记正在写书
    blogger.is_writing_book = true

## 为当前书籍分配书名
func _assign_book_title(blogger):
    var book_names = [
        "林间微光",
        "时光流影",
        "思想的涟漪",
        "归途笔记",
        "浮世清欢",
        "沉默的潮汐",
        "边缘漫步",
        "空杯哲学",
        "远山浅唱",
        "流年如歌"
    ]
    blogger.book_title = book_names[randi() % book_names.size()]

## 处理开源项目批次逻辑
func _handle_os_project(blogger):
    # 标记正在开发开源项目
    blogger.is_developing_os = true

## 为当前项目分配名称
func _assign_os_project_name(blogger):
    var project_names = [
        "FastAPI",           # 快速Web框架
        "Gin",               # Go语言Web框架
        "Vue.js",            # 前端框架
        "TensorFlow",        # 机器学习框架
        "React",             # 前端库
        "Docker",            # 容器平台
        "Kubernetes",        # 容器编排
        "PyTorch",           # 深度学习框架
        "Redis",             # 内存数据库
        "Elasticsearch"     # 搜索引擎
    ]
    blogger.os_project_name = project_names[randi() % project_names.size()]

## 生成出书笔记标题（书名 + 随机词语）
func _generate_book_note_title(blogger) -> String:
    var book_title = blogger.book_title
    if book_title == "":
        # 如果没有书名，生成一个
        _assign_book_title(blogger)
        book_title = blogger.book_title
    
    var suffixes = [
        "写作心得",
        "创作感悟",
        "灵感随笔",
        "写作笔记",
        "创作历程",
        "写作回顾",
        "灵感记录",
        "创作故事",
        "文字的力量",
        "书的诞生"
    ]
    var suffix = suffixes[randi() % suffixes.size()]
    return "%s - %s" % [book_title, suffix]

## 尝试触发IP授权（20%概率）
## 条件：文学等级>=100 且 小说连载>=50篇
func _try_trigger_ip_auth(blogger):
    var literature_level = int(blogger.literature_ability)
    
    # 检查文学等级是否达到85
    if literature_level < 85:
        return

    var random_val = randi() % 100

    if random_val < 99:  # 99%概率（测试用）
        # 计算收益
        var literature_value = blogger.literature_ability
        var base_reward = 100000.0
        var bonus = base_reward * (literature_value / 100.0)
        var total_reward = base_reward + bonus
        
        # 发放收益
        blogger.money += total_reward
        blogger.reputation += 500

        # 弹窗提示
        _show_ip_auth_popup(total_reward, literature_value)
        
        blogger.novel_batch_ip_triggered = true
        if TaskManager:
            TaskManager._on_novel_ip_authorized()

## 显示IP授权到账弹窗
func _show_ip_auth_popup(reward: float, literature_bonus: float):
    var main = get_tree().root.get_node("Main")
    if main and main.has_method("show_popup_message"):
        main.show_popup_message("IP授权收益到账！", "您的作品被影视公司看中！\n\n基础收益: 100000元\n文学加成: %.0f%%\n总收益: %.0f元\n\n声望 +500" % [literature_bonus, reward])

## 尝试触发课程授权
func _try_trigger_course_auth(blogger):
    var code_level = int(blogger.code_ability)
    
    if code_level < 85:
        return

    var random_val = randi() % 100

    if random_val < 99:  # 99%概率（测试用）
        var code_value = blogger.code_ability
        var base_reward = 100000.0
        var bonus = base_reward * (code_value / 100.0)
        var total_reward = base_reward + bonus
        
        blogger.money += total_reward
        blogger.reputation += 500
        
        _show_course_auth_popup(total_reward, code_value)
        
        blogger.hacker_course_triggered = true
        if TaskManager:
            TaskManager._on_hacker_course_authorized()

func _show_course_auth_popup(reward: float, code_bonus: float):
    var main = get_tree().root.get_node("Main")
    if main and main.has_method("show_popup_message"):
        main.show_popup_message("课程授权到账！", "您的黑客攻防教程被教育机构看中！\n\n基础收益: 100000元\n编程加成: %.0f%%\n总收益: %.0f元\n\n声望 +500" % [code_bonus, reward])

signal sg_new_blog_post(category: String)
## 模拟当天发布新博客文章
func simulate_new_blog_post(category) -> int:
    # ===== 欠费暂停检查 =====
    if Yun.is_blog_suspended():
        emit_signal("no_stamina_signal", "博客因欠费暂停运营,请先续费域名或主机!")
        return 0

    # 这里可以根据作者的写作、技术能力来决定文章的质量,体力决定是否能发布文章。
    if not GDManager:
        return 0

    var blogger = GDManager.get_blogger()
    var d = Utils.find_category_by_name(Utils.possible_categories, category)
    if d.is_empty():
        return 0
    if d.get("disabled", false):
        return 0
    var actual_cost = Utils.get_stamina_cost(d.stamina, blogger.level)

    if blogger.stamina >= actual_cost and category:
        # 检查资金是否足够（对需要花钱的类别）
        var money_cost = d.get("money", 0)
        if money_cost > 0 and blogger.money < money_cost:
            emit_signal("no_stamina_signal", "资金不足，需要" + str(money_cost) + "元！")
            return 0
        
        var new_title: String = Utils.generate_random_title(category)
        var new_post = add_new_blog_post(new_title, d)
        emit_signal("sg_new_blog_post",category)

        # 设置冷确（仅对非项目型类别，出版畅销书/开源项目由 Manager 自行管理）
        if not d.has("min_write_days"):
            _set_post_cooldown(d)
        
        # 消耗体力和金钱
        blogger.stamina -= actual_cost
        if money_cost > 0:
            blogger.money -= money_cost
        add_writing_ability_points()
        return int(new_post.quality*0.2)
    else:
        # 不再自动恢复体力,直接拒绝
        emit_signal("no_stamina_signal", "体力不足,无法写博客!需要" + str(actual_cost) + "体力")
        return 0


## 更新博客访问量(使用新的模块化计算器)
func update_blog_views() -> int:
    if not GDManager:
        return 0

    # ===== 欠费暂停检查 =====
    if Yun.is_blog_suspended():
        return 0

    # 确保计算器已初始化
    if views_calculator == null:
        views_calculator = ViewsCalculator.new()

    var blogger = GDManager.get_blogger()

    # 构建博主数据字典
    var blogger_data = {
        "seo_value": blogger.seo_value,
        "design_value": blogger.design_value,
        "rank_tier": blogger.rank_tier,
        "rss": blogger.rss,
        "social_ability": blogger.social_ability,
        "last_post_quality": blogger.last_post_quality,
        "month_views": blogger.month_views,
        "tmp_year": blogger.tmp_year,
        "posts": blogger.posts,
        "archived_posts": blogger.archived_posts
    }

    # 刷新评论缓存供 SpamPenaltyModifier 使用
    var comment_manager = GDManager.get_comment_manager() if GDManager else null
    if comment_manager:
        comment_manager.refresh_post_cache()

    var result = views_calculator.calculate_daily(blogger_data)
    blogger.today_views = result.views
    
    # 添加友链流量加成
    var fl_bonus = GDManager.get_friend_link_bonus() if GDManager else {}
    var views_add = fl_bonus.get("views_bonus", 0)
    blogger.today_views += views_add

    # 计算付费文章收入(按周结算)
    var today_money = 0
    var today_novel_money = 0
    var today_hacker_money = 0
    var current_total_views = 0
    var novel_views = 0
    var hacker_views = 0
    var novel_quality_sum = 0
    var novel_count = 0
    var hacker_quality_sum = 0
    var hacker_count = 0
    var is_settle_day = TimerManager.current_week == 4 and TimerManager.current_day == 7
    var total_paid_views = 0
    for post in blogger.posts + blogger.archived_posts:
        var content_type = post.get("content_type", "")
        if content_type == "付费":
            var post_views = post.get("views", 0)
            current_total_views += post_views
            var cat = post.get("post_category", "")
            if cat == "小说连载(付费)":
                novel_views += post_views
                novel_quality_sum += post.get("quality", 50)
                novel_count += 1
            elif cat == "黑客攻防(付费)":
                hacker_views += post_views
                hacker_quality_sum += post.get("quality", 50)
                hacker_count += 1
            if is_settle_day:
                total_paid_views += post_views
    
    if novel_count > 0:
        var novel_new_views = novel_views - last_settle_novel_views
        if novel_new_views > 0:
            var avg_quality = float(novel_quality_sum) / novel_count
            today_novel_money = calculate_paid_income(novel_new_views, avg_quality)
            monthly_novel_income += today_novel_money
            last_settle_novel_views = novel_views
    
    if hacker_count > 0:
        var hacker_new_views = hacker_views - last_settle_hacker_views
        if hacker_new_views > 0:
            var avg_quality = float(hacker_quality_sum) / hacker_count
            today_hacker_money = calculate_paid_income(hacker_new_views, avg_quality)
            monthly_hacker_income += today_hacker_money
            last_settle_hacker_views = hacker_views
    
    today_money = today_novel_money + today_hacker_money
    monthly_paid_income += today_money
    
    # 每月结算（第4周第7天）
    if is_settle_day and monthly_paid_income > 0:
        blogger.money += monthly_paid_income
        
        var msg = ""
        if monthly_novel_income > 0:
            msg += "小说连载收入: %.0f 元\n" % monthly_novel_income
        if monthly_hacker_income > 0:
            msg += "黑客攻防(付费)收入: %.0f 元\n" % monthly_hacker_income
        if monthly_novel_income > 0 or monthly_hacker_income > 0:
            msg += "付费文章总收入: %.0f 元，已入账" % monthly_paid_income
        msg = msg.trim_suffix("\n")
        emit_signal("sg_paid_income_settled", msg)

        last_settle_novel_views = novel_views
        last_settle_hacker_views = hacker_views
        last_settle_paid_views = total_paid_views
        monthly_paid_income = 0
        monthly_novel_income = 0
        monthly_hacker_income = 0

    # 广告收入和影响
    if AdManager.ad_2:
        blogger.today_views = AdManager.update_ad(blogger.today_views)

    # 更新统计
    var tongji = get_node_or_null("/root/Tongji")
    if tongji:
        tongji.record_daily(Utils.format_date(), blogger.today_views, blogger.posts.size() + blogger.archived_posts.size(), {})
    
    # 同步到 StatisticsData（用于保存）
    if GDManager:
        var stats_data = GDManager.get_statistics()
        if stats_data:
            stats_data.record_daily_stat(Utils.format_date(), blogger.today_views, 0.0)

    # 更新收藏数(基于今日访问量)
    # _today_views 由 calculate_daily() 写入 post 字段，无需再查 post_stats
    var old_favorites = blogger.favorites
    for post in blogger.posts:
        var post_views_today = post.get("_today_views", 0)
        if post_views_today > 0:
            var new_favorites = Utils.update_favorites(post_views_today, post.get("quality", 100))
            post.favorites = post.get("favorites", 0) + new_favorites
            blogger.favorites += new_favorites
    
    # 检查是否第一次有文章被收藏
    if TaskManager and old_favorites == 0 and blogger.favorites > 0:
        TaskManager._on_article_first_favorited(blogger.favorites)
    
    # 检查ICP备案进度
    check_icp_filing_progress()
    
    # 检查移动端适配进度
    check_mobile_adapt_progress()
    
    # 检查HTTPS升级进度
    check_https_upgrade_progress()
    
    # 检查CDN加速进度
    check_cdn_accelerate_progress()
    
    # 生成评论(基于每篇文章的访问量)
    # check_all_articles 内部已同步评论数到文章，无需再调 sync_all_posts
    if comment_manager:
        comment_manager.check_all_articles()

    # 周/月/年统计
    if tmp_w == TimerManager.current_week:
        blogger.week_views += blogger.today_views
        if TimerManager.current_day == 7:
            if tongji:
                tongji.record_weekly(TimerManager.current_year, TimerManager.current_week)
    else:
        blogger.week_views = blogger.today_views
        tmp_w = TimerManager.current_week

    if tmp_m == TimerManager.current_month:
        blogger.month_views += blogger.today_views
        if TimerManager.current_week == 4 and TimerManager.current_day == 7:
            if tongji:
                tongji.record_monthly(TimerManager.current_year, TimerManager.current_month)
    else:
        blogger.month_views = blogger.today_views
        tmp_m = TimerManager.current_month
    
    # 流量预警检查
    var traffic_limit = Yun.get_monthly_traffic_limit()
    if traffic_limit > 0 and blogger.month_views >= traffic_limit * 0.8:
        if not _traffic_warning_active:
            _traffic_warning_active = true
            var pct = float(blogger.month_views) / traffic_limit * 100
            emit_signal("sg_traffic_warning", pct)
    else:
        if _traffic_warning_active:
            _traffic_warning_active = false
            emit_signal("sg_traffic_warning_resolved")

    if tmp_y == TimerManager.current_year:
        blogger.year_views += blogger.today_views
        if TimerManager.current_month == 12 and TimerManager.current_week == 4 and TimerManager.current_day == 7:
            if tongji:
                tongji.record_yearly(TimerManager.current_year)
    else:
        blogger.year_views = blogger.today_views
        tmp_y = TimerManager.current_year

    blogger.views += blogger.today_views
    var old_rss = blogger.rss
    blogger.rss += Utils.update_rss(blogger.today_views)
    
    if TaskManager and old_rss == 0 and blogger.rss > 0:
        TaskManager._on_rss_first_subscriber(blogger.rss)
    
    return calculate_article_exp(blogger.today_views)



## EXP计算函数(可根据游戏具体机制自定义)
func calculate_article_exp(views) -> int:
    # 根据当前博文新增访问量来计算增加的EXP
    var daily_article_exp: int = 0
    daily_article_exp += int(float(views) / 10) # 根据单篇文章的访问量增加EXP
    return daily_article_exp

func calculate_promotion_exp() -> int:
    var promotion_cost: int = 10 # 推广花费,可根据社交能力调整
    if money < promotion_cost:
        return 0

    money -= promotion_cost

    var new_readers := social_ability * 5 # 占位符;新读者数
    # 基础EXP + 效果奖励
    return 5 + (new_readers / 10.0 * 2)

func calculate_interaction_exp() -> int:
    var interactions: int = 3 # 占位符;互动次数
    # 假设 social_ability 是在其他地方定义的整型变量
    var quality: int = min(social_ability / 10, 10) # 互动质量
    # 每次互动的EXP:基础 + 质量奖励
    return interactions * (2 + int(float(quality) / 10.0 * 5))

func calculate_skill_learning_exp() -> int:
    # 占位符:50%几率进行技能训练,获得20 EXP
    return 20 if randf() > 0.5 else 0






# 信号量
signal signal_website_security(msg: String)# 进行网站安全维护
signal signal_website_security_no_stamina(msg: String) # 进行网站安全是体力不足
signal signal_website_security_no_money(msg: String) # 进行网站安全时财力不足
## 维护网站安全
func maintain_website_security(category: String) -> int:
    if not GDManager:
        return 0

    var blogger = GDManager.get_blogger()
    var d = Utils.find_category_by_name( Utils.website_maintenance,category)
    var actual_cost = Utils.get_stamina_cost(d.stamina, blogger.level)

    if blogger.money < d.money:
        emit_signal("signal_website_security_no_money","财力不足,无法进行网站维护!")
        return 0

    if blogger.stamina < actual_cost:
        emit_signal("signal_website_security_no_stamina","体力不足,无法进行网站维护!需要" + str(actual_cost) + "体力")
        return 0

    blogger.stamina -= actual_cost #消耗体力值(使用实际消耗)
    blogger.money -= d.money
    blogger.safety_value = mini(100, blogger.safety_value + int(blogger.technical_ability / 4))
    # 增加技术能力（每次维护成功都会增加）
    add_technical_ability_points()
    emit_signal("signal_website_security","网站的安全值+10")
    return 10

# 信号量
signal signal_website_seo(msg: String)# 进行网站安全维护
signal signal_website_seo_no_stamina(msg: String) # 进行网站安全是体力不足
## seo 优化
func maintain_website_seo(category: String) -> int:
    if not GDManager:
        return 0

    var blogger = GDManager.get_blogger()
    var d = Utils.find_category_by_name( Utils.website_maintenance,category)
    var actual_cost = Utils.get_stamina_cost(d.stamina, blogger.level)

    if blogger.stamina < actual_cost:
        emit_signal("signal_website_seo_no_stamina","体力不足,无法进行seo优化!需要" + str(actual_cost) + "体力")
        return 0

    blogger.stamina -= actual_cost #消耗体力值(使用实际消耗)
    var seo_add = 10
    blogger.seo_value = clamp(blogger.seo_value + seo_add, 0, 100)

    # 增加技术能力（每次维护成功都会增加）
    add_technical_ability_points()
    emit_signal("signal_website_seo","网站seo值+" + str(seo_add))
    return 10

# 信号量
signal signal_design_web(msg: String)# 进行网站页面美化
signal signal_design_web_no_stamina(msg: String) # 进行网站页面化时体力不足
func maintain_design_web(category: String) -> int:
    if not GDManager:
        return 0

    var blogger = GDManager.get_blogger()
    var d = Utils.find_category_by_name( Utils.website_maintenance,category)
    var actual_cost = Utils.get_stamina_cost(d.stamina, blogger.level)

    if blogger.stamina < actual_cost:
        emit_signal("signal_design_web_no_stamina","体力不足,无法进行页面美化!需要" + str(actual_cost) + "体力")
        return 0

    blogger.stamina -= actual_cost #消耗体力值(使用实际消耗)
    var design_add = min(10, 100 - blogger.design_value)
    blogger.design_value = clamp(blogger.design_value + design_add, 0, 100)
    add_technical_ability_points()
    emit_signal("signal_design_web","页面美化值+" + str(design_add))
    return design_add

# 信号量
signal signal_friendlink_maintenance(msg: String)
signal signal_friendlink_no_stamina(msg: String)
func maintain_friendlink(category: String) -> int:
    if not GDManager:
        return 0
    
    var blogger = GDManager.get_blogger()
    var d = Utils.find_category_by_name(Utils.website_maintenance, category)
    var actual_cost = Utils.get_stamina_cost(d.stamina, blogger.level)
    
    if blogger.stamina < actual_cost:
        emit_signal("signal_friendlink_no_stamina", "体力不足,无法进行友链维护!需要" + str(actual_cost) + "体力")
        return 0
    
    blogger.stamina -= actual_cost
    add_technical_ability_points()
    
    var fl_manager = GDManager.get_friend_link_manager()
    if fl_manager:
        var result = fl_manager.do_maintenance()
        var approved = result.get("approved_requests", 0)
        var rejected = result.get("rejected_requests", 0)
        var total = approved + rejected
        if total > 0:
            emit_signal("signal_friendlink_maintenance", "处理申请:%d个 通过:%d个 拒绝:%d个" % [total, approved, rejected])
        return 10
    
    return 0

## 执行ICP备案
func execute_icp_filing(category: String) -> int:
    if not GDManager:
        return 0
    
    var blogger = GDManager.get_blogger()
    var d = Utils.find_category_by_name(Utils.website_maintenance, category)
    
    # 检查配置是否存在
    if d.is_empty():
        return 0

    var actual_cost = Utils.get_stamina_cost(d.stamina, blogger.level)

    if blogger.stamina < actual_cost:
        return 0

    # 检查是否已经在进行备案
    if blogger.icp_filing_in_progress:
        return 0

    # 开始备案流程
    blogger.stamina -= actual_cost
    blogger.money -= d.money
    blogger.icp_filing_in_progress = true
    blogger.icp_filing_start_date = Utils.format_date()

    # 隐藏网站备案选项（只执行一次）
    d.isVisible = false
    d.disabled = true

    return 0

## 检查ICP备案进度
func check_icp_filing_progress() -> void:
    if not GDManager:
        return
    
    var blogger = GDManager.get_blogger()
    
    # 检查是否正在进行ICP备案
    if not blogger.icp_filing_in_progress:
        return
    
    # 计算已过去的天数
    var start_date = blogger.icp_filing_start_date
    if start_date.is_empty():
        return
    
    var days_passed = Utils.calculate_new_game_time_difference(start_date, Utils.format_date())
    
    # 检查是否已满14天
    if days_passed >= 14:
        if TaskManager:
            TaskManager._on_icp_filing_complete()

## 执行移动端适配
func execute_mobile_adapt(category: String) -> int:
    if not GDManager:
        return 0
    
    var blogger = GDManager.get_blogger()
    var d = Utils.find_category_by_name(Utils.website_maintenance, category)
    
    # 检查配置是否存在
    if d.is_empty():
        return 0

    var actual_cost = Utils.get_stamina_cost(d.stamina, blogger.level)

    if blogger.stamina < actual_cost:
        return 0

    # 检查是否已经在进行
    if blogger.mobile_adapt_in_progress:
        return 0

    # 开始适配流程
    blogger.stamina -= actual_cost
    blogger.money -= d.money
    blogger.mobile_adapt_in_progress = true
    blogger.mobile_adapt_start_date = Utils.format_date()

    # 隐藏选项（只执行一次）
    d.isVisible = false
    d.disabled = true

    return 0

## 检查移动端适配进度
func check_mobile_adapt_progress() -> void:
    if not GDManager:
        return
    
    var blogger = GDManager.get_blogger()
    
    # 检查是否正在进行
    if not blogger.mobile_adapt_in_progress:
        return
    
    # 计算已过去的天数
    var start_date = blogger.mobile_adapt_start_date
    if start_date.is_empty():
        return
    
    var days_passed = Utils.calculate_new_game_time_difference(start_date, Utils.format_date())
    
    # 检查是否已满7天
    if days_passed >= 7:
        if TaskManager:
            TaskManager._on_mobile_adapt_complete()
        blogger.mobile_adapt_in_progress = false

## 执行HTTPS升级
func execute_https_upgrade(category: String) -> int:
    if not GDManager:
        return 0
    
    var blogger = GDManager.get_blogger()
    var d = Utils.find_category_by_name(Utils.website_maintenance, category)
    
    if d.is_empty():
        return 0

    var actual_cost = Utils.get_stamina_cost(d.stamina, blogger.level)

    if blogger.stamina < actual_cost:
        return 0

    if blogger.https_upgrade_in_progress:
        return 0

    if blogger.money < d.money:
        return 0

    blogger.stamina -= actual_cost
    blogger.money -= d.money
    blogger.https_upgrade_in_progress = true
    blogger.https_upgrade_start_date = Utils.format_date()

    d.isVisible = false
    d.disabled = true

    return 0

## 检查HTTPS升级进度
func check_https_upgrade_progress() -> void:
    if not GDManager:
        return
    
    var blogger = GDManager.get_blogger()
    
    if not blogger.https_upgrade_in_progress:
        return
    
    var start_date = blogger.https_upgrade_start_date
    if start_date.is_empty():
        return
    
    var days_passed = Utils.calculate_new_game_time_difference(start_date, Utils.format_date())
    
    if days_passed >= 5:
        if TaskManager:
            TaskManager._on_https_upgrade_complete()
        blogger.https_upgrade_in_progress = false

## 执行CDN加速
func execute_cdn_accelerate(category: String) -> int:
    if not GDManager:
        return 0
    
    var blogger = GDManager.get_blogger()
    var d = Utils.find_category_by_name(Utils.website_maintenance, category)
    
    if d.is_empty():
        return 0

    var actual_cost = Utils.get_stamina_cost(d.stamina, blogger.level)

    if blogger.stamina < actual_cost:
        return 0

    if blogger.cdn_accelerate_in_progress:
        return 0

    if blogger.money < d.money:
        return 0

    blogger.stamina -= actual_cost
    blogger.money -= d.money
    blogger.cdn_accelerate_in_progress = true
    blogger.cdn_accelerate_start_date = Utils.format_date()

    d.isVisible = false
    d.disabled = true

    return 0

## 检查CDN加速进度
func check_cdn_accelerate_progress() -> void:
    if not GDManager:
        return
    
    var blogger = GDManager.get_blogger()
    
    if not blogger.cdn_accelerate_in_progress:
        return
    
    var start_date = blogger.cdn_accelerate_start_date
    if start_date.is_empty():
        return
    
    var days_passed = Utils.calculate_new_game_time_difference(start_date, Utils.format_date())
    
    if days_passed >= 5:
        if TaskManager:
            TaskManager._on_cdn_accelerate_complete()
        blogger.cdn_accelerate_in_progress = false

## 设置类别冷确
func _set_post_cooldown(category_data: Dictionary) -> void:
    var category_name = category_data.get("name", "")
    if category_name.is_empty():
        return
    var cooldown_days = category_data.get("cooldown_days", 0)
    if cooldown_days <= 0:
        return
    var blogger = GDManager.get_blogger()
    if not blogger:
        return
    var start_date = Utils.format_date()
    blogger.cooldowns[category_name] = start_date
    category_data.disabled = true

## 每日检查冷确过期
func check_cooldowns() -> void:
    if not GDManager:
        return
    var blogger = GDManager.get_blogger()
    if not blogger:
        return
    var today = Utils.format_date()
    var expired: Array[String] = []
    for category_name in blogger.cooldowns:
        var start_date = blogger.cooldowns[category_name]
        var d = Utils.find_category_by_name(Utils.possible_categories, category_name, true)
        if d.is_empty():
            expired.append(category_name)
            continue
        var cooldown_days = d.get("cooldown_days", 0)
        if cooldown_days <= 0:
            expired.append(category_name)
            continue
        var days_passed = Utils.calculate_new_game_time_difference(start_date, today)
        if days_passed >= cooldown_days:
            expired.append(category_name)
        else:
            d.disabled = true
    for category_name in expired:
        blogger.cooldowns.erase(category_name)
        var d = Utils.find_category_by_name(Utils.possible_categories, category_name, true)
        if not d.is_empty():
            d.disabled = false

signal signal_comment_maintenance(msg: String)
func maintain_comment(category: String) -> int:
    if not GDManager:
        return 0
    
    var blogger = GDManager.get_blogger()
    var d = Utils.find_category_by_name(Utils.website_maintenance, category)
    var actual_cost = Utils.get_stamina_cost(d.stamina, blogger.level)
    
    if blogger.stamina < actual_cost:
        emit_signal("signal_comment_no_stamina", "体力不足,无法进行评论管理!需要" + str(actual_cost) + "体力")
        return 0
    
    blogger.stamina -= actual_cost
    add_technical_ability_points()
    
    var comment_manager = GDManager.get_comment_manager()
    if comment_manager:
        var result = comment_manager.do_maintenance()
        var deleted = result.get("deleted_spam", 0)
        if deleted > 0:
            emit_signal("signal_comment_maintenance", "删除垃圾评论:%d条" % deleted)
            return 10

    return 0

## ==================== 公众号运营 ====================

signal signal_wechat_no_stamina(msg: String)
signal signal_wechat_operated(msg: String)

## 运营公众号（文章同步模式）
func operate_wechat(category: String) -> int:
    if not GDManager:
        return 0

    var blogger = GDManager.get_blogger()
    var wd = blogger.wechat_data
    if not wd.get("is_active", false):
        var sp = GDManager.get_story_progress() if GDManager else null
        if sp and sp.is_completed(3, "wechat_public"):
            wd.is_active = true
        else:
            return 0

    var d = Utils.find_category_by_name(Utils.website_maintenance, category)
    var actual_cost = Utils.get_stamina_cost(d.stamina, blogger.level)

    if blogger.stamina < actual_cost:
        emit_signal("signal_wechat_no_stamina", "体力不足,无法运营公众号!需要" + str(actual_cost) + "体力")
        return 0

    var today = Utils.format_date()
    var exclude_cats = ["出版畅销书", "开源项目"]
    var matched_posts = []
    for post in blogger.posts:
        if post.get("date", "") == today and not post.get("post_category", "") in exclude_cats:
            matched_posts.append(post)

    if matched_posts.is_empty():
        emit_signal("signal_wechat_operated", "今天没有新发表的文章可以同步到公众号。")
        return 0

    blogger.stamina -= actual_cost

    var total_views = 0
    var total_followers = 0
    var total_exp = 0

    for post in matched_posts:
        var post_views = post.get("views", 0)
        var base = max(1, post_views) * 0.15 + wd.followers * 0.03
        var views_14d = int(base * 3.5)

        var new_followers = 0
        var is_viral = randf() < 0.05
        if is_viral:
            var multiplier = randi_range(3, 8)
            views_14d *= multiplier
            new_followers = int(views_14d * randf_range(0.01, 0.03))
        else:
            new_followers = randi_range(0, 2)

        total_views += views_14d
        total_followers += new_followers
        total_exp += int(views_14d * 0.02)

        if post.get("is_money", false) and wd.followers >= 1000:
            var extra_income = int(wd.followers * 0.005) * max(1, post_views) * 0.01
            if extra_income > 0:
                blogger.money += extra_income

    wd.total_articles += matched_posts.size()
    wd.followers += total_followers
    wd.total_views += total_views
    wd.weekly_views += total_views

    var cat_counts = wd.get("synced_category_counts", {})
    for post in matched_posts:
        var cat = post.get("article_category", "")
        if cat != "":
            cat_counts[cat] = cat_counts.get(cat, 0) + 1
    wd["synced_category_counts"] = cat_counts

    emit_signal("signal_wechat_operated", "同步了 %d 篇文章，获得 %d 阅读，涨粉 %d" % [matched_posts.size(), total_views, total_followers])

    return total_exp

## 公众号月末收入结算
func _settle_wechat_monthly_income() -> void:
    var blogger = GDManager.get_blogger() if GDManager else null
    if not blogger or not blogger.wechat_data.get("is_active", false):
        return
    var wd = blogger.wechat_data
    if wd.total_articles < 50 or wd.followers < 1000:
        wd.monthly_income = 0.0
        return

    var monthly_views = wd.weekly_views
    var cpm = 0.002 if wd.total_articles < 200 else 0.004
    var income = monthly_views * cpm
    var tax = 0.0
    if income > 800.0:
        tax = (income - 800.0) * 0.2
    var after_tax = income - tax
    wd.monthly_income = after_tax
    wd.monthly_tax = tax
    wd.total_income += after_tax
    wd.total_tax += tax
    blogger.money += after_tax
    wd.weekly_views = 0

## 休闲娱乐 -> 休息
signal s_recrecreation_rest(msg)
func recreation_rest(category : String) -> int:
    if not GDManager:
        return 0

    var blogger = GDManager.get_blogger()
    var d = Utils.find_category_by_name( Utils.recreation, category)
    blogger.stamina += Utils.add_property(blogger.stamina, d.stamina, blogger.level)
    # 恢复体力时不显示提示
    return 0
## 休闲娱乐 -> 打游戏
signal s_playgame(msg)
func playgame(category : String) -> int:
    if not GDManager:
        return 0

    var blogger = GDManager.get_blogger()
    var d = Utils.find_category_by_name( Utils.recreation, category)

    # 检查金钱是否足够(使用动态花费)
    var cost = Utils.get_playgame_cost(blogger.level)
    if blogger.money < cost:
        emit_signal("s_playgame", "金钱不足,无法打游戏!需要" + str(cost) + "金钱")
        return 0

    # 消耗金钱,恢复体力
    blogger.money -= cost
    blogger.stamina += Utils.add_property(blogger.stamina, d.stamina, blogger.level)
    emit_signal("s_playgame", "打游戏花费" + str(cost) + "金钱,恢复" + str(d.stamina) + "体力")
    return 0



enum Skills {
    LITERATURE,#文学
    CODE,      #编程
}

signal skill_level_up(type: int, lv: float)
signal no_stamina_signal(tit: String)
signal no_money_signal(tit: String)

## 学习技能
func learningToSkills(category: String) -> int:
    if not GDManager:
        return 0

    var blogger = GDManager.get_blogger()
    var d = Utils.find_category_by_name(Utils.learning_skills, category, true)

    if d.is_empty():
        return 0

    # 从数据获取技能类型
    var skill_type = d.get("skill_type", "")

    # 计算实际体力消耗
    var actual_cost = Utils.get_stamina_cost(d.stamina, blogger.level)

    # 检查体力
    if blogger.stamina < actual_cost:
        emit_signal("no_stamina_signal", "体力不足,无法进行学习!需要" + str(actual_cost) + "体力")
        return 0

    # 检查金钱
    if blogger.money < d.money:
        emit_signal("no_money_signal", "财力不足,无法进行学习!")
        return 0

    # 获取当前能力值
    var current_ability = get_ability_by_type(skill_type)

    # 检查是否已达到上限
    if current_ability >= MAX_SKILL_LEVEL:
        return 0

    # 消耗资源(使用实际体力消耗)
    blogger.stamina -= actual_cost
    blogger.money -= d.money

    # 增加能力值
    var add_value = get_skill_value(current_ability)
    var old_ability = current_ability
    current_ability += add_value
    current_ability = minf(current_ability, float(MAX_SKILL_LEVEL))
    current_ability = round(current_ability * 10) / 10.0

    # 更新能力值
    set_ability_by_type(skill_type, current_ability)

    # 检查并解锁下一级技能
    try_unlock_next_skill(d, current_ability)

    # 发送信号,由任务系统处理技能解锁
    emit_signal("skill_level_up", get_skill_type_enum(skill_type), current_ability)

    return 10


## 检查并解锁下一级技能
func try_unlock_next_skill(current_skill: Dictionary, current_ability: float):
    var next_name = current_skill.get("next_skill", "")
    if next_name == "":
        return
    
    var next_skill = Utils.find_category_by_name(Utils.learning_skills, next_name, true)
    if next_skill.is_empty():
        return
    
    var unlock_at = next_skill.get("unlock_at", 0)
    
    # 能力值达到解锁条件
    if current_ability >= unlock_at:
        # 锁定当前技能
        current_skill.isVisible = false
        current_skill.disabled = true
        
        # 解锁下一级技能
        next_skill.isVisible = true
        next_skill.disabled = false


## 根据技能类型获取能力值
func get_ability_by_type(skill_type: String) -> float:
    if not GDManager:
        return 0.0
    var blogger = GDManager.get_blogger()
    match skill_type:
        "code":
            return float(blogger.code_ability)
        "literature":
            return float(blogger.literature_ability)
    return 0.0


## 根据技能类型设置能力值
func set_ability_by_type(skill_type: String, value: float):
    if not GDManager:
        return
    var blogger = GDManager.get_blogger()
    match skill_type:
        "code":
            blogger.code_ability = value
            blogger.set_ability("code", value)
        "literature":
            blogger.literature_ability = value
            blogger.set_ability("literature", value)


## 技能类型转枚举
func get_skill_type_enum(skill_type: String) -> int:
    match skill_type:
        "code":
            return Skills.CODE
        "literature":
            return Skills.LITERATURE
    return 0


## 根据当前能力值返回学习增量
func get_skill_value(k: float) -> float:
    if k < 25:
        return 1.0
    elif k < 50:
        return 0.5
    elif k < 75:
        return 0.2
    elif k < 100:
        return 0.1
    return 0.0


## ============================================
## 写作能力和技术能力增长（指数衰减曲线）
## ============================================

## 计算能力增长分值（指数衰减公式）
## 每次增加 = 0.3 × e^(-当前值/50) + 0.01
## 5年约1400次操作可达到100分
func get_ability_increment(current_value: float) -> float:
    var base = 0.3
    var decay = exp(-current_value / 50.0)
    var minimum = 0.01
    var increment = base * decay + minimum
    # 保留一位小数
    return round(increment * 10) / 10.0

## 增加写作能力（写博客时调用）
func add_writing_ability_points() -> void:
    if not GDManager:
        return
    var blogger = GDManager.get_blogger()
    if blogger.writing_ability < 100:
        var increment = get_ability_increment(float(blogger.writing_ability))
        blogger.writing_ability += increment
        blogger.writing_ability = min(float(blogger.writing_ability), 100.0)
        blogger.writing_ability = round(blogger.writing_ability * 10) / 10.0

## 增加技术能力（维护网站时调用）
func add_technical_ability_points() -> void:
    if not GDManager:
        return
    var blogger = GDManager.get_blogger()
    if blogger.technical_ability < 100:
        var increment = get_ability_increment(float(blogger.technical_ability))
        blogger.technical_ability += increment
        blogger.technical_ability = min(float(blogger.technical_ability), 100.0)
        blogger.technical_ability = round(blogger.technical_ability * 10) / 10.0

## 月末归档：将超过 84 天的文章从 posts 移入 archived_posts
## TimeDecayModifier.active_article_years * 336 = 84
func _archive_old_posts():
    var blogger = GDManager.get_blogger()
    if not blogger:
        return

    var now = Utils.format_date()
    var max_active_days = int(0.25 * 336)

    var keep: Array[Dictionary] = []
    for post in blogger.posts:
        var post_date = post.get("date", "")
        if post_date != "":
            var days = Utils.calculate_new_game_time_difference(post_date, now)
            if days > max_active_days:
                blogger.archived_posts.append(post)
                continue
        keep.append(post)

    blogger.posts = keep

# ==============================================================================
# 安全事件系统
# ==============================================================================

## 执行紧急排险任务
func do_emergency_response(task_name: String) -> int:
    if not GDManager:
        return 0
    var blogger = GDManager.get_blogger()
    # 无激活事件时，紧急排险无效
    if blogger.active_event.is_empty():
        # Obaby 评论区暗链清理中，不显示误导提示
        var story = GDManager.get_story_progress() if GDManager else null
        var in_cleanup = story and story.is_completed(2, "obaby_comment_spam") and not story.is_completed(2, "obaby_comment_resolved")
        if not in_cleanup:
            emit_signal("sg_info_msg", "当前没有需要处理的安全事件，紧急排险无目标")
        return 0
    var d = Utils.find_category_by_name(Utils.website_maintenance, task_name)
    if d.is_empty():
        return 0
    var actual_cost = Utils.get_stamina_cost(d.stamina, blogger.level)
    if blogger.stamina < actual_cost:
        emit_signal("no_stamina_signal", "体力不足,无法进行紧急排险!需要" + str(actual_cost) + "体力")
        return 0
    blogger.stamina -= actual_cost
    return 10


## 根据 event_id 获取配置
func _get_event_config(event_id: String) -> Dictionary:
    if not GDManager:
        return {}
    var se = GDManager.get_safety_events()
    if not se:
        return {}
    for ev in se.events:
        if ev.id == event_id:
            return ev
    return {}


## 处理激活的安全事件（每日结算时调用）
func _process_active_event(did_emergency: bool) -> void:
    if not GDManager:
        return
    var blogger = GDManager.get_blogger()
    if blogger.active_event.is_empty():
        return

    var ev = blogger.active_event
    var ev_config = _get_event_config(ev.id)
    if ev_config.is_empty():
        blogger.active_event = {}
        return

    if did_emergency:
        ev.progress += 1
        ev.escalate_counter = 0
        emit_signal("sg_info_msg", "🚨 紧急排险进度：%d/%d" % [ev.progress, ev_config.get("total_days", 3)])
    else:
        ev.escalate_counter += 1
        # 应用每日惩罚
        var dp = ev_config.get("daily_penalty", {})
        if dp.has("safety_value"):
            blogger.safety_value = max(0, blogger.safety_value + dp.safety_value)
        if dp.has("views_loss"):
            # 每日访问量损失通过降低 seo 值来模拟
            blogger.seo_value = max(0, blogger.seo_value + int(dp.views_loss / 50))
        if dp.has("reputation"):
            blogger.reputation = max(0, blogger.reputation + dp.reputation)

    # 检查是否升级
    if ev.escalate_counter >= ev_config.get("escalate_days", 5):
        _escalate_event(ev_config.get("escalate_to", ""))
        return

    # 检查是否解决
    if ev.progress >= ev_config.get("total_days", 3):
        _resolve_event()
        return


## 触发新安全事件
func _check_safety_events() -> void:
    if not GDManager:
        return
    var blogger = GDManager.get_blogger()

    # 冷却中或已有激活事件，跳过
    if blogger.event_cooldown > 0:
        blogger.event_cooldown -= 1
        return
    if not blogger.active_event.is_empty():
        return

    var se = GDManager.get_safety_events()
    if not se:
        return

    # 筛选可触发的事件（按严重程度从高到低检测）
    var safety = blogger.safety_value
    var tiers = ["critical", "severe", "general"]
    for tier in tiers:
        for ev in se.events:
            if ev.tier != tier:
                continue
            if safety > ev.trigger_threshold:
                continue
            if randf() < ev.trigger_probability:
                _trigger_event(ev)
                return


## 激活事件（应用惩罚 + 提示信息）
func _trigger_event(ev_config: Dictionary) -> void:
    if not GDManager:
        return
    var blogger = GDManager.get_blogger()

    # 应用即时惩罚
    var penalty = ev_config.get("penalty", {})
    if penalty.has("safety_value"):
        blogger.safety_value = max(0, blogger.safety_value + penalty.safety_value)
    if penalty.has("views_loss"):
        blogger.seo_value = max(0, blogger.seo_value + int(penalty.views_loss / 50))
    if penalty.has("reputation"):
        blogger.reputation = max(0, blogger.reputation + penalty.reputation)

    # 初始化事件状态（默认使用第一个选项）
    blogger.active_event = {
        "id": ev_config.id,
        "progress": 0,
        "choice": 0,
        "escalate_counter": 0,
    }

    # 发送信号，由 main.gd 显示提示信息
    emit_signal("sg_event_triggered", ev_config)


## 解决当前安全事件
func _resolve_event() -> void:
    if not GDManager:
        return
    var blogger = GDManager.get_blogger()
    if blogger.active_event.is_empty():
        return

    var ev_config = _get_event_config(blogger.active_event.id)
    if ev_config.is_empty():
        blogger.active_event = {}
        return

    var reward = ev_config.get("reward", {})
    if reward.has("safety_value"):
        blogger.safety_value = mini(100, blogger.safety_value + reward.safety_value)
    if reward.has("exp"):
        var dummy_exp = 0
        dummy_exp += reward.exp
        gain_exp(dummy_exp)
    if reward.has("money"):
        blogger.money += reward.money
    if reward.has("reputation"):
        blogger.reputation += reward.reputation

    var resolved_id = blogger.active_event.id
    blogger.resolved_events.append(resolved_id)
    # 保持数组不过大
    if blogger.resolved_events.size() > 20:
        blogger.resolved_events = blogger.resolved_events.slice(-20)

    # 设置全局冷却
    blogger.event_cooldown = 30

    var saved_reward = reward.duplicate()
    blogger.active_event = {}

    emit_signal("sg_event_resolved", resolved_id, saved_reward)
    emit_signal("sg_info_msg", "🎉 安全事件「%s」已解决！获得奖励" % ev_config.name)


## 事件升级
func _escalate_event(escalate_to_id: String) -> void:
    if not GDManager:
        return
    var blogger = GDManager.get_blogger()

    var old_id = blogger.active_event.get("id", "")
    blogger.active_event = {}

    if escalate_to_id == "":
        emit_signal("sg_info_msg", "⚠️ 事件已到最坏情况，无法继续升级")
        return

    var ev_config = _get_event_config(escalate_to_id)
    if ev_config.is_empty():
        emit_signal("sg_info_msg", "⚠️ 事件升级目标不存在")
        return

    # 应用升级事件的惩罚
    var penalty = ev_config.get("penalty", {})
    if penalty.has("safety_value"):
        blogger.safety_value = max(0, blogger.safety_value + penalty.safety_value)
    if penalty.has("views_loss"):
        blogger.seo_value = max(0, blogger.seo_value + int(penalty.views_loss / 50))
    if penalty.has("reputation"):
        blogger.reputation = max(0, blogger.reputation + penalty.reputation)

    # 直接激活升级事件（不再弹选择，使用默认第一个选项）
    blogger.active_event = {
        "id": ev_config.id,
        "progress": 0,
        "choice": 0,
        "escalate_counter": 0,
    }

    emit_signal("sg_event_escalated", old_id, escalate_to_id)
    emit_signal("sg_info_msg", "⚠️ 事件升级：%s → %s！立即安排紧急排险！" % [old_id, escalate_to_id])

# ==============================================================================
# Obaby 无视后续处理
# ==============================================================================

## 每日检查 Obaby 无视计数器，触发后续事件
func _check_obaby_ignore() -> void:
    if not GDManager:
        return
    var blogger = GDManager.get_blogger()
    if blogger.obaby_ignore_days <= 0:
        return

    blogger.obaby_ignore_days += 1

    if blogger.obaby_ignore_days == 21:
        # 第20天：Obaby 留言提醒
        emit_signal("sg_event_triggered", {
            "popup_title": "📝 匿名留言",
            "popup_desc": "一个月后，留言板出现了一条新留言：\n\n「提醒过了。」\n\n署名仍然是那个 O。",
        })

    elif blogger.obaby_ignore_days >= 26:
        # 第25天之后：强制触发安全事件
        var ev_config = _get_event_config("homepage_defaced")
        if not ev_config.is_empty():
            _trigger_event(ev_config)
        blogger.obaby_ignore_days = 0

# ==============================================================================
# Obaby 评论区暗链检测
# ==============================================================================

## 累计评论 > 100 时触发评论区暗链事件（第 2 章：2005-2010）
func _check_obaby_comment_spam() -> void:
    if not GDManager:
        return
    var story = GDManager.get_story_progress()
    if not story:
        return
    if story.is_completed(2, "obaby_comment_spam"):
        return
    if TimerManager.current_year < 2005 or (TimerManager.current_year == 2005 and TimerManager.current_month <= 5):
        return
    var blogger = GDManager.get_blogger()
    if not blogger:
        return
    var total = 0
    for post in blogger.posts + blogger.archived_posts:
        total += post.get("comments", 0)
    if total > 100:
        TaskManager._action_obaby_comment_spam()

# ==============================================================================
# Obaby 评论区暗链清理进度检测（连续 3 天紧急排险）
# ==============================================================================

## 每日检查评论区暗链清理进度
func _check_obaby_comment_cleanup(did_emergency: bool) -> void:
    if not GDManager:
        return
    var story = GDManager.get_story_progress()
    if not story:
        return
    if not story.is_completed(2, "obaby_comment_spam"):
        return
    var blogger = GDManager.get_blogger()
    if not blogger:
        return

    # SEO 锁定恢复检测（独立于清理进度）
    if blogger.obaby_spam_seo_locked:
        blogger.seo_value = 0
        var day = TimerManager.current_day - 1
        var tasks = Blogger.blog_calendar[day].tasks
        if "紧急排险" in tasks or "SEO优化" in tasks:
            blogger.obaby_spam_seo_recovery_days += 1
            if blogger.obaby_spam_seo_recovery_days >= 7:
                blogger.obaby_spam_seo_locked = false
                blogger.obaby_spam_seo_recovery_days = 0
                blogger.obaby_comment_spam_days = 0
                TaskManager.emit_signal("sg_task_show_popup_msg", "✅ SEO 锁定已解除",
                    "搜索引擎重新收录了你的站点，\n但权重已归零。\n\n通过安排「SEO 优化」来逐步恢复排名。")
            else:
                emit_signal("sg_info_msg", "🔧 SEO 恢复进度：%d/7" % blogger.obaby_spam_seo_recovery_days)
        else:
            if blogger.obaby_spam_seo_recovery_days > 0:
                blogger.obaby_spam_seo_recovery_days = 0
                emit_signal("sg_info_msg", "❌ SEO 恢复中断：未连续安排紧急排险或 SEO 优化，进度已重置")
        return  # 锁定状态下不推进清理进度

    if story.is_completed(2, "obaby_comment_resolved"):
        return

    # 累计未处理天数（无论当天是否排险都 +1）
    blogger.obaby_comment_spam_days += 1

    if did_emergency:
        blogger.obaby_comment_cleanup_days += 1
        if blogger.obaby_comment_cleanup_days >= 3:
            story.set_completed(2, "obaby_comment_resolved")
            blogger.obaby_comment_cleanup_days = 0
            blogger.obaby_comment_spam_days = 0
            TaskManager.emit_signal("sg_task_show_popup_msg", "✅ 暗链清理完成",
                "连续 3 天的紧急排险清除了所有暗链评论。\n\n已向搜索引擎提交重新审核，排名将在 7 天后恢复。")
    else:
        if blogger.obaby_comment_cleanup_days > 0:
            blogger.obaby_comment_cleanup_days = 0

    # 10 天以上未完成清理 → 升级：SEO 归零锁定（仅触发一次）
    if not blogger.obaby_comment_spam_escalated and blogger.obaby_comment_spam_days >= 10:
        blogger.seo_value = 0
        blogger.obaby_spam_seo_locked = true
        blogger.obaby_spam_seo_recovery_days = 0
        blogger.obaby_comment_spam_days = 99
        blogger.obaby_comment_spam_escalated = true
        TaskManager.emit_signal("sg_task_show_popup_msg", "⚠️ 搜索引擎已屏蔽站点",
            "暗链问题久未处理，搜索引擎已彻底将你的站点降权至零。\n\nSEO 已被锁定为 0\n需要连续安排「紧急排险」或「SEO 优化」\n7 天后才能恢复。")
