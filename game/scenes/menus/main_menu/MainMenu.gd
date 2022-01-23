extends Node

onready var center_container: CenterContainer = $CenterContainer
onready var viewport_container: ViewportContainer = $CenterContainer/ViewportContainer
onready var viewport: Viewport = $CenterContainer/ViewportContainer/Viewport

onready var animation_player: AnimationPlayer = $AnimationPlayer

onready var main_sm: = $StateMachines/MainStateMachine


func _on_CenterContainer_resized() -> void:
	update_viewport()


func _on_MainStateMachine_transited(from, to) -> void:
	match to:
		"Menu":
			pass
		"Options":
			pass
		"Quit":
			get_tree().quit()
			return
	
	animation_player.play("%s->%s" % [from, to])


func _on_Menu_options() -> void:
	prints("on menu options")
	main_sm.set_trigger("options")


func _on_Menu_quit() -> void:
	prints("on menu quit")
	main_sm.set_trigger("quit")


func _on_Menu_start() -> void:
	prints("on menu start")
	main_sm.set_trigger("start")


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	update_viewport()


func update_viewport() -> void:
	if not is_inside_tree():
		return
	
	center_container = $CenterContainer
	viewport_container = $CenterContainer/ViewportContainer
	viewport = $CenterContainer/ViewportContainer/Viewport
	
	viewport_container.rect_min_size = center_container.rect_size
	viewport.size = center_container.rect_size
