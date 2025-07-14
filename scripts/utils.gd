extends Node

# 工具类，存放一些工具方法

## 博客类型
var possible_categories: Array[Dictionary] = [
	{
		"name":"生活日记",
		"tip":"生活流水账，如果文学素养很高，写出的日记会很招人喜欢？",
		"disabled":false,
		"pressed":false,
		"is_money":false,
		"money" : 0,
		"stamina":10,
	},
	{
		"name":"网站运维",
		"tip":"关于运营博客的一些心得，编程等级很高的人可以写出更多的精品运维技术文章。",
		"disabled":false,
		"pressed":false,
		"money" : 0,
		"is_money":false,
		"stamina":10,
	},
	{
		"name":"编程教程",
		"tip":"完成学习编程1级后的时候解锁。",
		"disabled":true,
		"pressed":false,
		"money" : 0,
		"is_money":false,
		"stamina":10,
	},
	{
		"name":"程序员周刊",
		"tip":"当技术达到一定程度后，编写技术周刊可以定期收获大量访问量。",
		"disabled":true,
		"pressed":false,
		"money" : 0,
		"is_money":false,
		"stamina":50,
	},
	{
		"name":"付费编程教程",
		"tip":"完成高级编程学习后可以解锁付费程，访问量不高，
		但是却可以有一定的收入。",
		"disabled":true,
		"pressed":false,
		"money" : 0,
		"is_money":true,
		"stamina":30,
	},
	{
		"name":"付费黑客攻防",
		"tip":"编程及技术达到最高级别解锁，访问量不高，
		但是却可以有很高的收入。",
		"disabled":true,
		"pressed":false,
		"money" : 0,
		"is_money":true,
		"stamina":50,
	},
		{
		"name":"散文随笔",
		"tip":"多多阅读可以解锁。",
		"disabled":true,
		"pressed":false,
		"money" : 0,
		"is_money":false,
		"stamina":10,
	},
	{
		"name":"文学周刊",
		"tip":"高质量的文学周刊，令人眼前一亮！",
		"disabled":true,
		"pressed":false,
		"money" : 0,
		"is_money":false,
		"stamina":50,
	},
	{
		"name":"爆款网文",
		"tip":"一针见血，直击热点内容！",
		"disabled":true,
		"pressed":false,
		"money" : 0,
		"is_money":false,
		"stamina":50,
	},
	{
		"name":"小说连载(收费)",
		"tip":"情节令人惊叹，文笔优雅，就算是收费的，
		也还是有很多人订阅了连载",
		"disabled":true,
		"pressed":false,
		"money" : 0,
		"is_money":true,
		"stamina":30,
	},
	{
		"name":"插画壁纸",
		"tip":"画画新手的练习日常，很受手欢迎？",
		"disabled":true,
		"pressed":false,
		"money" : 0,
		"is_money":false,
		"stamina":10,
	},
	{
		"name":"绘画基础教程",
		"tip":"完成素描色彩基础后可以编写些适合新手的程。",
		"disabled":true,
		"pressed":false,
		"money" : 0,
		"is_money":false,
		"stamina":20,
	},
	{
		"name":"艺术周刊",
		"tip":"原画师达成的路上，分享对艺术的另类见解，
		深受网友喜爱",
		"disabled":true,
		"pressed":false,
		"money" : 0,
		"is_money":false,
		"stamina":50,
	},
	{
		"name":"动漫连载(收费)",
		"tip":"情节令人惊叹，独创画风，就算是收费，
		也还是有很多人订阅了连载",
		"disabled":true,
		"pressed":false,
		"money" : 0,
		"is_money":true,
		"stamina":50,
	},
	]
	
