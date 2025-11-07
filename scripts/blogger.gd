extends Node

var tmp_v = 23

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

## 博客属性
var myblog_type = Blog_Type.文学
## 写作能力：决定文章质量和写作速度。
var writing_ability: int = tmp_v

## 技术能力：影响博客维护、SEO优化和网站性能。
var technical_ability: int = tmp_v

## 文学能力：可以博主的文学素养，除了可以撰写相关文章，还可以优化其他类型的文章。
var literature_ability = tmp_v

## 编程能力：可以撰写编程相关的博文，2级学完可以开始接私活赚钱。
var code_ability = tmp_v

## 绘画能力:最后可以为原画师和大画家。
var drawing_ability = tmp_v

## 体力值：创作文章，维护博客，社交需要体力值。
var stamina : int = 100

## 社交能力：影响推广成功率和读者参与度。
var social_ability: int = 5

# 新增属性
## 金钱：用于推广、学习技能、网站维护等
var money: float = 100000


## 博客的rss订阅量：新文章提供访问量
var blog_rss: int =0

# 经验值（EXP）与等级
## exp: 当前经验值
var exp: int = 0

# 已经为等级提升添加了提示，还需要添加绰号
signal s_level(l:int) #定义一个关于等级成长的信号量
## level: 当前等级
var level: int = 1

## 博客段位
var dw:int = 0

## 可用于提升属性的点数
var attribute_points: int = 0

## 技能 - 字典，键为技能名，值为技能等级
#var skills: Dictionary = {}
## 后最后一篇文章的质量分
var tmp_quality = 0
## 工作学习休息日程
var blog_calendar : Array = [
    {
        "task" : "阅读名著",
    },
    {
        "task" : "阅读名著",
    },
    {
        "task" : "阅读名著",
    },
    {
        "task" : "阅读名著",
    },
    {
        "task" : "安全维护",
    },
    {
        "task" : "SEO优化",
    },
    {
        "task" : "打游戏",
    },
]

#@ 博客数据
var blog_data: Dictionary = {
    "blog_name": "我的博客",
    "blog_author":"J.sky",
    "blog_type":1,#博客类型。
    "safety_value" : 100, #安全值，过低网站会遭受攻击和入侵
    "seo_value": 100, # seo值，当SEO值过低的时候会降低访问量
    "design_value": 100, # 页面美化值，美化值会之时间而减低，类似于视觉疲劳，按着0.1比例增加访博文问量
    "ui":0,#blog页面美化，最高为100，可以提升访问量10%
    "views": 0, # 总访问量
    "rss":0,#rss订阅量
    "favorites":0,# 博客中所有文章的收藏量的和
    "today_views": 0, # 今日访问量
    "week_views": 0, # 周访问量
    "month_views": 0, # 月访问量
    "year_views": 0, # 年访问量
    "posts": [], # 存储博客文章的数组
}

# 临时量，用来记录周、月份、年份统计使用
var tmp_w = 1 #第一周
var tmp_m = 1 #第一月
var tmp_y = 2000 #第一年

# 初始化
func _ready():
    pass



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
    exp += amount # 增加经验值
    # 循环处理升级，直到EXP不足以升到下一级
    while exp >= get_exp_for_next_level() and level < MAX_LEVEL:
        exp -= get_exp_for_next_level() # 扣除升级所需EXP
        level += 1 # 等级提升
        # 判断是否是10的倍数，并且 level 不等于0（避免刚初始化就触发）
        if level % 10 == 0 and level != 0:
            emit_signal("s_level", level)
        # 技能升
        if writing_ability< 100:
            writing_ability += 1
            
        if technical_ability < 100:
            technical_ability +=1
            
        if social_ability < 100:
            social_ability += 1
        #attribute_points += 5 # 每次升级获得5个属性点
    # 达到100级后，EXP不再累积
    if level >= MAX_LEVEL:
        exp = 0 # 封顶于maxlevel级




