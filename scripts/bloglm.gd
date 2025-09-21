extends Node

var lm_0 = false # 是否注册成功
var jhph = []
var jhph_js = []
var jhph_wx = []
var jhph_ys = []
var jhph_jz = []

var is_join = false #是否加入联盟

## 捐赠据
var donate_data = []
var donate_max = 100
var donate_min = 50

#固定捐赠ID
var donate_ids = [1,2,3,4]

## 联盟成员列表
var lm_list = [
  {
    "id": 1,
    "blog_name": "星光博客",
    "blog_author": "星语者",
    "lv": 50,
    "type": 1,
    "quality": 50
  },
  {
    "id": 2,
    "blog_name": "极客笔记",
    "blog_author": "GeekPanda",
    "lv": 49,
    "type": 3,
    "quality": 48
  },
  {
    "id": 3,
    "blog_name": "墨染书斋",
    "blog_author": "墨染",
    "lv": 48,
    "type": 2,
    "quality": 46
  },
  {
    "id": 4,
    "blog_name": "视觉艺术",
    "blog_author": "VisionArt",
    "lv": 47,
    "type": 4,
    "quality": 44
  },
  {
    "id": 5,
    "blog_name": "星辰大海",
    "blog_author": "懒懒",
    "lv": 43,
    "type": 1,
    "quality": 42
  },
  {
    "id": 6,
    "blog_name": "万象集",
    "blog_author": "老万",
    "lv": 43,
    "type": 1,
    "quality": 44
  },
  {
    "id": 7,
    "blog_name": "浮生志",
    "blog_author": "阿浮",
    "lv": 40,
    "type": 1,
    "quality": 41
  },
  {
    "id": 8,
    "blog_name": "跨界笔记",
    "blog_author": "CrossMind",
    "lv": 33,
    "type": 1,
    "quality": 33
  },
  {
    "id": 9,
    "blog_name": "知行录",
    "blog_author": "知行君",
    "lv": 42,
    "type": 1,
    "quality": 40
  },
  {
    "id": 10,
    "blog_name": "灵感盒子",
    "blog_author": "IdeaCat",
    "lv": 42,
    "type": 1,
    "quality": 45
  },
  {
    "id": 11,
    "blog_name": "拾光集",
    "blog_author": "拾光人",
    "lv": 44,
    "type": 1,
    "quality": 42
  },
  {
    "id": 12,
    "blog_name": "无界笔记",
    "blog_author": "NoBound",
    "lv": 38,
    "type": 1,
    "quality": 44
  },
  {
    "id": 13,
    "blog_name": "思与行",
    "blog_author": "ThinkDo",
    "lv": 41,
    "type": 1,
    "quality": 41
  },
  {
    "id": 14,
    "blog_name": "诗与远方",
    "blog_author": "远行人",
    "lv": 28,
    "type": 2,
    "quality": 33
  },
  {
    "id": 15,
    "blog_name": "纸上烟云",
    "blog_author": "文心雕龙",
    "lv": 39,
    "type": 2,
    "quality": 36
  },
  {
    "id": 16,
    "blog_name": "字里行间",
    "blog_author": "字游者",
    "lv": 18,
    "type": 2,
    "quality": 25
  },
  {
    "id": 17,
    "blog_name": "南风诗话",
    "blog_author": "南风子",
    "lv": 32,
    "type": 2,
    "quality": 30
  },
  {
    "id": 18,
    "blog_name": "浮生笔录",
    "blog_author": "浮生一梦",
    "lv": 22,
    "type": 2,
    "quality": 27
  },
  {
    "id": 19,
    "blog_name": "旧纸堆",
    "blog_author": "藏书人",
    "lv": 26,
    "type": 2,
    "quality": 29
  },
  {
    "id": 20,
    "blog_name": "诗酒趁年华",
    "blog_author": "醉墨",
    "lv": 44,
    "type": 2,
    "quality": 35
  },
  {
    "id": 21,
    "blog_name": "纸上江湖",
    "blog_author": "笔侠客",
    "lv": 15,
    "type": 2,
    "quality": 20
  },
  {
    "id": 22,
    "blog_name": "词海拾贝",
    "blog_author": "词匠",
    "lv": 30,
    "type": 2,
    "quality": 31
  },
  {
    "id": 23,
    "blog_name": "CodeLab",
    "blog_author": "DevZero",
    "lv": 38,
    "type": 3,
    "quality": 37
  },
  {
    "id": 24,
    "blog_name": "算法之路",
    "blog_author": "AlgoMaster",
    "lv": 40,
    "type": 3,
    "quality": 39
  },
  {
    "id": 25,
    "blog_name": "前端小站",
    "blog_author": "FrontEndCat",
    "lv": 20,
    "type": 3,
    "quality": 24
  },
  {
    "id": 26,
    "blog_name": "码上人生",
    "blog_author": "CoderLife",
    "lv": 33,
    "type": 3,
    "quality": 32
  },
  {
    "id": 27,
    "blog_name": "Python实验室",
    "blog_author": "PyLover",
    "lv": 27,
    "type": 3,
    "quality": 26
  },
  {
    "id": 28,
    "blog_name": "架构师手记",
    "blog_author": "ArchitectX",
    "lv": 36,
    "type": 3,
    "quality": 38
  },
  {
    "id": 29,
    "blog_name": "Bug终结者",
    "blog_author": "DebugHero",
    "lv": 19,
    "type": 3,
    "quality": 22
  },
  {
    "id": 30,
    "blog_name": "云上代码",
    "blog_author": "CloudCoder",
    "lv": 31,
    "type": 3,
    "quality": 30
  },
  {
    "id": 31,
    "blog_name": "数据之眼",
    "blog_author": "DataEye",
    "lv": 29,
    "type": 3,
    "quality": 27
  },
  {
    "id": 32,
    "blog_name": "光影画坊",
    "blog_author": "光影",
    "lv": 34,
    "type": 4,
    "quality": 35
  },
  {
    "id": 33,
    "blog_name": "色彩日记",
    "blog_author": "Colorist",
    "lv": 23,
    "type": 4,
    "quality": 26
  },
  {
    "id": 34,
    "blog_name": "素描本",
    "blog_author": "SketchBoy",
    "lv": 17,
    "type": 4,
    "quality": 19
  },
  {
    "id": 35,
    "blog_name": "音符之间",
    "blog_author": "Melody",
    "lv": 30,
    "type": 4,
    "quality": 33
  },
  {
    "id": 36,
    "blog_name": "舞动时光",
    "blog_author": "DanceWave",
    "lv": 21,
    "type": 4,
    "quality": 24
  },
  {
    "id": 37,
    "blog_name": "镜头背后",
    "blog_author": "LensMaster",
    "lv": 37,
    "type": 4,
    "quality": 36
  },
  {
    "id": 38,
    "blog_name": "设计狂想",
    "blog_author": "DesignDream",
    "lv": 28,
    "type": 4,
    "quality": 31
  },
  {
    "id": 39,
    "blog_name": "手作时光",
    "blog_author": "CraftyMe",
    "lv": 16,
    "type": 4,
    "quality": 18
  },
  {
    "id": 40,
    "blog_name": "水墨丹青",
    "blog_author": "墨客",
    "lv": 32,
    "type": 4,
    "quality": 34
  },
  {
    "id": 41,
    "blog_name": "音律之森",
    "blog_author": "Aria",
    "lv": 24,
    "type": 4,
    "quality": 25
  },
  {
    "id": 42,
    "blog_name": "梦的碎片",
    "blog_author": "Dreamer",
    "lv": 14,
    "type": 2,
    "quality": 16
  },
  {
    "id": 43,
    "blog_name": "散文角落",
    "blog_author": "闲笔",
    "lv": 19,
    "type": 2,
    "quality": 21
  },
  {
    "id": 44,
    "blog_name": "小说工坊",
    "blog_author": "StoryWeaver",
    "lv": 35,
    "type": 2,
    "quality": 33
  },
  {
    "id": 45,
    "blog_name": "古韵新声",
    "blog_author": "吟风",
    "lv": 27,
    "type": 2,
    "quality": 30
  },
  {
    "id": 46,
    "blog_name": "夜读笔记",
    "blog_author": "夜行人",
    "lv": 22,
    "type": 2,
    "quality": 23
  },
  {
    "id": 47,
    "blog_name": "代码艺术",
    "blog_author": "ArtOfCode",
    "lv": 39,
    "type": 3,
    "quality": 37
  },
  {
    "id": 48,
    "blog_name": "AI前线",
    "blog_author": "Neuron",
    "lv": 38,
    "type": 3,
    "quality": 39
  },
  {
    "id": 49,
    "blog_name": "Linux小屋",
    "blog_author": "TuxFan",
    "lv": 26,
    "type": 3,
    "quality": 25
  },
  {
    "id": 50,
    "blog_name": "移动开发日志",
    "blog_author": "AppDev",
    "lv": 31,
    "type": 3,
    "quality": 30
  },
  {
    "id": 51,
    "blog_name": "安全边界",
    "blog_author": "Firewall",
    "lv": 33,
    "type": 3,
    "quality": 34
  },
  {
    "id": 52,
    "blog_name": "摄影日记",
    "blog_author": "Shutterbug",
    "lv": 29,
    "type": 4,
    "quality": 32
  },
  {
    "id": 53,
    "blog_name": "插画星球",
    "blog_author": "Illustra",
    "lv": 20,
    "type": 4,
    "quality": 22
  },
  {
    "id": 54,
    "blog_name": "陶艺手记",
    "blog_author": "ClayArt",
    "lv": 18,
    "type": 4,
    "quality": 20
  },
  {
    "id": 55,
    "blog_name": "舞者笔记",
    "blog_author": "Salsa",
    "lv": 25,
    "type": 4,
    "quality": 27
  },
  {
    "id": 56,
    "blog_name": "油画时光",
    "blog_author": "OilPainter",
    "lv": 36,
    "type": 4,
    "quality": 35
  },
  {
    "id": 57,
    "blog_name": "哲思小语",
    "blog_author": "思者无疆",
    "lv": 12,
    "type": 2,
    "quality": 15
  },
  {
    "id": 58,
    "blog_name": "随笔集",
    "blog_author": "随风",
    "lv": 11,
    "type": 2,
    "quality": 14
  },
  {
    "id": 59,
    "blog_name": "文学驿站",
    "blog_author": "文驿",
    "lv": 34,
    "type": 2,
    "quality": 31
  },
  {
    "id": 60,
    "blog_name": "诗与咖啡",
    "blog_author": "PoetCoffee",
    "lv": 28,
    "type": 2,
    "quality": 29
  },
  {
    "id": 61,
    "blog_name": "码农日常",
    "blog_author": "CodeFarmer",
    "lv": 37,
    "type": 3,
    "quality": 36
  },
  {
    "id": 62,
    "blog_name": "React小站",
    "blog_author": "ReactKid",
    "lv": 24,
    "type": 3,
    "quality": 26
  },
  {
    "id": 63,
    "blog_name": "Go语言笔记",
    "blog_author": "Gopher",
    "lv": 30,
    "type": 3,
    "quality": 33
  },
  {
    "id": 64,
    "blog_name": "数据库手札",
    "blog_author": "DBA_X",
    "lv": 27,
    "type": 3,
    "quality": 28
  },
  {
    "id": 65,
    "blog_name": "Web3探索",
    "blog_author": "CryptoCat",
    "lv": 32,
    "type": 3,
    "quality": 31
  },
  {
    "id": 66,
    "blog_name": "数字绘画",
    "blog_author": "PixelArt",
    "lv": 26,
    "type": 4,
    "quality": 29
  },
  {
    "id": 67,
    "blog_name": "雕塑笔记",
    "blog_author": "StoneCarver",
    "lv": 19,
    "type": 4,
    "quality": 21
  },
  {
    "id": 68,
    "blog_name": "音乐盒子",
    "blog_author": "MusicBox",
    "lv": 23,
    "type": 4,
    "quality": 24
  },
  {
    "id": 69,
    "blog_name": "动漫手绘",
    "blog_author": "AnimeDraw",
    "lv": 31,
    "type": 4,
    "quality": 33
  },
  {
    "id": 70,
    "blog_name": "创意工坊",
    "blog_author": "CreativeMind",
    "lv": 35,
    "type": 4,
    "quality": 34
  },
  {
    "id": 71,
    "blog_name": "小说夜话",
    "blog_author": "夜话人",
    "lv": 13,
    "type": 2,
    "quality": 17
  },
  {
    "id": 72,
    "blog_name": "散文诗",
    "blog_author": "诗影",
    "lv": 10,
    "type": 2,
    "quality": 12
  },
  {
    "id": 73,
    "blog_name": "科幻笔记",
    "blog_author": "SciFiFan",
    "lv": 29,
    "type": 2,
    "quality": 30
  },
  {
    "id": 74,
    "blog_name": "读书拾遗",
    "blog_author": "书虫",
    "lv": 21,
    "type": 2,
    "quality": 23
  },
  {
    "id": 75,
    "blog_name": "Java之道",
    "blog_author": "JavaKnight",
    "lv": 38,
    "type": 3,
    "quality": 37
  },
  {
    "id": 76,
    "blog_name": "Node小屋",
    "blog_author": "NodeNinja",
    "lv": 22,
    "type": 3,
    "quality": 25
  },
  {
    "id": 77,
    "blog_name": "DevOps笔记",
    "blog_author": "OpsMaster",
    "lv": 33,
    "type": 3,
    "quality": 32
  },
  {
    "id": 78,
    "blog_name": "机器学习笔记",
    "blog_author": "ML_Explorer",
    "lv": 39,
    "type": 3,
    "quality": 38
  },
  {
    "id": 79,
    "blog_name": "嵌入式小站",
    "blog_author": "EmbeddedDev",
    "lv": 28,
    "type": 3,
    "quality": 27
  },
  {
    "id": 80,
    "blog_name": "现代舞笔记",
    "blog_author": "ModernDancer",
    "lv": 20,
    "type": 4,
    "quality": 23
  },
  {
    "id": 81,
    "blog_name": "水彩时光",
    "blog_author": "Watercolor",
    "lv": 17,
    "type": 4,
    "quality": 19
  },
  {
    "id": 82,
    "blog_name": "街头涂鸦",
    "blog_author": "GraffitiKing",
    "lv": 25,
    "type": 4,
    "quality": 26
  },
  {
    "id": 83,
    "blog_name": "古典音乐录",
    "blog_author": "Maestro",
    "lv": 36,
    "type": 4,
    "quality": 35
  },
  {
    "id": 84,
    "blog_name": "微小说集",
    "blog_author": "微言",
    "lv": 15,
    "type": 2,
    "quality": 18
  },
  {
    "id": 85,
    "blog_name": "诗歌工厂",
    "blog_author": "VerseMaker",
    "lv": 18,
    "type": 2,
    "quality": 20
  },
  {
    "id": 86,
    "blog_name": "文学灯塔",
    "blog_author": "灯塔客",
    "lv": 30,
    "type": 2,
    "quality": 32
  },
  {
    "id": 87,
    "blog_name": "故事集",
    "blog_author": "StoryTeller",
    "lv": 24,
    "type": 2,
    "quality": 26
  },
  {
    "id": 88,
    "blog_name": "Rust探索",
    "blog_author": "Rustacean",
    "lv": 37,
    "type": 3,
    "quality": 36
  },
  {
    "id": 89,
    "blog_name": "K8s笔记",
    "blog_author": "KubeMaster",
    "lv": 31,
    "type": 3,
    "quality": 33
  },
  {
    "id": 90,
    "blog_name": "前端艺术",
    "blog_author": "FrontArtist",
    "lv": 29,
    "type": 3,
    "quality": 30
  },
  {
    "id": 91,
    "blog_name": "逆向工程",
    "blog_author": "Reverser",
    "lv": 35,
    "type": 3,
    "quality": 34
  },
  {
    "id": 92,
    "blog_name": "UI设计手记",
    "blog_author": "UIDesigner",
    "lv": 27,
    "type": 4,
    "quality": 28
  },
  {
    "id": 93,
    "blog_name": "插画日记",
    "blog_author": "InkDoodle",
    "lv": 22,
    "type": 4,
    "quality": 25
  },
  {
    "id": 94,
    "blog_name": "陶艺工坊",
    "blog_author": "ClayMaster",
    "lv": 16,
    "type": 4,
    "quality": 18
  },
  {
    "id": 95,
    "blog_name": "舞蹈人生",
    "blog_author": "DanceSoul",
    "lv": 23,
    "type": 4,
    "quality": 24
  },
  {
    "id": 96,
    "blog_name": "光影艺术",
    "blog_author": "LightArtist",
    "lv": 32,
    "type": 4,
    "quality": 33
  },
  {
    "id": 97,
    "blog_name": "纸上星辰",
    "blog_author": "星尘写字",
    "lv": 33,
    "type": 2,
    "quality": 32
  },
  {
    "id": 98,
    "blog_name": "半卷诗书",
    "blog_author": "吟书客",
    "lv": 25,
    "type": 2,
    "quality": 28
  },
  {
    "id": 99,
    "blog_name": "旧梦笔谈",
    "blog_author": "梦余生",
    "lv": 16,
    "type": 2,
    "quality": 19
  }
];



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    up_jhph()

