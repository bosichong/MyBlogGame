extends Node

# 工具类，存放一些工具方法

## 数据变量（在 _init 中初始化）
var possible_categories
var website_maintenance
var recreation
var learning_skills

var post_trend = {"type": "文学", "views_add": 0.1}
var bc_type = ["文学", "技术", "艺术"]

func _init():
	# GDManager 的 _init 先执行，数据已加载
	possible_categories = GDManager.get_blog_categories().categories
	website_maintenance = GDManager.get_website_maintenance().items
	recreation = GDManager.get_recreation().items
	learning_skills = GDManager.get_learning_skills().items


## 返回文章质量
func get_quality(category: String) -> int:
	var literary = ["年度总结", "生活日记", "爆款网文", "散文随笔", "文学周刊", "小说连载(收费)"]
	var tech = ["编程教程", "付费编程教程", "程序员周刊", "付费黑客攻防"]
	var art = ["插画壁纸", "绘画基础教程", "艺术周刊", "动漫连载(收费)"]
	
	if category in literary:
		return int(Blogger.writing_ability + Blogger.literature_ability)
	elif category == "网站运维":
		return int(Blogger.writing_ability * 0.5 + Blogger.technical_ability * 0.5 + Blogger.code_ability * 0.5 + Blogger.literature_ability * 0.5)
	elif category in tech:
		return int(Blogger.writing_ability * 0.5 + Blogger.code_ability + Blogger.literature_ability * 0.5)
	elif category in art:
		return int(Blogger.writing_ability * 0.5 + Blogger.drawing_ability + Blogger.literature_ability * 0.5)
	else:
		return 0


## 生成随机标题
func generate_random_title(category: String) -> String:
	var prefixes = GDManager.get_title_templates().prefixes
	var topics = GDManager.get_title_templates().topics
	
	if not contains_weekly_shorter(category):
		var prefix = prefixes[randi() % prefixes.size()]
		var topic_list = topics.get(category, ["未知主题"])
		var topic = topic_list[randi() % topic_list.size()]
		if category == "年度总结":
			return prefix + str(TimerManager.current_year) + "年" + topic
		elif category == "第一篇博文":
			return "新人报道请多关照：新博客开张了！"
		else:
			return prefix + " " + topic
	else:
		return category + " " + format_date()


## 清除子节点
func clear_children(parent):
	for child in parent.get_children():
		parent.remove_child(child)
		child.queue_free()


func create_ad_checkbox(fc, array, button_group, callback):
	for cat in array:
		add_ad_checkbox(fc, cat, button_group, callback)


func add_ad_checkbox(fc, cat, button_group, callback):
	var cb = CheckBox.new()
	cb.text = cat["name"]
	if cat.has("tip"):
		cb.tooltip_text = cat["tip"]
	cb.disabled = cat["disabled"]
	if AdManager.ad_set == cat["name"]:
		cb.button_pressed = true
	cb.button_group = button_group
	fc.add_child(cb)
	cb.toggled.connect(callback.bind(cat["name"]))


func create_checkbox(node, KEY, text, array, callback):
	var fc = FlowContainer.new()
	var label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	node.add_child(label)
	node.add_child(fc)
	
	for cat in array:
		if should_add_category(cat["name"], KEY + 1):
			add_checkbox(fc, cat, KEY, callback)


func should_add_category(cname: String, day: int) -> bool:
	if cname == "程序员周刊" and day == 1:
		return true
	elif cname == "文学周刊" and day == 3:
		return true
	elif cname == "艺术周刊" and day == 5:
		return true
	else:
		return not (cname in ["程序员周刊", "文学周刊", "艺术周刊"])


func add_checkbox(fc, cat, KEY, callback):
	if not cat["isVisible"]:
		return
	var cb = CheckBox.new()
	cb.text = cat["name"]
	if cat.has("tip"):
		cb.tooltip_text = cat["tip"]
	cb.disabled = cat["disabled"]
	if cat["name"] in Blogger.blog_calendar[KEY]["tasks"]:
		cb.button_pressed = true
	fc.add_child(cb)
	cb.toggled.connect(callback.bind(cat["name"]))


func create_all_checkbox(node, KEY, callback):
	var items = [
		{"text": "博文写作安排", "ary": possible_categories},
		{"text": "网站维护", "ary": website_maintenance},
		{"text": "休闲娱乐", "ary": recreation},
		{"text": "自律学习", "ary": learning_skills},
	]
	for item in items:
		create_checkbox(node, KEY, item["text"], item["ary"], callback)


func check_name_exists(categories: Array, name_to_check: String) -> bool:
	for cat in categories:
		if cat["name"] == name_to_check:
			return true
	return false


func get_selected_category_names(categories):
	var result = []
	for cat in categories:
		if not cat["disabled"] and cat["pressed"]:
			result.append(cat["name"])
	return result


func contains_weekly_shorter(s: String) -> bool:
	return "周刊" in s


func find_category_by_id(array: Array, id: String) -> Dictionary:
	for cat in array:
		if cat.get("id", "").to_lower() == id.to_lower():
			return cat
	return {}


func find_category_by_name(array: Array, name: String) -> Dictionary:
	for cat in array:
		if cat.get("name", "").to_lower() == name.to_lower():
			return cat
	return {}


## 获取体力上限（按等级）
func get_max_stamina(level: int) -> int:
	if level <= 10:
		return 50 + level  # 51-60
	elif level <= 30:
		return 60 + (level - 10)  # 61-80
	elif level <= 50:
		return 80 + (level - 30)  # 81-100
	else:
		return 100 + int((level - 50) * 0.5)  # 101-125


