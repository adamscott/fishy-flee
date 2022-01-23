extends Node

signal godot_splash_finished

const ResourceQueue: = preload("res://scripts/resource_queue.gd")
const WaitForSplashFinish: = preload("res://scripts/wait_for_splash_finish.gd")

var queue: ResourceQueue

onready var wait_for_splash_finish: WaitForSplashFinish = $WaitForSplashFinish


func _on_WaitForSplashFinish_godot_splash_finished() -> void:
	emit_signal("godot_splash_finished")


func _ready() -> void:
	init_resource_queue()


func init_resource_queue() -> void:
	queue = ResourceQueue.new()
	queue.start()
