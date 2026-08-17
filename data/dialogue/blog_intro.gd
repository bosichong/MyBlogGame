extends Node

## 第一章剧情对白：什么是博客？
## 玩家向莫比乌斯请教博客的意义

var dialogue = {
    "id": "blog_intro",
    "title": "什么是博客？",
    "auto_interval": 4.0,
    "background": "",
    "after_finish": "",
    "lines": [
        {"speaker": "player", "text": "老莫！什么是博客？"},
        {"speaker": "莫比乌斯", "text": "博客啊……简单说，就是一块你自己的地皮，随你种什么。"},
        {"speaker": "player", "text": "地皮？像论坛那样发帖子不行吗？"},
        {"speaker": "莫比乌斯", "text": "不一样。论坛是菜市场，人来人往，一转头你的摊子就被淹没了。"},
        {"speaker": "莫比乌斯", "text": "博客是你自己的书房。别人爱来不来，来的都是客，走的都是缘。"},
        {"speaker": "player", "text": "听起来……有点孤独。"},
        {"speaker": "莫比乌斯", "text": "写作本来就是一场孤独的自我悖驳。我写自己的生活，也写自己的讣告。"},
        {"speaker": "player", "text": "讣告？！你这说的是什么话！"},
        {"speaker": "莫比乌斯", "text": "呵，博客不是写给别人的，是写给时间的。哪怕有一天我不在了，那些字还在网上漂着。"},
        {"speaker": "player", "text": "……这样啊。"},
        {"speaker": "莫比乌斯", "text": "所以，别问博客是什么。去写，写够了，你就知道它是什么了。", "end": true},
    ],
}