## 网站运维
var website_maintenance: Array[Dictionary] =[
	{
		"name":"SEO优化",
		"tip":"保证博客来自搜索引擎的基础访问量，
		SEO值过低，博客会没有访问量",
		"disabled":false,
		"pressed":false,
		"money" : 0,
		"stamina":10,
		
	},
	{
		"name":"安全维护",
		"tip":"博客的安全数值，安全值过低，
		博客会遭到攻击，丢失数据或无法打开页面。",
		"disabled":false,
		"pressed":false,
		"money" : 0,
		"stamina":10,
	},
	{
		"name":"页面美化",
		"tip":"需要一定的绘画等级，
		漂亮的页面会是访问量、收藏量增加。",
		"disabled":true,
		"pressed":false,
		"money" : 0,
		"stamina":10,
	},
	{
		"name":"互动管理",
		"tip":"良好的互动会增加博客的知名度，
		进而增加博客访问量。需要有评论或留言的候才会开启。",
		"disabled":true,
		"pressed":false,
		"money" : 0,
		"stamina":5,
	},
]

## 休闲娱乐
var recreation : Array[Dictionary] = [
	{
		"name":"休息",
		"disabled":false,
		"pressed":false,
		"money" : 0,
		"stamina":50,
	},
	{
		"name":"打游戏",
		"disabled":false,
		"pressed":false,
		"money" : 100,
		"stamina":100,
	},
	{
		"name":"国内旅游",
		"disabled":true,
		"pressed":false,
		"money" : 3000,
		"stamina":80,
	},
	{
		"name":"出国旅游",
		"disabled":true,
		"pressed":false,
		"money" : 10000,
		"stamina":80,
	},
]

## 学习各种技能
var learning_skills : Array[Dictionary] = [
	{
		"name":"自学编程",
		"tip":"编程1级",
		"disabled":false,
		"pressed":false,
		"money" : 10,
		"stamina":10,
	},
	{
		"name":"学习前端",
		"tip":"编程2级，需学完编程1级后解锁",
		"disabled":true,
		"pressed":false,
		"money" : 20,
		"stamina":10,
	},
	{
		"name":"高级编程",
		"tip":"编程3级，需学完2级后解锁",
		"disabled":true,
		"pressed":false,
		"money" : 50,
		"stamina":10,
	},
		{
		"name":"成为黑客",
		"tip":"编程4级，需学完编程3级后解锁",
		"disabled":true,
		"pressed":false,
		"money" : 100,
		"stamina":10,
	},
	{
		"name":"阅读名著",
		"tip":"文学1级，提高文学素养。",
		"disabled":false,
		"pressed":false,
		"money" : 10,
		"stamina":10,
	},
	{
		"name":"写作基础理论",
		"tip":"文学2级，需学完文学1级后解锁",
		"disabled":true,
		"pressed":false,
		"money" : 20,
		"stamina":10,
	},
	{
		"name":"高级文学",
		"tip":"文学3级，需学完文学2级后解锁",
		"disabled":true,
		"pressed":false,
		"money" : 50,
		"stamina":10,
	},
		{
		"name":"小说家",
		"tip":"文学4级，需学完文学3级后解锁",
		"disabled":true,
		"pressed":false,
		"money" : 100,
		"stamina":10,
	},
	{
		"name":"自学画画",
		"tip":"绘画1级",
		"disabled":false,
		"pressed":false,
		"money" : 10,
		"stamina":10,
	},
	{
		"name":"素描和色彩",
		"tip":"绘画2级，需学完绘画1级后解锁",
		"disabled":true,
		"pressed":false,
		"money" : 20,
		"stamina":10,
	},
	{
		"name":"原画师之路",
		"tip":"绘画3级，需学完绘画2级后解锁",
		"disabled":true,
		"pressed":false,
		"money" : 50,
		"stamina":10,
	},
		{
		"name":"大画家",
		"tip":"绘画4级，需学完绘画3级后解锁",
		"disabled":true,
		"pressed":false,
		"money" : 100,
		"stamina":10,
	},

]
## 清除当前节点下所有子节点
func clear_children(node):
	# 获取当前节点的所有子节点
	var children = node.get_children()

	# 遍历子节点数组并移除它们
	for child in children:
		remove_child(child)
		# 建议使用 queue_free() 来在下一帧安全地释放节点
		child.queue_free()
	
