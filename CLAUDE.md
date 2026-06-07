# 博客游戏 (MyBlogGame)

用 Godot 4.6 开发的可玩博客模拟经营游戏，玩家扮演博主经营自己的博客。

## 技术栈

- **引擎**: Godot 4.6
- **语言**: GDScript
- **存档**: JSON 文件（SaveManager）
- **UID 管理**: `.gd.uid` 文件

## 项目结构

```
MyBlogGame/
├── assets/              # 图片、字体等静态资源（场景贴图、.pxo 源文件）
├── data/                # 游戏数据（可热重载的配置数据）
│   ├── blog_categories/ # 博客分类配置（每个分类一个 .gd 文件）
│   ├── maintenance/     # 网站维护日程配置
│   ├── recreation/      # 娱乐活动配置
│   ├── skills/          # 技能配置
│   ├── blog_categories.gd     # 分类汇总（扫描子目录加载）
│   ├── website_maintenance.gd # 维护汇总
│   ├── recreation.gd          # 娱乐汇总
│   ├── learning_skills.gd     # 技能汇总
│   ├── book_publish.gd        # 出版畅销书业务数据
│   ├── ip_authorization.gd    # IP授权业务数据
│   ├── ip_companies.gd
│   ├── lm_members.gd          # 联盟成员
│   ├── open_source_project.gd
│   ├── publishers.gd
│   ├── title_templates.gd
│   ├── comment_templates.gd   # 评论模板（友链/联盟评论）
│   └── yearly_summary_template.gd # 年度总结弹窗模板
├── milestones/          # 成就系统（config.gd + main.gd/tscn + mile.gd/tscn）
├── scenes/              # Godot 场景文件 (.tscn)
│   ├── main.tscn        # 主场景
│   ├── 日程.tscn         # 日程面板
│   ├── blog_dashboard.tscn # 博客后台
│   ├── lm.tscn          # 博客联盟
│   ├── bank_main.tscn   # 银行主界面
│   ├── yun_main.tscn    # 主机/域名界面
│   ├── ad.tscn          # 广告
│   ├── popup.tscn       # 弹窗
│   ├── r_panel.tscn     # 信息显示
│   ├── top.tscn / bottom.tscn # 顶/底导航
│   ├── s001/ ~ s004/    # 章节场景
│   └── ...
├── scripts/             # GDScript 脚本
│   ├── 日程.gd              # 日程驱动
│   ├── timer_manager.gd     # 计时器
│   ├── blogger.gd           # 博主核心逻辑（最大文件，~1260 行）
│   ├── blog_dashboard.gd
│   ├── bloglm.gd            # 联盟
│   ├── BankSystem.gd        # 银行系统
│   ├── bank_main.gd
│   ├── yun.gd / yun_main.gd # 主机/域名
│   ├── lm_mian.gd
│   ├── ad.gd / ad_manager.gd # 广告
│   ├── bottom.gd / top.gd
│   ├── calendar.gd / popup.gd / r_panel.gd
│   ├── hf.gd                # 恢复体力
│   ├── test.gd / tongji.gd  # 统计
│   ├── strings.gd           # 字符串常量（autoload: Strs）
│   ├── utils.gd             # 数据快捷访问（Utils.possible_categories 等）
│   ├── GlobalDataManager.gd # 全局数据管理（autoload: GDManager）
│   ├── config/              # 平衡配置
│   │   └── GameBalanceConfig.gd # 体力上限/消耗静态类
│   ├── days/                # 日程面板
│   │   └── day_panel.gd
│   ├── story/               # 剧情进度
│   │   └── StoryProgress.gd
│   ├── utils/               # 工具脚本
│   │   └── YearlySummaryFormatter.gd
│   ├── views/               # 访问量系统
│   │   ├── ViewsCalculator.gd / PostStatsManager.gd
│   │   ├── ViewsEvent.gd / ViewsEventManager.gd
│   │   ├── ViewsModifier.gd / ViewsModifierManager.gd
│   │   ├── ViewsStatsData.gd / ViewsStatsManager.gd
│   │   ├── events/  modifiers/
│   ├── managers/            # 管理器
│   │   ├── SaveManager.gd
│   │   ├── ConfigManager.gd
│   │   ├── FriendLinkManager.gd
│   │   └── CommentManager.gd       # 评论管理
│   ├── data/                # 运行时数据类
│   │   ├── DataContainer.gd        # 数据容器
│   │   ├── RuntimeData.gd / StaticConfig.gd
│   │   ├── BloggerData.gd / TimeData.gd
│   │   ├── BankData.gd / AdData.gd
│   │   ├── CommentData.gd / FriendLinkData.gd
│   │   ├── LeagueData.gd / PostData.gd
│   │   ├── StatisticsData.gd / TaskData.gd
│   │   └── YearlySummaryData.gd    # 年度快照
│   └── task_system/         # 任务系统
│       ├── TaskManager.gd         # 任务调度（autoload）
│       ├── TaskConfig.gd          # 任务配置（条件/动作/任务列表）
│       ├── BookPublishManager.gd  # 出书业务
│       ├── OpenSourceManager.gd   # 开源业务
│       └── IPAuthManager.gd       # IP授权业务
├── tests/               # 单元测试
├── reports/             # 测试/审查报告
├── 开发笔记/             # 设计文档归档（系统设计、代码审查报告等）
├── 优秀博客大奖赛/        # 章节素材
├── our_theme.tres
├── README.md
├── LICENSE
└── project.godot        # 项目配置
```

