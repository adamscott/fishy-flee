extends Node

signal intro_end

const YAFSM: = preload("res://addons/imjp94.yafsm/YAFSM.gd")
const StateMachinePlayer: = YAFSM.StateMachinePlayer

onready var main_sm: StateMachinePlayer = $StateMachines/MainStateMachine


func _on_MainStateMachine_transited(from, to) -> void:
	match to:
		"Godot":
			$AnimationPlayer.play("Godot")
		"Gwj":
			$AnimationPlayer.play("Gwj")
		"AdamScott":
			$AnimationPlayer.play("AdamScott")
		"End":
			emit_signal("intro_end")


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("skip_cutscene"):
		main_sm.set_trigger("skip_cutscene")
