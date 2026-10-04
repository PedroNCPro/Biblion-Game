extends Node2D
class_name LevelTemplate

# NOTE this script DOES NOT deal with run logic (creating one level after this one)
# This script's sole purpose is to organize the elements visually on the screen for the level. That means:
# - taking a grid, a keyboard, and a background node, and organizing the UI visually
# - making all signal connections needed for the interaction to work
# - initiating all the components of the level accordingly
# What this script DOES NOT do:
# - keep updating the UI (the ones who _should_ do this are specialized scripts, such as [for example] PointsLabel, LetterBox, Grid...)


@export var winning_menu: WinningMenuUI
@export var game_over_ui: Control
@export var level_label: Label
@export var grid: Grid
@export var keyboard: Keyboard
@export var background: ColorRect
@export var level_manager: LevelManager
@export var blackout: ColorRect
@export var sub_viewport: SubViewport
@export var sub_viewport_container: SubViewportContainer
@export var camera: Camera2D
@export var point_threshold_label: Label
@export var point_threshold: int
@export var inventory : LevelInventory


var words_list : Array = []


## Sets up the current level's UI elements. It assumes [member LevelTemplate.grid], [member LevelTemplate.keyboard] and
## [member LevelTemplate.background] are set.
func setup() -> void:
	sub_viewport.add_child(grid)
	add_child(keyboard)
	add_child(background)

	move_child(background, 0)
	#move_child(sub_viewport_container, -1)
	move_child(keyboard, -1)
	move_child(inventory,-1)

	grid.grid_gestures.camera = camera
	inventory.setup()
	
	blackout.size = Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width"), 
		ProjectSettings.get_setting("display/window/size/viewport_height")
	)
	point_threshold_label.text = "/" + str(point_threshold)
	move_child(blackout, -1)
	move_child(game_over_ui, -1)
	move_child(winning_menu, -1)
	#grid.position = Vector2(129, 230)
	keyboard.set_anchors_preset(Control.LayoutPreset.PRESET_CENTER)
	keyboard.position = Vector2(325, 971)

	level_manager.grid = grid
	level_manager.keyboard = keyboard
	level_manager.point_threshold = point_threshold

	level_manager.choose_secret_word()


func setup_level_inventory() -> void:
	inventory.setup()


func _on_return_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://game/main_menu/main_menu.tscn")


func _on_restart_game_button_pressed() -> void:
	RunManager.point_threshold = 0
	RunManager._on_main_menu_play_pressed()