## 全局访问入口（Autoload 单例）

> 注册位置：`project.godot` 的 `[autoload]` 段。按 `project.godot` 文件中**声明的顺序**加载（不是字母顺序）。

| 名称 | 类型 | 来源 | 用途 |
|------|------|------|------|
| `GDManager` | GlobalDataManager | `scripts/GlobalDataManager.gd` | 顶层数据入口（信号/存档/数据访问） |
| `TimerManager` | Node | `scripts/timer_manager.gd` | 计时器（年/月/周/天推进） |
| `Blogger` | Node (blogger.gd) | `scripts/blogger.gd` | 玩家博客数据/博文发布信号 |
| `Utils` | Node (utils.gd) | `scripts/utils.gd` | 数据快捷访问 + 工具方法 |
| `Strs` | Node (strings.gd) | `scripts/strings.gd` | 字符串常量（评论模板、博客名等） |
| `AdManager` | Node | `scripts/ad_manager.gd` | 广告联盟（佣金结算、审核） |
| `Tongji` | Node (tongji.gd) | `scripts/tongji.gd` | 数据统计（按月/季度记录） |
| `Lm` | Node (bloglm.gd) | `scripts/bloglm.gd` | 博客联盟（友链/成员数据） |
| `Bs` | BankSystem | `scripts/BankSystem.gd` | 银行系统（存款/贷款/利息） |
| `Yun` | Node (yun.gd) | `scripts/yun.gd` | 主机/域名/备案（每日检查、到期停服） |
| `TaskManager` | Node (TaskManager.gd) | `scripts/task_system/TaskManager.gd` | 任务系统入口 |

> 重要：`Utils._init()` 在 `GDManager._init()` 之后执行（autoload 顺序保证），
> 因此 `Utils.possible_categories` 等在脚本运行期随时可用。

---

## 核心概念

### 日程驱动系统
游戏采用**日程驱动**模式：玩家在管理面板设置自动处理规则，维护日程按规则自动执行。无需手动操作面板，功能通过定时日程管理。

### SEO 系统
- SEO 值最高 200（blogger.gd 中 clamp 上限）
- 友链 SEO 贡献上限为 20（占比 10%）
- SEO 值过低会导致博客失去来自搜索引擎的基础访问量

### 付费文章系统
- 订阅价格固定 9.9 元（`PAID_SUBSCRIPTION_PRICE`），5% 访问量转化为订阅人数（`PAID_SUBSCRIPTION_RATE`）
- **按月结算**：每月第 4 周第 7 天（月末）触发，累计一个月的 `monthly_paid_income` 后入账
- 收入 = 新增订阅人数 × 订阅价格（按 `小说连载` / `付费黑客攻防` 分别累积，再汇总入账）

### 能力等级
- 最高等级：`const MAX_LEVEL = 100`
- 技能最高等级：`const MAX_SKILL_LEVEL = 100`
- 核心属性：写作能力(writing_ability)、技术能力(technical_ability)、文学能力(literature_ability)、编程能力(code_ability)
- 派生属性：体力值(stamina)、社交能力(social_ability)、金钱(money)、rss订阅(blog_rss)、今日/本周访问量、exp、level、reputation、文章质量分

---

## 数据系统（如何创建/读取数据）