## 博客的核心更新方法，每日更新
func daily_activities():
    # 模拟每天的活动
    var exp_gained := 0 # 记录本周获得的EXP
    var day = TimerManager.current_day-1 #获取当日所属周中几日值。
    if Utils.check_name_exists(Utils.possible_categories,Blogger.blog_calendar[day].task):
        exp_gained += simulate_new_blog_post(Blogger.blog_calendar[day].task) # 模拟发布新博客文章
    elif Utils.check_name_exists(Utils.website_maintenance,Blogger.blog_calendar[day].task):
        if Blogger.blog_calendar[day].task == "安全维护":
            exp_gained += maintain_website_security(Blogger.blog_calendar[day].task) # 进行网站安全维护
        if Blogger.blog_calendar[day].task == "SEO优化":
            exp_gained += maintain_website_seo(Blogger.blog_calendar[day].task) # 进行网站安全维护
        if Blogger.blog_calendar[day].task == "页面美化":
            exp_gained += maintain_design_web(Blogger.blog_calendar[day].task) # 进行网站页面美化
    elif Utils.check_name_exists(Utils.recreation,Blogger.blog_calendar[day].task):
        if Blogger.blog_calendar[day].task == "休息":
            exp_gained += recreation_rest(Blogger.blog_calendar[day].task) # 休息一天
        if Blogger.blog_calendar[day].task == "打游戏":
            exp_gained += playgame(Blogger.blog_calendar[day].task) # 休息一天
    elif Utils.check_name_exists(Utils.learning_skills,Blogger.blog_calendar[day].task):
        exp_gained =  learningToSkills(Blogger.blog_calendar[day].task)
        
    else:
        stamina += Utils.add_property(stamina,5)
        print("当天没有任务")
    
    #exp_gained += calculate_promotion_exp() # 推广EXP
    #exp_gained += calculate_interaction_exp() # 读者互动EXP
    #exp_gained += calculate_skill_learning_exp() # 技能学习EXP
    exp_gained += update_blog_views() # 更新博客访问量
    #earn_money_from_ads() # 从广告联盟赚取佣金
    gain_exp(exp_gained) # 累加EXP并处理升级
    
func week_activites():
    # 一些博客相关数值每周递减
    blog_data.safety_value = Utils.decrease_value_safely(blog_data.safety_value,1,3)
    blog_data.seo_value = Utils.decrease_value_safely(blog_data.seo_value,1,3)
    blog_data.design_value = Utils.decrease_value_safely(blog_data.seo_value,1,3)
    #print("rss-----",str(blog_data.rss))
    blog_data.rss = Utils.decrease_rss(blog_data.rss) #rss订阅量的递减
    #print("rss-----",str(blog_data.rss))
    del_fa()
    
    # 判断绘画技能值>=25的候，可以开启页面美化
    var tmp_design = Utils.find_category_by_name(Utils.website_maintenance,"页面美化")
    if tmp_design.disabled :
        if drawing_ability >= 25:
            tmp_design.disabled = false
    

## 博客文章收藏量在三个月后始递减
func del_fa():
    for p in blog_data["posts"]:
        # 博文发布时间与当前时间的间隔日期。
        var tmp_b = Utils.calculate_new_game_time_difference(Utils.format_date(),p.date)
        if tmp_b > 28*6 and p.favorites > 100:
            var tmp_k = randi_range(0,10)
            p.favorites -= tmp_k
            blog_data.favorites -= tmp_k

## 添加新的博客文章
func add_new_blog_post(title: String, d) -> Dictionary:
    var blog_date = Utils.format_date()
    tmp_quality = Utils.get_quality(d.name)
    var new_post: Dictionary = {
        "title": title,
        "category": d.name,
        "type":d.type,#博文种类
        "type1":d.type1,#博文种类
        "views": 0,#总访问量
        "comments": 0, #评论
        "favorites": 0,#收藏
        "is_money":false, #是否收费
        "date" : blog_date,
        "quality": tmp_quality,		
    }
    
    blog_data["posts"].append(new_post)
    print("新博客文章发布: ", title, "，分类: ", d.name,"，日期: ", blog_date,)
    return new_post
    
