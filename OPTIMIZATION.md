# MyBlogGame 代码优化计划

> 生成日期：2026-03-25
> 代码规模：39 个脚本，共 6727 行

---

## 优化清单

### 🔴 高优先级（影响维护性）

#### 1. 代码重复严重

**位置**：`scripts/days/d_1.gd` ~ `d_7.gd`

**问题**：7 个文件几乎一模一样，只是 `KEY` 常量不同（0-6）

**建议**：合并成 1 个脚本，通过场景参数传入 KEY

**改动范围**：
- 删除 `d_1.gd` ~ `d_7.gd`（7 个文件）
- 创建 `day_panel.gd`（1 个文件）
- 修改 `scenes/日程.tscn` 中的脚本引用

**风险**：低

---

#### 2. utils.gd 太臃肿

**位置**：`scripts/utils.gd`（1071 行）

**问题**：职责混杂，包含：
- 数据定义（`possible_categories`、`website_maintenance` 等）
- UI 创建方法（`create_checkbox`、`add_checkbox` 等）
- 工具方法（`format_date`、`calculate_post_views` 等）
- 业务逻辑（`decrease_blog_views` 等）

**建议**：拆分成多个文件
- `data/categories.gd` — 博客类型、技能等数据定义
- `data/recreation.gd` — 休闲娱乐数据
- `utils/ui_helper.gd` — UI 创建方法
- `utils/utils.gd` — 通用工具方法

**风险**：中（需要修改多处引用）

---

#### 3. 注释掉的旧代码

**位置**：
- `scripts/calendar.gd` — 整个文件都是注释
- 其他文件中零散的注释代码块

**问题**：有 Git 做版本控制，不需要保留注释掉的代码

**建议**：删除所有注释掉的旧代码

**风险**：极低

---

### 🟡 中优先级（影响可读性）

#### 4. 硬编码字符串

**位置**：各处

**问题**：`"生活日记"`、`"安全维护"`、`"休息"` 等字符串到处写

**建议**：用常量或枚举定义

```gdscript
# 改前
if task == "安全维护":

# 改后
const TASK_SECURITY = "安全维护"
if task == TASK_SECURITY:
```

**风险**：低

---

#### 5. 魔法数字

**位置**：各处

**问题**：`stamina += 5`、`return 10` 等数字没说明含义

**建议**：用常量定义并注释

```gdscript
# 改前
stamina += 5

# 改后
const REST_STAMINA_BONUS = 5  # 休息恢复的体力值
stamina += REST_STAMINA_BONUS
```

**风险**：低

---

#### 6. 命名不一致

**位置**：各处

**问题**：
- 中英文混用：`blog_calendar` vs `t_d`
- 缩写不一致：`tmp_v` vs `temporary_value`
- 风格不统一：`s_level`（信号）vs `signal_level`

**建议**：制定命名规范
- 变量：蛇形命名 `blog_calendar`
- 常量：全大写 `MAX_LEVEL`
- 信号：`signal_` 前缀或 `_changed` 后缀

**风险**：低（纯重命名，不改变逻辑）

---

### 🟢 低优先级（锦上添花）

#### 7. 信号连接方式

**位置**：`scripts/task_system/TaskManager.gd` 等

**问题**：使用 `connect()` 旧写法

```gdscript
# 当前写法
Blogger.connect("sg_new_blog_post", check_new_blog_post)

# Godot 4.0+ 推荐写法
Blogger.sg_new_blog_post.connect(check_new_blog_post)
```

**建议**：逐步更新为 Godot 4 的新写法

**风险**：低

---

#### 8. 缺少类型注解

**位置**：部分函数

**问题**：返回值和参数没有类型注解

```gdscript
# 改前
func get_exp_for_next_level():

# 改后
func get_exp_for_next_level() -> int:
```

**建议**：逐步添加类型注解

**风险**：极低

---

## 建议的优化顺序

| 步骤 | 内容 | 预计耗时 | 风险 |
|------|------|----------|------|
| 1 | 删除注释掉的旧代码 | 5 分钟 | 极低 |
| 2 | 合并 `d_1.gd` ~ `d_7.gd` | 15 分钟 | 低 |
| 3 | 提取硬编码字符串为常量 | 10 分钟 | 低 |
| 4 | 提取魔法数字为常量 | 10 分钟 | 低 |
| 5 | 拆分 `utils.gd` | 30 分钟 | 中 |
| 6 | 统一命名规范 | 20 分钟 | 低 |
| 7 | 更新信号连接方式 | 15 分钟 | 低 |
| 8 | 添加类型注解 | 30 分钟 | 极低 |

---

## 注意事项

1. **每完成一步，提交一次 Git**，方便回滚
2. **每次只做一件事**，不要同时改动多个部分
3. **改完测试游戏**，确保功能正常
4. **标记已完成的步骤**，方便追踪进度

---

## 进度追踪

- [ ] 步骤 1：删除注释掉的旧代码
- [ ] 步骤 2：合并 `d_1.gd` ~ `d_7.gd`
- [ ] 步骤 3：提取硬编码字符串为常量
- [ ] 步骤 4：提取魔法数字为常量
- [ ] 步骤 5：拆分 `utils.gd`
- [ ] 步骤 6：统一命名规范
- [ ] 步骤 7：更新信号连接方式
- [ ] 步骤 8：添加类型注解