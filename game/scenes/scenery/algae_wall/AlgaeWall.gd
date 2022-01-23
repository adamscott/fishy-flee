extends Spatial

onready var wall: StaticBody = $Wall
onready var disable_collision_area: Area = $DisableCollisionArea

func _on_DisableCollisionArea_body_entered(body: Node) -> void:
	if body is CollisionObject:
		wall.add_collision_exception_with(body)


func _on_DisableCollisionArea_body_exited(body: Node) -> void:
	if body is CollisionObject:
		wall.remove_collision_exception_with(body)


func _ready() -> void:
	pass

