extends Spatial

const Player: = preload("res://scenes/player/Player.gd")

export (float) var max_height: = 2.5
export (float) var max_side_width: = 2.5

onready var player: Player = $Player as Player


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	limit_player_height(delta)


func limit_player_height(delta: float) -> void:
	if player.global_transform.origin.y > max_height:
		player.global_transform.origin.y = max_height

	if player.global_transform.origin.x > max_side_width:
		player.global_transform.origin.x = max_side_width
	
	if player.global_transform.origin.x < -max_side_width:
		player.global_transform.origin.x = -max_side_width