### 创建每日任务单选按钮
#func create_checkbox(node,KEY,text,array,button_group,_on_checkbox_toggled):
	#var fc = FlowContainer.new()
	#var blog_label = Label.new()
	#blog_label.text = text
	#blog_label.set_h_size_flags(Control.SIZE_SHRINK_CENTER)
	#node.add_child(blog_label)
	#node.add_child(fc)
	#for category in array:
		#var cname = category.name
		#if cname  == "程序员周刊" and KEY + 1 == 1:
			#var checkbox = CheckBox.new()
			#checkbox.text = category.name
			#if category.has("tip"):
				#checkbox.set_tooltip_text(category.tip)
			#checkbox.disabled = category.disabled
			#if Blogger.blog_calendar[KEY].task == category.name:
				#checkbox.set_pressed_no_signal(true)
			#checkbox.button_group = button_group
			#fc.add_child(checkbox)
			#checkbox.toggled.connect(_on_checkbox_toggled.bind(category.name))
		#else:
			#pass
			
func create_ad_checkbox(fc,array,button_grroup,_on_checkbox_toggled):
	for category in array:
		var cname = category.name
		add_ad_checkbox(fc,category,button_grroup,_on_checkbox_toggled)
# 创建并添加广告联盟的复选框
func add_ad_checkbox(fc, category, button_group, _on_checkbox_toggled):
	
	var checkbox = CheckBox.new()
	#print("Adding checkbox for category: ", category.name) # 调试信息
	checkbox.text = category.name
	if category.has("tip"):
		checkbox.set_tooltip_text(category.tip)
	checkbox.disabled = category.disabled
	if AdManager.ad_set == category.name:
		checkbox.set_pressed_no_signal(true)
	checkbox.button_group = button_group
	fc.add_child(checkbox)
	checkbox.toggled.connect(_on_checkbox_toggled.bind(category.name))

func create_checkbox(node,KEY,text,array,button_group,_on_checkbox_toggled):
	var fc = FlowContainer.new()
	var blog_label = Label.new()
	blog_label.text = text
	blog_label.set_h_size_flags(Control.SIZE_SHRINK_CENTER)
	node.add_child(blog_label)
	node.add_child(fc)

	for category in array:
		var cname = category.name

		if should_add_category(cname, KEY + 1):
			add_checkbox(fc, category, KEY, button_group, _on_checkbox_toggled)


# 判断是否应该添加某个类别
func should_add_category(cname: String, day: int) -> bool:
	if cname == "程序员周刊" and day == 1:
		return true
	elif cname == "文学周刊" and day == 3:
		return true
	elif cname == "艺术周刊" and day == 5:
		return true
	else:
		# 对于非特定字符串的情况，如果没有匹配到上述任何条件，则无条件添加
		# 注意：这里假设如果cname不是这三个特定字符串之一，则返回true表示添加
		# 如果逻辑是只有这三个条件才添加，其他情况都不添加，则应改为：
		# return false
		return not (cname == "程序员周刊" or cname == "文学周刊" or cname == "艺术周刊")





# 创建并添加复选框
func add_checkbox(fc, category, KEY, button_group, _on_checkbox_toggled):
	assert(fc != null, "FlowContainer is null")
	
	var checkbox = CheckBox.new()
	#print("Adding checkbox for category: ", category.name) # 调试信息
	checkbox.text = category.name
	if category.has("tip"):
		checkbox.set_tooltip_text(category.tip)
	checkbox.disabled = category.disabled
	if Blogger.blog_calendar[KEY].task == category.name:
		checkbox.set_pressed_no_signal(true)
	checkbox.button_group = button_group
	fc.add_child(checkbox)
	checkbox.toggled.connect(_on_checkbox_toggled.bind(category.name))

