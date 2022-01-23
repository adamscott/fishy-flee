extends Node

signal start

onready var background: Control = $Background
onready var viewport_container: ViewportContainer = $Background/ViewportContainer
onready var viewport: Viewport = $Background/ViewportContainer/Viewport

onready var animation_player: AnimationPlayer = $AnimationPlayer

onready var main_sm: = $StateMachines/MainStateMachine


func _on_Background_resized() -> void:
	update_viewport()


func _on_MainStateMachine_transited(from, to) -> void:
	match to:
		"Menu":
			pass
		"Start":
			pass
		"Options":
			pass
		"Quit":
			get_tree().quit()
			return
	
	animation_player.play("%s->%s" % [from, to])


func _on_Menu_options() -> void:
	main_sm.set_trigger("options")


func _on_Menu_quit() -> void:
	main_sm.set_trigger("quit")


func _on_Menu_start() -> void:
	main_sm.set_trigger("start")


func _on_Options_back() -> void:
	main_sm.set_trigger("back")


func _ready() -> void:
	update_viewport()


func _process(delta: float) -> void:
	pass


func start() -> void:
	main_sm.restart(true, true)


func update_viewport() -> void:
	if not is_inside_tree():
		return
	
	background = $Background
	viewport_container = $Background/ViewportContainer
	viewport = $Background/ViewportContainer/Viewport
	
	viewport_container.rect_min_size = background.rect_size
	viewport.size = background.rect_size
