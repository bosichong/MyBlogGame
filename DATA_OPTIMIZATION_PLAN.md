# MyBlogGame 数据管理优化方案

> 生成日期：2026-03-26
> 优化目标：统一数据管理、实现存档功能、提升代码可维护性

---

## 一、优化背景

### 当前问题

1. **数据分散**：游戏数据分散在 Blogger、TimerManager、BankSystem、AdManager、Tongji 等多个单例中
2. **GlobalDataManager 未充分利用**：虽然设计了框架，但只加载了一个 milestones 配置
3. **缺乏存档功能**：游戏无法保存和加载，关闭游戏后所有进度丢失
4. **配置和运行时数据混杂**：Utils.gd 中既有静态配置，又有业务逻辑
5. **数据访问不统一**：代码中到处都是 `Blogger.xxx`、`AdManager.xxx` 等分散调用

### 优化目标

1. **统一数据管理**：所有运行时数据集中到 GlobalDataManager
2. **实现存档功能**：支持多存档槽位、自动保存、手动保存
3. **数据访问规范化**：通过统一接口访问所有数据
4. **配置与运行时分离**：静态配置不保存到存档
5. **提升可维护性**：数据结构清晰，易于扩展和修改

---

## 二、整体架构设计

### 2.1 架构层次图

```
┌─────────────────────────────────────────────────────────┐
│                    游戏场景层 (Scenes)                    │
│  main.tscn, bottom.tscn, bank_main.tscn, yun_main.tscn  │
└────────────────────┬────────────────────────────────────┘
                     │ 通过信号和直接调用访问
┌────────────────────▼────────────────────────────────────┐
│                  业务逻辑层 (Scripts)                     │
│  Blogger.gd, TimerManager.gd, BankSystem.gd,            │
│  AdManager.gd, TaskManager.gd, Tongji.gd                │
└────────────────────┬────────────────────────────────────┘
                     │ 所有数据访问通过统一接口
┌────────────────────▼────────────────────────────────────┐
│              GlobalDataManager (数据中心)                 │
│  ┌─────────────────────────────────────────────────┐   │
│  │          DataContainer (数据容器)                │   │
│  │  ├─ StaticConfig (静态配置 - 不需要保存)         │   │
│  │  │  ├─ PostCategories (文章类型配置)             │   │
│  │  │  ├─ SkillsConfig (技能配置)                   │   │
│  │  │  ├─ MaintenanceConfig (维护配置)               │   │
│  │  │  ├─ RecreationConfig (娱乐配置)               │   │
│  │  │  ├─ AdConfig (广告配置)                       │   │
│  │  │  ├─ GameStrings (游戏文本)                    │   │
│  │  │  └─ RankTitles (头衔配置)                     │   │
│  │  └─ RuntimeData (运行时数据 - 需要保存)          │   │
│  │     ├─ BloggerData (博主数据)                    │   │
│  │     ├─ TimeData (时间数据)                       │   │
│  │     ├─ BankData (银行数据)                       │   │
│  │     ├─ AdData (广告数据)                         │   │
│  │     ├─ StatisticsData (统计数据)                 │   │
│  │     ├─ TaskData (任务数据)                       │   │
│  │     └─ LeagueData (联盟数据)                     │   │
│  └─────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────┐   │
│  │          SaveManager (存档管理器)                │   │
│  │  ├─ save_game(slot)      - 保存游戏              │   │
│  │  ├─ load_game(slot)      - 加载游戏              │   │
│  │  ├─ delete_save(slot)    - 删除存档              │   │
│  │  ├─ list_saves()         - 列出存档              │   │
│  │  └─ auto_save()          - 自动保存              │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

### 2.2 数据访问原则

**原则1：单一数据源**
- 所有运行时数据存储在 GlobalDataManager 中
- 各业务脚本不再保存数据，只保存逻辑和引用

**原则2：统一访问接口**
- 通过 `GlobalDataManager.data.xxx` 访问数据
- 禁止直接访问其他单例的变量（除配置外）

**原则3：数据变更通知**
- 数据变更通过信号通知
- 各业务脚本订阅需要的数据变更信号

**原则4：配置与运行时分离**
- 静态配置不保存到存档
- 运行时数据保存到存档

---

## 三、数据结构设计

### 3.1 数据结构类清单

需要创建以下数据结构类：

| 文件名 | 说明 | 保存到存档 |
|--------|------|-----------|
| `scripts/data/BloggerData.gd` | 博主数据 | ✅ 是 |
| `scripts/data/TimeData.gd` | 时间数据 | ✅ 是 |
| `scripts/data/BankData.gd` | 银行数据 | ✅ 是 |
| `scripts/data/AdData.gd` | 广告数据 | ✅ 是 |
| `scripts/data/StatisticsData.gd` | 统计数据 | ✅ 是 |
| `scripts/data/TaskData.gd` | 任务数据 | ✅ 是 |
| `scripts/data/LeagueData.gd` | 联盟数据 | ✅ 是 |
| `scripts/data/RuntimeData.gd` | 运行时数据容器 | ✅ 是 |
| `scripts/data/StaticConfig.gd` | 静态配置容器 | ❌ 否 |
| `scripts/data/DataContainer.gd` | 总数据容器 | ❌ 否 |

### 3.2 BloggerData（博主数据）

```gdscript
class_name BloggerData extends Resource

