extends Node

signal main_menu

const YAFSM: = preload("res://addons/imjp94.yafsm/YAFSM.gd")
const StateMachinePlayer: = YAFSM.StateMachinePlayer

const Pause: = preload("res://scenes/menus/pause/Pause.gd")

const PROTOTYPE_LEVEL_PATH: = "res://scenes/levels/prototype/PrototypeLevel.tscn"

var level = null

onready var game_container: Node = $GameContainer
onready var game_viewport_container: ViewportContainer = $GameContainer/ViewportContainer
onready var pause: Pause = $Pause
onready var game_viewport: Viewport = $GameContainer/ViewportContainer/Viewport
onready var main_sm: StateMachinePlayer = $StateMachines/MainStateMachine


func get_is_loaded() -> bool:
	return Global.queue.is_ready(PROTOTYPE_LEVEL_PATH)


func _on_GameContainer_resized() -> void:
	update_game_viewport()


func _on_MainStateMachine_transited(from, to) -> void:
	prints("game from:", from, "to:", to)
	
	match from:
		"Loading":
			Global.hide_loading()
		"Pause":
			pause.hide()
			get_tree().paused = false
	
	match to:
		"Loading":
			Global.display_loading()
			Global.queue.queue_resource(PROTOTYPE_LEVEL_PATH)
		"Game":
			show_game()
		"Pause":
			pause.show()
			get_tree().paused = true


func _on_Pause_main_menu() -> void:
	prints("_on_pause_main_menu")
	emit_signal("main_menu")


func _on_Pause_unpause() -> void:
	main_sm.set_trigger("unpause")


func _ready() -> void:
	pause.hide()
	
	update_game_viewport()
	update_state_machines()
	update_loading()


func _process(delta: float) -> void:
	update_state_machines()
	update_pause()
	update_loading()


func update_game_viewport() -> void:
	if not is_inside_tree():
		return
	
	game_container = $GameContainer
	game_viewport_container = $GameContainer/ViewportContainer
	game_viewport = $GameContainer/ViewportContainer/Viewport
	
	game_viewport_container.rect_min_size = game_container.rect_size
	game_viewport.size = game_container.rect_size


func update_state_machines() -> void:
	main_sm.set_param("game_loaded", get_is_loaded())


func update_pause() -> void:
	if Input.is_action_just_pressed("pause"):
		main_sm.set_trigger("pause")


func update_loading() -> void:
	if main_sm.get_current() != "Loading":
		return
	
	Global.loading_value = Global.queue.get_progress(PROTOTYPE_LEVEL_PATH) * 100.0


func show_game() -> void:
	if not level:
		level = Global.queue.get_resource(PROTOTYPE_LEVEL_PATH).instance()
		game_viewport.add_child(level)
