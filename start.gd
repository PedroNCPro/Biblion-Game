extends Node
# This scene is supposed to be set as the first one to run when the game is lauched,
# so that it can correctly initialize SceneSwitcher for its use afterwards


func _ready() -> void:
	SceneSwitcher.current_scene_root = self
	SceneSwitcher.go_to_main_menu()
