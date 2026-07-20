extends Node

## 游戏发布 - 从测试到上市
## 完成游戏开发后解锁
## 共3阶段×10天=30个任务周期
## 阶段：测试→预告发布→正式发布

var item = {
    "name": "游戏发布",
    "tip": "完成游戏开发后解锁。\n共3阶段×10天：测试→预告发布→正式发布\n让你的作品与玩家见面！\n通往游戏结局的最后一步！",
    "unlock_condition": "game_dev_completed",
    "category": "技术",
    "content_type": "付费",
    "isVisible": false,
    "disabled": true,
    "pressed": false,
    "money": 1000,
    "is_money": true,
    "stamina": 80,
    "article_level": 5,
    "cooldown_days": 100,
    "min_write_days": 30,
}
