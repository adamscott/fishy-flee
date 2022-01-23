extends Control

signal unpause
signal main_menu


func _on_ReturnToGame_pressed() -> void:
	emit_signal("unpause")


func _on_MainMenu_pressed() -> void:
	emit_signal("main_menu")


func _on_Quit_pressed() -> void:
	get_tree().quit()


func _ready() -> void:
	pass


func show() -> void:
	$CenterContainer/Panel/CenterContainer/VBoxContainer/VBoxContainer/ReturnToGame.grab_focus()
	.show()
