extends Node

## 年度总结弹窗内容模板
## 使用 {key} 占位符，会被 YearlySummaryFormatter 替换

const YEARLY_SUMMARY_TEMPLATE = """📊 今年数据变化（vs {year}年初）
━━━━━━━━━━━━━━━━━━━━━━━━━
📈 等级：{level_before} → {level_after}（{level_change}）
💰 资产：{money_before} → {money_after}（{money_change}）
👀 总访问量：{views_before} → {views_after}（{views_change}）
📨 RSS订阅：{rss_before} → {rss_after}（{rss_change}）
⭐ 文章收藏：{favorites_before} → {favorites_after}（{favorites_change}）

📝 今年发布了 {posts_total} 篇文章
{posts_categories}

🏆 这一年你辛苦了！继续加油！
"""
