extends Node

## 评论管理
## 网站维护
## 解锁条件：收到第一条评论时解锁

var item = {
    "name": "评论管理",
    "tip": "管理博客评论，良好的互动会增加博客的知名度和访问量。收到第一条评论后解锁。",
    "unlock_condition": "has_first_comment",
    "category": "网站维护",
    "content_type": "互动",
    "isVisible": true,
    "disabled": true,
    "pressed": false,
    "money": 0,
    "is_money": false,
    "stamina": 10,
}