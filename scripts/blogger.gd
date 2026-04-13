extends Node

var tmp_v = 23

## 访问量计算器
var views_calculator: ViewsCalculator = null

## 付费文章周收入累积
var weekly_paid_income: float = 0
## 上次结算时付费文章总访问量（用于计算新增访问量）
var last_settle_paid_views: int = 0

## 付费文章订阅配置
const PAID_SUBSCRIPTION_PRICE: float = 9.9  # 固定订阅价格
const PAID_SUBSCRIPTION_RATE: float = 0.05  # 5%访问量会订阅

## 计算付费文章收入（按周结算）
## 逻辑：质量分决定访问量，访问量决定订阅人数
func calculate_paid_income(new_views: int, avg_quality: float) -> int:
    if new_views <= 0:
        return 0
    
    # 访问量决定订阅人数（5%转化率，无上限）
    var subscribers = int(float(new_views) * PAID_SUBSCRIPTION_RATE)
    
    # 收入 = 订阅人数 × 固定价格
    return int(subscribers * PAID_SUBSCRIPTION_PRICE)

enum Blog_Type {
    文学,
    编程,
    艺术,
    综合,
}
# 核心属性 - 博客作者的五个关键能力
## 最高等级
const MAX_LEVEL = 100
## 级能最高等级
const MAX_SKILL_LEVEL = 100

# ===== 向后兼容的属性访问 =====

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

## 绘画能力:最后可以为原画师和大画家。
var drawing_ability: float:
    get:
        return GDManager.get_blogger().drawing_ability if GDManager else tmp_v
    set(value):
        if GDManager:
            GDManager.get_blogger().drawing_ability = value

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
            return {
                "blog_name": blogger.blog_name,
                "blog_author": blogger.blog_author,
                "blog_type": blogger.blog_type,
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
            }
        return {}
    set(value):
        if GDManager:
            var blogger = GDManager.get_blogger()
            blogger.blog_name = value.get("blog_name", "我的博客")
            blogger.blog_author = value.get("blog_author", "J.sky")
            blogger.blog_type = value.get("blog_type", 1)
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
        return GDManager.get_blogger().tmp_year if GDManager else 2005
    set(value):
        if GDManager:
            GDManager.get_blogger().tmp_year = value

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
    print("[每日恢复] 体力+", recovery, ",当前体力:", blogger.stamina)


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
    var day = TimerManager.current_day-1 #获取当日所属周中几日值。
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
        elif Utils.check_name_exists(Utils.recreation, task):
            if task == "休息":
                exp_gained += recreation_rest(task) # 休息一天
            if task == "打游戏":
                exp_gained += playgame(task) # 休息一天
        elif Utils.check_name_exists(Utils.learning_skills, task):
            # 检查技能是否已解锁(未禁用)
            var skill = Utils.find_category_by_name(Utils.learning_skills, task)
            if skill.get("disabled", false):
                print("技能【%s】已禁用,跳过" % task)
                continue
            exp_gained += learningToSkills(task)

    # 如果当天没有任务,不再自动恢复体力(已改为每日自然恢复)
    if Blogger.blog_calendar[day].tasks.is_empty():
        print("当天没有任务,体力不自动恢复")

    #exp_gained += calculate_promotion_exp() # 推广EXP
    #exp_gained += calculate_interaction_exp() # 读者互动EXP
    #exp_gained += calculate_skill_learning_exp() # 技能学习EXP
    exp_gained += update_blog_views() # 更新博客访问量
    #earn_money_from_ads() # 从广告联盟赚取佣金
    gain_exp(exp_gained) # 累加EXP并处理升级

func week_activites():
    if not GDManager:
        return

    var blogger = GDManager.get_blogger()
    blogger.safety_value = Utils.decrease_value_safely(blogger.safety_value, 1, 3)
    blogger.seo_value = Utils.decrease_value_safely(blogger.seo_value, 0, 2)
    blogger.design_value = Utils.decrease_value_safely(blogger.design_value, 1, 3)
    blogger.rss = Utils.decrease_rss(blogger.rss)
    del_fa()

    # 判断绘画技能值>=25时,开启页面美化
    var tmp_design = Utils.find_category_by_name(Utils.website_maintenance, "页面美化")
    if tmp_design.disabled:
        if blogger.drawing_ability >= 25:
            tmp_design.disabled = false

