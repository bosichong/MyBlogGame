# AGENTS.md — MyBlogGame

Godot 4.7 GDScript 博客模拟经营游戏。

## 关键命令

```bash
# 运行测试（Godot headless 模式）
godot --headless -s tests/test_book_publish.gd
godot --headless -s tests/test_chapter_reward.gd

# 运行游戏（编辑器内按 F5）
```

> 无 lint/typecheck/codegen 工具链。唯一验证方式是在 Godot 编辑器中运行或执行测试脚本。

## Autoload 单例（按 project.godot 声明顺序加载）

| 名称 | 来源 | 用途 |
|------|------|------|
| GDManager | `scripts/GlobalDataManager.gd` | 顶层数据入口（信号/存档/热重载） |
| TimerManager | `scripts/timer_manager.gd` | 计时器（年/月/周/天推进） |
| Blogger | `scripts/blogger.gd` | 玩家博客数据 + 博文发布信号 |
| Utils | `scripts/utils.gd` | 数据快捷访问 + `goto_scene()` 等 |
| Strs | `scripts/strings.gd` | 字符串常量 |
| AdManager | `scripts/ad_manager.gd` | 广告联盟 |
| Tongji | `scripts/tongji.gd` | 数据统计 |
| Lm | `scripts/bloglm.gd` | 博客联盟 |
| Bs | `scripts/BankSystem.gd` | 银行系统 |
| Yun | `scripts/yun.gd` | 主机/域名/备案 |
| TaskManager | `scripts/task_system/TaskManager.gd` | 任务系统入口（数据驱动） |
| AwardManager | `scripts/managers/AwardManager.gd` | 优秀博客大赛奖项判定 |

> `Utils._init()` 在 `GDManager._init()` 之后执行（autoload 顺序保证）。

## 入口与场景切换

- 入口场景：`res://scenes/main.tscn`（`run/main_scene`）
- 场景切换：`Utils.goto_scene(path)`
- 场景列表：`scenes/` 下含主场景（日程、博客后台、联盟、银行等）及章节子目录

## 数据系统

```
data/*.gd ──→ GDManager._load_all_data() ──→ loaded_data 字典
                                                  ↓
                                         Utils / ConfigManager
```

- `data/` 下 `.gd` 文件分两类：
  - **子目录汇总型**（`blog_categories.gd` 等）：扫描子目录收集 `item` 字典
  - **单项配置**（单个 `.gd` 文件）：每个含 `item` 字典（name/tip/category/isVisible/disabled/money/stamina 等）
- 扩展数据配置：`book_publish.gd`、`open_source_project.gd`、`ip_authorization.gd`、`ip_companies.gd`、`lm_members.gd`、`publishers.gd`、`comment_templates.gd`、`title_templates.gd`、`yearly_summary_template.gd`、`website_maintenance.gd`
- 子目录包括：`blog_categories/`（47 种分类）、`maintenance/`（20 项运维）、`recreation/`（14 项娱乐）、`skills/`（20 项技能）
- 修改 `data/` 后调 `GDManager.reload_all_data()` 热重载，无需重启
- .gd.uid 文件自动管理资源 UID
- 存档：`~/.local/share/godot/app_userdata/MyBlogGame/`（JSON 格式）

## 核心数值

| 项 | 值 |
|----|-----|
| SEO 上限 | 200（clamp），友链贡献 ≤ 20 |
| 付费订阅价格 | 9.9 元，5% 访问量 → 订阅 |
| 付费结算 | 月末触发，按月累计入账 |
| 玩家等级上限 | 100 |
| 技能等级上限 | 100 |

## BloggerData 关键属性

`BloggerData.gd` 是玩家存档核心，除基础属性（等级/经验/金钱/体力/能力值）外，以下属性用于系统判定的关键计数器：

