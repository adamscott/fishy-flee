extends Camera

export (NodePath) var _target: NodePath setget set_target_path
var target: Spatial
export (float) var distance: = 3.0
export (float) var speed: = 5.0
export (Vector3) var forward: = Vector3.FORWARD


func set_target_path(val: NodePath) -> void:
	_target = val
	
	if is_inside_tree():
		target = get_node(_target) as Spatial


func _ready() -> void:
	init_target()


func _process(delta: float) -> void:
	update_position(delta)


func init_target() -> void:
	set_target_path(_target)
	assert(_target != "")
	assert(target != null)


func update_position(delta: float) -> void:
	#var forward: = global_transform.basis.z
	
	#var target_origin: = target.global_transform.origin
	#var self_origin: = global_transform.origin
	#var origin_diff: = target_origin - self_origin
	
	#var forward_diff: = origin_diff * forward
	
	#global_transform.origin = self_origin.linear_interpolate(
	#	self_origin + forward_diff + (forward * distance),
	#	speed * delta
	#)
	
	var target_origin: = target.global_transform.origin
	var self_origin: = global_transform.origin
	
	var origin_diff: = target_origin - self_origin
	var forward_diff: = forward.abs() * origin_diff
	
	global_transform.origin = self_origin.linear_interpolate(
		self_origin + forward_diff - (forward * distance),
		speed * delta
	)
