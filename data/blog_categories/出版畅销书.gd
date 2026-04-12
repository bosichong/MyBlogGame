extends Node

## 出版畅销书
## 博客类型：文学 - 出版
## 解锁条件：文学能力达到100级

var item = {
    "name": "出版畅销书",
    "tip": "文学能力达到100级后解锁，开始创作畅销书，持续写作半年(168天)后可出版上市！",
    "unlock_condition": "literature_value_ge_100",
    "type": "文学",
    "type1": "出版",
    "isVisible": false,
    "disabled": true,
    "pressed": false,
    "money": 0,
    "is_money": true,
    "stamina": 100,
    "min_write_days": 168,
    "max_write_days": 336,
    "edit_days": 5,
    "publish_days": 7,
    "publish_reward": 50000,
    "reputation_reward": 1000,
}