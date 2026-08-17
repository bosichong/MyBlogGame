extends Node

## 示例多人对话（调试用）
## 包含普通行自动推进、玩家选项分支、标签跳转

var dialogue = {
    "id": "example",
    "title": "联盟初见",
    "auto_interval": 3.0,
    "background": "",
    "after_finish": "",
    "lines": [
        {"speaker": "莫比乌斯", "text": "你终于来了！我们都等你很久了。"},
        {"speaker": "黑客O", "text": "欢迎新博主！你的博客我早就关注了。"},
        {"speaker": "莫比乌斯", "text": "要加入我们的联盟圈子吗？"},
        {
            "speaker": "莫比乌斯", "text": "怎么样，考虑一下？",
            "choices": [
                {"text": "当然要！求之不得", "next": "join"},
                {"text": "先看看再说", "next": "decline"},
            ],
        },
        {"label": "join", "speaker": "player", "text": "当然要！求之不得！"},
        {"label": "join", "speaker": "莫比乌斯", "text": "太好了，欢迎欢迎！"},
        {"label": "join", "speaker": "黑客O", "text": "以后多多关照！", "end": true},
        {"label": "decline", "speaker": "player", "text": "我再考虑考虑吧……"},
        {"label": "decline", "speaker": "黑客O", "text": "没关系，随时欢迎你来~", "end": true},
    ],
}
