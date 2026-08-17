extends Node

## 第一章剧情对白：博客主题设计
## 玩家让孤斗评价自己新设计的极简白色主题

var dialogue = {
    "id": "theme_review",
    "title": "主题设计",
    "auto_interval": 4.0,
    "background": "",
    "after_finish": "",
    "lines": [
        {"speaker": "player", "text": "孤斗，你帮我看看，我这博客主题设计得怎么样？"},
        {"speaker": "孤斗", "text": "哦？新改的？我看看……"},
        {"speaker": "player", "text": "极简白色背景，干干净净，就一个 logo 一排导航。"},
        {"speaker": "孤斗", "text": "……就这？"},
        {"speaker": "孤斗", "text": "你这主题是性冷淡主题吗？"},
        {"speaker": "player", "text": "性、性冷淡？！这叫极简主义！"},
        {"speaker": "孤斗", "text": "极简是克制，不是空白。你这叫懒得设计。"},
        {"speaker": "player", "text": "……那你说怎么办？"},
        {"speaker": "孤斗", "text": "加个漂亮的渐变色块，标题来点衬线字体，留白里放点小心思。"},
        {"speaker": "孤斗", "text": "记住：空白是呼吸的地方，不是偷懒的地方。", "end": true},
    ],
}