数据全部存放在 `data/` 目录下的 `.gd` 配置文件中。修改后**热重载即可**，无需重启游戏。

### 1. 数据加载流程

```
data/xxx.gd  ─┐
data/xxx/*.gd ─┼─→  GDManager._load_all_data()  ─→  loaded_data 字典
               │                                          ↓
               │                                    Utils（快捷访问）
               │                                          ↓
               │                                    ConfigManager → StaticConfig
```

- `GDManager._load_all_data()` 在 `_init()` 中执行（早于 `_ready()`）
- `Utils._init()` 紧接着把数据转成便捷字段
- `ConfigManager` 在 `_ready()` 时把数据复制到 `StaticConfig`（用于存档快照/查询）

### 2. 数据文件的两类形态

#### A. 子目录汇总型（如 `blog_categories.gd`）

汇总文件扫描子目录下所有独立 `.gd` 文件，把每个文件里的 `item` 字典收集到一个数组：

```gdscript
# data/blog_categories.gd
extends Node

var categories: Array = []

func _init():
    _load_all_categories()

func _load_all_categories():
    var dir = DirAccess.open("res://data/blog_categories/")
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if file_name.ends_with(".gd") and file_name != "blog_categories.gd":
                var full_path = "res://data/blog_categories/" + file_name
                var script = load(full_path)
                if script:
                    var instance = script.new()
                    if "item" in instance:
                        categories.append(instance.get("item"))
            file_name = dir.get_next()
        dir.list_dir_end()
```

**约定**：子目录里**禁止**放和汇总文件同名的文件（会被过滤）。

#### B. 单个配置项文件（如 `SEO优化.gd`）

每个文件只描述一项配置，结构固定为：

```gdscript
# data/maintenance/SEO优化.gd
extends Node
## SEO优化
## 网站维护

var item = {
    "name": "SEO优化",            # 必填，名称（Utils.find_category_by_name 按此查找）
    "tip": "...",                  # 必填，玩家提示
    "category": "网站维护",        # 分类标签
    "content_type": "SEO",         # 子分类
    "isVisible": true,             # 是否在 UI 显示
    "disabled": true,              # 是否禁用（任务未解锁时为 true）
    "pressed": false,              # 默认未按下
    "money": 0,                    # 花费/收益
    "is_money": false,             # 是否产生金钱效果
    "stamina": 10,                 # 体力消耗/恢复
}
```

### 3. 各类数据的字段约定

> 下表列出**实际存在的关键字段**（基于代码核对每个 .gd 文件）。
> 通用字段（几乎所有 item 都有）：`name`, `tip`, `isVisible`, `disabled`, `money`, `stamina`。
> 注意：`pressed` 在 blog_categories / maintenance / recreation 中存在，但 **skills 中不存在**；
> `unlock_condition` 在 blog_categories / maintenance / skills 中存在，但 **recreation 中不存在**；
> `is_money` 仅在 blog_categories 和 maintenance 中存在，**recreation 和 skills 中没有**。

| 文件 | 顶层字段 | 数组字段 | 关键字段 |
|------|---------|---------|---------|
| `blog_categories/*.gd` | `item` | `categories` | `category`(文学/技术 — 字符串字面量), `content_type`(免费/付费/出版/周刊/连载/授权/开源), `is_money`, `article_level`(1-5), `unlock_condition`(条件 ID 字符串) / `unlock_post_tip`+`lock_post_tip`(替代字段), 业务型额外: `min_write_days`, `max_write_days`, `edit_days`, `publish_days`, `publish_reward`/`sponsor_reward`, `reputation_reward`, `presale_unlock_days` |
| `maintenance/*.gd` | `item` | `items` | `category`(网站维护), `content_type`(SEO/安全/互动/备案/设计/友链), `is_money`, `unlock_condition`(条件 ID 字符串) |
| `recreation/*.gd` | `item` | `items` | — （无 `is_money`、无 `unlock_condition`，仅含 name/tip/isVisible/disabled/pressed/money/stamina） |
| `skills/*.gd` | `item` | `items` | `skill_type`("literature"/"code" — 字面量, 区分文学/编程), `skill_level`(1-5), `unlock_at`(解锁所需能力值), `next_skill`(下一技能名, 最高级为 ""), `unlock_post_tip`, `lock_post_tip` |
| `lm_members.gd` | `lm_list` | - | 联盟成员 |
| `book_publish.gd` | `books`, `current_book_state`, `published_books` | - | 业务状态数据 |
| `ip_authorization.gd` | `current_ip_state` | - | 业务状态数据 |

