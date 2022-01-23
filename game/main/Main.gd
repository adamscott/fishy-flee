extends Node

const YAFSM: = preload("res://addons/imjp94.yafsm/YAFSM.gd")
const StateMachinePlayer: = YAFSM.StateMachinePlayer

const Loading: = preload("res://scenes/menus/loading/Loading.gd")

const Intro: = preload("res://scenes/intro/Intro.gd")
const MainMenu: = preload("res://scenes/menus/main_menu/MainMenu.gd")

const INTRO_PATH: = "res://scenes/intro/Intro.tscn"
const MAIN_MENU_PATH: = "res://scenes/menus/main_menu/MainMenu.tscn"
const GAME_PATH: = "res://scenes/game/Game.tscn"

var intro: Intro = null
var main_menu: MainMenu = null
var game = null

var async_shaders_timer_done: = false
var intro_ended: = false
var start_game: = false

onready var loading: Loading = $Loading
onready var intro_container: Node = $IntroContainer
onready var main_menu_container: Node = $MainMenuContainer
onready var game_container: Node = $GameContainer
onready var main_sm: StateMachinePlayer = $StateMachines/MainStateMachine


func _on_Root_size_changed() -> void:
	update_root_viewport_size()


func _on_AsyncShadersTimer_timeout() -> void:
	async_shaders_timer_done = true


func _on_MainStateMachine_transited(from, to) -> void:
	prints("on mainstatemachine transited", from, to)
	
	match from:
		"Loading":
			loading.visible = false
		"Intro":
			hide_intro()
		"MainMenu":
			hide_main_menu()
		"Game":
			hide_game()

	match to:
		"Loading":
			load_intro()
			load_main_menu()
			load_game()
		"Intro":
			show_intro()
		"MainMenu":
			get_tree().paused = false
			intro_ended = false
			show_main_menu()
		"Game":
			start_game = false
			show_game()


func _on_Intro_intro_end() -> void:
	intro_ended = true


func _on_MainMenu_start() -> void:
	start_game = true


func _on_Game_main_menu() -> void:
	main_sm.set_trigger("main_menu")


func _ready() -> void:
	get_tree().get_root().connect("size_changed", self, "_on_Root_size_changed")
	Global.main = self


func _process(delta: float) -> void:
	update_progress_bar(delta)
	update_state_machines(delta)


func update_root_viewport_size() -> void:
	get_tree().get_root().size = OS.window_size


func load_intro() -> void:
	Global.queue.queue_resource(INTRO_PATH)


func load_main_menu() -> void:
	Global.queue.queue_resource(MAIN_MENU_PATH)


func load_game() -> void:
	Global.queue.queue_resource(GAME_PATH)


func show_intro() -> void:
	intro = Global.queue.get_resource(INTRO_PATH).instance()
	intro.connect("intro_end", self, "_on_Intro_intro_end")
	intro_container.add_child(intro)


func hide_intro() -> void:
	intro_container.remove_child(intro)
	intro.queue_free()


func show_main_menu() -> void:
	if not main_menu:
		main_menu = Global.queue.get_resource(MAIN_MENU_PATH).instance()
		main_menu.connect("start", self, "_on_MainMenu_start")
	main_menu_container.add_child(main_menu)
	main_menu.start()


func hide_main_menu() -> void:
	main_menu_container.remove_child(main_menu)


func show_game() -> void:
	if not game:
		game = Global.queue.get_resource(GAME_PATH).instance()
		game.connect("main_menu", self, "_on_Game_main_menu")
	game_container.add_child(game)


func hide_game() -> void:
	game_container.remove_child(game)
	game.queue_free()
	game = null


func update_progress_bar(delta: float) -> void:
	var intro_progress: float = Global.queue.get_progress(INTRO_PATH)
	var main_menu_progress: float = Global.queue.get_progress(MAIN_MENU_PATH)
	var game_progress: float = Global.queue.get_progress(GAME_PATH)
	
	loading.value = intro_progress * 100


func update_state_machines(delta: float) -> void:
	var intro_progress: float = Global.queue.get_progress(INTRO_PATH)
	var main_menu_progress: float = Global.queue.get_progress(MAIN_MENU_PATH)
	var game_progress: float = Global.queue.get_progress(GAME_PATH)
	
	main_sm.set_param("intro_loaded", intro_progress >= 1.0)
	main_sm.set_param("main_menu_loaded", main_menu_progress >= 1.0)
	main_sm.set_param("game_loaded", game_progress >= 1.0)
	
	main_sm.set_param("async_shaders_timer_done", async_shaders_timer_done)
	main_sm.set_param("intro_ended", intro_ended)
	main_sm.set_param("start_game", start_game)


func get_state() -> Dictionary:
	return {
		"main": main_sm.get_current()
	}