## 更新联盟数据
func up_jhph():
    
    jhph = sort_by_lv(0)
    jhph_wx = sort_by_lv(2)
    jhph_js = sort_by_lv(3)
    jhph_ys = sort_by_lv(4)
    
    donate_lm()
    jhph_jz = process_donation_data(donate_data)
    
func join_lm():
    var lm_player = {
    "id":888,
    "blog_name": Blogger.blog_data.blog_name,
    "blog_author": Blogger.blog_data.blog_author,
    "lv": Blogger.level,
    "type": Blogger.blog_data.blog_type,
    "quality": Blogger.tmp_quality,
    }
    lm_list.append(lm_player)
    
    is_join = true
    
func exit_lm():
    is_join = false
    remove_by_id(888)

## 捐赠联盟
func donate_lm():
    for id in donate_ids:
        var m = randi_range(10,donate_max)
        donate_data.append([id,m])
    
    var tm_ids = []
    for i in range(10):
        tm_ids.append(randi_range(4, 99))
    for id in tm_ids:
        var m = randi_range(10,donate_min)
        donate_data.append([id,m])
        
        
    
    
     
func on_month():
    up_jhph()
    
func quarter_activities():
    # 每季度增加联盟blog的属性值
    for blog in lm_list:
        if blog.id <=4:
            blog.lv += 1
            blog.quality += 1
        else:
            if blog.id == 888 :
                pass
            else:
                blog.lv = increase_level(blog.lv,1)
                blog.quality = increase_level(blog.quality,1)




