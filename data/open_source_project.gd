extends Node

## 开源项目数据配置
## 解锁条件：编程能力 ≥90

var projects = [
    {
        "name": "开源项目",
        "description": "编程能力达到90级后，可以创建开源项目",
        "unlock_condition": "code_value_ge_90",
        "type": "开源",
        
        # 开发阶段参数（游戏时间）
        "stamina_per_dev": 30,         # 每次开发消耗体力（与出版畅销书一致）
        "min_write_days": 5,            # 最少写作天数
        "max_write_days": 10,           # 最长写作天数
        "progress_per_day": 1,          # 每天开发进度
        
        # 发布流程阶段
        "phases": [
            {
                "name": "开发阶段",
                "duration_type": "dynamic",
                "min_duration": 5,
                "max_duration": 10,
                "description": "持续开发，积累代码和功能",
            },
            {
                "name": "社区运营",
                "duration_type": "ongoing",
                "description": "发布到GitHub，获得Star和开发者关注",
            },
            {
                "name": "厂商审核",
                "duration_type": "event",
                "description": "大厂发起商务谈判和技术评估",
            },
            {
                "name": "赞助上线",
                "duration_type": "instant",
                "description": "项目获得厂商赞助，持续产生收入",
            }
        ],
        
        # 赞助收益参数
        "sponsor_base_reward": 80000,   # 基础赞助奖励8万
        "reputation_reward": 2000,       # 声望奖励
        
        # 赞助条件
        "min_star_for_sponsor": 100,    # 最低Star数（降低门槛）
        "min_months_for_sponsor": 1,    # 最低运营月数（发布即有机会）
        
        # 状态
        "isVisible": false,
        "disabled": true,
    },
]

## 可赞助的厂商列表（知名大厂）
var sponsors = [
    {
        "name": "谷歌(Google)",
        "min_star": 500,
        "reward_range": [80000, 150000],
        "reputation": 5000,
        "monthly_base": 200000,
        "description": "全球科技巨头，开源生态重要贡献者",
    },
    {
        "name": "苹果(Apple)",
        "min_star": 400,
        "reward_range": [70000, 120000],
        "reputation": 4500,
        "monthly_base": 180000,
        "description": "产品生态领导者，对优质开源项目青睐有加",
    },
    {
        "name": "微软(Microsoft)",
        "min_star": 300,
        "reward_range": [60000, 100000],
        "reputation": 4000,
        "monthly_base": 170000,
        "description": "GitHub最大客户，开源战略重要推手",
    },
    {
        "name": "腾讯",
        "min_star": 200,
        "reward_range": [50000, 80000],
        "reputation": 3500,
        "monthly_base": 150000,
        "description": "国内互联网巨头，技术投资力度大",
    },
    {
        "name": "阿里云",
        "min_star": 200,
        "reward_range": [45000, 75000],
        "reputation": 3000,
        "monthly_base": 140000,
        "description": "国内云服务领导者，开源项目活跃",
    },
    {
        "name": "字节跳动",
        "min_star": 150,
        "reward_range": [40000, 65000],
        "reputation": 2500,
        "monthly_base": 130000,
        "description": "AI和短视频领域领导者，技术氛围浓厚",
    },
    {
        "name": "华为",
        "min_star": 150,
        "reward_range": [35000, 60000],
        "reputation": 2500,
        "monthly_base": 120000,
        "description": "技术研发实力雄厚，注重基础软件",
    },
    {
        "name": "百度",
        "min_star": 100,
        "reward_range": [30000, 50000],
        "reputation": 2000,
        "monthly_base": 110000,
        "description": "AI和搜索引擎领导者，对开源项目支持力度大",
    },
    {
        "name": "美团",
        "min_star": 100,
        "reward_range": [25000, 45000],
        "reputation": 1800,
        "monthly_base": 100000,
        "description": "本地生活巨头，技术投入持续增加",
    },
    {
        "name": "京东",
        "min_star": 100,
        "reward_range": [25000, 40000],
        "reputation": 1500,
        "monthly_base": 90000,
        "description": "电商巨头，云计算和物流技术领先",
    },
]

## 当前开源项目状态（运行时数据）
var current_project_state = {
    "is_developing": false,
    "project_id": "",
    "project_name": "",
    "current_phase": 0,
    "write_days": 0,
    "write_quality": 0,
    "total_progress": 0,
    "phase_day": 0,
	"completed": false,
	"publish_date": "",
	"stars": 0,
    "fork_count": 0,
    "issue_count": 0,
    "sponsor_months": 0,
    "total_sponsor_income": 0,
    "sponsor": {},
    "sponsor_name": "",
    "code_value": 0,
}

## 已发布开源项目列表（可同时有多个项目）
var published_projects: Array = []

## 生成项目ID
func generate_project_id() -> String:
    return "os_" + str(Time.get_ticks_msec()) + "_" + str(randi() % 10000)

## 计算项目质量（基于开发天数和编程能力值）
func calculate_project_quality(write_days: int, code_value: float) -> float:
    var day_factor = clamp(float(write_days) / 10.0, 0.5, 1.0)
    var code_factor = code_value / 100.0
    return day_factor * code_factor

## 检查是否满足赞助条件
func check_sponsor_eligible(project: Dictionary) -> bool:
    if not project.get("published", false):
        return false
    if project.get("sponsor_months", 0) >= 12:  # 赞助周期12个月
        return false
    
    var stars = project.get("stars", 0)
    
    return stars >= 100  # 降低门槛

## 获取符合条件的赞助商
func get_eligible_sponsors(star_count: int) -> Array:
    var eligible = []
    for sponsor in sponsors:
        if star_count >= sponsor.min_star:
            eligible.append(sponsor)
    return eligible

## 计算赞助奖励
func calculate_sponsor_reward(sponsor: Dictionary, project_quality: float) -> int:
    var min_reward = sponsor.reward_range[0]
    var max_reward = sponsor.reward_range[1]
    var reward = min_reward + int((max_reward - min_reward) * project_quality)
    return reward

## 更新所有项目的Star数（每月调用）
func update_all_projects_stars() -> Dictionary:
    var updates = []
    
    for project in published_projects:
        if not project.get("published", false) or project.get("sponsor_months", 0) >= 12:
            continue
        
        # 根据项目质量增加Star
        var quality = project.get("write_quality", 0.5)
        var new_stars = int(randf_range(10, 50) * quality)
        project.stars = project.get("stars", 0) + new_stars
        project.sponsor_months = project.get("sponsor_months", 0) + 1
        
        # 赞助收入（根据厂商和项目质量）
        var sponsor = project.get("sponsor", {})
        var monthly_base = sponsor.get("monthly_base", 100000)
        var write_quality = project.get("write_quality", 0.5)
        var peak_income = monthly_base * (0.8 + 0.4 * write_quality)
        var sponsor_months = project.get("sponsor_months", 1)
        
        var sponsor_income = 0
        if sponsor_months < 6:
            sponsor_income = int(peak_income * pow(float(sponsor_months) / 6.0, 1.5))
        else:
            sponsor_income = int(peak_income * (0.9 + randf_range(-0.1, 0.1)))
        
        project.total_sponsor_income = project.get("total_sponsor_income", 0) + sponsor_income
        
        updates.append({
            "project_name": project.get("project_name", ""),
            "new_stars": new_stars,
            "total_stars": project.stars,
            "sponsor_income": sponsor_income,
            "sponsor_months": sponsor_months,
        })
    
    return {"updates": updates}
