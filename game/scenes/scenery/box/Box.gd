tool
extends KinematicBody

export (bool) var breakable: = false setget set_breakable


func set_breakable(val: bool) -> void:
	breakable = val
	$Box.breakable = breakable
	
	if breakable:
		add_to_group("breakable")
	else:
		remove_from_group("breakable")


func _ready() -> void:
	pass


func break_self() -> void:
	$CollisionShape.disabled = true
	$AnimationPlayer.play("break")
