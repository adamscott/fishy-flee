tool
extends Spatial

export (bool) var shadow: = true setget set_shadow


func set_shadow(val: bool) -> void:
	shadow = val
	
	if is_inside_tree():
		$Shadow.visible = shadow


func _ready() -> void:
	set_shadow(shadow)
