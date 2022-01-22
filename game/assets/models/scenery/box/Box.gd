tool
extends Spatial

const breakable_box_material: ShaderMaterial = preload("res://assets/models/scenery/box/materials/breakable_box.material")

export (bool) var breakable: = false setget set_breakable


func set_breakable(val: bool) -> void:
	breakable = val
	update_material()


func _ready() -> void:
	update_material()


func update_material() -> void:
	if not is_inside_tree():
		return
	
	if breakable:
		$Cube.material_override = breakable_box_material
	else:
		$Cube.material_override = null