signal sg_new_blog_post(category: String)
## 模拟当天发布新博客文章
func simulate_new_blog_post(category) -> int:
    # 这里可以根据作者的写作、技术能力来决定文章的质量，体力决定是否能发布文章。
    var d = Utils.find_category_by_name(Utils.possible_categories,category)
    if stamina > d.stamina and category: ## 如果体力大于，并且当天有写作任务。
        var new_title: String = Utils.generate_random_title(category) # 生成一个简单的随机标题
        var new_post = add_new_blog_post(new_title, d)
        # 这里定义了一个博文发布信号量，当有博文成功发布时候触发，将会在res://scripts/task_system/TaskManager.gd中引用信号量
        emit_signal("sg_new_blog_post",category) 
        #if category == '年度总结':
            #var k = Utils.find_category_by_name(Utils.possible_categories,category)
            #k.disabled = true
            #Utils.replace_task_value(blog_calendar, category, "休息")  # 更新日历任务为休息
        # 文章质量：基于写作能力和其他能力，最大100
        
        # 这里可以根据文章的质量和访问量来计算EXP
        stamina -= d.stamina
        #print(new_post)
        return int(new_post.quality*0.2)# 简化计算，实际应更复杂
    else:
        stamina += Utils.add_property(stamina,5)
        print("没有体力，或是当天没有写作任务")
        return 0


