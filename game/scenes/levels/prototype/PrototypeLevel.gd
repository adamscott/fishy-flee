extends Spatial

const Player: = preload("res://scenes/player/Player.gd")

export (bool) var chasing_atmosphere: = false

onready var player: Player = $Player
onready var animation_player: AnimationPlayer = $AnimationPlayer


func _on_Part1CutsceneArea_body_entered(body: Node) -> void:
	if not (body is Player):
		return
	
	animation_player.play("cutscene_net_approaching")


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("skip_cutscene"):
		if animation_player.is_playing() and animation_player.current_animation == "cutscene_net_approaching":
			animation_player.seek(animation_player.current_animation_length - 0.01)


func _physics_process(delta: float) -> void:
	pass