### 4. 添加新数据项的步骤（以新增一个"博客分类"为例）

1. **创建配置文件**：`data/blog_categories/我的新分类.gd`
2. **填入 item 字典**，参考上面"单个配置项文件"格式
3. **设置初始状态**：`isVisible` 与 `disabled` 决定该分类是否对玩家可见/可用
4. **如需解锁任务**：在 `TaskConfig.gd` 的 `TASKS` 里添加一个 `UNLOCK_POST_TASK` 任务

文件**会被自动发现**（汇总脚本扫描目录），无需修改 `blog_categories.gd`。

### 5. 读取数据的方式

```gdscript
# ===== 方式 1：经 Utils（最常用）=====
var all_categories: Array = Utils.possible_categories      # Array[Dictionary]
var seo_item: Dictionary = Utils.find_category_by_name(Utils.website_maintenance, "SEO优化")

# ===== 方式 2：经 GDManager（拿到原始 Node）=====
var bc_node = GDManager.get_blog_categories()              # 返回 data/blog_categories.gd 实例
var categories_array = bc_node.categories
GDManager.reload_all_data()                                # 热重载所有数据

# ===== 方式 3：经 ConfigManager（拿到配置快照 StaticConfig）=====
var static_cfg = GDManager.get_config()                    # StaticConfig 实例
var skills: Array[Dictionary] = static_cfg.skills_config
```

### 6. 热重载数据

修改 `data/` 下任意 `.gd` 文件后，调用 `GDManager.reload_all_data()` 即可重载。
任务系统会自动通过 `_add_missing_tasks()` 兼容新加的任务（旧存档不丢）。

---

## 任务系统（如何创建/添加新任务）

任务系统是**数据驱动**的——几乎所有任务配置都在 `scripts/task_system/TaskConfig.gd` 一个文件里，
不需改逻辑代码就能加新任务。

### 1. 任务系统架构

```
玩家操作/信号  ─→  TaskManager  ─→  检查条件  ─→  执行动作
                       │
                       ├─ BookPublishManager  (出书业务)
                       ├─ OpenSourceManager   (开源业务)
                       └─ IPAuthManager       (IP授权业务)
```

- `TaskManager` 是单例（`TaskManager` autoload）
- 任务配置在 `TaskConfig.gd`：`TASKS` 数组 + `CONDITIONS` 字典 + `ActionType`/`ConditionType`/`CompareOp` 枚举
- 任务状态主存储在 `TaskManager.task_states`，通过 `reset_task_states()` 从 `TASKS` 复制一份带 `is_active`/`is_completed` 字段；副本同步到 `DataContainer → RuntimeData → TaskData.task_states`（用于存档）
- 任务执行入口：
  - **时间触发**：`main.gd:263` 在 `_on_day_ended()` 中调 `TaskManager.day_task_func()` → `check_tasks_by_trigger("time_check", {})`
  - **信号触发**：散落在三处（详见第 6 节）
  - **外部触发**：业务代码直接调 `TaskManager.check_tasks_by_trigger(trigger, ctx)`

### 2. 添加新任务的最小步骤（仅改配置）

#### 步骤 A：定义/复用触发类型

可选 trigger_type：
- `time_check`  （每日轮询，配合时间条件） — **已实现**
- `skill_up`    （技能升级信号）— **已实现**
- `level_up`    （玩家升级）— **已实现**
- `post_event`  （发布博文，配合 `post_type_filter`）— **已实现**
- `ad_income_paid`（广告佣金发放）— **已实现**
- `friendlink_added`（友链添加）— **已实现**
- `rss_subscribe` / `article_favorited` / `icp_filing_complete`（**配置已存在，但触发信号未连接，触发点为死代码**）
- `book_event` / `open_source_event`（**业务事件，目前在 TaskConfig.gd 中配置但全项目无任何 `check_tasks_by_trigger` 调用点，暂不可用**）

#### 步骤 B：定义/复用条件

编辑 `TaskConfig.gd` 中的 `CONDITIONS` 字典：

```gdscript
"my_new_condition": {
    "type": ConditionType.PLAYER_LEVEL,   # 条件类型
    "op": CompareOp.GE,                    # 比较运算符
    "value": 50,
}
```

