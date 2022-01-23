# https://github.com/godotengine/godot/issues/30723#issuecomment-865786917
extends Node

signal godot_splash_finished


func _ready() -> void:
	var pss = poll_splash_screen()


func poll_splash_screen() -> void:
	yield(get_tree().create_timer(0.001), "timeout")
	emit_signal("godot_splash_finished")
	queue_free()
