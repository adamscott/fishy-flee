extends Spatial

signal main_menu

const Player: = preload("res://scenes/player/Player.gd")

export (bool) var chasing_atmosphere: = false

onready var player: Player = $Player
onready var animation_player: AnimationPlayer = $AnimationPlayer

onready var position_start: Position3D = $Position/Start
onready var position_end: Position3D = $Position/End

onready var pursuit_fish_animation_tree: AnimationTree = $GUI/Pursuit/MarginContainer/ColorRect/VBoxContainer/Fish/AnimationTree
onready var pursuit_net_animation_tree: AnimationTree = $GUI/Pursuit/MarginContainer/ColorRect/VBoxContainer2/Net/AnimationTree


func _on_Part1CutsceneArea_body_entered(body: Node) -> void:
	if not (body is Player):
		return
	
	animation_player.play("cutscene_net_approaching")


func _on_FishingNetArea_body_entered(body: Node) -> void:
	if not (body is Player):
		return
	
	animation_player.play("game_over")


func _on_ReturnToMainMenu_pressed() -> void:
	emit_signal("main_menu")


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	update_skip_cutscene()
	update_pursuit_gui()


func _physics_process(delta: float) -> void:
	pass


func update_skip_cutscene() -> void:
	if Input.is_action_just_pressed("skip_cutscene"):
		if animation_player.is_playing() and animation_player.current_animation == "cutscene_net_approaching":
			animation_player.play("cutscene_net_approaching_skip")


func update_pursuit_gui() -> void:
	var player_distance_to_end: = player.global_transform.origin.distance_to(position_end.global_transform.origin)
	var pursuit_distance: = position_start.global_transform.origin.distance_to(position_end.global_transform.origin)
	
	pursuit_fish_animation_tree["parameters/blend_position"] = player_distance_to_end / pursuit_distance
	# pursuit_net_animation_tree["parameters/blend_position"] = player_distance_to_end / pursuit_distance