# ===== 核心属性 =====
var level: int = 1
var exp: int = 0
var rank_tier: int = 0  # 段位（0-9）
var attribute_points: int = 0

# ===== 能力值 =====
var writing_ability: int = 23
var technical_ability: int = 23
var code_ability: int = 23
var literature_ability: int = 23
var drawing_ability: int = 23

# ===== 资源 =====
var stamina: int = 100
var money: float = 100000.0
var social_ability: int = 5

# ===== 博客数据 =====
var blog_name: String = "我的博客"
var blog_author: String = "J.sky"
var blog_type: int = 1

var safety_value: int = 100
var seo_value: int = 100
var design_value: int = 100
var ui_value: int = 0

var views: int = 0
var rss: int = 0
var favorites: int = 0

var today_views: int = 0
var week_views: int = 0
var month_views: int = 0
var year_views: int = 0

var posts: Array[Dictionary] = []

# ===== 日程安排（7天）=====
var calendar: Array[Dictionary] = [
    {"tasks": ["阅读名著"]},
    {"tasks": ["阅读名著"]},
    {"tasks": ["阅读名著"]},
    {"tasks": ["阅读名著"]},
    {"tasks": ["安全维护"]},
    {"tasks": ["SEO优化"]},
    {"tasks": ["打游戏"]},
]

# ===== 临时变量 =====
var tmp_week: int = 1
var tmp_month: int = 1
var tmp_year: int = 2000
var last_post_quality: int = 0

# ===== 信号 =====
signal level_changed(new_level: int)
signal exp_changed(new_exp: int)
signal ability_changed(ability_type: String, new_value: int)
signal blog_views_changed(new_views: int)
signal post_added(post_data: Dictionary)
```

### 3.3 TimeData（时间数据）

```gdscript
class_name TimeData extends Resource

var current_year: int = 2000
var current_month: int = 1
var current_week: int = 1
var current_day: int = 1
var current_quarter: int = 1

var time_scale: float = 1.0
var is_paused: bool = false

var game_start_date: String = "2000-1-1-1"
var current_date_str: String = "2000-1-1-1"

func get_total_days() -> int:
    return (current_year - 2000) * 12 * 4 * 7 + \
           (current_month - 1) * 4 * 7 + \
           (current_week - 1) * 7 + \
           current_day
```

### 3.4 BankData（银行数据）

```gdscript
class_name BankData extends Resource

var savings_balance: float = 0.0
var savings_interest: float = 0.0
var fixed_deposits: Dictionary = {}
var next_deposit_id: int = 1

const SAVINGS_DAILY_RATE = 0.01
const FIXED_RATE_HALF_YEAR = 2.301
const FIXED_RATE_ONE_YEAR = 4.603
const FIXED_RATE_THREE_YEARS = 13.809

var deposit_history: Array[Dictionary] = []
var withdraw_history: Array[Dictionary] = []
```

### 3.5 AdData（广告数据）

```gdscript
class_name AdData extends Resource

var current_ad_type: String = "文字广告"
var is_registered: bool = true
var is_under_review: bool = false
var is_approved: bool = false
var review_days: int = 0

var pending_commission: float = 0.0
var settled_commission: float = 0.0
var total_commission: float = 0.0

var ad_statistics: Array[Dictionary] = []
```

### 3.6 StatisticsData（统计数据）

```gdscript
class_name StatisticsData extends Resource

