# 博客游戏 (MyBlogGame)

用 Godot 4.2 开发的可玩博客模拟经营游戏，玩家扮演博主经营自己的博客。

## 技术栈

- **引擎**: Godot 4.2
- **语言**: GDScript
- **存档**: JSON 文件（SaveManager）
- **UID 管理**: `.gd.uid` 文件

## 项目结构

```
MyBlogGame/
├── assets/              # 图片、字体等静态资源
├── data/                # 游戏数据（可热重载的配置数据）
│   ├── blog_categories/ # 博客分类配置（按分类名的独立 .gd 文件）
│   ├── maintenance/     # 网站维护日程配置
│   │   ├── SEO优化.gd
│   │   ├── 安全维护.gd
│   │   ├── 评论管理.gd
│   │   └── 友情链接维护.gd
│   ├── recreation/       # 娱乐活动配置
│   ├── skills/           # 技能配置
│   ├── blog_categories.gd
│   ├── book_publish.gd
│   ├── ip_authorization.gd
│   ├── ip_companies.gd
│   ├── lm_members.gd     # 联盟成员配置
│   ├── open_source_project.gd
│   ├── publishers.gd
│   ├── recreation.gd
│   ├── title_templates.gd
│   └── website_maintenance.gd
├── milestones/          # 成就系统
│   ├── main.gd
│   ├── mile.gd
│   └── config.gd
├── scenes/               # Godot 场景文件 (.tscn)
│   ├── s001/ ~ s004/    # 子场景
│   ├── main.tscn
│   ├── blog_dashboard.tscn
│   └── ...
├── scripts/              # GDScript 脚本
│   ├── 日程.gd           # 日程驱动系统
│   ├── timer_manager.gd  # 计时器管理
│   ├── blogger.gd        # 博主核心逻辑（~43KB，最大文件）
│   ├── blog_dashboard.gd # 博客仪表板
│   ├── tongji.gd         # 统计系统
│   ├── yun.gd / yun_main.gd # 运营系统
│   ├── BankSystem.gd / bank_main.gd # 银行系统
│   ├── ad_manager.gd / ad.gd # 广告系统
│   ├── bloglm.gd / lm_mian.gd # 联盟系统
│   ├── GlobalDataManager.gd # 全局数据管理
│   ├── managers/         # 管理器
│   │   ├── SaveManager.gd    # 存档管理（~15KB）
│   │   ├── ConfigManager.gd
│   │   └── FriendLinkManager.gd
│   ├── task_system/      # 任务系统
│   │   ├── TaskManager.gd       # 任务管理（~22KB）
│   │   ├── TaskConfig.gd         # 任务配置（~36KB）
│   │   ├── BookPublishManager.gd
│   │   ├── OpenSourceManager.gd
│   │   └── IPAuthManager.gd
│   └── views/            # UI 视图
│       └── modifiers/    # 属性修饰器（SEOBaseModifier 等）
├── tests/                # 单元测试
│   └── test_book_publish.gd
└── project.godot         # 项目配置
```

## 核心概念

### 日程驱动系统
游戏采用**日程驱动**模式：玩家在管理面板设置自动处理规则，维护日程按规则自动执行。无需手动操作面板，功能通过定时日程管理。

### 数据文件格式
`data/` 目录下的 `.gd` 文件（如 `SEO优化.gd`）是配置数据文件，格式为 GDScript：
```gdscript
extends Node
var item = {
    "name": "SEO优化",
    "tip": "...",
    "type": "网站维护",
    "stamina": 10,
    ...
}
```

### SEO 系统
- SEO 值最高 200（blogger.gd 中 clamp 上限）
- 友链 SEO 贡献上限为 20（占比 10%）
- SEO 值过低会导致博客失去来自搜索引擎的基础访问量

### 付费文章系统
- 订阅价格固定 9.9 元，5% 访问量转化为订阅人数
- 按周结算，收入 = 订阅人数 × 订阅价格

### 能力等级
- 最高等级：`const MAX_LEVEL = 100`
- 技能最高等级：`const MAX_SKILL_LEVEL = 100`
- 核心属性：写作能力、技术能力、文学能力、编程能力

## 常用操作

| 操作 | 方法 |
|------|------|
| 运行游戏 | Godot 4.2 打开项目后按 F5 |
| 编辑场景 | Godot 4.2 双击 .tscn 文件 |
| 修改代码 | Godot 内置编辑器或 VS Code |
| 热重载数据 | 修改 `data/` 下的 `.gd` 文件后重载即可，无需重启游戏 |

## 代码规范

- 使用 `.gd.uid` 文件管理资源 UID
- 信号命名：`signal xxx_changed`
- 常量：`const XXX = value`
- 枚举：`enum xxx { A, B, C }`
- 管理类系统采用"策略设置+日程驱动"模式

## 数据存档

- 位置：`~/.local/share/godot/app_userdata/MyBlogGame/`
- 格式：JSON
- 备份：上述目录下的所有 .json 文件

## 设计偏好（爸爸的）

- 倾向最小改动方案，不喜欢大规模修改多个文件
- 倾向"日程驱动"玩法，功能通过定时日程自动管理
- 喜欢精简系统，删除不必要的复杂度（如好感度系统）
- 能快速发现设计逻辑错误（如"高等级友链申请应该欢迎而非拒绝"）
