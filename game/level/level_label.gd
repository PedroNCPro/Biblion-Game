extends RichTextLabel

## Script for the LevelLabel to automatically update when GameState changes.
func _ready() -> void:
	var game_state = get_node("../GameState") as GameState
	
	if game_state:
		game_state.level_changed.connect(_on_level_changed)
		
		_on_level_changed(game_state.level)
	else:
		push_error("LevelLabel: GameState node not found!")

## Called whenever the level_changed signal is emitted.
## [param new_level]: The integer value of the new level.
func _on_level_changed(new_level: int) -> void:
	text = "Level: " + str(new_level)