var daily_stats: Array[Dictionary] = []
var weekly_stats: Array[Dictionary] = []
var monthly_stats: Array[Dictionary] = []
var yearly_stats: Array[Dictionary] = []

var total_posts: int = 0
var paid_posts: int = 0
var free_posts: int = 0

var total_income: float = 0.0
var ad_income: float = 0.0
var post_income: float = 0.0
var bank_income: float = 0.0
```

### 3.7 TaskData（任务数据）

```gdscript
class_name TaskData extends Resource

var task_states: Array[Dictionary] = []
var completed_tasks: int = 0
var active_tasks: int = 0
var total_rewards: Dictionary = {"money": 0.0, "exp": 0}
```

### 3.8 LeagueData（联盟数据）

```gdscript
class_name LeagueData extends Resource

var is_joined: bool = false
var donation_total: float = 0.0
var donation_history: Array[Dictionary] = []

var rank_overall: Array[Dictionary] = []
var rank_literature: Array[Dictionary] = []
var rank_tech: Array[Dictionary] = []
var rank_art: Array[Dictionary] = []

var donation_ranking: Array[Array] = []
```

### 3.9 RuntimeData（运行时数据容器）

```gdscript
class_name RuntimeData extends Resource

var blogger: BloggerData = BloggerData.new()
var time: TimeData = TimeData.new()
var bank: BankData = BankData.new()
var ad: AdData = AdData.new()
var statistics: StatisticsData = StatisticsData.new()
var task: TaskData = TaskData.new()
var league: LeagueData = LeagueData.new()
```

### 3.10 StaticConfig（静态配置容器）

```gdscript
class_name StaticConfig extends Resource

var post_categories: Array[Dictionary] = []
var skills_config: Array[Dictionary] = []
var maintenance_config: Array[Dictionary] = []
var recreation_config: Array[Dictionary] = []
var ad_config: Array[Dictionary] = []
var game_strings: Dictionary = {}
var rank_titles: Array[String] = []
var milestones_config: Dictionary = {}

const MAX_LEVEL = 100
const MAX_SKILL_LEVEL = 100
const DAYS_IN_WEEK = 7
const WEEKS_IN_MONTH = 4
const MONTHS_IN_YEAR = 12
```

### 3.11 DataContainer（总数据容器）

```gdscript
class_name DataContainer extends Resource

var static_config: StaticConfig = StaticConfig.new()
var runtime_data: RuntimeData = RuntimeData.new()

func get_blogger() -> BloggerData:
    return runtime_data.blogger

func get_time() -> TimeData:
    return runtime_data.time

func get_bank() -> BankData:
    return runtime_data.bank

func get_ad() -> AdData:
    return runtime_data.ad

func get_statistics() -> StatisticsData:
    return runtime_data.statistics

func get_task() -> TaskData:
    return runtime_data.task

func get_league() -> LeagueData:
    return runtime_data.league
```

---

## 四、管理器设计

### 4.1 SaveManager（存档管理器）

需要创建 `scripts/managers/SaveManager.gd`

**功能**：
- `save_game(slot: int, data_container: DataContainer) -> Dictionary`
- `load_game(slot: int) -> Dictionary`
- `delete_save(slot: int) -> bool`
- `list_saves() -> Array`
- `auto_save()` - 定期自动保存

**存档格式**：
```json
{
  "version": "1.0",
  "timestamp": 1234567890,
  "runtime_data": {
    "blogger": {...},
    "time": {...},
    "bank": {...},
    "ad": {...},
    "statistics": {...},
    "task": {...},
    "league": {...}
  },
  "metadata": {
    "blog_name": "我的博客",
    "level": 10,
    "money": 50000.0,
    "current_date": "2001-3-2-1"
  }
}
```

**存档位置**：`user://saves/save_0.save`

### 4.2 ConfigManager（配置管理器）

需要创建 `scripts/managers/ConfigManager.gd`

**功能**：
- 从现有脚本加载所有静态配置
- 迁移 Utils.gd 中的配置数据
- 迁移 Strs.gd 中的文本数据
- 迁移 AdManager 中的广告配置

