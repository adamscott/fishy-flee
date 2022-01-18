extends Node

const MIN_ROTATION_BOOM: = deg2rad(-80.0)
const MAX_ROTATION_BOOM: = deg2rad(80.0)

export (NodePath) var _target: NodePath
export (bool) var current: = false setget set_current
export (float) var roll: = 0.0
export (float) var rotation_speed: = PI / 2.0

onready var target: Spatial = get_node(_target) as Spatial setget set_target
onready var camera_roll: Spatial = $CameraRoll
onready var camera_pivot: Spatial = $CameraRoll/CameraPivot
onready var camera_boom: Spatial = $CameraRoll/CameraPivot/CameraBoom
onready var camera: Camera = $CameraRoll/CameraPivot/CameraBoom/SpringArm/Camera

var capturing_mouse: = false setget set_capturing_mouse
var mouse_input: Vector2 = Vector2.ZERO


func set_current(val: bool) -> void:
	current = val
	$CameraRoll/CameraPivot/CameraBoom/SpringArm/Camera.current = current


func _ready() -> void:
	assert(_target != "")
	yield(get_tree(), "idle_frame")
	camera_roll.global_transform.origin = target.global_transform.origin


func _input(event: InputEvent) -> void:
	if capturing_mouse:
		process_capturing_input(event)
	else:
		process_non_capturing_input(event)


func _process(delta: float) -> void:
	process_roll(delta)
	process_translation(delta)
	process_input(delta)
	process_auto_rotation(delta)
	
	mouse_input = Vector2.ZERO


func process_capturing_input(event: InputEvent) -> void:
	if event.is_action_released("camera_move"):
		set_capturing_mouse(false)
		return
	
	if event is InputEventMouseMotion:
		mouse_input += event.relative


func process_non_capturing_input(event: InputEvent) -> void:
	if event.is_action_pressed("camera_move"):
		set_capturing_mouse(true)


func process_roll(delta: float) -> void:
	camera_roll.transform = camera_roll.transform.interpolate_with(
		camera_roll.transform.rotated(Vector3.FORWARD, deg2rad(roll)),
		rotation_speed * delta
	)


func process_translation(delta: float) -> void:
	camera_roll.global_transform.origin = camera_roll.global_transform.origin.linear_interpolate(
		target.global_transform.origin,
		rotation_speed * delta
	)


func process_input(delta: float) -> void:
	var mouse_invert: Vector2 = ProjectSettings.get_setting("game/input/camera/mouse/invert")
	var mouse_acc: Vector2 = ProjectSettings.get_setting("game/input/camera/mouse/acceleration")
	var mouse_sensitivity: float = ProjectSettings.get_setting("game/input/camera/mouse/sensitivity")
	
	var joystick_invert: Vector2 = ProjectSettings.get_setting("game/input/camera/joystick/invert")
	var joystick_acc: Vector2 = ProjectSettings.get_setting("game/input/camera/joystick/acceleration")
	var joystick_sensitivity: float = ProjectSettings.get_setting("game/input/camera/joystick/sensitivity")
	
	var joystick_input: = Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")
	
	mouse_input.x = mouse_input.x * mouse_invert.x * mouse_acc.x * mouse_sensitivity
	mouse_input.y = mouse_input.y * mouse_invert.y * mouse_acc.y * mouse_sensitivity
	
	joystick_input.x = joystick_input.x * joystick_invert.x * joystick_acc.x * joystick_sensitivity
	joystick_input.y = joystick_input.y * joystick_invert.y * joystick_acc.y * joystick_sensitivity
	
	var input: = mouse_input + joystick_input
	
	camera_pivot.rotate_object_local(Vector3.UP, input.x * delta)
	camera_boom.rotate_object_local(Vector3.RIGHT, input.y * delta)
	
	camera_boom.rotation.x = clamp(camera_boom.rotation.x, MIN_ROTATION_BOOM, MAX_ROTATION_BOOM)


func process_auto_rotation(delta: float) -> void:
	var camera_origin: = camera.global_transform.origin
	var target_origin: = target.global_transform.origin
	
	var angle: = camera_origin.signed_angle_to(target_origin, Vector3.UP)
	var angle_deg: = rad2deg(angle)
	prints(angle_deg)
	if abs(angle_deg) < 10.0:
		return


func set_capturing_mouse(val: bool) -> void:
	capturing_mouse = val
	
	if capturing_mouse:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func set_target(val: Spatial) -> void:
	target = val