## 更新博客访问量
func update_blog_views() -> int:
    blog_data.today_views = 0
    var exp_day_views:int = 0 #经验值
    var tody_money = 0 # 今日的付费文章入
    var tody_rss = 0
    var tody_f =0
    # 遍历所有博客文章，增加它们的访问量
    for post in blog_data["posts"]:
        #print(post)
        # 每篇文章的基础访问量
        var base_views: int = randi_range(1,blog_data.seo_value * 0.1)
        var new_views_for_post: int = Utils.calculate_post_views(base_views,post)
        #print(post.quality ,blog_data.seo_value,new_views_for_post)
        var now_date = Utils.format_date()
        # 访问量按着时间递减，因为越久的文章浏览量会越少
        new_views_for_post = Utils.decrease_blog_views(new_views_for_post,post.date,now_date,post.type1)
        #print("old:",new_views_for_post)
        var end_views_for_post = new_views_for_post #最终叠加所有buff的访问量
        # 在最终确定每篇访问量之前，叠加各种访问量buff。
        # 分享，每篇文章都会被分享，根据访问量有几率获得一定的文章分享值，已增加最终的访问量
        end_views_for_post += Utils.calculate_final_views(new_views_for_post)
        #print("叠加分享：",end_views_for_post)
        ## 根据文章的收藏增加访问量
        var tmp_fa = Utils.favorites_add(post.favorites,post.date)
        #if tmp_fa > 0:
            #print(Utils.format_date()," ",tmp_fa)
        end_views_for_post += tmp_fa
        tody_f += tmp_fa
        #print("收藏叠加：",end_views_for_post,"收藏增加：",tmp_fa)
        
        # 博文发布时间与当前时间的间隔日期。
        var tmp_b = Utils.calculate_new_game_time_difference(Utils.format_date(),post.date)
        
        if tmp_b < 8 :
            var tmp_rss = Utils.rss_add(blog_data.rss,tmp_b)
            # 根据blogRSS订阅，按几率增加问量。
            end_views_for_post += tmp_rss
            tody_rss += tmp_rss
            #print("RSS订阅叠加：",end_views_for_post,"RSS订阅增加：",tmp_rss)
        # 页面化增加一个访问量的buff，提升1%，100级提升10%
        var tmp_design = int(end_views_for_post * (blog_data.design_value * 0.01))
        end_views_for_post += tmp_design
        #print("design叠加：",end_views_for_post,"design增加：",tmp_design)
        # 每10级增加一个访问量的buff，提升1%，100级提升10%
        end_views_for_post += int(end_views_for_post * (dw * 0.01))
        # 根据热门风向标来增加流量,根据文章质量分满分200后，最终可以提升10%的流量
        if post.type == Utils.post_trend.type:
            
            end_views_for_post+= int(end_views_for_post * (post.quality/200 * Utils.post_trend.views_add))
        

        
        # 收费文章将当前的访问量进行转化，暂定每200流量转换1收费，收费根据文章的质量来定义费用，基础费用为:质量分/200*10元*end_views_for_post/200，
        
        
        if post.type1 == "付费":
            end_views_for_post = int(end_views_for_post / 100)
            if end_views_for_post > 0 : # 访问量大于最低访问才会有收入
                var post_money = int(float(post.quality)/200 * 10 * end_views_for_post)
                tody_money += post_money
        
        
        
        ## 叠加访问量后更新每篇文章的收藏.
        post.favorites += Utils.update_favorites(end_views_for_post,post.quality)
        blog_data.favorites += Utils.update_favorites(end_views_for_post,post.quality)
        
        
        post.views += end_views_for_post
        blog_data.today_views += end_views_for_post
        exp_day_views += calculate_article_exp(end_views_for_post)
    #print(blog_data.today_views)
    # 叠加今日付费文章收入
    #if tody_money > 0 :
            #print(tody_money)
    #print("rss++",tody_rss)
    #print("f+++",tody_f)
    money += tody_money
    #这里更新广告联盟的收入，以及添加广告后对问量的最终影响
    if AdManager.ad_2: # 只有申请并通过并有广告管理的权限后，才会有收入。
        blog_data.today_views = AdManager.update_ad(blog_data.today_views)
        

    
    # 这里可以方便创建个站点的统计，统计blog的访问量细节。
    #统计系统记录访问量
    Tongji.t_d.append([Utils.format_date(),blog_data.today_views])
    #print(Tongji.t_d)
    
    # 每周的访问量
    if tmp_w == TimerManager.current_week:
        blog_data.week_views += blog_data.today_views
        #周访问量几录
        if TimerManager.current_day == 7 :
            var date = str(TimerManager.current_year) + "-" + str(TimerManager.current_month) + "-" + str(TimerManager.current_week)
            Tongji.t_w.append([date,blog_data.week_views])
            #print(Tongji.t_w)
    else:
        blog_data.week_views = 0
        blog_data.week_views += blog_data.today_views
        tmp_w = TimerManager.current_week
    
    # 每月的访问量
    if tmp_m == TimerManager.current_month:
        blog_data.month_views += blog_data.today_views
        if TimerManager.current_week == 4 and TimerManager.current_day == 7 :
            var date = str(TimerManager.current_year) + "-" + str(TimerManager.current_month)
            Tongji.t_m.append([date,blog_data.month_views])
    else:
        blog_data.month_views = 0
        blog_data.month_views += blog_data.today_views
        tmp_m = TimerManager.current_month
        
    # 每年的访问量
    if tmp_y ==TimerManager.current_year:
        blog_data.year_views += blog_data.today_views
        if TimerManager.current_month == 12 and TimerManager.current_week == 4 and TimerManager.current_day == 7 :
            var date = str(TimerManager.current_year)
            Tongji.t_y.append([date,blog_data.year_views])
            #print(Tongji.t_y)
    else:
        blog_data.year_views = 0
        blog_data.year_views += blog_data.today_views
        tmp_y = TimerManager.current_year
        
    blog_data.views += blog_data.today_views
    # 叠加访问量后更新博客的RSS订阅量
    blog_data.rss += Utils.update_rss(blog_data.today_views)
    return exp_day_views