**加载内容**：
- 文章类型配置（Utils.possible_categories）
- 技能学习配置（Utils.learning_skills）
- 网站维护配置（Utils.website_maintenance）
- 休闲娱乐配置（Utils.recreation）
- 广告配置（AdManager.ads）
- 游戏文本（Strs.game_strs）
- 头衔配置（Strs.game_strs.头衔）
- 成就配置（GDManager["milestones"]）

### 4.3 GlobalDataManager（全局数据管理器）

重构 `scripts/GlobalDataManager.gd`

**核心功能**：
```gdscript
# 数据访问快捷方法
func get_blogger() -> BloggerData
func get_time() -> TimeData
func get_bank() -> BankData
func get_ad() -> AdData
func get_statistics() -> StatisticsData
func get_task() -> TaskData
func get_league() -> LeagueData

# 常用数据访问
func get_level() -> int
func set_level(new_level: int)
func get_money() -> float
func add_money(amount: float)
func deduct_money(amount: float) -> bool
func get_current_date() -> String
func advance_day()

# 存档管理
func save_game(slot: int = 0) -> Dictionary
func load_game(slot: int = 0) -> Dictionary
func delete_save(slot: int) -> bool
func list_saves() -> Array
```

**信号定义**：
```gdscript
signal money_changed(new_money: float)
signal level_changed(new_level: int)
signal day_passed
signal week_passed
signal month_passed
signal year_passed
signal game_loaded(slot: int)
```

---

## 五、数据访问接口

### 5.1 统一访问方式

**旧方式**：
```gdscript
Blogger.level
Blogger.money
Blogger.stamina
TimerManager.current_year
BankSystem.savings_balance
AdManager.ad_set
```

**新方式**：
```gdscript
GlobalDataManager.get_blogger().level
GlobalDataManager.get_blogger().money
GlobalDataManager.get_blogger().stamina
GlobalDataManager.get_time().current_year
GlobalDataManager.get_bank().savings_balance
GlobalDataManager.get_ad().current_ad_type
```

**快捷方式**：
```gdscript
GlobalDataManager.get_level()
GlobalDataManager.set_level(new_level)
GlobalDataManager.get_money()
GlobalDataManager.add_money(100.0)
GlobalDataManager.deduct_money(50.0)
GlobalDataManager.get_current_date()
GlobalDataManager.advance_day()
```

### 5.2 信号订阅

**数据变更信号**：
```gdscript
# 订阅金钱变化
GlobalDataManager.connect("money_changed", _on_money_changed)

# 订阅等级变化
GlobalDataManager.connect("level_changed", _on_level_changed)

# 订阅时间流逝
GlobalDataManager.connect("day_passed", _on_day_passed)
GlobalDataManager.connect("week_passed", _on_week_passed)
GlobalDataManager.connect("month_passed", _on_month_passed)
GlobalDataManager.connect("year_passed", _on_year_passed)

# 订阅游戏加载
GlobalDataManager.connect("game_loaded", _on_game_loaded)
```

---

## 六、迁移策略

### 6.1 迁移阶段

**阶段1：准备工作（2天）**
- [ ] 创建数据结构类（10个文件）
- [ ] 创建管理器类（2个文件）
- [ ] 重构 GlobalDataManager
- [ ] 测试基础功能

**阶段2：数据迁移（5天）**
- [ ] 迁移 Blogger.gd 数据
- [ ] 迁移 TimerManager.gd 数据
- [ ] 迁移 BankSystem.gd 数据
- [ ] 迁移 AdManager 数据
- [ ] 迁移 Tongji.gd 数据
- [ ] 迁移 TaskManager.gd 数据

**阶段3：接口迁移（7天）**
- [ ] 修改 main.gd 数据访问
- [ ] 修改 top.gd 数据访问
- [ ] 修改 bottom.gd 数据访问
- [ ] 修改 bank_main.gd 数据访问
- [ ] 修改 yun_main.gd 数据访问
- [ ] 修改 lm_mian.gd 数据访问
- [ ] 修改其他UI脚本数据访问

**阶段4：添加存档功能（3天）**
- [ ] 创建存档/读档UI
- [ ] 实现自动保存
- [ ] 实现退出保存
- [ ] 创建存档管理界面

**阶段5：测试和优化（5天）**
- [ ] 测试存档保存
- [ ] 测试存档加载
- [ ] 测试所有游戏功能
- [ ] 性能优化
- [ ] Bug修复

**阶段6：清理工作（2天）**
- [ ] 删除冗余代码
- [ ] 优化代码结构
- [ ] 更新注释