## 获取实际体力消耗（按等级）
func get_stamina_cost(base_cost: int, level: int) -> int:
	var coefficient = 1.0
	if level <= 10:
		coefficient = 1.0
	elif level <= 30:
		coefficient = 0.9
	elif level <= 50:
		coefficient = 0.8
	elif level <= 75:
		coefficient = 0.7
	else:
		coefficient = 0.6
	return int(base_cost * coefficient)


## 获取每日自然恢复量（按等级）
func get_daily_stamina_recovery(level: int) -> int:
	if level <= 10:
		return 5
	elif level <= 30:
		return 8
	elif level <= 50:
		return 10
	else:
		return 15


## 获取打游戏花费（按等级增加）
func get_playgame_cost(level: int) -> int:
	if level <= 10:
		return 50    # 新手便宜
	elif level <= 30:
		return 80    # 中期适中
	elif level <= 50:
		return 100   # 后期标准
	elif level <= 75:
		return 150   # 高级玩家买更好的游戏
	else:
		return 200   # 满级玩家买顶级游戏设备


## 属性增加值计算（支持等级参数）
func add_property(current_value: int, add_value: int, level: int = 1) -> int:
	var max_value = get_max_stamina(level)
	if current_value + add_value <= max_value:
		return add_value
	elif current_value <= max_value and current_value + add_value > max_value:
		return max_value - current_value
	return 0


func get_time_string(y, m, w, d, q) -> String:
	return "%d年%d月%d周%d天" % [y, m, w, d]


func format_date() -> String:
	return "%d-%d-%d-%d" % [TimerManager.current_year, TimerManager.current_month, TimerManager.current_week, TimerManager.current_day]


func calculate_new_game_time_difference(date1: String, date2: String, absolute: bool = true) -> int:
	var p1 = date1.split("-")
	var p2 = date2.split("-")
	
	var days1 = (int(p1[0]) - 1) * 336 + (int(p1[1]) - 1) * 28 + (int(p1[2]) - 1) * 7 + int(p1[3])
	var days2 = (int(p2[0]) - 1) * 336 + (int(p2[1]) - 1) * 28 + (int(p2[2]) - 1) * 7 + int(p2[3])
	
	if absolute:
		return abs(days2 - days1) + 1
	return days2 - days1 + 1


const SHORT_DECAY = 5
const MEDIUM_DECAY = 10
const LONG_DECAY = 21


func decrease_blog_views(views: int, old_day: String, now_day: String, cat_type: String) -> int:
	var days = calculate_new_game_time_difference(old_day, now_day)
	
	if days <= SHORT_DECAY and days > 0:
		return views
	elif days <= MEDIUM_DECAY:
		return int(views * 0.5)
	elif days <= LONG_DECAY:
		return int(views * 0.2)
	else:
		if "周刊" in cat_type:
			return randi_range(0, 5)
		return randi_range(0, 1)


func replace_task_value(arr: Array, old_task: String, new_task: String):
	for i in arr.size():
		if arr[i].has("tasks"):
			var tasks = arr[i]["tasks"]
			for j in tasks.size():
				if tasks[j] == old_task:
					tasks[j] = new_task


func decrease_value_safely(val: int, min_d: int, max_d: int) -> int:
	var dec = randi_range(min_d, max_d)
	var new_val = val - dec
	return clamp(new_val, 0, 100)


func find_category_index(list, name: String) -> int:
	for i in list.size():
		if list[i]["name"] == name:
			return i
	return -1


func calculate_post_views(base: int, post: Dictionary) -> int:
	var quality = float(post["quality"]) / 200.0
	var effect = pow(quality, 2.0) * 200.0
	var result = int(base * effect)
	if result < 1:
		result = 1
	return result


func calculate_final_views(base: int) -> int:
	var weight = clamp(float(base) / 5000.0, 0.0, 1.0)
	var share = lerp(0.01, 0.5, weight)
	var read = lerp(0.25, 0.75, weight)
	return int(base * share * read)


func update_rss(views: int) -> int:
	return views / 600


func rss_add(r: int, days: int) -> int:
	if days <= 3:
		return int(r * 0.1)
	elif days <= 7:
		return int(r * 0.05)
	return 0


func decrease_rss(r: int, rate: float = 0.1) -> int:
	if r > 10:
		return int(r - r * rate)
	return r


func update_favorites(views: int, quality: int) -> int:
	return int(views * quality * 0.1 / 1000)


func favorites_add(v: int, date: String) -> int:
	if calculate_new_game_time_difference(date, format_date()) >= 280:
		return 0
	
	if v < 100:
		return randi_range(0, 1)
	elif v < 500:
		return randi_range(1, 5)
	elif v < 1000:
		return randi_range(3, 8)
	else:
		return randi_range(5, v / 10)


func format_number(val: int) -> String:
	if val >= 100000000:
		return "%.1f亿" % [val / 100000000.0]
	elif val >= 10000:
		return "%.1f万" % [val / 10000.0]
	return str(val)


func get_rank_title(level: int, ranks: Array) -> String:
	"""根据等级获取段位名称
	- level 1-10 → 索引0（初入江湖）
	- level 11-20 → 索引1（崭露头角）
	- level 21-30 → 索引2（锋芒毕露）
	- ...
	- level 91-100 → 索引9（天外飞仙）
	"""
	if level < 1:
		return "无效等级"
	if level > 100:
		level = 100
	var index = (level - 1) / 10  # 关键：(level-1)/10 确保每10级一个段位
	if index >= ranks.size():
		index = ranks.size() - 1
	return ranks[index]


func goto_scene(path: String):
	var err = get_tree().change_scene_to_file(path)
	if err != OK:
		print("场景切换失败：", err)
	else:
		print("场景跳转成功：", path)
