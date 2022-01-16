extends KinematicBody

const YAFSM: = preload("res://addons/imjp94.yafsm/YAFSM.gd")
const StateMachinePlayer: = YAFSM.StateMachinePlayer

export (Vector3) var up_direction: = Vector3.UP
export (float) var speed: = 20.0
export (float) var min_velocity: = 0.3
export (float) var max_velocity_horizontal: = 5.0
export (float) var max_velocity_vertical: = 2.0
export (float) var friction: = 0.5

onready var move_sm: StateMachinePlayer = $StateMachines/MoveStateMachine as StateMachinePlayer

var velocity: = Vector3.ZERO
var acceleration: = Vector3.ZERO

var input_direction: = Vector3.ZERO
var move_direction: = Vector3.ZERO


func _on_MoveStateMachine_transited(from, to) -> void:
	match to:
		"Idle":
			pass
		"Move":
			pass


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	process_input(delta)


func _physics_process(delta: float) -> void:
	process_physics(delta)


func process_input(delta: float) -> void:
	var cardinal_input: = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	input_direction = Vector3(
		cardinal_input.x,
		Input.get_action_strength("move_up") - Input.get_action_strength("move_down"),
		cardinal_input.y
	)
	
	var camera: = get_viewport().get_camera()
	
	var target_position_on_screen: = camera.unproject_position(global_transform.origin)
	var ray_origin: = camera.project_local_ray_normal(target_position_on_screen)
	var faraway: = camera.project_position(target_position_on_screen, camera.far)
	
	var camera_transform: = Transform(camera.global_transform.basis, ray_origin)
	var camera_vertical: = camera_transform.origin * up_direction
	var target_vertical: = global_transform.origin * up_direction
	camera_transform.origin = camera_transform.origin - camera_vertical + target_vertical
	
	camera_transform.looking_at(faraway, up_direction)
	
	var not_up_mask: = Vector3.ONE - up_direction
	var direction_right: = camera_transform.basis.x * input_direction.x * not_up_mask
	var direction_up: = camera_transform.basis.y * input_direction.y * up_direction
	var direction_forwards: = camera_transform.basis.z * input_direction.z * not_up_mask
	
	move_direction = (direction_right + direction_up + direction_forwards).normalized()


func process_physics(delta: float) -> void:
	process_physics_before_gravity(delta)
	process_physics_gravity(delta)
	process_physics_after_gravity(delta)
	
	process_physics_before_move_and_slide(delta)
	process_physics_move_and_slide(delta)
	process_physics_after_move_and_slide(delta)


func process_physics_before_gravity(delta: float) -> void:
	apply_rotation(delta)
	apply_movement(delta)
	apply_friction(delta)


func process_physics_gravity(delta: float) -> void:
	pass


func process_physics_after_gravity(delta: float) -> void:
	pass


func process_physics_before_move_and_slide(delta: float) -> void:
	pass


func process_physics_move_and_slide(delta: float) -> void:
	if velocity.length_squared() < min_velocity * min_velocity:
		velocity = Vector3.ZERO
	
	var integrated: = velocity + acceleration
	
	var integrated_vertical: = up_direction * integrated
	var integrated_horizontal: = integrated - integrated_vertical

	prints(integrated_horizontal, integrated_vertical)

	if integrated_horizontal.length_squared() > max_velocity_horizontal * max_velocity_horizontal:
		integrated_horizontal = integrated_horizontal.normalized() * max_velocity_horizontal

	if integrated_vertical.length_squared() > max_velocity_vertical * max_velocity_vertical:
		integrated_vertical = integrated_vertical.normalized() * max_velocity_vertical
	
	integrated = integrated_vertical + integrated_horizontal
	
	velocity = move_and_slide(integrated, up_direction, true)
	acceleration = Vector3.ZERO


func process_physics_after_move_and_slide(delta: float) -> void:
	pass


func apply_rotation(delta: float) -> void:
	pass


func apply_movement(delta: float) -> void:
	acceleration = move_direction * speed * delta


func apply_friction(delta: float) -> void:
	velocity = velocity.linear_interpolate(
		Vector3.ZERO,
		friction * delta
	)