## 循环创建每日任务单选按钮
func create_all_checkbox(node,KEY,button_group,_on_checkbox_toggled):
	var items = [
		{
			"text":"博文写作安排",
			"ary":Utils.possible_categories,
		},
		{
			"text":"网站维护",
			"ary":Utils.website_maintenance,
		},
		{
			"text":"休闲娱乐",
			"ary":Utils.recreation,
		},
		{
			"text":"自律学习",
			"ary":Utils.learning_skills,
		},
	]
	for item in items:
		create_checkbox(node,KEY,item.text,item.ary,button_group,_on_checkbox_toggled)
	
	

# 检查字符串是否存在于数组中的方法
func check_name_exists(categories: Array, name_to_check: String) -> bool:
	for category in categories:
		if category["name"] == name_to_check:
			return true
	return false

## 获取博客文章类型
func get_selected_category_names(categories: Array[Dictionary]) -> Array[String]:
	var selected_names: Array[String] = []
	for category in categories:
		if not category.disabled and category.pressed:
			selected_names.append(category.name)
	return selected_names

## 获取当前时间的字符串表示
func get_time_string(current_year, current_month, current_week, current_day,current_quarter) -> String:
	return "%d年%d月%d周%d天" % [current_year, current_month, current_week, current_day]


## 格式化日期为 "YYYY-M-D" 字符串
func format_date() -> String:
	return str(TimerManager.current_year) + "-" + str(TimerManager.current_month) + "-" + str(TimerManager.current_week) + "-" + str(TimerManager.current_day)

## 是否为周刊
func contains_weekly_shorter(p_string: String) -> bool:
	return p_string.find("周刊") != -1

## 生成一个简单的随机标题
func generate_random_title(category: String) -> String:
	
	if not contains_weekly_shorter(category):
		var prefixes: Array[String] = [
		"探索", "分享", "我的", "关于", "如何",
		"学习", "体验", "发现", "讨论", "实践"
		]
		var topics: Dictionary = {
		"生活日记": [
			"每日心得", "家庭活动", "工作牢骚", "无聊的一天",
			"心情记录", "生活小确幸", "日常琐事", "成长感悟",
			"周末时光", "生活碎片"
		],
		"网站运维": [
			"HTML/CSS技巧", "SEO优化策略", "网站安全防护", "用户体验设计",
			"服务器配置", "前端性能优化", "内容管理技巧", "插件推荐",
			"流量分析方法", "响应式布局"
		],
		"编程教程": [
			"Python入门", "Web开发技巧", "算法学习", "游戏开发",
			"JavaScript基础", "数据库操作", "版本控制", "项目实战",
			"API设计与调用", "调试技巧"
		],
		"付费编程教程": ["全栈开发实战", "Python自动化脚本", "React前端进阶", 
		"Docker与容器化部署","机器学习实战", "Node.js项目实战", "数据库性能优化",
		"TypeScript高级技巧","微服务架构详解", "CI/CD流程构建"
		],
		"付费黑客攻防": ["Web渗透测试", "逆向工程入门", "漏洞挖掘实战", 
		"社工攻击解析","内网横向渗透", "加密解密技术", "CTF竞赛技巧", 
		"安全加固指南", "APT攻击分析",  "红队攻防演练"
		],
		"散文随笔": [
			"自然感悟", "心灵鸡汤", "城市故事", "旅行随感",
			"童年回忆", "人生哲理", "四季变换", "夜晚思绪",
			"阅读笔记", "人间烟火"
		],
		"爆款网文": ["都市异能", "玄幻修真", "穿越重生", 
		"系统流爽文","恋爱甜宠", "末世生存", "悬疑推理", 
		"反套路爽文","高武世界", "校园热血"
		],
		"小说连载(收费)": [
			"科幻世界", "悬疑解谜", "浪漫爱情", "历史传奇",
			"都市异能", "青春校园", "末日生存", "穿越时空",
			"奇幻冒险", "热血战斗"
		],
		"插画壁纸": [
			"自然风景", "梦幻星空", "动物天地", "建筑艺术",
			"极简风格", "复古风情", "未来科技", "动漫角色",
			"节日氛围", "手绘涂鸦"
		],
		"绘画基础教程": [
			"色彩理论", "素描基础", "构图技巧", "光影效果",
			"线条练习", "比例结构", "透视原理", "材质表现",
			"动态姿势", "工具使用"
		],
		"动漫连载(收费)": [
			"青春校园", "奇幻冒险", "热血战斗", "温馨日常",
			"机甲战争", "魔法世界", "恋爱喜剧", "悬疑推理",
			"异世界穿越", "职场奋斗"
		]
	}
		var prefix: String = prefixes[randi() % prefixes.size()]
		var topic: String = topics.get(category, ["未知主题"])[randi() % topics.get(category, ["未知主题"]).size()]
		print(prefix + " " + topic)
		return prefix + " " + topic
	else :
		var blog_date = Utils.format_date()
		print(category + " " + blog_date)
		return category + " " + blog_date

