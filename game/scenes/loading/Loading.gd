extends Control

export (float) var value: float setget set_value


func set_value(val: float) -> void:
	value = val
	$MarginContainer/ProgressBar.value = val


func _ready() -> void:
	pass