## 随机提升等级的方法
func increase_level(lv: int, k: int) -> int:
    # 检查 k 是否有效
    if k < 1:
        return lv  # 如果 k 小于1，不进行提升
    
    # 生成 1 到 k 之间的随机整数
    var boost: int = randi_range(0, 1)
    
    # 返回提升后的等级
    return lv + boost
    
## 提升等级的方法
func add_level(lv: int, k: int) -> int:
    # 检查 k 是否有效
    if k < 1:
        return lv  # 如果 k 小于1，不进行提升
    # 返回提升后的等级
    return lv + k

## 按 lv 排序，type=0 返回全部，否则只返回指定 type 的数据
func sort_by_lv(type: int = 0) -> Array:
    var filtered_list = []
    for item in lm_list:
        if type == 0 or item["type"] == type:
            filtered_list.append(item.duplicate())  # 避免修改原数据
    
    filtered_list.sort_custom(compare_by_lv)
    return filtered_list

## 比较函数：lv 降序
func compare_by_lv(a: Dictionary, b: Dictionary) -> bool:
    return a["lv"] > b["lv"]


## 按 quality 排序，支持 type 过滤
func sort_by_quality(type: int = 0) -> Array:
    var filtered_list = []
    for item in lm_list:
        if type == 0 or item["type"] == type:
            filtered_list.append(item.duplicate())
    
    filtered_list.sort_custom(compare_by_quality)
    return filtered_list