## 返回文章质量，生活日记只需要写作能力，其他的要写作能力/2+专业能力/2
func get_quality(category:String) -> int:
	if category == "生活日记" or category == "散文随笔" or category == "文学周刊" or category == "小说连载(收费)":
		return int(Blogger.writing_ability + Blogger.literature_ability)
	elif category == "网站运维" :
		return int(Blogger.writing_ability*0.5 + Blogger.technical_ability*0.5 + Blogger.code_ability*0.5 + Blogger.literature_ability *0.5)
	elif  category == "编程教程" or category == "付费编程教程" or category == "程序员周刊" or category == "付费黑客攻防":
		return int(Blogger.writing_ability*0.5 + Blogger.code_ability + Blogger.literature_ability *0.5)
	else:
		return 0
	
## 根据 name 值从数组中查找并返回对应的字典。
func find_category_by_name(array:Array ,name_to_find: String) -> Dictionary:
	for category in array:
		if category.get("name", "").to_lower() == name_to_find.to_lower():
			return category
	return {}
	
## 属性值的增加
func add_property(a,b) -> int:
	if a + b <= 100:
		return  b
	elif a<=100 and a + b>100:
		return 100 - a
	else:
		return 0

func calculate_new_game_time_difference(date_str1: String, date_str2: String) -> int:
	"""
	计算两个新的游戏日期字符串之间的天数差，格式为 "YYYY-M-W-D"。

	参数:
		date_str1: 第一个日期字符串，格式为 "YYYY-M-W-D"。
		date_str2: 第二个日期字符串，格式为 "YYYY-M-W-D"。

	返回值:
		两个日期之间的天数差（整数）。
	"""
	var date1_parts_str = date_str1.split("-")
	var date1_parts = []
	for part in date1_parts_str:
		date1_parts.append(int(part))
	var year1 = date1_parts[0]
	var month1 = date1_parts[1]
	var week1 = date1_parts[2]
	var day1 = date1_parts[3]

	var date2_parts_str = date_str2.split("-")
	var date2_parts = []
	for part in date2_parts_str:
		date2_parts.append(int(part))
	var year2 = date2_parts[0]
	var month2 = date2_parts[1]
	var week2 = date2_parts[2]
	var day2 = date2_parts[3]

	# 计算第一个日期距离游戏纪元（可以假定为 0000-1-1-1）的天数
	var days1 = (year1 - 1) * 12 * 4 * 7 + (month1 - 1) * 4 * 7 + (week1 - 1) * 7 + day1

	# 计算第二个日期距离游戏纪元的天数
	var days2 = (year2 - 1) * 12 * 4 * 7 + (month2 - 1) * 4 * 7 + (week2 - 1) * 7 + day2

	# 返回两个日期之间的天数差的绝对值
	return abs(days2 - days1)+1