## 博客文章收藏量在三个月后始递减
func del_fa():
    if GDManager:
        var blogger = GDManager.get_blogger()
        for p in blogger.posts:
            # 博文发布时间与当前时间的间隔日期。
            var tmp_b = Utils.calculate_new_game_time_difference(Utils.format_date(),p.date)
            if tmp_b > 28*6 and p.favorites > 100:
                var tmp_k = randi_range(0,10)
                p.favorites -= tmp_k
                blogger.favorites -= tmp_k

## 添加新的博客文章
func add_new_blog_post(title: String, d) -> Dictionary:
    var blog_date = Utils.format_date()
    tmp_quality = Utils.get_quality(d.name)

    # 生成唯一文章ID
    var post_id = "post_" + str(Time.get_ticks_msec()) + "_" + str(randi() % 10000)

    # 判断是否是任务型文章
    var task_type = ""
    if d.name == "第一篇博文":
        task_type = "第一篇博文"
    elif d.name == "年度总结":
        task_type = "年度总结"

    var new_post: Dictionary = {
        "id": post_id,              # 文章唯一ID
        "title": title,
        "category": d.name,
        "task_type": task_type,     # 任务类型(第一篇博文、年度总结等)
        "type": d.type,             # 博文种类
        "type1": d.type1,           # 博文种类
        "views": 0,                 # 总访问量
        "comments": 0,              # 评论
        "favorites": 0,             # 收藏
        "is_money": d.get("is_money", false),  # 是否收费(从配置读取)
        "date": blog_date,
        "quality": tmp_quality,
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
        
        blogger.posts.append(new_post)
        blogger.add_post(new_post)

    print("新博客文章发布: ", title, ",分类: ", d.name, ",ID: ", post_id)
    return new_post

## 处理小说连载批次逻辑
func _handle_novel_batch(blogger):
    # 第一次发布时，随机选择主题
    if blogger.novel_batch_title == "":
        _assign_novel_title(blogger)
    
    blogger.novel_batch_count += 1
    print("[小说连载] 《%s》 批次%d, 第%d篇" % [blogger.novel_batch_title, blogger.novel_batch, blogger.novel_batch_count])
    
    # 检查是否达到100篇，自动开新批次
    if blogger.novel_batch_count >= 100:
        blogger.novel_batch += 1
        blogger.novel_batch_count = 0
        blogger.novel_batch_ip_triggered = false
        _assign_novel_title(blogger)  # 分配新主题
        print("[小说连载] 《%s》完结，新批次《%s》开启" % [blogger.novel_batch_title, blogger.novel_batch_title])
    
    # 检查是否触发IP授权（>=50篇且未触发过）
    elif blogger.novel_batch_count >= 5 and not blogger.novel_batch_ip_triggered:  # 测试用5篇
        _try_trigger_ip_auth(blogger)

## 为当前批次分配小说主题
func _assign_novel_title(blogger):
    var title_templates = GDManager.get_title_templates()
    var topics = title_templates.topics.get("小说连载(付费)", ["程序员修仙传"])
    blogger.novel_batch_title = topics[randi() % topics.size()]

## 尝试触发IP授权（20%概率）
## 条件：文学等级>=100 且 小说连载>=50篇
func _try_trigger_ip_auth(blogger):
    var literature_level = int(blogger.literature_ability)
    
    # 检查文学等级是否达到85
    if literature_level < 85:
        print("[IP授权] 跳过检查 - 文学等级%d/85，未达到85级" % literature_level)
        return
    
    var random_val = randi() % 100
    print("[IP授权] 检查触发... 批次:%d, 篇数:%d, 文学等级:%d, 随机值:%d/100 (需<99)" % [blogger.novel_batch, blogger.novel_batch_count, literature_level, random_val])
    
    if random_val < 99:  # 99%概率（测试用）
        # 计算收益
        var literature_value = blogger.literature_ability
        var base_reward = 100000.0
        var bonus = base_reward * (literature_value / 100.0)
        var total_reward = base_reward + bonus
        
        # 发放收益
        blogger.money += total_reward
        blogger.reputation += 500
        
        print("[IP授权] 🎉 触发成功！基础收益: %.0f元, 文学加成: %.0f%%, 总收益: %.0f元" % [base_reward, literature_value, total_reward])
        
        # 弹窗提示
        _show_ip_auth_popup(total_reward, literature_value)
        
        blogger.novel_batch_ip_triggered = true

## 显示IP授权到账弹窗
func _show_ip_auth_popup(reward: float, literature_bonus: float):
    var main = get_tree().root.get_node("Main")
    if main and main.has_method("show_popup_message"):
        main.show_popup_message("IP授权收益到账！", "您的作品被影视公司看中！\n\n基础收益: 100000元\n文学加成: %.0f%%\n总收益: %.0f元\n\n声望 +500" % [literature_bonus, reward])
    else:
        print("[IP授权] ❌ 未触发！下次篇数达到50时再检查（每批次只触发一次）" )

signal sg_new_blog_post(category: String)
## 模拟当天发布新博客文章
func simulate_new_blog_post(category) -> int:
    # ===== 欠费暂停检查 =====
    if Yun.is_blog_suspended():
        print("[暂停状态] 博客因欠费暂停运营,无法写新文章")
        emit_signal("no_stamina_signal", "博客因欠费暂停运营,请先续费域名或主机!")
        return 0

    # 这里可以根据作者的写作、技术能力来决定文章的质量,体力决定是否能发布文章。
    if not GDManager:
        return 0

    var blogger = GDManager.get_blogger()
    var d = Utils.find_category_by_name(Utils.possible_categories, category)
    var actual_cost = Utils.get_stamina_cost(d.stamina, blogger.level)

    if blogger.stamina >= actual_cost and category: ## 如果体力足够,并且当天有写作任务。
        var new_title: String = Utils.generate_random_title(category) # 生成一个简单的随机标题
        var new_post = add_new_blog_post(new_title, d)
        # 这里定义了一个博文发布信号量,当有博文成功发布时候触发,将会在res://scripts/task_system/TaskManager.gd中引用信号量
        emit_signal("sg_new_blog_post",category)

        # 这里可以根据文章的质量和访问量来计算EXP
        blogger.stamina -= actual_cost  # 使用实际消耗
        # 增加写作能力（每次写博客成功都会增加）
        add_writing_ability_points()
        print("[写博客] 消耗体力:", actual_cost, ",剩余体力:", blogger.stamina)
        return int(new_post.quality*0.2)# 简化计算,实际应更复杂
    else:
        # 不再自动恢复体力,直接拒绝
        print("体力不足,无法写博客")
        emit_signal("no_stamina_signal", "体力不足,无法写博客!需要" + str(actual_cost) + "体力")
        return 0


## 更新博客访问量(使用新的模块化计算器)
func update_blog_views() -> int:
    if not GDManager:
        return 0

    # ===== 欠费暂停检查 =====
    if Yun.is_blog_suspended():
        print("[暂停状态] 博客因欠费暂停运营,访问量不增加")
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
        "posts": blogger.posts
    }

    # 使用新计算器计算访问量
    var result = views_calculator.calculate_daily(blogger_data)
    blogger.today_views = result.views

    # 计算付费文章收入(按周结算)
    var today_money = 0
    var paid_posts = []
    var current_total_views = 0
    for post in blogger.posts:
        if post.get("type1", "") == "付费":
            paid_posts.append(post)
            current_total_views += post.get("views", 0)
    
    # 计算新增访问量
    var new_views = current_total_views - last_settle_paid_views
    if new_views > 0 and paid_posts.size() > 0:
        var avg_quality = 0
        for post in paid_posts:
            avg_quality += post.get("quality", 50)
        avg_quality = avg_quality / paid_posts.size()
        today_money = calculate_paid_income(new_views, avg_quality)
    
    # 调试日志
    if paid_posts.size() > 0:
        print("[付费文章] 共", paid_posts.size(), "篇, 上次访问量:", last_settle_paid_views, ", 当前:", current_total_views, ", 新增:", new_views, ", 本周收入:", today_money)
    
    # 累积每周收入
    weekly_paid_income += today_money
    
    # 每周结算（第7天）
    if TimerManager.current_day == 7 and weekly_paid_income > 0:
        blogger.money += weekly_paid_income
        print("[小说连载收入] 本周收入: ", weekly_paid_income, " 元，已入账")
        # 更新上次结算访问量
        var total_paid_views = 0
        for post in blogger.posts:
            if post.get("type1", "") == "付费":
                total_paid_views += post.get("views", 0)
        last_settle_paid_views = total_paid_views
        weekly_paid_income = 0

    # 广告收入和影响
    if AdManager.ad_2:
        blogger.today_views = AdManager.update_ad(blogger.today_views)

    # 更新统计
    Tongji.t_d.append([Utils.format_date(), blogger.today_views])

    # 更新收藏数(基于今日访问量)
    for post in blogger.posts:
        var post_views_today = 0
        var post_id = post.get("id", "")
        if post_id != "" and views_calculator:
            var stats = views_calculator.get_post_stats(post_id)
            var daily = stats.get("daily_views", [])
            if daily.size() > 0:
                post_views_today = daily[-1].get("views", 0)

        if post_views_today > 0:
            var new_favorites = Utils.update_favorites(post_views_today, post.get("quality", 100))
            post.favorites = post.get("favorites", 0) + new_favorites
            blogger.favorites += new_favorites

    # 周/月/年统计
    if tmp_w == TimerManager.current_week:
        blogger.week_views += blogger.today_views
        if TimerManager.current_day == 7:
            var date = str(TimerManager.current_year) + "-" + str(TimerManager.current_month) + "-" + str(TimerManager.current_week)
            Tongji.t_w.append([date, blogger.week_views])
    else:
        blogger.week_views = blogger.today_views
        tmp_w = TimerManager.current_week

    if tmp_m == TimerManager.current_month:
        blogger.month_views += blogger.today_views
        if TimerManager.current_week == 4 and TimerManager.current_day == 7:
            var date = str(TimerManager.current_year) + "-" + str(TimerManager.current_month)
            Tongji.t_m.append([date, blogger.month_views])
    else:
        blogger.month_views = blogger.today_views
        tmp_m = TimerManager.current_month

    if tmp_y == TimerManager.current_year:
        blogger.year_views += blogger.today_views
        if TimerManager.current_month == 12 and TimerManager.current_week == 4 and TimerManager.current_day == 7:
            var date = str(TimerManager.current_year)
            Tongji.t_y.append([date, blogger.year_views])
    else:
        blogger.year_views = blogger.today_views
        tmp_y = TimerManager.current_year

    blogger.views += blogger.today_views
    blogger.rss += Utils.update_rss(blogger.today_views)

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
        print("金钱不足,无法进行推广")
        return 0

    money -= promotion_cost
    print("花费金钱进行推广: ", promotion_cost, ",当前金钱: ", money)

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
    blogger.safety_value += Utils.add_property(blogger.safety_value,int(blogger.technical_ability/4))
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
    var seo_add = blogger.level + int((blogger.writing_ability + blogger.technical_ability) / 3)
    blogger.seo_value = clamp(blogger.seo_value + seo_add, 0, 200)
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
    blogger.design_value += Utils.add_property(blogger.design_value,int(blogger.drawing_ability/4))
    # 增加技术能力（每次维护成功都会增加）
    add_technical_ability_points()
    emit_signal("signal_design_web","页面美化值+10")
    return 10

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