### 6.2 兼容性策略

**保持兼容性**：
```gdscript
# Blogger.gd 中保持兼容
var level: int:
    get:
        return GlobalDataManager.get_blogger().level
    set(value):
        GlobalDataManager.set_level(value)

var money: float:
    get:
        return GlobalDataManager.get_blogger().money
    set(value):
        GlobalDataManager.get_blogger().money = value
```

**新旧接口并存**：
- 在迁移期间保留原有的全局变量
- 通过属性 getter/setter 重定向到 GlobalDataManager
- 逐步切换到新接口

---

## 七、实施步骤

### 步骤1：创建目录结构

```
scripts/
├── data/           # 数据结构类
├── managers/       # 管理器类
├── task_system/    # 任务系统（已存在）
└── days/           # 日程管理（已存在）
```

### 步骤2：创建数据结构类（按顺序）

1. 创建 `scripts/data/BloggerData.gd`
2. 创建 `scripts/data/TimeData.gd`
3. 创建 `scripts/data/BankData.gd`
4. 创建 `scripts/data/AdData.gd`
5. 创建 `scripts/data/StatisticsData.gd`
6. 创建 `scripts/data/TaskData.gd`
7. 创建 `scripts/data/LeagueData.gd`
8. 创建 `scripts/data/RuntimeData.gd`
9. 创建 `scripts/data/StaticConfig.gd`
10. 创建 `scripts/data/DataContainer.gd`

### 步骤3：创建管理器类

1. 创建 `scripts/managers/SaveManager.gd`
2. 创建 `scripts/managers/ConfigManager.gd`

### 步骤4：重构 GlobalDataManager

1. 添加数据容器
2. 添加管理器引用
3. 实现数据访问方法
4. 实现存档管理方法
5. 定义信号

### 步骤5：迁移业务逻辑脚本

1. 修改 `Blogger.gd`
   - 将变量改为从 GlobalDataManager 获取
   - 保持方法逻辑不变
   - 添加兼容性代码

2. 修改 `TimerManager.gd`
   - 迁移时间数据到 GlobalDataManager
   - 保持时间逻辑不变

3. 修改 `BankSystem.gd`
   - 迁移银行数据到 GlobalDataManager
   - 保持业务逻辑不变

4. 修改 `AdManager`
   - 迁移广告数据到 GlobalDataManager
   - 保持业务逻辑不变

5. 修改 `Tongji.gd`
   - 迁移统计数据到 GlobalDataManager
   - 保持业务逻辑不变

6. 修改 `TaskManager.gd`
   - 迁移任务数据到 GlobalDataManager
   - 保持业务逻辑不变

### 步骤6：更新UI脚本

1. 修改 `main.gd`
2. 修改 `top.gd`
3. 修改 `bottom.gd`
4. 修改 `bank_main.gd`
5. 修改 `yun_main.gd`
6. 修改 `lm_mian.gd`
7. 修改其他UI脚本

### 步骤7：添加存档功能

1. 在主菜单添加存档/读档按钮
2. 创建存档选择界面
3. 实现自动保存（每天结束时）
4. 实现退出时保存
5. 创建存档管理界面（查看、删除）

### 步骤8：测试

1. **存档测试**
   - 测试保存功能
   - 测试加载功能
   - 测试多存档槽位
   - 测试存档删除

2. **功能测试**
   - 测试博主功能
   - 测试时间系统
   - 测试银行系统
   - 测试广告系统
   - 测试任务系统
   - 测试联盟系统

3. **数据一致性测试**
   - 验证存档前后数据一致
   - 验证加载后功能正常
   - 验证数据不会丢失

4. **性能测试**
   - 测试存档保存速度
   - 测试存档加载速度
   - 测试内存占用

### 步骤9：清理和优化

1. 删除冗余代码
2. 优化代码结构
3. 添加注释和文档
4. 代码审查

---

## 八、预期效果

### 8.1 优势

1. **数据集中管理**
   - 所有数据集中在一个地方
   - 易于查找和修改
   - 数据结构清晰

2. **存档功能完善**
   - 支持多存档槽位（10个）
   - 自动保存和手动保存
   - 存档信息清晰（等级、金钱、日期）
   - 支持存档删除

3. **代码更清晰**
   - 数据访问统一
   - 减少代码耦合
   - 易于维护和扩展

