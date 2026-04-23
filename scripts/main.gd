extends Node

## 经验值进度条
var pb_value = 0.0
## 每天的时间长度 秒
var DAY_TIMA : float = 2

@onready var info_display = $ui/r_panel


func _ready() -> void:
    if Blogger :
        # 等级提升
        Blogger.s_level.connect(s_level)
        # 广告联盟审核通过通知
        AdManager.connect("sig_ad_1_day",on_sig_ad_1_day)
        # 广告联盟佣金结算和发放通知
        AdManager.connect("sig_ad_commission_settled",on_sig_ad_commission_settled)
        AdManager.connect("sig_ad_commission_paid",on_sig_ad_commission_paid)


        #休息信号
        Blogger.s_recrecreation_rest.connect(s_recrecreation_rest)
        Blogger.s_playgame.connect(s_playgame)

        # 技能学习信号
        Blogger.skill_learned.connect(_on_skill_learned)

        # 网站安全信号
        Blogger.signal_website_security.connect(signal_website_security)
        Blogger.signal_website_security_no_stamina.connect(signal_website_security_no_stamina)
        Blogger.signal_website_security_no_money.connect(signal_website_security_no_money)

        # seo维护
        Blogger.signal_website_seo.connect(signal_website_seo)
        Blogger.signal_website_seo_no_stamina.connect(signal_website_seo_no_stamina)

        # 页面美化
        Blogger.signal_design_web.connect(signal_design_web)
        Blogger.signal_design_web_no_stamina.connect(signal_design_web_no_stamina)

    # ===== 主机域名系统信号 =====
    if Yun:
        Yun.connect("game_over", _on_game_over)
        Yun.connect("suspend_warning", _on_suspend_warning)
        Yun.connect("blog_suspended", _on_blog_suspended)

    TimerManager.timer.wait_time = DAY_TIMA
    $ui/bottom.connect("create_blog_passed",_on_bottom_calendar_passed)
    $日程.connect("close_calendar_passed",_on_close_blog_passed)
    $ui/top.connect("time_x",_on_time_x)
    $ui/bottom.connect("open_ad_passed",_on_open_ad_passed)
    $ui/bottom.connect("open_lm",_on_open_lm)
    $lm_mian.connect("close_lm",_on_close_lm)
    $ui/bottom.connect("open_bm",_on_open_bm)
    $bank_main.connect("close_bm",_on_close_bm)
    $ui/bottom.connect("open_yun",_on_open_yun)
    $yun_main.connect("close_yun",_on_close_yun)
    $ui/bottom.connect("open_mialestones",_on_open_mialestones)
    $m_main.connect("close_mialestones",_on_close_mialestones)
    $AcceptDialog.confirmed.connect(_close_ac)

    TaskManager.connect("sg_task_info_display_msg",sg_task_info_display_msg)
    TaskManager.connect("schedule_refresh_needed", _on_schedule_refresh_needed)
    TaskManager.connect("sg_task_show_popup_msg",sg_task_show_popup_msg)
    
    # 延迟检查初始任务，确保所有节点的 _ready() 都执行完毕
    call_deferred("_check_initial_tasks")
    
    update_ui()


func _check_initial_tasks() -> void:
    TaskManager.check_initial_tasks()


    if TimerManager:
        if TimerManager.timer.is_stopped():
            TimerManager.timer.start()

    else:
        print("未能获取 TimerManager 实例")

    # 连接GDManager的自动保存信号（已禁用）
    # if GDManager and GDManager.save_manager:
    #     GDManager.save_manager.connect("auto_save_triggered", _on_auto_save_triggered)

    # 连接GDManager的时间信号
    if GDManager:
        GDManager.connect("day_passed",_on_day_ended)
        GDManager.connect("week_passed",_on_week_ended)
        GDManager.connect("month_passed",_on_month_passed)
        GDManager.connect("quarter_passed",_on_quarter_passed)
        GDManager.connect("year_passed",_on_year_passed)

    # 连接游戏退出信号（仅在非编辑器模式下）
    if not OS.has_feature("editor"):
        get_tree().set_auto_accept_quit(false)
        get_tree().quit_requested.connect(_on_quit_requested)



    
    


