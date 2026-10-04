extends Control
class_name MainMenuUI

signal play_pressed


## Minimal MainMenuUI
func _ready() -> void:
	pass

func _on_button_button_up() -> void:
	play_pressed.emit()
