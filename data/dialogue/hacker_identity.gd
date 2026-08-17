extends Node

## 第一章剧情对白：黑客O的身份
## 玩家追问黑客O的真实身份，连猜数个身份

var dialogue = {
    "id": "hacker_identity",
    "title": "你是谁？",
    "auto_interval": 4.0,
    "background": "",
    "after_finish": "",
    "lines": [
        {"speaker": "player", "text": "O，你到底是谁？"},
        {"speaker": "黑客O", "text": "我是谁，很重要吗？"},
        {"speaker": "player", "text": "你技术这么强，又神神秘秘的……我猜，你是个程序员？"},
        {"speaker": "黑客O", "text": "算沾点边，但那是上辈子的事了。"},
        {"speaker": "player", "text": "那就是……黑客？专门黑别人网站那种？"},
        {"speaker": "黑客O", "text": "呵，黑客只是业余爱好。严格来说，我是个逆向工程师。"},
        {"speaker": "player", "text": "逆向工程师？听着像拆炸弹的。"},
        {"speaker": "黑客O", "text": "也差不多。别人写的程序，我负责把它拆开，看里面藏了什么。"},
        {"speaker": "player", "text": "那……拆完呢？"},
        {"speaker": "黑客O", "text": "拆完就写篇博客记录心得。咱们做博主的，不都这样？"},
        {"speaker": "player", "text": "所以你其实是个……程序媛？"},
        {"speaker": "黑客O", "text": "嗯……最后一个答案，倒是猜中了。", "end": true},
    ],
}