`ConditionType` 可选：`SKILL_VALUE`/`SKILL_LEVEL`/`PLAYER_LEVEL`/`POST_COUNT`/`ARTICLE_COUNT`/`SEO_VALUE`/`TIME_MATCH`/`MILESTONE_COMPLETED`/`CUSTOM`。
`CompareOp` 可选：`EQ`/`NE`/`GT`/`GE`/`LT`/`LE`。
`CUSTOM` 走 `check_func` 字符串，函数定义在 `TaskManager` 上（参见 `_check_custom_condition`）。

#### 步骤 C：往 `TASKS` 数组追加任务

```gdscript
{
    "id": "my_new_task",                          # 唯一 ID
    "description": "我的新任务描述",              # 任务描述
    "conditions": ["my_new_condition"],            # 引用的条件 ID 列表
    "trigger_type": "time_check",                  # 触发类型
    "is_repeatable": false,                       # 是否每年/每日可重复
    "duration_days": false,                       # 长期任务标记（不立即置为完成）
    "post_type_filter": "",                       # 仅 post_event 需要
    "actions": [
        {"type": ActionType.UNLOCK_POST_TASK, "post_type": "我的新博文"},
        {"type": ActionType.SHOW_POPUP_NOTIFICATION,
         "title": "标题", "content": "内容"},
    ],
}
```

常用 `ActionType`：
- `UNLOCK_POST_TASK`（解锁博文类型）/ `LOCK_POST_TASK` / `HIDE_POST_TASK`
- `SKILL_LEVEL_UNLOCK` / `SKILL_LEVEL_LOCK`（解锁/锁定技能）
- `UNLOCK_WEBSITE_MAINTENANCE`（解锁网站维护项）
- `UNLOCK_MILESTONES_TASK`（解锁成就）
- `SET_STORY_MILESTONE`（设置剧情里程碑，给 chapter + milestone）
- `SHOW_NOTIFICATION`（信息条提示）/ `SHOW_POPUP_NOTIFICATION`（弹窗）
- `START_GAME_TIME`（开始游戏时间）/ `START_BOOK_WRITE` / `START_OPEN_SOURCE_PROJECT`
- `BOOK_PROGRESS` / `BOOK_PHASE_CHANGE` / `OPEN_SOURCE_PROGRESS` / `OPEN_SOURCE_ACQUISITION`
- `IP_MONTHLY_INCOME` / `TRIGGER_IP_AUTH` / `TRIGGER_ANIME_IP_AUTH`（动漫IP授权 — **ActionType 已定义但 TaskManager._execute_action() 的 match 中无对应分支，暂未生效**）
- `MODIFY_ATTRIBUTE` / `CHANGE_SCENE` / `CUSTOM_ACTION`（需自行扩展）
- `SET_ICP_FILING_NUMBER` / `SEO_NOTIFICATION` / `UPDATE_BLOG_UNION_BUTTON` / `REPLACE_POST_TREND`
- `UNLOCK_INITIAL_TASKS`（解锁初始 16 个任务选项：日常创作、网站维护、休闲娱乐、自律学习）

### 3. 完整示例（已存在于 `TaskConfig.gd`）

**示例 1：技能到达 60 解锁爆款网文**
```gdscript
{
    "id": "literature_post_unlock_60",
    "description": "文学能力值达到60，解锁爆款网文文章类型",
    "conditions": ["literature_value_ge_60"],
    "trigger_type": "skill_up",
    "is_repeatable": false,
    "actions": [
        {"type": ActionType.UNLOCK_POST_TASK, "post_type": "爆款网文"},
    ],
}
```

**示例 2：时间触发解锁年度总结博文（每年重复）**
```gdscript
{
    "id": "unlock_year_summary",
    "description": "每年12月份发布一次年度总结博文",
    "conditions": ["time_year_summary_unlock"],
    "is_repeatable": true,
    "trigger_type": "time_check",
    "duration_days": true,                          # 长期任务，标记而不完成
    "actions": [
        {"type": ActionType.UNLOCK_POST_TASK, "post_type": "年度总结"},
    ],
}
```

**示例 3：发布出版畅销书时累计写书进度（重复任务）**
```gdscript
{
    "id": "book_publish_progress",
    "description": "发布出版畅销书文章，累计进度",
    "conditions": [],
    "trigger_type": "post_event",
    "post_type_filter": "出版畅销书",               # 仅在发布该类型时触发
    "is_repeatable": true,
    "actions": [
        {"type": ActionType.BOOK_PROGRESS, "progress": 1},
    ],
}
```

