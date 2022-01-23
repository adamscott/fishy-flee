extends Node

const YAFSM: = preload("res://addons/imjp94.yafsm/YAFSM.gd")
const StateMachinePlayer: = YAFSM.StateMachinePlayer

const Loading = preload("res://scenes/loading/Loading.gd")

const PROTOTYPE_LEVEL_PATH: = "res://scenes/levels/prototype/PrototypeLevel.tscn"

var level = null

onready var loading: Loading = $Loading
onready var game_container: Node = $GameContainer
onready var game_viewport_container: ViewportContainer = $GameContainer/ViewportContainer
onready var game_viewport: Viewport = $GameContainer/ViewportContainer/Viewport
onready var main_sm: StateMachinePlayer = $StateMachines/MainStateMachine


func get_is_loaded() -> bool:
	return Global.queue.is_ready(PROTOTYPE_LEVEL_PATH)


func _on_GameContainer_resized() -> void:
	update_game_viewport()


func _on_MainStateMachine_transited(from, to) -> void:
	prints("game from:", from, "to:", to)
	
	match to:
		"Loading":
			loading.visible = true
			Global.queue.queue_resource(PROTOTYPE_LEVEL_PATH)
		"Game":
			loading.visible = false
			show_game()


func _ready() -> void:
	update_game_viewport()
	update_state_machines()
	update_loading()


func _process(delta: float) -> void:
	update_state_machines()


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


func update_loading() -> void:
	if main_sm.get_current() != "Loading":
		return
	
	loading.value = Global.queue.get_progress(PROTOTYPE_LEVEL_PATH) * 100.0


func show_game() -> void:
	level = Global.queue.get_resource(PROTOTYPE_LEVEL_PATH).instance()
	game_viewport.add_child(level)