##主界面UI刷新
func update_ui():
    $ui/top/h1/blog_author.text = Blogger.blog_data.blog_author
    $ui/top/h1/blog_level.text = "等级:"+str(Blogger.level) + "级"
    var tx = Utils.get_rank_title(Blogger.level,Strs.game_strs.头衔)
    $ui/top/h1/头衔.text = tx
    $ui/top/h1/blog_stamina.text = "体力:"+str(Blogger.stamina)
    $ui/top/h1/blog_money.text = "钱:%.2f" % Blogger.money
    $ui/top/h1/date.text = Utils.get_time_string(TimerManager.current_year, TimerManager.current_month, TimerManager.current_week, TimerManager.current_day,TimerManager.current_quarter)
    
    $ui/top/h2/Panel/ProgressBar.show_percentage = false
    pb_value = float(Blogger.exp) / float(Blogger.get_exp_for_next_level()) * 100
    $ui/top/h2/Panel/ProgressBar.set_value_no_signal(pb_value) 
    $ui/top/h2/Panel/ProgressBar/blog_exp.text = str(Blogger.exp)+"/"+str(Blogger.get_exp_for_next_level())
    
    
    $ui/bottom/v1/h3/blog_name.text = Blogger.blog_data.blog_name
    $ui/bottom/v1/h3/blog_posts.text = "文章数:" + str(len(Blogger.blog_data.posts))
    $ui/bottom/v1/h3/blog_safety.text = "安全指数:" + str(Blogger.blog_data.safety_value)
    $ui/bottom/v1/h3/blog_seo.text = "SEO:" + str(Blogger.blog_data.seo_value)
    
    
    $ui/bottom/v1/h4/today_views.text="昨日:"+ str(Blogger.blog_data.today_views)
    $ui/bottom/v1/h4/month_vies.text="本月:"+ Utils.format_number(Blogger.blog_data.month_views)
    $ui/bottom/v1/h4/year_vies.text="今年:"+ Utils.format_number(Blogger.blog_data.year_views)
    $ui/bottom/v1/h4/blog_views.text="总:"+ Utils.format_number(Blogger.blog_data.views)
    
    $ui/bottom/v1/h5/rss.text = "RSS订阅数:"+ Utils.format_number(Blogger.blog_data.rss)
    $ui/bottom/v1/h5/favorites.text = "博文收藏数:"+ Utils.format_number(Blogger.blog_data.favorites)
    $ui/bottom/v1/h5/weekly_income.text = "小说周收入:" + str(int(Blogger.weekly_paid_income)) + "元"
    # 能力值>=80时显示付费收入
    if Blogger.literature_ability >= 80 or Blogger.code_ability >= 80 or Blogger.drawing_ability >= 80:
        $ui/bottom/v1/h5/weekly_income.visible = true
    else:
        $ui/bottom/v1/h5/weekly_income.visible = false
    
    $ui/r_panel/top/writingProgressBar.show_percentage = false
    $ui/r_panel/top/writingProgressBar.set_value_no_signal(Blogger.writing_ability)
    $ui/r_panel/top/technicalProgressBar.show_percentage = false
    $ui/r_panel/top/technicalProgressBar.set_value_no_signal(Blogger.technical_ability) 
    $ui/r_panel/top/codeProgressBar.show_percentage = false
    $ui/r_panel/top/codeProgressBar.set_value_no_signal(Blogger.code_ability) 
    $ui/r_panel/top/literatureProgressBar.show_percentage = false
    $ui/r_panel/top/literatureProgressBar.set_value_no_signal(Blogger.literature_ability) 
    $ui/r_panel/top/drawingProgressBar.show_percentage = false
    $ui/r_panel/top/drawingProgressBar.set_value_no_signal(Blogger.drawing_ability) 

## 游戏时间倍数运行控制
func time_stop_bt():
    if TimerManager.time_stop :
        $ui/top/h1/time_stop.text = "启动时间"
    else:
        $ui/top/h1/time_stop.text = "暂停时间"

## 日程管理
func _on_bottom_calendar_passed():
    $日程.visible = true
    $日程.up_data()
    
    
    TimerManager.stop_timer()
## 关闭日程管理窗口
func _on_close_blog_passed():
    $日程.visible = false
    TimerManager.start_timer()

