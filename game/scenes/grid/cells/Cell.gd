extends KinematicBody
class_name Cell

signal updated_position(pos)

export (int) var id: = -1
export (Vector2) var position: = Vector2.ZERO setget set_position

onready var tween: Tween = $Tween as Tween


func set_position(val: Vector2) -> void:
	position = val
	update()
	emit_signal("updated_position", val)


func _ready() -> void:
	assert(id != -1)
	assert(tween != null)


func update() -> void:
	if Engine.editor_hint:
		return
	
	tween.interpolate_property(self, "translation", transform.origin, Vector3(position.x, -position.y, 0), 0.2)
	tween.start()