### 4. 添加自定义动作（需改逻辑代码）

如果现有 `ActionType` 满足不了需求：
1. 在 `TaskConfig.gd` 的 `enum ActionType` 中加新枚举值
2. 在 `TaskManager._execute_action()` 的 `match` 中加一个分支
3. 在 `TaskManager` 上加 `_action_xxx(action: Dictionary)` 方法

### 5. 添加自定义条件检查

1. 在 `TaskConfig.gd` 的 `CONDITIONS` 里用 `{"type": ConditionType.CUSTOM, "check_func": "my_check"}`
2. 在 `TaskManager` 上定义 `func my_check(context: Dictionary) -> bool`

参考现有：`check_blog_union_not_joined`、`check_book_writing`、`check_open_source_project` 等。

### 6. 触发任务的"信号 → TaskManager"路径

实际信号连接**分散在三处**，没有统一入口：

**A. `TaskManager._connect_signals()`（TaskManager.gd:77-81）** 自动连 3 个 Blogger 信号：
```gdscript
Blogger.connect("sg_new_blog_post", _on_blog_post)   # → post_event
Blogger.connect("s_level", _on_level_up)              # → level_up
Blogger.connect("skill_level_up", _on_skill_level_up) # → skill_up
```

**B. `main.gd:22` 业务代码直接连 AdManager 信号**：
```gdscript
AdManager.connect("sig_ad_commission_paid", TaskManager._on_ad_income_paid)
# → ad_income_paid
```

**C. `main.gd:84, 425-427` 业务代码自己处理后转发**：
```gdscript
FriendLinkManager.connect("link_added", _on_friend_link_added)
# → friendlink_added
```

**D. `_on_rss_first_subscriber` / `_on_article_first_favorited` / `_on_icp_filing_complete`**
在 `TaskManager.gd:186-195` 存在但**没有任何代码 connect**，对应 trigger 实际不触发。

新加信号触发的任务时，根据是否需要改 `TaskManager._connect_signals` 来选择路径：
- 想统一管理：在 `TaskManager._connect_signals()` 加 `Blogger.connect("新信号", _on_xxx)`，并在 `TaskManager` 上加 `_on_xxx(...)` 函数，内部调 `check_tasks_by_trigger(...)`
- 想在业务模块自己管控：在调用点（如 `main.gd`）直接 connect 信号到 TaskManager 的 `_on_xxx`，或者业务处理函数里调 `TaskManager.check_tasks_by_trigger(trigger, ctx)`

### 7. 任务系统信号（用于 UI 反馈）

任务执行时 TaskManager 会发：
- `sg_task_info_display_msg(msg)` 信息条提示
- `sg_task_show_popup_msg(title, content)` 弹窗提示
- `schedule_refresh_needed` 日程面板需刷新

`main.gd` 已连接这三个信号，无需手动接。

---

## 常用操作

| 操作 | 方法 |
|------|------|
| 运行游戏 | Godot 4.6 打开项目后按 F5 |
| 编辑场景 | Godot 4.6 双击 .tscn 文件 |
| 修改代码 | Godot 内置编辑器或 VS Code |
| 热重载数据 | 修改 `data/` 下的 `.gd` 文件后调用 `GDManager.reload_all_data()` |
| 热重载配置 | `ConfigManager.reload_configs()` |
| 热重载任务 | `TaskManager.reset_task_states()`（会自动通过 `_add_missing_tasks` 兼容） |

## 代码规范

- 使用 `.gd.uid` 文件管理资源 UID
- 信号命名：`signal xxx_changed`
- 常量：`const XXX = value`
- 枚举：`enum xxx { A, B, C }`
- 管理类系统采用"策略设置+日程驱动"模式
- **不要在已有逻辑里加临时条件分支**，新功能优先走任务系统

## 数据存档

- 位置：`~/.local/share/godot/app_userdata/MyBlogGame/`
- 格式：JSON
- 备份：上述目录下的所有 .json 文件

## 设计偏好（爸爸的）

- 倾向最小改动方案，不喜欢大规模修改多个文件
- 倾向"日程驱动"玩法，功能通过定时日程自动管理
- 喜欢精简系统，删除不必要的复杂度（如好感度系统）
- 能快速发现设计逻辑错误（如"高等级友链申请应该欢迎而非拒绝"）
- 新功能优先通过**数据 + 任务配置**实现，而不是写新逻辑
