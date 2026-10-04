extends Node2D

@export var main_menu_ui : MainMenuUI
@export var level : Level

var current_state : = UIState.MAIN_MENU

enum UIState{
	MAIN_MENU,
	PLAYING
}

func change_state(target_state : UIState):
	_exit_state(current_state)
	current_state = target_state
	_enter_state(current_state)
	
func _exit_state(state : UIState):
	if (state == UIState.MAIN_MENU):
		main_menu_ui.hide()
	elif (state == UIState.PLAYING):
		level.hide()
	
func _enter_state(state : UIState):
	if (state == UIState.MAIN_MENU):
		main_menu_ui.show()
	elif (state == UIState.PLAYING):
		level.show()
		level.new_game()
	
func _ready():
	main_menu_ui.play.connect(func(): change_state(UIState.PLAYING))
	level.return_to_main_menu.connect(func(): change_state(UIState.MAIN_MENU))
	change_state(current_state)