## EXP计算函数（可根据游戏具体机制自定义）
func calculate_article_exp(views) -> int:
    # 根据当前博文新增访问量来计算增加的EXP
    var daily_article_exp: int = 0
    daily_article_exp += int(float(views) / 10) # 根据单篇文章的访问量增加EXP
    return daily_article_exp

func calculate_promotion_exp() -> int:
    var promotion_cost: int = 10 # 推广花费，可根据社交能力调整
    if money < promotion_cost:
        print("金钱不足，无法进行推广")
        return 0

    money -= promotion_cost
    print("花费金钱进行推广: ", promotion_cost, "，当前金钱: ", money)

    var new_readers := social_ability * 5 # 占位符；新读者数
    # 基础EXP + 效果奖励
    return 5 + (new_readers / 10.0 * 2)

func calculate_interaction_exp() -> int:
    var interactions: int = 3 # 占位符；互动次数
    # 假设 social_ability 是在其他地方定义的整型变量
    var quality: int = min(social_ability / 10, 10) # 互动质量
    # 每次互动的EXP：基础 + 质量奖励
    return interactions * (2 + int(float(quality) / 10.0 * 5))

func calculate_skill_learning_exp() -> int:
    # 占位符：50%几率进行技能训练，获得20 EXP
    return 20 if randf() > 0.5 else 0






# 信号量
signal signal_website_security(msg: String)# 进行网站安全维护
signal signal_website_security_no_stamina(msg: String) # 进行网站安全是体力不足
signal signal_website_security_no_money(msg: String) # 进行网站安全时财力不足
## 维护网站安全
func maintain_website_security(category: String) -> int:
    var d = Utils.find_category_by_name( Utils.website_maintenance,category)
    if money < d.money:
        emit_signal("signal_website_security_no_money","财力不足，无法进行网站维护！")
        # 可以添加一些负面影响，例如网站性能下降，访问量减少等
        return 0
    
    if stamina < d.stamina :
        emit_signal("signal_website_security_no_stamina","体力不足，无法进行网站维护！")
        stamina += Utils.add_property(stamina,5)
        return 0
    stamina -= d.stamina #消耗体力值
    money -= d.money
    blog_data.safety_value += Utils.add_property(blog_data.safety_value,int(technical_ability/4))
    emit_signal("signal_website_security","网站的安全值+10")
    return 10
    # 可以添加一些正面影响，例如提升网站性能，增加访问量等

# 信号量
signal signal_website_seo(msg: String)# 进行网站安全维护
signal signal_website_seo_no_stamina(msg: String) # 进行网站安全是体力不足
## seo 优化
func maintain_website_seo(category: String) -> int:
    var d = Utils.find_category_by_name( Utils.website_maintenance,category)
    if stamina < d.stamina :
        emit_signal("signal_website_seo_no_stamina","体力不足，无法进行seo优化！")
        stamina += Utils.add_property(stamina,5)
        return 0
    stamina -= d.stamina #消耗体力值
    blog_data.seo_value += Utils.add_property(blog_data.seo_value,int(technical_ability/4))
    emit_signal("signal_website_seo","网站seo值+10")
    return 10
    
# 信号量
signal signal_design_web(msg: String)# 进行网站页面美化
signal signal_design_web_no_stamina(msg: String) # 进行网站页面化时体力不足	
func maintain_design_web(category: String) -> int:
    var d = Utils.find_category_by_name( Utils.website_maintenance,category)
    if stamina < d.stamina :
        emit_signal("signal_design_web_no_stamina","体力不足，无法进行页面美化！")
        stamina += Utils.add_property(stamina,5)
        return 0
    stamina -= d.stamina #消耗体力值
    blog_data.design_value += Utils.add_property(blog_data.design_value,int(drawing_ability/4))
    emit_signal("signal_design_web","页面美化值+10")
    return 10
    