| 属性 | 类型 | 说明 | 递增位置 |
|------|------|------|----------|
| `book_publish_count` | `int` | 已出版畅销书累计数 | `BookPublishManager._complete_book_publish()` |
| `open_source_count` | `int` | 已发布开源项目累计数 | `OpenSourceManager._complete_os_project()` |
| `novel_batch` | `int` | 小说连载当前批次 | 每日结算 |
| `hacker_batch` | `int` | 黑客攻防当前批次 | 每日结算 |

> 以上计数器随 `serialize_blogger_data()` 自动存读档，无需额外处理。第五章结局判定通过 `TaskConfig.gd` 的 `CUSTOM` 条件函数读取。

## 任务系统（数据驱动）

配置在 `scripts/task_system/TaskConfig.gd` 的 `TASKS` 数组 + `CONDITIONS` 字典。

### 可用的 trigger_type

| trigger | 状态 |
|---------|------|
| `time_check` / `skill_up` / `level_up` / `post_event` / `ad_income_paid` / `friendlink_added` | ✅ `TaskManager._connect_signals()` / 外部连接 |
| `rss_subscribe` / `article_favorited` | ✅ `blogger.gd` 每日结算直接调用 |
| `icp_filing_complete` / `mobile_adapt_complete` / `https_upgrade_complete` / `cdn_accelerate_complete` | ✅ `main.gd` 管理（网站运维完成后调用） |
| `book_publish_complete` / `open_source_complete` | ✅ `BookPublishManager` / `OpenSourceManager` 完成时调用 |
| `novel_batch_complete` / `novel_ip_authorized` / `hacker_course_complete` / `hacker_course_authorized` | ✅ 外部调用 |
| `book_event` / `open_source_event` | ❌ 无调用点 |

### 信号→TaskManager 连接路径

1. **TaskManager._connect_signals()**：自动连 Blogger 的 `sg_new_blog_post` / `s_level` / `skill_level_up`
2. **main.gd**：连接 `AdManager.sig_ad_commission_paid` / 网站运维完成信号 / `FriendLinkManager.link_added` → 各 `_on_*` 方法
3. **BookPublishManager** / **OpenSourceManager**：完成时直接调用 `_on_book_publish_complete()` / `_on_open_source_complete()`
4. **blogger.gd** 每日结算：调用 `_on_rss_first_subscriber()` / `_on_article_first_favorited()`

### 条件类型

`SKILL_VALUE` / `SKILL_LEVEL` / `PLAYER_LEVEL` / `POST_COUNT` / `ARTICLE_COUNT` / `SEO_VALUE` / `TIME_MATCH` / `MILESTONE_COMPLETED` / `CUSTOM`

### 常用动作类型

`UNLOCK_POST_TASK` / `LOCK_POST_TASK` / `SKILL_LEVEL_UNLOCK` / `SHOW_NOTIFICATION` / `SHOW_POPUP_NOTIFICATION` / `SET_STORY_MILESTONE` / `CHANGE_SCENE`

以及子模块委托：`START_BOOK_WRITE`→`BookPublishMgr`、`TRIGGER_IP_AUTH` / `IP_MONTHLY_INCOME`→`IPAuthMgr`、`START_OPEN_SOURCE_PROJECT`→`OpenSourceMgr`

> `TRIGGER_ANIME_IP_AUTH` 枚举已定义但 `_execute_action()` 无对应分支。

## 新增功能原则

- 优先改 **数据配置**（`data/`）和 **任务配置**（`TaskConfig.gd`），而非逻辑代码
- 不在已有逻辑里加临时条件分支
- 倾向"日程驱动"玩法，功能通过定时日程自动管理
- 倾向最小改动方案

## 热重载速查

| 操作 | 调用 |
|------|------|
| 重载所有数据 | `GDManager.reload_all_data()` |
| 重载配置 | `ConfigManager.reload_configs()` |
| 重载任务 | `TaskManager.reset_task_states()` |

## 代码约定

- 信号：`signal xxx_changed`
- 常量：`const XXX = value`
- 枚举：`enum xxx { A, B, C }`