## 日程刷新请求（任务系统锁定/隐藏文章后触发）
func _on_schedule_refresh_needed():
    # 无论日程面板是否打开，都刷新数据
    if $日程.visible:
        $日程.up_data()
    
    
## 倍速按钮按下   
func _on_time_x():
    if TimerManager.timer.wait_time == 2.0 :
        TimerManager.timer.wait_time = 1.0
        $ui/top/h1/time_x.text = "2倍速"
        #print(TimerManager.timer.wait_time)
    elif TimerManager.timer.wait_time == 1.0 :
        TimerManager.timer.wait_time = 0.1
        $ui/top/h1/time_x.text = "4倍速"
        #print(TimerManager.timer.wait_time)
    elif TimerManager.timer.wait_time != 2.0 :
        TimerManager.timer.wait_time = 2.0
        $ui/top/h1/time_x.text = "1倍速"
        #print(TimerManager.timer.wait_time)

func _on_open_bm():
    $bank_main.visible = true
    $bank_main.on_show_panel()
    
    TimerManager.stop_timer()    
    
func _on_close_bm():
    $bank_main.visible = false
    TimerManager.start_timer()
    
func _on_open_lm():
    $lm_mian.visible = true
    $lm_mian.on_show_panel()
    
    TimerManager.stop_timer()

func _on_close_lm():
    $lm_mian.visible = false
    TimerManager.start_timer()

func _on_open_yun():
    $yun_main.visible = true
    TimerManager.stop_timer()
    
func _on_close_yun():
    $yun_main.visible = false
    TimerManager.start_timer()
    
func _on_open_mialestones():
    $m_main.visible = true
    $m_main.setup_ui()
    TimerManager.stop_timer()
    
func _on_close_mialestones():
    $m_main.visible = false
    TimerManager.start_timer()
    
func _on_open_ad_passed():
    $Ad.on_show_panel()
    $Ad.visible = true
    TimerManager.stop_timer()
    
    
    

    
## 每天的信号量
func _on_day_ended():
    TaskManager.day_task_func() #游戏事件遍历
    Bs.day_fs()
    Yun.day_fs()  # 主机域名系统每日检查
    
    # 访问量计算器每日更新（事件衰减等）
    if Blogger.views_calculator:
        Blogger.views_calculator.daily_update()
    
    Blogger.daily_activities()
    
    # 每日自然恢复体力
    Blogger.daily_stamina_recovery()
    
    time_stop_bt()
    update_ui()
    AdManager.ad_day() # 更新审核日期触发审核结束的信号量

    # 自动保存游戏（已禁用）
    # auto_save_game()
    
    

func _on_week_ended():
    Blogger.week_activites() #博客相关的数据每周更新
    
    # 访问量统计周更新
    if Blogger.views_calculator:
        Blogger.views_calculator.weekly_update(TimerManager.current_year, TimerManager.current_week)

func _on_month_passed():
    # 访问量统计月更新
    if Blogger.views_calculator:
        Blogger.views_calculator.monthly_update(TimerManager.current_year, TimerManager.current_month)
    
    # 书籍销售月结算
    var sales_result = TaskManager.settle_monthly_book_sales()
    if sales_result.total_income > 0:
        var msg = "📚 本月书籍销售收入：%d元" % sales_result.total_income
        if sales_result.has("books") and sales_result.books.size() > 0:
            msg += "\n"
            for book in sales_result.books:
                msg += "  《%s》[%s]: %d元 (第%d月, 累计%d元)\n" % [
                    book.book_name, 
                    book.publisher,
                    book.income, 
                    book.sales_months, 
                    book.total_income
                ]
        # 去掉最后的换行
        msg = msg.trim_suffix("\n")
        info_display.add_message(msg)
    
    # 开源项目月结算
    var os_result = TaskManager.settle_monthly_open_source()
    if os_result.total_income > 0:
        var msg = "💻 本月开源项目赞助收入：%d元" % os_result.total_income
        if os_result.has("projects") and os_result.projects.size() > 0:
            msg += "\n"
            for project in os_result.projects:
                msg += "  《%s》[%s]: %d元 (第%d月, 累计%d元)\n" % [
                    project.project_name, 
                    project.sponsor,
                    project.income, 
                    project.sponsor_months, 
                    project.total_income
                ]
        # 去掉最后的换行
        msg = msg.trim_suffix("\n")
        info_display.add_message(msg)

