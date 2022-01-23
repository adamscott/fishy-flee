extends Node

signal godot_splash_finished

const ResourceQueue: = preload("res://scripts/resource_queue.gd")
const WaitForSplashFinish: = preload("res://scripts/wait_for_splash_finish.gd")

var loading_value: float setget set_loading_value, get_loading_value

var queue: ResourceQueue
var main: Node

onready var wait_for_splash_finish: WaitForSplashFinish = $WaitForSplashFinish


func set_loading_value(val: float) -> void:
	main.loading.value = val


func get_loading_value() -> float:
	return main.loading.value


func _on_WaitForSplashFinish_godot_splash_finished() -> void:
	emit_signal("godot_splash_finished")


func _ready() -> void:
	init_resource_queue()


func init_resource_queue() -> void:
	queue = ResourceQueue.new()
	queue.start()


func display_loading() -> void:
	main.loading.visible = true


func hide_loading() -> void:
	main.loading.visible = false