const SHORT_DECAY_THRESHOLD = 5
const MEDIUM_DECAY_THRESHOLD = 10
const LONG_DECAY_THRESHOLD = 21
## 访问量按着时间递减，因为越久的文章浏览量会越少
func decrease_blog_views(views, old_day, now_day) -> int:
	var kk = calculate_new_game_time_difference(old_day, now_day)
	#print(old_day, now_day,kk)
	if kk <= SHORT_DECAY_THRESHOLD and kk > 0:
		return views
	elif kk > SHORT_DECAY_THRESHOLD and kk <= MEDIUM_DECAY_THRESHOLD:
		return int(views * 0.5)
	elif kk > MEDIUM_DECAY_THRESHOLD and kk <= LONG_DECAY_THRESHOLD:
		return int(views * 0.2)
	else:
		# 处理 kk <= 0 或 kk > LONG_DECAY_THRESHOLD 的情况
		return randf_range(0,1) # 例如，超过21天后，几乎没有流量，当然热门文章会另有算法。

## 替换数组中的字典值
func replace_task_value(arr: Array, old_task: String, new_task: String):
	# 遍历数组中的每个元素
	for i in range(arr.size()):
		# 检查当前元素是否是字典，并且包含 "task" 键
		if arr[i].has("task"):
			# 如果当前任务值等于需要替换的旧任务值，则进行替换
			if arr[i]["task"] == old_task:
				arr[i]["task"] = new_task
				
# 定义一个方法用于减少给定值，并确保其不会小于0
func decrease_value_safely(current_value: int, min_decrease: int, max_decrease: int) -> int:
	# 减少的值为[min_decrease, max_decrease]之间的随机数
	var decrease_amount = randi_range(min_decrease, max_decrease)
	
	# 更新current_value，但确保它不会小于0
	var new_value = current_value - decrease_amount
	if new_value < 0:
		new_value = 0
	if new_value > 100:
		new_value = 100
	
	return new_value
	
	
# 定义一个函数用于查找指定名称技能的索引
func find_category_index(skill_list, category_name: String) -> int:
	for i in range(skill_list.size()):
		if skill_list[i].name == category_name:
			return i  # 返回找到的索引
	return -1  # 如果没有找到，返回-1


# base_views 基础问量
# post 可以是一个包含 'quality' 属性的任何对象或字典
## 该方法会根据文章质量返回计算出的文章访问量
func calculate_post_views(base_views:int, post: Dictionary) -> int:

	# 2. 归一化文章质量分 (将 0-200 转换为 0-1)
	# 确保 post.quality 是 float 类型以便精确计算
	var normalized_quality: float = float(post.quality) / 200.0

	# 3. 定义幂函数指数，用于控制梯度陡峭程度
	# power = 2.0 (平方) 是推荐值，能提供明显的梯度
	var power: float = 2.0 
	var quality_effect_multiplier: float = pow(normalized_quality, power)

	# 4. 定义满分文章的最高倍数
	# 这表示当文章质量为满分(200)时，访问量是 base_views 的多少倍
	var max_possible_quality_effect: float = 200.0 

	# 5. 计算最终访问量
	var final_views: int = int(base_views * quality_effect_multiplier * max_possible_quality_effect)

	# 6. 确保最低访问量为 1，避免出现 0 访问量的情况（可选）
	final_views = max(1, final_views)
	
	return final_views
	
## 根据访问量叠加分享后的访问量
func calculate_final_views(base_views: int) -> int:
	# 定义最大访问量用于归一化
	const MAX_VIEWS := 5000

	# 将 base_views 映射为 [0, 1] 区间
	var weight = clamp(float(base_views) / MAX_VIEWS, 0.0, 1.0)

	# 根据 weight 动态计算分享几率（1% ~ 50%）
	var share_chance = lerp(0.01, 0.5, weight)

	# 根据 weight 动态计算阅读几率（25% ~ 75%）
	var read_chance = lerp(0.25, 0.75, weight)

	# 新增访问量 = 原始访问量 × 分享几率 × 阅读几率
	var added_views = base_views * share_chance * read_chance

	# 返回最终访问量
	return int(added_views)