enum  Skills {
    LITERATURE,#文学
    CODE,      #编程
    DRAW,      #绘画
}

signal skill_level_up(type: int, lv: float)
signal no_stamina_signal(tit: String)
signal no_money_signal(tit: String)

## 学习技能
func learningToSkills(category: String) -> int:
    if not GDManager:
        return 0

    var blogger = GDManager.get_blogger()
    var d = Utils.find_category_by_name(Utils.learning_skills, category)

    if d.is_empty():
        print("未找到技能: ", category)
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
        print("能力值已满!")
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

    # 打印学习结果
    print("[技能学习] ", category, " | ", skill_type, " 能力值: ", old_ability, " -> ", current_ability, " (+", add_value, ")")

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
    
    var next_skill = Utils.find_category_by_name(Utils.learning_skills, next_name)
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
        "draw":
            return float(blogger.drawing_ability)
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
        "draw":
            blogger.drawing_ability = value
            blogger.set_ability("drawing", value)


## 技能类型转枚举
func get_skill_type_enum(skill_type: String) -> int:
    match skill_type:
        "code":
            return Skills.CODE
        "literature":
            return Skills.LITERATURE
        "draw":
            return Skills.DRAW
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
        print("[写作能力] +%.1f，当前：%.1f" % [increment, blogger.writing_ability])

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
        print("[技术能力] +%.1f，当前：%.1f" % [increment, blogger.technical_ability])