4. **易于扩展**
   - 新增数据类型简单
   - 新增游戏系统方便
   - 配置和数据分离

5. **便于调试**
   - 数据状态清晰
   - 易于追踪数据变化
   - 信号系统完善

### 8.2 风险和挑战

1. **工作量大**
   - 需要创建约12个新文件
   - 需要修改约20个现有文件
   - 预计需要21天完成

2. **兼容性问题**
   - 可能引入新的bug
   - 需要保证数据一致性
   - 需要充分测试

3. **学习成本**
   - 开发者需要熟悉新架构
   - 需要更新开发习惯
   - 需要理解数据访问方式

### 8.3 解决方案

1. **分阶段实施**
   - 每个阶段独立测试
   - 每个阶段提交一次Git
   - 遇到问题及时回滚

2. **保持兼容性**
   - 新旧接口并存
   - 逐步切换到新接口
   - 保留过渡期

3. **充分测试**
   - 每个阶段都要测试
   - 重点测试存档功能
   - 确保数据不丢失

---

## 九、时间估算

| 阶段 | 内容 | 预计耗时 | 风险 |
|------|------|----------|------|
| 阶段1 | 准备工作（创建数据结构和管理器） | 2天 | 低 |
| 阶段2 | 数据迁移（迁移6个业务脚本） | 5天 | 中 |
| 阶段3 | 接口迁移（修改20+个UI脚本） | 7天 | 中 |
| 阶段4 | 添加存档功能（UI和逻辑） | 3天 | 低 |
| 阶段5 | 测试和优化（全面测试） | 5天 | 低 |
| 阶段6 | 清理工作（删除冗余代码） | 2天 | 极低 |
| **总计** | **完整优化** | **24天** | **中** |

---

## 十、注意事项

1. **每完成一个阶段，提交一次Git**
   - 方便回滚
   - 记录进度

2. **每次只做一件事**
   - 不要同时改动多个部分
   - 降低风险

3. **改完测试游戏**
   - 确保功能正常
   - 确保数据正确

4. **保持兼容性**
   - 新旧接口并存
   - 逐步切换

5. **充分测试存档功能**
   - 这是最重要的功能
   - 确保数据不丢失

6. **及时沟通**
   - 遇到问题及时反馈
   - 不要拖延

---

## 十一、进度追踪

- [ ] 阶段1：准备工作
  - [ ] 创建数据结构类（10个）
  - [ ] 创建管理器类（2个）
  - [ ] 重构 GlobalDataManager
  - [ ] 测试基础功能

- [ ] 阶段2：数据迁移
  - [ ] 迁移 Blogger.gd
  - [ ] 迁移 TimerManager.gd
  - [ ] 迁移 BankSystem.gd
  - [ ] 迁移 AdManager
  - [ ] 迁移 Tongji.gd
  - [ ] 迁移 TaskManager.gd

- [ ] 阶段3：接口迁移
  - [ ] 修改 main.gd
  - [ ] 修改 top.gd
  - [ ] 修改 bottom.gd
  - [ ] 修改其他UI脚本

- [ ] 阶段4：添加存档功能
  - [ ] 创建存档UI
  - [ ] 实现自动保存
  - [ ] 实现退出保存
  - [ ] 创建存档管理界面

- [ ] 阶段5：测试和优化
  - [ ] 测试存档功能
  - [ ] 测试游戏功能
  - [ ] 性能优化
  - [ ] Bug修复

- [ ] 阶段6：清理工作
  - [ ] 删除冗余代码
  - [ ] 优化代码结构
  - [ ] 更新注释

---

## 十二、后续改进

完成本次优化后，还可以考虑以下改进：

1. **添加存档加密**
   - 防止玩家修改存档
   - 提高存档安全性

2. **添加云存档**
   - 支持Steam云存档
   - 支持跨设备同步

3. **添加存档回放**
   - 记录玩家操作
   - 支持游戏回放

4. **添加数据导出**
   - 导出统计数据
   - 生成游戏报告

5. **添加配置热重载**
   - 修改配置无需重启
   - 方便调试

---

## 十三、相关文档

- `OPTIMIZATION.md` - 代码质量优化计划
- `README.md` - 项目说明
- `project.godot` - Godot项目配置

---

**最后更新时间**：2026-03-26
**文档状态**：待审核