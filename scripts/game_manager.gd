extends Node

## 经验值进度条
var pb_value = 0.0
## 每天的时间长度 秒
@export var DAY_TIMA : float = 1

@onready var info_display = $ui/r_panel

func _ready() -> void:
	if Blogger :
		# 网站安全信号
		Blogger.signal_website_security.connect(signal_website_security)
		Blogger.signal_website_security_no_stamina.connect(signal_website_security_no_stamina)
		
		# seo维护
		Blogger.signal_website_seo.connect(signal_website_seo)
		Blogger.signal_website_seo_no_stamina.connect(signal_website_seo_no_stamina)
		
		# 编程技能信号
		Blogger.s_self_learning_programming_end.connect(s_self_learning_programming_end)
		Blogger.s_self_learning_programming_end_no_stamina.connect(s_self_learning_programming_end_no_stamina)
		
		Blogger.s_web_front.connect(s_web_front)
		Blogger.s_web_front_no_stamina.connect(s_web_front_no_stamina)
		
		Blogger.s_advanced_programming.connect(s_advanced_programming)
		Blogger.s_advanced_programming_no_stamina.connect(s_advanced_programming_no_stamina)
		
		Blogger.s_hacker.connect(s_hacker)
		Blogger.s_hacker_no_stamina.connect(s_hacker_no_stamina)
		
		
		# 文学技能信号
		Blogger.s_literature_1.connect(s_literature_1)
		Blogger.s_literature_1_no_stamina.connect(s_literature_1_no_stamina)
		
		Blogger.s_literature_2.connect(s_literature_2)
		Blogger.s_literature_2_no_stamina.connect(s_literature_2_no_stamina)
		
		Blogger.s_literature_3.connect(s_literature_3)
		Blogger.s_literature_3_no_stamina.connect(s_literature_3_no_stamina)
		
		Blogger.s_literature_4.connect(s_literature_4)
		Blogger.s_literature_4_no_stamina.connect(s_literature_4_no_stamina)
		
		
		# 绘画技能信号
		Blogger.s_draw_1.connect(s_draw_1)
		Blogger.s_draw_1_no_stamina.connect(s_draw_1_no_stamina)
		
		Blogger.s_draw_2.connect(s_draw_2)
		Blogger.s_draw_2_no_stamina.connect(s_draw_2_no_stamina)
		
		Blogger.s_draw_3.connect(s_draw_3)
		Blogger.s_draw_3_no_stamina.connect(s_draw_3_no_stamina)
		
		Blogger.s_draw_4.connect(s_draw_4)
		Blogger.s_draw_4_no_stamina.connect(s_draw_4_no_stamina)
		
	TimerManager.timer.wait_time = DAY_TIMA 
	$ui/bottom.connect("create_blog_passed",_on_bottom_calendar_passed)
	$calendar.connect("close_calendar_passed",_on_close_blog_passed)
	
	
	update_ui()
	

	if TimerManager:
		TimerManager.connect("day_passed",_on_day_ended) # 绑定每天信号量
		TimerManager.connect("week_passed",_on_week_ended) # 绑定每周信号量
		TimerManager.connect("month_passed",_on_month_passed)
		TimerManager.connect("quarter_passed", _on_quarter_passed)
		TimerManager.connect("year_passed",_on_year_passed)
		if TimerManager.timer.is_stopped():
			TimerManager.timer.start()
			#Blogger.daily_activities()
		
	else:
		print("未能获取 TimerManager 实例")


## 每天的信号量
func _on_day_ended():
	Blogger.daily_activities()
	#print( " 属性: ", Blogger.writing_ability, ", ", Blogger.social_ability, ", ", Blogger.technical_ability,", ", Blogger.stamina, ", ",  " 金钱: ", Blogger.money,)
	
	update_ui()
	

func update_ui():
	$ui/top/h1/blog_author.text = Blogger.blog_data.blog_author
	$ui/top/h1/blog_level.text = str(Blogger.level) + "级"
	$ui/top/h1/blog_stamina.text = str(Blogger.stamina)
	$ui/top/h1/blog_money.text = str(Blogger.money)
	$ui/top/h1/date.text = Utils.get_time_string(TimerManager.current_year, TimerManager.current_month, TimerManager.current_week, TimerManager.current_day,TimerManager.current_quarter)
	
	$ui/top/h2/Panel/ProgressBar.show_percentage = false
	pb_value = float(Blogger.exp) / float(Blogger.get_exp_for_next_level()) * 100
	$ui/top/h2/Panel/ProgressBar.set_value_no_signal(pb_value) 
	$ui/top/h2/Panel/ProgressBar/blog_exp.text = str(Blogger.exp)+"/"+str(Blogger.get_exp_for_next_level())
	
	
	$ui/bottom/v1/h3/blog_name.text = Blogger.blog_data.blog_name
	$ui/bottom/v1/h3/blog_posts.text = "文章数:" + str(len(Blogger.blog_data.posts))
	$ui/bottom/v1/h3/blog_safety.text = "安全指数:" + str(Blogger.blog_data.safety_value)
	$ui/bottom/v1/h3/blog_seo.text = "SEO:" + str(Blogger.blog_data.seo_value)
	
	
	$ui/bottom/v1/h4/today_views.text="昨日："+ str(Blogger.blog_data.today_views)
	$ui/bottom/v1/h4/month_vies.text="本月："+ str(Blogger.blog_data.month_views)
	$ui/bottom/v1/h4/year_vies.text="今年："+ str(Blogger.blog_data.year_views)
	$ui/bottom/v1/h4/blog_views.text="总："+ str(Blogger.blog_data.views)

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

