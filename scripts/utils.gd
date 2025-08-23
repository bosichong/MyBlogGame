extends Node

# 工具类，存放一些工具方法

## 博客类型
var possible_categories: Array[Dictionary] = [
	{
		"name":"生活日记",
		"tip":"生活流水账，如果文学素养很高，写出的日记会很招人喜欢？",
		"type":"文学",
		"disabled":false,
		"pressed":false,
		"is_money":false,
		"money" : 0,
		"stamina":10,
	},

	{
		"name":"网站运维",
		"tip":"关于运营博客的一些心得，编程等级很高的人可以写出更多的精品运维技术文章。",
		"type":"技术",
		"disabled":false,
		"pressed":false,
		"money" : 0,
		"is_money":false,
		"stamina":10,
	},
	
	{
		"name":"编程教程",
		"tip":"完成学习编程1级后的时候解锁。",
		"type":"技术",
		"disabled":true,
		"pressed":false,
		"money" : 0,
		"is_money":false,
		"stamina":10,
	},
	{
		"name":"程序员周刊",
		"tip":"当技术达到一定程度后，编写技术周刊可以定期收获大量访问量。",
		"type":"技术",
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
		"type":"技术",
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
		"type":"技术",
		"disabled":true,
		"pressed":false,
		"money" : 0,
		"is_money":true,
		"stamina":50,
	},
		{
		"name":"散文随笔",
		"tip":"多多阅读可以解锁。",
		"type":"文学",
		"disabled":true,
		"pressed":false,
		"money" : 0,
		"is_money":false,
		"stamina":10,
	},
	{
		"name":"文学周刊",
		"tip":"高质量的文学周刊，令人眼前一亮！",
		"type":"文学",
		"disabled":true,
		"pressed":false,
		"money" : 0,
		"is_money":false,
		"stamina":50,
	},
	{
		"name":"爆款网文",
		"tip":"一针见血，直击热点内容！",
		"type":"文学",
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
		"type":"文学",
		"disabled":true,
		"pressed":false,
		"money" : 0,
		"is_money":true,
		"stamina":30,
	},
	{
		"name":"插画壁纸",
		"tip":"画画新手的练习日常，很受手欢迎？",
		"type":"艺术",
		"disabled":true,
		"pressed":false,
		"money" : 0,
		"is_money":false,
		"stamina":10,
	},
	{
		"name":"绘画基础教程",
		"tip":"完成素描色彩基础后可以编写些适合新手的程。",
		"type":"艺术",
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
		"type":"艺术",
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
		"type":"艺术",
		"disabled":true,
		"pressed":false,
		"money" : 0,
		"is_money":true,
		"stamina":50,
	},
	{
		"name":"年度总结",
		"tip":"又一年即将过去了，这一年你都做了些什么？貌似博客站长们都喜欢在年底做个总结，
		而且大家都热衷于告诉别人和了解别人这一年都做了啥？
		每年的年底年初可以发表一次该博文。",
		"type":"文学",
		"disabled":true,
		"pressed":false,
		"money" : 0,
		"is_money":false,
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
		"money" : 10,
		"stamina":10,
	},
	{
		"name":"页面美化",
		"tip":"需要绘画等级1后解锁，
		漂亮的页面会增加访问量。",
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
		"stamina":30,
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

var blog_post_events = [
	{
		"name":"年度总结",
		"times":1,#事件次数
		"post_times":1,#年度总结发布次数。
		#事件启用结束时间，
		"event_date":{
			"y":[0],
			"m":[12,1],
			"w":[0],
			"d":[0]
		},
		"views_add":1.0,# 访问量增加百分比。
	},
	{
		"name":"热点风向",
		"times":1,#事件次数
		"type":"文学",#当前热门博客文章风向种类,默认文学
		"add":0.1,
		#事件启用结束时间，
		"event_date":{
			"y":[0],
			"m":[1,6],
			"w":[2],
			"d":[1]
		},
		"views_add":1.0,# 访问量增加百分比。
	},
]

var bc_type = ["文学","技术","艺术"]

## 返回文章质量，生活日记只需要写作能力，其他的要写作能力/2+专业能力/2
func get_quality(category:String) -> int:
	if category == "年度总结" or category == "生活日记" or category == "爆款网文" or category == "散文随笔" or category == "文学周刊" or category == "小说连载(收费)":
		return int(Blogger.writing_ability + Blogger.literature_ability)
	elif category == "网站运维" :
		return int(Blogger.writing_ability*0.5 + Blogger.technical_ability*0.5 + Blogger.code_ability*0.5 + Blogger.literature_ability *0.5)
	elif  category == "编程教程" or category == "付费编程教程" or category == "程序员周刊" or category == "付费黑客攻防":
		return int(Blogger.writing_ability*0.5 + Blogger.code_ability + Blogger.literature_ability *0.5)
	elif  category == "插画壁纸" or category == "绘画基础教程" or category == "艺术周刊" or category == "动漫连载(收费)":
		return int(Blogger.writing_ability*0.5 + Blogger.drawing_ability + Blogger.literature_ability *0.5)
	else:
		return 0


## 生成一个简单的随机标题
func generate_random_title(category: String) -> String:
	
	#如果不是周刊
	if not contains_weekly_shorter(category):
		var prefixes: Array[String] = [
		"探索", "分享", "我的", "关于", "如何",
		"学习", "体验", "发现", "讨论", "实践",
		"解读", "揭秘", "轻松", "深入", "快速",
		"全面", "实用", "精彩", "独特", "最新"
		]
		var topics: Dictionary = {
			"年度总结": [
		"年度成长回顾", "一年的收获与遗憾", "年度目标复盘",
		"这一年的生活点滴", "年度精彩瞬间", "年度工作成果总结",
		"年度情感历程", "年度旅行足迹", "年度学习心得", "年度生活感悟",
		"个人成长轨迹", "年度阅读报告", "家庭大事记", "健康计划回顾",
		"财务状况盘点", "人际关系梳理", "梦想实现进度", "技能提升清单",
		"兴趣探索之旅", "挑战尝试记录", "年度关键词", "时光印记",
		"得与失的思考", "高光时刻", "低谷与突破", "转折点",
		"改变与坚持", "放弃与选择", "遇见与告别", "开始与结束",
		"投入与回报", "时间分配分析", "精力管理心得", "习惯养成记录",
		"失败教训总结", "成功经验分享", "意外之喜", "计划外收获",
		"最难忘的体验", "最深刻的教训", "最大的进步", "最小的进步",
		"最想感谢的人", "最想弥补的事", "最自豪的成就", "最遗憾的错过",
		"心态的演变", "价值观的巩固", "世界观的拓展", "自我认知的深化",
		"年度感恩清单", "来年期许与展望"
	],
			"生活日记": [
		"每日心得", "家庭时光", "工作随想", "平凡的一天",
		"心情笔记", "微小幸福", "日常琐记", "成长点滴",
		"周末记事", "生活碎片",
		"清晨的宁静", "深夜的思绪", "通勤路上见闻", "午休小憩",
		"购物清单与收获", "厨房实验记", "阳台上的绿植", "窗外的风景",
		"与宠物的日常", "老友的电话", "意外的小惊喜", "计划外的散步",
		"旧物整理记", "照片背后的故事", "天气与心情", "季节的变换",
		"一顿难忘的晚餐", "失眠的夜晚", "早起的鸟儿", "晚归的疲惫",
		"独处的时光", "热闹的聚会", "安静的阅读时刻", "忙碌的早晨",
		"拖延的烦恼", "完成的成就感", "目标与计划", "迷茫与思考",
		"简单的快乐", "复杂的感受", "回忆涌上心头", "未来的憧憬",
		"身体的小信号", "健康小目标", "运动后的畅快", "久坐的不适",
		"省钱小妙招", "冲动消费的反思", "意外的发现", "熟悉的路线",
		"陌生人的善意", "城市的呼吸", "自然的馈赠", "内心的对话",
		"时间都去哪儿了", "今日小确幸", "此刻的心情", "生活的节奏",
		"偶然的灵感", "重复中的不同", "期待与失落", "平静与波澜"
	],
			"网站运维": [
		"HTML/CSS技巧", "SEO优化实战", "网站安全防护", "用户体验优化",
		"服务器配置管理", "前端性能调优", "内容管理策略", "实用插件推荐",
		"流量分析解读", "响应式设计实践",
		"CDN加速原理", "数据库备份与恢复", "负载均衡配置", "DNS解析详解",
		"SSL证书部署", "防火墙规则设置", "日志分析技巧", "监控告警配置",
		"网站可用性保障", "故障排查指南", "缓存策略应用", "资源压缩方法",
		"图片优化方案", "代码分割实践", "构建流程自动化", "部署脚本编写",
		"版本管理规范", "环境隔离策略", "灰度发布流程", "回滚机制设计",
		"API接口管理", "第三方服务集成", "表单安全防护", "防爬虫策略",
		"反垃圾邮件技巧", "用户数据保护", "GDPR合规要点", "移动端适配",
		"跨浏览器兼容", "无障碍访问实现", "网站速度测试", "性能瓶颈定位",
		"成本优化方案", "云服务选型", "容器化部署入门", "微服务架构运维",
		"自动化测试集成", "安全漏洞扫描", "渗透测试基础", "应急响应预案",
		"知识库搭建", "团队协作流程"
	],
			"编程教程": [
		"Python入门指南", "Web开发入门", "算法学习路径", "游戏开发起步",
		"JavaScript基础精讲", "数据库操作详解", "版本控制实战", "项目实战演练",
		"API设计与调用", "调试技巧大全",
		"Java快速上手", "C++核心概念", "Go语言初探", "Rust编程基础",
		"TypeScript入门", "Vue.js框架学习", "React开发实战", "Angular基础",
		"Node.js后端开发", "Django快速开发", "Flask入门", "Spring Boot应用",
		"数据结构详解", "排序算法实现", "搜索算法解析", "动态规划入门",
		"递归与分治", "面向对象编程", "函数式编程思想", "设计模式应用",
		"单元测试编写", "集成测试实践", "TDD开发流程", "BDD行为驱动",
		"Linux命令行", "Shell脚本编写", "正则表达式应用", "JSON处理技巧",
		"XML解析方法", "RESTful API构建", "GraphQL入门", "微服务架构基础",
		"Docker容器入门", "Kubernetes基础", "CI/CD流水线搭建", "云开发平台",
		"移动端开发", "前端构建工具", "代码质量提升", "性能优化技巧"
	],
			"付费编程教程": [
		"全栈开发实战项目", "Python自动化脚本开发", "React前端进阶", 
		"Docker与容器化部署实战","机器学习实战应用", "Node.js高并发服务", "数据库性能调优",
		"TypeScript高级应用","微服务架构实战", "CI/CD流程深度构建",
		"Go语言高性能服务", "Rust系统编程", "Kubernetes集群管理", 
		"云原生架构设计", "Serverless开发实战", "大数据处理Pipeline",
		"实时数据流处理", "分布式系统设计", "高可用架构实现", "容错与灾备方案",
		"GraphQL API设计", "WebSocket实时通信", "PWA渐进式应用", 
		"Electron跨平台桌面应用", "Flutter跨平台移动开发", "React Native性能优化",
		"Vue 3 Composition API", "Svelte框架实战", "前端状态管理深入", 
		"前端微前端架构", "后端API网关", "服务网格Istio", "消息队列应用",
		"缓存策略与高并发", "搜索引擎集成", "推荐系统入门", "计算机视觉实战",
		"自然语言处理应用", "区块链开发基础", "智能合约编写", "Web3应用开发",
		"密码学应用开发", "安全编码实践", "渗透测试开发", "自动化测试框架",
		"性能压测与分析", "可观测性系统", "监控告警平台", "日志分析平台"
	],
			"付费黑客攻防": [
		"Web渗透测试实战", "逆向工程入门与实践", "漏洞挖掘高级技巧", 
		"社会工程学攻击案例分析","内网横向渗透技术", "加密解密技术详解", 
		"CTF竞赛策略与技巧", "系统安全加固指南", "APT攻击防御策略", 
		"红队攻防演练实录",
		"网络侦查与情报收集", "高级持续威胁(APT)分析", "恶意软件分析与对抗", 
		"二进制漏洞利用", "移动应用安全评估", "无线网络安全攻防", 
		"物联网设备安全检测", "区块链安全审计", "云服务安全漏洞解析", 
		"基于AI的安全防护机制", "隐私保护与数据泄露预防", "企业级防火墙配置", 
		"DDoS攻击防御方案", "身份验证绕过技术", "权限提升技巧", 
		"文件包含漏洞利用", "SQL注入高级技术", "XSS跨站脚本攻击防御", 
		"CSRF跨站请求伪造防护", "端口扫描与服务识别", "蜜罐技术及其部署", 
		"网络协议逆向工程", "反病毒引擎规避方法", "Rootkit技术剖析", 
		"内存溢出攻击与防护", "沙箱逃逸技术", "威胁情报共享平台构建", 
		"应急响应流程设计", "数字取证与犯罪追踪", "安全编码最佳实践", 
		"Web应用防火墙(WAF)配置", "零信任架构实施", "供应链攻击防范", 
		"硬件安全模块(HSM)使用", "量子加密基础", "社交网络信息收集", 
		"暗网活动监测", "网络钓鱼攻击模拟", "电子邮件安全增强", 
		"即时通讯工具安全评估", "虚拟化环境下的安全挑战", "智能合约安全性审查"
	],
			"散文随笔": [
		"自然感悟", "心灵鸡汤", "城市故事", "旅行随感",
		"童年回忆", "人生哲理", "四季变换", "夜晚思绪",
		"阅读笔记", "人间烟火",
		"雨中的静思", "山间的心跳", "海边的沉思", "森林的低语",
		"清晨的第一缕阳光", "午夜的秘密花园", "春日花开时的遐想",
		"夏日微风里的清凉", "秋叶飘落的记忆", "冬雪覆盖下的温暖",
		"老街巷尾的时光", "故乡的味道", "远方的呼唤", "孤独的美好",
		"与书为伴的日子", "梦想启航的地方", "那些年的青春岁月",
		"生活中的小确幸", "不期而遇的惊喜", "生命中不可承受之轻",
		"漫步在历史长河中", "城市的脉搏", "乡间的晨曦", "夜空中最亮的星",
		"咖啡馆里的午后", "火车上的风景", "家的意义", "亲情的力量",
		"友情的温度", "爱情的模样", "失落与寻找", "遗忘的角落",
		"时间的脚步声", "季节的礼赞", "生命的轮回", "内心的对话",
		"自我发现之旅", "平凡之路", "追求梦想的勇气", "面对未知的恐惧",
		"希望的灯塔", "失落的世界", "重拾旧时光", "给未来的信",
		"记忆的碎片", "心中的岛屿", "灵魂的归宿", "寻找宁静之地",
		"在路上的感受", "文字的力量", "音乐中的世界", "艺术的灵魂"
	],
			"爆款网文": [
		"都市异能觉醒", "玄幻修真之路", "穿越重生逆袭", 
		"系统流爽文", "恋爱甜宠日常", "末世生存挑战", "悬疑推理谜案", 
		"反套路爽文", "高武世界争霸", "校园热血青春",
		"废柴逆袭记", "天才崛起录", "神豪从零开始", "首富养成计划",
		"超级兵王归来", "隐世高手下山", "最强赘婿翻身", "医武圣手",
		"全能艺术家", "科技霸主崛起", "文娱教父", "末世种田流",
		"无限流游戏", "规则类怪谈", "惊悚直播间", "诡异复苏",
		"灵气复苏时代", "全民御兽世界", "机甲战神", "赛博朋克未来",
		"星际争霸", "宇宙探险家", "快穿之任务达人", "穿书之改变命运",
		"女强逆袭", "萌宝助攻", "总裁的掌心娇", "先婚后爱",
		"马甲文：马甲无数", "团宠文：全员宠爱", "钓系美人", "黑莲花女主",
		"疯批反派拯救计划", "病娇男主", "替身觉醒", "白月光归来",
		"娱乐圈风云", "直播带货之神", "美食文：舌尖诱惑", "风水师传奇",
		"盗墓笔记新篇", "神医下山", "兵王护花", "全能学霸"
	],
			"小说连载(收费)": [
		"科幻史诗：星河远征", "悬疑解谜：迷雾之城", "浪漫爱情：时光之约", "历史传奇：王朝兴衰",
		"都市异能：暗影行者", "青春校园：追光者", "末日生存：方舟计划", "穿越时空：命运之轮",
		"奇幻冒险：龙裔传说", "热血战斗：武道巅峰",
		"权谋天下：帝王业", "谍战风云：无声战场", "异能特工：守夜人", "废土求生：新纪元",
		"星际帝国：银河争霸", "修真界：问道长生", "末世进化：觉醒者", "灵气复苏：守护者",
		"平行世界：交错时空", "未来都市：代码人生",
		"家族秘辛：血脉传承", "古老遗迹：失落文明", "神话再临：众神归位", "机械纪元：觉醒纪元",
		"赛博都市：霓虹之下", "深空探索：孤航者", "虫族入侵：人类反击", "基因改造：新人类",
		"学院流：魔法与剑", "王朝争霸：铁血山河", "江湖恩怨：快意恩仇", "仙侠世界：问道苍穹",
		"末世异兽：生存法则", "时间循环：无限七日", "空间折叠：异界行者", "梦境编织者",
		"记忆碎片：寻找真相", "灵魂摆渡：幽冥引路", "契约者：与魔共舞", "天选之子：救世之旅",
		"失落科技：重启文明", "海洋深处：亚特兰蒂斯", "天空之城：浮空秘境", "地下世界：地心之谜",
		"虚拟现实：第二人生", "数据生命：意识上传", "克苏鲁降临：旧日支配者", "蒸汽朋克：齿轮之心"
	],
			"插画壁纸": [
		"自然风光：山川湖海", "梦幻星空：银河与极光", "动物世界：萌宠与猛兽", 
		"建筑艺术：古今中外", "极简主义：留白与几何", "复古风情：胶片与怀旧",
		"未来科技：赛博与机械", "动漫角色：经典与原创", "节日庆典：喜庆氛围", 
		"手绘涂鸦：自由笔触",
		"四季之景：春樱夏荷", "城市剪影：天际线", "静物写意：花瓶与书本",
		"幻想生物：龙与精灵", "抽象艺术：色彩与形态", "水彩晕染：柔和意境",
		"像素艺术：复古游戏风", "扁平插画：清新可爱", "国风元素：水墨丹青",
		"洛可可风格：华丽繁复", "蒸汽朋克：齿轮与雾都", "低多边形：简约立体",
		"故障艺术：Glitch效果", "霓虹光影：都市夜景", "星空宇宙：深空探索",
		"海底世界：珊瑚与鱼群", "森林秘境：晨雾与古树", "沙漠绿洲：孤寂与希望",
		"极地风光：冰雪与极光", "田园牧歌：麦田与风车", "雨天氛围：窗边雨滴",
		"雪景静谧：落雪与灯火", "秋日私语：落叶与长椅", "夏日海滩：阳光与浪花",
		"春日花园：繁花与蝴蝶", "童话小屋：蘑菇与烟囱", "神话场景：神祇与战场",
		"科幻都市：空中楼阁", "未来载具：飞船与机甲", "概念设计：奇思妙想",
		"人物肖像：侧脸与背影", "情侣剪影：浪漫时刻", "宠物日常：睡姿与玩耍",
		"美食诱惑：甜点与咖啡", "饮品特写：气泡与冰块", "植物图鉴：多肉与蕨类",
		"花卉集锦：玫瑰与向日葵", "星空露营：帐篷与篝火", "热气球之旅：漂浮云端",
		"图书馆一角：书架与台灯", "咖啡馆时光：拿铁与窗景", "游戏场景：奇幻地图",
		"电影海报：经典重现"
	],
			"绘画基础教程": [
		"色彩理论", "素描基础", "构图技巧", "光影效果",
		"线条练习", "比例结构", "透视原理", "材质表现",
		"动态姿势", "工具使用",
		"色彩混合实践", "色调与氛围营造", "对比度调整", "色相环应用",
		"单色素描技巧", "明暗对比练习", "阴影绘制", "质感表达",
		"人体解剖学基础", "面部特征描绘", "手部细节处理", "脚部绘画技巧",
		"衣物褶皱表现", "头发绘制技法", "背景设计原则", "前景与中景布局",
		"一点透视画法", "两点透视详解", "三点透视入门", "曲线透视应用",
		"速写练习方法", "快速捕捉形态", "自然元素绘制", "植物绘画技巧",
		"动物姿态描绘", "风景构图要点", "城市景观绘制", "建筑草图技法",
		"使用参考资料", "创意灵感激发", "艺术风格探索", "个人项目规划",
		"每日绘画习惯", "持续学习策略", "社区交流参与", "接受批评与反馈",
		"自我评估技巧", "长期目标设定", "短期技能提升", "跨媒介尝试",
		"数字绘画入门", "传统与现代结合", "水彩画技法", "油画颜料特性",
		"丙烯酸涂料运用", "实验性材料探索", "作品展示准备", "在线平台发布",
		"实体展览策划", "艺术市场了解"
	],
			"动漫连载(收费)": [
		"青春校园", "奇幻冒险", "热血战斗", "温馨日常",
		"机甲战争", "魔法世界", "恋爱喜剧", "悬疑推理",
		"异世界穿越", "职场奋斗",
		"科幻未来", "历史传奇", "竞技体育", "音乐梦想",
		"美食之旅", "末日求生", "超能力战斗", "侦探故事",
		"心理惊悚", "家族故事", 
		"虚拟现实游戏", "神话传说改编", "治愈系生活", "都市怪谈",
		"动物伙伴冒险", "校园恐怖", "时空旅行", "英雄崛起",
		"海盗探险", "古代文明探索", "间谍行动", "超级英雄",
		"怪物猎人", "忍者传说", "神秘事件调查", "太空探索",
		"西部开拓", "生存挑战", "复仇之路", "心灵成长",
		"艺术创作", "科技革新", "灾难应对", "友情考验",
		"寻宝冒险", "未来城市", "军事战略", "幻想文学改编",
		"传统文化体验", "环境保育", "社会问题探讨", "梦境探险"
	]
		}
		var prefix: String = prefixes[randi() % prefixes.size()]
		var topic: String = topics.get(category, ["未知主题"])[randi() % topics.get(category, ["未知主题"]).size()]
		if category == "年度总结":
			var tit = ""
			if TimerManager.current_month == 12:
				tit = prefix + str(TimerManager.current_year) + "年" + topic
			else :
				tit = prefix + str(TimerManager.current_year-1) + "年" + topic
			print(tit)
			return tit
		else:
			print(prefix + " " + topic)
			return prefix + " " + topic
	else :
		var blog_date = Utils.format_date()
		print(category + " " + blog_date)
		return category + " " + blog_date







		
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
	
	

## 检查字符串是否存在于数组中的方法,这里主要是检查是否存在当前任务
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



## 是否为周刊
func contains_weekly_shorter(p_string: String) -> bool:
	return p_string.find("周刊") != -1


	
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



## 格式化日期为 "YYYY-M-D" 字符串
func format_date() -> String:
	return str(TimerManager.current_year) + "-" + str(TimerManager.current_month) + "-" + str(TimerManager.current_week) + "-" + str(TimerManager.current_day)


##计算两个新的游戏日期字符串之间的天数差，格式为 "YYYY-M-W-D"。
#
#参数:
	#date_str1: 第一个日期字符串，格式为 "YYYY-M-W-D"。
	#date_str2: 第二个日期字符串，格式为 "YYYY-M-W-D"。
#
#返回值:两个日期之间的天数差（整数）。
func calculate_new_game_time_difference(date_str1: String, date_str2: String) -> int:


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


## 文章rss订阅增加,
func update_rss(views):
	var rss = int(views / 600)
	#print(Utils.format_date() + ":" + str(rss))
	return rss
## 根据博客rss订阅量，返回新发布文章的追加问量	
#r 当前博客的rss订阅量，b 文章发布日期与当前日期的间隔时间
func rss_add(r,b):
	var end = 0
	if b <= 3:
		end = int(r*0.1)
	elif b>3 and b<=7 :
		end = int(r*0.05)
	else :
		end = 0
	#print(Utils.format_date(),"+",end,"+",r,"+",b)
	return end
## rss订阅量的递减
func decrease_rss(r,b=0.2):
	var rss = r
	# 如果rss订阅量小于10 则保留10
	if r > 10 :
		rss = int(r-r*b)
	#print(Utils.format_date(),":",rss)
	return rss
	
	
## 单篇文章的收藏数量增加
func update_favorites(views,quality):
	var f = int(views*quality*0.1 / 300)
	#print(Utils.format_date() + ":" + str(f))
	return f

# 根据文章收藏量 v，返回每日增加的问量（随机值）
func favorites_add(v: int,d) -> int:
	var nd = format_date()
	if calculate_new_game_time_difference(d,nd) < 280 :
		if v > 1 and v < 100:
			# 区间 (0, 500)：随机返回 1
			return  randi_range(0, 1)
		
		elif v >= 100 and v < 500:
			# 区间 [500, 1000)：随机返回 1 到 5
			return randi_range(1, 5)
		
		elif v >= 500 and v < 1000:
			# 区间 [1000, 3000)：随机返回 5 到 10
			return randi_range(3, 8)
		
		elif v >= 1000:
			# v >= 3000：随机返回 10 到 30
			return randi_range(5, int(v/10))
		
		else:
			# v <= 0 的情况，返回 0 或根据需要处理
			return 0
	else:
		return 0
## 格式化访问量
func format_number(value: int) -> String:
	var formatted: String
	if value >= 100000000:  # 大于等于1亿
		var 亿_units = value / 100000000.0
		formatted = "%.1f亿" % 亿_units
	elif value >= 10000:  # 大于等于1万
		var 万_units = value / 10000.0
		formatted = "%.1f万" % 万_units
	else:
		formatted = str(value)  # 小于1万，直接显示原数字
	return formatted
