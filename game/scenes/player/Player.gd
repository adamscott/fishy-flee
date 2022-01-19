tool
extends KinematicBody

const YAFSM: = preload("res://addons/imjp94.yafsm/YAFSM.gd")
const StateMachinePlayer: = YAFSM.StateMachinePlayer

export (Vector3) var up_direction: = Vector3.UP
export (float) var speed: = 19.0
export (float) var min_velocity_horizontal: = 0.3
export (float) var min_velocity_vertical: = 0.1
export (float) var max_velocity_horizontal: = 2.5
export (float) var max_velocity_vertical: = 1.0
export (float) var friction_horizontal: = 0.8
export (float) var friction_vertical: = 1.0
export (float) var rotation_speed_factor: = PI * 2.0
export (float) var rush_velocity: = 10.0

var velocity: = Vector3.ZERO
var acceleration: = Vector3.ZERO

var input_direction: = Vector3.ZERO
var move_direction: = Vector3.ZERO

onready var skin: Spatial = $Skin

onready var main_sm: StateMachinePlayer = $StateMachines/MainStateMachine as StateMachinePlayer
onready var move_sm: StateMachinePlayer = $StateMachines/MainStateMachine/MoveStateMachine as StateMachinePlayer
onready var charge_sm: StateMachinePlayer = $StateMachines/MainStateMachine/ChargeStateMachine as StateMachinePlayer

onready var shadow_raycast: RayCast = $RayCastsContainer/RayCasts/ShadowRayCast as RayCast
onready var shadow_sprite3D: Sprite3D = $RayCastsContainer/RayCasts/ShadowRayCast/Shadow as Sprite3D

onready var salmon_at: AnimationTree = $Skin/Salmon/AnimationTree as AnimationTree

onready var charge_rush_timer: Timer = $Timers/ChargeRushTimer as Timer


func _on_MainStateMachine_transited(from, to) -> void:
	move_sm.active = false
	charge_sm.active = false
	
	match to:
		"Move":
			move_sm.restart(true, true)
		"Charge":
			charge_sm.restart(true, true)


func _on_MoveStateMachine_transited(from, to) -> void:
	salmon_at["parameters/active/velocity_timescale/scale"] = 1.0
	
	match to:
		"Idle":
			pass
		"Move":
			pass


func _on_ChargeStateMachine_transited(from, to) -> void:
	prints(to)
	match to:
		"Charging":
			salmon_at["parameters/active/charge_oneshot/active"] = true
		"Rush":
			apply_charge_rush()


func _on_Salmon_charging_animation_end() -> void:
	charge_sm.set_trigger("charging_end")


func _on_ChargeRushTimer_timeout() -> void:
	main_sm.set_trigger("charge_end")


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	process_shadow(delta)
	
	if Engine.editor_hint:
		return
	
	process_input(delta)
	process_animation(delta)


func _physics_process(delta: float) -> void:
	if Engine.editor_hint:
		return
	
	process_physics(delta)


func get_state() -> Dictionary:
	return {
		"main": main_sm.get_current(),
		"move": move_sm.get_current(),
		"charge": charge_sm.get_current()
	}


func process_input(delta: float) -> void:
	update_camera(delta)
	update_charge(delta)


func process_animation(delta: float) -> void:
	var ratio_horizontal: = velocity.length() / max_velocity_horizontal
	salmon_at["parameters/active/velocity/blend_position"] = ratio_horizontal


func process_shadow(delta: float) -> void:
	shadow_raycast = $RayCastsContainer/RayCasts/ShadowRayCast
	shadow_sprite3D = $RayCastsContainer/RayCasts/ShadowRayCast/Shadow
	
	if not shadow_raycast.is_colliding():
		shadow_sprite3D.visible = false
		return
	
	var collision_point: = shadow_raycast.get_collision_point()
	var collision_normal: = shadow_raycast.get_collision_normal()
	
	shadow_sprite3D.visible = true
	shadow_sprite3D.global_transform.origin = collision_point + (up_direction.normalized() * 0.1)


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
	apply_rotation_redirection(delta)
	apply_charging(delta)


func process_physics_gravity(delta: float) -> void:
	pass


func process_physics_after_gravity(delta: float) -> void:
	pass


func process_physics_before_move_and_slide(delta: float) -> void:
	pass


func process_physics_move_and_slide(delta: float) -> void:
	var vertical_velocity = velocity * up_direction
	var horizontal_velocity = velocity - vertical_velocity
	
	if horizontal_velocity.length_squared() < min_velocity_horizontal * min_velocity_horizontal:
		horizontal_velocity = Vector3.ZERO
	
	if vertical_velocity.length_squared() < min_velocity_vertical * min_velocity_vertical:
		vertical_velocity = Vector3.ZERO
	
	velocity = horizontal_velocity + vertical_velocity
	
	var integrated: = velocity + acceleration
	
	match get_state():
		{ "main": "Charge", "charge": "Rush", .. }:
			pass
		_:
			var integrated_vertical: = up_direction * integrated
			var integrated_horizontal: = integrated - integrated_vertical
			
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
	match get_state():
		{ "main": "Charge", "charge": "Rush", .. }:
			return
	
	if move_direction.is_equal_approx(Vector3.ZERO):
		return

	var target_direction: = global_transform.looking_at(
		global_transform.origin + move_direction, 
		up_direction
	)
	global_transform = global_transform.interpolate_with(target_direction, rotation_speed_factor * delta)


func apply_movement(delta: float) -> void:
	match get_state():
		{ "main": "Charge", .. }:
			return
	
	var vertical_direction: = move_direction * up_direction
	var horizontal_direction: = move_direction - vertical_direction
	acceleration += -global_transform.basis.z * horizontal_direction.length() * speed * delta


func apply_friction(delta: float) -> void:
	var vertical_velocity: = velocity * up_direction
	var horizontal_velocity: = velocity - vertical_velocity
	
	vertical_velocity = vertical_velocity.linear_interpolate(
		Vector3.ZERO,
		friction_vertical * delta
	)
	
	horizontal_velocity = horizontal_velocity.linear_interpolate(
		Vector3.ZERO,
		friction_horizontal * delta
	)
	
	velocity = horizontal_velocity + vertical_velocity


func apply_rotation_redirection(delta: float) -> void:
	var forward: = -global_transform.basis.z
	velocity = forward.normalized() * velocity.length()


func apply_charging(delta: float) -> void:
	match get_state():
		{ "main": "Charge", "charge": "Charging", .. }:
			pass
		_:
			return
	
	if velocity.length_squared() < 0.5 * 0.5:
		velocity = Vector3.ZERO
		return
	
	velocity = velocity.linear_interpolate(
		Vector3.ZERO,
		10.0 * delta
	)


func update_camera(delta: float) -> void:
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


func update_charge(delta: float) -> void:
	if Input.is_action_just_pressed("charge"):
		main_sm.set_trigger("charge")


func apply_charge_rush() -> void:
	acceleration += global_transform.basis.z * rush_velocity
	salmon_at["parameters/active/velocity_timescale/scale"] = 2.0
	charge_rush_timer.start()
