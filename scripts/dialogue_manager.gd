extends Node

## 对话系统入口
## 提供 play(id) 播放入口与对白结束信号

const DIALOGUE_SCENE_PATH = "res://scenes/dialogue.tscn"

## 当前播放的对白 id（由 dialogue.gd 读取）
var current_id: String = ""

## 是否由调试试用场景发起（结束时回到调试面板）
var from_test: bool = false

## 刚从对白场景返回调试面板（用于测试场景判断是否再次自动播放）
var return_from_dialogue: bool = false

## 对白正常播完（且无 after_finish）时发出
signal dialogue_finished(id: String)

## 播放指定对白：跳转到对话场景
func play(id: String, tester: bool = false) -> void:
	current_id = id
	from_test = tester
	Utils.goto_scene(DIALOGUE_SCENE_PATH)

## 通知对白结束
func notify_finished(id: String) -> void:
	dialogue_finished.emit(id)