## 日程管理
func _on_bottom_calendar_passed():
	$calendar.visible = true
	# 根据配置文件，更新选框按钮
	$calendar/Panel/bottom/sc/bt/day_tabs/d1._on_show_panel()
	$calendar/Panel/bottom/sc/bt/day_tabs/d2._on_show_panel()
	$calendar/Panel/bottom/sc/bt/day_tabs/d3._on_show_panel()
	$calendar/Panel/bottom/sc/bt/day_tabs/d4._on_show_panel()
	$calendar/Panel/bottom/sc/bt/day_tabs/d5._on_show_panel()
	$calendar/Panel/bottom/sc/bt/day_tabs/d6._on_show_panel()
	$calendar/Panel/bottom/sc/bt/day_tabs/d7._on_show_panel()
	
	TimerManager.timer.stop()
	
## 关闭程管理窗口
func _on_close_blog_passed():
	$calendar.visible = false
	TimerManager.timer.start()
	

func _on_week_ended():
	Blogger.week_activites()

func _on_month_passed():
	info_display.add_message("一个月过去了！ ")

func _on_quarter_passed():
	info_display.add_message("一个季度过去了！ ")

func _on_year_passed():
	info_display.add_message("一年过去了！ ")
	
func signal_website_security(msg):
	info_display.add_message(msg)
	
func signal_website_security_no_stamina(msg):
	info_display.add_message(msg)
	
func signal_website_seo(msg):
	info_display.add_message(msg)
	
func signal_website_seo_no_stamina(msg):
	info_display.add_message(msg)
	
	
# 编程技能信号量
func s_self_learning_programming_end(msg):
	var d = Utils.find_category_by_name(Utils.possible_categories,"编程教程")
	d.disabled = false
	info_display.add_message(msg)
	
func s_self_learning_programming_end_no_stamina(msg):
	info_display.add_message(msg)
	
func s_web_front(msg):
	var d = Utils.find_category_by_name(Utils.possible_categories,"程序员周刊")
	d.disabled = false
	info_display.add_message(msg)
	
func s_web_front_no_stamina(msg):
	info_display.add_message(msg)
	
func s_advanced_programming(msg):
	var d = Utils.find_category_by_name(Utils.possible_categories,"付费编程教程")
	d.disabled = false
	info_display.add_message(msg)
	
func s_advanced_programming_no_stamina(msg):
	info_display.add_message(msg)
	
func s_hacker(msg):
	var d = Utils.find_category_by_name(Utils.possible_categories,"付费黑客攻防")
	d.disabled = false
	info_display.add_message(msg)
	
func s_hacker_no_stamina(msg):
	info_display.add_message(msg)
	
	
# 文学技能信号量
	
func s_literature_1(msg):
	var d = Utils.find_category_by_name(Utils.possible_categories,"散文随笔")
	d.disabled = false
	info_display.add_message(msg)
	
func s_literature_1_no_stamina(msg):
	info_display.add_message(msg)
	
func s_literature_2(msg):
	var d = Utils.find_category_by_name(Utils.possible_categories,"文学周刊")
	d.disabled = false
	info_display.add_message(msg)
	
func s_literature_2_no_stamina(msg):
	info_display.add_message(msg)
	
func s_literature_3(msg):
	var d = Utils.find_category_by_name(Utils.possible_categories,"爆款网文")
	d.disabled = false
	info_display.add_message(msg)
	
func s_literature_3_no_stamina(msg):
	info_display.add_message(msg)
	
func s_literature_4(msg):
	var d = Utils.find_category_by_name(Utils.possible_categories,"小说连载(收费)")
	d.disabled = false
	info_display.add_message(msg)
	
func s_literature_4_no_stamina(msg):
	info_display.add_message(msg)

# 绘画技能信号量
	
func s_draw_1(msg):
	var d = Utils.find_category_by_name(Utils.possible_categories,"插画壁纸")
	d.disabled = false
	info_display.add_message(msg)
	
func s_draw_1_no_stamina(msg):
	info_display.add_message(msg)
	
func s_draw_2(msg):
	var d = Utils.find_category_by_name(Utils.possible_categories,"绘画基础教程")
	d.disabled = false
	info_display.add_message(msg)
	
func s_draw_2_no_stamina(msg):
	info_display.add_message(msg)
	
func s_draw_3(msg):
	var d = Utils.find_category_by_name(Utils.possible_categories,"艺术周刊")
	d.disabled = false
	info_display.add_message(msg)
	
func s_draw_3_no_stamina(msg):
	info_display.add_message(msg)
	
func s_draw_4(msg):
	var d = Utils.find_category_by_name(Utils.possible_categories,"动漫连载(收费)")
	d.disabled = false
	info_display.add_message(msg)
	
func s_draw_4_no_stamina(msg):
	info_display.add_message(msg)
