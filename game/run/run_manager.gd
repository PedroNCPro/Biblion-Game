extends Node

# this is the class that will deal with the flow of a run. It is responsible for establishing each step of the
# main gameplay loop, getting data from it and transitioning between scenes according to it. It will:
# - call random level creation
# - go to the "win coins" scene once the player finished the level, or to the game over one otherwise
# - go to the shop scene once the player obtained their coins
# - go to a new level after the player leaves the shop
# That means that for all the buttons the player presses to go from one scene to another, the one class that deals with those
# signals is this one
@export var run_progression_list: Array[RunProgression]
@export var level_generator: LevelGenerator

# allPowerUps should be updated during shop phase
@onready var allPowerUps : Dictionary[String, LetterPowerUp] = {}
var power_ups: Array[ShopItem]
var current_difficulty: RunProgression
var current_level := 1
var point_threshold := 0
var coins := 0


# NOTE: this script needs to:
# - go to win screen when level is won
# - go to game over screen when level is failed
# - go to shop when button is pressed on win screen
# - generate a new level when exiting shop

func _create_next_level() -> Node:
	if current_difficulty == null:
		current_difficulty = run_progression_list[0]
	level_generator.min_word_size = current_difficulty.min_word_size
	level_generator.max_word_size = current_difficulty.max_word_size
	level_generator.attempts = current_difficulty.attempts
	point_threshold += current_difficulty.point_threshold_increase
	level_generator.point_threshold = point_threshold
	level_generator.current_level = current_level
	for difficulty in run_progression_list:
		if current_level >= difficulty.level_start:
			current_difficulty = difficulty
	return level_generator.generate_level()


func _on_level_manager_level_lost() -> void:
	pass


func _on_level_manager_level_won() -> void:
	GameState.coins += 5


func _on_shop_manager_next_level_pressed(next_level: LevelTemplate) -> void:
	next_level.setup_level_inventory()
	SceneSwitcher._change_to_scene(next_level)


func _on_winning_menu_next_level_pressed() -> void:
	current_level += 1
	SceneSwitcher.go_to_shop()


func _on_main_menu_play_pressed() -> void:
	RunManager.current_level = 1
	RunManager.coins = 0
	SceneSwitcher._change_to_scene(_create_next_level())

func _on_menu_tab_leave_pressed():
	SceneSwitcher.go_to_main_menu()

func _on_main_menu_continue_pressed():
	SceneSwitcher._change_to_scene(_create_next_level())


func _on_shop_manager_item_bought(item: ShopItem) -> void:
	for i in range(len(power_ups)):
		if power_ups[i].item_name == item.item_name:
			power_ups.remove_at(i)
			break
	power_ups.append(item)