## 比较函数：quality 降序
func compare_by_quality(a: Dictionary, b: Dictionary) -> bool:
    return a["quality"] > b["quality"]

# 通过 id 搜索博客信息，返回匹配的字典，未找到返回 null
func find_by_id(target_id):
    for item in lm_list:
        if item["id"] == target_id:
            return item # 返回副本，避免外部意外修改原数据
    return null

# 删除 lm_list 中指定 id 的博客
func remove_by_id(target_id):
    for i in range(lm_list.size()):
        if lm_list[i]["id"] == target_id:
            lm_list.remove_at(i)
            print("已删除 id 为 %d 的博客" % [target_id])
            return true
    print("未找到 id 为 %d 的博客，无法删除" % [target_id])
    return false

## 返回捐赠的排序列表
func process_donation_data(donate_data: Array) -> Array:
    var sum_dict = {}
    
    # 统计求和
    for item in donate_data:
        sum_dict[item[0]] = sum_dict.get(item[0], 0) + item[1]
    
    # 转换并排序
    var result = []
    for id in sum_dict.keys():
        result.append([id, sum_dict[id]])
    
    result.sort_custom(func(a, b): return a[1] > b[1])
    return result

func get_index_by_id(target_id):
    for i in range(lm_list.size()):
        if lm_list[i]["id"] == target_id:
            return i  # 返回的就是数组中的索引（从 0 开始）
    return -1  # 没找到
