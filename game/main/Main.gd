extends Node

const YAFSM: = preload("res://addons/imjp94.yafsm/YAFSM.gd")
const StateMachinePlayer: = YAFSM.StateMachinePlayer
const Intro: = preload("res://scenes/intro/Intro.gd")
const MainMenu: = preload("res://scenes/menus/main_menu/MainMenu.gd")

const INTRO_PATH: = "res://scenes/intro/Intro.tscn"
const MAIN_MENU_PATH: = "res://scenes/menus/main_menu/MainMenu.tscn"
const PROTOTYPE_LEVEL_PATH: = "res://scenes/levels/prototype/PrototypeLevel.tscn"

var intro: Intro = null
var main_menu: MainMenu = null

var intro_ended: = false

onready var loading_control: Control = $Loading
onready var loading_progress_bar: ProgressBar = $Loading/MarginContainer/ProgressBar
onready var intro_container: Node = $IntroContainer
onready var main_menu_container: Node = $MainMenuContainer
onready var main_sm: StateMachinePlayer = $StateMachines/MainStateMachine


func _on_MainStateMachine_transited(from, to) -> void:
	prints("mainstatemachine transited from", from, "to", to)

	match to:
		"Loading":
			load_intro()
			load_main_menu()
		"Intro":
			show_intro()
		"MainMenu":
			show_main_menu()


func _on_Intro_intro_end() -> void:
	intro_ended = true


func _ready() -> void:
	# loading_control.visible = false
	pass


func _process(delta: float) -> void:
	update_progress_bar(delta)
	update_state_machines(delta)


func load_intro() -> void:
	prints("load intro")
	Global.queue.queue_resource(INTRO_PATH)


func load_main_menu() -> void:
	prints("load main menu")
	Global.queue.queue_resource(MAIN_MENU_PATH)


func show_intro() -> void:
	prints("show intro")
	intro = Global.queue.get_resource(INTRO_PATH).instance()
	intro.connect("intro_end", self, "_on_Intro_intro_end")
	intro_container.add_child(intro)


func show_main_menu() -> void:
	intro_container.remove_child(intro)
	intro.queue_free()
	
	main_menu = Global.queue.get_resource(MAIN_MENU_PATH).instance()
	main_menu_container.add_child(main_menu)


func update_progress_bar(delta: float) -> void:
	pass


func update_main_menu_progress_bar(delta: float) -> void:
	loading_progress_bar.value = Global.queue.get_progress(MAIN_MENU_PATH) * 100


func update_state_machines(delta: float) -> void:
	var intro_progress: float = Global.queue.get_progress(INTRO_PATH)
	var main_menu_progress: float = Global.queue.get_progress(MAIN_MENU_PATH)
	
	main_sm.set_param("intro_loaded", intro_progress >= 1.0)
	main_sm.set_param("main_menu_loaded", main_menu_progress >= 1.0)
	
	main_sm.set_param("intro_ended", intro_ended)


func get_state() -> Dictionary:
	return {
		"main": main_sm.get_current()
	}
