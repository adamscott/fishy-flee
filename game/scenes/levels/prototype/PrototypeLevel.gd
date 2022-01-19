extends Spatial

const Player: = preload("res://scenes/player/Player.gd")

export (float) var max_height: = 2.5
export (float) var max_side_width: = 2.5

onready var player: Player = $Player as Player


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	pass