func _on_quarter_passed():
    Lm.up_jhph()
    Lm.quarter_activities()

    

func _on_year_passed():
    Bs.year_fs()
    
    # 访问量统计年更新
    if Blogger.views_calculator:
        Blogger.views_calculator.yearly_update(TimerManager.current_year)
    
    info_display.add_message("一年过去了！ ")


func s_playgame(msg):
    pass

func s_recrecreation_rest(msg):
    pass
    
func signal_website_security(msg):
    pass
    
func signal_website_security_no_stamina(msg):
    info_display.add_message(msg)
    
func signal_website_security_no_money(msg):
    info_display.add_message(msg)
    

func signal_website_seo(msg):
    pass
    
func signal_website_seo_no_stamina(msg):
    info_display.add_message(msg)

func signal_design_web(msg):
    pass
    
func signal_design_web_no_stamina(msg):
    info_display.add_message(msg)   
    

## 显示通用弹窗
func show_popup_message(title: String, content: String) -> void:
    
    $AcceptDialog.title = title
    $AcceptDialog.dialog_text = content
    $AcceptDialog.set_size(Vector2i(400,200))
    $AcceptDialog.popup_centered()  
    
    TimerManager.stop_timer()

func s_level(l):
    var tx = Utils.get_rank_title(l,Strs.game_strs.头衔)
    show_popup_message("等级提升", "恭喜您的等级提升到"+str(l)+"！您的博客段位提升到了："+tx+"。")

func on_sig_ad_1_day():
    # 从审核界面切换到管理面板，并开始记录广告费用
    AdManager.ad_1_day = 0
    AdManager.ad_1 = false
    AdManager.ad_2 = true   
    show_popup_message("审核通知", "恭喜您通过广告联盟的申请！现在您可以通过点击广告联盟的按钮来设置广告投放方式以及查看收入。")

func on_sig_ad_commission_settled(msg):
    info_display.add_message(msg)

func on_sig_ad_commission_paid(msg):
    info_display.add_message(msg)

func _close_ac():
    TimerManager.start_timer()

func sg_task_info_display_msg(msg):
    info_display.add_message(msg)

## 技能学习完成处理
func _on_skill_learned(skill_name: String, tip: String):
    info_display.add_message(tip)
    # 刷新日程面板
    if $日程.visible:
        $日程.up_data()

func sg_task_show_popup_msg(title: String, content: String):
    show_popup_message(title,content)

# ===== 主机域名系统信号处理 =====

func _on_blog_suspended(source: String):
    """博客暂停信号处理"""
    info_display.add_message("⚠️ 博客已暂停运营！原因：" + ("域名" if source == "domain" else "主机" if source == "host" else "域名和主机") + "欠费")
    show_popup_message("博客暂停", "您的博客因欠费已暂停运营！\n原因：" + ("域名" if source == "domain" else "主机" if source == "host" else "域名和主机") + "到期未续费\n\n请尽快续费，否则4周后游戏将结束！")

func _on_suspend_warning(message: String):
    """欠费警告信号处理"""
    info_display.add_message("⚠️ " + message)
    show_popup_message("欠费警告", message)

func _on_game_over(suspend_days: int):
    """游戏结束信号处理"""
    # 暂停计时器
    TimerManager.stop_timer()
    # 显示游戏结束弹窗
    show_popup_message("游戏结束", "您的博客因欠费已永久下线！\n\n欠费天数：%d 天\n\n感谢您的游玩！" % suspend_days)


## 自动保存游戏（已禁用）
func auto_save_game():
    if GDManager:
        var result = GDManager.auto_save()
        if result.get("success", false):
            info_display.add_message("游戏已自动保存到存档槽位0")
        else:
            info_display.add_message("自动保存失败：" + result.get("error", "未知错误"))

## 处理自动保存触发信号（已禁用）
func _on_auto_save_triggered():
    # auto_save_game()
    pass

## 处理游戏退出请求
func _on_quit_requested():
    # 退出前保存游戏（已禁用）
    # auto_save_game()
    get_tree().quit()
    
    
    
    
