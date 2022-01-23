extends CenterContainer

signal start
signal options
signal quit

onready var start_btn: Button = $VBoxContainer/Start
onready var options_btn: Button = $VBoxContainer/Options
onready var quit_btn: Button = $VBoxContainer/Quit


func _on_Options_pressed() -> void:
	emit_signal("options")


func _on_Start_pressed() -> void:
	emit_signal("start")


func _on_Quit_pressed() -> void:
	emit_signal("quit")


func _ready() -> void:
	start_btn.grab_focus()
