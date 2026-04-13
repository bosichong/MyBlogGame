extends Node

## 小说连载（付费）
## 博客类型：文学 - 付费
## 解锁条件：文学能力达到80级

var item = {
    "name": "小说连载(付费)",
    "tip": "文学80级解锁。每部小说连载100篇后自动换新小说，≥50篇时有机会触发IP授权！",
    "unlock_condition": "literature_value_ge_80",
    "type": "文学",
    "type1": "付费",
    "isVisible": false,
    "disabled": true,
    "pressed": false,
    "money": 0,
    "is_money": true,
    "stamina": 30,
}