## 休闲娱乐 -> 休息 
signal s_recrecreation_rest(msg)
func recreation_rest(category : String) -> int:
    var d = Utils.find_category_by_name( Utils.recreation,category)
    stamina += Utils.add_property(stamina,d.stamina)
    var t_msg = "今天休息体力加："+str(d.stamina)
    emit_signal("s_recrecreation_rest",t_msg)
    #print("今天休息体力加：",d.stamina)
    return 0
## 休闲娱乐 -> 打游戏	
signal s_playgame(msg)
func playgame(category : String) -> int:
    var d = Utils.find_category_by_name( Utils.recreation,category)
    stamina += Utils.add_property(stamina,d.stamina)
    var t_msg = "今天休息体力加："+str(d.stamina)
    emit_signal("s_playgame",t_msg)
    #print("今天休息体力加：",d.stamina)
    return 0



enum  Skills {
    LITERATURE,#文学
    CODE,      #编程
    DRAW,      #绘画
}

## 学习技能
func learningToSkills(category: String) -> int:
    
    var skill_type = get_skill(category)
    print(skill_type)
    var exp = 0
    exp = learning_skill(skill_type,category)
    return exp
    
    
func get_skill(category: String):
    var literature = ["阅读名著","写作基础理论","高级文学","小说家",]
    var code = ["自学编程","学习前端","高级编程","成为黑客",]
    var draw = ["自学画画","素描和色彩","原画师之路","大画家",]
    if category in literature : return Skills.LITERATURE
    elif category in code : return Skills.CODE
    elif category in draw : return Skills.DRAW
    else : return 0


signal skill_level_up(type:int,lv:float)
signal no_stamina_signal(tit:String)
signal no_money_signal(tit:String)
## 升级能并返回经验值
func learning_skill(type : int, category : String) -> int:
    # 查找与给定类别名称对应的技能数据
    var d = Utils.find_category_by_name(Utils.learning_skills, category)
    var tmp_skill_level = 0
    match type:
        Skills.DRAW:
            tmp_skill_level = drawing_ability
        Skills.CODE:
            tmp_skill_level = code_ability
        Skills.LITERATURE:
            tmp_skill_level = literature_ability
    if tmp_skill_level < MAX_SKILL_LEVEL :
        if stamina < d.stamina :  # 如果当前体力不足以支付此次学习的成本
            emit_signal("no_stamina_signal", "体力不足，无法进行学习！")  # 发出体力不足的信号
            stamina += Utils.add_property(stamina, 5)  # 增加少量体力
            return 0  # 返回0表示此次学习未成功进行
        if money < d.money :
            emit_signal("no_money_signal", "财力不足，无法进行学习！")  # 发出体力不足的信号
            stamina += Utils.add_property(stamina, 5)  # 增加少量体力
            return 0  # 返回0表示此次学习未成功进行
        # 减少相应的体力和金钱，并增加编程能力
        stamina -= d.stamina
        money -= d.money
        
        tmp_skill_level += get_value(tmp_skill_level)
        tmp_skill_level = round(tmp_skill_level * 10) / 10  # 保留小数点后一位
        if tmp_skill_level > MAX_SKILL_LEVEL: #如果最后技分值大于则纠正
            tmp_skill_level = MAX_SKILL_LEVEL
        
        match type:
            Skills.DRAW:
                drawing_ability = tmp_skill_level
            Skills.CODE:
                code_ability = tmp_skill_level
            Skills.LITERATURE:
                literature_ability = tmp_skill_level
                
        emit_signal("skill_level_up",type,tmp_skill_level) # 用于任务系统触发信号量
        print(tmp_skill_level)  # 打印更新后能力值
    return 10

## 技能升级反回的经验值
func get_value(k):
    if k < 25:
        return 1
    elif k>=25 and k < 50:
        return 0.5
    elif k>=50 and k < 75:
        return 0.2
    elif k>=75 and k < 100:
        return 0.1
    else:
        # 如果 k >= 100，可以返回一个默认值或根据需求处理
        return 0  # 或者返回 null, 或抛出错误
